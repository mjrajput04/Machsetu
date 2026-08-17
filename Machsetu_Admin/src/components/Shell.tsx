"use client";

import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState, type ReactNode } from "react";
import { useAdminSession } from "./AdminSession";
import { Sidebar } from "./Sidebar";

/**
 * App frame: a fixed sidebar on desktop, a slide-over on mobile, and a
 * sticky top bar with search and notifications.
 */
export function Shell({ children }: { children: ReactNode }) {
  const [drawerOpen, setDrawerOpen] = useState(false);
  const { token, admin, ready, signOut } = useAdminSession();
  const pathname = usePathname();
  const router = useRouter();

  const isLogin = pathname === "/login";

  // Bounce straight to the sign-in page when there is no session.
  useEffect(() => {
    if (ready && !token && !isLogin) router.replace("/login");
  }, [ready, token, isLogin, router]);

  // The login page paints its own full-screen layout.
  if (isLogin) return <>{children}</>;

  if (!ready || !token) {
    return (
      <div className="grid min-h-screen place-items-center bg-canvas">
        <p className="text-sm font-semibold text-muted">Loading console…</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen lg:flex">
      <aside className="hidden w-64 shrink-0 lg:fixed lg:inset-y-0 lg:flex lg:flex-col">
        <Sidebar />
      </aside>

      {drawerOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          <button
            aria-label="Close navigation"
            className="absolute inset-0 bg-navy-950/50"
            onClick={() => setDrawerOpen(false)}
          />
          <div className="absolute inset-y-0 left-0 w-64 shadow-xl">
            <Sidebar onNavigate={() => setDrawerOpen(false)} />
          </div>
        </div>
      )}

      <div className="flex min-w-0 flex-1 flex-col lg:pl-64">
        <header className="sticky top-0 z-30 border-b border-line bg-white/85 backdrop-blur">
          <div className="flex items-center gap-3 px-4 py-3 sm:px-6">
            <button
              aria-label="Open navigation"
              onClick={() => setDrawerOpen(true)}
              className="grid h-9 w-9 place-items-center rounded-lg text-navy-800 hover:bg-slate-100 lg:hidden"
            >
              <svg
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth={1.8}
                strokeLinecap="round"
                className="h-5 w-5"
              >
                <path d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>

            <label className="relative hidden max-w-md flex-1 sm:block">
              <span className="sr-only">Search</span>
              <svg
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth={1.8}
                strokeLinecap="round"
                className="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-faint"
              >
                <circle cx="11" cy="11" r="7" />
                <path d="m20 20-3.5-3.5" />
              </svg>
              <input
                type="search"
                placeholder="Search machines, users, orders…"
                className="w-full rounded-lg border border-line bg-canvas py-2 pr-3 pl-9 text-sm outline-none placeholder:text-faint focus:border-navy-600 focus:bg-white"
              />
            </label>

            <div className="ml-auto flex items-center gap-2">
              <button
                aria-label="Notifications"
                className="relative grid h-9 w-9 place-items-center rounded-lg text-navy-800 hover:bg-slate-100"
              >
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={1.8}
                  strokeLinecap="round"
                  className="h-5 w-5"
                >
                  <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
                  <path d="M13.7 21a2 2 0 0 1-3.4 0" />
                </svg>
                <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full bg-accent-500 ring-2 ring-white" />
              </button>

              <div className="flex items-center gap-2.5 rounded-lg py-1 pr-2 pl-1">
                <span className="grid h-8 w-8 place-items-center rounded-full bg-navy-800 text-[11px] font-bold text-white">
                  {(admin?.name ?? "AD")
                    .split(/\s+/)
                    .slice(0, 2)
                    .map((part) => part[0])
                    .join("")
                    .toUpperCase()}
                </span>
                <div className="hidden leading-tight sm:block">
                  <p className="text-xs font-semibold text-navy-800">
                    {admin?.name ?? "Admin"}
                  </p>
                  <p className="text-[11px] text-muted">{admin?.role}</p>
                </div>
              </div>

              <button
                onClick={signOut}
                title="Sign out"
                className="grid h-9 w-9 place-items-center rounded-lg text-muted hover:bg-rose-50 hover:text-rose-600"
              >
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={1.8}
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className="h-5 w-5"
                >
                  <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9" />
                </svg>
              </button>
            </div>
          </div>
        </header>

        <main className="flex-1 px-4 py-6 sm:px-6 lg:px-8">{children}</main>

        <footer className="border-t border-line px-4 py-4 text-xs text-faint sm:px-6 lg:px-8">
          © 2026 MachSetu Marketplace · Admin Console v1.0 · Frontend preview
          with mock data
        </footer>
      </div>
    </div>
  );
}
