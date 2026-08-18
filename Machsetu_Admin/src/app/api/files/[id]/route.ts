import { readFile } from "node:fs/promises";
import path from "node:path";

import { files } from "@/server/db";
import { UPLOAD_DIR, UPLOAD_TYPES } from "@/server/storage";

type Ctx = { params: Promise<{ id: string }> };

const CACHE = "public, max-age=31536000, immutable";

function contentTypeFor(name: string): string {
  const ext = path.extname(name).toLowerCase();
  const match = Object.entries(UPLOAD_TYPES).find(([, e]) => e === ext);
  return match?.[0] ?? "application/octet-stream";
}

/**
 * Serves an uploaded photo or document.
 *
 * Uploads live in the upload folder and are normally served by the web server
 * straight off the disk. This route is the fallback for two cases: running
 * without a web server in front, and files that predate the folder and are
 * still held in the database.
 */
export async function GET(_request: Request, ctx: Ctx) {
  const { id } = await ctx.params;

  // A crafted id must never reach outside the upload folder.
  const name = path.basename(id);
  if (!name || name !== id) return new Response("Not found", { status: 404 });

  try {
    const bytes = await readFile(path.join(UPLOAD_DIR, name));
    return new Response(new Uint8Array(bytes), {
      headers: {
        "Content-Type": contentTypeFor(name),
        "Content-Length": String(bytes.byteLength),
        "Cache-Control": CACHE,
        ETag: `"${name}"`,
      },
    });
  } catch {
    // Not on disk — fall through to the legacy database copy.
  }

  const doc = await (await files()).findOne({ id: name });
  if (!doc) return new Response("Not found", { status: 404 });

  const bytes = doc.data.buffer as Uint8Array;
  return new Response(new Uint8Array(bytes), {
    headers: {
      "Content-Type": doc.contentType || "application/octet-stream",
      "Content-Length": String(bytes.byteLength),
      "Cache-Control": CACHE,
      ETag: `"${doc.id}"`,
    },
  });
}
