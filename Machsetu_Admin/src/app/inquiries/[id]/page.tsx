"use client";

import Image from "next/image";
import Link from "next/link";
import { use, useState } from "react";
import { api, useApi, usePolling } from "@/lib/api";
import { rupees, shortDate } from "@/lib/format";
import { BackLink, Rows } from "@/components/record";
import {
  Badge,
  Button,
  Card,
  CardHeader,
  EmptyState,
  PageHeader,
  statusTone,
} from "@/components/ui";

const STATUSES = [
  "New",
  "Broker Assigned",
  "Awaiting Quote",
  "Quote Received",
  "Negotiating",
  "Closed",
  "Lost",
  "Expired",
];

interface InquiryRecord {
  id: string;
  machine: string;
  brand: string;
  image: string | null;
  specs: string[];
  buyer: string;
  company: string;
  city: string;
  budget: number;
  quoted: number | null;
  status: string;
  broker: string | null;
  responseNote: string;
  productId?: string | null;
  raisedOn: string;
  lastActivity: string;
}

/**
 * Everything the buyer typed into the app's RFQ form, with the desk's own
 * controls beside it — assign a broker, record a quote, close it out.
 */
export default function InquiryDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const record = useApi<{ inquiry: InquiryRecord }>(
    `/api/admin/inquiries/${id}`,
  );
  const inquiry = record.data?.inquiry;

  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Only the touched fields are held here; the rest comes off the record.
  const [edits, setEdits] = useState<{
    broker?: string;
    quoted?: string;
    responseNote?: string;
  }>({});

  usePolling(record.reload);

  async function save(patch: Record<string, unknown>) {
    setBusy(true);
    setError(null);
    try {
      await api.put(`/api/admin/inquiries/${id}`, patch);
      setEdits({});
      record.reload();
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  if (!inquiry) {
    return (
      <>
        <BackLink href="/inquiries" label="Back to Inquiries" />
        <Card>
          <EmptyState
            title={record.loading ? "Loading inquiry…" : "Inquiry not found"}
            message={record.error ?? `No RFQ is filed under ${id}.`}
          />
        </Card>
      </>
    );
  }

  const broker = edits.broker ?? inquiry.broker ?? "";
  const quoted =
    edits.quoted ?? (inquiry.quoted !== null ? String(inquiry.quoted) : "");
  const note = edits.responseNote ?? inquiry.responseNote ?? "";

  return (
    <>
      <BackLink href="/inquiries" label="Back to Inquiries" />

      <PageHeader
        title={inquiry.machine}
        subtitle={`${inquiry.id} · raised ${shortDate(inquiry.raisedOn)} by ${inquiry.buyer}`}
        actions={
          <>
            <Badge tone={statusTone(inquiry.status)} dot>
              {inquiry.status}
            </Badge>
            <select
              value={inquiry.status}
              disabled={busy}
              onChange={(e) => save({ status: e.target.value })}
              aria-label="Inquiry status"
              className="rounded-lg border border-line bg-white px-3 py-2 text-sm font-semibold text-navy-800 outline-none focus:border-navy-600 disabled:opacity-50"
            >
              {STATUSES.map((s) => (
                <option key={s}>{s}</option>
              ))}
            </select>
          </>
        }
      />

      {error && (
        <div className="mb-4 rounded-lg border border-rose-200 bg-rose-50 px-4 py-3 text-sm font-semibold text-rose-700">
          {error}
        </div>
      )}

      <div className="grid gap-4 xl:grid-cols-5">
        <div className="space-y-4 xl:col-span-3">
          <Card>
            <CardHeader
              title="What the buyer asked for"
              subtitle="Exactly as submitted on the app's inquiry form"
            />

            <div className="mb-4 flex items-start gap-4">
              <div className="relative h-20 w-28 shrink-0 overflow-hidden rounded-lg bg-navy-50">
                {inquiry.image && (
                  <Image
                    src={inquiry.image}
                    alt={inquiry.machine}
                    fill
                    sizes="112px"
                    className="object-cover"
                  />
                )}
              </div>
              <div className="min-w-0">
                {inquiry.productId ? (
                  <Link
                    href={`/products/${inquiry.productId}`}
                    className="text-lg font-extrabold text-navy-800 hover:text-accent-600"
                  >
                    {inquiry.machine}
                  </Link>
                ) : (
                  <p className="text-lg font-extrabold text-navy-800">
                    {inquiry.machine}
                  </p>
                )}
                <p className="mt-0.5 text-sm text-muted">
                  {inquiry.brand || "Any brand"}
                </p>
                <p className="mt-2 text-2xl font-extrabold text-accent-600">
                  {inquiry.budget > 0
                    ? rupees(inquiry.budget)
                    : "No budget given"}
                </p>
                <p className="text-xs font-semibold text-muted">
                  Target budget
                </p>
              </div>
            </div>

            <p className="mb-2 text-sm font-semibold text-navy-800">
              Required specifications
            </p>
            {inquiry.specs.length === 0 ? (
              <p className="text-sm text-muted">None given.</p>
            ) : (
              <div className="flex flex-wrap gap-2">
                {inquiry.specs.map((spec, index) => (
                  <span
                    key={`${spec}-${index}`}
                    className="rounded-full bg-canvas px-3 py-1.5 text-xs font-semibold text-muted ring-1 ring-line ring-inset"
                  >
                    {spec}
                  </span>
                ))}
              </div>
            )}
          </Card>

          <Card>
            <CardHeader
              title="Sourcing desk"
              subtitle="Saved changes notify the buyer in the app"
            />
            <div className="grid gap-4 sm:grid-cols-2">
              <label className="block">
                <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                  Broker
                </span>
                <input
                  value={broker}
                  placeholder="Who is handling this"
                  onChange={(e) =>
                    setEdits((p) => ({ ...p, broker: e.target.value }))
                  }
                  className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                />
              </label>
              <label className="block">
                <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                  Quoted price (₹)
                </span>
                <input
                  value={quoted}
                  inputMode="numeric"
                  placeholder="Leave blank until quoted"
                  onChange={(e) =>
                    setEdits((p) => ({ ...p, quoted: e.target.value }))
                  }
                  className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                />
              </label>
              <div className="sm:col-span-2">
                <label className="block">
                  <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                    Response to the buyer
                  </span>
                  <textarea
                    rows={3}
                    value={note}
                    placeholder="Shown on the buyer's inquiry card and sent as a notification"
                    onChange={(e) =>
                      setEdits((p) => ({ ...p, responseNote: e.target.value }))
                    }
                    className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                  />
                </label>
              </div>
            </div>

            <div className="mt-4 flex flex-wrap gap-2">
              <Button
                disabled={busy}
                onClick={() => save({ broker, quoted, responseNote: note })}
              >
                {busy ? "Saving…" : "Save and notify"}
              </Button>
              <Button
                variant="secondary"
                disabled={busy}
                onClick={() =>
                  save({
                    broker,
                    quoted,
                    responseNote: note,
                    status: "Quote Received",
                  })
                }
              >
                Send as quote
              </Button>
              <Button
                variant="danger"
                disabled={busy}
                onClick={() => save({ status: "Lost", responseNote: note })}
              >
                Mark lost
              </Button>
            </div>
          </Card>
        </div>

        <div className="space-y-4 xl:col-span-2">
          <Card>
            <CardHeader title="Buyer" />
            <Rows
              rows={[
                ["Name", inquiry.buyer],
                ["Company", inquiry.company],
                ["Delivery city", inquiry.city],
              ]}
            />
          </Card>

          <Card>
            <CardHeader title="Inquiry record" />
            <Rows
              rows={[
                ["RFQ ID", inquiry.id],
                ["Status", inquiry.status],
                ["Broker", inquiry.broker ?? "Not assigned"],
                [
                  "Budget",
                  inquiry.budget > 0 ? rupees(inquiry.budget) : "Not given",
                ],
                [
                  "Quoted",
                  inquiry.quoted !== null
                    ? rupees(inquiry.quoted)
                    : "Not quoted",
                ],
                ["Raised on", shortDate(inquiry.raisedOn)],
                ["Last activity", shortDate(inquiry.lastActivity)],
              ]}
            />
          </Card>
        </div>
      </div>
    </>
  );
}
