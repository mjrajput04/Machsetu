import { ensureIndexes, users } from "@/server/db";
import { fail, normPhone, ok } from "@/server/auth";
import { issueOtp } from "@/server/sms";

/**
 * Step 1 of "Forgot password": sends a reset code to the account's mobile.
 * Also serves the OTP screen's "Resend" while resetting.
 */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  const phone = normPhone(body?.phone);
  if (phone.length !== 10) return fail("Enter a valid 10-digit mobile number");

  const user = await (await users()).findOne({ phone });
  if (!user) return fail("No account is registered with this mobile number", 404);

  const otp = await issueOtp(phone, "reset");
  if (otp.error) return fail(otp.error, 429);

  return ok({
    message: "A code has been sent to your mobile.",
    // Only present while no SMS gateway is configured.
    ...(otp.devCode ? { devOtp: otp.devCode } : {}),
  });
}
