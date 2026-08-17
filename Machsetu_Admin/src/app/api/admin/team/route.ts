import { admins, ensureIndexes } from "@/server/db";
import { fail, hashPassword, normEmail, ok, readToken } from "@/server/auth";

const ROLES = ["Super Admin", "Inspector", "Broker", "Accounts"];

function requireAdmin(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  return token && token.kind === "admin" ? token : null;
}

/** Who can sign in to this console. */
export async function GET(request: Request) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const docs = await (await admins())
    .find({}, { projection: { _id: 0, passwordHash: 0 } })
    .sort({ createdAt: 1 })
    .toArray();

  return ok({
    team: docs.map((a) => ({
      email: a.email,
      name: a.name,
      role: a.role,
      lastLoginAt: a.lastLoginAt ? a.lastLoginAt.toISOString() : null,
    })),
  });
}

/** Adds a console account. The invitee signs in with the password set here. */
export async function POST(request: Request) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const email = normEmail(body.email);
  const name = String(body.name ?? "").trim();
  const role = ROLES.includes(body.role) ? body.role : "Broker";
  const password = String(body.password ?? "");

  if (!email.includes("@")) return fail("Enter a valid email address");
  if (!name) return fail("Enter a name");
  if (password.length < 8) return fail("Use a password of at least 8 characters");

  const col = await admins();
  if (await col.findOne({ email })) return fail("That email already has access", 409);

  await col.insertOne({
    email,
    name,
    role,
    passwordHash: await hashPassword(password),
    createdAt: new Date(),
    lastLoginAt: null,
  });

  return ok({ member: { email, name, role, lastLoginAt: null } }, 201);
}

/** Revokes access. The last remaining account cannot be removed. */
export async function DELETE(request: Request) {
  await ensureIndexes();
  const token = requireAdmin(request);
  if (!token) return fail("Not authorised", 401);

  const email = normEmail(new URL(request.url).searchParams.get("email"));
  if (!email) return fail("Which account should be removed?");
  if (email === normEmail(token.sub)) {
    return fail("You cannot remove your own access");
  }

  const col = await admins();
  if ((await col.countDocuments()) <= 1) {
    return fail("Keep at least one console account");
  }

  const result = await col.deleteOne({ email });
  if (result.deletedCount === 0) return fail("No such console account", 404);
  return ok({ removed: email });
}
