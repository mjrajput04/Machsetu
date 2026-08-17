import { ensureIndexes, users } from "@/server/db";
import {
  fail,
  hashPassword,
  ok,
  publicUser,
  readToken,
  verifyPassword,
} from "@/server/auth";

async function currentUser(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return null;
  const col = await users();
  return col.findOne({ code: token.sub });
}

/** Persists the security toggles, and changes the password when asked. */
export async function PUT(request: Request) {
  await ensureIndexes();
  const user = await currentUser(request);
  if (!user) return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const col = await users();
  const update: Record<string, unknown> = { updatedAt: new Date() };

  for (const key of ["twoFactor", "biometrics", "loginAlerts"] as const) {
    if (typeof body[key] === "boolean") update[key] = body[key];
  }

  if (body.newPassword) {
    const current = String(body.currentPassword ?? "");
    const next = String(body.newPassword);
    if (next.length < 6) return fail("Password must be at least 6 characters");
    if (!(await verifyPassword(current, user.passwordHash))) {
      return fail("Your current password is incorrect", 403);
    }
    update.passwordHash = await hashPassword(next);
  }

  await col.updateOne({ _id: user._id }, { $set: update });
  const fresh = await col.findOne({ _id: user._id });
  return ok({ user: publicUser(fresh!) });
}
