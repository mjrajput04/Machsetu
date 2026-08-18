import { mkdir, unlink, writeFile } from "node:fs/promises";
import path from "node:path";

import { fail, ok, readToken } from "@/server/auth";
import {
  MAX_UPLOAD_BYTES,
  UPLOAD_DIR,
  UPLOAD_PREFIX,
  UPLOAD_TYPES,
  uploadName,
  uploadPath,
} from "@/server/storage";

/**
 * Accepts a multipart upload from the console or the mobile app.
 *
 * The bytes are written to the upload folder untouched — no resizing, no
 * re-encoding — and only the path comes back for the database to store. The
 * web server hands the file straight to the browser from there.
 */
export async function POST(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  if (!token) return fail("Not authorised", 401);

  const form = await request.formData().catch(() => null);
  if (!form) return fail("Expected a multipart form upload");

  const entries = form
    .getAll("file")
    .filter((f): f is File => f instanceof File);
  if (entries.length === 0) return fail("No file was uploaded");

  await mkdir(UPLOAD_DIR, { recursive: true });

  const uploaded: { url: string; name: string; size: number }[] = [];

  for (const file of entries) {
    if (file.size > MAX_UPLOAD_BYTES) {
      return fail(
        `${file.name} is larger than ${MAX_UPLOAD_BYTES / 1024 / 1024} MB`,
        413,
      );
    }
    const ext = UPLOAD_TYPES[file.type];
    if (!ext) return fail(`${file.name} is not a supported file type`, 415);

    const name = uploadName(file.name, ext, uploaded.length);
    const bytes = Buffer.from(await file.arrayBuffer());
    await writeFile(path.join(UPLOAD_DIR, name), bytes);

    uploaded.push({
      url: `${UPLOAD_PREFIX}/${name}`,
      name: file.name,
      size: bytes.byteLength,
    });
  }

  return ok({ files: uploaded, url: uploaded[0].url });
}

/** Removes a stored file. Only ever touches the upload folder. */
export async function DELETE(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  if (!token) return fail("Not authorised", 401);

  const url = new URL(request.url).searchParams.get("url") ?? "";
  const target = uploadPath(url);
  if (!target) return fail("That file is not an upload");

  try {
    await unlink(target);
  } catch {
    // Already gone — the caller only cares that it is no longer there.
  }
  return ok({ deleted: url });
}
