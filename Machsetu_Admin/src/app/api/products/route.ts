import { ensureIndexes, products } from "@/server/db";
import { fail, ok } from "@/server/auth";

/** Keeps a user's search text from being read as a regular expression. */
function escapeRegex(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Public catalogue read by the mobile app.
 *
 * Only live listings are exposed; drafts and sold units stay in the console.
 * Optional filters: `?category=VMC Centers`, `?q=grinder`, `?limit=20`.
 */
export async function GET(request: Request) {
  await ensureIndexes();
  const params = new URL(request.url).searchParams;

  const filter: Record<string, unknown> = { status: { $ne: "Draft" } };

  const category = params.get("category")?.trim();
  if (category && category !== "All") filter.category = category;

  const q = params.get("q")?.trim();
  if (q) {
    const rx = { $regex: escapeRegex(q), $options: "i" };
    filter.$or = [
      { title: rx },
      { brand: rx },
      { type: rx },
      { location: rx },
      { category: rx },
    ];
  }

  const limit = Math.min(Number(params.get("limit") ?? 200) || 200, 500);

  try {
    const col = await products();
    const docs = await col
      .find(filter, { projection: { _id: 0 } })
      .sort({ listedOn: -1, id: -1 })
      .limit(limit)
      .toArray();
    return ok({ products: docs, count: docs.length });
  } catch {
    return fail("Catalogue is unavailable right now", 503);
  }
}
