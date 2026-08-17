import { ensureIndexes, users } from "@/server/db";
import { fail, normEmail, ok, publicUser, readToken } from "@/server/auth";

async function currentUser(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return null;
  const col = await users();
  return col.findOne({ code: token.sub });
}

export async function GET(request: Request) {
  await ensureIndexes();
  const user = await currentUser(request);
  if (!user) return fail("Not authorised", 401);
  return ok({ user: publicUser(user) });
}

/**
 * Saves the edit-profile form. Email is the only field with a uniqueness
 * constraint, so it is checked before writing.
 */
export async function PUT(request: Request) {
  await ensureIndexes();
  const user = await currentUser(request);
  if (!user) return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const col = await users();
  const email = normEmail(body.email ?? user.email);
  if (email !== user.email) {
    if (await col.findOne({ email })) return fail("This email is already in use", 409);
  }

  const text = (value: unknown, fallback = "") =>
    value === undefined ? fallback : String(value).trim();

  await col.updateOne(
    { _id: user._id },
    {
      $set: {
        name: text(body.name, user.name),
        email,
        avatar: text(body.avatar, user.avatar ?? ""),
        designation: text(body.designation, user.designation),
        company: text(body.company, user.company),
        gstin: text(body.gstin, user.gstin).toUpperCase(),
        pan: text(body.pan, user.pan).toUpperCase(),
        address: text(body.address, user.address),
        city: text(body.city, user.city),
        state: text(body.state, user.state),
        zip: text(body.zip, user.zip),
        updatedAt: new Date(),
      },
    },
  );

  const fresh = await col.findOne({ _id: user._id });
  return ok({ user: publicUser(fresh!) });
}
