import { SiteFooter } from "@/components/site/SiteFooter";
import { SiteHeader } from "@/components/site/SiteHeader";
import { siteData } from "@/server/site";

// Live listings, categories and contact details come straight from the
// database on every visit, so the site never shows stale machines.
export const dynamic = "force-dynamic";

export default async function SiteLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  const { support, categories } = await siteData();

  return (
    <div className="flex min-h-screen flex-col bg-white text-ink">
      <SiteHeader />
      <main className="flex-1">{children}</main>
      <SiteFooter support={support} categories={categories} />
    </div>
  );
}
