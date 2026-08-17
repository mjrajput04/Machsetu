import bcrypt from "bcryptjs";
import { ensureIndexes, otps, users } from "@/server/db";
import { fail, hashPassword, isEmail, normEmail, normPhone, ok } from "@/server/auth";

/**
 * Fixed demo OTP until an SMS gateway is connected. Override with
 * DEFAULT_OTP in `.env.local`, or swap this for a random code once real
 * messages are being sent.
 */
const DEFAULT_OTP = process.env.DEFAULT_OTP ?? "123456";

async function nextUserCode(): Promise<string> {
  const col = await users();
  const count = await col.countDocuments();
  return `U-${2200 + count + 1}`;
}

/**
 * Registers an account and issues a phone OTP. The account exists straight
 * away but stays `phoneVerified: false` until the code is confirmed.
 */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const name = String(body.name ?? "").trim();
  const email = normEmail(body.email);
  const phone = normPhone(body.phone);
  const password = String(body.password ?? "");

  if (name.length < 3) return fail("Enter at least 3 characters for the name");
  if (!isEmail(email)) return fail("Enter a valid email address");
  if (phone.length !== 10) return fail("Enter a valid 10-digit mobile number");
  if (password.length < 6) return fail("Password must be at least 6 characters");

  const col = await users();
  if (await col.findOne({ email })) return fail("This email is already registered", 409);
  if (await col.findOne({ phone })) return fail("This mobile number is already registered", 409);

  const now = new Date();
  await col.insertOne({
    code: await nextUserCode(),
    name,
    email,
    phone,
    passwordHash: await hashPassword(password),
    avatar: "",
    designation: "",
    company: "",
    gstin: "",
    pan: "",
    address: "",
    city: "",
    state: "",
    zip: "",
    twoFactor: false,
    biometrics: false,
    loginAlerts: true,
    role: "Buyer",
    status: "Pending KYC",
    phoneVerified: false,
    listings: 0,
    orders: 0,
    createdAt: now,
    updatedAt: now,
    lastLoginAt: null,
  });

  const code = DEFAULT_OTP;
  const otpCol = await otps();
  await otpCol.deleteMany({ phone, purpose: "registration" });
  await otpCol.insertOne({
    phone,
    codeHash: await bcrypt.hash(code, 10),
    purpose: "registration",
    attempts: 0,
    expiresAt: new Date(Date.now() + 10 * 60_000),
    createdAt: now,
  });

  // No SMS gateway yet, so the code is echoed back for testing.
  return ok({ message: "Registered. Verify the OTP sent to your mobile.", devOtp: code });
}
