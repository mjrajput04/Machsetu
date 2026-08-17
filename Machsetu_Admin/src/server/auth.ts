import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { NextResponse } from "next/server";
import type { UserDoc } from "./db";

/**
 * Password hashing and JWT helpers.
 *
 * The secret falls back to a development constant so the project runs out of
 * the box; set JWT_SECRET in `.env.local` before any real deployment.
 */
const SECRET = process.env.JWT_SECRET ?? "machsetu-dev-secret-change-me";
const ROUNDS = 10;

export function hashPassword(plain: string): Promise<string> {
  return bcrypt.hash(plain, ROUNDS);
}

export function verifyPassword(plain: string, hash: string): Promise<boolean> {
  return bcrypt.compare(plain, hash);
}

export type TokenKind = "user" | "admin";

export interface TokenPayload {
  sub: string;
  kind: TokenKind;
}

export function signToken(sub: string, kind: TokenKind): string {
  return jwt.sign({ sub, kind } satisfies TokenPayload, SECRET, {
    expiresIn: "30d",
  });
}

export function readToken(header: string | null): TokenPayload | null {
  if (!header?.startsWith("Bearer ")) return null;
  try {
    return jwt.verify(header.slice(7), SECRET) as TokenPayload;
  } catch {
    return null;
  }
}

/* --------------------------------------------------------------- shapes -- */

/** The user object returned to clients — never includes the password hash. */
export function publicUser(doc: UserDoc) {
  return {
    id: doc.code,
    name: doc.name,
    email: doc.email,
    phone: doc.phone,
    avatar: doc.avatar ?? "",
    designation: doc.designation,
    company: doc.company,
    gstin: doc.gstin,
    pan: doc.pan,
    address: doc.address,
    city: doc.city,
    state: doc.state,
    zip: doc.zip,
    twoFactor: doc.twoFactor,
    biometrics: doc.biometrics,
    loginAlerts: doc.loginAlerts,
    role: doc.role,
    status: doc.status,
    phoneVerified: doc.phoneVerified,
  };
}

export function ok(data: Record<string, unknown>, status = 200) {
  return NextResponse.json({ ok: true, ...data }, { status });
}

export function fail(message: string, status = 400) {
  return NextResponse.json({ ok: false, message }, { status });
}

/* --------------------------------------------------------- normalisation -- */

export function normEmail(value: unknown): string {
  return String(value ?? "").trim().toLowerCase();
}

/** Strips spaces, dashes and a +91 prefix so lookups always match. */
export function normPhone(value: unknown): string {
  const digits = String(value ?? "").replace(/\D/g, "");
  return digits.length > 10 ? digits.slice(-10) : digits;
}

export function isEmail(value: string): boolean {
  return /^[\w.\-+]+@([\w-]+\.)+[a-zA-Z]{2,}$/.test(value);
}
