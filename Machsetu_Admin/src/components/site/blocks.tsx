import Image from "next/image";
import Link from "next/link";
import type { ReactNode } from "react";
import { cx } from "@/components/ui";
import { Arrow } from "./icons";

/** Small label above a section title. */
export function Eyebrow({
  children,
  tone = "light",
}: {
  children: ReactNode;
  tone?: "light" | "dark";
}) {
  return (
    <p
      className={cx(
        "inline-flex items-center gap-2 text-xs font-bold tracking-[0.16em] uppercase",
        tone === "light" ? "text-accent-600" : "text-accent-500",
      )}
    >
      <span className="h-px w-6 bg-current" />
      {children}
    </p>
  );
}

export function SectionHeading({
  eyebrow,
  title,
  body,
  align = "left",
  tone = "light",
  action,
}: {
  eyebrow: string;
  title: ReactNode;
  body?: string;
  align?: "left" | "center";
  tone?: "light" | "dark";
  action?: ReactNode;
}) {
  return (
    <div
      className={cx(
        "flex flex-wrap items-end justify-between gap-6",
        align === "center" && "flex-col items-center text-center",
      )}
    >
      <div className={cx("max-w-2xl", align === "center" && "mx-auto")}>
        <Eyebrow tone={tone}>{eyebrow}</Eyebrow>
        <h2
          className={cx(
            "mt-3 text-3xl font-extrabold tracking-tight sm:text-4xl",
            tone === "light" ? "text-navy-900" : "text-white",
          )}
        >
          {title}
        </h2>
        {body && (
          <p
            className={cx(
              "mt-4 text-base leading-relaxed sm:text-lg",
              tone === "light" ? "text-muted" : "text-white/65",
            )}
          >
            {body}
          </p>
        )}
      </div>
      {action}
    </div>
  );
}

/** Dark banner at the top of inner pages. */
export function PageHero({
  eyebrow,
  title,
  body,
  image,
}: {
  eyebrow: string;
  title: ReactNode;
  body: string;
  image: string;
}) {
  return (
    <section className="relative isolate overflow-hidden bg-navy-950 text-white">
      <Image
        src={image}
        alt=""
        fill
        priority
        sizes="100vw"
        className="-z-20 object-cover opacity-25"
      />
      <div className="absolute inset-0 -z-10 bg-gradient-to-r from-navy-950 via-navy-950/90 to-navy-950/40" />
      <div className="site-grid absolute inset-0 -z-10 opacity-[0.06]" />
      <div className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8 lg:py-28">
        <div className="site-rise max-w-3xl">
          <Eyebrow tone="dark">{eyebrow}</Eyebrow>
          <h1 className="mt-4 text-4xl leading-[1.1] font-extrabold tracking-tight sm:text-5xl lg:text-6xl">
            {title}
          </h1>
          <p className="mt-6 max-w-2xl text-lg leading-relaxed text-white/70">{body}</p>
        </div>
      </div>
    </section>
  );
}

/** Orange closing call-to-action shared by every page. */
export function CtaBand({
  title,
  body,
  primary,
  secondary,
}: {
  title: string;
  body: string;
  primary: { label: string; href: string };
  secondary?: { label: string; href: string };
}) {
  return (
    <section className="px-4 py-16 sm:px-6 lg:px-8 lg:py-24">
      <div className="relative mx-auto max-w-7xl overflow-hidden rounded-[32px] bg-gradient-to-br from-accent-500 via-accent-600 to-accent-700 px-6 py-14 text-white sm:px-12 lg:px-16 lg:py-16">
        <div className="site-grid absolute inset-0 opacity-10" />
        <div className="absolute -top-24 -right-24 h-72 w-72 rounded-full bg-white/15 blur-3xl" />
        <div className="relative flex flex-wrap items-center justify-between gap-8">
          <div className="max-w-2xl">
            <h2 className="text-3xl font-extrabold tracking-tight sm:text-4xl">{title}</h2>
            <p className="mt-3 text-lg text-white/85">{body}</p>
          </div>
          <div className="flex flex-wrap gap-3">
            <Link
              href={primary.href}
              className="inline-flex items-center gap-2 rounded-full bg-white px-6 py-3.5 text-sm font-bold text-accent-700 shadow-lg transition hover:-translate-y-0.5"
            >
              {primary.label}
              <Arrow className="h-4 w-4" />
            </Link>
            {secondary && (
              <Link
                href={secondary.href}
                className="inline-flex items-center gap-2 rounded-full border border-white/40 px-6 py-3.5 text-sm font-bold text-white transition hover:bg-white/10"
              >
                {secondary.label}
              </Link>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}

/** Expandable question list, rendered with native <details> so it needs no JS. */
export function Faq({ items }: { items: { question: string; answer: string }[] }) {
  return (
    <div className="divide-y divide-line overflow-hidden rounded-3xl border border-line bg-white">
      {items.map((item) => (
        <details key={item.question} className="group px-6 py-5 open:bg-navy-50/40">
          <summary className="flex cursor-pointer list-none items-center justify-between gap-4 text-left font-bold text-navy-900 [&::-webkit-details-marker]:hidden">
            {item.question}
            <span className="grid h-8 w-8 shrink-0 place-items-center rounded-full bg-navy-50 text-navy-700 transition group-open:rotate-45 group-open:bg-accent-500 group-open:text-white">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.2} strokeLinecap="round" className="h-4 w-4">
                <path d="M12 5v14M5 12h14" />
              </svg>
            </span>
          </summary>
          <p className="mt-3 pr-12 leading-relaxed text-muted">{item.answer}</p>
        </details>
      ))}
    </div>
  );
}
