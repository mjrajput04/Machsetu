"use client";

import Link from "next/link";
import { useState } from "react";
import { CATEGORIES } from "@/lib/data";
import { Button, Card, CardHeader, PageHeader, cx } from "@/components/ui";

const CONDITIONS = ["Excellent", "Good", "Average", "Fair", "Needs Repair"];
const WORKING_STATUS = ["Running", "Idle", "Under Repair", "Not Working"];
const OWNER_TYPES = ["1st Owner", "Dealer", "Reseller"];
const PHOTO_VIEWS = [
  "Front View",
  "Back View",
  "Left Side View",
  "Right Side View",
  "Controller Panel",
  "Electrical Panel",
  "Name Plate",
  "Tool Magazine",
  "Chuck / Spindle",
  "Hydraulic Unit",
];
const DOC_TYPES = [
  "GST Certificate",
  "Ownership Proof",
  "Purchase Invoice",
  "AMC Details",
  "Original Invoice",
  "Maintenance Records",
  "Machine Manual",
  "Warranty (If Any)",
];

export default function AddProductPage() {
  const [categories, setCategories] = useState<string[]>([]);
  const [photos, setPhotos] = useState<string[]>([]);
  const [docs, setDocs] = useState<string[]>([]);
  const [condition, setCondition] = useState("Good");
  const [working, setWorking] = useState("Running");
  const [owner, setOwner] = useState("1st Owner");
  const [negotiable, setNegotiable] = useState(true);

  function toggle(
    list: string[],
    set: (next: string[]) => void,
    value: string,
  ) {
    set(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]);
  }

  return (
    <>
      <PageHeader
        title="Add Product"
        subtitle="Publish a machine directly to the marketplace, bypassing the seller queue."
        actions={
          <>
            <Link href="/products">
              <Button variant="secondary">Cancel</Button>
            </Link>
            <Button variant="secondary">Save draft</Button>
            <Button>Publish listing</Button>
          </>
        }
      />

      <form className="grid gap-4 xl:grid-cols-3">
        <div className="space-y-4 xl:col-span-2">
          <Card>
            <CardHeader
              title="Machine identity"
              subtitle="What the buyer sees at the top of the listing"
            />
            <div className="grid gap-4 sm:grid-cols-2">
              <Field label="Machine title" hint="e.g. Haas VF-2SS">
                <Input placeholder="Haas VF-2SS" />
              </Field>
              <Field label="Brand / Make">
                <Input placeholder="Haas Automation" />
              </Field>
              <Field label="Model">
                <Input placeholder="VF-2SS" />
              </Field>
              <Field label="Machine type">
                <Input placeholder="Super-Speed Vertical Machining Center" />
              </Field>
              <Field label="Manufacturing year">
                <Input placeholder="2021" inputMode="numeric" />
              </Field>
              <Field label="Country of origin">
                <Input placeholder="USA" />
              </Field>
            </div>

            <div className="mt-5">
              <p className="mb-2 text-sm font-semibold text-navy-800">
                Category
              </p>
              <div className="flex flex-wrap gap-2">
                {CATEGORIES.map((c) => (
                  <Chip
                    key={c}
                    active={categories.includes(c)}
                    onClick={() => toggle(categories, setCategories, c)}
                  >
                    {c}
                  </Chip>
                ))}
              </div>
            </div>
          </Card>

          <Card>
            <CardHeader
              title="Specifications"
              subtitle="Powers the technical tables on the product page"
            />
            <div className="grid gap-4 sm:grid-cols-2">
              <Field label="Controller">
                <Input placeholder="Fanuc 31i-B" />
              </Field>
              <Field label="No. of axis">
                <Input placeholder="3 Axis" />
              </Field>
              <Field label="Travels X / Y / Z">
                <Input placeholder="762 / 406 / 508 mm" />
              </Field>
              <Field label="Table size">
                <Input placeholder="914 x 356 mm" />
              </Field>
              <Field label="Spindle speed">
                <Input placeholder="12,000 rpm" />
              </Field>
              <Field label="Spindle taper">
                <Input placeholder="CT 40" />
              </Field>
              <Field label="Tool magazine capacity">
                <Input placeholder="24+1 side mount" />
              </Field>
              <Field label="Coolant system">
                <Input placeholder="Through spindle 300 psi" />
              </Field>
              <Field label="Power requirement">
                <Input placeholder="3-Phase 415V, 22.4 kVA" />
              </Field>
              <Field label="Machine weight">
                <Input placeholder="3,175 kg" />
              </Field>
            </div>

            <div className="mt-5">
              <Field label="Overview">
                <textarea
                  rows={4}
                  placeholder="Describe condition, ownership history, included accessories and any known issues…"
                  className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                />
              </Field>
            </div>
          </Card>

          <Card>
            <CardHeader
              title="Media"
              subtitle="Up to 10 photos — the first becomes the listing thumbnail"
            />
            <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
              <button
                type="button"
                className="grid aspect-square place-items-center rounded-lg border-2 border-dashed border-line text-muted transition-colors hover:border-navy-600 hover:text-navy-700"
              >
                <span className="text-center text-xs font-semibold">
                  <span className="mb-1 block text-2xl leading-none">+</span>
                  Upload
                </span>
              </button>
              {[1, 2, 3].map((n) => (
                <div
                  key={n}
                  className="relative grid aspect-square place-items-center overflow-hidden rounded-lg bg-navy-50 text-xs font-semibold text-navy-600"
                >
                  Photo {n}
                  {n === 1 && (
                    <span className="absolute bottom-1.5 left-1.5 rounded bg-navy-800 px-1.5 py-0.5 text-[10px] text-white">
                      Main
                    </span>
                  )}
                </div>
              ))}
            </div>

            <p className="mt-5 mb-2 text-sm font-semibold text-navy-800">
              Required views checklist
            </p>
            <div className="grid gap-2 sm:grid-cols-2">
              {PHOTO_VIEWS.map((v) => (
                <Check
                  key={v}
                  checked={photos.includes(v)}
                  onChange={() => toggle(photos, setPhotos, v)}
                >
                  {v}
                </Check>
              ))}
            </div>
          </Card>

          <Card>
            <CardHeader
              title="Documents"
              subtitle="Attached paperwork increases buyer trust"
            />
            <div className="grid gap-2 sm:grid-cols-2">
              {DOC_TYPES.map((d) => (
                <Check
                  key={d}
                  checked={docs.includes(d)}
                  onChange={() => toggle(docs, setDocs, d)}
                >
                  {d}
                </Check>
              ))}
            </div>
          </Card>
        </div>

        <div className="space-y-4">
          <Card>
            <CardHeader title="Pricing" />
            <Field label="Expected price (₹)">
              <Input placeholder="7050000" inputMode="numeric" />
            </Field>
            <div className="mt-4">
              <p className="mb-2 text-sm font-semibold text-navy-800">
                Negotiable
              </p>
              <div className="flex gap-2">
                <Chip active={negotiable} onClick={() => setNegotiable(true)}>
                  Yes
                </Chip>
                <Chip active={!negotiable} onClick={() => setNegotiable(false)}>
                  No
                </Chip>
              </div>
            </div>
            <div className="mt-4">
              <p className="mb-2 text-sm font-semibold text-navy-800">
                Owner type
              </p>
              <div className="flex flex-wrap gap-2">
                {OWNER_TYPES.map((o) => (
                  <Chip
                    key={o}
                    active={owner === o}
                    onClick={() => setOwner(o)}
                  >
                    {o}
                  </Chip>
                ))}
              </div>
            </div>
          </Card>

          <Card>
            <CardHeader title="Condition" />
            <div className="flex flex-wrap gap-2">
              {CONDITIONS.map((c) => (
                <Chip
                  key={c}
                  active={condition === c}
                  onClick={() => setCondition(c)}
                >
                  {c}
                </Chip>
              ))}
            </div>
            <p className="mt-4 mb-2 text-sm font-semibold text-navy-800">
              Working status
            </p>
            <div className="flex flex-wrap gap-2">
              {WORKING_STATUS.map((w) => (
                <Chip
                  key={w}
                  active={working === w}
                  onClick={() => setWorking(w)}
                >
                  {w}
                </Chip>
              ))}
            </div>
            <div className="mt-4 grid gap-4">
              <Field label="Working hours">
                <Input placeholder="4200" inputMode="numeric" />
              </Field>
              <Field label="Last service date">
                <Input placeholder="18 Aug 2026" />
              </Field>
            </div>
          </Card>

          <Card>
            <CardHeader title="Seller & location" />
            <div className="grid gap-4">
              <Field label="Seller / company">
                <Input placeholder="Fortune Gold Machine Tools" />
              </Field>
              <Field label="City">
                <Input placeholder="Rajkot" />
              </Field>
              <Field label="State">
                <Input placeholder="Gujarat" />
              </Field>
              <Field label="Serial number">
                <Input placeholder="SN-9827346A" />
              </Field>
            </div>
          </Card>

          <Card className="bg-navy-800 text-white" >
            <p className="text-sm font-bold">Ready to publish?</p>
            <p className="mt-1.5 text-xs text-white/70">
              Published listings appear in the buyer app immediately and are
              indexed for search.
            </p>
            <Button className="mt-4 w-full">Publish listing</Button>
          </Card>
        </div>
      </form>
    </>
  );
}

/* ------------------------------------------------------------- controls -- */

function Field({
  label,
  hint,
  children,
}: {
  label: string;
  hint?: string;
  children: React.ReactNode;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-sm font-semibold text-navy-800">
        {label}
      </span>
      {children}
      {hint && <span className="mt-1 block text-xs text-faint">{hint}</span>}
    </label>
  );
}

function Input(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      {...props}
      className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
    />
  );
}

function Chip({
  children,
  active,
  onClick,
}: {
  children: React.ReactNode;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cx(
        "rounded-full px-3.5 py-2 text-xs font-semibold transition-colors",
        active
          ? "bg-navy-800 text-white"
          : "bg-canvas text-muted ring-1 ring-line ring-inset hover:bg-navy-50 hover:text-navy-700",
      )}
    >
      {children}
    </button>
  );
}

function Check({
  children,
  checked,
  onChange,
}: {
  children: React.ReactNode;
  checked: boolean;
  onChange: () => void;
}) {
  return (
    <label
      className={cx(
        "flex cursor-pointer items-center gap-2.5 rounded-lg border px-3 py-2.5 text-sm transition-colors",
        checked
          ? "border-accent-500 bg-accent-50 font-semibold text-accent-700"
          : "border-line bg-white text-ink hover:bg-canvas",
      )}
    >
      <input
        type="checkbox"
        checked={checked}
        onChange={onChange}
        className="h-4 w-4 rounded border-line accent-[#f97316]"
      />
      {children}
    </label>
  );
}
