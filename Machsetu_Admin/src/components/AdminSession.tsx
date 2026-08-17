"use client";

import { useRouter } from "next/navigation";
import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useSyncExternalStore,
  type ReactNode,
} from "react";

export interface AdminAccount {
  email: string;
  name: string;
  role: string;
}

interface SessionValue {
  token: string | null;
  admin: AdminAccount | null;
  ready: boolean;
  signIn: (token: string, admin: AdminAccount) => void;
  signOut: () => void;
}

const KEY = "machsetu.admin.session";
const EVENT = "machsetu-admin-session";

/* --------------------------------------------------------- external store -- */
/* localStorage is outside React, so it is read through useSyncExternalStore
   rather than an effect — no cascading renders, no hydration mismatch. */

function subscribe(onChange: () => void) {
  window.addEventListener(EVENT, onChange);
  window.addEventListener("storage", onChange);
  return () => {
    window.removeEventListener(EVENT, onChange);
    window.removeEventListener("storage", onChange);
  };
}

/** Returns the raw string so the snapshot stays referentially stable. */
function getSnapshot(): string | null {
  return localStorage.getItem(KEY);
}

/** The server has no session; the client fills it in after hydration. */
function getServerSnapshot(): string | null {
  return null;
}

const Ctx = createContext<SessionValue | null>(null);

/**
 * Console session held in localStorage.
 *
 * Good enough for an internal tool on a trusted network; move to an
 * httpOnly cookie before exposing this beyond the office.
 */
export function AdminSessionProvider({ children }: { children: ReactNode }) {
  const raw = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
  const router = useRouter();

  // `ready` flips once React has hydrated and the real value is available.
  const hydrated = useSyncExternalStore(
    subscribe,
    () => true,
    () => false,
  );

  const parsed = useMemo(() => {
    if (!raw) return { token: null, admin: null };
    try {
      const value = JSON.parse(raw) as { token: string; admin: AdminAccount };
      return { token: value.token, admin: value.admin };
    } catch {
      return { token: null, admin: null };
    }
  }, [raw]);

  const signIn = useCallback((token: string, admin: AdminAccount) => {
    localStorage.setItem(KEY, JSON.stringify({ token, admin }));
    window.dispatchEvent(new Event(EVENT));
  }, []);

  const signOut = useCallback(() => {
    localStorage.removeItem(KEY);
    window.dispatchEvent(new Event(EVENT));
    router.push("/login");
  }, [router]);

  const value = useMemo(
    () => ({ ...parsed, ready: hydrated, signIn, signOut }),
    [parsed, hydrated, signIn, signOut],
  );

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useAdminSession(): SessionValue {
  const value = useContext(Ctx);
  if (!value) {
    throw new Error("useAdminSession must be used inside AdminSessionProvider");
  }
  return value;
}
