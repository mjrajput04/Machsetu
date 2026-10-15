import type { Metadata } from "next";
import { CONTACT, PublicPage, Section } from "@/components/PublicPage";
import { DeleteAccountForm } from "./DeleteAccountForm";

export const metadata: Metadata = {
  title: "Delete your account | MachSetu",
  description:
    "Permanently delete your MachSetu account and the data linked to it.",
};

/**
 * The account-deletion URL given to Google Play. It has to work for someone
 * who no longer has the app installed, so it signs in with the same email or
 * mobile number and password as the app.
 */
export default function DeleteAccountPage() {
  return (
    <PublicPage title="Delete your MachSetu account">
      <p className="mb-8 text-[15px] leading-7 text-ink">
        You can permanently delete your MachSetu account and the personal data
        linked to it. You can do this in the app, or right here on this page.
      </p>

      <Section title="Option 1: In the app">
        <ul>
          <li>Open the MachSetu app and sign in.</li>
          <li>Go to Profile → Security.</li>
          <li>Tap Delete Account, enter your password and confirm.</li>
        </ul>
      </Section>

      <Section title="Option 2: On this page">
        <p>
          Enter the email or mobile number and password you use to sign in to
          MachSetu.
        </p>
        <DeleteAccountForm />
      </Section>

      <Section title="What gets deleted">
        <ul>
          <li>Your profile: name, email, mobile number, password and photo</li>
          <li>Company details, GSTIN, PAN and saved addresses</li>
          <li>Your machine listings, uploaded photos and documents</li>
          <li>Your inquiries and notifications</li>
        </ul>
        <p>Deletion happens immediately and cannot be undone.</p>
      </Section>

      <Section title="What we keep">
        <p>
          Records of orders you placed (invoice, company, GSTIN and billing
          details) are kept for up to 8 years because Indian tax law requires
          it. Your name, email and phone number are removed from them.
        </p>
      </Section>

      <Section title="Forgot your password?">
        <p>
          Reset it from the app&apos;s sign-in screen (Forgot Password), or email{" "}
          <a
            href={`mailto:${CONTACT.email}?subject=${encodeURIComponent("Delete my MachSetu account")}`}
            className="font-semibold text-navy-600 underline"
          >
            {CONTACT.email}
          </a>{" "}
          from your registered email address with the subject &quot;Delete my
          MachSetu account&quot;. We will verify it is you and delete the
          account within 7 days.
        </p>
      </Section>
    </PublicPage>
  );
}
