import type { Metadata } from "next";
import { AdminSessionProvider } from "@/components/AdminSession";
import { Shell } from "@/components/Shell";

export const metadata: Metadata = {
  title: { default: "Admin Console", template: "%s · MachSetu Admin" },
  description:
    "Operations console for the MachSetu industrial machine marketplace.",
  // The console is for the desk only; keep it out of search results.
  robots: { index: false, follow: false },
};

export default function AdminLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <AdminSessionProvider>
      <Shell>{children}</Shell>
    </AdminSessionProvider>
  );
}
