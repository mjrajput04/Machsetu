import type { AddressDoc } from "@/server/db";
import { ensureIndexes, users } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

/**
 * Saved delivery addresses for the signed-in app user.
 *
 * They live as an array on the user document rather than their own collection
 * — a user has a handful, they are always read with the account, and there is
 * no query that needs them independently.
 */

async function currentUser(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return null;
  const col = await users();
  return col.findOne({ code: token.sub });
}

const text = (value: unknown) => String(value ?? "").trim();

function validate(body: Record<string, unknown>): string | null {
  if (!text(body.line1)) return "Address line 1 is required";
  if (!text(body.city)) return "City is required";
  if (!text(body.state)) return "State is required";
  const zip = text(body.zip);
  if (!/^\d{6}$/.test(zip)) return "Enter a valid 6-digit PIN code";
  const phone = text(body.contactPhone).replace(/\D/g, "");
  if (phone && !/^[6-9]\d{9}$/.test(phone)) {
    return "Enter a valid 10-digit mobile number";
  }
  return null;
}

function shape(body: Record<string, unknown>, id: string, createdAt: Date): AddressDoc {
  return {
    id,
    label: text(body.label) || "Address",
    contactName: text(body.contactName),
    contactPhone: text(body.contactPhone).replace(/\D/g, ""),
    line1: text(body.line1),
    line2: text(body.line2),
    landmark: text(body.landmark),
    city: text(body.city),
    state: text(body.state),
    zip: text(body.zip),
    isDefault: body.isDefault === true,
    createdAt,
  };
}

/** Keeps exactly one default: the flagged one, or the first if none is. */
function normaliseDefaults(list: AddressDoc[], preferId?: string): AddressDoc[] {
  if (list.length === 0) return list;
  let chosen = preferId ?? list.find((a) => a.isDefault)?.id ?? list[0].id;
  if (!list.some((a) => a.id === chosen)) chosen = list[0].id;
  return list.map((a) => ({ ...a, isDefault: a.id === chosen }));
}

export async function GET(request: Request) {
  await ensureIndexes();
  const user = await currentUser(request);
  if (!user) return fail("Not authorised", 401);
  return ok({ addresses: user.addresses ?? [] });
}

export async function POST(request: Request) {
  await ensureIndexes();
  const user = await currentUser(request);
  if (!user) return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const problem = validate(body);
  if (problem) return fail(problem);

  const existing = user.addresses ?? [];
  if (existing.length >= 20) {
    return fail("You can save up to 20 addresses");
  }

  const id = `ADR-${Date.now()}-${Math.floor(Math.random() * 9000 + 1000)}`;
  const created = shape(body, id, new Date());
  // The very first address is always the default.
  const next = normaliseDefaults(
    [...existing, created],
    created.isDefault || existing.length === 0 ? id : undefined,
  );

  const col = await users();
  await col.updateOne(
    { _id: user._id },
    { $set: { addresses: next, updatedAt: new Date() } },
  );
  return ok({ addresses: next });
}

export async function PUT(request: Request) {
  await ensureIndexes();
  const user = await currentUser(request);
  if (!user) return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const id = text(body.id);
  if (!id) return fail("Address id is required");

  const existing = user.addresses ?? [];
  const current = existing.find((a) => a.id === id);
  if (!current) return fail("That address no longer exists", 404);

  // A bare {id, isDefault:true} just promotes an address without re-validating.
  const promoteOnly = Object.keys(body).length <= 2 && body.isDefault === true;
  if (!promoteOnly) {
    const problem = validate(body);
    if (problem) return fail(problem);
  }

  const updated = promoteOnly
    ? current
    : shape(body, id, current.createdAt ?? new Date());

  const next = normaliseDefaults(
    existing.map((a) => (a.id === id ? updated : a)),
    body.isDefault === true ? id : undefined,
  );

  const col = await users();
  await col.updateOne(
    { _id: user._id },
    { $set: { addresses: next, updatedAt: new Date() } },
  );
  return ok({ addresses: next });
}

export async function DELETE(request: Request) {
  await ensureIndexes();
  const user = await currentUser(request);
  if (!user) return fail("Not authorised", 401);

  const id = new URL(request.url).searchParams.get("id") ?? "";
  if (!id) return fail("Address id is required");

  const existing = user.addresses ?? [];
  if (!existing.some((a) => a.id === id)) {
    return fail("That address no longer exists", 404);
  }

  // Removing the default promotes whichever address is left first.
  const next = normaliseDefaults(existing.filter((a) => a.id !== id));

  const col = await users();
  await col.updateOne(
    { _id: user._id },
    { $set: { addresses: next, updatedAt: new Date() } },
  );
  return ok({ addresses: next });
}
