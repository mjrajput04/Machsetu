"use client";

import { useState, type FormEvent } from "react";
import { CONTACT_TOPICS as TOPICS, type ContactTopic } from "@/lib/site";
import { cx } from "@/components/ui";
import { Arrow } from "./icons";

type Status =
  | { kind: "idle" }
  | { kind: "sending" }
  | { kind: "sent" }
  | { kind: "error"; message: string };

const input =
  "w-full rounded-xl border border-line bg-white px-4 py-3 text-sm text-ink outline-none transition placeholder:text-faint focus:border-navy-600 focus:ring-4 focus:ring-navy-600/10";

export function ContactForm({
  initialTopic,
  initialMessage,
}: {
  initialTopic: ContactTopic;
  initialMessage: string;
}) {
  const [status, setStatus] = useState<Status>({ kind: "idle" });

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const body = Object.fromEntries(new FormData(form));

    setStatus({ kind: "sending" });
    try {
      const response = await fetch("/api/contact", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(body),
      });
      const payload = await response.json().catch(() => ({}));
      if (!response.ok || payload?.ok === false) {
        throw new Error(payload?.message ?? "Something went wrong. Please try again.");
      }
      form.reset();
      setStatus({ kind: "sent" });
    } catch (err) {
      setStatus({ kind: "error", message: (err as Error).message });
    }
  }

  if (status.kind === "sent") {
    return (
      <div className="grid min-h-[420px] place-items-center rounded-[28px] border border-emerald-100 bg-emerald-50/60 p-8 text-center">
        <div>
          <span className="mx-auto grid h-16 w-16 place-items-center rounded-full bg-emerald-500 text-white shadow-lg">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={3} className="h-8 w-8">
              <path d="m5 12 5 5L20 7" />
            </svg>
          </span>
          <p className="mt-6 text-2xl font-extrabold text-navy-900">Message sent!</p>
          <p className="mx-auto mt-2 max-w-sm text-muted">
            Thank you for reaching out. A member of the MachSetu team will get
            back to you soon.
          </p>
          <button
            onClick={() => setStatus({ kind: "idle" })}
            className="mt-6 text-sm font-bold text-accent-600 hover:text-accent-700"
          >
            Send another message
          </button>
        </div>
      </div>
    );
  }

  const sending = status.kind === "sending";

  return (
    <form
      onSubmit={onSubmit}
      className="rounded-[28px] border border-line bg-white p-6 shadow-[0_24px_60px_-30px_rgba(14,46,92,0.3)] sm:p-8"
    >
      <h2 className="text-2xl font-extrabold text-navy-900">Send us a message</h2>
      <p className="mt-1 text-sm text-muted">
        Fields marked <span className="text-accent-600">*</span> are required.
      </p>

      <div className="mt-6 grid gap-4 sm:grid-cols-2">
        <label className="block">
          <span className="mb-1.5 block text-sm font-semibold text-navy-900">
            Full name <span className="text-accent-600">*</span>
          </span>
          <input name="name" required maxLength={120} autoComplete="name" placeholder="Your name" className={input} />
        </label>
        <label className="block">
          <span className="mb-1.5 block text-sm font-semibold text-navy-900">Company</span>
          <input name="company" maxLength={160} autoComplete="organization" placeholder="Company / workshop" className={input} />
        </label>
        <label className="block">
          <span className="mb-1.5 block text-sm font-semibold text-navy-900">
            Email <span className="text-accent-600">*</span>
          </span>
          <input name="email" type="email" required maxLength={160} autoComplete="email" placeholder="you@company.com" className={input} />
        </label>
        <label className="block">
          <span className="mb-1.5 block text-sm font-semibold text-navy-900">Mobile number</span>
          <div className="flex">
            <span className="grid place-items-center rounded-l-xl border border-r-0 border-line bg-canvas px-3 text-sm font-semibold text-muted">
              +91
            </span>
            <input
              name="phone"
              type="tel"
              inputMode="numeric"
              pattern="[0-9 ]{10,12}"
              maxLength={12}
              autoComplete="tel-national"
              placeholder="98765 43210"
              className={cx(input, "rounded-l-none")}
            />
          </div>
        </label>
      </div>

      <fieldset className="mt-5">
        <legend className="mb-2 text-sm font-semibold text-navy-900">I&apos;m interested in</legend>
        <div className="flex flex-wrap gap-2">
          {TOPICS.map((topic) => (
            <label key={topic} className="cursor-pointer">
              <input
                type="radio"
                name="topic"
                value={topic}
                defaultChecked={topic === initialTopic}
                className="peer sr-only"
              />
              <span className="inline-flex rounded-full border border-line px-4 py-2 text-sm font-semibold text-muted transition peer-checked:border-navy-900 peer-checked:bg-navy-900 peer-checked:text-white peer-focus-visible:ring-4 peer-focus-visible:ring-navy-600/20 hover:border-navy-600">
                {topic}
              </span>
            </label>
          ))}
        </div>
      </fieldset>

      <label className="mt-5 block">
        <span className="mb-1.5 block text-sm font-semibold text-navy-900">
          Message <span className="text-accent-600">*</span>
        </span>
        <textarea
          name="message"
          required
          minLength={10}
          maxLength={4000}
          rows={5}
          defaultValue={initialMessage}
          placeholder="Machine type, make, model, budget, location — anything that helps us help you."
          className={cx(input, "resize-y")}
        />
      </label>

      {/* Honeypot — hidden from people, tempting to bots. */}
      <input
        type="text"
        name="website"
        tabIndex={-1}
        autoComplete="off"
        aria-hidden
        className="absolute -left-[9999px] h-0 w-0 opacity-0"
      />

      {status.kind === "error" && (
        <p role="alert" className="mt-4 rounded-xl bg-rose-50 px-4 py-3 text-sm font-semibold text-rose-700">
          {status.message}
        </p>
      )}

      <button
        type="submit"
        disabled={sending}
        className="mt-6 inline-flex w-full items-center justify-center gap-2 rounded-full bg-accent-500 px-6 py-4 text-sm font-bold text-white shadow-[0_12px_30px_-10px_rgba(249,115,22,0.8)] transition hover:-translate-y-0.5 hover:bg-accent-600 disabled:translate-y-0 disabled:opacity-60 sm:w-auto"
      >
        {sending ? "Sending…" : "Send message"}
        {!sending && <Arrow className="h-4 w-4" />}
      </button>
    </form>
  );
}
