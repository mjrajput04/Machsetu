import { ensureIndexes, nextId, sellRequests, users } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

const text = (value: unknown) => String(value ?? "").trim();

/** Yes/No pairs arrive as true, false, or null when the seller skipped them. */
const tri = (value: unknown) => (typeof value === "boolean" ? value : null);

const list = (value: unknown): string[] =>
  Array.isArray(value) ? value.map(text).filter(Boolean) : [];

function digits(value: unknown): number {
  const only = String(value ?? "").replace(/[^0-9]/g, "");
  return only ? Number(only) : 0;
}

/**
 * Seller submission from the app's four-step wizard.
 *
 * Every field is optional — the sourcing desk fills the gaps during
 * verification, exactly as the wizard promises.
 */
export async function POST(request: Request) {
  await ensureIndexes();
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "user") return fail("Not authorised", 401);

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const seller = await (await users()).findOne({ code: token.sub });
  if (!seller) return fail("Account not found", 404);

  const now = new Date();
  const id = await nextId("requests", "REQ-", 5500);
  const categories = list(body.categories);

  const doc = {
    id,
    userCode: seller.code,
    machine:
      [text(body.brand), text(body.model)].filter(Boolean).join(" ") ||
      text(body.machineType) ||
      "Untitled machine",
    brand: text(body.brand),
    model: text(body.model),
    category: text(body.category) || categories[0] || "",
    categories,
    year: text(body.year),
    askingPrice: digits(body.price),
    condition: text(body.condition),
    hours: text(body.workingHours),
    city: text(body.city) || text(body.location),
    seller: text(body.companyName) || seller.company || seller.name,
    status: "Awaiting Review",
    submittedOn: now.toISOString().slice(0, 10),
    note: "",
    description: text(body.description),

    images: list(body.images),
    documents: Array.isArray(body.documents) ? body.documents : [],
    requiredPhotos: list(body.requiredPhotos),

    sellerInfo: {
      name: text(body.sellerName),
      company: text(body.companyName),
      mobile: text(body.mobile),
      whatsapp: text(body.whatsapp),
      email: text(body.email),
      gstNumber: text(body.gstNumber),
      panNumber: text(body.panNumber),
      address: text(body.address),
      city: text(body.city),
      state: text(body.state),
      pincode: text(body.pincode),
    },
    details: {
      machineType: text(body.machineType),
      installationYear: text(body.installationYear),
      countryOfOrigin: text(body.countryOfOrigin),
      controller: text(body.controller),
      numberOfAxis: text(body.numberOfAxis),
      machineCapacity: text(body.machineCapacity),
      powerRequirement: text(body.powerRequirement),
      maxSpindleSpeed: text(body.maxSpindleSpeed),
      weight: text(body.weight),
      workingStatus: text(body.workingStatus),
      maintenanceStatus: text(body.maintenanceStatus),
      lastServiceDate: text(body.lastServiceDate),
      accessoriesIncluded: text(body.accessoriesIncluded),
      serialNumber: text(body.serialNumber),
      location: text(body.location),
    },
    specs: {
      tableSize: text(body.tableSize),
      lubricationSystem: text(body.lubricationSystem),
      electricalPanelCondition: text(body.electricalPanelCondition),
      toolMagazineCapacity: text(body.toolMagazineCapacity),
      servoMotors: text(body.servoMotors),
      toolChangerType: text(body.toolChangerType),
      ballScrewCondition: text(body.ballScrewCondition),
      coolantSystem: text(body.coolantSystem),
      guideways: text(body.guideways),
      hydraulicSystem: text(body.hydraulicSystem),
      otherSpecifications: text(body.otherSpecifications),
    },
    commercial: {
      negotiable: tri(body.negotiable),
      gstAvailable: tri(body.gstAvailable),
      taxInvoiceAvailable: tri(body.taxInvoiceAvailable),
      financePending: tri(body.financePending),
      deliveryAvailable: tri(body.deliveryAvailable),
      loadingAvailable: tri(body.loadingAvailable),
      ownerType: text(body.ownerType),
    },
    additionalRemarks: text(body.additionalRemarks),
    inspection: null,
    views: 0,
    activeInquiries: 0,
    createdAt: now,
    updatedAt: now,
  };

  await (await sellRequests()).insertOne(doc);
  await (await users()).updateOne(
    { code: seller.code },
    { $inc: { listings: 1 }, $set: { updatedAt: now } },
  );

  return ok({ reference: id, request: { ...doc, _id: undefined } }, 201);
}
