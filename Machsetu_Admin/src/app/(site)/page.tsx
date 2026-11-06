import Image from "next/image";
import Link from "next/link";
import { HeroCarousel, type HeroSlide } from "@/components/site/HeroCarousel";
import {
  CtaBand,
  Faq,
  SectionHeading,
} from "@/components/site/blocks";
import {
  Arrow,
  Camera,
  Chat,
  FileCheck,
  Handshake,
  Lock,
  Search,
  ShieldCheck,
  Smartphone,
  Truck,
} from "@/components/site/icons";
import { siteData } from "@/server/site";

const SLIDES: HeroSlide[] = [
  {
    eyebrow: "India's pre-owned machine marketplace",
    title: "Buy verified CNC & VMC machines",
    highlight: "without the guesswork.",
    body: "Browse inspected second-hand machining centres, lathes, EDMs and grinders from sellers across India — with service history, spindle hours and a broker on your side.",
    image: "/machines/vmc_machining_center.jpg",
    imageAlt: "Operator at the control panel of a vertical machining centre",
    caption: "Every listing carries its service record and spindle hours",
    primary: { label: "Explore machines", href: "#machines" },
    secondary: { label: "How it works", href: "#how-it-works" },
  },
  {
    eyebrow: "For machine owners",
    title: "Sell your idle machine",
    highlight: "to serious buyers.",
    body: "List in minutes from the MachSetu app. Our sourcing desk reviews every submission — most clear within 48 hours — and brings you verified buyers, not window-shoppers.",
    image: "/machines/integrex_i200.jpg",
    imageAlt: "Multi-tasking CNC machine on a showroom floor",
    caption: "Reviewed by the sourcing desk before it goes live",
    primary: { label: "List a machine", href: "/contact?topic=sell" },
    secondary: { label: "Why sell with us", href: "#why" },
  },
  {
    eyebrow: "Protected end to end",
    title: "Inspection, escrow and freight —",
    highlight: "handled for you.",
    body: "Your payment stays in escrow until the inspection window closes. Freight and installation are quoted upfront, so the price you see is the price you plan for.",
    image: "/machines/mazak_quick_turn.jpg",
    imageAlt: "CNC turning centre ready for dispatch",
    caption: "Funds are released only after your inspection",
    primary: { label: "Talk to a broker", href: "/contact" },
    secondary: { label: "About MachSetu", href: "/about" },
  },
  {
    eyebrow: "Broker-backed negotiation",
    title: "Raise one inquiry,",
    highlight: "get a real quote.",
    body: "Tell us the make, model, budget and location you need. A MachSetu broker carries your offer to the seller and keeps you posted at every step.",
    image: "/machines/okuma_genos.jpg",
    imageAlt: "Horizontal machining centre in a modern plant",
    caption: "One broker, from first inquiry to delivery",
    primary: { label: "Send an inquiry", href: "/contact?topic=buy" },
    secondary: { label: "See our machine range", href: "#machines" },
  },
];

/** The kinds of machines MachSetu deals in — shown without stock or prices. */
const MACHINE_RANGE = [
  {
    name: "Vertical Machining Centres",
    body: "3- and 4-axis VMCs for die, mould and general machining.",
    image: "/machines/haas_vf2ss.jpg",
  },
  {
    name: "CNC Turning Centres",
    body: "Slant-bed CNC lathes for shafts, flanges, bushes and more.",
    image: "/machines/mazak_quick_turn.jpg",
  },
  {
    name: "Horizontal Machining Centres",
    body: "Pallet-changer HMCs for multi-face, high-volume production.",
    image: "/machines/hmc_horizontal.jpg",
  },
  {
    name: "Multi-tasking & 5-Axis",
    body: "Mill-turn and 5-axis machines that finish complex parts in one setup.",
    image: "/machines/integrex_i200.jpg",
  },
  {
    name: "Drill-Tap Centres",
    body: "Compact, high-speed machines for small precision components.",
    image: "/machines/fanuc_robodrill.jpg",
  },
  {
    name: "Wire-Cut EDM",
    body: "Wire EDMs for punches, dies and fine-tolerance profiles.",
    image: "/machines/wire_edm_robofil.jpg",
  },
  {
    name: "Cylindrical Grinders",
    body: "OD/ID grinders for tight-tolerance round work.",
    image: "/machines/grinder_cylindrical.jpg",
  },
  {
    name: "Surface Grinders",
    body: "Precision surface grinding for plates, dies and tooling.",
    image: "/machines/grinder_surface.jpg",
  },
];

const MAKES = [
  "DMG MORI",
  "Mazak",
  "Haas",
  "Okuma",
  "Doosan",
  "FANUC",
  "Makino",
  "Mitsubishi",
  "GF Machining",
];

const BUYER_STEPS = [
  {
    icon: Search,
    title: "Find the right machine",
    body: "Filter by category, make, year and location. Each listing shows photos, specs, hours and documents.",
  },
  {
    icon: Chat,
    title: "Raise an inquiry",
    body: "A broker is assigned, checks the details with the seller and comes back with a firm quote.",
  },
  {
    icon: Lock,
    title: "Pay into escrow",
    body: "Your money is held safely until you have inspected the machine and the window closes.",
  },
  {
    icon: Truck,
    title: "Delivered & installed",
    body: "Freight is quoted upfront and tracked stage by stage until the machine reaches your floor.",
  },
];

const SELLER_STEPS = [
  {
    icon: Camera,
    title: "Photograph & submit",
    body: "Upload photos, the name plate, specs and service papers straight from the app.",
  },
  {
    icon: FileCheck,
    title: "Desk review",
    body: "Our sourcing desk checks every submission — most go live within 48 hours.",
  },
  {
    icon: Handshake,
    title: "Meet verified buyers",
    body: "Brokers bring you qualified offers and handle the negotiation for you.",
  },
  {
    icon: ShieldCheck,
    title: "Get paid securely",
    body: "Escrow releases your payment once the buyer's inspection is complete.",
  },
];

const REASONS = [
  {
    icon: ShieldCheck,
    title: "Technical audit on every listing",
    body: "Spindle hours, service history and a physical check before a machine appears on MachSetu.",
  },
  {
    icon: Lock,
    title: "Escrow-protected payments",
    body: "Funds are held until the inspection window closes — no paying blind for heavy equipment.",
  },
  {
    icon: Handshake,
    title: "A broker on your side",
    body: "Real people who know machines carry your offer, negotiate the price and follow through.",
  },
  {
    icon: Truck,
    title: "Freight & installation",
    body: "Transport is quoted as a clear percentage on every order, and tracked to your door.",
  },
  {
    icon: FileCheck,
    title: "Documents in one place",
    body: "Invoices, service records and inspection reports travel with the listing.",
  },
  {
    icon: Smartphone,
    title: "Track it all in the app",
    body: "Listings, inquiries, quotes and orders — with notifications at every stage.",
  },
];

export default async function HomePage() {
  const data = await siteData();

  const stats = [
    { value: "Pan-India", label: "Buyers & sellers" },
    { value: `${MACHINE_RANGE.length}+`, label: "Machine types we handle" },
    { value: "48 hrs", label: "Typical listing review" },
    { value: "100%", label: "Escrow-protected orders" },
  ];

  return (
    <>
      <HeroCarousel slides={SLIDES} stats={stats} />

      {/* Machine range — the kinds of machines we deal in. No stock, no prices. */}
      <section id="machines" className="scroll-mt-24 px-4 py-20 sm:px-6 lg:px-8 lg:py-28">
        <div className="mx-auto max-w-7xl">
          <SectionHeading
            eyebrow="Our machine range"
            title="Machines we buy & sell"
            body="Pre-owned machine tools from India's workshops and plants — inspected before they change hands. Tell us what you need and we'll source it."
            action={
              <Link
                href="/contact?topic=buy"
                className="inline-flex items-center gap-2 rounded-full border border-line px-5 py-3 text-sm font-bold text-navy-900 transition hover:border-navy-900"
              >
                Share your requirement
                <Arrow className="h-4 w-4" />
              </Link>
            }
          />

          <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {MACHINE_RANGE.map((m) => (
              <Link
                key={m.name}
                href={`/contact?topic=buy&category=${encodeURIComponent(m.name)}`}
                className="group flex flex-col overflow-hidden rounded-3xl border border-line bg-white transition duration-300 hover:-translate-y-1 hover:shadow-[0_24px_48px_-24px_rgba(14,46,92,0.35)]"
              >
                <div className="relative aspect-[4/3] overflow-hidden bg-navy-50">
                  <Image
                    src={m.image}
                    alt={m.name}
                    fill
                    sizes="(min-width: 1024px) 300px, (min-width: 640px) 50vw, 100vw"
                    className="object-cover transition duration-500 group-hover:scale-105"
                  />
                </div>
                <div className="flex flex-1 flex-col p-5">
                  <p className="text-lg leading-snug font-bold text-navy-900">{m.name}</p>
                  <p className="mt-2 text-sm leading-relaxed text-muted">{m.body}</p>
                  <p className="mt-auto flex items-center gap-1.5 pt-4 text-sm font-bold text-accent-600">
                    Enquire
                    <Arrow className="h-4 w-4 transition group-hover:translate-x-1" />
                  </p>
                </div>
              </Link>
            ))}
          </div>

          <p className="mt-8 text-sm text-muted">
            Also: centreless grinders, spark & small-hole EDMs, conventional
            lathes, milling machines and more — just ask.
          </p>

          {/* Makes */}
          <div className="mt-14 rounded-3xl bg-canvas px-6 py-8">
            <p className="text-center text-xs font-bold tracking-[0.16em] text-faint uppercase">
              Makes we regularly source
            </p>
            <ul className="mt-5 flex flex-wrap items-center justify-center gap-x-10 gap-y-4">
              {MAKES.map((make) => (
                <li key={make} className="text-lg font-extrabold tracking-tight text-navy-900/45 transition hover:text-navy-900">
                  {make}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* How it works */}
      <section id="how-it-works" className="scroll-mt-24 bg-canvas px-4 py-20 sm:px-6 lg:px-8 lg:py-28">
        <div className="mx-auto max-w-7xl">
          <SectionHeading
            align="center"
            eyebrow="How it works"
            title="Simple for buyers. Simple for sellers."
            body="MachSetu takes the risk and the running around out of buying and selling heavy machinery."
          />

          <div className="mt-14 grid gap-6 lg:grid-cols-2">
            {[
              { label: "Buying a machine", tone: "navy", steps: BUYER_STEPS },
              { label: "Selling a machine", tone: "accent", steps: SELLER_STEPS },
            ].map((track) => (
              <div
                key={track.label}
                className="rounded-[28px] border border-line bg-white p-6 shadow-[0_1px_2px_rgba(14,46,92,0.04)] sm:p-8"
              >
                <p
                  className={
                    track.tone === "navy"
                      ? "inline-flex rounded-full bg-navy-50 px-3.5 py-1.5 text-xs font-bold text-navy-700"
                      : "inline-flex rounded-full bg-accent-50 px-3.5 py-1.5 text-xs font-bold text-accent-700"
                  }
                >
                  {track.label}
                </p>
                <ol className="mt-6 space-y-6">
                  {track.steps.map((step, i) => {
                    const Icon = step.icon;
                    return (
                      <li key={step.title} className="relative flex gap-4">
                        {i < track.steps.length - 1 && (
                          <span className="absolute top-12 bottom-[-1.5rem] left-6 w-px bg-line" />
                        )}
                        <span
                          className={
                            track.tone === "navy"
                              ? "relative grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-navy-900 text-white"
                              : "relative grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-accent-500 text-white"
                          }
                        >
                          <Icon className="h-5 w-5" />
                        </span>
                        <div>
                          <p className="text-xs font-bold text-faint">STEP {i + 1}</p>
                          <p className="mt-0.5 font-bold text-navy-900">{step.title}</p>
                          <p className="mt-1 text-sm leading-relaxed text-muted">{step.body}</p>
                        </div>
                      </li>
                    );
                  })}
                </ol>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Why MachSetu */}
      <section id="why" className="relative isolate scroll-mt-24 overflow-hidden bg-navy-950 px-4 py-20 text-white sm:px-6 lg:px-8 lg:py-28">
        <div className="site-grid absolute inset-0 -z-10 opacity-[0.06]" />
        <div className="absolute top-0 left-1/2 -z-10 h-96 w-[700px] -translate-x-1/2 rounded-full bg-navy-600/30 blur-[120px]" />
        <div className="mx-auto max-w-7xl">
          <SectionHeading
            tone="dark"
            align="center"
            eyebrow="Why MachSetu"
            title="Built for how machines really change hands"
            body="Buying a used machine shouldn't mean trusting a stranger with lakhs of rupees. We built the safeguards in."
          />
          <div className="mt-14 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {REASONS.map((r) => {
              const Icon = r.icon;
              return (
                <div
                  key={r.title}
                  className="group rounded-3xl border border-white/10 bg-white/[0.04] p-7 backdrop-blur transition hover:-translate-y-1 hover:border-accent-500/50 hover:bg-white/[0.07]"
                >
                  <span className="grid h-12 w-12 place-items-center rounded-2xl bg-accent-500/15 text-accent-500 transition group-hover:bg-accent-500 group-hover:text-white">
                    <Icon className="h-6 w-6" />
                  </span>
                  <p className="mt-5 text-lg font-bold">{r.title}</p>
                  <p className="mt-2 text-sm leading-relaxed text-white/60">{r.body}</p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* App */}
      <section className="px-4 py-20 sm:px-6 lg:px-8 lg:py-28">
        <div className="mx-auto grid max-w-7xl items-center gap-12 lg:grid-cols-2">
          <div>
            <SectionHeading
              eyebrow="The MachSetu app"
              title="Your machine desk, in your pocket"
              body="Browse live listings, raise inquiries, list your own machine with photos and documents, and follow every order stage — all from your phone."
            />
            <ul className="mt-8 grid gap-3 sm:grid-cols-2">
              {[
                "Live catalogue with filters",
                "List a machine in minutes",
                "Broker quotes & negotiation",
                "Order tracking & alerts",
              ].map((item) => (
                <li key={item} className="flex items-center gap-3 text-sm font-semibold text-navy-900">
                  <span className="grid h-6 w-6 place-items-center rounded-full bg-emerald-50 text-emerald-600">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={3} className="h-3.5 w-3.5">
                      <path d="m5 12 5 5L20 7" />
                    </svg>
                  </span>
                  {item}
                </li>
              ))}
            </ul>
            <div className="mt-8 inline-flex items-center gap-3 rounded-2xl bg-navy-900 px-5 py-3 text-white">
              <Smartphone className="h-6 w-6 text-accent-500" />
              <div className="leading-tight">
                <p className="text-[11px] text-white/60">Android app</p>
                <p className="text-sm font-bold">Launching soon on Google Play</p>
              </div>
            </div>
          </div>

          <div className="relative">
            <div className="absolute inset-6 -z-10 rounded-[40px] bg-gradient-to-br from-accent-500/30 to-navy-600/30 blur-3xl" />
            <div className="grid grid-cols-2 gap-4">
              <div className="relative aspect-[3/4] overflow-hidden rounded-3xl">
                <Image src="/machines/haas_vf2.jpg" alt="Vertical machining centre" fill sizes="(min-width: 1024px) 300px, 50vw" className="object-cover" />
              </div>
              <div className="relative mt-10 aspect-[3/4] overflow-hidden rounded-3xl">
                <Image src="/machines/wire_edm_ona.jpg" alt="Wire EDM machine" fill sizes="(min-width: 1024px) 300px, 50vw" className="object-cover" />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ */}
      {data.support.faqs.length > 0 && (
        <section className="bg-canvas px-4 py-20 sm:px-6 lg:px-8 lg:py-28">
          <div className="mx-auto grid max-w-7xl gap-10 lg:grid-cols-[1fr_1.4fr]">
            <SectionHeading
              eyebrow="FAQ"
              title="Questions buyers and sellers ask us"
              body="Still unsure? Our team is a call away."
              action={
                <Link href="/contact" className="inline-flex items-center gap-2 text-sm font-bold text-accent-600 hover:text-accent-700">
                  Contact support <Arrow className="h-4 w-4" />
                </Link>
              }
            />
            <Faq items={data.support.faqs} />
          </div>
        </section>
      )}

      <CtaBand
        title="Have a machine in mind — or one to sell?"
        body="Tell us what you need and a MachSetu broker will get back to you with options."
        primary={{ label: "Get in touch", href: "/contact" }}
        secondary={{ label: "Learn about us", href: "/about" }}
      />
    </>
  );
}
