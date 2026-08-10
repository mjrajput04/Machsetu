"use client";

import { useMemo, useState } from "react";
import { SELL_REQUESTS, type RequestStatus, type SellRequest } from "@/lib/data";
import { relativeDate, rupees, shortDate } from "@/lib/format";
import {
  Avatar,
  Badge,
  Button,
  Card,
  CardHeader,
  EmptyState,
  PageHeader,
  cx,
  statusTone,
} from "@/components/ui";

const TABS: Array<RequestStatus | "All"> = [
  "All",
  "Awaiting Review",
  "Inspection Scheduled",
  "Approved",
  "Rejected",
];

export default function RequestsPage() {
  const [tab, setTab] = useState<RequestStatus | "All">("Awaiting Review");
  const [activeId, setActiveId] = useState<string>(SELL_REQUESTS[0].id);

  const rows = useMemo(
    () =>
      tab === "All"
        ? SELL_REQUESTS
        : SELL_REQUESTS.filter((r) => r.status === tab),
    [tab],
  );

  // Keep the detail pane on a row that is actually in the filtered list.
  const active: SellRequest | undefined =
    rows.find((r) => r.id === activeId) ?? rows[0];

  return (
    <>
      <PageHeader
        title="Sell Requests"
        subtitle="Machines submitted by sellers, waiting on verification before they go live."
        actions={<Button variant="secondary">Assign inspector</Button>}
      />

      <div className="mb-4 flex flex-wrap gap-1.5">
        {TABS.map((t) => {
          const count =
            t === "All"
              ? SELL_REQUESTS.length
              : SELL_REQUESTS.filter((r) => r.status === t).length;
          return (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={cx(
                "flex items-center gap-2 rounded-lg px-3.5 py-2 text-sm font-semibold transition-colors",
                tab === t
                  ? "bg-navy-800 text-white"
                  : "bg-white text-muted ring-1 ring-line ring-inset hover:bg-navy-50 hover:text-navy-700",
              )}
            >
              {t}
              <span
                className={cx(
                  "rounded-full px-1.5 py-0.5 text-[10px] font-bold",
                  tab === t ? "bg-white/20" : "bg-canvas text-muted",
                )}
              >
                {count}
              </span>
            </button>
          );
        })}
      </div>

      {rows.length === 0 ? (
        <Card>
          <EmptyState
            title="Nothing in this state"
            message="Requests will appear here as sellers submit machines."
          />
        </Card>
      ) : (
        <div className="grid gap-4 xl:grid-cols-5">
          <div className="space-y-3 xl:col-span-2">
            {rows.map((r) => (
              <button
                key={r.id}
                onClick={() => setActiveId(r.id)}
                className={cx(
                  "w-full rounded-xl border bg-white p-4 text-left transition-colors",
                  active?.id === r.id
                    ? "border-accent-500 ring-1 ring-accent-500"
                    : "border-line hover:border-navy-600",
                )}
              >
                <div className="flex items-start gap-3">
                  <Avatar name={r.seller} tone="accent" />
                  <div className="min-w-0 flex-1">
                    <p className="truncate font-bold text-navy-800">
                      {r.machine}
                    </p>
                    <p className="truncate text-xs text-muted">
                      {r.brand} · {r.year}
                    </p>
                  </div>
                  <Badge tone={statusTone(r.status)}>{r.status}</Badge>
                </div>
                <div className="mt-3 flex items-center justify-between text-xs">
                  <span className="text-muted">
                    {r.seller} · {r.city}
                  </span>
                  <span className="font-bold text-navy-800">
                    {rupees(r.askingPrice)}
                  </span>
                </div>
                <p className="mt-1.5 text-[11px] text-faint">
                  {r.id} · submitted {relativeDate(r.submittedOn)}
                </p>
              </button>
            ))}
          </div>

          {active && (
            <div className="space-y-4 xl:col-span-3">
              <Card>
                <div className="flex flex-wrap items-start justify-between gap-4">
                  <div>
                    <Badge tone={statusTone(active.status)} dot>
                      {active.status}
                    </Badge>
                    <h2 className="mt-2.5 text-xl font-extrabold text-navy-800">
                      {active.machine}
                    </h2>
                    <p className="mt-1 text-sm text-muted">
                      {active.brand} · {active.category} · {active.year}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-2xl font-extrabold text-accent-600">
                      {rupees(active.askingPrice)}
                    </p>
                    <p className="text-xs text-muted">Asking price</p>
                  </div>
                </div>

                <dl className="mt-5 grid gap-4 border-t border-line pt-5 sm:grid-cols-2 lg:grid-cols-4">
                  <Fact label="Request ID" value={active.id} />
                  <Fact label="Seller" value={active.seller} />
                  <Fact label="Location" value={active.city} />
                  <Fact
                    label="Submitted"
                    value={shortDate(active.submittedOn)}
                  />
                </dl>

                <div className="mt-5 grid gap-3 sm:grid-cols-2">
                  <Attachment
                    label="Photos attached"
                    count={active.photos}
                    total={15}
                  />
                  <Attachment
                    label="Documents attached"
                    count={active.documents}
                    total={10}
                  />
                </div>

                <div className="mt-5 rounded-lg border-l-4 border-accent-500 bg-canvas p-4">
                  <p className="text-xs font-bold tracking-wide text-muted uppercase">
                    Seller note
                  </p>
                  <p className="mt-1.5 text-sm leading-relaxed text-ink">
                    {active.note}
                  </p>
                </div>

                <div className="mt-5 flex flex-wrap gap-2 border-t border-line pt-5">
                  <Button>Approve &amp; publish</Button>
                  <Button variant="secondary">Schedule inspection</Button>
                  <Button variant="secondary">Request more info</Button>
                  <Button variant="danger">Reject</Button>
                </div>
              </Card>

              <Card>
                <CardHeader
                  title="Verification checklist"
                  subtitle="All four must clear before a listing goes live"
                />
                <ul className="space-y-2.5">
                  {[
                    { label: "Ownership proof matches GSTIN", done: true },
                    { label: "Serial plate photo legible", done: active.photos >= 6 },
                    {
                      label: "Invoice or purchase record attached",
                      done: active.documents >= 3,
                    },
                    {
                      label: "Physical inspection completed",
                      done: active.status === "Approved",
                    },
                  ].map((c) => (
                    <li
                      key={c.label}
                      className="flex items-center gap-3 rounded-lg border border-line px-3.5 py-3"
                    >
                      <span
                        className={cx(
                          "grid h-5 w-5 shrink-0 place-items-center rounded-full text-[11px] font-bold text-white",
                          c.done ? "bg-emerald-500" : "bg-slate-300",
                        )}
                      >
                        {c.done ? "✓" : "!"}
                      </span>
                      <span
                        className={cx(
                          "text-sm",
                          c.done
                            ? "text-ink"
                            : "font-medium text-muted",
                        )}
                      >
                        {c.label}
                      </span>
                    </li>
                  ))}
                </ul>
              </Card>
            </div>
          )}
        </div>
      )}
    </>
  );
}

function Fact({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <dt className="text-xs font-bold tracking-wide text-muted uppercase">
        {label}
      </dt>
      <dd className="mt-1 text-sm font-semibold text-navy-800">{value}</dd>
    </div>
  );
}

function Attachment({
  label,
  count,
  total,
}: {
  label: string;
  count: number;
  total: number;
}) {
  const pct = Math.min(100, Math.round((count / total) * 100));
  return (
    <div className="rounded-lg border border-line p-3.5">
      <div className="flex items-baseline justify-between">
        <p className="text-sm font-semibold text-navy-800">{label}</p>
        <p className="text-sm font-bold text-navy-800">
          {count}
          <span className="text-xs font-medium text-faint">/{total}</span>
        </p>
      </div>
      <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-navy-50">
        <div
          className={cx(
            "h-full rounded-full",
            pct >= 60 ? "bg-emerald-500" : "bg-accent-500",
          )}
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
}
