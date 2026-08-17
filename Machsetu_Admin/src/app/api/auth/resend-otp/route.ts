import bcrypt from "bcryptjs";
import { ensureIndexes, otps, users } from "@/server/db";
import { fail, normPhone, ok } from "@/server/auth";

/** Issues a fresh registration OTP, replacing any outstanding one. */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  const phone = normPhone(body?.phone);
  if (phone.length !== 10) return fail("Enter a valid 10-digit mobile number");

  const col = await users();
  if (!(await col.findOne({ phone }))) return fail("Account not found", 404);

  const code = process.env.DEFAULT_OTP ?? "123456";
  const otpCol = await otps();
  await otpCol.deleteMany({ phone, purpose: "registration" });
  await otpCol.insertOne({
    phone,
    codeHash: await bcrypt.hash(code, 10),
    purpose: "registration",
    attempts: 0,
    expiresAt: new Date(Date.now() + 10 * 60_000),
    createdAt: new Date(),
  });

  return ok({ message: "A new code has been sent.", devOtp: code });
}
