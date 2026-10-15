import { unlink } from "node:fs/promises";
import {
  db,
  ensureIndexes,
  inquiries,
  otps,
  sellRequests,
  users,
  type UserDoc,
} from "@/server/db";
import {
  fail,
  isEmail,
  normEmail,
  normPhone,
  ok,
  readToken,
  verifyPassword,
} from "@/server/auth";
import { uploadPath } from "@/server/storage";

/**
 * Permanently deletes a user's own account — the endpoint behind the app's
 * "Delete Account" button and the public machsetu.com/delete-account page,
 * which Google Play requires for any app that lets people sign up.
 *
 * Two ways in, both needing the account password:
 *   - the app sends its bearer token plus `password`;
 *   - the web page sends `identifier` (email or mobile) plus `password`.
 *
 * Erased: the profile, saved addresses, profile photo, notifications, pending
 * OTPs, sell requests and inquiries. Orders are kept, with the buyer's
 * contact details stripped, because GST law requires the invoice trail to be
 * retained — the privacy policy says so.
 */
export async function POST(request: Request) {
  await ensureIndexes();

  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  const password = String(body.password ?? "");
  if (!password) return fail("Enter your password to confirm");

  const col = await users();
  let user: UserDoc | null = null;

  const token = readToken(request.headers.get("authorization"));
  if (token && token.kind === "user") {
    user = await col.findOne({ code: token.sub });
  } else {
    const raw = String(body.identifier ?? "").trim();
    if (!raw) return fail("Enter your email or mobile number");
    const asEmail = normEmail(raw);
    const asPhone = normPhone(raw);
    user = isEmail(asEmail)
      ? await col.findOne({ email: asEmail })
      : asPhone.length === 10
        ? await col.findOne({ phone: asPhone })
        : null;
  }

  // One message for "no such account" and "wrong password", so the page
  // cannot be used to discover which emails or numbers are registered.
  if (!user || !(await verifyPassword(password, user.passwordHash))) {
    return fail("Incorrect credentials", 401);
  }

  const code = user.code;
  const database = await db();

  await Promise.all([
    database.collection("notifications").deleteMany({ userCode: code }),
    (await otps()).deleteMany({ phone: user.phone }),
    (await sellRequests()).deleteMany({ userCode: code }),
    (await inquiries()).deleteMany({ userCode: code }),
    database.collection("orders").updateMany(
      { userCode: code },
      {
        $set: {
          "customer.name": "Deleted user",
          "customer.email": "",
          "customer.phone": "",
          accountDeleted: true,
          updatedAt: new Date(),
        },
      },
    ),
  ]);

  await col.deleteOne({ _id: user._id });

  // The profile photo is the one upload that belongs to the person rather
  // than to a listing; a missing file is not worth failing the request over.
  const photo = user.avatar ? uploadPath(user.avatar) : null;
  if (photo) await unlink(photo).catch(() => undefined);

  return ok({ deleted: true });
}
