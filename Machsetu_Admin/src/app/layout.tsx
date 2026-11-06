import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { SITE_URL } from "@/lib/site";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "MachSetu — Buy & Sell Pre-Owned CNC and VMC Machines in India",
    template: "%s · MachSetu",
  },
  description:
    "MachSetu is India's marketplace for verified second-hand CNC, VMC, lathe, EDM and grinding machines. Every listing is inspected, payments are held in escrow, and freight is handled end to end.",
  // src/app/icon.png is picked up automatically for the tab and bookmarks.
  applicationName: "MachSetu",
  openGraph: {
    type: "website",
    siteName: "MachSetu",
    locale: "en_IN",
    images: ["/machines/vmc_machining_center.jpg"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body className={`${inter.variable} antialiased`}>{children}</body>
    </html>
  );
}
