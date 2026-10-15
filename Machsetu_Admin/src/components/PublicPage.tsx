import Image from "next/image";
import Link from "next/link";
import type { ReactNode } from "react";

/** Contact details printed on every public page and inside the policies. */
export const CONTACT = {
  company: "MachSetu",
  email: "machsetu@gmail.com",
  phone: "+91 84015 03169",
  address:
    "Office No. 219, Fortune Gold Complex, Road No E, Near Murlidhar Commercial Complex, Lodhika GIDC, Rajkot, Gujarat 360021, India",
};

const LINKS = [
  { href: "/privacy", label: "Privacy Policy" },
  { href: "/terms", label: "Terms of Use" },
  { href: "/delete-account", label: "Delete Account" },
];

/**
 * Frame for the public pages: logo header, a readable column, and a footer
 * that links the three policies to one another.
 */
export function PublicPage({
  title,
  updated,
  children,
}: {
  title: string;
  updated?: string;
  children: ReactNode;
}) {
  return (
    <div className="flex min-h-screen flex-col bg-canvas">
      <header className="border-b border-line bg-white">
        <div className="mx-auto flex max-w-3xl items-center justify-between gap-4 px-4 py-4">
          <Link href="/privacy" className="flex items-center gap-2.5">
            <Image
              src="/machsetu-mark.png"
              alt=""
              width={36}
              height={36}
              className="h-9 w-9 rounded-lg"
            />
            <span className="text-lg font-extrabold tracking-tight text-navy-800">
              MachSetu
            </span>
          </Link>
          <nav className="hidden gap-5 text-sm font-semibold text-muted sm:flex">
            {LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="hover:text-navy-800"
              >
                {link.label}
              </Link>
            ))}
          </nav>
        </div>
      </header>

      <main className="mx-auto w-full max-w-3xl flex-1 px-4 py-10">
        <h1 className="text-3xl font-extrabold tracking-tight text-navy-800 sm:text-4xl">
          {title}
        </h1>
        {updated && (
          <p className="mt-2 text-sm text-faint">Last updated: {updated}</p>
        )}
        <div className="mt-8">{children}</div>
      </main>

      <footer className="border-t border-line bg-white">
        <div className="mx-auto flex max-w-3xl flex-col gap-3 px-4 py-6 text-sm text-muted sm:flex-row sm:items-center sm:justify-between">
          <p>© 2026 MachSetu. All rights reserved.</p>
          <nav className="flex flex-wrap gap-x-5 gap-y-2">
            {LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="hover:text-navy-800"
              >
                {link.label}
              </Link>
            ))}
          </nav>
        </div>
      </footer>
    </div>
  );
}

/** One numbered policy section. */
export function Section({
  title,
  children,
}: {
  title: string;
  children: ReactNode;
}) {
  return (
    <section className="mb-9">
      <h2 className="mb-3 text-xl font-bold text-navy-800">{title}</h2>
      <div className="space-y-3 text-[15px] leading-7 text-ink [&_li]:ml-5 [&_li]:list-disc [&_li]:pl-1 [&_ul]:space-y-1.5">
        {children}
      </div>
    </section>
  );
}
