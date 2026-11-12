import { ensureIndexes, users } from "@/server/db";
import { fail, normPhone, ok, signResetToken } from "@/server/auth";
import { consumeOtp } from "@/server/sms";

/**
 * Step 2 of "Forgot password": trades a correct reset code for a short-lived
 * reset token. The token only works on /api/auth/reset-password.
 */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const phone = normPhone(body.phone);
  const code = String(body.otp ?? "").trim();
  if (phone.length !== 10) return fail("Enter a valid 10-digit mobile number");
  if (code.length !== 6) return fail("Enter the complete 6-digit code");

  const problem = await consumeOtp(phone, "reset", code);
  if (problem) return fail(problem);

  const user = await (await users()).findOne({ phone });
  if (!user) return fail("Account not found", 404);

  return ok({ resetToken: signResetToken(user) });
}
