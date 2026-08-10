import type { ReactNode } from "react";

/** Tailwind class merge that keeps the call sites readable. */
export function cx(...parts: Array<string | false | null | undefined>) {
  return parts.filter(Boolean).join(" ");
}

export function Card({
  children,
  className,
  padded = true,
}: {
  children: ReactNode;
  className?: string;
  padded?: boolean;
}) {
  return (
    <section
      className={cx(
        "rounded-xl border border-line bg-white shadow-[0_1px_2px_rgba(14,46,92,0.04)]",
        padded && "p-5",
        className,
      )}
    >
      {children}
    </section>
  );
}

export function CardHeader({
  title,
  subtitle,
  action,
}: {
  title: string;
  subtitle?: string;
  action?: ReactNode;
}) {
  return (
    <header className="mb-4 flex items-start justify-between gap-4">
      <div>
        <h2 className="text-base font-bold text-navy-800">{title}</h2>
        {subtitle && <p className="mt-0.5 text-sm text-muted">{subtitle}</p>}
      </div>
      {action}
    </header>
  );
}

export function PageHeader({
  title,
  subtitle,
  actions,
}: {
  title: string;
  subtitle: string;
  actions?: ReactNode;
}) {
  return (
    <header className="mb-6 flex flex-wrap items-end justify-between gap-4">
      <div>
        <h1 className="text-2xl font-extrabold tracking-tight text-navy-800">
          {title}
        </h1>
        <p className="mt-1 text-sm text-muted">{subtitle}</p>
      </div>
      {actions && <div className="flex flex-wrap gap-2">{actions}</div>}
    </header>
  );
}

type Tone =
  | "neutral"
  | "navy"
  | "accent"
  | "success"
  | "danger"
  | "warning"
  | "info";

const TONES: Record<Tone, string> = {
  neutral: "bg-slate-100 text-slate-600 ring-slate-200",
  navy: "bg-navy-50 text-navy-700 ring-navy-100",
  accent: "bg-accent-50 text-accent-700 ring-accent-100",
  success: "bg-emerald-50 text-emerald-700 ring-emerald-100",
  danger: "bg-rose-50 text-rose-700 ring-rose-100",
  warning: "bg-amber-50 text-amber-700 ring-amber-100",
  info: "bg-sky-50 text-sky-700 ring-sky-100",
};

export function Badge({
  children,
  tone = "neutral",
  dot = false,
}: {
  children: ReactNode;
  tone?: Tone;
  dot?: boolean;
}) {
  return (
    <span
      className={cx(
        "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset whitespace-nowrap",
        TONES[tone],
      )}
    >
      {dot && <span className="h-1.5 w-1.5 rounded-full bg-current" />}
      {children}
    </span>
  );
}

/** Maps every status string in the dataset onto a badge tone. */
export function statusTone(status: string): Tone {
  switch (status) {
    case "Live":
    case "Active":
    case "Approved":
    case "Delivered":
    case "Closed":
      return "success";
    case "Pending Review":
    case "Pending KYC":
    case "Awaiting Review":
    case "New":
      return "warning";
    case "Rejected":
    case "Suspended":
    case "Lost":
      return "danger";
    case "Under Offer":
    case "Negotiating":
    case "Under Review":
      return "accent";
    case "Inspection Scheduled":
    case "Broker Assigned":
    case "Quoted":
    case "Price Confirmed":
    case "Machine Reserved":
    case "Delivery Scheduled":
      return "info";
    default:
      return "neutral";
  }
}

export function Button({
  children,
  variant = "primary",
  size = "md",
  type = "button",
  className,
  ...rest
}: {
  children: ReactNode;
  variant?: "primary" | "secondary" | "ghost" | "danger";
  size?: "sm" | "md";
} & React.ButtonHTMLAttributes<HTMLButtonElement>) {
  const variants = {
    primary:
      "bg-accent-500 text-white hover:bg-accent-600 focus-visible:outline-accent-500",
    secondary:
      "bg-white text-navy-800 ring-1 ring-inset ring-line hover:bg-navy-50 focus-visible:outline-navy-600",
    ghost: "text-muted hover:bg-slate-100 hover:text-navy-800",
    danger:
      "bg-white text-rose-600 ring-1 ring-inset ring-rose-200 hover:bg-rose-50",
  };

  return (
    <button
      type={type}
      className={cx(
        "inline-flex items-center justify-center gap-2 rounded-lg font-semibold transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
        size === "sm" ? "px-3 py-1.5 text-xs" : "px-4 py-2.5 text-sm",
        variants[variant],
        className,
      )}
      {...rest}
    >
      {children}
    </button>
  );
}

export function Table({ children }: { children: ReactNode }) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full min-w-[720px] border-collapse text-left text-sm">
        {children}
      </table>
    </div>
  );
}

export function Th({
  children,
  className,
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <th
      className={cx(
        "border-b border-line px-4 py-3 text-xs font-bold tracking-wide text-muted uppercase whitespace-nowrap",
        className,
      )}
    >
      {children}
    </th>
  );
}

export function Td({
  children,
  className,
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <td className={cx("border-b border-line/70 px-4 py-3.5", className)}>
      {children}
    </td>
  );
}

export function EmptyState({
  title,
  message,
}: {
  title: string;
  message: string;
}) {
  return (
    <div className="px-4 py-16 text-center">
      <p className="text-sm font-bold text-navy-800">{title}</p>
      <p className="mx-auto mt-1 max-w-sm text-sm text-muted">{message}</p>
    </div>
  );
}

/** Round monogram used wherever a person or company is listed. */
export function Avatar({ name, tone = "navy" }: { name: string; tone?: "navy" | "accent" }) {
  const initials = name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join("")
    .toUpperCase();

  return (
    <span
      className={cx(
        "grid h-9 w-9 shrink-0 place-items-center rounded-full text-xs font-bold text-white",
        tone === "navy" ? "bg-navy-800" : "bg-accent-500",
      )}
    >
      {initials}
    </span>
  );
}
