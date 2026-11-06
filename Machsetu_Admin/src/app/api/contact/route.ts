import { contactMessages, nextId } from "@/server/db";
import { fail, isEmail, normEmail, normPhone, ok } from "@/server/auth";
import { CONTACT_TOPICS } from "@/lib/site";

/** Trims a field and caps its length, so one form can't flood the database. */
function field(value: unknown, max: number): string {
  return String(value ?? "").trim().slice(0, max);
}

/**
 * Takes a message from the website's contact page and files it for the desk.
 *
 * Public on purpose. The `website` field is a honeypot: people never see it,
 * so a request that fills it in came from a bot and is dropped quietly.
 */
export async function POST(request: Request) {
  const body = await request.json().catch(() => null);
  if (!body) return fail("Invalid request body");

  if (field(body.website, 200)) return ok({ received: true });

  const name = field(body.name, 120);
  const email = normEmail(field(body.email, 160));
  const phone = normPhone(body.phone);
  const message = field(body.message, 4000);
  const topic = (CONTACT_TOPICS as readonly string[]).includes(body.topic)
    ? String(body.topic)
    : "Other";

  if (!name) return fail("Please tell us your name");
  if (!isEmail(email)) return fail("Please enter a valid email address");
  if (phone && phone.length !== 10) {
    return fail("Please enter a 10-digit mobile number");
  }
  if (message.length < 10) return fail("Please write a little more about what you need");

  try {
    const col = await contactMessages();
    await col.insertOne({
      id: await nextId("contactMessages", "MSG-", 1000),
      name,
      company: field(body.company, 160),
      email,
      phone,
      topic,
      message,
      status: "New",
      createdAt: new Date(),
    });
    return ok({ received: true }, 201);
  } catch {
    return fail("We couldn't send your message right now. Please call or email us.", 503);
  }
}
