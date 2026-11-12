import { ensureIndexes, otps, users } from "@/server/db";
import {
  fail,
  hashPassword,
  ok,
  readResetToken,
  resetTokenSubject,
} from "@/server/auth";

/**
 * Step 3 of "Forgot password": sets the new password. Needs the reset token
 * from step 2, which stops working as soon as the password changes.
 */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const token = String(body.resetToken ?? "");
  const password = String(body.password ?? "");
  if (password.length < 6) return fail("Password must be at least 6 characters");

  const code = resetTokenSubject(token);
  const col = await users();
  const user = code ? await col.findOne({ code }) : null;
  if (!readResetToken(token, user) || !user) {
    return fail("This reset link has expired. Please request a new code.", 401);
  }

  const now = new Date();
  await col.updateOne(
    { code: user.code },
    { $set: { passwordHash: await hashPassword(password), updatedAt: now } },
  );
  // Any code still outstanding for this number is no longer needed.
  await (await otps()).deleteMany({ phone: user.phone, purpose: "reset" });

  return ok({ message: "Password updated. Please sign in with your new password." });
}
