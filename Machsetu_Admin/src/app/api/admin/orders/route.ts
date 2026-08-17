import { ensureIndexes, orders } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

/** Order pipeline, newest first. */
export async function GET(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "admin") return fail("Not authorised", 401);

  const col = await orders();
  const docs = await col
    .find({}, { projection: { _id: 0 } })
    .sort({ placedOn: -1 })
    .toArray();
  return ok({ orders: docs });
}
