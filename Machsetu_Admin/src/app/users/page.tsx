"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { api, useApi } from "@/lib/api";
import type { AdminUser, UserRole, UserStatus } from "@/lib/types";
import { relativeDate, shortDate } from "@/lib/format";
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

const ROLES: Array<UserRole | "All"> = ["All", "Buyer", "Seller", "Both", "Broker"];
const STATUSES: Array<UserStatus | "All"> = [
  "All",
  "Active",
  "Pending KYC",
  "Suspended",
];

export default function UsersPage() {
  const [query, setQuery] = useState("");
  const [role, setRole] = useState<UserRole | "All">("All");
  const [status, setStatus] = useState<UserStatus | "All">("All");
  const [busy, setBusy] = useState(false);

  const accounts = useApi<{ users: AdminUser[] }>("/api/admin/users");
  const all = useMemo(() => accounts.data?.users ?? [], [accounts.data]);
  const { loading, error } = accounts;

  /** Suspend / restore straight from the row. */
  async function setAccountStatus(user: AdminUser) {
    const next = user.status === "Suspended" ? "Active" : "Suspended";
    setBusy(true);
    try {
      await api.put(`/api/admin/users/${user.id}`, { status: next });
      accounts.reload();
    } catch (err) {
      window.alert((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return all.filter((u) => {
      if (role !== "All" && u.role !== role) return false;
      if (status !== "All" && u.status !== status) return false;
      if (!q) return true;
      return [u.name, u.company, u.email, u.phone, u.city, u.gstin, u.pan, u.id]
        .join(" ")
        .toLowerCase()
        .includes(q);
    });
  }, [all, query, role, status]);

  const counts = {
    total: all.length,
    sellers: all.filter((u) => u.role === "Seller" || u.role === "Both").length,
    buyers: all.filter((u) => u.role === "Buyer" || u.role === "Both").length,
    pending: all.filter((u) => u.status === "Pending KYC").length,
  };

  return (
    <>
      <PageHeader
        title="Users"
        subtitle="Live accounts registered through the MachSetu mobile app."
        actions={
          <>
            <Button variant="secondary">Export list</Button>
            <Button>Invite user</Button>
          </>
        }
      />

      <div className="mb-4 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {[
          { label: "Total users", value: counts.total, tone: "navy" as const },
          { label: "Sellers", value: counts.sellers, tone: "accent" as const },
          { label: "Buyers", value: counts.buyers, tone: "info" as const },
          { label: "Pending KYC", value: counts.pending, tone: "warning" as const },
        ].map((s) => (
          <Card key={s.label}>
            <div className="flex items-center justify-between">
              <p className="text-xs font-bold tracking-wide text-muted uppercase">
                {s.label}
              </p>
              <Badge tone={s.tone}>{s.value}</Badge>
            </div>
            <p className="mt-2 text-3xl font-extrabold text-navy-800">
              {s.value}
            </p>
          </Card>
        ))}
      </div>

      <Card padded={false}>
        <div className="flex flex-wrap items-center gap-3 border-b border-line p-4">
          <label className="relative min-w-[220px] flex-1">
            <span className="sr-only">Search users</span>
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search by name, company, email, mobile or GSTIN…"
              className="w-full rounded-lg border border-line bg-canvas px-3 py-2 text-sm outline-none placeholder:text-faint focus:border-navy-600 focus:bg-white"
            />
          </label>

          <select
            value={role}
            onChange={(e) => setRole(e.target.value as UserRole | "All")}
            className="rounded-lg border border-line bg-white px-3 py-2 text-sm font-medium text-navy-800 outline-none focus:border-navy-600"
          >
            {ROLES.map((r) => (
              <option key={r} value={r}>
                {r === "All" ? "All roles" : r}
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

        {loading ? (
          <EmptyState title="Loading…" message="Fetching users from MongoDB." />
        ) : error ? (
          <EmptyState title="Could not load users" message={error} />
        ) : rows.length === 0 ? (
          <EmptyState
            title={all.length === 0 ? "No users yet" : "No users match"}
            message={
              all.length === 0
                ? "Register an account in the mobile app and it will appear here."
                : "Adjust the search term, role or status filter."
            }
          />
        ) : (
          <Table>
            <thead>
              <tr>
                <Th>User</Th>
                <Th>Contact</Th>
                <Th>Role</Th>
                <Th>Status</Th>
                <Th>GSTIN / PAN</Th>
                <Th className="text-right">Listings</Th>
                <Th className="text-right">Orders</Th>
                <Th className="text-right">Joined</Th>
                <Th className="w-24 text-right">Actions</Th>
              </tr>
            </thead>
            <tbody>
              {rows.map((u) => (
                <tr key={u.id} className="hover:bg-canvas/60">
                  <Td>
                    <Link
                      href={`/users/${u.id}`}
                      className="group flex items-center gap-3"
                    >
                      <Avatar name={u.name} />
                      <div className="min-w-0">
                        <p className="truncate font-bold text-navy-800 group-hover:text-accent-600">
                          {u.name}
                        </p>
                        <p className="truncate text-xs text-muted">
                          {u.designation || "—"}
                        </p>
                        <p className="truncate text-xs text-faint">
                          {u.company || u.id}
                        </p>
                      </div>
                    </Link>
                  </Td>
                  <Td>
                    <p className="whitespace-nowrap text-ink">{u.email}</p>
                    <p className="text-xs whitespace-nowrap text-muted">
                      +91 {u.phone}
                      {u.phoneVerified ? (
                        <span className="ml-1.5 font-semibold text-emerald-600">
                          ✓ verified
                        </span>
                      ) : (
                        <span className="ml-1.5 font-semibold text-amber-600">
                          unverified
                        </span>
                      )}
                    </p>
                    <p className="text-xs text-faint">
                      {[u.address, u.city, u.state, u.pincode]
                        .filter(Boolean)
                        .join(", ") || "No address on file"}
                    </p>
                  </Td>
                  <Td>
                    <Badge tone={u.role === "Broker" ? "accent" : "navy"}>
                      {u.role}
                    </Badge>
                  </Td>
                  <Td>
                    <Badge tone={statusTone(u.status)} dot>
                      {u.status}
                    </Badge>
                    {u.lastLoginAt && (
                      <p className="mt-1 text-[11px] text-faint">
                        Last login {relativeDate(u.lastLoginAt)}
                      </p>
                    )}
                  </Td>
                  <Td className="font-mono text-xs whitespace-nowrap text-muted">
                    {u.gstin || "—"}
                    <span className="block text-faint">{u.pan || "—"}</span>
                  </Td>
                  <Td className="text-right font-semibold">{u.listings}</Td>
                  <Td className="text-right font-semibold">{u.orders}</Td>
                  <Td className="text-right text-xs whitespace-nowrap text-muted">
                    {shortDate(u.joinedOn)}
                  </Td>
                  <Td className="text-right">
                    <div className="flex justify-end gap-1.5">
                      <Link href={`/users/${u.id}`}>
                        <Button size="sm" variant="secondary">
                          View
                        </Button>
                      </Link>
                      <Button
                        size="sm"
                        variant="danger"
                        disabled={busy}
                        onClick={() => setAccountStatus(u)}
                      >
                        {u.status === "Suspended" ? "Restore" : "Suspend"}
                      </Button>
                    </div>
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        )}

        <div className="px-4 py-3 text-sm text-muted">
          Showing <strong className="text-navy-800">{rows.length}</strong> of{" "}
          {all.length} users · live from MongoDB
        </div>
      </Card>
    </>
  );
}
