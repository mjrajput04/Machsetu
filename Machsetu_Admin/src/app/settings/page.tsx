"use client";

import { useState } from "react";
import { CATEGORIES } from "@/lib/data";
import {
  Badge,
  Button,
  Card,
  CardHeader,
  PageHeader,
  cx,
} from "@/components/ui";

const TABS = [
  "Marketplace",
  "Commercials",
  "Team & Roles",
  "Notifications",
] as const;

type Tab = (typeof TABS)[number];

export default function SettingsPage() {
  const [tab, setTab] = useState<Tab>("Marketplace");

  return (
    <>
      <PageHeader
        title="Settings"
        subtitle="Marketplace rules, commercial defaults and console access."
        actions={
          <>
            <Button variant="secondary">Discard</Button>
            <Button>Save changes</Button>
          </>
        }
      />

      <div className="mb-4 flex flex-wrap gap-1.5">
        {TABS.map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={cx(
              "rounded-lg px-3.5 py-2 text-sm font-semibold transition-colors",
              tab === t
                ? "bg-navy-800 text-white"
                : "bg-white text-muted ring-1 ring-line ring-inset hover:bg-navy-50 hover:text-navy-700",
            )}
          >
            {t}
          </button>
        ))}
      </div>

      {tab === "Marketplace" && (
        <div className="grid gap-4 xl:grid-cols-2">
          <Card>
            <CardHeader
              title="Categories"
              subtitle="Shown as filter chips in the buyer app"
            />
            <ul className="space-y-2">
              {CATEGORIES.map((c) => (
                <li
                  key={c}
                  className="flex items-center justify-between rounded-lg border border-line px-3.5 py-3"
                >
                  <span className="text-sm font-semibold text-navy-800">
                    {c}
                  </span>
                  <div className="flex items-center gap-2">
                    <Badge tone="success">Visible</Badge>
                    <Button size="sm" variant="ghost">
                      Edit
                    </Button>
                  </div>
                </li>
              ))}
            </ul>
            <Button variant="secondary" className="mt-3 w-full">
              Add category
            </Button>
          </Card>

          <Card>
            <CardHeader
              title="Listing rules"
              subtitle="Applied to every seller submission"
            />
            <div className="space-y-1">
              <Toggle
                label="Require inspection before publishing"
                hint="Listings stay in review until an inspector signs off"
                defaultOn
              />
              <Toggle
                label="Require ownership proof"
                hint="Block approval when the document is missing"
                defaultOn
              />
              <Toggle
                label="Auto-publish trusted sellers"
                hint="Sellers with 5+ completed sales skip manual review"
              />
              <Toggle
                label="Allow price on request"
                hint="Sellers may omit an asking price"
                defaultOn
              />
            </div>
            <div className="mt-4 grid gap-4 sm:grid-cols-2">
              <NumberField label="Minimum photos" value="6" />
              <NumberField label="Listing expiry (days)" value="90" />
            </div>
          </Card>
        </div>
      )}

      {tab === "Commercials" && (
        <div className="grid gap-4 xl:grid-cols-2">
          <Card>
            <CardHeader
              title="Fees and taxes"
              subtitle="Used to compute buyer quotes and the checkout summary"
            />
            <div className="grid gap-4 sm:grid-cols-2">
              <NumberField label="GST rate (%)" value="18" />
              <NumberField label="Brokerage fee (₹)" value="1120" />
              <NumberField label="Estimated shipping (₹)" value="4250" />
              <NumberField label="Platform commission (%)" value="2.5" />
            </div>
            <div className="mt-4 rounded-lg border-l-4 border-accent-500 bg-canvas p-4 text-sm text-muted">
              GST applies to goods plus shipping and brokerage, matching the
              buyer app&apos;s cart and checkout totals.
            </div>
          </Card>

          <Card>
            <CardHeader
              title="Escrow"
              subtitle="Funds release policy for completed orders"
            />
            <div className="space-y-1">
              <Toggle
                label="Hold funds until buyer sign-off"
                hint="Release only after the inspection window closes"
                defaultOn
              />
              <Toggle
                label="Auto-release after inspection window"
                hint="Release automatically if the buyer does not respond"
                defaultOn
              />
            </div>
            <div className="mt-4 grid gap-4 sm:grid-cols-2">
              <NumberField label="Inspection window (days)" value="7" />
              <NumberField label="Release delay (hours)" value="48" />
            </div>
          </Card>
        </div>
      )}

      {tab === "Team & Roles" && (
        <Card padded={false}>
          <div className="p-5">
            <CardHeader
              title="Console access"
              subtitle="Who can sign in to this admin panel"
              action={<Button size="sm">Invite member</Button>}
            />
          </div>
          <ul className="divide-y divide-line">
            {[
              { name: "Admin Desk", email: "ops@machsetu.in", role: "Super Admin" },
              { name: "R. Deshmukh", email: "inspection@machsetu.in", role: "Inspector" },
              { name: "Kavita Desai", email: "kavita@desaibrokers.in", role: "Broker" },
              { name: "Finance Team", email: "finance@machsetu.in", role: "Accounts" },
            ].map((m) => (
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
                <Button size="sm" variant="ghost">
                  Manage
                </Button>
              </li>
            ))}
          </ul>
        </Card>
      )}

      {tab === "Notifications" && (
        <Card className="max-w-2xl">
          <CardHeader
            title="Alerts"
            subtitle="What the operations desk gets pinged about"
          />
          <div className="space-y-1">
            <Toggle label="New sell request submitted" defaultOn />
            <Toggle label="Inquiry with no broker for 24h" defaultOn />
            <Toggle label="Inspection report uploaded" defaultOn />
            <Toggle label="Order stuck in a stage for 7 days" defaultOn />
            <Toggle label="Weekly marketplace digest" />
            <Toggle label="Seller KYC expiring" />
          </div>
        </Card>
      )}
    </>
  );
}

function Toggle({
  label,
  hint,
  defaultOn = false,
}: {
  label: string;
  hint?: string;
  defaultOn?: boolean;
}) {
  const [on, setOn] = useState(defaultOn);
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
        onClick={() => setOn(!on)}
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

function NumberField({ label, value }: { label: string; value: string }) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-sm font-semibold text-navy-800">
        {label}
      </span>
      <input
        defaultValue={value}
        inputMode="decimal"
        className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
      />
    </label>
  );
}
