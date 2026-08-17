"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAdminSession } from "./AdminSession";
import { cx } from "./ui";

const NAV = [
  {
    section: "Overview",
    items: [{ href: "/", label: "Dashboard", icon: IconGrid }],
  },
  {
    section: "Marketplace",
    items: [
      { href: "/products", label: "Products", icon: IconBox },
      { href: "/products/new", label: "Add Product", icon: IconPlus },
      { href: "/requests", label: "Sell Requests", icon: IconInbox, badge: 3 },
      { href: "/inquiries", label: "Inquiries", icon: IconChat, badge: 2 },
      { href: "/orders", label: "Orders", icon: IconTruck },
    ],
  },
  {
    section: "People",
    items: [{ href: "/users", label: "Users", icon: IconUsers }],
  },
  {
    section: "System",
    items: [{ href: "/settings", label: "Settings", icon: IconCog }],
  },
];

export function Sidebar({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = usePathname();
  const { admin } = useAdminSession();

  return (
    <div className="flex h-full flex-col bg-navy-900 text-white">
      <div className="flex items-center gap-3 px-5 py-5">
        <span className="grid h-10 w-10 place-items-center rounded-lg bg-accent-500 text-sm font-black">
          MS
        </span>
        <div className="leading-tight">
          <p className="text-sm font-extrabold tracking-wide">MACHSETU</p>
          <p className="text-[11px] text-white/50">Admin Console</p>
        </div>
      </div>

      <nav className="flex-1 space-y-6 overflow-y-auto px-3 pb-6">
        {NAV.map((group) => (
          <div key={group.section}>
            <p className="px-3 pb-2 text-[10px] font-bold tracking-[0.12em] text-white/35 uppercase">
              {group.section}
            </p>
            <ul className="space-y-1">
              {group.items.map((item) => {
                // "/" would otherwise prefix-match every route.
                const active =
                  item.href === "/"
                    ? pathname === "/"
                    : pathname === item.href ||
                      (pathname.startsWith(`${item.href}/`) &&
                        item.href !== "/products");
                const Icon = item.icon;

                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      onClick={onNavigate}
                      className={cx(
                        "group flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors",
                        active
                          ? "bg-accent-500 text-white"
                          : "text-white/70 hover:bg-white/10 hover:text-white",
                      )}
                    >
                      <Icon className="h-[18px] w-[18px] shrink-0" />
                      <span className="flex-1">{item.label}</span>
                      {"badge" in item && item.badge ? (
                        <span
                          className={cx(
                            "rounded-full px-2 py-0.5 text-[10px] font-bold",
                            active
                              ? "bg-white/25 text-white"
                              : "bg-accent-500 text-white",
                          )}
                        >
                          {item.badge}
                        </span>
                      ) : null}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </nav>

      <div className="border-t border-white/10 p-4">
        <div className="flex items-center gap-3">
          <span className="grid h-9 w-9 place-items-center rounded-full bg-white/15 text-xs font-bold">
            AD
          </span>
          <div className="min-w-0 flex-1 leading-tight">
            <p className="truncate text-sm font-semibold">
              {admin?.name ?? "Admin"}
            </p>
            <p className="truncate text-[11px] text-white/50">
              {admin?.email ?? ""}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------------- icons -- */
/* Inline so the panel ships without an icon dependency. */

type IconProps = { className?: string };

function base(className?: string) {
  return {
    className,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };
}

function IconGrid({ className }: IconProps) {
  return (
    <svg {...base(className)}>
      <rect x="3" y="3" width="7" height="7" rx="1.5" />
      <rect x="14" y="3" width="7" height="7" rx="1.5" />
      <rect x="3" y="14" width="7" height="7" rx="1.5" />
      <rect x="14" y="14" width="7" height="7" rx="1.5" />
    </svg>
  );
}

function IconBox({ className }: IconProps) {
  return (
    <svg {...base(className)}>
      <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
      <path d="m3.3 7 8.7 5 8.7-5M12 22V12" />
    </svg>
  );
}

function IconPlus({ className }: IconProps) {
  return (
    <svg {...base(className)}>
      <circle cx="12" cy="12" r="9" />
      <path d="M12 8v8M8 12h8" />
    </svg>
  );
}

function IconInbox({ className }: IconProps) {
  return (
    <svg {...base(className)}>
      <path d="M22 12h-6l-2 3h-4l-2-3H2" />
      <path d="M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z" />
    </svg>
  );
}

function IconChat({ className }: IconProps) {
  return (
    <svg {...base(className)}>
      <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
    </svg>
  );
}

function IconTruck({ className }: IconProps) {
  return (
    <svg {...base(className)}>
      <path d="M14 17V5a1 1 0 0 0-1-1H2a1 1 0 0 0-1 1v11a1 1 0 0 0 1 1h2" />
      <path d="M14 8h4l4 4v4a1 1 0 0 1-1 1h-1" />
      <circle cx="7" cy="18" r="2" />
      <circle cx="17" cy="18" r="2" />
    </svg>
  );
}

function IconUsers({ className }: IconProps) {
  return (
    <svg {...base(className)}>
      <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  );
}

function IconCog({ className }: IconProps) {
  return (
    <svg {...base(className)}>
      <circle cx="12" cy="12" r="3" />
      <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.6a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
    </svg>
  );
}
