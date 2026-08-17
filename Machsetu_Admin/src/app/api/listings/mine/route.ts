import { ensureIndexes, products, sellRequests } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

/**
 * The seller's own listings for "My Listings" and its detail page.
 *
 * Submissions and published catalogue entries are merged into one stream so
 * the app can show a single list ordered newest-first.
 */
export async function GET(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return fail("Not authorised", 401);

  const requests = await (await sellRequests())
    .find({ userCode: token.sub }, { projection: { _id: 0 } })
    .sort({ createdAt: -1 })
    .toArray();

  const published = requests
    .map((r) => r.publishedProductId)
    .filter((id): id is string => typeof id === "string");

  const live = published.length
    ? await (await products())
        .find({ id: { $in: published } }, { projection: { _id: 0 } })
        .toArray()
    : [];

  const byId = new Map(live.map((p) => [p.id, p]));

  const listings = requests.map((r) => {
    const product = r.publishedProductId ? byId.get(String(r.publishedProductId)) : null;
    return {
      ...r,
      // A published listing carries the live counters back to the seller.
      state: product ? String(product.status ?? "Live") : String(r.status ?? ""),
      views: product?.views ?? r.views ?? 0,
      activeInquiries: product?.inquiries ?? r.activeInquiries ?? 0,
      productId: r.publishedProductId ?? null,
    };
  });

  return ok({ listings, count: listings.length });
}
