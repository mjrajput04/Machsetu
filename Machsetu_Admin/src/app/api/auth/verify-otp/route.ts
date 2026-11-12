import { ensureIndexes, users } from "@/server/db";
import { fail, normPhone, ok, publicUser, signToken } from "@/server/auth";
import { consumeOtp } from "@/server/sms";

/** Confirms the registration OTP and signs the user in. */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const phone = normPhone(body.phone);
  const code = String(body.otp ?? "").trim();
  if (phone.length !== 10) return fail("Enter a valid 10-digit mobile number");
  if (code.length !== 6) return fail("Enter the complete 6-digit code");

  const problem = await consumeOtp(phone, "registration", code);
  if (problem) return fail(problem);

  const col = await users();
  const now = new Date();
  const user = await col.findOneAndUpdate(
    { phone },
    { $set: { phoneVerified: true, status: "Active", lastLoginAt: now, updatedAt: now } },
    { returnDocument: "after" },
  );
  if (!user) return fail("Account not found", 404);

  return ok({ token: signToken(user.code, "user"), user: publicUser(user) });
}
