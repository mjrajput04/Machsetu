"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { use, useRef, useState } from "react";
import { api, useApi } from "@/lib/api";
import type { AdminUser } from "@/lib/types";
import { relativeDate, shortDate } from "@/lib/format";
import { BackLink } from "@/components/record";
import {
  Avatar,
  Badge,
  Button,
  Card,
  CardHeader,
  EmptyState,
  PageHeader,
  statusTone,
} from "@/components/ui";

const ROLES = ["Buyer", "Seller", "Both", "Broker"] as const;
const STATUSES = ["Active", "Pending KYC", "Suspended"] as const;

/** Editable half of the account — mirrors the app's Edit Profile screen. */
const FIELDS: Array<[keyof AdminUser, string, string]> = [
  ["name", "Full Name", "Rajesh Kumar"],
  ["designation", "Designation", "Purchase Manager"],
  ["company", "Company Name", "Apex Engineering Works"],
  ["email", "Email Address", "you@company.com"],
  ["phone", "Mobile Number", "98765 43210"],
  ["gstin", "GST Number", "27AABCA9021M1Z8"],
  ["pan", "PAN Number", "AABCA9021M"],
  ["address", "Address", "Plot 18, MIDC Phase II"],
  ["city", "City", "Pune"],
  ["state", "State", "Maharashtra"],
  ["pincode", "Pincode", "411019"],
];

export default function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const router = useRouter();

  const record = useApi<{ user: AdminUser }>(`/api/admin/users/${id}`);
  const user = record.data?.user;

  // Only the touched fields are held in state; the rest comes off the record,
  // so a reload shows fresh values without an effect to copy them across.
  const [edits, setEdits] = useState<Partial<AdminUser>>({});
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const [uploading, setUploading] = useState(false);
  const picker = useRef<HTMLInputElement>(null);

  const draft: Partial<AdminUser> = { ...user, ...edits };

  function set(key: keyof AdminUser, value: string | boolean) {
    setEdits((prev) => ({ ...prev, [key]: value }));
    setSaved(false);
  }

  /** Profile photo, shown on the account and in the app's profile screen. */
  async function pickAvatar(files: FileList | null) {
    if (!files?.length) return;
    setUploading(true);
    setError(null);
    try {
      const result = await api.upload([files[0]]);
      set("avatar", result.files[0].url);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setUploading(false);
      if (picker.current) picker.current.value = "";
    }
  }

  async function save() {
    setSaving(true);
    setError(null);
    try {
      const patch = Object.fromEntries(
        FIELDS.map(([key]) => [key, draft[key] ?? ""]),
      );
      await api.put(`/api/admin/users/${id}`, {
        ...patch,
        avatar: draft.avatar ?? "",
        role: draft.role,
        status: draft.status,
        phoneVerified: draft.phoneVerified,
      });
      setEdits({});
      record.reload();
      setSaved(true);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setSaving(false);
    }
  }

  async function remove() {
    if (
      !window.confirm(
        `Delete ${user?.name}? Their account and sign-in are removed for good.`,
      )
    ) {
      return;
    }
    setSaving(true);
    try {
      await api.del(`/api/admin/users/${id}`);
      router.push("/users");
    } catch (err) {
      setError((err as Error).message);
      setSaving(false);
    }
  }

  if (!user) {
    return (
      <>
        <BackLink href="/users" label="Back to Users" />
        <Card>
          <EmptyState
            title={record.loading ? "Loading account…" : "User not found"}
            message={record.error ?? `No account is filed under ${id}.`}
          />
        </Card>
      </>
    );
  }

  return (
    <>
      <BackLink href="/users" label="Back to Users" />

      <PageHeader
        title={user.name}
        subtitle={`${user.id} · joined ${shortDate(user.joinedOn)}${
          user.lastLoginAt ? ` · last login ${relativeDate(user.lastLoginAt)}` : ""
        }`}
        actions={
          <>
            <Button variant="secondary" disabled={saving} onClick={save}>
              {saving ? "Saving…" : saved ? "Saved" : "Save changes"}
            </Button>
            <Button variant="danger" disabled={saving} onClick={remove}>
              Delete account
            </Button>
          </>
        }
      />

      {error && (
        <div className="mb-4 rounded-lg border border-rose-200 bg-rose-50 px-4 py-3 text-sm font-semibold text-rose-700">
          {error}
        </div>
      )}

      <div className="grid gap-4 xl:grid-cols-3">
        <div className="space-y-4 xl:col-span-2">
          <Card>
            <CardHeader
              title="Profile & address"
              subtitle="Every field the seller edits in the app — editable here too"
            />
            <div className="grid gap-4 sm:grid-cols-2">
              {FIELDS.map(([key, label, placeholder]) => (
                <div
                  key={key}
                  className={key === "address" ? "sm:col-span-2" : undefined}
                >
                  <label className="block">
                    <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                      {label}
                    </span>
                    <input
                      value={String(draft[key] ?? "")}
                      placeholder={placeholder}
                      onChange={(e) => set(key, e.target.value)}
                      className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                    />
                  </label>
                </div>
              ))}
            </div>
          </Card>

          <Card>
            <CardHeader
              title="Account controls"
              subtitle="Role, verification and access"
            />
            <div className="grid gap-4 sm:grid-cols-2">
              <label className="block">
                <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                  Role
                </span>
                <select
                  value={draft.role ?? user.role}
                  onChange={(e) => set("role", e.target.value)}
                  className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
                >
                  {ROLES.map((r) => (
                    <option key={r}>{r}</option>
                  ))}
                </select>
              </label>
              <label className="block">
                <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                  Account status
                </span>
                <select
                  value={draft.status ?? user.status}
                  onChange={(e) => set("status", e.target.value)}
                  className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
                >
                  {STATUSES.map((s) => (
                    <option key={s}>{s}</option>
                  ))}
                </select>
              </label>
              <label className="flex items-center gap-2.5 rounded-lg border border-line bg-white px-3 py-2.5 text-sm sm:col-span-2">
                <input
                  type="checkbox"
                  checked={Boolean(draft.phoneVerified)}
                  onChange={(e) => set("phoneVerified", e.target.checked)}
                  className="h-4 w-4 rounded border-line accent-[#f97316]"
                />
                Mobile number verified — an unverified account cannot sign in
              </label>
            </div>
          </Card>
        </div>

        <div className="space-y-4">
          <Card>
            <input
              ref={picker}
              type="file"
              accept="image/*"
              hidden
              onChange={(e) => pickAvatar(e.target.files)}
            />
            <div className="flex items-center gap-3">
              {draft.avatar ? (
                <div className="relative h-11 w-11 shrink-0 overflow-hidden rounded-full bg-navy-50">
                  <Image
                    src={draft.avatar}
                    alt={user.name}
                    fill
                    sizes="44px"
                    className="object-cover"
                  />
                </div>
              ) : (
                <Avatar name={user.name} />
              )}
              <div className="min-w-0 flex-1">
                <p className="truncate font-bold text-navy-800">{user.name}</p>
                <p className="truncate text-xs text-muted">
                  {user.designation || "—"}
                </p>
              </div>
              <div className="flex shrink-0 gap-1">
                <Button
                  size="sm"
                  variant="ghost"
                  disabled={uploading}
                  onClick={() => picker.current?.click()}
                >
                  {uploading ? "Uploading…" : "Photo"}
                </Button>
                {draft.avatar && (
                  <Button
                    size="sm"
                    variant="ghost"
                    onClick={() => set("avatar", "")}
                  >
                    Clear
                  </Button>
                )}
              </div>
            </div>
            <div className="mt-4 flex flex-wrap gap-2">
              <Badge tone={statusTone(user.status)} dot>
                {user.status}
              </Badge>
              <Badge tone={user.role === "Broker" ? "accent" : "navy"}>
                {user.role}
              </Badge>
              <Badge tone={user.phoneVerified ? "success" : "warning"}>
                {user.phoneVerified ? "Verified" : "Unverified"}
              </Badge>
            </div>
            <dl className="mt-4 divide-y divide-line/70">
              {[
                ["Account ID", user.id],
                ["Listings", String(user.listings ?? 0)],
                ["Orders", String(user.orders ?? 0)],
                ["Joined", shortDate(user.joinedOn)],
                [
                  "Last login",
                  user.lastLoginAt ? relativeDate(user.lastLoginAt) : "Never",
                ],
              ].map(([label, value]) => (
                <div
                  key={label}
                  className="flex items-center justify-between gap-4 py-2.5"
                >
                  <dt className="text-sm text-muted">{label}</dt>
                  <dd className="text-sm font-semibold text-navy-800">
                    {value}
                  </dd>
                </div>
              ))}
            </dl>
          </Card>

          <Card>
            <CardHeader
              title="Security"
              subtitle="Set by the account holder in the app"
            />
            <dl className="divide-y divide-line/70">
              {[
                ["Two-factor authentication", user.twoFactor],
                ["Biometric unlock", user.biometrics],
                ["Login alerts", user.loginAlerts],
              ].map(([label, on]) => (
                <div
                  key={String(label)}
                  className="flex items-center justify-between gap-4 py-2.5"
                >
                  <dt className="text-sm text-muted">{label}</dt>
                  <dd>
                    <Badge tone={on ? "success" : "neutral"}>
                      {on ? "On" : "Off"}
                    </Badge>
                  </dd>
                </div>
              ))}
            </dl>
          </Card>
        </div>
      </div>
    </>
  );
}
