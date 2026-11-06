import { contactMessages } from "@/server/db";
import { fail, ok, readToken } from "@/server/auth";

/** Messages from the website's contact page, newest first. */
export async function GET(request: Request) {
  const token = readToken(request.headers.get("authorization"));
  if (!token || token.kind !== "admin") return fail("Not authorised", 401);

  const docs = await (await contactMessages())
    .find({}, { projection: { _id: 0 } })
    .sort({ createdAt: -1 })
    .limit(500)
    .toArray();
  return ok({ messages: docs });
}
