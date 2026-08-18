import { readdir } from "node:fs/promises";
import path from "node:path";

import { INQUIRIES, ORDERS, PRODUCTS, SELL_REQUESTS } from "@/lib/data";
import {
  db,
  ensureIndexes,
  inquiries,
  orders,
  products,
  sellRequests,
  syncCounter,
} from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

/**
 * Points any row still holding a database-backed URL for one of the bundled
 * demo photos back at the file itself.
 *
 * Only the names actually shipped in `public/machines` are rewritten, so a
 * real upload that happens to sit behind the same route is left alone.
 */
async function relinkBundledPhotos(): Promise<number> {
  let names: string[];
  try {
    names = await readdir(path.join(process.cwd(), "public", "machines"));
  } catch {
    return 0;
  }

  const database = await db();
  let moved = 0;

  for (const name of names) {
    const from = `/api/files/${name}`;
    const to = `/machines/${name}`;

    for (const collection of ["products", "sellRequests"]) {
      const result = await database
        .collection(collection)
        .updateMany({ images: from }, { $set: { "images.$[el]": to } }, {
          arrayFilters: [{ el: from }],
        });
      moved += result.modifiedCount;
    }

    for (const collection of ["inquiries", "orders"]) {
      const result = await database
        .collection(collection)
        .updateMany({ image: from }, { $set: { image: to } });
      moved += result.modifiedCount;
    }

    const slides = await database
      .collection("settings")
      .updateMany({ "heroSlides.image": from }, {
        $set: { "heroSlides.$[el].image": to },
      }, { arrayFilters: [{ "el.image": from }] });
    moved += slides.modifiedCount;

    const avatars = await database
      .collection("users")
      .updateMany({ avatar: from }, { $set: { avatar: to } });
    moved += avatars.modifiedCount;
  }

  return moved;
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

  const now = new Date();
  for (const p of PRODUCTS) {
    await productCol.updateOne(
      { id: p.id },
      { $set: { ...p, updatedAt: now }, $setOnInsert: { createdAt: now } },
      { upsert: true },
    );
  }
  for (const r of SELL_REQUESTS) {
    await requestCol.updateOne(
      { id: r.id },
      { $set: { ...r, updatedAt: now }, $setOnInsert: { createdAt: now } },
      { upsert: true },
    );
  }
  for (const i of INQUIRIES) {
    await inquiryCol.updateOne(
      { id: i.id },
      { $set: { ...i, updatedAt: now }, $setOnInsert: { createdAt: now } },
      { upsert: true },
    );
  }
  for (const o of ORDERS) {
    await orderCol.updateOne(
      { id: o.id },
      { $set: { ...o, updatedAt: now }, $setOnInsert: { createdAt: now } },
      { upsert: true },
    );
  }

  const relinked = await relinkBundledPhotos();

  // The import brings its own ids, so the generators have to move past them.
  await syncCounter("products", "MS-", 1000, "products");
  await syncCounter("requests", "REQ-", 5500, "sellRequests");

  return ok({
    relinked,
    products: await productCol.countDocuments(),
    requests: await requestCol.countDocuments(),
    inquiries: await inquiryCol.countDocuments(),
    orders: await orderCol.countDocuments(),
  });
}
