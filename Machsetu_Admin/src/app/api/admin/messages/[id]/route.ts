import { contactMessages } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

type Ctx = { params: Promise<{ id: string }> };

function requireAdmin(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  return token && token.kind === "admin" ? token : null;
}

/** Marks a message read or unread. */
export async function PUT(request: Request, ctx: Ctx) {
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const body = await request.json().catch(() => null);
  const status = body?.status === "Read" ? "Read" : "New";

  const result = await (await contactMessages()).updateOne(
    { id },
    { $set: { status } },
  );
  if (result.matchedCount === 0) return fail("Message not found", 404);
  return ok({ status });
}

export async function DELETE(request: Request, ctx: Ctx) {
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const result = await (await contactMessages()).deleteOne({ id });
  if (result.deletedCount === 0) return fail("Message not found", 404);
  return ok({ deleted: true });
}
