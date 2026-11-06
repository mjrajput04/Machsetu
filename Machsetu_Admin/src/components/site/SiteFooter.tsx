import Image from "next/image";
import Link from "next/link";
import { LEGAL_LINKS, NAV_LINKS, OFFICE } from "@/lib/site";
import type { SiteData } from "@/server/site";
import { Clock, Mail, MapPin, Phone } from "./icons";

export function SiteFooter({
  support,
  categories,
}: {
  support: SiteData["support"];
  categories: SiteData["categories"];
}) {
  return (
    <footer className="relative overflow-hidden bg-navy-950 text-white">
      <div className="pointer-events-none absolute -top-40 right-0 h-80 w-80 rounded-full bg-accent-500/15 blur-[100px]" />

      <div className="relative mx-auto grid max-w-7xl gap-10 px-4 py-16 sm:px-6 md:grid-cols-2 lg:grid-cols-[1.4fr_1fr_1fr_1.3fr] lg:px-8">
        <div>
          <Link href="/" className="inline-flex items-center gap-2.5">
            <span className="grid h-11 w-11 place-items-center rounded-xl bg-white p-1.5">
              <Image src="/machsetu-mark.png" alt="" width={40} height={30} className="h-auto w-full" />
            </span>
            <span className="text-xl font-extrabold tracking-tight">
              Mach<span className="text-accent-500">Setu</span>
            </span>
          </Link>
          <p className="mt-4 max-w-xs text-sm leading-relaxed text-white/60">
            The bridge between India&apos;s machine owners and the shops that
            need them — verified pre-owned CNC, VMC, lathe, EDM and grinding
            machines.
          </p>
        </div>

        <div>
          <p className="text-xs font-bold tracking-[0.14em] text-white/40 uppercase">Company</p>
          <ul className="mt-4 space-y-2.5 text-sm">
            {NAV_LINKS.map((link) => (
              <li key={link.href}>
                <Link href={link.href} className="text-white/70 transition hover:text-white">
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <p className="text-xs font-bold tracking-[0.14em] text-white/40 uppercase">Machines</p>
          <ul className="mt-4 space-y-2.5 text-sm">
            {categories.slice(0, 6).map((name) => (
              <li key={name}>
                <Link
                  href={`/contact?topic=buy&category=${encodeURIComponent(name)}`}
                  className="text-white/70 transition hover:text-white"
                >
                  {name}
                </Link>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <p className="text-xs font-bold tracking-[0.14em] text-white/40 uppercase">Reach us</p>
          <ul className="mt-4 space-y-3 text-sm text-white/70">
            <li className="flex gap-3">
              <Phone className="mt-0.5 h-4 w-4 shrink-0 text-accent-500" />
              <a href={`tel:${support.phone.replace(/\s/g, "")}`} className="hover:text-white">
                {support.phone}
              </a>
            </li>
            <li className="flex gap-3">
              <Mail className="mt-0.5 h-4 w-4 shrink-0 text-accent-500" />
              <a href={`mailto:${support.email}`} className="break-all hover:text-white">
                {support.email}
              </a>
            </li>
            <li className="flex gap-3">
              <Clock className="mt-0.5 h-4 w-4 shrink-0 text-accent-500" />
              {support.hours}
            </li>
            <li className="flex gap-3">
              <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-accent-500" />
              {OFFICE.city}, {OFFICE.region}
            </li>
          </ul>
        </div>
      </div>

      <div className="relative border-t border-white/10">
        <div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-3 px-4 py-6 text-xs text-white/45 sm:px-6 lg:px-8">
          <p>© {new Date().getFullYear()} MachSetu. All rights reserved.</p>
          <nav className="flex flex-wrap gap-x-5 gap-y-2">
            {LEGAL_LINKS.map((link) => (
              <Link key={link.href} href={link.href} className="hover:text-white">
                {link.label}
              </Link>
            ))}
          </nav>
        </div>
      </div>
    </footer>
  );
}
