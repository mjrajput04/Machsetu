"use client";

import Image from "next/image";
import Link from "next/link";
import { use, useState } from "react";
import { api, useApi, usePolling } from "@/lib/api";
import { rupees, shortDate } from "@/lib/format";
import { BackLink, Rows } from "@/components/record";
import {
  Badge,
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
const STAGES = [
  "Inquiry Received",
  "Under Review",
  "Broker Contacting You",
  "Price Confirmed",
  "Machine Reserved",
  "Order Confirmed",
  "Delivery Scheduled",
  "Delivered",
];

interface OrderItem {
  productId: string | null;
  title: string;
  brand: string;
  equipmentType: string;
  image: string | null;
  unitPrice: number;
  quantity: number;
}

interface Customer {
  name: string;
  company: string;
  email: string;
  phone: string;
  gstin: string;
  pan: string;
  designation: string;
  street: string;
  city: string;
  state: string;
  zip: string;
}

interface OrderRecord {
  id: string;
  machine: string;
  image: string | null;
  buyer: string;
  seller: string;
  amount: number;
  subtotal: number;
  freight: number;
  gst: number;
  stage: string;
  stageIndex: number;
  placedOn: string;
  destination: string;
  deliveryAddress?: string;
  customer?: Customer;
  equipmentType: string;
  logisticsMode: string;
  items?: OrderItem[];
  note?: string;
}

/**
 * Everything the buyer typed at checkout, in one place — so the desk can
 * raise the invoice and book the freight without calling them back.
 */
export default function OrderDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const record = useApi<{ order: OrderRecord }>(`/api/admin/orders/${id}`);
  const order = record.data?.order;

  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");

  usePolling(record.reload);

  async function move(stage: string) {
    setBusy(true);
    try {
      await api.put(`/api/admin/orders/${id}`, { stage, note: note.trim() });
      setNote("");
      record.reload();
    } catch (error) {
      window.alert((error as Error).message);
    } finally {
      setBusy(false);
    }
  }

  if (!order) {
    return (
      <>
        <BackLink href="/orders" label="Back to Orders" />
        <Card>
          <EmptyState
            title={record.loading ? "Loading order…" : "Order not found"}
            message={record.error ?? `No order is filed under ${id}.`}
          />
        </Card>
      </>
    );
  }

  const customer = order.customer;
  const items = order.items ?? [];
  const reached = order.stageIndex ?? 1;

  return (
    <>
      <BackLink href="/orders" label="Back to Orders" />

      <PageHeader
        title={order.id}
        subtitle={`${order.machine} · placed ${shortDate(order.placedOn)} · ${order.buyer}`}
        actions={
          <>
            <Badge tone={statusTone(order.stage)} dot>
              {order.stage}
            </Badge>
            <select
              value={order.stage}
              disabled={busy}
              onChange={(e) => move(e.target.value)}
              aria-label="Order stage"
              className="rounded-lg border border-line bg-white px-3 py-2 text-sm font-semibold text-navy-800 outline-none focus:border-navy-600 disabled:opacity-50"
            >
              {STAGES.map((stage) => (
                <option key={stage}>{stage}</option>
              ))}
            </select>
          </>
        }
      />

      <div className="grid gap-4 xl:grid-cols-5">
        <div className="space-y-4 xl:col-span-3">
          <Card padded={false}>
            <div className="p-5">
              <CardHeader
                title="Machines ordered"
                subtitle={`${items.length} line${items.length === 1 ? "" : "s"} · sold by ${order.seller}`}
              />
            </div>
            <Table>
              <thead>
                <tr>
                  <Th>Machine</Th>
                  <Th className="text-right">Unit price</Th>
                  <Th className="text-right">Qty</Th>
                  <Th className="text-right">Line total</Th>
                </tr>
              </thead>
              <tbody>
                {items.map((item, index) => (
                  <tr key={`${item.title}-${index}`}>
                    <Td>
                      <div className="flex items-center gap-3">
                        <div className="relative h-11 w-14 shrink-0 overflow-hidden rounded-lg bg-navy-50">
                          {item.image && (
                            <Image
                              src={item.image}
                              alt={item.title}
                              fill
                              sizes="56px"
                              className="object-cover"
                            />
                          )}
                        </div>
                        <div className="min-w-0">
                          {item.productId ? (
                            <Link
                              href={`/products/${item.productId}`}
                              className="truncate font-bold text-navy-800 hover:text-accent-600"
                            >
                              {item.title}
                            </Link>
                          ) : (
                            <p className="truncate font-bold text-navy-800">
                              {item.title}
                            </p>
                          )}
                          <p className="truncate text-xs text-muted">
                            {[item.brand, item.equipmentType, item.productId]
                              .filter(Boolean)
                              .join(" · ")}
                          </p>
                        </div>
                      </div>
                    </Td>
                    <Td className="text-right whitespace-nowrap">
                      {rupees(item.unitPrice)}
                    </Td>
                    <Td className="text-right">{item.quantity}</Td>
                    <Td className="text-right font-bold whitespace-nowrap text-navy-800">
                      {rupees(item.unitPrice * item.quantity)}
                    </Td>
                  </tr>
                ))}
              </tbody>
            </Table>

            <dl className="divide-y divide-line/70 border-t border-line px-5">
              {[
                ["Subtotal", order.subtotal],
                ["Freight & brokerage", order.freight],
                ["GST", order.gst],
              ].map(([label, value]) => (
                <div
                  key={String(label)}
                  className="flex items-center justify-between gap-4 py-2.5"
                >
                  <dt className="text-sm text-muted">{label}</dt>
                  <dd className="text-sm font-semibold text-navy-800">
                    {rupees(Number(value))}
                  </dd>
                </div>
              ))}
              <div className="flex items-center justify-between gap-4 py-3.5">
                <dt className="text-sm font-bold text-navy-800">
                  Total charged
                </dt>
                <dd className="text-xl font-extrabold text-accent-600">
                  {rupees(order.amount)}
                </dd>
              </div>
            </dl>
          </Card>

          <Card>
            <CardHeader
              title="Fulfilment timeline"
              subtitle="What the buyer sees on the app's tracking screen"
            />
            <ol className="space-y-2.5">
              {STAGES.map((stage, index) => {
                const done = index + 1 < reached;
                const current = index + 1 === reached;
                return (
                  <li
                    key={stage}
                    className={cx(
                      "flex items-center gap-3 rounded-lg border px-3.5 py-3",
                      current
                        ? "border-accent-200 bg-accent-50"
                        : "border-line",
                    )}
                  >
                    <span
                      className={cx(
                        "grid h-5 w-5 shrink-0 place-items-center rounded-full text-[11px] font-bold text-white",
                        done
                          ? "bg-emerald-500"
                          : current
                            ? "bg-accent-500"
                            : "bg-slate-300",
                      )}
                    >
                      {done ? "✓" : index + 1}
                    </span>
                    <span
                      className={cx(
                        "text-sm",
                        current
                          ? "font-bold text-accent-700"
                          : done
                            ? "text-ink"
                            : "font-medium text-muted",
                      )}
                    >
                      {stage}
                    </span>
                  </li>
                );
              })}
            </ol>

            <div className="mt-4">
              <label className="block">
                <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                  Note to the buyer
                </span>
                <textarea
                  rows={2}
                  value={note}
                  placeholder="Sent with the next stage change as a notification"
                  onChange={(e) => setNote(e.target.value)}
                  className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                />
              </label>
              {order.note && (
                <p className="mt-2 text-xs text-muted">
                  Last note sent: {order.note}
                </p>
              )}
            </div>
          </Card>
        </div>

        <div className="space-y-4 xl:col-span-2">
          <Card>
            <CardHeader
              title="Buyer details"
              subtitle="Exactly as entered on the checkout form"
            />
            <Rows
              rows={[
                ["Contact person", customer?.name ?? order.buyer],
                ["Designation", customer?.designation ?? ""],
                ["Company", customer?.company ?? ""],
                ["Mobile", customer?.phone ?? ""],
                ["Email", customer?.email ?? ""],
                ["GSTIN", customer?.gstin ?? ""],
                ["PAN", customer?.pan ?? ""],
              ]}
            />
          </Card>

          <Card>
            <CardHeader
              title="Delivery address"
              subtitle={order.logisticsMode}
            />
            <p className="mb-3 text-sm leading-relaxed text-ink">
              {order.deliveryAddress || order.destination || "Not provided"}
            </p>
            <Rows
              rows={[
                ["Street / unit", customer?.street ?? ""],
                ["City", customer?.city ?? ""],
                ["State", customer?.state ?? ""],
                ["Pincode", customer?.zip ?? ""],
              ]}
            />
          </Card>

          <Card>
            <CardHeader title="Order record" />
            <Rows
              rows={[
                ["Order ID", order.id],
                ["Placed on", shortDate(order.placedOn)],
                ["Stage", `${order.stage} (${reached}/${STAGES.length})`],
                ["Seller", order.seller],
                ["Equipment type", order.equipmentType],
                ["Logistics", order.logisticsMode],
              ]}
            />
          </Card>
        </div>
      </div>
    </>
  );
}
