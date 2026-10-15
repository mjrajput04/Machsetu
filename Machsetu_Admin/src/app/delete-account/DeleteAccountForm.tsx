"use client";

import { useState } from "react";
import { Button } from "@/components/ui";

const inputClass =
  "w-full rounded-lg border border-line bg-white px-3.5 py-2.5 text-[15px] outline-none placeholder:text-faint focus:border-navy-600";

/** Email-or-mobile plus password, then an explicit confirmation tick. */
export function DeleteAccountForm() {
  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [confirmed, setConfirmed] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setError(null);
    setBusy(true);
    try {
      const response = await fetch("/api/account/delete", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ identifier, password }),
      });
      const data = await response.json();
      if (!response.ok || !data.ok) {
        setError(data.message ?? "Could not delete the account");
        return;
      }
      setDone(true);
    } catch {
      setError("Could not reach the server. Please try again.");
    } finally {
      setBusy(false);
    }
  }

  if (done) {
    return (
      <div className="rounded-xl border border-emerald-200 bg-emerald-50 p-5">
        <p className="font-bold text-emerald-800">Your account has been deleted.</p>
        <p className="mt-1 text-sm text-emerald-700">
          Your personal data has been removed from MachSetu. You can uninstall
          the app. Thank you for using MachSetu.
        </p>
      </div>
    );
  }

  return (
    <form
      onSubmit={submit}
      className="space-y-4 rounded-xl border border-line bg-white p-5"
    >
      <label className="block">
        <span className="mb-1.5 block text-sm font-semibold text-navy-800">
          Email or mobile number
        </span>
        <input
          className={inputClass}
          value={identifier}
          onChange={(e) => setIdentifier(e.target.value)}
          autoComplete="username"
          placeholder="you@company.com or 98765 43210"
          required
        />
      </label>

      <label className="block">
        <span className="mb-1.5 block text-sm font-semibold text-navy-800">
          Password
        </span>
        <input
          className={inputClass}
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          autoComplete="current-password"
          required
        />
      </label>

      <label className="flex items-start gap-2.5 text-sm text-ink">
        <input
          type="checkbox"
          checked={confirmed}
          onChange={(e) => setConfirmed(e.target.checked)}
          className="mt-0.5 h-4 w-4 accent-rose-600"
        />
        <span>
          I understand my account and data will be permanently deleted and
          cannot be recovered.
        </span>
      </label>

      {error && (
        <p className="rounded-lg bg-rose-50 px-3 py-2 text-sm font-medium text-rose-700">
          {error}
        </p>
      )}

      <Button
        type="submit"
        variant="danger"
        disabled={!confirmed || busy}
        className="w-full"
      >
        {busy ? "Deleting…" : "Permanently delete my account"}
      </Button>
    </form>
  );
}
