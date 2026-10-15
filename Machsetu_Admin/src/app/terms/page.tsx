import type { Metadata } from "next";
import Link from "next/link";
import { CONTACT, PublicPage, Section } from "@/components/PublicPage";

export const metadata: Metadata = {
  title: "Terms of Use | MachSetu",
  description: "The terms for using the MachSetu machine marketplace.",
};

/** Mirrors the Terms & Conditions screen in the app. */
export default function TermsPage() {
  return (
    <PublicPage title="Terms of Use" updated="15 October 2026">
      <p className="mb-9 text-[15px] leading-7 text-ink">
        These terms apply to the MachSetu mobile app and the website at
        machsetu.com. By creating an account or using the Service you agree to
        them. If you do not agree, please do not use MachSetu.
      </p>

      <Section title="1. Scope of the marketplace">
        <p>
          MachSetu operates a business-to-business marketplace connecting
          buyers and sellers of CNC, VMC and allied industrial machinery in
          India. MachSetu facilitates discovery, technical verification, escrow
          and logistics; it is not the manufacturer or owner of the machines
          listed.
        </p>
        <p>
          Accounts are for businesses and their authorised staff, aged 18 or
          over. You confirm you are authorised to act for the organisation you
          name, and that the details you give us are true.
        </p>
      </Section>

      <Section title="2. Listings and technical audits">
        <p>
          Sellers are responsible for the accuracy of specifications, spindle
          hours and maintenance history submitted with a listing, and must own
          or be authorised to sell the machine. Audit reports reflect the
          condition observed on the audit date and are not a warranty of future
          performance.
        </p>
        <p>
          Buyers are responsible for their own final inspection before payment.
          Where a discrepancy between the audit report and the delivered
          machine is established, the escrow release is suspended pending
          resolution.
        </p>
      </Section>

      <Section title="3. Prices, fees and escrow">
        <p>
          Brokerage, freight, GST and platform fees are shown on every quote
          before an order is placed. Funds are held in escrow until the
          inspection window closes, after which they are released to the
          seller.
        </p>
      </Section>

      <Section title="4. Delivery and cancellation">
        <p>
          Delivery windows are estimates. MachSetu is not liable for delays
          caused by force majeure, port congestion or regulatory holds.
        </p>
        <p>
          An inquiry may be withdrawn at no cost before a firm quote is
          accepted. After acceptance, cancellation charges may apply to cover
          rigging, transport and restocking already committed.
        </p>
      </Section>

      <Section title="5. Acceptable use">
        <ul>
          <li>Do not post false, misleading or stolen listings.</li>
          <li>Do not use another person&apos;s account or details.</li>
          <li>
            Do not try to break, overload or gain unauthorised access to the
            Service.
          </li>
        </ul>
        <p>
          We may remove listings or suspend accounts that break these terms.
        </p>
      </Section>

      <Section title="6. Privacy and account deletion">
        <p>
          Our{" "}
          <Link href="/privacy" className="font-semibold text-navy-600 underline">
            Privacy Policy
          </Link>{" "}
          explains how we handle your data. You can delete your account at any
          time from the app (Profile → Security → Delete Account) or on our{" "}
          <Link
            href="/delete-account"
            className="font-semibold text-navy-600 underline"
          >
            account deletion page
          </Link>
          .
        </p>
      </Section>

      <Section title="7. Liability">
        <p>
          To the extent permitted by law, MachSetu&apos;s aggregate liability in
          connection with any transaction is limited to the platform fees
          received for that transaction. Nothing in these terms limits
          liability for fraud or for death or personal injury caused by
          negligence.
        </p>
      </Section>

      <Section title="8. Governing law">
        <p>
          These terms are governed by the laws of India. Disputes are subject
          to the exclusive jurisdiction of the courts at Ahmedabad, Gujarat.
        </p>
      </Section>

      <Section title="9. Contact">
        <p>
          {CONTACT.company}, {CONTACT.address}
          <br />
          Email:{" "}
          <a
            href={`mailto:${CONTACT.email}`}
            className="font-semibold text-navy-600 underline"
          >
            {CONTACT.email}
          </a>{" "}
          · Phone: {CONTACT.phone}
        </p>
      </Section>
    </PublicPage>
  );
}
