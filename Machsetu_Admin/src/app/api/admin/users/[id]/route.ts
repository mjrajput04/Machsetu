import { ensureIndexes, users } from "@/server/db";
import { fail, normEmail, normPhone, ok, readToken } from "@/server/auth";

function requireAdmin(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  return token && token.kind === "admin" ? token : null;
}

type Ctx = { params: Promise<{ id: string }> };

function shape(u: Record<string, unknown>) {
  const createdAt = u.createdAt as Date | undefined;
  const lastLoginAt = u.lastLoginAt as Date | null | undefined;
  return {
    id: u.code,
    name: u.name,
    avatar: u.avatar ?? "",
    designation: u.designation,
    company: u.company,
    email: u.email,
    phone: u.phone,
    whatsapp: u.phone,
    address: u.address,
    city: u.city,
    state: u.state,
    pincode: u.zip,
    gstin: u.gstin,
    pan: u.pan,
    role: u.role,
    status: u.status,
    phoneVerified: u.phoneVerified,
    twoFactor: u.twoFactor,
    biometrics: u.biometrics,
    loginAlerts: u.loginAlerts,
    listings: u.listings,
    orders: u.orders,
    joinedOn: createdAt ? createdAt.toISOString() : null,
    lastLoginAt: lastLoginAt ? lastLoginAt.toISOString() : null,
  };
}

export async function GET(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const col = await users();
  const user = await col.findOne({ code: id });
  if (!user) return fail("User not found", 404);
  return ok({ user: shape(user) });
}

/** Full profile edit from the console, including role and account status. */
export async function PUT(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const col = await users();
  const user = await col.findOne({ code: id });
  if (!user) return fail("User not found", 404);

  const patch: Record<string, unknown> = { updatedAt: new Date() };
  const text = (key: string, target = key) => {
    if (body[key] !== undefined) patch[target] = String(body[key]).trim();
  };

  text("name");
  text("avatar");
  text("designation");
  text("company");
  text("address");
  text("city");
  text("state");
  text("pincode", "zip");

  if (body.gstin !== undefined) patch.gstin = String(body.gstin).trim().toUpperCase();
  if (body.pan !== undefined) patch.pan = String(body.pan).trim().toUpperCase();

  if (body.email !== undefined) {
    const email = normEmail(body.email);
    if (email !== user.email && (await col.findOne({ email }))) {
      return fail("This email is already in use", 409);
    }
    patch.email = email;
  }

  if (body.phone !== undefined) {
    const phone = normPhone(body.phone);
    if (phone.length !== 10) return fail("Enter a valid 10-digit mobile number");
    if (phone !== user.phone && (await col.findOne({ phone }))) {
      return fail("This mobile number is already in use", 409);
    }
    patch.phone = phone;
  }

  const roles = ["Buyer", "Seller", "Both", "Broker"];
  if (roles.includes(body.role)) patch.role = body.role;

  const statuses = ["Active", "Pending KYC", "Suspended"];
  if (statuses.includes(body.status)) patch.status = body.status;

  if (typeof body.phoneVerified === "boolean") {
    patch.phoneVerified = body.phoneVerified;
  }

  await col.updateOne({ code: id }, { $set: patch });
  const fresh = await col.findOne({ code: id });
  return ok({ user: shape(fresh!) });
}

export async function DELETE(request: Request, ctx: Ctx) {
  await ensureIndexes();
  if (!requireAdmin(request)) return fail("Not authorised", 401);

  const { id } = await ctx.params;
  const col = await users();
  const result = await col.deleteOne({ code: id });
  if (result.deletedCount === 0) return fail("User not found", 404);
  return ok({ deleted: id });
}
