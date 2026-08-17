import { ensureIndexes, nextId, orders, products, users } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";
import { notify } from "@/server/notify";

const text = (value: unknown) => String(value ?? "").trim();
const money = (value: unknown) => {
  const n = Number(value);
  return Number.isFinite(n) && n > 0 ? n : 0;
};

/** The eight stops the app's tracking timeline draws, in order. */
export const ORDER_STAGES = [
  "Inquiry Received",
  "Under Review",
  "Broker Contacting You",
  "Price Confirmed",
  "Machine Reserved",
  "Order Confirmed",
  "Delivery Scheduled",
  "Delivered",
];

/** This buyer's orders, newest first. */
export async function GET(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return fail("Not authorised", 401);

  const docs = await (await orders())
    .find({ userCode: token.sub }, { projection: { _id: 0 } })
    .sort({ createdAt: -1 })
    .toArray();
  return ok({ orders: docs, count: docs.length });
}

/** Places the cart as a real order the sourcing desk can work. */
export async function POST(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const incoming = Array.isArray(body.items) ? body.items : [];
  if (incoming.length === 0) return fail("Your cart is empty");

  const buyer = await (await users()).findOne({ code: token.sub });
  if (!buyer) return fail("Account not found", 404);

  const items = incoming.map((item: Record<string, unknown>) => ({
    productId: text(item.productId) || null,
    title: text(item.title),
    brand: text(item.brand),
    equipmentType: text(item.equipmentType),
    image: text(item.image) || null,
    unitPrice: money(item.unitPrice),
    quantity: Math.max(1, Number(item.quantity) || 1),
  }));

  // The listing carries the seller's name; the first line names the order.
  const first = items[0];
  const listing = first.productId
    ? await (await products()).findOne({ id: first.productId })
    : null;

  // The checkout form wins where it is filled in; the profile fills the rest,
  // so an order always carries a complete billing and delivery record.
  const form = (body.customer ?? {}) as Record<string, unknown>;
  const pick = (key: string, fallback: string) =>
    text(form[key]) || fallback;

  const customer = {
    name: pick("name", buyer.name),
    company: pick("company", buyer.company),
    email: pick("email", buyer.email),
    phone: pick("phone", buyer.phone),
    gstin: pick("gstin", buyer.gstin).toUpperCase(),
    pan: pick("pan", buyer.pan).toUpperCase(),
    designation: pick("designation", buyer.designation),
    street: pick("street", buyer.address),
    city: pick("city", buyer.city),
    state: pick("state", buyer.state),
    zip: pick("zip", buyer.zip),
  };

  const address = [
    customer.street,
    customer.city,
    customer.state,
    customer.zip,
  ]
    .filter(Boolean)
    .join(", ");

  const now = new Date();
  const id = await nextId("orders", "ORD-", 88200);

  const doc = {
    id,
    userCode: buyer.code,
    machine: first.title || "Industrial equipment",
    image: first.image,
    buyer: buyer.company || buyer.name,
    seller: text(listing?.seller) || "MachSetu Sourcing Desk",
    amount: money(body.total),
    subtotal: money(body.subtotal),
    freight: money(body.freight),
    gst: money(body.gst),
    stage: ORDER_STAGES[0],
    stageIndex: 1,
    placedOn: now.toISOString().slice(0, 10),
    destination:
      text(body.destination) ||
      [customer.city, customer.state].filter(Boolean).join(", "),
    customer,
    deliveryAddress: address,
    equipmentType: first.equipmentType,
    logisticsMode: text(body.logisticsMode) || "Expedited Freight",
    items,
    note: "",
    createdAt: now,
    updatedAt: now,
  };

  await (await orders()).insertOne(doc);
  await (await users()).updateOne(
    { code: buyer.code },
    { $inc: { orders: 1 }, $set: { updatedAt: now } },
  );

  await notify(buyer.code, {
    title: "Order placed",
    body: `${doc.machine} — we are reviewing your inquiry and will confirm shortly.`,
    kind: "order",
    reference: id,
    image: doc.image,
  });

  return ok({ reference: id, order: { ...doc, _id: undefined } }, 201);
}
