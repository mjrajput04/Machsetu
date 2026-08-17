import { ensureIndexes, products } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

function requireAdmin(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  return token && token.kind === "admin" ? token : null;
}

type Ctx = { params: Promise<{ id: string }> };

export async function GET(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const col = await products();
  const product = await col.findOne({ id }, { projection: { _id: 0 } });
  if (!product) return fail("Product not found", 404);
  return ok({ product });
}

export async function PUT(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const col = await products();
  // `id` and `_id` are immutable, so they never travel with the patch.
  const patch: Record<string, unknown> = { ...body };
  delete patch.id;
  delete patch._id;

  const result = await col.updateOne(
    { id },
    { $set: { ...patch, updatedAt: new Date() } },
  );
  if (result.matchedCount === 0) return fail("Product not found", 404);

  const product = await col.findOne({ id }, { projection: { _id: 0 } });
  return ok({ product });
}

export async function DELETE(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const col = await products();
  const result = await col.deleteOne({ id });
  if (result.deletedCount === 0) return fail("Product not found", 404);
  return ok({ deleted: id });
}
