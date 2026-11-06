import { cache } from "react";
import { marketplaceSettings, DEFAULT_SETTINGS } from "./db";

/**
 * What the public website reads from the database.
 *
 * Only marketplace settings — category names and the support desk's contact
 * details. The website deliberately never shows individual listings, stock
 * counts or prices; those stay in the app.
 */
export interface SiteData {
  categories: string[];
  support: {
    phone: string;
    email: string;
    hours: string;
    faqs: { question: string; answer: string }[];
  };
}

function shape(config: typeof DEFAULT_SETTINGS): SiteData {
  return {
    categories: config.categories.filter((c) => c.visible).map((c) => c.name),
    support: {
      phone: config.support.phone,
      email: config.support.email,
      hours: config.support.hours,
      faqs: config.support.faqs,
    },
  };
}

/**
 * A slow or unreachable database must never take the website down with it,
 * so the read gives up after a few seconds and the pages render from the
 * built-in defaults instead. Cached per request, so the layout and the page
 * share one read.
 */
export const siteData = cache(async (): Promise<SiteData> => {
  try {
    const config = await Promise.race([
      marketplaceSettings(),
      new Promise<never>((_, reject) =>
        setTimeout(() => reject(new Error("timeout")), 4000),
      ),
    ]);
    return shape(config);
  } catch {
    return shape(DEFAULT_SETTINGS);
  }
});
