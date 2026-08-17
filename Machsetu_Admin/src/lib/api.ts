"use client";

import { useCallback, useEffect, useRef, useState } from "react";

/**
 * Browser-side calls into the console API.
 *
 * The bearer token lives in the same localStorage entry the session provider
 * writes, so any page can call these without threading the token through
 * props.
 */
const KEY = "machsetu.admin.session";

export function adminToken(): string | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(KEY);
    return raw ? (JSON.parse(raw).token as string) : null;
  } catch {
    return null;
  }
}

export class ApiError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  const token = adminToken();
  const headers = new Headers(init.headers);
  if (token) headers.set("authorization", `Bearer ${token}`);
  if (init.body && !(init.body instanceof FormData)) {
    headers.set("content-type", "application/json");
  }

  const response = await fetch(path, { ...init, headers, cache: "no-store" });
  const payload = await response.json().catch(() => ({}));

  if (!response.ok || payload?.ok === false) {
    throw new ApiError(
      payload?.message ?? "Something went wrong. Try again.",
      response.status,
    );
  }
  return payload as T;
}

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, body: unknown) =>
    request<T>(path, { method: "POST", body: JSON.stringify(body) }),
  put: <T>(path: string, body: unknown) =>
    request<T>(path, { method: "PUT", body: JSON.stringify(body) }),
  del: <T>(path: string) => request<T>(path, { method: "DELETE" }),

  /** Multipart upload; returns the public URLs of the stored files. */
  upload: async (files: File[]) => {
    const form = new FormData();
    files.forEach((file) => form.append("file", file));
    return request<{ files: { url: string; name: string; size: number }[] }>(
      "/api/upload",
      { method: "POST", body: form },
    );
  },
};

interface Resource<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
  reload: () => void;
  /** Lets a page apply an optimistic change without a round trip. */
  set: (value: T) => void;
}

/**
 * Re-runs `reload` on a timer for as long as the component is mounted.
 *
 * Used by the pages a desk leaves open — an order placed in the app, or a
 * machine submitted for review, lands without anyone pressing refresh.
 */
export function usePolling(reload: () => void, everyMs = 20_000) {
  const latest = useRef(reload);

  // Kept in a ref so a new closure each render does not restart the timer.
  useEffect(() => {
    latest.current = reload;
  }, [reload]);

  useEffect(() => {
    const id = setInterval(() => latest.current(), everyMs);
    return () => clearInterval(id);
  }, [everyMs]);
}

interface Loaded<T> {
  /** Which request produced this result — path plus the reload counter. */
  key: string;
  data: T | null;
  error: string | null;
}

/**
 * GET a path, re-fetching whenever `path` changes or `reload()` is called.
 *
 * State is only written from the response callback; `loading` is derived by
 * comparing the request we want against the one we last stored, so nothing is
 * set synchronously inside the effect.
 */
export function useApi<T>(path: string | null): Resource<T> {
  const [tick, setTick] = useState(0);
  const [result, setResult] = useState<Loaded<T>>({
    key: "",
    data: null,
    error: null,
  });

  const key = path ? `${path}#${tick}` : "";

  // Guards against a slow response from an earlier path overwriting a newer one.
  const latest = useRef("");

  useEffect(() => {
    if (!path) return;
    latest.current = key;

    api
      .get<T>(path)
      .then((value) => {
        if (latest.current === key)
          setResult({ key, data: value, error: null });
      })
      .catch((err: Error) => {
        if (latest.current === key) {
          setResult({ key, data: null, error: err.message });
        }
      });
  }, [path, key]);

  const reload = useCallback(() => setTick((t) => t + 1), []);
  const settled = result.key === key;

  return {
    data: settled ? result.data : null,
    loading: Boolean(path) && !settled,
    error: settled ? result.error : null,
    reload,
    set: (value: T) => setResult({ key, data: value, error: null }),
  };
}
