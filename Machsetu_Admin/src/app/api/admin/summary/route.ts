import { db, ensureIndexes } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

const MONTHS = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

interface Activity {
  kind: "order" | "listing" | "inquiry" | "user";
  title: string;
  detail: string;
  at: string;
}

/** Newest first, whichever collection it came from. */
function byRecency(a: Activity, b: Activity) {
  return b.at.localeCompare(a.at);
}

/**
 * Dashboard-only figures that cannot be worked out from the list endpoints:
 * the activity feed and the twelve-month revenue trend.
 */
export async function GET(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "admin") return fail("Not authorised", 401);

  const database = await db();

  const [orders, requests, rfqs, accounts] = await Promise.all([
    database
      .collection("orders")
      .find({}, { projection: { _id: 0 } })
      .sort({ createdAt: -1, placedOn: -1 })
      .limit(40)
      .toArray(),
    database
      .collection("sellRequests")
      .find({}, { projection: { _id: 0 } })
      .sort({ createdAt: -1, submittedOn: -1 })
      .limit(10)
      .toArray(),
    database
      .collection("inquiries")
      .find({}, { projection: { _id: 0 } })
      .sort({ createdAt: -1, raisedOn: -1 })
      .limit(10)
      .toArray(),
    database
      .collection("users")
      .find({}, { projection: { _id: 0, passwordHash: 0 } })
      .sort({ createdAt: -1 })
      .limit(10)
      .toArray(),
  ]);

  const stamp = (value: unknown, fallback: unknown) => {
    if (value instanceof Date) return value.toISOString().slice(0, 10);
    const text = String(value ?? "");
    if (text) return text.slice(0, 10);
    return fallback instanceof Date
      ? fallback.toISOString().slice(0, 10)
      : String(fallback ?? "").slice(0, 10);
  };

  const activity: Activity[] = [
    ...orders.slice(0, 10).map((o) => ({
      kind: "order" as const,
      title: `Order ${o.id} — ${o.stage}`,
      detail: `${o.machine} · ${o.buyer}`,
      at: stamp(o.placedOn, o.createdAt),
    })),
    ...requests.map((r) => ({
      kind: "listing" as const,
      title: `Submission ${r.id} — ${r.status}`,
      detail: `${r.machine} · ${r.seller}`,
      at: stamp(r.submittedOn, r.createdAt),
    })),
    ...rfqs.map((i) => ({
      kind: "inquiry" as const,
      title: `Inquiry ${i.id} — ${i.status}`,
      detail: `${i.machine} · ${i.buyer}`,
      at: stamp(i.lastActivity ?? i.raisedOn, i.createdAt),
    })),
    ...accounts.map((u) => ({
      kind: "user" as const,
      title: `${u.name} registered`,
      detail: `${u.company || u.email} · ${u.role}`,
      at: stamp(u.createdAt, u.createdAt),
    })),
  ]
    .filter((a) => a.at)
    .sort(byRecency)
    .slice(0, 12);

  // Twelve months back from today, so the chart always ends on this month.
  const now = new Date();
  const buckets = new Map<string, number>();
  for (let i = 11; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    buckets.set(`${d.getFullYear()}-${d.getMonth()}`, 0);
  }

  const ledger = await database
    .collection("orders")
    .find({}, { projection: { amount: 1, placedOn: 1, createdAt: 1, _id: 0 } })
    .toArray();

  for (const order of ledger) {
    const raw = String(order.placedOn ?? "");
    const when = raw ? new Date(raw) : (order.createdAt as Date | undefined);
    if (!when || Number.isNaN(when.getTime())) continue;

    const key = `${when.getFullYear()}-${when.getMonth()}`;
    if (buckets.has(key)) {
      buckets.set(key, (buckets.get(key) ?? 0) + Number(order.amount ?? 0));
    }
  }

  const revenue = [...buckets.entries()].map(([key, value]) => {
    const [, month] = key.split("-").map(Number);
    return { label: MONTHS[month], value };
  });

  // ---- the figures under each headline number -----------------------------

  const day = 24 * 60 * 60 * 1000;
  const weekAgo = new Date(now.getTime() - 7 * day);
  const twoDaysAgo = new Date(now.getTime() - 2 * day);
  const today = now.toISOString().slice(0, 10);
  const thisMonth = `${now.getFullYear()}-${now.getMonth()}`;
  const lastMonthDate = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const lastMonth = `${lastMonthDate.getFullYear()}-${lastMonthDate.getMonth()}`;

  /** When a row was created, however that row records it. */
  const when = (value: unknown, fallback: unknown): Date | null => {
    if (value instanceof Date) return value;
    const parsed = new Date(String(value ?? ""));
    if (!Number.isNaN(parsed.getTime())) return parsed;
    return fallback instanceof Date ? fallback : null;
  };

  const [listingsThisWeek, approvalsOverdue, inquiriesToday] =
    await Promise.all([
      database.collection("products").countDocuments({
        status: "Live",
        createdAt: { $gte: weekAgo },
      }),
      database
        .collection("sellRequests")
        .find({ status: "Awaiting Review" }, { projection: { submittedOn: 1, createdAt: 1 } })
        .toArray()
        .then(
          (rows) =>
            rows.filter((r) => {
              const at = when(r.submittedOn, r.createdAt);
              return at !== null && at < twoDaysAgo;
            }).length,
        ),
      database.collection("inquiries").countDocuments({ raisedOn: today }),
    ]);

  let gmvThisMonth = 0;
  let gmvLastMonth = 0;
  for (const order of ledger) {
    const at = when(order.placedOn, order.createdAt);
    if (!at) continue;
    const key = `${at.getFullYear()}-${at.getMonth()}`;
    if (key === thisMonth) gmvThisMonth += Number(order.amount ?? 0);
    if (key === lastMonth) gmvLastMonth += Number(order.amount ?? 0);
  }

  return ok({
    activity,
    revenue,
    deltas: {
      listingsThisWeek,
      approvalsOverdue,
      inquiriesToday,
      gmvThisMonth,
      gmvLastMonth,
    },
  });
}
