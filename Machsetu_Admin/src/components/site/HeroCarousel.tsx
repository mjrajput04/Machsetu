"use client";

import Image from "next/image";
import Link from "next/link";
import { useCallback, useEffect, useRef, useState } from "react";
import { cx } from "@/components/ui";
import { Arrow, ShieldCheck } from "./icons";

export interface HeroSlide {
  eyebrow: string;
  title: string;
  highlight: string;
  body: string;
  image: string;
  imageAlt: string;
  caption: string;
  primary: { label: string; href: string };
  secondary: { label: string; href: string };
}

const INTERVAL = 6000;

/**
 * Auto-advancing hero. Pauses while the pointer is over it or the tab is
 * hidden, and swipes on touch screens.
 */
export function HeroCarousel({
  slides,
  stats,
}: {
  slides: HeroSlide[];
  stats: { value: string; label: string }[];
}) {
  const [index, setIndex] = useState(0);
  const [paused, setPaused] = useState(false);
  const touchX = useRef<number | null>(null);
  const count = slides.length;

  const go = useCallback(
    (next: number) => setIndex(((next % count) + count) % count),
    [count],
  );

  useEffect(() => {
    if (paused || count < 2) return;
    const timer = window.setTimeout(() => go(index + 1), INTERVAL);
    return () => window.clearTimeout(timer);
  }, [index, paused, count, go]);

  useEffect(() => {
    const onVisibility = () => setPaused(document.hidden);
    document.addEventListener("visibilitychange", onVisibility);
    return () => document.removeEventListener("visibilitychange", onVisibility);
  }, []);

  return (
    <section
      className="relative isolate overflow-hidden bg-navy-950 text-white"
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
      onTouchStart={(e) => (touchX.current = e.touches[0].clientX)}
      onTouchEnd={(e) => {
        if (touchX.current == null) return;
        const dx = e.changedTouches[0].clientX - touchX.current;
        if (Math.abs(dx) > 50) go(index + (dx < 0 ? 1 : -1));
        touchX.current = null;
      }}
      aria-roledescription="carousel"
      aria-label="MachSetu highlights"
    >
      {/* Backdrop: a soft glow and a fine grid, like a machine shop floor plan. */}
      <div className="pointer-events-none absolute inset-0 -z-10">
        <div className="absolute -top-40 -left-40 h-[520px] w-[520px] rounded-full bg-navy-600/40 blur-[120px]" />
        <div className="absolute -right-32 -bottom-48 h-[480px] w-[480px] rounded-full bg-accent-500/25 blur-[120px]" />
        <div className="site-grid absolute inset-0 opacity-[0.07]" />
      </div>

      <div className="mx-auto grid max-w-7xl items-center gap-10 px-4 pt-12 pb-10 sm:px-6 sm:pb-16 lg:min-h-[640px] lg:grid-cols-[1.05fr_1fr] lg:gap-14 lg:px-8 lg:pt-16 lg:pb-24">
        {/* Copy — every slide sits in the same grid cell, so the block is as
            tall as the longest one and nothing below it ever overlaps. */}
        <div className="grid">
          {slides.map((slide, i) => (
            <div
              key={slide.title}
              role="group"
              aria-roledescription="slide"
              aria-label={`${i + 1} of ${count}`}
              aria-hidden={i !== index}
              className={cx(
                "[grid-area:1/1] self-center transition-all duration-700 ease-out",
                i === index
                  ? "translate-y-0 opacity-100"
                  : "pointer-events-none translate-y-4 opacity-0",
              )}
            >
              <span className="inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/5 px-3.5 py-1.5 text-xs font-semibold tracking-wide text-white/80 backdrop-blur">
                <span className="h-1.5 w-1.5 rounded-full bg-accent-500" />
                {slide.eyebrow}
              </span>
              <h1 className="mt-5 text-4xl leading-[1.08] font-extrabold tracking-tight sm:text-5xl lg:text-[3.4rem]">
                {slide.title}{" "}
                <span className="bg-gradient-to-r from-accent-500 to-amber-300 bg-clip-text text-transparent">
                  {slide.highlight}
                </span>
              </h1>
              <p className="mt-5 max-w-xl text-base leading-relaxed text-white/70 sm:text-lg">
                {slide.body}
              </p>
              <div className="mt-8 flex flex-wrap gap-3">
                <Link
                  href={slide.primary.href}
                  tabIndex={i === index ? 0 : -1}
                  className="inline-flex items-center gap-2 rounded-full bg-accent-500 px-6 py-3.5 text-sm font-bold text-white shadow-[0_12px_30px_-10px_rgba(249,115,22,0.8)] transition hover:-translate-y-0.5 hover:bg-accent-600"
                >
                  {slide.primary.label}
                  <Arrow className="h-4 w-4" />
                </Link>
                <Link
                  href={slide.secondary.href}
                  tabIndex={i === index ? 0 : -1}
                  className="inline-flex items-center gap-2 rounded-full border border-white/20 bg-white/5 px-6 py-3.5 text-sm font-bold text-white backdrop-blur transition hover:bg-white/10"
                >
                  {slide.secondary.label}
                </Link>
              </div>
            </div>
          ))}
        </div>

        {/* Photo stack */}
        <div className="relative">
          <div className="relative aspect-[4/3] overflow-hidden rounded-[28px] shadow-[0_40px_80px_-30px_rgba(0,0,0,0.7)] ring-1 ring-white/10">
            {slides.map((slide, i) => (
              <div
                key={slide.image}
                className={cx(
                  "absolute inset-0 transition-opacity duration-1000",
                  i === index ? "opacity-100" : "opacity-0",
                )}
              >
                <Image
                  src={slide.image}
                  alt={slide.imageAlt}
                  fill
                  priority={i === 0}
                  sizes="(min-width: 1024px) 560px, 100vw"
                  className={cx(
                    "object-cover",
                    i === index && "site-kenburns",
                  )}
                />
              </div>
            ))}
            <div className="absolute inset-0 bg-gradient-to-t from-navy-950/80 via-navy-950/10 to-transparent" />
            <p className="absolute bottom-5 left-5 right-5 text-sm font-semibold text-white/90">
              {slides[index].caption}
            </p>
          </div>

          {/* Floating trust card */}
          <div className="absolute -top-5 -right-3 hidden items-center gap-3 rounded-2xl bg-white px-4 py-3 text-ink shadow-xl sm:flex lg:-right-6">
            <span className="grid h-10 w-10 place-items-center rounded-xl bg-emerald-50 text-emerald-600">
              <ShieldCheck className="h-5 w-5" />
            </span>
            <div className="leading-tight">
              <p className="text-sm font-bold text-navy-900">Inspected before listing</p>
              <p className="text-xs text-muted">Escrow-protected payment</p>
            </div>
          </div>
        </div>
      </div>

      {/* Controls */}
      <div className="mx-auto flex max-w-7xl items-center gap-4 px-4 pb-10 sm:px-6 lg:-mt-12 lg:px-8">
        <div className="flex items-center gap-2">
          {slides.map((slide, i) => (
            <button
              key={slide.title}
              aria-label={`Show slide ${i + 1}`}
              aria-current={i === index}
              onClick={() => go(i)}
              className="group relative h-1.5 overflow-hidden rounded-full bg-white/15 transition-all"
              style={{ width: i === index ? 48 : 20 }}
            >
              {i === index && (
                <span
                  key={`${index}-${paused}`}
                  className={cx(
                    "absolute inset-y-0 left-0 rounded-full bg-accent-500",
                    paused ? "w-full" : "site-progress",
                  )}
                  style={{ animationDuration: `${INTERVAL}ms` }}
                />
              )}
            </button>
          ))}
        </div>
        <div className="ml-auto flex gap-2">
          <button
            aria-label="Previous slide"
            onClick={() => go(index - 1)}
            className="grid h-10 w-10 place-items-center rounded-full border border-white/15 text-white/80 transition hover:bg-white/10 hover:text-white"
          >
            <Arrow className="h-4 w-4 rotate-180" />
          </button>
          <button
            aria-label="Next slide"
            onClick={() => go(index + 1)}
            className="grid h-10 w-10 place-items-center rounded-full border border-white/15 text-white/80 transition hover:bg-white/10 hover:text-white"
          >
            <Arrow className="h-4 w-4" />
          </button>
        </div>
      </div>

      {/* Stats ribbon */}
      <div className="border-t border-white/10 bg-white/[0.03]">
        <dl className="mx-auto grid max-w-7xl grid-cols-2 gap-px px-4 sm:px-6 lg:grid-cols-4 lg:px-8">
          {stats.map((s) => (
            <div key={s.label} className="px-2 py-6 sm:px-4">
              <dt className="text-xs font-semibold tracking-wide text-white/50 uppercase">
                {s.label}
              </dt>
              <dd className="mt-1 text-2xl font-extrabold tracking-tight sm:text-3xl">
                {s.value}
              </dd>
            </div>
          ))}
        </dl>
      </div>
    </section>
  );
}
