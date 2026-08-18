"use client";

import Link from "next/link";
import { useMemo } from "react";

import { useApi } from "@/lib/api";
import type {
  AdminUser,
  Inquiry,
  Order,
  Product,
  SellRequest,
} from "@/lib/types";
import { relativeDate, rupees, rupeesShort } from "@/lib/format";
import {
  Avatar,
  Badge,
  Button,
  Card,
  CardHeader,
  PageHeader,
  Table,
  Td,
  Th,
  cx,
  statusTone,
} from "@/components/ui";

export default function DashboardPage() {
  // The console reads straight from the database, so the desk always sees the
  // same numbers the mobile app does.
  const catalogue = useApi<{ products: Product[] }>("/api/admin/products");
  const submissions = useApi<{ requests: SellRequest[] }>(
    "/api/admin/requests",
  );
  const rfqs = useApi<{ inquiries: Inquiry[] }>("/api/admin/inquiries");
  const ledger = useApi<{ orders: Order[] }>("/api/admin/orders");
  const accounts = useApi<{ users: AdminUser[] }>("/api/admin/users");
  const summary = useApi<{
    activity: { kind: string; title: string; detail: string; at: string }[];
    revenue: { label: string; value: number }[];
    deltas: {
      listingsThisWeek: number;
      approvalsOverdue: number;
      inquiriesToday: number;
      gmvThisMonth: number;
      gmvLastMonth: number;
    };
  }>("/api/admin/summary");
  const config = useApi<{ categories: string[] }>("/api/settings");

  const PRODUCTS = useMemo(
    () => catalogue.data?.products ?? [],
    [catalogue.data],
  );
  const SELL_REQUESTS = useMemo(
    () => submissions.data?.requests ?? [],
    [submissions.data],
  );
  const INQUIRIES = useMemo(() => rfqs.data?.inquiries ?? [], [rfqs.data]);
  const ORDERS = useMemo(() => ledger.data?.orders ?? [], [ledger.data]);
  const USERS = useMemo(() => accounts.data?.users ?? [], [accounts.data]);
  const ACTIVITY = useMemo(() => summary.data?.activity ?? [], [summary.data]);
  const REVENUE_TREND = useMemo(
    () => summary.data?.revenue ?? [],
    [summary.data],
  );
  const CATEGORIES = useMemo(
    () => config.data?.categories ?? [],
    [config.data],
  );

  const liveListings = PRODUCTS.filter((p) => p.status === "Live").length;
  const pendingRequests = SELL_REQUESTS.filter(
    (r) => r.status === "Awaiting Review",
  ).length;
  const openInquiries = INQUIRIES.filter(
    (i) => i.status !== "Closed" && i.status !== "Lost",
  ).length;
  const inventoryValue = PRODUCTS.filter((p) => p.status === "Live").reduce(
    (sum, p) => sum + p.price,
    0,
  );

  // Every figure below is counted off the database — nothing is illustrative.
  const deltas = summary.data?.deltas;
  const gmvThisMonth = deltas?.gmvThisMonth ?? 0;
  const gmvLastMonth = deltas?.gmvLastMonth ?? 0;
  const gmvChange =
    gmvLastMonth > 0
      ? Math.round(((gmvThisMonth - gmvLastMonth) / gmvLastMonth) * 100)
      : null;
  const inFlight = ORDERS.filter((o) => o.stage !== "Delivered").length;

  const stats = [
    {
      label: "Live Listings",
      value: `${liveListings}`,
      delta:
        deltas === undefined
          ? "—"
          : deltas.listingsThisWeek > 0
            ? `+${deltas.listingsThisWeek} this week`
            : "none this week",
      up: (deltas?.listingsThisWeek ?? 0) > 0,
      hint: `${PRODUCTS.length} total in catalogue`,
    },
    {
      label: "Pending Approvals",
      value: `${pendingRequests}`,
      delta:
        deltas === undefined
          ? "—"
          : deltas.approvalsOverdue > 0
            ? `${deltas.approvalsOverdue} over 48h`
            : "all within 48h",
      up: (deltas?.approvalsOverdue ?? 0) === 0,
      hint: "Sell requests awaiting review",
    },
    {
      label: "Open Inquiries",
      value: `${openInquiries}`,
      delta:
        deltas === undefined
          ? "—"
          : deltas.inquiriesToday > 0
            ? `+${deltas.inquiriesToday} today`
            : "none today",
      up: (deltas?.inquiriesToday ?? 0) > 0,
      hint: `${INQUIRIES.length} raised all-time`,
    },
    {
      label: "Order Value (MTD)",
      value: rupeesShort(gmvThisMonth),
      delta:
        gmvChange === null
          ? "no orders last month"
          : `${gmvChange >= 0 ? "+" : ""}${gmvChange}% vs last month`,
      up: (gmvChange ?? 0) >= 0,
      hint: `${inFlight} order${inFlight === 1 ? "" : "s"} in progress`,
    },
  ];

  const peak = Math.max(1, ...REVENUE_TREND.map((m) => m.value));
  const recentOrders = ORDERS.slice(0, 4);
  const queue = SELL_REQUESTS.filter(
    (r) => r.status === "Awaiting Review",
  ).slice(0, 3);

  return (
    <>
      <PageHeader
        title="Dashboard"
        subtitle="Marketplace health, approval queue and live commercial activity."
        actions={
          <>
            <Button variant="secondary">Export report</Button>
            <Link href="/products/new">
              <Button>Add product</Button>
            </Link>
          </>
        }
      />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {stats.map((s) => (
          <Card key={s.label}>
            <p className="text-xs font-bold tracking-wide text-muted uppercase">
              {s.label}
            </p>
            <div className="mt-2 flex items-end gap-2">
              <p className="text-3xl font-extrabold text-navy-800">{s.value}</p>
              <span
                className={cx(
                  "mb-1 text-xs font-bold",
                  s.up ? "text-emerald-600" : "text-accent-600",
                )}
              >
                {s.delta}
              </span>
            </div>
            <p className="mt-1 text-xs text-faint">{s.hint}</p>
          </Card>
        ))}
      </div>

      <div className="mt-4 grid gap-4 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <CardHeader
            title="Gross merchandise value"
            subtitle="Rolling twelve months, all completed and in-flight orders"
            action={
              <span className="text-right">
                <span className="block text-lg font-extrabold text-navy-800">
                  {rupeesShort(REVENUE_TREND.reduce((s, m) => s + m.value, 0))}
                </span>
                <span className="text-xs text-muted">Total GMV</span>
              </span>
            }
          />
          <div className="flex h-52 items-end gap-2">
            {REVENUE_TREND.map((m, i) => {
              const height = Math.round((m.value / peak) * 100);
              const latest = i === REVENUE_TREND.length - 1;
              return (
                <div
                  key={`${m.label}-${i}`}
                  className="group flex flex-1 flex-col items-center gap-2"
                >
                  <div className="relative flex w-full flex-1 items-end">
                    <div
                      style={{ height: `${height}%` }}
                      className={cx(
                        "w-full rounded-t-md transition-colors",
                        latest
                          ? "bg-accent-500"
                          : "bg-navy-100 group-hover:bg-navy-600",
                      )}
                    />
                    <span className="pointer-events-none absolute -top-7 left-1/2 -translate-x-1/2 rounded-md bg-navy-900 px-2 py-1 text-[10px] font-semibold whitespace-nowrap text-white opacity-0 transition-opacity group-hover:opacity-100">
                      {rupeesShort(m.value)}
                    </span>
                  </div>
                  <span className="text-[10px] font-medium text-faint">
                    {m.label}
                  </span>
                </div>
              );
            })}
          </div>
        </Card>

        <Card>
          <CardHeader
            title="Catalogue mix"
            subtitle={`${rupeesShort(inventoryValue)} of live inventory`}
          />
          <ul className="space-y-3.5">
            {CATEGORIES.map((category) => {
              const items = PRODUCTS.filter((p) => p.category === category);
              const share =
                PRODUCTS.length === 0
                  ? 0
                  : Math.round((items.length / PRODUCTS.length) * 100);
              return (
                <li key={category}>
                  <div className="mb-1.5 flex items-baseline justify-between text-sm">
                    <span className="font-semibold text-navy-800">
                      {category}
                    </span>
                    <span className="text-xs text-muted">
                      {items.length} · {share}%
                    </span>
                  </div>
                  <div className="h-2 overflow-hidden rounded-full bg-navy-50">
                    <div
                      className="h-full rounded-full bg-navy-600"
                      style={{ width: `${share}%` }}
                    />
                  </div>
                </li>
              );
            })}
          </ul>
        </Card>
      </div>

      <div className="mt-4 grid gap-4 xl:grid-cols-3">
        <Card className="xl:col-span-2" padded={false}>
          <div className="p-5">
            <CardHeader
              title="Recent orders"
              subtitle="Latest procurement activity across the marketplace"
              action={
                <Link
                  href="/orders"
                  className="text-sm font-bold text-accent-600 hover:underline"
                >
                  View all
                </Link>
              }
            />
          </div>
          <Table>
            <thead>
              <tr>
                <Th>Order</Th>
                <Th>Machine</Th>
                <Th>Buyer</Th>
                <Th>Stage</Th>
                <Th className="text-right">Amount</Th>
              </tr>
            </thead>
            <tbody>
              {recentOrders.map((o) => (
                <tr key={o.id} className="hover:bg-canvas/60">
                  <Td className="font-bold whitespace-nowrap text-navy-800">
                    {o.id}
                  </Td>
                  <Td className="whitespace-nowrap">{o.machine}</Td>
                  <Td className="whitespace-nowrap text-muted">{o.buyer}</Td>
                  <Td>
                    <Badge tone={statusTone(o.stage)}>{o.stage}</Badge>
                  </Td>
                  <Td className="text-right font-bold whitespace-nowrap text-navy-800">
                    {rupees(o.amount)}
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        </Card>

        <Card>
          <CardHeader title="Activity" subtitle="Last 7 days" />
          <ol className="space-y-4">
            {ACTIVITY.length === 0 && (
              <li className="text-sm text-muted">
                {summary.loading
                  ? "Loading recent activity…"
                  : "Nothing has happened on the marketplace yet."}
              </li>
            )}
            {ACTIVITY.map((a, index) => (
              <li key={`${a.title}-${index}`} className="flex gap-3">
                <span
                  className={cx(
                    "mt-1.5 h-2 w-2 shrink-0 rounded-full",
                    a.kind === "order" && "bg-emerald-500",
                    a.kind === "listing" && "bg-accent-500",
                    a.kind === "inquiry" && "bg-navy-600",
                    a.kind === "user" && "bg-sky-500",
                  )}
                />
                <div className="min-w-0">
                  <p className="text-sm leading-snug font-semibold text-ink">
                    {a.title}
                  </p>
                  <p className="truncate text-xs text-muted">{a.detail}</p>
                  <p className="mt-0.5 text-xs text-faint">
                    {relativeDate(a.at)}
                  </p>
                </div>
              </li>
            ))}
          </ol>
        </Card>
      </div>

      <div className="mt-4 grid gap-4 xl:grid-cols-2">
        <Card>
          <CardHeader
            title="Approval queue"
            subtitle={`${pendingRequests} sell requests awaiting review`}
            action={
              <Link
                href="/requests"
                className="text-sm font-bold text-accent-600 hover:underline"
              >
                Open queue
              </Link>
            }
          />
          <ul className="space-y-3">
            {queue.map((r) => (
              <li
                key={r.id}
                className="flex items-center gap-3 rounded-lg border border-line p-3"
              >
                <Avatar name={r.seller} tone="accent" />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-bold text-navy-800">
                    {r.machine}
                  </p>
                  <p className="truncate text-xs text-muted">
                    {r.seller} · {r.city}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-bold text-navy-800">
                    {rupeesShort(r.askingPrice)}
                  </p>
                  <p className="text-[11px] text-faint">
                    {relativeDate(r.submittedOn)}
                  </p>
                </div>
              </li>
            ))}
          </ul>
        </Card>

        <Card>
          <CardHeader
            title="Top sellers"
            subtitle="Ranked by live listings and closed orders"
          />
          <ul className="space-y-3">
            {[...USERS]
              .filter((u) => u.role === "Seller" || u.role === "Both")
              .sort((a, b) => b.listings + b.orders - (a.listings + a.orders))
              .slice(0, 5)
              .map((u) => (
                <li key={u.id} className="flex items-center gap-3">
                  <Avatar name={u.name} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-semibold text-navy-800">
                      {u.company}
                    </p>
                    <p className="truncate text-xs text-muted">{u.city}</p>
                  </div>
                  <div className="flex gap-1.5">
                    <Badge tone="navy">{u.listings} listings</Badge>
                    <Badge tone="neutral">{u.orders} orders</Badge>
                  </div>
                </li>
              ))}
          </ul>
        </Card>
      </div>
    </>
  );
}
