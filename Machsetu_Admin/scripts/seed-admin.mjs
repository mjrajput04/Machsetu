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

const ACCOUNTS = [
  {
    email: "admin@machsetu.in",
    name: "Admin Desk",
    role: "Super Admin",
    password: "Machsetu@2026",
  },
  {
    email: "ops@machsetu.in",
    name: "Operations",
    role: "Operations",
    password: "Ops@2026",
  },
];

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
