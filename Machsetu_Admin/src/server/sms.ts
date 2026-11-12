import bcrypt from "bcryptjs";

import { otps } from "./db";

/**
 * OTP delivery over SMS, through SMS Indori.
 *
 * India's DLT rules only let a message through when it matches a registered
 * template word for word, from a registered sender, through a bound
 * telemarketer chain. The template below is the one approved on the Airtel
 * DLT portal for ELIVOR VALVES; change it there first, then here.
 *
 * Until SMSINDORI_KEY is set the code falls back to a fixed number so local
 * work and testing still run — `smsIsLive()` says which mode is in force.
 */
const ENDPOINT = "http://sms.smsindori.com/http-tokenkeyapi.php";

const KEY = process.env.SMSINDORI_KEY?.trim() ?? "";
const SENDER = process.env.SMSINDORI_SENDER?.trim() || "ELIVOR";
const TEMPLATE_ID =
  process.env.SMSINDORI_TEMPLATE_ID?.trim() || "1077453050123323726";
/** The route SMS Indori assigned this account for transactional OTPs. */
const ROUTE = process.env.SMSINDORI_ROUTE?.trim() || "06";

/** DLT template 1077453050123323726, exactly as approved. */
const TEMPLATE =
  "{#numeric#} is your OTP for MachSetu login. Valid for 10 minutes. Do not share it with anyone. - ELIVOR VALVES";

/** The stand-in used only while no gateway is configured. */
const FALLBACK_OTP = process.env.DEFAULT_OTP ?? "123456";

/** How long a code stays valid — the template promises 10 minutes. */
export const OTP_TTL_MINUTES = 10;

/** A number can't ask for a new code more often than this. */
const COOLDOWN_SECONDS = 30;

/** Nor more than this many times in an hour — every send costs a credit. */
const MAX_SENDS_PER_HOUR = 5;

/** True once a real gateway is configured; false means the fixed code. */
export function smsIsLive(): boolean {
  return KEY !== "";
}

/** Six digits, evenly distributed, from the platform's secure source. */
function newCode(): string {
  const bytes = crypto.getRandomValues(new Uint32Array(1));
  return String(bytes[0] % 1_000_000).padStart(6, "0");
}

/**
 * SMS Indori answers 200 whether or not it takes the message, so success is
 * read from the body: an accepted message comes back as
 * "msg-id : MzY0MDY5MQ==", and anything else ("Please Provide valid
 * routeid", "Provide valid Authentic Token Key.") is a refusal.
 */
const ACCEPTED = /^msg-id\s*:/i;

/**
 * Hands one OTP to SMS Indori. Returns null when it was accepted, or a
 * message saying why it wasn't.
 */
async function deliver(phone: string, code: string): Promise<string | null> {
  const params = new URLSearchParams({
    "authentic-key": KEY,
    senderid: SENDER,
    route: ROUTE,
    number: `91${phone}`,
    message: TEMPLATE.replace("{#numeric#}", code),
    templateid: TEMPLATE_ID,
  });

  try {
    const response = await fetch(`${ENDPOINT}?${params}`, {
      signal: AbortSignal.timeout(15_000),
    });
    const body = (await response.text()).trim();

    // Logged without the key, so the desk can see what the gateway said.
    console.info(`SMS to ******${phone.slice(-4)}: ${response.status} ${body.slice(0, 200)}`);

    if (!response.ok || !ACCEPTED.test(body)) {
      return "We couldn't send the code right now. Please try again in a minute.";
    }
    return null;
  } catch (error) {
    console.error("OTP send failed", error);
    return "We couldn't reach the SMS service. Please try again in a minute.";
  }
}

export interface OtpIssue {
  /** Set when no code was sent; show it to the caller. */
  error: string | null;
  /** Returned only while no gateway is configured, so testing still works. */
  devCode: string | null;
}

/**
 * Issues a fresh OTP for a number: stores its hash, then sends it.
 *
 * Any earlier code for the same purpose is replaced, so only the newest one
 * can be used. Repeated requests are throttled so nobody can drain the SMS
 * balance by hammering "Resend".
 */
export async function issueOtp(
  phone: string,
  purpose: "registration" | "reset",
): Promise<OtpIssue> {
  const col = await otps();
  const now = Date.now();
  const previous = await col.findOne({ phone, purpose });

  if (previous && now - previous.createdAt.getTime() < COOLDOWN_SECONDS * 1000) {
    return {
      error: `Please wait ${COOLDOWN_SECONDS} seconds before asking for a new code.`,
      devCode: null,
    };
  }

  const windowStart =
    previous?.windowStart && now - previous.windowStart.getTime() < 3_600_000
      ? previous.windowStart
      : new Date(now);
  const sends = windowStart === previous?.windowStart ? (previous.sends ?? 1) + 1 : 1;
  if (sends > MAX_SENDS_PER_HOUR) {
    return {
      error: "Too many codes requested for this number. Please try again in an hour.",
      devCode: null,
    };
  }

  const live = smsIsLive();
  const code = live ? newCode() : FALLBACK_OTP;

  await col.deleteMany({ phone, purpose });
  await col.insertOne({
    phone,
    purpose,
    codeHash: await bcrypt.hash(code, 10),
    attempts: 0,
    sends,
    windowStart,
    expiresAt: new Date(now + OTP_TTL_MINUTES * 60 * 1000),
    createdAt: new Date(now),
  });

  if (!live) return { error: null, devCode: code };

  const error = await deliver(phone, code);
  return { error, devCode: null };
}

/**
 * Checks a code against the outstanding OTP for a number and, when it
 * matches, uses it up. Returns null on success or the message to show.
 */
export async function consumeOtp(
  phone: string,
  purpose: "registration" | "reset",
  code: string,
): Promise<string | null> {
  const col = await otps();
  const record = await col.findOne({ phone, purpose });
  if (!record) return "No code was requested for this number. Please resend.";
  if (record.expiresAt.getTime() < Date.now()) {
    await col.deleteOne({ _id: record._id });
    return "This code has expired. Please resend.";
  }
  if (record.attempts >= 5) {
    await col.deleteOne({ _id: record._id });
    return "Too many attempts. Please resend a new code.";
  }
  if (!(await bcrypt.compare(code, record.codeHash))) {
    await col.updateOne({ _id: record._id }, { $inc: { attempts: 1 } });
    return "The code you entered is incorrect";
  }
  await col.deleteOne({ _id: record._id });
  return null;
}
