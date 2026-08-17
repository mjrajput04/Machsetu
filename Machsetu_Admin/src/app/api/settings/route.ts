import { marketplaceSettings } from "@/server/db";
import { ok } from "@/server/auth";

/**
 * Marketplace settings the mobile app needs: which category chips to show,
 * the home hero, and the fee percentages used on the cart and checkout.
 *
 * Public on purpose — nothing here is sensitive, and the app reads it before
 * anyone has signed in.
 */
export async function GET() {
  const doc = await marketplaceSettings();

  return ok({
    categories: doc.categories.filter((c) => c.visible).map((c) => c.name),
    heroSlides: doc.heroSlides,
    // Older app builds read a single hero object.
    hero: doc.heroSlides[0],
    commercials: doc.commercials,
    support: doc.support,
    sellOptions: doc.sellOptions,
    listingRules: {
      minimumPhotos: doc.listingRules.minimumPhotos,
      allowPriceOnRequest: doc.listingRules.allowPriceOnRequest,
    },
  });
}
