/**
 * Seeds the console admin accounts.
 *
 *   node scripts/seed-admin.mjs
 *
 * Passwords are bcrypt-hashed before they touch the database — the plain
 * text never leaves this file.
 */
import bcrypt from "bcryptjs";
import { MongoClient } from "mongodb";

const uri = process.env.MONGODB_URI ?? "mongodb://127.0.0.1:27017";
const dbName = process.env.MONGODB_DB ?? "machsetu";

// Production passwords come from the environment so the real ones never sit
// in the repository; the defaults are for local development only.
const ACCOUNTS = [
  {
    email: process.env.ADMIN_EMAIL ?? "admin@machsetu.in",
    name: "Admin Desk",
    role: "Super Admin",
    password: process.env.ADMIN_PASSWORD ?? "Machsetu@2026",
  },
  {
    email: process.env.OPS_EMAIL ?? "ops@machsetu.in",
    name: "Operations",
    role: "Operations",
    password: process.env.OPS_PASSWORD ?? "Ops@2026",
  },
];

for (const account of ACCOUNTS) {
  if (account.password.length < 8) {
    throw new Error(`Set a longer password for ${account.email}`);
  }
}

const client = new MongoClient(uri);
await client.connect();
const admins = client.db(dbName).collection("admins");
await admins.createIndex({ email: 1 }, { unique: true });

for (const account of ACCOUNTS) {
  const passwordHash = await bcrypt.hash(account.password, 10);
  await admins.updateOne(
    { email: account.email },
    {
      $set: {
        email: account.email,
        name: account.name,
        role: account.role,
        passwordHash,
      },
      $setOnInsert: { createdAt: new Date(), lastLoginAt: null },
    },
    { upsert: true },
  );
  console.log(`seeded ${account.email}`);
}

await client.close();
console.log("done");
