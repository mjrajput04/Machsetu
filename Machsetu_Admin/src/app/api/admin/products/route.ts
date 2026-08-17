import { ensureIndexes, nextId, products } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";
import { withProductDefaults } from "@/server/shape";

function requireAdmin(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  return token && token.kind === "admin" ? token : null;
}

/** Full catalogue for the console. */
export async function GET(request: Request) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const col = await products();
  const docs = await col
    .find({}, { projection: { _id: 0 } })
    .sort({ createdAt: -1 })
    .toArray();
  return ok({ products: docs });
}

/** Creates a listing straight from the console. */
export async function POST(request: Request) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const col = await products();
  const id = body.id ?? (await nextId("products", "MS-", 1000));
  const now = new Date();

  await col.insertOne({
    ...withProductDefaults(body),
    id,
    createdAt: now,
    updatedAt: now,
  });
  const created = await col.findOne({ id }, { projection: { _id: 0 } });
  return ok({ product: created }, 201);
}
