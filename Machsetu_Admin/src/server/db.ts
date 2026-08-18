import {
  MongoClient,
  type Binary,
  type Collection,
  type Db,
  type ObjectId,
} from "mongodb";

/**
 * Mongo connection shared across API routes.
 *
 * Next.js reloads modules on every edit in dev, so the client is cached on
 * `globalThis` to avoid opening a new pool on each hot reload.
 */
const uri = process.env.MONGODB_URI ?? "mongodb://127.0.0.1:27017";
const dbName = process.env.MONGODB_DB ?? "machsetu";

declare global {
  var _machsetuMongo: Promise<MongoClient> | undefined;
}

function client(): Promise<MongoClient> {
  if (!global._machsetuMongo) {
    global._machsetuMongo = new MongoClient(uri).connect();
  }
  return global._machsetuMongo;
}

export async function db(): Promise<Db> {
  return (await client()).db(dbName);
}

/* ------------------------------------------------------------ documents -- */

export interface UserDoc {
  _id?: ObjectId;
  /** Human-facing id, e.g. U-2213. */
  code: string;

  // Registration (Flutter register screen)
  name: string;
  email: string;
  /** Ten digits, no country code — the app stores it that way. */
  phone: string;
  passwordHash: string;

  // Profile (Flutter edit-profile screen)
  /** Uploaded profile photo, e.g. /uploads/… — empty until they set one. */
  avatar: string;
  designation: string;
  company: string;
  gstin: string;
  pan: string;
  address: string;
  city: string;
  state: string;
  zip: string;

  // Security toggles (Flutter security screen)
  twoFactor: boolean;
  biometrics: boolean;
  loginAlerts: boolean;

  role: "Buyer" | "Seller" | "Both" | "Broker";
  status: "Active" | "Pending KYC" | "Suspended";
  /** False until the registration OTP is verified. */
  phoneVerified: boolean;

  listings: number;
  orders: number;
  createdAt: Date;
  updatedAt: Date;
  lastLoginAt: Date | null;
}

export interface OtpDoc {
  _id?: ObjectId;
  phone: string;
  codeHash: string;
  purpose: "registration" | "reset";
  attempts: number;
  expiresAt: Date;
  createdAt: Date;
}

/** Catalogue listing — carries the whole registration record. */
export interface ProductDoc {
  _id?: ObjectId;
  id: string;
  [key: string]: unknown;
}

/** Seller submission awaiting approval. */
export interface RequestDoc {
  _id?: ObjectId;
  id: string;
  [key: string]: unknown;
}

export interface InquiryDoc {
  _id?: ObjectId;
  id: string;
  [key: string]: unknown;
}

export interface OrderDoc {
  _id?: ObjectId;
  id: string;
  [key: string]: unknown;
}

/**
 * One marketplace-wide settings document.
 *
 * The console edits it and the mobile app reads it, so category chips, the
 * home hero and every fee stay in one place.
 */
/** One panel of the app's home carousel. */
export interface HeroSlide {
  badge: string;
  title: string;
  subtitle: string;
  ctaLabel: string;
  image: string;
}

export interface SettingsDoc {
  _id: string;
  categories: { name: string; visible: boolean }[];
  /** Shown in order, one after another, on the app's home screen. */
  heroSlides: HeroSlide[];
  /** Every commercial is a percentage of the order value. */
  commercials: {
    gstRate: number;
    brokerageRate: number;
    shippingRate: number;
    platformCommission: number;
  };
  listingRules: {
    requireInspection: boolean;
    requireOwnershipProof: boolean;
    autoPublishTrusted: boolean;
    allowPriceOnRequest: boolean;
    minimumPhotos: number;
    listingExpiryDays: number;
  };
  escrow: {
    holdUntilSignOff: boolean;
    autoRelease: boolean;
    inspectionWindowDays: number;
    releaseDelayHours: number;
  };
  notifications: Record<string, boolean>;
  /** Copy the app shows on Help & Support and Terms. */
  support: {
    faqs: { question: string; answer: string }[];
    phone: string;
    email: string;
    hours: string;
    terms: string;
  };
  /** Option lists behind the seller wizard's checklists. */
  sellOptions: {
    requiredPhotos: string[];
    documentTypes: string[];
    workingStatus: string[];
    conditions: string[];
    maintenanceStatus: string[];
    ownerTypes: string[];
  };
  updatedAt: Date;
}

/**
 * A file that was stored in the database before uploads moved to a folder.
 *
 * New uploads are written to disk and only their path is kept, so this
 * collection is read-only history — `/api/files/<id>` still answers for
 * anything already in here.
 */
export interface FileDoc {
  _id?: ObjectId;
  /** Public id, including the extension — e.g. `haas-vf2ss-ms1a2b.jpg`. */
  id: string;
  filename: string;
  contentType: string;
  size: number;
  data: Binary;
  /** Account code of whoever uploaded it, or "admin". */
  uploadedBy: string;
  createdAt: Date;
}

export interface AdminDoc {
  _id?: ObjectId;
  email: string;
  name: string;
  role: string;
  passwordHash: string;
  createdAt: Date;
  lastLoginAt: Date | null;
}

export async function users(): Promise<Collection<UserDoc>> {
  return (await db()).collection<UserDoc>("users");
}

export async function otps(): Promise<Collection<OtpDoc>> {
  return (await db()).collection<OtpDoc>("otps");
}

export async function admins(): Promise<Collection<AdminDoc>> {
  return (await db()).collection<AdminDoc>("admins");
}

export async function products(): Promise<Collection<ProductDoc>> {
  return (await db()).collection<ProductDoc>("products");
}

export async function sellRequests(): Promise<Collection<RequestDoc>> {
  return (await db()).collection<RequestDoc>("sellRequests");
}

export async function inquiries(): Promise<Collection<InquiryDoc>> {
  return (await db()).collection<InquiryDoc>("inquiries");
}

export async function orders(): Promise<Collection<OrderDoc>> {
  return (await db()).collection<OrderDoc>("orders");
}

export async function files(): Promise<Collection<FileDoc>> {
  return (await db()).collection<FileDoc>("files");
}

export async function settings(): Promise<Collection<SettingsDoc>> {
  return (await db()).collection<SettingsDoc>("settings");
}

/** Shipped defaults, used until the desk saves its own. */
export const DEFAULT_SETTINGS: Omit<SettingsDoc, "_id" | "updatedAt"> = {
  categories: [
    { name: "CNC Machines", visible: true },
    { name: "VMC Centers", visible: true },
    { name: "Lathes", visible: true },
    { name: "Grinders", visible: true },
    { name: "EDM", visible: true },
  ],
  heroSlides: [
    {
      badge: "VERIFIED LISTINGS",
      title: "Mastering Precision,\nMarket-Ready.",
      subtitle:
        "Access 450+ certified CNC and VMC centers with full maintenance history and performance logs.",
      ctaLabel: "Explore Manifest",
      image: "/machines/workshop_banner.jpg",
    },
    {
      badge: "INSPECTED & GRADED",
      title: "Every Machine,\nAudited First.",
      subtitle:
        "Spindle hours, service history and a technical audit before a single listing goes live.",
      ctaLabel: "See Inspections",
      image: "/machines/vmc_machining_center.jpg",
    },
    {
      badge: "SELL IN 48 HOURS",
      title: "Idle Capacity,\nBack to Work.",
      subtitle:
        "List a machine in four steps and our sourcing desk brings verified buyers to you.",
      ctaLabel: "List a Machine",
      image: "/machines/dmg_mori_nhx.jpg",
    },
  ],
  commercials: {
    gstRate: 18,
    brokerageRate: 1.5,
    shippingRate: 0.5,
    platformCommission: 2.5,
  },
  listingRules: {
    requireInspection: true,
    requireOwnershipProof: true,
    autoPublishTrusted: false,
    allowPriceOnRequest: true,
    minimumPhotos: 6,
    listingExpiryDays: 90,
  },
  escrow: {
    holdUntilSignOff: true,
    autoRelease: true,
    inspectionWindowDays: 7,
    releaseDelayHours: 48,
  },
  notifications: {
    "New sell request submitted": true,
    "Inquiry with no broker for 24h": true,
    "Inspection report uploaded": true,
    "Order stuck in a stage for 7 days": true,
    "Weekly marketplace digest": false,
    "Seller KYC expiring": false,
  },
  support: {
    faqs: [
      {
        question: "How does MachSetu verify a machine?",
        answer:
          "Every listing goes through a technical audit — spindle hours, service history and a physical inspection — before it appears in the app.",
      },
      {
        question: "Who pays for freight and installation?",
        answer:
          "Freight is quoted as a percentage of the machine value and shown on the cart. Installation is arranged with the seller and billed separately.",
      },
      {
        question: "How long does a sell request take to approve?",
        answer:
          "Most submissions clear the sourcing desk within 48 hours. Machines needing an on-site inspection take a little longer.",
      },
      {
        question: "Can I negotiate the asking price?",
        answer:
          "Yes. Raise an inquiry and a broker will carry your offer to the seller.",
      },
    ],
    phone: "+91 84015 03169",
    email: "support@machsetu.in",
    hours: "Mon–Sat, 9:30 AM – 7:00 PM IST",
    terms:
      "MachSetu is a marketplace for second-hand industrial machines. Listings are published after a technical audit, but buyers are responsible for their own final inspection before payment. Funds are held in escrow until the inspection window closes. Brokerage and freight percentages are shown on every quote before an order is placed.",
  },
  sellOptions: {
    requiredPhotos: [
      "Front View",
      "Side View",
      "Control Panel",
      "Name Plate",
      "Spindle",
      "Tool Changer",
      "Table / Bed",
      "Electrical Panel",
      "Hydraulic Unit",
      "Coolant System",
      "Chip Conveyor",
      "Accessories",
      "Working Sample",
      "Machine in Operation",
      "Overall Shop Floor",
    ],
    documentTypes: [
      "GST Certificate",
      "Ownership Proof",
      "Purchase Invoice",
      "AMC Details",
      "Original Invoice",
      "Maintenance Records",
      "Machine Manual",
      "Warranty (If Any)",
      "Inspection Report",
      "Other",
    ],
    workingStatus: ["Running", "Idle", "Under Repair", "Not Working"],
    conditions: [
      "Excellent",
      "Good",
      "Average",
      "Like New",
      "Fair",
      "Needs Repair",
    ],
    maintenanceStatus: ["Regular", "Irregular", "Not Maintained"],
    ownerTypes: ["1st Owner", "Dealer", "Reseller"],
  },
};

/** Reads the settings document, creating it from the defaults on first run. */
export async function marketplaceSettings(): Promise<SettingsDoc> {
  const col = await settings();
  const found = await col.findOne({ _id: "marketplace" });

  if (found) {
    // Sections the document predates are filled in — all of them in one
    // pass, so a document missing several is whole after a single read.
    const missing: Partial<SettingsDoc> = {};

    if (!Array.isArray(found.heroSlides) || found.heroSlides.length === 0) {
      // Before the carousel, the home banner was a single `hero` object.
      const legacy = (found as SettingsDoc & { hero?: HeroSlide }).hero;
      missing.heroSlides = legacy ? [legacy] : DEFAULT_SETTINGS.heroSlides;
    }
    if (!Array.isArray(found.categories) || found.categories.length === 0) {
      missing.categories = DEFAULT_SETTINGS.categories;
    }
    if (!found.commercials) missing.commercials = DEFAULT_SETTINGS.commercials;
    if (!found.listingRules) {
      missing.listingRules = DEFAULT_SETTINGS.listingRules;
    }
    if (!found.escrow) missing.escrow = DEFAULT_SETTINGS.escrow;
    if (!found.notifications) {
      missing.notifications = DEFAULT_SETTINGS.notifications;
    }
    if (!found.support) missing.support = DEFAULT_SETTINGS.support;
    if (!found.sellOptions) missing.sellOptions = DEFAULT_SETTINGS.sellOptions;

    if (Object.keys(missing).length === 0) return found;

    await col.updateOne(
      { _id: "marketplace" },
      { $set: missing, $unset: { hero: "" } },
    );

    const merged = { ...found, ...missing };
    // The legacy key is gone from the database, so it leaves the reply too.
    delete (merged as SettingsDoc & { hero?: HeroSlide }).hero;
    return merged;
  }

  const fresh: SettingsDoc = {
    _id: "marketplace",
    ...DEFAULT_SETTINGS,
    updatedAt: new Date(),
  };
  await col.insertOne(fresh);
  return fresh;
}

/**
 * Next id in a series, e.g. `MS-1016`. Uses findOneAndUpdate so two parallel
 * requests can never take the same number.
 */
export async function nextId(series: string, prefix: string, start: number) {
  const counters = (await db()).collection<{ _id: string; value: number }>(
    "counters",
  );
  const doc = await counters.findOneAndUpdate(
    { _id: series },
    { $inc: { value: 1 }, $setOnInsert: {} },
    { upsert: true, returnDocument: "after" },
  );
  return `${prefix}${start + (doc?.value ?? 1)}`;
}

/**
 * Pushes a counter past the highest id already in a collection.
 *
 * Imported seed data carries its own ids, so without this the first generated
 * id would collide with `MS-1001`.
 */
export async function syncCounter(
  series: string,
  prefix: string,
  start: number,
  collection: string,
): Promise<void> {
  const database = await db();
  const docs = await database
    .collection<{ id: string }>(collection)
    .find({}, { projection: { id: 1 } })
    .toArray();

  let highest = 0;
  for (const doc of docs) {
    const id = String(doc.id ?? "");
    if (!id.startsWith(prefix)) continue;
    const n = Number(id.slice(prefix.length));
    if (Number.isFinite(n) && n - start > highest) highest = n - start;
  }
  if (highest === 0) return;

  const counters = database.collection<{ _id: string; value: number }>(
    "counters",
  );
  await counters.updateOne(
    { _id: series, value: { $lt: highest } },
    { $set: { value: highest } },
    { upsert: false },
  );
  await counters.updateOne(
    { _id: series },
    { $setOnInsert: { value: highest } },
    { upsert: true },
  );
}

/**
 * Unique indexes and the OTP TTL. Safe to call on every request — Mongo
 * treats a matching createIndex as a no-op.
 */
let ensured = false;
export async function ensureIndexes(): Promise<void> {
  if (ensured) return;

  const u = await users();
  await u.createIndex({ email: 1 }, { unique: true });
  await u.createIndex({ phone: 1 }, { unique: true });
  await u.createIndex({ code: 1 }, { unique: true });

  const o = await otps();
  await o.createIndex({ phone: 1, purpose: 1 });
  // Mongo removes expired codes on its own.
  await o.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 });

  const a = await admins();
  await a.createIndex({ email: 1 }, { unique: true });

  await (await products()).createIndex({ id: 1 }, { unique: true });
  await (await sellRequests()).createIndex({ id: 1 }, { unique: true });
  await (await inquiries()).createIndex({ id: 1 }, { unique: true });
  await (await orders()).createIndex({ id: 1 }, { unique: true });
  await (await sellRequests()).createIndex({ userCode: 1 });
  await (await inquiries()).createIndex({ userCode: 1 });
  await (await files()).createIndex({ id: 1 }, { unique: true });

  await syncCounter("products", "MS-", 1000, "products");
  await syncCounter("requests", "REQ-", 5500, "sellRequests");
  await syncCounter("inquiries", "RFQ-", 4470, "inquiries");

  ensured = true;
}
