import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { Binary } from "mongodb";

import { INQUIRIES, ORDERS, PRODUCTS, SELL_REQUESTS } from "@/lib/data";
import {
  db,
  ensureIndexes,
  files,
  inquiries,
  orders,
  products,
  sellRequests,
  syncCounter,
} from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

const TYPES: Record<string, string> = {
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
  ".webp": "image/webp",
};

/**
 * Moves the bundled demo photos into the database.
 *
 * After this runs every image in the app is served from Mongo through
 * `/api/files/<name>`, so nothing depends on files sitting on a disk.
 */
async function importPhotos(): Promise<number> {
  const dir = path.join(process.cwd(), "public", "machines");
  let names: string[];
  try {
    names = await readdir(dir);
  } catch {
    return 0;
  }

  const col = await files();
  let stored = 0;

  for (const name of names) {
    const ext = path.extname(name).toLowerCase();
    const contentType = TYPES[ext];
    if (!contentType) continue;

    // The id is the file name, so re-seeding refreshes rather than duplicates
    // and existing listings keep pointing at the right photo.
    const bytes = await readFile(path.join(dir, name));
    await col.updateOne(
      { id: name },
      {
        $set: {
          id: name,
          filename: name,
          contentType,
          size: bytes.byteLength,
          data: new Binary(bytes),
          uploadedBy: "seed",
        },
        $setOnInsert: { createdAt: new Date() },
      },
      { upsert: true },
    );
    stored += 1;
  }
  return stored;
}

/** Rewrites bundled `/machines/x.jpg` paths onto the database-backed URL. */
function toFileUrls<T>(record: T): T {
  return JSON.parse(
    JSON.stringify(record).replaceAll("/machines/", "/api/files/"),
  ) as T;
}

const OLD = "/machines/";
const NEW = "/api/files/";

/** One `$replaceAll` on a single string field. */
const swap = (field: string) => ({
  $replaceAll: { input: `$${field}`, find: OLD, replacement: NEW },
});

/**
 * Points rows written before this change at the database-backed URLs.
 *
 * Runs on every seed so a listing approved from an older submission cannot
 * keep a stale link to a file on disk.
 */
async function normaliseImagePaths(): Promise<void> {
  const database = await db();

  for (const name of ["products", "sellRequests"]) {
    await database.collection(name).updateMany({ images: { $type: "array" } }, [
      {
        $set: {
          images: {
            $map: {
              input: "$images",
              in: {
                $replaceAll: { input: "$$this", find: OLD, replacement: NEW },
              },
            },
          },
        },
      },
    ]);
  }

  for (const name of ["inquiries", "orders"]) {
    await database
      .collection(name)
      .updateMany({ image: { $type: "string" } }, [
        { $set: { image: swap("image") } },
      ]);
  }

  await database
    .collection("settings")
    .updateMany({ "hero.image": { $type: "string" } }, [
      { $set: { "hero.image": swap("hero.image") } },
    ]);

  await database
    .collection("users")
    .updateMany({ avatar: { $type: "string" } }, [
      { $set: { avatar: swap("avatar") } },
    ]);
}

/**
 * One-time import of the bundled catalogue into MongoDB.
 *
 * Safe to re-run: each document is upserted on its `id`, so existing rows are
 * refreshed rather than duplicated. Pass `{ "reset": true }` to wipe first.
 */
export async function POST(request: Request) {
  await ensureIndexes();

  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "admin") return fail("Not authorised", 401);

  const body = await request.json().catch(() => ({}));
  const reset = body?.reset === true;

  const [productCol, requestCol, inquiryCol, orderCol] = await Promise.all([
    products(),
    sellRequests(),
    inquiries(),
    orders(),
  ]);

  if (reset) {
    await Promise.all([
      productCol.deleteMany({}),
      requestCol.deleteMany({}),
      inquiryCol.deleteMany({}),
      orderCol.deleteMany({}),
    ]);
  }

  const photos = await importPhotos();

  const now = new Date();
  for (const raw of PRODUCTS) {
    const p = toFileUrls(raw);
    await productCol.updateOne(
      { id: p.id },
      { $set: { ...p, updatedAt: now }, $setOnInsert: { createdAt: now } },
      { upsert: true },
    );
  }
  for (const rawRequest of SELL_REQUESTS) {
    const r = toFileUrls(rawRequest);
    await requestCol.updateOne(
      { id: r.id },
      { $set: { ...r, updatedAt: now }, $setOnInsert: { createdAt: now } },
      { upsert: true },
    );
  }
  for (const rawInquiry of INQUIRIES) {
    const i = toFileUrls(rawInquiry);
    await inquiryCol.updateOne(
      { id: i.id },
      { $set: { ...i, updatedAt: now }, $setOnInsert: { createdAt: now } },
      { upsert: true },
    );
  }
  for (const rawOrder of ORDERS) {
    const o = toFileUrls(rawOrder);
    await orderCol.updateOne(
      { id: o.id },
      { $set: { ...o, updatedAt: now }, $setOnInsert: { createdAt: now } },
      { upsert: true },
    );
  }

  await normaliseImagePaths();

  // The import brings its own ids, so the generators have to move past them.
  await syncCounter("products", "MS-", 1000, "products");
  await syncCounter("requests", "REQ-", 5500, "sellRequests");

  return ok({
    photos,
    products: await productCol.countDocuments(),
    requests: await requestCol.countDocuments(),
    inquiries: await inquiryCol.countDocuments(),
    orders: await orderCol.countDocuments(),
  });
}
