import { ensureIndexes, inquiries } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";
import { notify } from "@/server/notify";

type Ctx = { params: Promise<{ id: string }> };

const STATUSES = [
  "New",
  "Broker Assigned",
  "Awaiting Quote",
  "Quote Received",
  "Negotiating",
  "Closed",
  "Lost",
  "Expired",
];

function requireAdmin(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  return token && token.kind === "admin" ? token : null;
}

export async function GET(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const found = await (await inquiries()).findOne(
    { id },
    { projection: { _id: 0 } },
  );
  if (!found) return fail("Inquiry not found", 404);
  return ok({ inquiry: found });
}

/** Assigns a broker, records a quote, or closes the RFQ. */
export async function PUT(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const col = await inquiries();
  const found = await col.findOne({ id });
  if (!found) return fail("Inquiry not found", 404);

  const today = new Date().toISOString().slice(0, 10);
  const patch: Record<string, unknown> = {
    lastActivity: today,
    updatedAt: new Date(),
  };

  const status = String(body.status ?? "");
  if (status) {
    if (!STATUSES.includes(status)) return fail("Unknown inquiry status");
    patch.status = status;
  }
  if (typeof body.broker === "string") patch.broker = body.broker.trim() || null;
  if (typeof body.responseNote === "string") {
    patch.responseNote = body.responseNote.trim();
  }
  if (body.quoted !== undefined) {
    const digits = String(body.quoted).replace(/[^0-9]/g, "");
    patch.quoted = digits ? Number(digits) : null;
  }

  await col.updateOne({ id }, { $set: patch });

  // The buyer hears about a quote or a change of hands, not every edit.
  const worthTelling = status || patch.quoted !== undefined || patch.broker;
  if (worthTelling && typeof found.userCode === "string") {
    await notify(found.userCode, {
      title: patch.quoted
        ? `Quote received for ${found.machine}`
        : `Inquiry ${id} — ${status || "updated"}`,
      body:
        typeof patch.responseNote === "string" && patch.responseNote
          ? String(patch.responseNote)
          : `Your inquiry for ${found.machine} has been updated.`,
      kind: "inquiry",
      reference: id,
      image: (found.image as string | null) ?? null,
    });
  }

  const updated = await col.findOne({ id }, { projection: { _id: 0 } });
  return ok({ inquiry: updated });
}
