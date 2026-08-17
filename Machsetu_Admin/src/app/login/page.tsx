"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { useAdminSession } from "@/components/AdminSession";
import { Button, cx } from "@/components/ui";

export default function AdminLoginPage() {
  const router = useRouter();
  const { signIn, token, ready } = useAdminSession();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [show, setShow] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  // Already signed in? Skip the form.
  useEffect(() => {
    if (ready && token) router.replace("/");
  }, [ready, token, router]);

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setError(null);
    setBusy(true);
    try {
      const response = await fetch("/api/admin/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });
      const data = await response.json();
      if (!response.ok || !data.ok) {
        setError(data.message ?? "Sign in failed");
        return;
      }
      signIn(data.token, data.admin);
      router.replace("/");
    } catch {
      setError("Could not reach the server. Is it running?");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="grid min-h-screen lg:grid-cols-2">
      {/* Brand panel */}
      <div className="relative hidden flex-col justify-between overflow-hidden bg-navy-900 p-10 text-white lg:flex">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0 opacity-30"
          style={{
            backgroundImage:
              "radial-gradient(600px circle at 20% 20%, #f97316 0%, transparent 55%), radial-gradient(700px circle at 80% 75%, #1a5490 0%, transparent 60%)",
          }}
        />
        <div className="relative flex items-center gap-3">
          <span className="grid h-11 w-11 place-items-center rounded-lg bg-accent-500 text-sm font-black">
            MS
          </span>
          <div className="leading-tight">
            <p className="text-sm font-extrabold tracking-wide">MACHSETU</p>
            <p className="text-[11px] text-white/50">Admin Console</p>
          </div>
        </div>

        <div className="relative max-w-md">
          <h2 className="text-3xl leading-tight font-extrabold">
            India&apos;s B2B marketplace for CNC &amp; VMC machines.
          </h2>
          <p className="mt-4 text-sm leading-relaxed text-white/60">
            Approve seller submissions, manage the catalogue and track every
            inquiry from one console.
          </p>
          <div className="mt-8 grid grid-cols-3 gap-4 border-t border-white/10 pt-6">
            {[
              ["15", "Listings"],
              ["12", "Users"],
              ["9", "Inquiries"],
            ].map(([value, label]) => (
              <div key={label}>
                <p className="text-2xl font-extrabold">{value}</p>
                <p className="text-[11px] tracking-wide text-white/45 uppercase">
                  {label}
                </p>
              </div>
            ))}
          </div>
        </div>

        <p className="relative text-[11px] text-white/35">
          © 2026 MachSetu Marketplace · ISO 27001 Certified
        </p>
      </div>

      {/* Form */}
      <div className="flex items-center justify-center bg-canvas px-5 py-12">
        <div className="w-full max-w-sm">
          <div className="mb-8 flex items-center gap-3 lg:hidden">
            <span className="grid h-10 w-10 place-items-center rounded-lg bg-accent-500 text-sm font-black text-white">
              MS
            </span>
            <p className="text-sm font-extrabold tracking-wide text-navy-800">
              MACHSETU
            </p>
          </div>

          <h1 className="text-2xl font-extrabold text-navy-800">
            Sign in to the console
          </h1>
          <p className="mt-1.5 text-sm text-muted">
            Admin access only. Seller and buyer accounts use the mobile app.
          </p>

          <form onSubmit={submit} className="mt-7 space-y-4">
            <label className="block">
              <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                Email address
              </span>
              <input
                type="email"
                autoComplete="username"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@machsetu.in"
                className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
              />
            </label>

            <label className="block">
              <span className="mb-1.5 block text-sm font-semibold text-navy-800">
                Password
              </span>
              <div className="relative">
                <input
                  type={show ? "text" : "password"}
                  autoComplete="current-password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full rounded-lg border border-line bg-white px-3 py-2.5 pr-16 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                />
                <button
                  type="button"
                  onClick={() => setShow(!show)}
                  className="absolute top-1/2 right-2 -translate-y-1/2 rounded px-2 py-1 text-xs font-semibold text-muted hover:bg-canvas"
                >
                  {show ? "Hide" : "Show"}
                </button>
              </div>
            </label>

            {error && (
              <p
                role="alert"
                className={cx(
                  "rounded-lg border border-rose-200 bg-rose-50 px-3 py-2.5",
                  "text-sm font-medium text-rose-700",
                )}
              >
                {error}
              </p>
            )}

            <Button type="submit" disabled={busy} className="w-full">
              {busy ? "Signing in…" : "Sign in"}
            </Button>
          </form>

          <p className="mt-6 text-center text-xs text-faint">
            Trouble signing in? Contact the platform owner.
          </p>
        </div>
      </div>
    </div>
  );
}
