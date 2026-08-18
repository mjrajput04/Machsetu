import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { AdminSessionProvider } from "@/components/AdminSession";
import { Shell } from "@/components/Shell";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "MachSetu Admin Console",
  description:
    "Operations console for the MachSetu industrial machine marketplace.",
  // src/app/icon.png is picked up automatically for the tab and bookmarks.
  applicationName: "MachSetu",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body className={`${inter.variable} antialiased`}>
        <AdminSessionProvider>
          <Shell>{children}</Shell>
        </AdminSessionProvider>
      </body>
    </html>
  );
}
