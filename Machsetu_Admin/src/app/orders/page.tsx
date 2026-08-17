"use client";

import Image from "next/image";
import Link from "next/link";
import { useMemo, useState } from "react";
import { api, useApi, usePolling } from "@/lib/api";
import type { Order, OrderStage } from "@/lib/types";
import { rupees, rupeesShort, shortDate } from "@/lib/format";
import {
  Badge,
  Button,
  Card,
  CardHeader,
  EmptyState,
  PageHeader,
  Table,
  Td,
  Th,
  cx,
  statusTone,
} from "@/components/ui";

/** Must match the app's tracking timeline, stop for stop. */
const STAGES: OrderStage[] = [
  "Inquiry Received",
  "Under Review",
  "Broker Contacting You",
  "Price Confirmed",
  "Machine Reserved",
  "Order Confirmed",
  "Delivery Scheduled",
  "Delivered",
];

export default function OrdersPage() {
  const feed = useApi<{ orders: Order[] }>("/api/admin/orders");
  const all = useMemo(() => feed.data?.orders ?? [], [feed.data]);
  const [busy, setBusy] = useState("");

  // An order placed in the app shows up here on its own.
  usePolling(feed.reload);

  /// Moving an order along also notifies the buyer in the app.
  async function setStage(id: string, stage: string) {
    setBusy(id);
    try {
      await api.put(`/api/admin/orders/${id}`, { stage });
      feed.reload();
    } catch (error) {
      window.alert((error as Error).message);
    } finally {
      setBusy("");
    }
  }

  const total = all.reduce((sum, o) => sum + o.amount, 0);
  const delivered = all.filter((o) => o.stage === "Delivered");
  const inFlight = all.length - delivered.length;

  return (
    <>
      <PageHeader
        title="Orders"
        subtitle="Confirmed procurements moving through escrow, logistics and handover."
        actions={<Button variant="secondary">Export ledger</Button>}
      />

      <div className="mb-4 grid gap-4 sm:grid-cols-3">
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Total order value
          </p>
          <p className="mt-2 text-3xl font-extrabold text-navy-800">
            {rupeesShort(total)}
          </p>
          <p className="mt-1 text-xs text-faint">{all.length} orders</p>
        </Card>
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            In flight
          </p>
          <p className="mt-2 text-3xl font-extrabold text-accent-600">
            {inFlight}
          </p>
          <p className="mt-1 text-xs text-faint">Not yet delivered</p>
        </Card>
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Delivered
          </p>
          <p className="mt-2 text-3xl font-extrabold text-emerald-600">
            {delivered.length}
          </p>
          <p className="mt-1 text-xs text-faint">
            {rupeesShort(delivered.reduce((s, o) => s + o.amount, 0))} settled
          </p>
        </Card>
      </div>

      <Card className="mb-4">
        <CardHeader
          title="Pipeline by stage"
          subtitle="Where every open order currently sits"
        />
        <div className="grid gap-3 sm:grid-cols-3 xl:grid-cols-6">
          {STAGES.map((stage) => {
            const items = all.filter((o) => o.stage === stage);
            return (
              <div
                key={stage}
                className={cx(
                  "rounded-lg border p-3.5",
                  items.length > 0
                    ? "border-navy-100 bg-navy-50/50"
                    : "border-line bg-white",
                )}
              >
                <p className="text-2xl font-extrabold text-navy-800">
                  {items.length}
                </p>
                <p className="mt-1 text-xs leading-snug font-semibold text-muted">
                  {stage}
                </p>
              </div>
            );
          })}
        </div>
      </Card>

      <Card padded={false}>
        <div className="p-5">
          <CardHeader
            title="All orders"
            subtitle="Newest first, across every buyer and seller"
          />
        </div>
        {feed.loading || feed.error ? (
          <EmptyState
            title={feed.loading ? "Loading orders…" : "Could not load orders"}
            message={
              feed.error ?? "Fetching the order ledger from the database."
            }
          />
        ) : (
          <Table>
            <thead>
              <tr>
                <Th>Order</Th>
                <Th>Machine</Th>
                <Th>Buyer</Th>
                <Th>Seller</Th>
                <Th>Stage</Th>
                <Th>Destination</Th>
                <Th className="text-right">Amount</Th>
                <Th className="text-right">Placed</Th>
                <Th className="w-20 text-right">Action</Th>
              </tr>
            </thead>
            <tbody>
              {all.map((o) => (
                <tr key={o.id} className="hover:bg-canvas/60">
                  <Td className="font-bold whitespace-nowrap text-navy-800">
                    <Link
                      href={`/orders/${o.id}`}
                      className="hover:text-accent-600"
                    >
                      {o.id}
                    </Link>
                  </Td>
                  <Td>
                    <Link
                      href={`/orders/${o.id}`}
                      className="group flex items-center gap-3"
                    >
                      <div className="relative h-10 w-12 shrink-0 overflow-hidden rounded-md bg-navy-50">
                        {o.image && (
                          <Image
                            src={o.image}
                            alt={o.machine}
                            fill
                            sizes="48px"
                            className="object-cover"
                          />
                        )}
                      </div>
                      <span className="whitespace-nowrap group-hover:text-accent-600">
                        {o.machine}
                      </span>
                    </Link>
                  </Td>
                  <Td className="whitespace-nowrap text-muted">{o.buyer}</Td>
                  <Td className="whitespace-nowrap text-muted">{o.seller}</Td>
                  <Td>
                    <Badge tone={statusTone(o.stage)} dot>
                      {o.stage}
                    </Badge>
                  </Td>
                  <Td className="whitespace-nowrap text-muted">
                    {o.destination}
                  </Td>
                  <Td className="text-right font-bold whitespace-nowrap text-navy-800">
                    {rupees(o.amount)}
                  </Td>
                  <Td className="text-right text-xs whitespace-nowrap text-muted">
                    {shortDate(o.placedOn)}
                  </Td>
                  <Td className="text-right">
                    <select
                      value={o.stage}
                      disabled={busy === o.id}
                      onChange={(e) => setStage(o.id, e.target.value)}
                      aria-label={`Stage for ${o.id}`}
                      className="rounded-lg border border-line bg-white px-2 py-1.5 text-xs font-semibold text-navy-800 outline-none focus:border-navy-600 disabled:opacity-50"
                    >
                      {STAGES.map((stage) => (
                        <option key={stage}>{stage}</option>
                      ))}
                    </select>
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        )}
      </Card>
    </>
  );
}
