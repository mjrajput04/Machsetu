import { db, ensureIndexes } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

/** Everything that has happened on this account, newest first. */
export async function GET(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return fail("Not authorised", 401);

  const col = (await db()).collection("notifications");
  const docs = await col
    .find({ userCode: token.sub }, { projection: { _id: 0, userCode: 0 } })
    .sort({ createdAt: -1 })
    .limit(60)
    .toArray();

  const unread = docs.filter((d) => d.read !== true).length;
  return ok({ notifications: docs, unread });
}

/** Marks the list as read once the buyer has opened it. */
export async function PUT(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return fail("Not authorised", 401);

  const col = (await db()).collection("notifications");
  const result = await col.updateMany(
    { userCode: token.sub, read: { $ne: true } },
    { $set: { read: true } },
  );
  return ok({ marked: result.modifiedCount });
}
