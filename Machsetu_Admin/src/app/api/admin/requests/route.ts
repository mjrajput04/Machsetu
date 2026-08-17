import { ensureIndexes, sellRequests } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

export async function GET(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "admin") return fail("Not authorised", 401);

  const col = await sellRequests();
  const docs = await col
    .find({}, { projection: { _id: 0 } })
    .sort({ createdAt: -1 })
    .toArray();
  return ok({ requests: docs });
}
