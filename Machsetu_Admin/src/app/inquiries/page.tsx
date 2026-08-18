"use client";

import { useMemo, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { useApi, usePolling } from "@/lib/api";
import type { Inquiry, InquiryStatus } from "@/lib/types";
import { relativeDate, rupees } from "@/lib/format";
import {
  Avatar,
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

const STATUSES: Array<InquiryStatus | "All"> = [
  "All",
  "New",
  "Broker Assigned",
  "Awaiting Quote",
  "Quote Received",
  "Negotiating",
  "Closed",
  "Lost",
  "Expired",
];

export default function InquiriesPage() {
  const [status, setStatus] = useState<InquiryStatus | "All">("All");
  const [query, setQuery] = useState("");

  const feed = useApi<{ inquiries: Inquiry[] }>("/api/admin/inquiries");
  usePolling(feed.reload);
  const all = useMemo(() => feed.data?.inquiries ?? [], [feed.data]);

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return all.filter((i) => {
      if (status !== "All" && i.status !== status) return false;
      if (!q) return true;
      return [i.id, i.machine, i.buyer, i.company, i.city]
        .join(" ")
        .toLowerCase()
        .includes(q);
    });
  }, [all, status, query]);

  const pipeline = all
    .filter((i) => i.status !== "Closed" && i.status !== "Lost")
    .reduce((sum, i) => sum + (i.quoted ?? i.budget), 0);
  const won = all.filter((i) => i.status === "Closed").length;
  const lost = all.filter(
    (i) => i.status === "Lost" || i.status === "Expired",
  ).length;
  const winRate = won + lost === 0 ? 0 : Math.round((won / (won + lost)) * 100);

  return (
    <>
      <PageHeader
        title="Inquiries"
        subtitle="Requests for quotation raised by buyers, and where each one stands."
        actions={
          <>
            <Button variant="secondary">Export</Button>
            <Button>Assign broker</Button>
          </>
        }
      />

      <div className="mb-4 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Open pipeline
          </p>
          <p className="mt-2 text-3xl font-extrabold text-navy-800">
            {rupees(pipeline)}
          </p>
          <p className="mt-1 text-xs text-faint">Across active RFQs</p>
        </Card>
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Awaiting action
          </p>
          <p className="mt-2 text-3xl font-extrabold text-accent-600">
            {all.filter((i) => i.status === "New").length}
          </p>
          <p className="mt-1 text-xs text-faint">No broker assigned yet</p>
        </Card>
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Quoted
          </p>
          <p className="mt-2 text-3xl font-extrabold text-navy-800">
            {all.filter((i) => i.quoted !== null).length}
          </p>
          <p className="mt-1 text-xs text-faint">Price sent to buyer</p>
        </Card>
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Win rate
          </p>
          <p className="mt-2 text-3xl font-extrabold text-emerald-600">
            {winRate}%
          </p>
          <p className="mt-1 text-xs text-faint">
            {won} won · {lost} lost
          </p>
        </Card>
      </div>

      <Card padded={false}>
        <div className="flex flex-wrap items-center gap-3 border-b border-line p-4">
          <label className="relative min-w-[220px] flex-1">
            <span className="sr-only">Search inquiries</span>
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search by RFQ, machine, buyer or company…"
              className="w-full rounded-lg border border-line bg-canvas px-3 py-2 text-sm outline-none placeholder:text-faint focus:border-navy-600 focus:bg-white"
            />
          </label>
          <div className="flex flex-wrap gap-1.5">
            {STATUSES.map((s) => (
              <button
                key={s}
                onClick={() => setStatus(s)}
                className={cx(
                  "rounded-full px-3 py-1.5 text-xs font-semibold transition-colors",
                  status === s
                    ? "bg-navy-800 text-white"
                    : "bg-canvas text-muted hover:bg-navy-50 hover:text-navy-700",
                )}
              >
                {s}
              </button>
            ))}
          </div>
        </div>

        {feed.loading ? (
          <EmptyState
            title="Loading inquiries…"
            message="Fetching buyer RFQs from the database."
          />
        ) : feed.error ? (
          <EmptyState title="Could not load inquiries" message={feed.error} />
        ) : rows.length === 0 ? (
          <EmptyState
            title="No inquiries match"
            message="Try a different status filter or search term."
          />
        ) : (
          <Table>
            <thead>
              <tr>
                <Th>RFQ</Th>
                <Th>Machine</Th>
                <Th>Buyer</Th>
                <Th>Status</Th>
                <Th>Broker</Th>
                <Th className="text-right">Budget</Th>
                <Th className="text-right">Quoted</Th>
                <Th className="text-right">Last activity</Th>
                <Th className="w-20 text-right">Action</Th>
              </tr>
            </thead>
            <tbody>
              {rows.map((i) => (
                <tr key={i.id} className="hover:bg-canvas/60">
                  <Td className="font-bold whitespace-nowrap text-navy-800">
                    <Link
                      href={`/inquiries/${i.id}`}
                      className="hover:text-accent-600"
                    >
                      {i.id}
                    </Link>
                  </Td>
                  <Td>
                    <Link
                      href={`/inquiries/${i.id}`}
                      className="group flex items-center gap-3"
                    >
                      <div className="relative h-11 w-14 shrink-0 overflow-hidden rounded-md bg-navy-50">
                        {i.image && (
                          <Image
                            src={i.image}
                            alt={i.machine}
                            fill
                            sizes="56px"
                            className="object-cover"
                          />
                        )}
                      </div>
                      <div className="min-w-0">
                        <p className="truncate font-semibold text-navy-800 group-hover:text-accent-600">
                          {i.machine}
                        </p>
                        <p className="truncate text-xs text-muted">{i.brand}</p>
                        <div className="mt-1 flex flex-wrap gap-1">
                          {i.specs.slice(0, 3).map((sp) => (
                            <span
                              key={sp}
                              className="rounded bg-canvas px-1.5 py-0.5 text-[10px] font-semibold text-muted"
                            >
                              {sp}
                            </span>
                          ))}
                        </div>
                      </div>
                    </Link>
                  </Td>
                  <Td>
                    <div className="flex items-center gap-2.5">
                      <Avatar name={i.buyer} />
                      <div className="min-w-0">
                        <p className="truncate text-sm font-semibold text-navy-800">
                          {i.buyer}
                        </p>
                        <p className="truncate text-xs text-muted">
                          {i.company} · {i.city}
                        </p>
                      </div>
                    </div>
                  </Td>
                  <Td>
                    <Badge tone={statusTone(i.status)} dot>
                      {i.status}
                    </Badge>
                    {i.responseNote && (
                      <p className="mt-1.5 max-w-[220px] text-xs leading-snug text-muted">
                        {i.responseNote}
                      </p>
                    )}
                  </Td>
                  <Td className="whitespace-nowrap text-muted">
                    {i.broker ?? (
                      <span className="text-accent-600">Unassigned</span>
                    )}
                  </Td>
                  <Td className="text-right whitespace-nowrap text-muted">
                    {rupees(i.budget)}
                  </Td>
                  <Td className="text-right font-bold whitespace-nowrap text-navy-800">
                    {i.quoted === null ? "—" : rupees(i.quoted)}
                  </Td>
                  <Td className="text-right text-xs whitespace-nowrap text-muted">
                    {relativeDate(i.lastActivity)}
                  </Td>
                  <Td className="text-right">
                    <Link href={`/inquiries/${i.id}`}>
                      <Button size="sm" variant="secondary">
                        Open
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
          {all.length} inquiries
        </div>
      </Card>
    </>
  );
}
