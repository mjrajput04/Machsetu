import { Binary } from "mongodb";

import { ensureIndexes, files } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

const MAX_BYTES = 8 * 1024 * 1024;
const EXTENSIONS: Record<string, string> = {
  "image/jpeg": ".jpg",
  "image/png": ".png",
  "image/webp": ".webp",
  "image/gif": ".gif",
  "application/pdf": ".pdf",
};

function slug(name: string) {
  return (
    name
      .toLowerCase()
      .replace(/\.[^.]+$/, "")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "")
      .slice(0, 40) || "file"
  );
}

/**
 * Accepts a multipart upload from either the console or the mobile app and
 * keeps the bytes in MongoDB.
 *
 * Nothing touches the filesystem, so the returned URL is an API path the
 * database can always answer — never a link to a file on a disk somewhere.
 */
export async function POST(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token) return fail("Not authorised", 401);

  const form = await request.formData().catch(() => null);
  if (!form) return fail("Expected a multipart form upload");

  const entries = form.getAll("file").filter((f): f is File => f instanceof File);
  if (entries.length === 0) return fail("No file was uploaded");

  const col = await files();
  const uploaded: { url: string; name: string; size: number }[] = [];

  for (const file of entries) {
    if (file.size > MAX_BYTES) {
      return fail(`${file.name} is larger than 8 MB`, 413);
    }
    const ext = EXTENSIONS[file.type];
    if (!ext) return fail(`${file.name} is not a supported file type`, 415);

    // Timestamp plus a counter keeps ids unique without a random source.
    const stamp = `${Date.now().toString(36)}-${uploaded.length}`;
    const id = `${slug(file.name)}-${stamp}${ext}`;
    const bytes = Buffer.from(await file.arrayBuffer());

    await col.insertOne({
      id,
      filename: file.name,
      contentType: file.type,
      size: bytes.byteLength,
      data: new Binary(bytes),
      uploadedBy: token.sub,
      createdAt: new Date(),
    });

    uploaded.push({
      url: `/api/files/${id}`,
      name: file.name,
      size: file.size,
    });
  }

  return ok({ files: uploaded, url: uploaded[0].url });
}

/** Removes a stored file. Ids are opaque, so nothing else can be reached. */
export async function DELETE(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token) return fail("Not authorised", 401);

  const url = new URL(request.url).searchParams.get("url") ?? "";
  const id = url.startsWith("/api/files/")
    ? url.slice("/api/files/".length)
    : "";
  if (!id || id.includes("/")) return fail("That file is not an upload");

  // Deleting twice is not an error — the caller only cares that it is gone.
  await (await files()).deleteOne({ id });
  return ok({ deleted: `/api/files/${id}` });
}
