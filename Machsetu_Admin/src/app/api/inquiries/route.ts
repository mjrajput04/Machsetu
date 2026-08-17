import { ensureIndexes, inquiries, nextId, users } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

const text = (value: unknown) => String(value ?? "").trim();

function amount(value: unknown): number {
  const digits = String(value ?? "").replace(/[^0-9]/g, "");
  return digits ? Number(digits) : 0;
}

/** RFQs this buyer has raised, newest first. */
export async function GET(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return fail("Not authorised", 401);

  const docs = await (await inquiries())
    .find({ userCode: token.sub }, { projection: { _id: 0 } })
    .sort({ createdAt: -1 })
    .toArray();
  return ok({ inquiries: docs, count: docs.length });
}

/** Raises a new inquiry from the app's RFQ form. */
export async function POST(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const machine = text(body.machine);
  if (!machine) return fail("Tell us which machine you need");

  const buyer = await (await users()).findOne({ code: token.sub });
  if (!buyer) return fail("Account not found", 404);

  const now = new Date();
  const id = await nextId("inquiries", "RFQ-", 4470);
  const today = now.toISOString().slice(0, 10);

  const specs = Array.isArray(body.specs)
    ? body.specs.map(text).filter(Boolean)
    : [];
  const quantity = text(body.quantity);
  if (quantity) specs.push(`Qty ${quantity}`);

  const doc = {
    id,
    userCode: buyer.code,
    machine,
    brand: text(body.brand),
    image: text(body.image) || null,
    specs,
    buyer: buyer.name,
    company: buyer.company,
    city: text(body.city) || [buyer.city, buyer.state].filter(Boolean).join(", "),
    budget: amount(body.budget),
    quoted: null,
    status: "New",
    broker: null,
    responseNote: text(body.note) || "Awaiting broker assignment.",
    productId: text(body.productId) || null,
    raisedOn: today,
    lastActivity: today,
    createdAt: now,
    updatedAt: now,
  };

  await (await inquiries()).insertOne(doc);
  return ok({ reference: id, inquiry: { ...doc, _id: undefined } }, 201);
}
