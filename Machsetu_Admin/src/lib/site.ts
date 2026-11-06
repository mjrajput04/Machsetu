/**
 * Fixed copy for the public website.
 *
 * Phone, email, hours and FAQs come from the console's Settings → Support tab
 * at request time; only what the console does not manage lives here.
 */
export const SITE_URL = "https://machsetu.com";

export const OFFICE = {
  city: "Rajkot",
  region: "Gujarat, India",
};

export const NAV_LINKS = [
  { href: "/", label: "Home" },
  { href: "/about", label: "About" },
  { href: "/contact", label: "Contact" },
];

/** Policy pages — Google Play links to these from the store listing. */
export const LEGAL_LINKS = [
  { href: "/privacy", label: "Privacy Policy" },
  { href: "/terms", label: "Terms of Use" },
  { href: "/delete-account", label: "Delete Account" },
];

/** What a contact-form message is about. The API accepts only these. */
export const CONTACT_TOPICS = [
  "Buying a machine",
  "Selling a machine",
  "Partnership",
  "Other",
] as const;

export type ContactTopic = (typeof CONTACT_TOPICS)[number];
