"use client";

import Image from "next/image";
import Link from "next/link";
import { useMemo, useState } from "react";
import { REQUIRED_PHOTOS } from "@/lib/options";
import { useApi, usePolling } from "@/lib/api";
import type { RequestStatus, SellRequest } from "@/lib/types";
import { relativeDate, rupees } from "@/lib/format";
import {
  Badge,
  Button,
  Card,
  EmptyState,
  PageHeader,
  Table,
  Td,
  Th,
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

/** List only — the full submission lives on /requests/[id]. */
export default function RequestsPage() {
  const [tab, setTab] = useState<RequestStatus | "All">("All");
  const [query, setQuery] = useState("");

  const feed = useApi<{ requests: SellRequest[] }>("/api/admin/requests");
  usePolling(feed.reload);
  const all = useMemo(() => feed.data?.requests ?? [], [feed.data]);

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return all.filter((r) => {
      if (tab !== "All" && r.status !== tab) return false;
      if (!q) return true;
      return [r.id, r.machine, r.brand, r.seller, r.city]
        .join(" ")
        .toLowerCase()
        .includes(q);
    });
  }, [all, tab, query]);

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
            t === "All" ? all.length : all.filter((r) => r.status === t).length;
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

      <Card padded={false}>
        <div className="border-b border-line p-4">
          <label className="relative block max-w-md">
            <span className="sr-only">Search requests</span>
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search by request ID, machine, seller or city…"
              className="w-full rounded-lg border border-line bg-canvas px-3 py-2 text-sm outline-none placeholder:text-faint focus:border-navy-600 focus:bg-white"
            />
          </label>
        </div>

        {feed.loading ? (
          <EmptyState
            title="Loading submissions…"
            message="Fetching seller requests from the database."
          />
        ) : feed.error ? (
          <EmptyState title="Could not load requests" message={feed.error} />
        ) : rows.length === 0 ? (
          <EmptyState
            title="Nothing in this state"
            message="Requests appear here as sellers submit machines."
          />
        ) : (
          <Table>
            <thead>
              <tr>
                <Th>Machine</Th>
                <Th>Seller</Th>
                <Th>Status</Th>
                <Th className="text-right">Asking price</Th>
                <Th className="text-right">Photos</Th>
                <Th className="text-right">Docs</Th>
                <Th className="text-right">Submitted</Th>
                <Th className="w-28 text-right">Action</Th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id} className="group hover:bg-canvas/60">
                  <Td>
                    <Link
                      href={`/requests/${r.id}`}
                      className="flex items-center gap-3"
                    >
                      <div className="relative h-11 w-14 shrink-0 overflow-hidden rounded-lg bg-navy-50">
                        {r.images[0] && (
                          <Image
                            src={r.images[0]}
                            alt={r.machine}
                            fill
                            sizes="56px"
                            className="object-cover"
                          />
                        )}
                      </div>
                      <div className="min-w-0">
                        <p className="truncate font-bold text-navy-800 group-hover:text-accent-600">
                          {r.machine}
                        </p>
                        <p className="truncate text-xs text-muted">
                          {r.id} · {r.brand} · {r.year} · {r.category}
                        </p>
                      </div>
                    </Link>
                  </Td>
                  <Td>
                    <p className="whitespace-nowrap text-ink">{r.seller}</p>
                    <p className="text-xs whitespace-nowrap text-muted">
                      {r.city}
                    </p>
                  </Td>
                  <Td>
                    <Badge tone={statusTone(r.status)} dot>
                      {r.status}
                    </Badge>
                  </Td>
                  <Td className="text-right font-bold whitespace-nowrap text-navy-800">
                    {rupees(r.askingPrice)}
                  </Td>
                  <Td className="text-right text-muted">
                    {r.requiredPhotos.length}
                    <span className="text-faint">
                      /{REQUIRED_PHOTOS.length}
                    </span>
                  </Td>
                  <Td className="text-right text-muted">
                    {r.documents.length}
                  </Td>
                  <Td className="text-right text-xs whitespace-nowrap text-muted">
                    {relativeDate(r.submittedOn)}
                  </Td>
                  <Td className="text-right">
                    <Link href={`/requests/${r.id}`}>
                      <Button size="sm" variant="secondary">
                        Review
                      </Button>
                    </Link>
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        )}

        <div className="px-4 py-3 text-sm text-muted">
          Showing <strong className="text-navy-800">{rows.length}</strong> of{" "}
          {all.length} requests
        </div>
      </Card>
    </>
  );
}
