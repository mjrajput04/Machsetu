"use client";

import { useRouter } from "next/navigation";
import { use, useState } from "react";
import { api, useApi } from "@/lib/api";
import type { SellRequest } from "@/lib/types";
import { rupees, shortDate } from "@/lib/format";
import {
  Badge,
  Button,
  Card,
  CardHeader,
  EmptyState,
  PageHeader,
  statusTone,
} from "@/components/ui";
import {
  BackLink,
  CommercialCard,
  DetailsCard,
  DocumentsCard,
  Gallery,
  InspectionCard,
  PhotosChecklistCard,
  SellerCard,
  SpecsCard,
} from "@/components/record";

export default function RequestDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  const record = useApi<{ request: SellRequest }>(`/api/admin/requests/${id}`);
  const request = record.data?.request;

  /** Every desk decision goes through the same endpoint. */
  async function act(action: string, note?: string) {
    setBusy(true);
    try {
      const result = await api.put<{ publishedProductId?: string }>(
        `/api/admin/requests/${id}`,
        note === undefined ? { action } : { action, note },
      );
      if (result.publishedProductId) {
        router.push(`/products/${result.publishedProductId}`);
        return;
      }
      record.reload();
    } catch (error) {
      window.alert((error as Error).message);
    } finally {
      setBusy(false);
    }
  }

  function ask(action: string, prompt: string) {
    const note = window.prompt(prompt, "");
    if (note === null) return;
    act(action, note);
  }

  if (!request) {
    return (
      <>
        <BackLink href="/requests" label="Back to Sell Requests" />
        <Card>
          <EmptyState
            title={record.loading ? "Loading submission…" : "Request not found"}
            message={record.error ?? `No submission is filed under ${id}.`}
          />
        </Card>
      </>
    );
  }

  const open =
    request.status === "Awaiting Review" ||
    request.status === "Inspection Scheduled";

  return (
    <>
      <BackLink href="/requests" label="Back to Sell Requests" />

      <PageHeader
        title={request.machine}
        subtitle={`${request.id} · ${request.brand} · submitted ${shortDate(request.submittedOn)}`}
        actions={
          open ? (
            <>
              <Button disabled={busy} onClick={() => act("approve")}>
                Approve &amp; publish
              </Button>
              <Button
                variant="secondary"
                disabled={busy}
                onClick={() =>
                  ask("schedule", "Inspection note (inspector, date, venue)")
                }
              >
                Schedule inspection
              </Button>
              <Button
                variant="secondary"
                disabled={busy}
                onClick={() => ask("info", "What does the seller need to send?")}
              >
                Request more info
              </Button>
              <Button
                variant="danger"
                disabled={busy}
                onClick={() => ask("reject", "Reason for rejection")}
              >
                Reject
              </Button>
            </>
          ) : (
            <Button
              variant="secondary"
              disabled={busy}
              onClick={() => act("reopen")}
            >
              Reopen request
            </Button>
          )
        }
      />

      <div className="grid gap-4 xl:grid-cols-5">
        <div className="space-y-4 xl:col-span-3">
          <Card>
            <Gallery images={request.images} alt={request.machine} />

            <div className="mt-5 flex flex-wrap items-start justify-between gap-4">
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <Badge tone={statusTone(request.status)} dot>
                    {request.status}
                  </Badge>
                  <Badge tone="navy">{request.category}</Badge>
                </div>
                <h2 className="mt-3 text-2xl font-extrabold text-navy-800">
                  {request.machine}
                </h2>
                <p className="mt-1 text-sm text-muted">
                  {request.brand} · {request.year} · {request.condition}
                </p>
              </div>
              <div className="text-right">
                <p className="text-3xl font-extrabold text-accent-600">
                  {rupees(request.askingPrice)}
                </p>
                <p className="text-xs text-muted">Asking price</p>
              </div>
            </div>
          </Card>

          <DetailsCard
            details={request.details}
            categories={request.categories}
            location={request.city}
            hours={request.hours}
            condition={request.condition}
            description={request.description}
          />

          <SpecsCard specs={request.specs} />

          <InspectionCard
            report={request.inspection}
            subtitle={
              request.inspection
                ? `${request.inspection.inspectorName} · ${shortDate(request.inspection.inspectedOn)}`
                : "Not inspected yet"
            }
          />
        </div>

        <div className="space-y-4 xl:col-span-2">
          <Card>
            <CardHeader
              title="Verification checklist"
              subtitle="All four must clear before this listing goes live"
            />
            <ul className="space-y-2.5">
              {[
                {
                  label: "Ownership proof matches GSTIN",
                  done: request.documents.some(
                    (d) => d.category === "Ownership Proof",
                  ),
                },
                {
                  label: "Serial plate photo attached",
                  done: request.requiredPhotos.includes("Name Plate"),
                },
                {
                  label: "Invoice or purchase record attached",
                  done: request.documents.some((d) =>
                    d.category.includes("Invoice"),
                  ),
                },
                {
                  label: "Physical inspection completed",
                  done: request.inspection !== null,
                },
              ].map((c) => (
                <li
                  key={c.label}
                  className="flex items-center gap-3 rounded-lg border border-line px-3.5 py-3"
                >
                  <span
                    className={
                      c.done
                        ? "grid h-5 w-5 shrink-0 place-items-center rounded-full bg-emerald-500 text-[11px] font-bold text-white"
                        : "grid h-5 w-5 shrink-0 place-items-center rounded-full bg-slate-300 text-[11px] font-bold text-white"
                    }
                  >
                    {c.done ? "✓" : "!"}
                  </span>
                  <span
                    className={
                      c.done
                        ? "text-sm text-ink"
                        : "text-sm font-medium text-muted"
                    }
                  >
                    {c.label}
                  </span>
                </li>
              ))}
            </ul>
          </Card>

          <SellerCard
            seller={request.sellerInfo}
            subtitle={`Submitted ${shortDate(request.submittedOn)}`}
          />

          <CommercialCard
            commercial={request.commercial}
            price={request.askingPrice}
            remark={request.note}
          />

          <DocumentsCard documents={request.documents} />

          <PhotosChecklistCard ticked={request.requiredPhotos} />
        </div>
      </div>
    </>
  );
}
