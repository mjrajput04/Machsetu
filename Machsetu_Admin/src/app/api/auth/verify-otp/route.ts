import bcrypt from "bcryptjs";
import { ensureIndexes, otps, users } from "@/server/db";
import { fail, normPhone, ok, publicUser, signToken } from "@/server/auth";

/** Confirms the registration OTP and signs the user in. */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const phone = normPhone(body.phone);
  const code = String(body.otp ?? "").trim();
  if (phone.length !== 10) return fail("Enter a valid 10-digit mobile number");
  if (code.length !== 6) return fail("Enter the complete 6-digit code");

  const otpCol = await otps();
  const record = await otpCol.findOne({ phone, purpose: "registration" });
  if (!record) return fail("No code was requested for this number. Please resend.");
  if (record.expiresAt.getTime() < Date.now()) {
    await otpCol.deleteOne({ _id: record._id });
    return fail("This code has expired. Please resend.");
  }
  if (record.attempts >= 5) {
    await otpCol.deleteOne({ _id: record._id });
    return fail("Too many attempts. Please resend a new code.");
  }

  if (!(await bcrypt.compare(code, record.codeHash))) {
    await otpCol.updateOne({ _id: record._id }, { $inc: { attempts: 1 } });
    return fail("The code you entered is incorrect");
  }

  await otpCol.deleteOne({ _id: record._id });

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
