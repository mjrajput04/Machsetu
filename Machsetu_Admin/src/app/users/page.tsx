"use client";

import { useMemo, useState } from "react";
import { USERS, type UserRole, type UserStatus } from "@/lib/data";
import { shortDate } from "@/lib/format";
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

const ROLES: Array<UserRole | "All"> = [
  "All",
  "Buyer",
  "Seller",
  "Both",
  "Broker",
];
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

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return USERS.filter((u) => {
      if (role !== "All" && u.role !== role) return false;
      if (status !== "All" && u.status !== status) return false;
      if (!q) return true;
      return [u.name, u.company, u.email, u.city, u.gstin, u.id]
        .join(" ")
        .toLowerCase()
        .includes(q);
    });
  }, [query, role, status]);

  const counts = {
    total: USERS.length,
    sellers: USERS.filter((u) => u.role === "Seller" || u.role === "Both")
      .length,
    buyers: USERS.filter((u) => u.role === "Buyer" || u.role === "Both").length,
    pending: USERS.filter((u) => u.status === "Pending KYC").length,
  };

  return (
    <>
      <PageHeader
        title="Users"
        subtitle="Buyers, sellers and brokers registered on the marketplace."
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
          {
            label: "Pending KYC",
            value: counts.pending,
            tone: "warning" as const,
          },
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
              placeholder="Search by name, company, email or GSTIN…"
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

        {rows.length === 0 ? (
          <EmptyState
            title="No users match"
            message="Adjust the search term, role or status filter."
          />
        ) : (
          <Table>
            <thead>
              <tr>
                <Th>User</Th>
                <Th>Contact</Th>
                <Th>Role</Th>
                <Th>Status</Th>
                <Th>GSTIN</Th>
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
                    <div className="flex items-center gap-3">
                      <Avatar name={u.name} />
                      <div className="min-w-0">
                        <p className="truncate font-bold text-navy-800">
                          {u.name}
                        </p>
                        <p className="truncate text-xs text-muted">
                          {u.company}
                        </p>
                      </div>
                    </div>
                  </Td>
                  <Td>
                    <p className="whitespace-nowrap text-ink">{u.email}</p>
                    <p className="text-xs whitespace-nowrap text-muted">
                      {u.phone} · {u.city}
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
                  </Td>
                  <Td className="font-mono text-xs whitespace-nowrap text-muted">
                    {u.gstin}
                  </Td>
                  <Td className="text-right font-semibold">{u.listings}</Td>
                  <Td className="text-right font-semibold">{u.orders}</Td>
                  <Td className="text-right text-xs whitespace-nowrap text-muted">
                    {shortDate(u.joinedOn)}
                  </Td>
                  <Td className="text-right">
                    <div className="flex justify-end gap-1.5">
                      <Button size="sm" variant="secondary">
                        View
                      </Button>
                      <Button size="sm" variant="danger">
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
          {USERS.length} users
        </div>
      </Card>
    </>
  );
}
