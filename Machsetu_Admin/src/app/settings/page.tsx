"use client";

import Image from "next/image";
import { useRef, useState } from "react";
import { api, useApi } from "@/lib/api";
import { relativeDate } from "@/lib/format";
import {
  Badge,
  Button,
  Card,
  CardHeader,
  EmptyState,
  PageHeader,
  cx,
} from "@/components/ui";

/** Left-hand menu; each entry is one panel of the settings page. */
const SECTIONS = [
  {
    id: "categories",
    label: "Categories",
    hint: "Filter chips in the buyer app",
    icon: "M4 6h16M4 12h16M4 18h10",
  },
  {
    id: "hero",
    label: "App Home Hero",
    hint: "Carousel at the top of the app",
    icon: "M3 5h18v11H3zM8 20h8",
  },
  {
    id: "listings",
    label: "Listing Rules",
    hint: "What a submission must carry",
    icon: "M9 11l3 3 8-8M4 12v7h16v-4",
  },
  {
    id: "commercials",
    label: "Fees & Taxes",
    hint: "Percentages behind every quote",
    icon: "M12 3v18M8 7h6a3 3 0 0 1 0 6H9a3 3 0 0 0 0 6h7",
  },
  {
    id: "escrow",
    label: "Escrow",
    hint: "When funds are released",
    icon: "M5 11h14v9H5zM8 11V8a4 4 0 0 1 8 0v3",
  },
  {
    id: "support",
    label: "Help & Terms",
    hint: "FAQs and legal copy in the app",
    icon: "M12 17h.01M12 14a3 3 0 1 0-3-3M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z",
  },
  {
    id: "sell",
    label: "Seller Wizard",
    hint: "Photo and document checklists",
    icon: "M12 5v14M5 12h14",
  },
  {
    id: "team",
    label: "Team & Roles",
    hint: "Who can sign in here",
    icon: "M16 20v-2a4 4 0 0 0-8 0v2M12 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6z",
  },
  {
    id: "notifications",
    label: "Notifications",
    hint: "What the desk gets pinged about",
    icon: "M6 9a6 6 0 1 1 12 0c0 5 2 6 2 6H4s2-1 2-6M10 20h4",
  },
] as const;

type Section = (typeof SECTIONS)[number]["id"];

interface Category {
  name: string;
  visible: boolean;
}

interface HeroSlide {
  badge: string;
  title: string;
  subtitle: string;
  ctaLabel: string;
  image: string;
}

const BLANK_SLIDE: HeroSlide = {
  badge: "",
  title: "",
  subtitle: "",
  ctaLabel: "",
  image: "",
};

interface Commercials {
  gstRate: number;
  brokerageRate: number;
  shippingRate: number;
  platformCommission: number;
}

interface ListingRules {
  requireInspection: boolean;
  requireOwnershipProof: boolean;
  autoPublishTrusted: boolean;
  allowPriceOnRequest: boolean;
  minimumPhotos: number;
  listingExpiryDays: number;
}

interface Escrow {
  holdUntilSignOff: boolean;
  autoRelease: boolean;
  inspectionWindowDays: number;
  releaseDelayHours: number;
}

interface Faq {
  question: string;
  answer: string;
}

interface Support {
  faqs: Faq[];
  phone: string;
  email: string;
  hours: string;
  terms: string;
}

interface SellOptions {
  requiredPhotos: string[];
  documentTypes: string[];
  workingStatus: string[];
  conditions: string[];
  maintenanceStatus: string[];
  ownerTypes: string[];
}

interface Settings {
  categories: Category[];
  heroSlides: HeroSlide[];
  commercials: Commercials;
  listingRules: ListingRules;
  escrow: Escrow;
  notifications: Record<string, boolean>;
  support: Support;
  sellOptions: SellOptions;
}

/**
 * Sections added over time, so a document saved by an older build can be
 * missing one. Filling the gaps here keeps every card renderable instead of
 * crashing on an undefined section.
 */
const EMPTY: Settings = {
  categories: [],
  heroSlides: [],
  commercials: {
    gstRate: 18,
    brokerageRate: 1.5,
    shippingRate: 0.5,
    platformCommission: 2.5,
  },
  listingRules: {
    requireInspection: true,
    requireOwnershipProof: true,
    autoPublishTrusted: false,
    allowPriceOnRequest: true,
    minimumPhotos: 6,
    listingExpiryDays: 90,
  },
  escrow: {
    holdUntilSignOff: true,
    autoRelease: true,
    inspectionWindowDays: 7,
    releaseDelayHours: 48,
  },
  notifications: {},
  support: { faqs: [], phone: "", email: "", hours: "", terms: "" },
  sellOptions: {
    requiredPhotos: [],
    documentTypes: [],
    workingStatus: [],
    conditions: [],
    maintenanceStatus: [],
    ownerTypes: [],
  },
};

/**
 * Everything on this page is read by the mobile app: category chips, the home
 * hero and the fee percentages behind every cart total.
 */
export default function SettingsPage() {
  const [section, setSection] = useState<Section>("categories");
  const record = useApi<{ settings: Settings }>("/api/admin/settings");
  const saved = record.data?.settings;

  // Only edited sections live in state, so a reload shows fresh values.
  const [edits, setEdits] = useState<Partial<Settings>>({});
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);

  if (!saved) {
    return (
      <>
        <PageHeader
          title="Settings"
          subtitle="Marketplace rules, commercial defaults and console access."
        />
        <Card>
          <EmptyState
            title={
              record.loading ? "Loading settings…" : "Could not load settings"
            }
            message={record.error ?? "Reading the marketplace configuration."}
          />
        </Card>
      </>
    );
  }

  const current: Settings = {
    ...EMPTY,
    ...saved,
    ...edits,
    commercials: {
      ...EMPTY.commercials,
      ...saved.commercials,
      ...edits.commercials,
    },
    listingRules: {
      ...EMPTY.listingRules,
      ...saved.listingRules,
      ...edits.listingRules,
    },
    escrow: { ...EMPTY.escrow, ...saved.escrow, ...edits.escrow },
    support: { ...EMPTY.support, ...saved.support, ...edits.support },
    sellOptions: {
      ...EMPTY.sellOptions,
      ...saved.sellOptions,
      ...edits.sellOptions,
    },
  };

  function patch(next: Partial<Settings>) {
    setEdits((prev) => ({ ...prev, ...next }));
    setDone(false);
  }

  async function save() {
    setSaving(true);
    setError(null);
    try {
      await api.put("/api/admin/settings", current);
      setEdits({});
      record.reload();
      setDone(true);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <>
      <PageHeader
        title="Settings"
        subtitle="Marketplace rules, commercial defaults and console access."
        actions={
          <>
            <Button
              variant="secondary"
              disabled={saving}
              onClick={() => {
                setEdits({});
                setDone(false);
              }}
            >
              Discard
            </Button>
            <Button disabled={saving} onClick={save}>
              {saving ? "Saving…" : done ? "Saved" : "Save changes"}
            </Button>
          </>
        }
      />

      {error && (
        <div className="mb-4 rounded-lg border border-rose-200 bg-rose-50 px-4 py-3 text-sm font-semibold text-rose-700">
          {error}
        </div>
      )}

      <div className="grid gap-4 lg:grid-cols-[248px_minmax(0,1fr)]">
        <nav aria-label="Settings sections">
          <Card padded={false} className="overflow-hidden lg:sticky lg:top-4">
            <ul>
              {SECTIONS.map((s) => (
                <li key={s.id}>
                  <button
                    onClick={() => setSection(s.id)}
                    aria-current={section === s.id ? "page" : undefined}
                    className={cx(
                      "flex w-full items-start gap-3 border-l-2 px-4 py-3 text-left transition-colors",
                      section === s.id
                        ? "border-accent-500 bg-accent-50/60"
                        : "border-transparent hover:bg-canvas",
                    )}
                  >
                    <svg
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth={1.7}
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      className={cx(
                        "mt-0.5 h-4 w-4 shrink-0",
                        section === s.id ? "text-accent-600" : "text-muted",
                      )}
                    >
                      <path d={s.icon} />
                    </svg>
                    <span className="min-w-0">
                      <span
                        className={cx(
                          "block text-sm font-semibold",
                          section === s.id
                            ? "text-accent-700"
                            : "text-navy-800",
                        )}
                      >
                        {s.label}
                      </span>
                      <span className="mt-0.5 block text-xs text-muted">
                        {s.hint}
                      </span>
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          </Card>
        </nav>

        <div className="space-y-4">
          {section === "categories" && (
            <CategoriesCard
              categories={current.categories}
              onChange={(categories) => patch({ categories })}
            />
          )}

          {section === "hero" && (
            <HeroSlidesCard
              slides={current.heroSlides}
              onChange={(heroSlides) => patch({ heroSlides })}
            />
          )}

          {section === "listings" && (
            <Card>
              <CardHeader
                title="Listing rules"
                subtitle="Applied to every seller submission"
              />
              <div className="space-y-1">
                <Toggle
                  label="Require inspection before publishing"
                  hint="Listings stay in review until an inspector signs off"
                  on={current.listingRules.requireInspection}
                  onChange={(v) =>
                    patch({
                      listingRules: {
                        ...current.listingRules,
                        requireInspection: v,
                      },
                    })
                  }
                />
                <Toggle
                  label="Require ownership proof"
                  hint="Block approval when the document is missing"
                  on={current.listingRules.requireOwnershipProof}
                  onChange={(v) =>
                    patch({
                      listingRules: {
                        ...current.listingRules,
                        requireOwnershipProof: v,
                      },
                    })
                  }
                />
                <Toggle
                  label="Auto-publish trusted sellers"
                  hint="Sellers with 5+ completed sales skip manual review"
                  on={current.listingRules.autoPublishTrusted}
                  onChange={(v) =>
                    patch({
                      listingRules: {
                        ...current.listingRules,
                        autoPublishTrusted: v,
                      },
                    })
                  }
                />
                <Toggle
                  label="Allow price on request"
                  hint="Sellers may omit an asking price"
                  on={current.listingRules.allowPriceOnRequest}
                  onChange={(v) =>
                    patch({
                      listingRules: {
                        ...current.listingRules,
                        allowPriceOnRequest: v,
                      },
                    })
                  }
                />
              </div>
              <div className="mt-4 grid gap-4 sm:grid-cols-2">
                <NumberField
                  label="Minimum photos"
                  value={current.listingRules.minimumPhotos}
                  onChange={(v) =>
                    patch({
                      listingRules: {
                        ...current.listingRules,
                        minimumPhotos: v,
                      },
                    })
                  }
                />
                <NumberField
                  label="Listing expiry (days)"
                  value={current.listingRules.listingExpiryDays}
                  onChange={(v) =>
                    patch({
                      listingRules: {
                        ...current.listingRules,
                        listingExpiryDays: v,
                      },
                    })
                  }
                />
              </div>
            </Card>
          )}

          {section === "commercials" && (
            <Card>
              <CardHeader
                title="Fees and taxes"
                subtitle="Percentages of the order value, used for every buyer quote"
              />
              <div className="grid gap-4 sm:grid-cols-2">
                <NumberField
                  label="GST rate (%)"
                  value={current.commercials.gstRate}
                  onChange={(v) =>
                    patch({
                      commercials: { ...current.commercials, gstRate: v },
                    })
                  }
                />
                <NumberField
                  label="Brokerage fee (%)"
                  value={current.commercials.brokerageRate}
                  onChange={(v) =>
                    patch({
                      commercials: { ...current.commercials, brokerageRate: v },
                    })
                  }
                />
                <NumberField
                  label="Estimated shipping (%)"
                  value={current.commercials.shippingRate}
                  onChange={(v) =>
                    patch({
                      commercials: { ...current.commercials, shippingRate: v },
                    })
                  }
                />
                <NumberField
                  label="Platform commission (%)"
                  value={current.commercials.platformCommission}
                  onChange={(v) =>
                    patch({
                      commercials: {
                        ...current.commercials,
                        platformCommission: v,
                      },
                    })
                  }
                />
              </div>
              <div className="mt-4 rounded-lg border-l-4 border-accent-500 bg-canvas p-4 text-sm text-muted">
                GST applies to goods plus shipping and brokerage, matching the
                buyer app&apos;s cart and checkout totals.
              </div>
              <QuoteExample commercials={current.commercials} />
            </Card>
          )}

          {section === "escrow" && (
            <Card>
              <CardHeader
                title="Escrow"
                subtitle="Funds release policy for completed orders"
              />
              <div className="space-y-1">
                <Toggle
                  label="Hold funds until buyer sign-off"
                  hint="Release only after the inspection window closes"
                  on={current.escrow.holdUntilSignOff}
                  onChange={(v) =>
                    patch({
                      escrow: { ...current.escrow, holdUntilSignOff: v },
                    })
                  }
                />
                <Toggle
                  label="Auto-release after inspection window"
                  hint="Release automatically if the buyer does not respond"
                  on={current.escrow.autoRelease}
                  onChange={(v) =>
                    patch({ escrow: { ...current.escrow, autoRelease: v } })
                  }
                />
              </div>
              <div className="mt-4 grid gap-4 sm:grid-cols-2">
                <NumberField
                  label="Inspection window (days)"
                  value={current.escrow.inspectionWindowDays}
                  onChange={(v) =>
                    patch({
                      escrow: { ...current.escrow, inspectionWindowDays: v },
                    })
                  }
                />
                <NumberField
                  label="Release delay (hours)"
                  value={current.escrow.releaseDelayHours}
                  onChange={(v) =>
                    patch({
                      escrow: { ...current.escrow, releaseDelayHours: v },
                    })
                  }
                />
              </div>
            </Card>
          )}

          {section === "support" && (
            <SupportCard
              support={current.support}
              onChange={(support) => patch({ support })}
            />
          )}

          {section === "sell" && (
            <SellOptionsCard
              options={current.sellOptions}
              onChange={(sellOptions) => patch({ sellOptions })}
            />
          )}

          {section === "team" && <TeamCard />}

          {section === "notifications" && (
            <Card className="max-w-2xl">
              <CardHeader
                title="Alerts"
                subtitle="What the operations desk gets pinged about"
              />
              <div className="space-y-1">
                {Object.entries(current.notifications).map(([label, on]) => (
                  <Toggle
                    key={label}
                    label={label}
                    on={on}
                    onChange={(v) =>
                      patch({
                        notifications: { ...current.notifications, [label]: v },
                      })
                    }
                  />
                ))}
              </div>
            </Card>
          )}
        </div>
      </div>
    </>
  );
}

/* ---------------------------------------------------------------- cards -- */

function CategoriesCard({
  categories,
  onChange,
}: {
  categories: Category[];
  onChange: (next: Category[]) => void;
}) {
  const [adding, setAdding] = useState("");
  const [editing, setEditing] = useState<number | null>(null);

  function add() {
    const name = adding.trim();
    if (!name) return;
    if (categories.some((c) => c.name.toLowerCase() === name.toLowerCase())) {
      setAdding("");
      return;
    }
    onChange([...categories, { name, visible: true }]);
    setAdding("");
  }

  return (
    <Card>
      <CardHeader
        title="Categories"
        subtitle="Shown as filter chips in the buyer app and in Add Product"
      />
      <ul className="space-y-2">
        {categories.map((c, index) => (
          <li
            key={`${c.name}-${index}`}
            className="flex items-center justify-between gap-3 rounded-lg border border-line px-3.5 py-3"
          >
            {editing === index ? (
              <input
                autoFocus
                value={c.name}
                onChange={(e) => {
                  const next = [...categories];
                  next[index] = { ...c, name: e.target.value };
                  onChange(next);
                }}
                onBlur={() => setEditing(null)}
                onKeyDown={(e) => e.key === "Enter" && setEditing(null)}
                className="min-w-0 flex-1 rounded-md border border-line px-2 py-1 text-sm font-semibold text-navy-800 outline-none focus:border-navy-600"
              />
            ) : (
              <span className="min-w-0 flex-1 truncate text-sm font-semibold text-navy-800">
                {c.name}
              </span>
            )}
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => {
                  const next = [...categories];
                  next[index] = { ...c, visible: !c.visible };
                  onChange(next);
                }}
                title={c.visible ? "Hide from the app" : "Show in the app"}
              >
                <Badge tone={c.visible ? "success" : "neutral"}>
                  {c.visible ? "Visible" : "Hidden"}
                </Badge>
              </button>
              <Button
                size="sm"
                variant="ghost"
                onClick={() => setEditing(editing === index ? null : index)}
              >
                {editing === index ? "Done" : "Edit"}
              </Button>
              <Button
                size="sm"
                variant="ghost"
                onClick={() =>
                  onChange(categories.filter((_, i) => i !== index))
                }
              >
                Remove
              </Button>
            </div>
          </li>
        ))}
      </ul>

      <div className="mt-3 flex gap-2">
        <input
          value={adding}
          placeholder="New category name"
          onChange={(e) => setAdding(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && add()}
          className="min-w-0 flex-1 rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
        />
        <Button variant="secondary" onClick={add}>
          Add category
        </Button>
      </div>
    </Card>
  );
}

/** Headlines wrap onto two lines; the tab only has room for the first. */
function firstLine(title: string): string {
  return title.split(/\r?\n/)[0].trim();
}

function HeroSlidesCard({
  slides,
  onChange,
}: {
  slides: HeroSlide[];
  onChange: (next: HeroSlide[]) => void;
}) {
  const [open, setOpen] = useState(0);
  // A document saved before the carousel existed arrives with no slides.
  const list = slides.length > 0 ? slides : [{ ...BLANK_SLIDE }];
  const active = Math.min(open, list.length - 1);

  /** Swaps a slide with its neighbour; the app plays them in this order. */
  function move(index: number, by: number) {
    const to = index + by;
    if (to < 0 || to >= list.length) return;
    const next = [...list];
    [next[index], next[to]] = [next[to], next[index]];
    onChange(next);
    setOpen(to);
  }

  return (
    <Card>
      <CardHeader
        title="App home hero"
        subtitle="Slides play as a carousel at the top of the buyer app"
        action={
          <Button
            size="sm"
            variant="secondary"
            onClick={() => {
              onChange([...list, { ...BLANK_SLIDE }]);
              setOpen(list.length);
            }}
          >
            Add slide
          </Button>
        }
      />

      <div className="mb-4 flex flex-wrap gap-1.5">
        {list.map((slide, index) => (
          <button
            key={index}
            onClick={() => setOpen(index)}
            className={cx(
              "rounded-lg px-3 py-1.5 text-xs font-semibold transition-colors",
              index === active
                ? "bg-navy-800 text-white"
                : "bg-canvas text-muted ring-1 ring-line ring-inset hover:bg-navy-50 hover:text-navy-700",
            )}
          >
            {index + 1}. {slide.badge || firstLine(slide.title) || "Untitled"}
          </button>
        ))}
      </div>

      <SlideEditor
        slide={list[active]}
        index={active}
        count={list.length}
        onChange={(slide) => {
          const next = [...list];
          next[active] = slide;
          onChange(next);
        }}
        onMove={(by) => move(active, by)}
        onRemove={() => {
          onChange(list.filter((_, i) => i !== active));
          setOpen(Math.max(active - 1, 0));
        }}
      />
    </Card>
  );
}

function SlideEditor({
  slide,
  index,
  count,
  onChange,
  onMove,
  onRemove,
}: {
  slide: HeroSlide;
  index: number;
  count: number;
  onChange: (next: HeroSlide) => void;
  onMove: (by: number) => void;
  onRemove: () => void;
}) {
  const picker = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);

  async function pick(files: FileList | null) {
    if (!files?.length) return;
    setUploading(true);
    try {
      const result = await api.upload([files[0]]);
      onChange({ ...slide, image: result.files[0].url });
    } catch (error) {
      window.alert((error as Error).message);
    } finally {
      setUploading(false);
      if (picker.current) picker.current.value = "";
    }
  }

  return (
    <>
      <div className="relative mb-4 aspect-[21/9] overflow-hidden rounded-lg bg-navy-800">
        {slide.image && (
          <Image
            src={slide.image}
            alt={`Hero slide ${index + 1}`}
            fill
            sizes="(min-width: 1280px) 50vw, 90vw"
            className="object-cover opacity-60"
          />
        )}
        <div className="absolute inset-0 flex flex-col justify-center gap-2 p-5">
          <span className="w-fit rounded bg-accent-500 px-2 py-1 text-[10px] font-extrabold tracking-wide text-white">
            {slide.badge || "BADGE"}
          </span>
          <p className="text-lg leading-tight font-extrabold whitespace-pre-line text-white">
            {slide.title || "Hero headline"}
          </p>
          <p className="line-clamp-2 text-xs text-white/75">{slide.subtitle}</p>
        </div>
        <div className="absolute right-3 bottom-3 flex gap-1">
          {Array.from({ length: count }, (_, i) => (
            <span
              key={i}
              className={cx(
                "h-1.5 rounded-full transition-all",
                i === index ? "w-5 bg-white" : "w-1.5 bg-white/50",
              )}
            />
          ))}
        </div>
      </div>

      <input
        ref={picker}
        type="file"
        accept="image/*"
        hidden
        onChange={(e) => pick(e.target.files)}
      />
      <div className="mb-4 flex flex-wrap gap-2">
        <Button
          variant="secondary"
          disabled={uploading}
          onClick={() => picker.current?.click()}
        >
          {uploading ? "Uploading…" : "Replace photo"}
        </Button>
        <Button
          variant="ghost"
          onClick={() => onChange({ ...slide, image: "" })}
        >
          Remove photo
        </Button>
        <span className="flex-1" />
        <Button
          variant="ghost"
          disabled={index === 0}
          onClick={() => onMove(-1)}
        >
          ← Move earlier
        </Button>
        <Button
          variant="ghost"
          disabled={index === count - 1}
          onClick={() => onMove(1)}
        >
          Move later →
        </Button>
        <Button variant="ghost" disabled={count < 2} onClick={onRemove}>
          Delete slide
        </Button>
      </div>

      <div className="grid gap-4">
        <TextField
          label="Badge"
          value={slide.badge}
          onChange={(v) => onChange({ ...slide, badge: v })}
        />
        <label className="block">
          <span className="mb-1.5 block text-sm font-semibold text-navy-800">
            Headline
          </span>
          <textarea
            rows={2}
            value={slide.title}
            onChange={(e) => onChange({ ...slide, title: e.target.value })}
            className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
          />
        </label>
        <label className="block">
          <span className="mb-1.5 block text-sm font-semibold text-navy-800">
            Sub-headline
          </span>
          <textarea
            rows={3}
            value={slide.subtitle}
            onChange={(e) => onChange({ ...slide, subtitle: e.target.value })}
            className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
          />
        </label>
        <TextField
          label="Button label"
          value={slide.ctaLabel}
          onChange={(v) => onChange({ ...slide, ctaLabel: v })}
        />
      </div>
    </>
  );
}

/** Help & Support and Terms copy, exactly as the app renders it. */
function SupportCard({
  support,
  onChange,
}: {
  support: Support;
  onChange: (next: Support) => void;
}) {
  function setFaq(index: number, faq: Faq) {
    const faqs = [...support.faqs];
    faqs[index] = faq;
    onChange({ ...support, faqs });
  }

  return (
    <>
      <Card>
        <CardHeader
          title="Contact channels"
          subtitle="Shown on the app's Help & Support screen"
        />
        <div className="grid gap-4 sm:grid-cols-2">
          <TextField
            label="Support phone"
            value={support.phone}
            onChange={(v) => onChange({ ...support, phone: v })}
          />
          <TextField
            label="Support email"
            value={support.email}
            onChange={(v) => onChange({ ...support, email: v })}
          />
          <div className="sm:col-span-2">
            <TextField
              label="Working hours"
              value={support.hours}
              onChange={(v) => onChange({ ...support, hours: v })}
            />
          </div>
        </div>
      </Card>

      <Card>
        <CardHeader
          title="Frequently asked questions"
          subtitle="Buyers and sellers read these before they call"
          action={
            <Button
              size="sm"
              variant="secondary"
              onClick={() =>
                onChange({
                  ...support,
                  faqs: [...support.faqs, { question: "", answer: "" }],
                })
              }
            >
              Add question
            </Button>
          }
        />
        <div className="space-y-4">
          {support.faqs.map((faq, index) => (
            <div key={index} className="rounded-lg border border-line p-3.5">
              <div className="mb-2 flex items-center gap-2">
                <input
                  value={faq.question}
                  placeholder="Question"
                  onChange={(e) =>
                    setFaq(index, { ...faq, question: e.target.value })
                  }
                  className="min-w-0 flex-1 rounded-lg border border-line bg-white px-3 py-2 text-sm font-semibold text-navy-800 outline-none focus:border-navy-600"
                />
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() =>
                    onChange({
                      ...support,
                      faqs: support.faqs.filter((_, i) => i !== index),
                    })
                  }
                >
                  Remove
                </Button>
              </div>
              <textarea
                rows={3}
                value={faq.answer}
                placeholder="Answer"
                onChange={(e) =>
                  setFaq(index, { ...faq, answer: e.target.value })
                }
                className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
              />
            </div>
          ))}
        </div>
      </Card>

      <Card>
        <CardHeader
          title="Terms & conditions"
          subtitle="The full text shown on the app's Terms screen"
        />
        <textarea
          rows={10}
          value={support.terms}
          onChange={(e) => onChange({ ...support, terms: e.target.value })}
          className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm leading-relaxed outline-none focus:border-navy-600"
        />
      </Card>
    </>
  );
}

/** The tick lists and choice chips the seller wizard draws. */
function SellOptionsCard({
  options,
  onChange,
}: {
  options: SellOptions;
  onChange: (next: SellOptions) => void;
}) {
  const lists: Array<[keyof SellOptions, string, string]> = [
    ["requiredPhotos", "Required photos", "Views a seller is asked to attach"],
    ["documentTypes", "Document types", "Paperwork the desk accepts"],
    ["workingStatus", "Working status", "Section 2 choice chips"],
    ["conditions", "Machine condition", "Section 2 choice chips"],
    ["maintenanceStatus", "Maintenance status", "Section 2 choice chips"],
    ["ownerTypes", "Owner type", "Section 3 choice chips"],
  ];

  return (
    <>
      {lists.map(([key, label, hint]) => (
        <ListCard
          key={key}
          label={label}
          hint={hint}
          values={options[key]}
          onChange={(values) => onChange({ ...options, [key]: values })}
        />
      ))}
    </>
  );
}

/** Editable list of short strings — add, rename in place, remove. */
function ListCard({
  label,
  hint,
  values,
  onChange,
}: {
  label: string;
  hint: string;
  values: string[];
  onChange: (next: string[]) => void;
}) {
  const [adding, setAdding] = useState("");

  function add() {
    const value = adding.trim();
    if (!value || values.includes(value)) {
      setAdding("");
      return;
    }
    onChange([...values, value]);
    setAdding("");
  }

  return (
    <Card>
      <CardHeader title={label} subtitle={hint} />
      <div className="grid gap-2 sm:grid-cols-2">
        {values.map((value, index) => (
          <div key={index} className="flex items-center gap-1.5">
            <input
              value={value}
              onChange={(e) => {
                const next = [...values];
                next[index] = e.target.value;
                onChange(next);
              }}
              className="min-w-0 flex-1 rounded-lg border border-line bg-white px-3 py-2 text-sm outline-none focus:border-navy-600"
            />
            <Button
              size="sm"
              variant="ghost"
              disabled={values.length < 2}
              onClick={() => onChange(values.filter((_, i) => i !== index))}
            >
              ✕
            </Button>
          </div>
        ))}
      </div>

      <div className="mt-3 flex gap-2">
        <input
          value={adding}
          placeholder={`Add to ${label.toLowerCase()}`}
          onChange={(e) => setAdding(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && add()}
          className="min-w-0 flex-1 rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
        />
        <Button variant="secondary" onClick={add}>
          Add
        </Button>
      </div>
    </Card>
  );
}

/** Real console accounts, from the admins collection. */
function TeamCard() {
  const record = useApi<{
    team: {
      email: string;
      name: string;
      role: string;
      lastLoginAt: string | null;
    }[];
  }>("/api/admin/team");
  const team = record.data?.team ?? [];

  const [inviting, setInviting] = useState(false);
  const [draft, setDraft] = useState({
    name: "",
    email: "",
    role: "Broker",
    password: "",
  });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function invite() {
    setBusy(true);
    setError(null);
    try {
      await api.post("/api/admin/team", draft);
      setDraft({ name: "", email: "", role: "Broker", password: "" });
      setInviting(false);
      record.reload();
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  async function revoke(email: string) {
    if (!window.confirm(`Remove console access for ${email}?`)) return;
    setBusy(true);
    setError(null);
    try {
      await api.del(`/api/admin/team?email=${encodeURIComponent(email)}`);
      record.reload();
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <Card padded={false}>
      <div className="p-5">
        <CardHeader
          title="Console access"
          subtitle="Who can sign in to this admin panel"
          action={
            <Button size="sm" onClick={() => setInviting(!inviting)}>
              {inviting ? "Cancel" : "Invite member"}
            </Button>
          }
        />

        {error && (
          <p className="mb-3 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-sm font-semibold text-rose-700">
            {error}
          </p>
        )}

        {inviting && (
          <div className="grid gap-3 rounded-lg border border-line p-4 sm:grid-cols-2">
            <TextField
              label="Name"
              value={draft.name}
              onChange={(v) => setDraft({ ...draft, name: v })}
            />
            <TextField
              label="Email"
              value={draft.email}
              onChange={(v) => setDraft({ ...draft, email: v })}
            />
            <label className="block">
              <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                Role
              </span>
              <select
                value={draft.role}
                onChange={(e) => setDraft({ ...draft, role: e.target.value })}
                className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
              >
                {["Super Admin", "Inspector", "Broker", "Accounts"].map((r) => (
                  <option key={r}>{r}</option>
                ))}
              </select>
            </label>
            <label className="block">
              <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                Temporary password
              </span>
              <input
                type="password"
                value={draft.password}
                onChange={(e) =>
                  setDraft({ ...draft, password: e.target.value })
                }
                placeholder="At least 8 characters"
                className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
              />
            </label>
            <div className="sm:col-span-2">
              <Button disabled={busy} onClick={invite}>
                {busy ? "Adding…" : "Add member"}
              </Button>
            </div>
          </div>
        )}
      </div>

      {team.length === 0 ? (
        <EmptyState
          title={record.loading ? "Loading team…" : "No console accounts"}
          message={record.error ?? "Invite someone to give them access."}
        />
      ) : (
        <ul className="divide-y divide-line">
          {team.map((m) => (
            <li
              key={m.email}
              className="flex flex-wrap items-center gap-3 px-5 py-4"
            >
              <span className="grid h-9 w-9 place-items-center rounded-full bg-navy-800 text-xs font-bold text-white">
                {m.name
                  .split(/\s+/)
                  .slice(0, 2)
                  .map((p) => p[0])
                  .join("")}
              </span>
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-bold text-navy-800">
                  {m.name}
                </p>
                <p className="truncate text-xs text-muted">{m.email}</p>
              </div>
              <Badge tone={m.role === "Super Admin" ? "accent" : "navy"}>
                {m.role}
              </Badge>
              <span className="text-xs text-faint">
                {m.lastLoginAt
                  ? `Last login ${relativeDate(m.lastLoginAt)}`
                  : "Never signed in"}
              </span>
              <Button
                size="sm"
                variant="ghost"
                disabled={busy}
                onClick={() => revoke(m.email)}
              >
                Remove
              </Button>
            </li>
          ))}
        </ul>
      )}
    </Card>
  );
}

/** Shows what the percentages come to on a sample order. */
function QuoteExample({ commercials }: { commercials: Commercials }) {
  const base = 5000000;
  const shipping = (base * commercials.shippingRate) / 100;
  const brokerage = (base * commercials.brokerageRate) / 100;
  const gst = ((base + shipping + brokerage) * commercials.gstRate) / 100;
  const money = (n: number) => `₹${Math.round(n).toLocaleString("en-IN")}`;

  return (
    <dl className="mt-4 divide-y divide-line/70 rounded-lg border border-line px-4">
      <div className="flex justify-between py-2 text-sm">
        <dt className="text-muted">Machine at {money(base)}</dt>
        <dd className="font-semibold text-navy-800">{money(base)}</dd>
      </div>
      <div className="flex justify-between py-2 text-sm">
        <dt className="text-muted">Shipping</dt>
        <dd className="font-semibold text-navy-800">{money(shipping)}</dd>
      </div>
      <div className="flex justify-between py-2 text-sm">
        <dt className="text-muted">Brokerage</dt>
        <dd className="font-semibold text-navy-800">{money(brokerage)}</dd>
      </div>
      <div className="flex justify-between py-2 text-sm">
        <dt className="text-muted">GST</dt>
        <dd className="font-semibold text-navy-800">{money(gst)}</dd>
      </div>
      <div className="flex justify-between py-2.5 text-sm">
        <dt className="font-bold text-navy-800">Buyer pays</dt>
        <dd className="font-extrabold text-accent-600">
          {money(base + shipping + brokerage + gst)}
        </dd>
      </div>
    </dl>
  );
}

/* ------------------------------------------------------------- controls -- */

function Toggle({
  label,
  hint,
  on,
  onChange,
}: {
  label: string;
  hint?: string;
  on: boolean;
  onChange: (next: boolean) => void;
}) {
  return (
    <div className="flex items-start justify-between gap-4 border-b border-line py-3.5 last:border-0">
      <div className="min-w-0">
        <p className="text-sm font-semibold text-navy-800">{label}</p>
        {hint && <p className="mt-0.5 text-xs text-muted">{hint}</p>}
      </div>
      <button
        type="button"
        role="switch"
        aria-checked={on}
        aria-label={label}
        onClick={() => onChange(!on)}
        className={cx(
          "relative h-6 w-11 shrink-0 rounded-full transition-colors",
          on ? "bg-accent-500" : "bg-slate-300",
        )}
      >
        <span
          className={cx(
            "absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition-all",
            on ? "left-[22px]" : "left-0.5",
          )}
        />
      </button>
    </div>
  );
}

function NumberField({
  label,
  value,
  onChange,
}: {
  label: string;
  value: number;
  onChange: (next: number) => void;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-sm font-semibold text-navy-800">
        {label}
      </span>
      <input
        value={String(value)}
        inputMode="decimal"
        onChange={(e) => {
          const next = Number(e.target.value.replace(/[^0-9.]/g, ""));
          onChange(Number.isFinite(next) ? next : 0);
        }}
        className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
      />
    </label>
  );
}

function TextField({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (next: string) => void;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-sm font-semibold text-navy-800">
        {label}
      </span>
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
      />
    </label>
  );
}
