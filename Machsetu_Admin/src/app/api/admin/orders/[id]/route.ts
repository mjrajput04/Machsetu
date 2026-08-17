import { ensureIndexes, orders } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";
import { notify } from "@/server/notify";
import { ORDER_STAGES } from "@/app/api/orders/route";

type Ctx = { params: Promise<{ id: string }> };

function requireAdmin(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  return token && token.kind === "admin" ? token : null;
}

export async function GET(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const found = await (await orders()).findOne({ id }, { projection: { _id: 0 } });
  if (!found) return fail("Order not found", 404);
  return ok({ order: found });
}

/** Moves an order along the pipeline and tells the buyer it happened. */
export async function PUT(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const col = await orders();
  const found = await col.findOne({ id });
  if (!found) return fail("Order not found", 404);

  const patch: Record<string, unknown> = { updatedAt: new Date() };

  const stage = String(body.stage ?? "");
  if (stage) {
    if (!ORDER_STAGES.includes(stage)) return fail("Unknown order stage");
    patch.stage = stage;
    patch.stageIndex = ORDER_STAGES.indexOf(stage) + 1;
  }
  if (typeof body.note === "string") patch.note = body.note.trim();

  await col.updateOne({ id }, { $set: patch });

  if (stage && stage !== found.stage && typeof found.userCode === "string") {
    await notify(found.userCode, {
      title: `Order ${id} — ${stage}`,
      body:
        typeof patch.note === "string" && patch.note
          ? String(patch.note)
          : `${found.machine} has moved to "${stage}".`,
      kind: "order",
      reference: id,
      image: (found.image as string | null) ?? null,
    });
  }

  const updated = await col.findOne({ id }, { projection: { _id: 0 } });
  return ok({ order: updated });
}
