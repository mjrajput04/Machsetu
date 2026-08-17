import { ensureIndexes, users } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

/** Real registered users for the admin console. */
export async function GET(request: Request) {
  await ensureIndexes();

  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "admin") return fail("Not authorised", 401);

  const col = await users();
  const docs = await col.find({}).sort({ createdAt: -1 }).toArray();

  return ok({
    users: docs.map((u) => ({
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
      joinedOn: u.createdAt.toISOString(),
      lastLoginAt: u.lastLoginAt ? u.lastLoginAt.toISOString() : null,
    })),
  });
}
