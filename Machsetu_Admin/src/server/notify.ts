import { db } from "./db";

export interface NotificationInput {
  title: string;
  body: string;
  /** Drives the icon and tint the app draws. */
  kind: "order" | "listing" | "inquiry" | "account" | "system";
  /** The order, listing or RFQ this is about. */
  reference?: string;
  image?: string | null;
}

/**
 * Writes one notification for a user.
 *
 * Called wherever something happens the account holder should hear about —
 * an order placed, a listing approved, a quote received — so the app's
 * notification list is a record of real events rather than sample copy.
 */
export async function notify(
  userCode: string,
  input: NotificationInput,
): Promise<void> {
  const database = await db();
  await database.collection("notifications").insertOne({
    userCode,
    title: input.title,
    body: input.body,
    kind: input.kind,
    reference: input.reference ?? null,
    image: input.image ?? null,
    read: false,
    createdAt: new Date(),
  });
}
