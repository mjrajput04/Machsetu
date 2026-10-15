import type { Metadata } from "next";
import Link from "next/link";
import { CONTACT, PublicPage, Section } from "@/components/PublicPage";

export const metadata: Metadata = {
  title: "Privacy Policy | MachSetu",
  description:
    "How the MachSetu app and website collect, use, share and delete your data.",
};

export default function PrivacyPage() {
  return (
    <PublicPage title="Privacy Policy" updated="15 October 2026">
      <p className="mb-9 text-[15px] leading-7 text-ink">
        This policy explains how MachSetu (&quot;MachSetu&quot;,
        &quot;we&quot;, &quot;us&quot;) collects, uses, shares and protects
        information when you use the MachSetu mobile app and the website at
        machsetu.com (together, the &quot;Service&quot;). MachSetu is a
        business-to-business marketplace for buying and selling CNC, VMC and
        other industrial machines in India. By using the Service you agree to
        this policy.
      </p>

      <Section title="1. Information we collect">
        <p>
          <strong>Information you give us</strong>
        </p>
        <ul>
          <li>
            <strong>Account details:</strong> your name, email address, mobile
            number and password. We store passwords only as a secure one-way
            hash and never see them in plain text.
          </li>
          <li>
            <strong>Profile details (optional):</strong> profile photo, job
            title, company name, GSTIN, PAN and business address.
          </li>
          <li>
            <strong>Saved addresses:</strong> delivery and installation
            addresses with a contact name and phone number.
          </li>
          <li>
            <strong>Machine listings:</strong> when you sell a machine, the
            machine details, photos and documents you upload (for example GST
            certificate, ownership proof, purchase invoice, maintenance
            records), plus the seller contact details you enter.
          </li>
          <li>
            <strong>Inquiries and orders:</strong> the machines you ask about
            or buy, your messages, quantities, prices, billing and delivery
            details.
          </li>
          <li>
            <strong>Support:</strong> anything you send us by phone, email or
            WhatsApp.
          </li>
        </ul>
        <p>
          <strong>Information collected automatically</strong>
        </p>
        <ul>
          <li>
            Our servers keep standard technical logs (IP address, date and
            time, the request made) to keep the Service secure and working.
          </li>
          <li>
            The app stores your sign-in token, cart and recent searches on your
            own device so you stay signed in.
          </li>
        </ul>
        <p>
          We do <strong>not</strong> use advertising, analytics or tracking
          tools, we do not collect your precise location, and we do not read
          your contacts, messages or files other than the photos and documents
          you choose to upload.
        </p>
      </Section>

      <Section title="2. Device permissions">
        <ul>
          <li>
            <strong>Camera and photos:</strong> only when you choose to take or
            pick a photo for your profile or a machine listing.
          </li>
          <li>
            <strong>Files:</strong> only when you choose to attach a document
            to a listing.
          </li>
          <li>
            <strong>Internet:</strong> to connect to the MachSetu marketplace.
          </li>
        </ul>
      </Section>

      <Section title="3. How we use your information">
        <ul>
          <li>To create and secure your account and verify your mobile number.</li>
          <li>
            To publish and verify machine listings, run technical audits, and
            connect buyers with sellers.
          </li>
          <li>
            To process inquiries, quotes, orders, escrow, logistics and
            installation.
          </li>
          <li>To send you notifications about your orders, listings and inquiries.</li>
          <li>To provide customer support and respond to your requests.</li>
          <li>To prevent fraud and misuse, and to meet our legal obligations.</li>
        </ul>
      </Section>

      <Section title="4. How we share information">
        <p>We do not sell or rent your personal data. We share it only:</p>
        <ul>
          <li>
            <strong>With the other side of a deal:</strong> when you raise an
            inquiry or place an order, the seller (and our broker handling it)
            receives the details needed to quote and complete it. Published
            listings show the machine details and the seller or company name.
          </li>
          <li>
            <strong>With service providers</strong> who work for us, such as
            our hosting provider, logistics partners, inspection agencies and
            payment or escrow providers, only as needed to provide the Service.
          </li>
          <li>
            <strong>When the law requires it,</strong> for example in response
            to a valid order from a court or government authority, or to
            protect the rights and safety of our users and MachSetu.
          </li>
        </ul>
      </Section>

      <Section title="5. Data security">
        <p>
          All data between the app and our servers travels over an encrypted
          HTTPS connection. Passwords are hashed, access to our systems is
          limited to authorised staff, and uploaded files are stored on servers
          we control. No system is perfectly secure, but we work to protect
          your information and will tell you if a breach affects you, as the
          law requires.
        </p>
      </Section>

      <Section title="6. How long we keep data">
        <ul>
          <li>We keep your account data for as long as your account is open.</li>
          <li>
            When you delete your account, we erase your profile, saved
            addresses, profile photo, notifications, machine listings and
            inquiries straight away.
          </li>
          <li>
            Records of completed or placed orders (invoice, company, GSTIN and
            billing details) are kept for up to 8 years because Indian tax law
            requires it. Your name, email and phone number are removed from
            those records.
          </li>
          <li>
            Server logs are kept only as long as needed for security and
            troubleshooting, and then deleted.
          </li>
        </ul>
      </Section>

      <Section title="7. Your rights and choices">
        <ul>
          <li>
            <strong>Access and correct:</strong> view and edit your details at
            any time in the app under Profile → Edit Profile.
          </li>
          <li>
            <strong>Delete your account:</strong> in the app go to Profile →
            Security → Delete Account, or use our{" "}
            <Link
              href="/delete-account"
              className="font-semibold text-navy-600 underline"
            >
              account deletion page
            </Link>
            .
          </li>
          <li>
            <strong>Ask questions or complain:</strong> contact our Grievance
            Officer below. You also have the rights given to you under India&apos;s
            Digital Personal Data Protection Act, 2023.
          </li>
        </ul>
      </Section>

      <Section title="8. Children">
        <p>
          MachSetu is a business service for adults. It is not meant for
          anyone under 18, and we do not knowingly collect data from children.
          If you believe a child has given us data, contact us and we will
          delete it.
        </p>
      </Section>

      <Section title="9. Changes to this policy">
        <p>
          We may update this policy from time to time. We will change the
          &quot;Last updated&quot; date above and, for important changes, tell
          you in the app.
        </p>
      </Section>

      <Section title="10. Contact and Grievance Officer">
        <p>
          For any question about this policy or your data, contact:
        </p>
        <p>
          <strong>Grievance Officer, {CONTACT.company}</strong>
          <br />
          {CONTACT.address}
          <br />
          Email:{" "}
          <a
            href={`mailto:${CONTACT.email}`}
            className="font-semibold text-navy-600 underline"
          >
            {CONTACT.email}
          </a>
          <br />
          Phone: {CONTACT.phone}
        </p>
        <p>We reply to all requests within 30 days.</p>
      </Section>
    </PublicPage>
  );
}
