"use client";

import { useMemo, useState } from "react";
import { api, useApi } from "@/lib/api";
import { relativeDate } from "@/lib/format";
import {
  Avatar,
  Badge,
  Button,
  Card,
  EmptyState,
  PageHeader,
  cx,
  statusTone,
} from "@/components/ui";

interface ContactMessage {
  id: string;
  name: string;
  company: string;
  email: string;
  phone: string;
  topic: string;
  message: string;
  status: "New" | "Read";
  createdAt: string;
}

const FILTERS = ["All", "New", "Read"] as const;

export default function MessagesPage() {
  const inbox = useApi<{ messages: ContactMessage[] }>("/api/admin/messages");
  const all = useMemo(() => inbox.data?.messages ?? [], [inbox.data]);
  const [filter, setFilter] = useState<(typeof FILTERS)[number]>("All");
  const [busy, setBusy] = useState<string | null>(null);

  const rows = all.filter((m) => filter === "All" || m.status === filter);
  const unread = all.filter((m) => m.status === "New").length;

  async function setStatus(message: ContactMessage, status: "New" | "Read") {
    setBusy(message.id);
    try {
      await api.put(`/api/admin/messages/${message.id}`, { status });
      inbox.set({
        messages: all.map((m) => (m.id === message.id ? { ...m, status } : m)),
      });
    } catch (err) {
      window.alert((err as Error).message);
    } finally {
      setBusy(null);
    }
  }

  async function remove(message: ContactMessage) {
    if (!window.confirm(`Delete the message from ${message.name}?`)) return;
    setBusy(message.id);
    try {
      await api.del(`/api/admin/messages/${message.id}`);
      inbox.set({ messages: all.filter((m) => m.id !== message.id) });
    } catch (err) {
      window.alert((err as Error).message);
    } finally {
      setBusy(null);
    }
  }

  return (
    <>
      <PageHeader
        title="Website Messages"
        subtitle={`Sent from the contact page on machsetu.com · ${unread} unread`}
      />

      <div className="mb-4 flex gap-2">
        {FILTERS.map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={cx(
              "rounded-full px-3.5 py-1.5 text-xs font-semibold transition-colors",
              filter === f
                ? "bg-navy-800 text-white"
                : "bg-white text-muted ring-1 ring-line ring-inset hover:text-navy-800",
            )}
          >
            {f}
          </button>
        ))}
      </div>

      {inbox.loading ? (
        <Card>
          <p className="text-sm text-muted">Loading messages…</p>
        </Card>
      ) : inbox.error ? (
        <Card>
          <p className="text-sm text-rose-600">{inbox.error}</p>
        </Card>
      ) : rows.length === 0 ? (
        <Card padded={false}>
          <EmptyState
            title="No messages yet"
            message="When someone fills in the contact form on the website, it shows up here."
          />
        </Card>
      ) : (
        <div className="space-y-3">
          {rows.map((m) => (
            <Card
              key={m.id}
              className={cx(m.status === "New" && "border-l-4 border-l-accent-500")}
            >
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div className="flex min-w-0 items-start gap-3">
                  <Avatar name={m.name} tone={m.status === "New" ? "accent" : "navy"} />
                  <div className="min-w-0">
                    <p className="font-bold text-navy-800">
                      {m.name}
                      {m.company && (
                        <span className="font-medium text-muted"> · {m.company}</span>
                      )}
                    </p>
                    <p className="mt-0.5 text-sm text-muted">
                      <a href={`mailto:${m.email}`} className="hover:text-navy-700">
                        {m.email}
                      </a>
                      {m.phone && (
                        <>
                          {" · "}
                          <a href={`tel:+91${m.phone}`} className="hover:text-navy-700">
                            +91 {m.phone}
                          </a>
                        </>
                      )}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Badge tone="navy">{m.topic}</Badge>
                  <Badge tone={statusTone(m.status)} dot>
                    {m.status}
                  </Badge>
                  <span className="text-xs text-faint">{relativeDate(m.createdAt)}</span>
                </div>
              </div>

              <p className="mt-4 text-sm leading-relaxed whitespace-pre-line text-ink">
                {m.message}
              </p>

              <div className="mt-4 flex flex-wrap gap-2">
                <a
                  href={`mailto:${m.email}?subject=${encodeURIComponent("Re: your message to MachSetu")}`}
                  className="inline-flex items-center rounded-lg bg-accent-500 px-3 py-1.5 text-xs font-semibold text-white hover:bg-accent-600"
                >
                  Reply by email
                </a>
                <Button
                  size="sm"
                  variant="secondary"
                  disabled={busy === m.id}
                  onClick={() => setStatus(m, m.status === "New" ? "Read" : "New")}
                >
                  Mark as {m.status === "New" ? "read" : "unread"}
                </Button>
                <Button
                  size="sm"
                  variant="danger"
                  disabled={busy === m.id}
                  onClick={() => remove(m)}
                >
                  Delete
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </>
  );
}
