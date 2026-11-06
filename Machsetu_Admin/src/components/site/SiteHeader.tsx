"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { NAV_LINKS } from "@/lib/site";
import { cx } from "@/components/ui";
import { Arrow } from "./icons";

/** Sticky top bar: solid once the page scrolls, a slide-down menu on phones. */
export function SiteHeader() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <header
      className={cx(
        "sticky top-0 z-50 transition-all duration-300",
        scrolled || open
          ? "border-b border-line bg-white/90 shadow-[0_6px_24px_-12px_rgba(14,46,92,0.25)] backdrop-blur-lg"
          : "border-b border-transparent bg-white",
      )}
    >
      <div className="mx-auto flex h-16 max-w-7xl items-center gap-6 px-4 sm:px-6 lg:h-[72px] lg:px-8">
        <Link
          href="/"
          className="flex items-center gap-2.5"
          onClick={() => setOpen(false)}
        >
          <Image
            src="/machsetu-mark.png"
            alt=""
            width={44}
            height={32}
            className="h-8 w-auto"
            priority
          />
          <span className="text-lg font-extrabold tracking-tight text-navy-900">
            Mach<span className="text-accent-500">Setu</span>
          </span>
        </Link>

        <nav className="ml-auto hidden items-center gap-1 md:flex">
          {NAV_LINKS.map((link) => {
            const active = pathname === link.href;
            return (
              <Link
                key={link.href}
                href={link.href}
                className={cx(
                  "relative rounded-full px-4 py-2 text-sm font-semibold transition-colors",
                  active
                    ? "text-navy-900"
                    : "text-muted hover:bg-navy-50 hover:text-navy-900",
                )}
              >
                {link.label}
                {active && (
                  <span className="absolute inset-x-4 -bottom-0.5 h-0.5 rounded-full bg-accent-500" />
                )}
              </Link>
            );
          })}
        </nav>

        <Link
          href="/contact"
          className="hidden items-center gap-2 rounded-full bg-accent-500 px-5 py-2.5 text-sm font-bold text-white shadow-[0_8px_20px_-8px_rgba(249,115,22,0.7)] transition hover:-translate-y-0.5 hover:bg-accent-600 md:inline-flex"
        >
          Talk to us
          <Arrow className="h-4 w-4" />
        </Link>

        <button
          aria-label={open ? "Close menu" : "Open menu"}
          aria-expanded={open}
          onClick={() => setOpen((v) => !v)}
          className="ml-auto grid h-10 w-10 place-items-center rounded-full text-navy-900 hover:bg-navy-50 md:hidden"
        >
          <svg
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth={2}
            strokeLinecap="round"
            className="h-5 w-5"
          >
            {open ? (
              <path d="M6 6l12 12M18 6 6 18" />
            ) : (
              <path d="M4 7h16M4 12h16M4 17h16" />
            )}
          </svg>
        </button>
      </div>

      <div
        className={cx(
          "grid overflow-hidden transition-all duration-300 md:hidden",
          open ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0",
        )}
      >
        <nav className="min-h-0 px-4 pb-4">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              onClick={() => setOpen(false)}
              className={cx(
                "block rounded-xl px-4 py-3 text-base font-semibold",
                pathname === link.href
                  ? "bg-navy-50 text-navy-900"
                  : "text-muted hover:bg-navy-50",
              )}
            >
              {link.label}
            </Link>
          ))}
          <Link
            href="/contact"
            onClick={() => setOpen(false)}
            className="mt-2 flex items-center justify-center gap-2 rounded-xl bg-accent-500 px-4 py-3 text-base font-bold text-white"
          >
            Talk to us <Arrow className="h-4 w-4" />
          </Link>
        </nav>
      </div>
    </header>
  );
}
