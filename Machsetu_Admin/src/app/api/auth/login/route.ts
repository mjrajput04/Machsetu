import { ensureIndexes, users } from "@/server/db";
import {
  fail,
  isEmail,
  normEmail,
  normPhone,
  ok,
  publicUser,
  signToken,
  verifyPassword,
} from "@/server/auth";

/**
 * Signs a user in with EITHER their email or their mobile number, plus the
 * password. No OTP here — that is only for registration.
 */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const raw = String(body.identifier ?? body.email ?? "").trim();
  const password = String(body.password ?? "");
  if (!raw) return fail("Enter your email or mobile number");
  if (!password) return fail("Password is required");

  const col = await users();
  const asEmail = normEmail(raw);
  const asPhone = normPhone(raw);

  const user = isEmail(asEmail)
    ? await col.findOne({ email: asEmail })
    : asPhone.length === 10
      ? await col.findOne({ phone: asPhone })
      : null;

  // Same message either way, so the response cannot be used to probe which
  // emails or numbers exist.
  if (!user) return fail("Incorrect credentials", 401);
  if (!(await verifyPassword(password, user.passwordHash))) {
    return fail("Incorrect credentials", 401);
  }
  if (user.status === "Suspended") return fail("This account is suspended", 403);
  if (!user.phoneVerified) {
    return fail("Mobile number not verified. Please complete OTP verification.", 403);
  }

  await col.updateOne({ _id: user._id }, { $set: { lastLoginAt: new Date() } });
  return ok({ token: signToken(user.code, "user"), user: publicUser(user) });
}
