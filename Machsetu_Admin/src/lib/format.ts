/** Indian lakh/crore grouping — `159612.7` becomes `₹1,59,612.70`. */
export function rupees(amount: number, decimals = false): string {
  const fixed = amount.toFixed(decimals ? 2 : 0);
  const [whole, fraction] = fixed.split(".");
  const negative = whole.startsWith("-");
  const body = negative ? whole.slice(1) : whole;

  let grouped = body;
  if (body.length > 3) {
    const last3 = body.slice(-3);
    let rest = body.slice(0, -3);
    const parts: string[] = [];
    while (rest.length > 2) {
      parts.unshift(rest.slice(-2));
      rest = rest.slice(0, -2);
    }
    if (rest) parts.unshift(rest);
    grouped = `${parts.join(",")},${last3}`;
  }

  return `${negative ? "-" : ""}₹${grouped}${fraction ? `.${fraction}` : ""}`;
}

/** Compact crore/lakh label for dashboard tiles. */
export function rupeesShort(amount: number): string {
  if (amount >= 1_00_00_000) return `₹${(amount / 1_00_00_000).toFixed(2)} Cr`;
  if (amount >= 1_00_000) return `₹${(amount / 1_00_000).toFixed(1)} L`;
  return rupees(amount);
}

export function relativeDate(iso: string): string {
  const then = new Date(iso).getTime();
  const days = Math.round((Date.now() - then) / 86_400_000);
  if (days <= 0) return "Today";
  if (days === 1) return "Yesterday";
  if (days < 30) return `${days} days ago`;
  const months = Math.round(days / 30);
  return months === 1 ? "1 month ago" : `${months} months ago`;
}

export function shortDate(iso: string): string {
  return new Date(iso).toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}
