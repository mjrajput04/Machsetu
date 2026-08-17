"use client";

import Image from "next/image";
import Link from "next/link";
import { useMemo, useState } from "react";
import { api, useApi } from "@/lib/api";
import type { Product, ProductStatus } from "@/lib/types";
import { rupees, shortDate } from "@/lib/format";
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

const STATUSES: Array<ProductStatus | "All"> = [
  "All",
  "Live",
  "Pending Review",
  "Under Offer",
  "Sold",
  "Rejected",
];

export default function ProductsPage() {
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState<ProductStatus | "All">("All");
  const [category, setCategory] = useState<string>("All");
  const [selected, setSelected] = useState<string[]>([]);
  const [busy, setBusy] = useState(false);

  const catalogue = useApi<{ products: Product[] }>("/api/admin/products");
  // The filter offers whatever Settings currently publishes.
  const config = useApi<{ categories: string[] }>("/api/settings");
  const CATEGORIES = useMemo(() => config.data?.categories ?? [], [config.data]);
  const all = useMemo(
    () => catalogue.data?.products ?? [],
    [catalogue.data],
  );

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return all.filter((p) => {
      if (status !== "All" && p.status !== status) return false;
      if (category !== "All" && p.category !== category) return false;
      if (!q) return true;
      return [p.title, p.brand, p.id, p.seller, p.location]
        .join(" ")
        .toLowerCase()
        .includes(q);
    });
  }, [all, query, status, category]);

  const allShownSelected =
    rows.length > 0 && rows.every((r) => selected.includes(r.id));

  function toggleAll() {
    setSelected(allShownSelected ? [] : rows.map((r) => r.id));
  }

  function toggle(id: string) {
    setSelected((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id],
    );
  }

  /** Applies one change to every ticked row, then refreshes the table. */
  async function bulk(patch: Record<string, unknown>) {
    setBusy(true);
    try {
      await Promise.all(
        selected.map((id) => api.put(`/api/admin/products/${id}`, patch)),
      );
      setSelected([]);
      catalogue.reload();
    } catch (error) {
      window.alert((error as Error).message);
    } finally {
      setBusy(false);
    }
  }

  async function remove(ids: string[], label: string) {
    if (!window.confirm(`Delete ${label}? This cannot be undone.`)) return;
    setBusy(true);
    try {
      await Promise.all(ids.map((id) => api.del(`/api/admin/products/${id}`)));
      setSelected((prev) => prev.filter((id) => !ids.includes(id)));
      catalogue.reload();
    } catch (error) {
      window.alert((error as Error).message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <>
      <PageHeader
        title="Products"
        subtitle="Every machine in the catalogue, across all listing states."
        actions={
          <>
            <Button variant="secondary">Import CSV</Button>
            <Link href="/products/new">
              <Button>Add product</Button>
            </Link>
          </>
        }
      />

      <Card padded={false}>
        <div className="flex flex-wrap items-center gap-3 border-b border-line p-4">
          <label className="relative min-w-[220px] flex-1">
            <span className="sr-only">Search products</span>
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search by machine, brand, seller or ID…"
              className="w-full rounded-lg border border-line bg-canvas px-3 py-2 text-sm outline-none placeholder:text-faint focus:border-navy-600 focus:bg-white"
            />
          </label>

          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="rounded-lg border border-line bg-white px-3 py-2 text-sm font-medium text-navy-800 outline-none focus:border-navy-600"
          >
            <option value="All">All categories</option>
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>

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

        {selected.length > 0 && (
          <div className="flex flex-wrap items-center gap-3 border-b border-line bg-accent-50 px-4 py-3">
            <p className="text-sm font-semibold text-accent-700">
              {selected.length} selected
            </p>
            <div className="ml-auto flex gap-2">
              <Button
                size="sm"
                variant="secondary"
                disabled={busy}
                onClick={() => bulk({ status: "Live" })}
              >
                Publish
              </Button>
              <Button
                size="sm"
                variant="secondary"
                disabled={busy}
                onClick={() => bulk({ status: "Pending Review" })}
              >
                Unpublish
              </Button>
              <Button
                size="sm"
                variant="danger"
                disabled={busy}
                onClick={() => remove(selected, `${selected.length} machines`)}
              >
                Delete
              </Button>
            </div>
          </div>
        )}

        {catalogue.loading ? (
          <EmptyState
            title="Loading the catalogue…"
            message="Fetching every machine from the database."
          />
        ) : catalogue.error ? (
          <EmptyState
            title="Could not load products"
            message={catalogue.error}
          />
        ) : rows.length === 0 ? (
          <EmptyState
            title="No machines match"
            message="Try a different search term, category or status filter."
          />
        ) : (
          <Table>
            <thead>
              <tr>
                <Th className="w-10">
                  <input
                    type="checkbox"
                    checked={allShownSelected}
                    onChange={toggleAll}
                    aria-label="Select all"
                    className="h-4 w-4 rounded border-line accent-[#f97316]"
                  />
                </Th>
                <Th>Machine</Th>
                <Th>Category</Th>
                <Th>Seller</Th>
                <Th>Status</Th>
                <Th className="text-right">Price</Th>
                <Th className="text-right">Views</Th>
                <Th className="text-right">Listed</Th>
                <Th className="w-20 text-right">Actions</Th>
              </tr>
            </thead>
            <tbody>
              {rows.map((p) => (
                <tr key={p.id} className="hover:bg-canvas/60">
                  <Td>
                    <input
                      type="checkbox"
                      checked={selected.includes(p.id)}
                      onChange={() => toggle(p.id)}
                      aria-label={`Select ${p.title}`}
                      className="h-4 w-4 rounded border-line accent-[#f97316]"
                    />
                  </Td>
                  <Td>
                    <Link
                      href={`/products/${p.id}`}
                      className="group flex items-center gap-3"
                    >
                      <div className="relative h-11 w-14 shrink-0 overflow-hidden rounded-lg bg-navy-50">
                        {p.images[0] && (
                          <Image
                            src={p.images[0]}
                            alt={p.title}
                            fill
                            sizes="56px"
                            className="object-cover"
                          />
                        )}
                      </div>
                      <div className="min-w-0">
                        <p className="truncate font-bold text-navy-800 group-hover:text-accent-600">
                          {p.title}
                        </p>
                        <p className="truncate text-xs text-muted">
                          {p.id} · {p.year} · {p.type}
                        </p>
                      </div>
                    </Link>
                  </Td>
                  <Td className="whitespace-nowrap">
                    <Badge tone="navy">{p.category}</Badge>
                  </Td>
                  <Td className="whitespace-nowrap text-muted">{p.seller}</Td>
                  <Td>
                    <Badge tone={statusTone(p.status)} dot>
                      {p.status}
                    </Badge>
                  </Td>
                  <Td className="text-right font-bold whitespace-nowrap text-navy-800">
                    {rupees(p.price)}
                  </Td>
                  <Td className="text-right text-muted">{p.views}</Td>
                  <Td className="text-right text-xs whitespace-nowrap text-muted">
                    {shortDate(p.listedOn)}
                  </Td>
                  <Td className="text-right">
                    <div className="flex justify-end gap-1">
                      <Link
                        href={`/products/${p.id}`}
                        title="View"
                        className="grid h-8 w-8 place-items-center rounded-md text-muted hover:bg-navy-50 hover:text-navy-700"
                      >
                        <svg
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth={1.8}
                          className="h-4 w-4"
                        >
                          <path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z" />
                          <circle cx="12" cy="12" r="3" />
                        </svg>
                      </Link>
                      <Link
                        href={`/products/${p.id}/edit`}
                        title="Edit"
                        className="grid h-8 w-8 place-items-center rounded-md text-muted hover:bg-navy-50 hover:text-navy-700"
                      >
                        <svg
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth={1.8}
                          className="h-4 w-4"
                        >
                          <path d="M12 20h9M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z" />
                        </svg>
                      </Link>
                      <button
                        title="Delete"
                        disabled={busy}
                        onClick={() => remove([p.id], p.title)}
                        className="grid h-8 w-8 place-items-center rounded-md text-muted hover:bg-rose-50 hover:text-rose-600 disabled:opacity-50"
                      >
                        <svg
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth={1.8}
                          className="h-4 w-4"
                        >
                          <path d="M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6" />
                        </svg>
                      </button>
                    </div>
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        )}

        <div className="flex flex-wrap items-center justify-between gap-3 px-4 py-3 text-sm text-muted">
          <p>
            Showing <strong className="text-navy-800">{rows.length}</strong> of{" "}
            {all.length} machines
          </p>
          <div className="flex gap-1">
            <Button size="sm" variant="secondary" disabled>
              Previous
            </Button>
            <Button size="sm" variant="secondary" disabled>
              Next
            </Button>
          </div>
        </div>
      </Card>
    </>
  );
}
