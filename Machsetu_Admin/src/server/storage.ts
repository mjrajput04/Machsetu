import path from "node:path";

/**
 * Where uploaded photos and documents live on disk.
 *
 * Files are written to a folder and only their path is kept in MongoDB, so
 * nginx serves the bytes straight off the disk at full quality and the
 * database stays small.
 *
 * In development this is `public/uploads`, which Next serves on its own. On a
 * server set UPLOAD_DIR to a folder OUTSIDE the checkout — otherwise a
 * `git pull` or a fresh clone would take every uploaded file with it.
 */
export const UPLOAD_DIR =
  process.env.UPLOAD_DIR?.trim() ||
  path.join(process.cwd(), "public", "uploads");

/** Public prefix the stored paths carry, e.g. `/uploads/haas-ms1a2b.jpg`. */
export const UPLOAD_PREFIX = "/uploads";

/** Largest single file the API accepts. */
export const MAX_UPLOAD_BYTES = 25 * 1024 * 1024;

/** Extension per accepted content type; anything else is refused. */
export const UPLOAD_TYPES: Record<string, string> = {
  "image/jpeg": ".jpg",
  "image/png": ".png",
  "image/webp": ".webp",
  "image/gif": ".gif",
  "image/heic": ".heic",
  "application/pdf": ".pdf",
};

/** Readable, collision-free file name built from what the user sent. */
export function uploadName(original: string, ext: string, seq: number): string {
  const stem =
    original
      .toLowerCase()
      .replace(/\.[^.]+$/, "")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "")
      .slice(0, 40) || "file";

  // Timestamp plus a counter keeps names unique without a random source.
  return `${stem}-${Date.now().toString(36)}-${seq}${ext}`;
}

/**
 * Resolves a stored path back to a file on disk.
 *
 * Returns null for anything that is not one of our own uploads, so a crafted
 * path can never read outside the upload folder.
 */
export function uploadPath(url: string): string | null {
  if (!url.startsWith(`${UPLOAD_PREFIX}/`)) return null;

  // The tail must be a bare file name — no slashes, no climbing.
  const name = url.slice(UPLOAD_PREFIX.length + 1);
  if (!name || name !== path.basename(name) || name.startsWith(".")) {
    return null;
  }

  const resolved = path.resolve(UPLOAD_DIR, name);
  if (!resolved.startsWith(path.resolve(UPLOAD_DIR))) return null;
  return resolved;
}
