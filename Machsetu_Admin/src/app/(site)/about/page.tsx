import type { Metadata } from "next";
import Image from "next/image";
import { CtaBand, PageHero, SectionHeading } from "@/components/site/blocks";
import {
  Eye,
  FileCheck,
  Gear,
  Handshake,
  Lock,
  ShieldCheck,
  Target,
  Truck,
} from "@/components/site/icons";
import { siteData } from "@/server/site";

export const metadata: Metadata = {
  title: "About Us",
  description:
    "MachSetu is the bridge between India's machine owners and the workshops that need them — a verified marketplace for pre-owned CNC, VMC, lathe, EDM and grinding machines.",
};

const PILLARS = [
  {
    icon: Gear,
    title: "Marketplace",
    body: "A live catalogue of pre-owned CNC machines, VMCs, lathes, EDMs and grinders, listed by owners across India.",
  },
  {
    icon: FileCheck,
    title: "Sourcing desk",
    body: "A team that reviews every submission — photos, name plate, specs and papers — before a listing goes live.",
  },
  {
    icon: Handshake,
    title: "Brokerage",
    body: "Brokers who take inquiries, carry offers between buyer and seller, and close the deal on fair terms.",
  },
  {
    icon: Truck,
    title: "Logistics",
    body: "Freight and installation coordinated for heavy equipment, with every stage visible in the app.",
  },
];

const PROCESS = [
  {
    title: "Submission",
    body: "The seller lists the machine with photos, specs, service history and documents.",
  },
  {
    title: "Technical audit",
    body: "Our desk checks spindle hours, condition, maintenance records and ownership papers.",
  },
  {
    title: "Live listing",
    body: "Approved machines go live — most submissions clear review within 48 hours.",
  },
  {
    title: "Inquiry & quote",
    body: "Buyers raise an inquiry; a broker confirms details and returns a firm quote.",
  },
  {
    title: "Escrow & inspection",
    body: "Payment is held in escrow while the buyer completes a final inspection.",
  },
  {
    title: "Dispatch & delivery",
    body: "The machine is shipped, tracked stage by stage, and the seller is paid.",
  },
];

const VALUES = [
  {
    icon: ShieldCheck,
    title: "Trust first",
    body: "Nothing goes live without a check, and no one pays blind.",
  },
  {
    icon: Lock,
    title: "Transparent pricing",
    body: "GST, brokerage and freight are shown as clear percentages on every quote.",
  },
  {
    icon: Handshake,
    title: "People, not just a portal",
    body: "Every inquiry has a real broker behind it who knows machines.",
  },
];

export default async function AboutPage() {
  const data = await siteData();

  return (
    <>
      <PageHero
        eyebrow="About MachSetu"
        title={
          <>
            The <span className="text-accent-500">bridge</span> between
            machines and the people who need them.
          </>
        }
        body="“Setu” means bridge. MachSetu connects machine owners who want to sell with workshops and manufacturers who want to buy — and makes the whole journey safe, verified and simple."
        image="/machines/workshop_banner.jpg"
      />

      {/* Story */}
      <section className="px-4 py-20 sm:px-6 lg:px-8 lg:py-28">
        <div className="mx-auto grid max-w-7xl items-center gap-14 lg:grid-cols-2">
          <div className="relative">
            <div className="relative aspect-[4/3] overflow-hidden rounded-[32px]">
              <Image
                src="/machines/dmg_cmx_1100v.jpg"
                alt="Vertical machining centre on a factory floor"
                fill
                sizes="(min-width: 1024px) 600px, 100vw"
                className="object-cover"
              />
            </div>
            <div className="absolute -right-3 -bottom-8 rounded-3xl bg-navy-900 p-6 text-white shadow-2xl sm:-right-8">
              <p className="text-4xl font-extrabold text-accent-500">
                Pan-India
              </p>
              <p className="mt-1 text-sm text-white/70">
                buyers &amp; sellers, {data.categories.length} machine categories
              </p>
            </div>
          </div>

          <div>
            <SectionHeading
              eyebrow="Our story"
              title="Good machines deserve a second life"
            />
            <div className="mt-6 space-y-4 text-base leading-relaxed text-muted sm:text-lg">
              <p>
                Across India, capable CNC and VMC machines sit idle after an
                upgrade or a change in work — while smaller shops struggle to
                afford new ones. The trade in between has always run on phone
                calls, word of mouth and a lot of trust.
              </p>
              <p>
                MachSetu brings that trade online without losing the human
                part. Sellers list in minutes, our desk verifies every machine,
                brokers handle the negotiation, and escrow protects the money
                until the buyer is satisfied.
              </p>
              <p>
                The result: owners recover real value from their equipment, and
                buyers get dependable machines at a fraction of the new price.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Mission & vision */}
      <section className="bg-canvas px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto grid max-w-7xl gap-6 md:grid-cols-2">
          {[
            {
              icon: Target,
              label: "Our mission",
              body: "Make buying and selling pre-owned industrial machinery as safe and simple as buying new — with verified listings, fair prices and protected payments.",
            },
            {
              icon: Eye,
              label: "Our vision",
              body: "Become India's most trusted marketplace for second-hand machine tools, helping every workshop grow with the right equipment.",
            },
          ].map((card) => {
            const Icon = card.icon;
            return (
              <div key={card.label} className="rounded-[28px] border border-line bg-white p-8 sm:p-10">
                <span className="grid h-14 w-14 place-items-center rounded-2xl bg-accent-500 text-white">
                  <Icon className="h-7 w-7" />
                </span>
                <h3 className="mt-6 text-2xl font-extrabold text-navy-900">{card.label}</h3>
                <p className="mt-3 text-lg leading-relaxed text-muted">{card.body}</p>
              </div>
            );
          })}
        </div>
      </section>

      {/* What we do */}
      <section className="px-4 py-20 sm:px-6 lg:px-8 lg:py-28">
        <div className="mx-auto max-w-7xl">
          <SectionHeading
            align="center"
            eyebrow="What we do"
            title="One platform, the whole deal"
            body="Everything it takes to move a machine from one shop floor to another."
          />
          <div className="mt-14 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {PILLARS.map((p) => {
              const Icon = p.icon;
              return (
                <div
                  key={p.title}
                  className="group rounded-3xl border border-line bg-white p-7 transition hover:-translate-y-1 hover:border-accent-500/40 hover:shadow-[0_24px_48px_-24px_rgba(14,46,92,0.3)]"
                >
                  <span className="grid h-12 w-12 place-items-center rounded-2xl bg-navy-50 text-navy-700 transition group-hover:bg-navy-900 group-hover:text-white">
                    <Icon className="h-6 w-6" />
                  </span>
                  <p className="mt-5 text-lg font-bold text-navy-900">{p.title}</p>
                  <p className="mt-2 text-sm leading-relaxed text-muted">{p.body}</p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Process */}
      <section className="relative isolate overflow-hidden bg-navy-950 px-4 py-20 text-white sm:px-6 lg:px-8 lg:py-28">
        <div className="site-grid absolute inset-0 -z-10 opacity-[0.06]" />
        <div className="mx-auto max-w-7xl">
          <SectionHeading
            tone="dark"
            eyebrow="How a deal moves"
            title="From listing to delivery, every step checked"
          />
          <ol className="mt-14 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {PROCESS.map((step, i) => (
              <li
                key={step.title}
                className="relative rounded-3xl border border-white/10 bg-white/[0.04] p-7"
              >
                <span className="text-5xl font-extrabold text-white/10">
                  {String(i + 1).padStart(2, "0")}
                </span>
                <p className="mt-2 text-lg font-bold">{step.title}</p>
                <p className="mt-2 text-sm leading-relaxed text-white/60">{step.body}</p>
              </li>
            ))}
          </ol>
        </div>
      </section>

      {/* Values */}
      <section className="px-4 py-20 sm:px-6 lg:px-8 lg:py-28">
        <div className="mx-auto max-w-7xl">
          <SectionHeading eyebrow="What we stand for" title="Our values" />
          <div className="mt-12 grid gap-6 md:grid-cols-3">
            {VALUES.map((v) => {
              const Icon = v.icon;
              return (
                <div key={v.title} className="flex gap-4">
                  <span className="grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-accent-50 text-accent-600">
                    <Icon className="h-6 w-6" />
                  </span>
                  <div>
                    <p className="text-lg font-bold text-navy-900">{v.title}</p>
                    <p className="mt-1 leading-relaxed text-muted">{v.body}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      <CtaBand
        title="Let's move your next machine"
        body="Whether you are buying or selling, our team is ready to help."
        primary={{ label: "Contact us", href: "/contact" }}
        secondary={{ label: "Back to home", href: "/" }}
      />
    </>
  );
}
