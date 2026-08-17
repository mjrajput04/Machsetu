import { files } from "@/server/db";

type Ctx = { params: Promise<{ id: string }> };

/**
 * Serves an uploaded photo or document straight out of MongoDB.
 *
 * Public, like any image URL. Ids never change once written, so the response
 * is safe to cache for a long time.
 */
export async function GET(_request: Request, ctx: Ctx) {
  const { id } = await ctx.params;

  const doc = await (await files()).findOne({ id });
  if (!doc) {
    return new Response("Not found", { status: 404 });
  }

  const bytes = doc.data.buffer as Uint8Array;
  return new Response(new Uint8Array(bytes), {
    headers: {
      "Content-Type": doc.contentType || "application/octet-stream",
      "Content-Length": String(bytes.byteLength),
      "Cache-Control": "public, max-age=31536000, immutable",
      ETag: `"${doc.id}"`,
      "Content-Disposition": `inline; filename="${encodeURIComponent(doc.filename)}"`,
    },
  });
}
