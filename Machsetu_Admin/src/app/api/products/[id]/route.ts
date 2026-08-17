import { ensureIndexes, products } from "@/server/db";
import { fail, ok } from "@/server/auth";

type Ctx = { params: Promise<{ id: string }> };

/** Full detail record for the app's product page. Also bumps the view count. */
export async function GET(_request: Request, ctx: Ctx) {
  await ensureIndexes();
  const { id } = await ctx.params;

  const col = await products();
  const found = await col.findOne({ id }, { projection: { _id: 0 } });
  if (!found) return fail("Listing not found", 404);

  // ProductDoc is intentionally loose, so $inc needs a nudge to type-check.
  await col.updateOne({ id }, { $inc: { views: 1 } } as Record<string, unknown>);
  return ok({ product: found });
}
