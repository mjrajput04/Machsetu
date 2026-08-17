import {
  db,
  marketplaceSettings,
  settings,
  type HeroSlide,
  type SettingsDoc,
} from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

function requireAdmin(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  return token && token.kind === "admin" ? token : null;
}

/**
 * Moves every listing and submission filed under `from` across to `to`.
 *
 * Returns how many rows moved, so the console can say what happened.
 */
async function renameCategory(from: string, to: string): Promise<number> {
  const database = await db();
  let moved = 0;

  for (const name of ["products", "sellRequests"]) {
    const result = await database
      .collection(name)
      .updateMany({ category: from }, { $set: { category: to } });
    moved += result.modifiedCount;

    // `categories` is the seller's own multi-select, kept in step as well.
    await database.collection(name).updateMany(
      { categories: from },
      { $set: { "categories.$[el]": to } },
      {
        arrayFilters: [{ el: from }],
      },
    );
  }
  return moved;
}

export async function GET(request: Request) {
  if (!requireAdmin(request)) return fail("Not authorised", 401);
  return ok({ settings: await marketplaceSettings() });
}

/**
 * Saves the settings form. Sections are merged, so the console can send only
 * the tab it changed.
 */
export async function PUT(request: Request) {
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const current = await marketplaceSettings();
  const patch: Partial<SettingsDoc> = { updatedAt: new Date() };
  let renamed: { from: string; to: string; listings: number } | null = null;

  if (Array.isArray(body.categories)) {
    const seen = new Set<string>();
    const cleaned: { name: string; visible: boolean }[] = [];
    for (const entry of body.categories) {
      const name = String(entry?.name ?? "").trim();
      // A duplicate name would show the same chip twice in the app.
      if (!name || seen.has(name.toLowerCase())) continue;
      seen.add(name.toLowerCase());
      cleaned.push({ name, visible: entry?.visible !== false });
    }
    if (cleaned.length === 0) return fail("Keep at least one category");

    // A rename has to reach the listings too, or the app would show a chip
    // with nothing behind it. Only an in-place edit counts as a rename —
    // adding or removing entries is left alone.
    const before = current.categories.map((c) => c.name);
    const after = cleaned.map((c) => c.name);
    if (before.length === after.length) {
      const moved = before
        .map((name, i) => [name, after[i]] as const)
        .filter(([from, to]) => from !== to);

      if (moved.length === 1) {
        const [from, to] = moved[0];
        renamed = { from, to, listings: await renameCategory(from, to) };
      }
    }

    patch.categories = cleaned;
  }

  if (Array.isArray(body.heroSlides)) {
    const incoming = body.heroSlides as Record<string, unknown>[];
    const slides: HeroSlide[] = incoming
      .map((slide) => ({
        badge: String(slide?.badge ?? "").trim(),
        title: String(slide?.title ?? "").trim(),
        subtitle: String(slide?.subtitle ?? "").trim(),
        ctaLabel: String(slide?.ctaLabel ?? "").trim(),
        image: String(slide?.image ?? "").trim(),
      }))
      // A slide with no words and no photo would render as a blank panel.
      .filter((slide) => slide.title || slide.subtitle || slide.image);

    if (slides.length === 0) return fail("Keep at least one hero slide");
    patch.heroSlides = slides;
  }

  if (body.commercials) {
    const rate = (key: keyof SettingsDoc["commercials"]) => {
      const value = Number(body.commercials[key]);
      if (!Number.isFinite(value) || value < 0 || value > 100) {
        return current.commercials[key];
      }
      return value;
    };
    patch.commercials = {
      gstRate: rate("gstRate"),
      brokerageRate: rate("brokerageRate"),
      shippingRate: rate("shippingRate"),
      platformCommission: rate("platformCommission"),
    };
  }

  if (body.listingRules) {
    patch.listingRules = { ...current.listingRules, ...body.listingRules };
  }
  if (body.escrow) {
    patch.escrow = { ...current.escrow, ...body.escrow };
  }
  if (body.notifications) {
    patch.notifications = { ...current.notifications, ...body.notifications };
  }

  if (body.support) {
    const faqs = Array.isArray(body.support.faqs)
      ? (body.support.faqs as Record<string, unknown>[])
          .map((f) => ({
            question: String(f?.question ?? "").trim(),
            answer: String(f?.answer ?? "").trim(),
          }))
          .filter((f) => f.question || f.answer)
      : current.support.faqs;

    patch.support = { ...current.support, ...body.support, faqs };
  }

  if (body.sellOptions) {
    const list = (key: keyof SettingsDoc["sellOptions"]) => {
      const value = body.sellOptions[key];
      if (!Array.isArray(value)) return current.sellOptions[key];
      const cleaned = value.map((v: unknown) => String(v).trim()).filter(Boolean);
      // An emptied list would leave the wizard with nothing to tick.
      return cleaned.length > 0 ? cleaned : current.sellOptions[key];
    };

    patch.sellOptions = {
      requiredPhotos: list("requiredPhotos"),
      documentTypes: list("documentTypes"),
      workingStatus: list("workingStatus"),
      conditions: list("conditions"),
      maintenanceStatus: list("maintenanceStatus"),
      ownerTypes: list("ownerTypes"),
    };
  }

  const col = await settings();
  await col.updateOne({ _id: "marketplace" }, { $set: patch });
  return ok({ settings: await marketplaceSettings(), renamed });
}
