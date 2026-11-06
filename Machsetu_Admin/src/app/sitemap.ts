import type { MetadataRoute } from "next";
import { LEGAL_LINKS, NAV_LINKS, SITE_URL } from "@/lib/site";

export default function sitemap(): MetadataRoute.Sitemap {
  return [...NAV_LINKS, ...LEGAL_LINKS].map((link) => ({
    url: `${SITE_URL}${link.href === "/" ? "" : link.href}`,
    changeFrequency: link.href === "/" ? "weekly" : "monthly",
    priority: link.href === "/" ? 1 : 0.7,
  }));
}
