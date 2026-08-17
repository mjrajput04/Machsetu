import { ensureIndexes, nextId, products, sellRequests } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";
import { withProductDefaults } from "@/server/shape";
import { notify } from "@/server/notify";

function requireAdmin(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  return token && token.kind === "admin" ? token : null;
}

type Ctx = { params: Promise<{ id: string }> };

export async function GET(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const col = await sellRequests();
  const found = await col.findOne({ id }, { projection: { _id: 0 } });
  if (!found) return fail("Request not found", 404);
  return ok({ request: found });
}

/**
 * Moves a submission along. `action: "approve"` also publishes it into the
 * catalogue, carrying the whole registration record across.
 */
export async function PUT(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const col = await sellRequests();
  const found = await col.findOne({ id });
  if (!found) return fail("Request not found", 404);

  // Sub-documents are stored loosely, so they are read through a narrow shape.
  const details = (found.details ?? {}) as Record<string, string>;

  const action = String(body.action ?? "");
  const now = new Date();

  if (action === "approve") {
    const productCol = await products();
    const productId = await nextId("products", "MS-", 1000);

    await productCol.insertOne(
      withProductDefaults({
        id: productId,
        title: found.machine,
        brand: found.brand,
        type: details.machineType ?? "",
        category: found.category,
        categories: found.categories ?? [],
        year: found.year,
        price: found.askingPrice,
        location: found.city,
        condition: found.condition,
        hours: found.hours,
        origin: details.countryOfOrigin ?? "",
        status: "Live",
        views: 0,
        inquiries: 0,
        seller: found.seller,
        listedOn: now.toISOString().slice(0, 10),
        badge: "VERIFIED",
        priceNote: "EXCL. SHIPPING",
        ctaLabel: "Request Technical Audit",
        images: found.images ?? [],
        overview: found.description ? [found.description] : [],
        features: [],
        description: found.description ?? "",
        sellerInfo: found.sellerInfo,
        details: found.details,
        specs: found.specs,
        commercial: found.commercial,
        documents: found.documents ?? [],
        requiredPhotos: found.requiredPhotos ?? [],
        additionalRemarks: found.note ?? "",
        createdAt: now,
        updatedAt: now,
      }) as { id: string },
    );

    await col.updateOne(
      { id },
      {
        $set: {
          status: "Approved",
          publishedProductId: productId,
          note: `Approved and published as ${productId}.`,
          updatedAt: now,
        },
      },
    );

    if (typeof found.userCode === "string") {
      await notify(found.userCode, {
        title: "Listing approved",
        body: `${found.machine} is live on the marketplace as ${productId}.`,
        kind: "listing",
        reference: productId,
        image: Array.isArray(found.images) ? (found.images[0] ?? null) : null,
      });
    }

    const updated = await col.findOne({ id }, { projection: { _id: 0 } });
    return ok({ request: updated, publishedProductId: productId });
  }

  const statusByAction: Record<string, string> = {
    reject: "Rejected",
    schedule: "Inspection Scheduled",
    reopen: "Awaiting Review",
  };

  const patch: Record<string, unknown> = { updatedAt: now };
  if (statusByAction[action]) patch.status = statusByAction[action];
  if (typeof body.note === "string") patch.note = body.note;
  if (body.inspection) patch.inspection = body.inspection;

  await col.updateOne({ id }, { $set: patch });

  if (statusByAction[action] && typeof found.userCode === "string") {
    await notify(found.userCode, {
      title: `Submission ${statusByAction[action]}`,
      body:
        typeof patch.note === "string" && patch.note
          ? String(patch.note)
          : `${found.machine} is now marked "${statusByAction[action]}".`,
      kind: "listing",
      reference: id,
      image: Array.isArray(found.images) ? (found.images[0] ?? null) : null,
    });
  }

  const updated = await col.findOne({ id }, { projection: { _id: 0 } });
  return ok({ request: updated });
}
