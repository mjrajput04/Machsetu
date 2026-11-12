import { ensureIndexes, users } from "@/server/db";
import { fail, normPhone, ok } from "@/server/auth";
import { issueOtp } from "@/server/sms";

/** Issues a fresh registration OTP, replacing any outstanding one. */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  const phone = normPhone(body?.phone);
  if (phone.length !== 10) return fail("Enter a valid 10-digit mobile number");

  const col = await users();
  if (!(await col.findOne({ phone }))) return fail("Account not found", 404);

  const otp = await issueOtp(phone, "registration");
  if (otp.error) return fail(otp.error, 429);

  return ok({
    message: "A new code has been sent.",
    // Only present while no SMS gateway is configured.
    ...(otp.devCode ? { devOtp: otp.devCode } : {}),
  });
}
