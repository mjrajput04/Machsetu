import type { Metadata } from "next";
import { ContactForm } from "@/components/site/ContactForm";
import { Faq, PageHero } from "@/components/site/blocks";
import { Clock, Mail, MapPin, Phone, Whatsapp } from "@/components/site/icons";
import { OFFICE, type ContactTopic } from "@/lib/site";
import { siteData } from "@/server/site";

export const metadata: Metadata = {
  title: "Contact Us",
  description:
    "Talk to MachSetu about buying or selling a pre-owned CNC, VMC, lathe, EDM or grinding machine. Call, WhatsApp, email or send us a message.",
};

type Props = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const one = (value: string | string[] | undefined) =>
  (Array.isArray(value) ? value[0] : value)?.trim() ?? "";

/**
 * Links from the rest of the site arrive with `?topic=sell` or
 * `?category=Lathes`, so the form opens already filled in.
 */
function prefill(params: Awaited<Props["searchParams"]>) {
  const category = one(params.category).slice(0, 60);
  const topicParam = one(params.topic);

  if (topicParam === "sell") {
    return {
      topic: "Selling a machine" as ContactTopic,
      message: "Hi, I'd like to sell a machine. Make / model / year: ",
    };
  }
  if (topicParam === "buy" || category) {
    return {
      topic: "Buying a machine" as ContactTopic,
      message: category ? `Hi, I'm looking for ${category}. Requirement: ` : "",
    };
  }
  return { topic: "Buying a machine" as ContactTopic, message: "" };
}

export default async function ContactPage({ searchParams }: Props) {
  const [data, params] = await Promise.all([siteData(), searchParams]);
  const initial = prefill(params);
  const { phone, email, hours, faqs } = data.support;

  const digits = phone.replace(/\D/g, "");
  const whatsapp = digits.length >= 10 ? `https://wa.me/${digits.length === 10 ? `91${digits}` : digits}` : null;

  const channels = [
    {
      icon: Phone,
      label: "Call us",
      value: phone,
      href: `tel:+${digits.length === 10 ? `91${digits}` : digits}`,
    },
    whatsapp && {
      icon: Whatsapp,
      label: "WhatsApp",
      value: "Chat with our team",
      href: `${whatsapp}?text=${encodeURIComponent("Hi MachSetu, I have a question about a machine.")}`,
    },
    { icon: Mail, label: "Email", value: email, href: `mailto:${email}` },
    { icon: Clock, label: "Working hours", value: hours, href: null },
    {
      icon: MapPin,
      label: "Based in",
      value: `${OFFICE.city}, ${OFFICE.region}`,
      href: null,
    },
  ].filter(Boolean) as {
    icon: typeof Phone;
    label: string;
    value: string;
    href: string | null;
  }[];

  return (
    <>
      <PageHero
        eyebrow="Contact"
        title={
          <>
            Let&apos;s talk <span className="text-accent-500">machines.</span>
          </>
        }
        body="Looking for a specific machine, ready to sell one, or just have a question? Reach out — a real person from our team will help."
        image="/machines/hmc_horizontal.jpg"
      />

      <section className="px-4 py-16 sm:px-6 lg:px-8 lg:py-24">
        <div className="mx-auto grid max-w-7xl gap-10 lg:grid-cols-[1fr_1.5fr]">
          <div>
            <h2 className="text-2xl font-extrabold text-navy-900">Reach us directly</h2>
            <p className="mt-2 text-muted">
              Prefer to talk? Pick whichever is easiest for you.
            </p>
            <ul className="mt-8 space-y-3">
              {channels.map((c) => {
                const Icon = c.icon;
                const body = (
                  <>
                    <span className="grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-navy-50 text-navy-700 transition group-hover:bg-accent-500 group-hover:text-white">
                      <Icon className="h-5 w-5" />
                    </span>
                    <span className="min-w-0">
                      <span className="block text-xs font-bold tracking-wide text-faint uppercase">
                        {c.label}
                      </span>
                      <span className="block truncate font-bold text-navy-900">{c.value}</span>
                    </span>
                  </>
                );
                return (
                  <li key={c.label}>
                    {c.href ? (
                      <a
                        href={c.href}
                        target={c.href.startsWith("http") ? "_blank" : undefined}
                        rel={c.href.startsWith("http") ? "noopener noreferrer" : undefined}
                        className="group flex items-center gap-4 rounded-2xl border border-line bg-white p-4 transition hover:-translate-y-0.5 hover:border-accent-500/40 hover:shadow-[0_16px_40px_-24px_rgba(14,46,92,0.35)]"
                      >
                        {body}
                      </a>
                    ) : (
                      <div className="group flex items-center gap-4 rounded-2xl border border-line bg-white p-4">
                        {body}
                      </div>
                    )}
                  </li>
                );
              })}
            </ul>
          </div>

          <ContactForm
            key={`${initial.topic}|${initial.message}`}
            initialTopic={initial.topic}
            initialMessage={initial.message}
          />
        </div>
      </section>

      {faqs.length > 0 && (
        <section className="bg-canvas px-4 py-16 sm:px-6 lg:px-8 lg:py-24">
          <div className="mx-auto max-w-3xl">
            <h2 className="text-center text-3xl font-extrabold tracking-tight text-navy-900">
              Before you write — quick answers
            </h2>
            <div className="mt-10">
              <Faq items={faqs} />
            </div>
          </div>
        </section>
      )}
    </>
  );
}
