import { admins, ensureIndexes } from "@/server/db";
import { fail, normEmail, ok, signToken, verifyPassword } from "@/server/auth";

/** Console sign-in. Separate collection and token kind from app users. */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  const email = normEmail(body?.email);
  const password = String(body?.password ?? "");
  if (!email || !password) return fail("Email and password are required");

  const col = await admins();
  const admin = await col.findOne({ email });
  if (!admin || !(await verifyPassword(password, admin.passwordHash))) {
    return fail("Incorrect email or password", 401);
  }

  await col.updateOne({ _id: admin._id }, { $set: { lastLoginAt: new Date() } });

  return ok({
    token: signToken(admin.email, "admin"),
    admin: { email: admin.email, name: admin.name, role: admin.role },
  });
}
