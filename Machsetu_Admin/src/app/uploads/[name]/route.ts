import { readFile } from "node:fs/promises";
import path from "node:path";

import { UPLOAD_DIR, UPLOAD_TYPES } from "@/server/storage";

type Ctx = { params: Promise<{ name: string }> };

/**
 * Serves a file out of the upload folder.
 *
 * In production the web server should answer `/uploads/…` itself — it is far
 * faster off the disk than through Node. This route is the safety net for
 * when it does not, and for local development where the folder sits outside
 * `public/`.
 */
export async function GET(_request: Request, ctx: Ctx) {
  const { name: raw } = await ctx.params;

  // Only a bare file name is ever valid; anything else could climb out.
  const name = path.basename(raw);
  if (!name || name !== raw) return new Response("Not found", { status: 404 });

  const ext = path.extname(name).toLowerCase();
  const contentType =
    Object.entries(UPLOAD_TYPES).find(([, e]) => e === ext)?.[0] ??
    "application/octet-stream";

  try {
    const bytes = await readFile(path.join(UPLOAD_DIR, name));
    return new Response(new Uint8Array(bytes), {
      headers: {
        "Content-Type": contentType,
        "Content-Length": String(bytes.byteLength),
        // Names carry a timestamp, so a given URL never changes content.
        "Cache-Control": "public, max-age=31536000, immutable",
        ETag: `"${name}"`,
      },
    });
  } catch {
    return new Response("Not found", { status: 404 });
  }
}
