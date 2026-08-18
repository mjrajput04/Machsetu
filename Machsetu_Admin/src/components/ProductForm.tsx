"use client";

import Image from "next/image";
import Link from "next/link";
import { useRef, useState } from "react";
import {
  CATEGORY_OPTIONS,
  CONDITIONS,
  DOCUMENT_TYPES,
  MAINTENANCE_STATUS,
  OWNER_TYPES,
  REQUIRED_PHOTOS,
  WORKING_STATUS,
} from "@/lib/options";
import { api, useApi } from "@/lib/api";
import type { DocumentFile, Product } from "@/lib/types";
import { Button, Card, CardHeader, PageHeader, cx } from "@/components/ui";

/**
 * Mirrors the seller wizard in the Flutter app section for section, so a
 * machine added here carries exactly the same record as one submitted by a
 * seller. Every field is optional, matching the app.
 *
 * Shared by Add Product and Edit Listing — the only difference is what the
 * form opens with and where the save goes.
 */

/** Flat mirror of the record; nested sections are assembled on submit. */
interface FormValues {
  // Section 1
  sellerName: string;
  companyName: string;
  mobile: string;
  whatsapp: string;
  email: string;
  gstNumber: string;
  panNumber: string;
  pincode: string;
  address: string;
  city: string;
  state: string;

  // Section 2
  categoryOther: string;
  machineType: string;
  brand: string;
  model: string;
  year: string;
  installationYear: string;
  countryOfOrigin: string;
  controller: string;
  numberOfAxis: string;
  machineCapacity: string;
  powerRequirement: string;
  maxSpindleSpeed: string;
  weight: string;
  location: string;
  workingHours: string;
  lastServiceDate: string;
  serialNumber: string;
  accessoriesIncluded: string;
  description: string;

  // Section 4
  tableSize: string;
  lubricationSystem: string;
  toolMagazineCapacity: string;
  electricalPanelCondition: string;
  toolChangerType: string;
  servoMotors: string;
  coolantSystem: string;
  ballScrewCondition: string;
  hydraulicSystem: string;
  guideways: string;
  otherSpecifications: string;

  // Section 3
  price: string;
  additionalRemarks: string;

  // Marketplace display
  catalogueCategory: string;
  badge: string;
  priceNote: string;
  ctaLabel: string;
}

const BLANK: FormValues = {
  sellerName: "",
  companyName: "",
  mobile: "",
  whatsapp: "",
  email: "",
  gstNumber: "",
  panNumber: "",
  pincode: "",
  address: "",
  city: "",
  state: "",
  categoryOther: "",
  machineType: "",
  brand: "",
  model: "",
  year: "",
  installationYear: "",
  countryOfOrigin: "",
  controller: "",
  numberOfAxis: "",
  machineCapacity: "",
  powerRequirement: "",
  maxSpindleSpeed: "",
  weight: "",
  location: "",
  workingHours: "",
  lastServiceDate: "",
  serialNumber: "",
  accessoriesIncluded: "",
  description: "",
  tableSize: "",
  lubricationSystem: "",
  toolMagazineCapacity: "",
  electricalPanelCondition: "",
  toolChangerType: "",
  servoMotors: "",
  coolantSystem: "",
  ballScrewCondition: "",
  hydraulicSystem: "",
  guideways: "",
  otherSpecifications: "",
  price: "",
  additionalRemarks: "",
  catalogueCategory: "",
  badge: "",
  priceNote: "",
  ctaLabel: "",
};

const str = (value: unknown) => (value == null ? "" : String(value));

/** Unpacks a saved listing back into the flat form state. */
function toValues(product?: Product | null): FormValues {
  if (!product) return { ...BLANK };
  const seller = product.sellerInfo ?? ({} as Product["sellerInfo"]);
  const details = product.details ?? ({} as Product["details"]);
  const specs = product.specs ?? ({} as Product["specs"]);

  return {
    sellerName: str(seller.name),
    companyName: str(seller.company),
    mobile: str(seller.mobile),
    whatsapp: str(seller.whatsapp),
    email: str(seller.email),
    gstNumber: str(seller.gstNumber),
    panNumber: str(seller.panNumber),
    pincode: str(seller.pincode),
    address: str(seller.address),
    city: str(seller.city),
    state: str(seller.state),
    categoryOther: "",
    machineType: str(details.machineType || product.type),
    brand: str(product.brand),
    model: str(product.title).replace(str(product.brand), "").trim(),
    year: str(product.year),
    installationYear: str(details.installationYear),
    countryOfOrigin: str(details.countryOfOrigin || product.origin),
    controller: str(details.controller),
    numberOfAxis: str(details.numberOfAxis),
    machineCapacity: str(details.machineCapacity),
    powerRequirement: str(details.powerRequirement),
    maxSpindleSpeed: str(details.maxSpindleSpeed),
    weight: str(details.weight),
    location: str(product.location),
    workingHours: str(product.hours),
    lastServiceDate: str(details.lastServiceDate),
    serialNumber: str(details.serialNumber),
    accessoriesIncluded: str(details.accessoriesIncluded),
    description: str(product.description),
    tableSize: str(specs.tableSize),
    lubricationSystem: str(specs.lubricationSystem),
    toolMagazineCapacity: str(specs.toolMagazineCapacity),
    electricalPanelCondition: str(specs.electricalPanelCondition),
    toolChangerType: str(specs.toolChangerType),
    servoMotors: str(specs.servoMotors),
    coolantSystem: str(specs.coolantSystem),
    ballScrewCondition: str(specs.ballScrewCondition),
    hydraulicSystem: str(specs.hydraulicSystem),
    guideways: str(specs.guideways),
    otherSpecifications: str(specs.otherSpecifications),
    price: product.price ? String(product.price) : "",
    additionalRemarks: str(product.additionalRemarks),
    catalogueCategory: str(product.category),
    badge: str(product.badge),
    priceNote: str(product.priceNote),
    ctaLabel: str(product.ctaLabel),
  };
}

export interface ProductFormProps {
  title: string;
  subtitle: string;
  submitLabel: string;
  product?: Product | null;
  /** Receives the assembled record; resolves once the save succeeds. */
  onSubmit: (payload: Record<string, unknown>) => Promise<void>;
}

export default function ProductForm({
  title,
  subtitle,
  submitLabel,
  product,
  onSubmit,
}: ProductFormProps) {
  // Category chips and the catalogue dropdown are whatever Settings says.
  const config = useApi<{ categories: string[] }>("/api/settings");
  const catalogueCategories = config.data?.categories ?? [];

  const [values, setValues] = useState<FormValues>(() => toValues(product));
  const [categories, setCategories] = useState<string[]>(
    product?.categories ?? [],
  );
  const [photos, setPhotos] = useState<string[]>(product?.requiredPhotos ?? []);
  const [docs, setDocs] = useState<DocumentFile[]>(product?.documents ?? []);
  const [images, setImages] = useState<string[]>(product?.images ?? []);
  const [condition, setCondition] = useState(product?.condition || "Good");
  const [working, setWorking] = useState(
    str(product?.details?.workingStatus) || "Running",
  );
  const [maintenance, setMaintenance] = useState(
    str(product?.details?.maintenanceStatus) || "Regular",
  );
  const [owner, setOwner] = useState(
    str(product?.commercial?.ownerType) || "1st Owner",
  );
  const [status, setStatus] = useState(product?.status ?? "Pending Review");

  const [yesNo, setYesNo] = useState<Record<string, boolean | null>>({
    negotiable: product?.commercial?.negotiable ?? true,
    gstAvailable: product?.commercial?.gstAvailable ?? true,
    taxInvoiceAvailable: product?.commercial?.taxInvoiceAvailable ?? null,
    financePending: product?.commercial?.financePending ?? null,
    deliveryAvailable: product?.commercial?.deliveryAvailable ?? null,
    loadingAvailable: product?.commercial?.loadingAvailable ?? null,
  });

  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const filePicker = useRef<HTMLInputElement>(null);

  function set<K extends keyof FormValues>(key: K, value: FormValues[K]) {
    setValues((prev) => ({ ...prev, [key]: value }));
  }

  function toggle(list: string[], apply: (n: string[]) => void, value: string) {
    apply(
      list.includes(value) ? list.filter((v) => v !== value) : [...list, value],
    );
  }

  async function addImages(files: FileList | null) {
    if (!files?.length) return;
    setUploading(true);
    setError(null);
    try {
      const result = await api.upload(Array.from(files).slice(0, 10));
      setImages((prev) => [...prev, ...result.files.map((f) => f.url)]);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setUploading(false);
      if (filePicker.current) filePicker.current.value = "";
    }
  }

  async function dropImage(url: string) {
    setImages((prev) => prev.filter((u) => u !== url));
    // Only files the database holds are ours to delete.
    if (url.startsWith("/api/files/")) {
      await api
        .del(`/api/upload?url=${encodeURIComponent(url)}`)
        .catch(() => {});
    }
  }

  /** Assembles the flat form back into the record shape the API stores. */
  function payload(nextStatus: string): Record<string, unknown> {
    const machineTitle = [values.brand, values.model]
      .map((p) => p.trim())
      .filter(Boolean)
      .join(" ");
    const picked = categories.filter((c) => c !== "Other");
    if (categories.includes("Other") && values.categoryOther.trim()) {
      picked.push(values.categoryOther.trim());
    }

    return {
      title: machineTitle || values.machineType || "Untitled machine",
      brand: values.brand,
      type: values.machineType,
      category: values.catalogueCategory,
      categories: picked,
      year: values.year,
      price: Number(values.price.replace(/[^0-9]/g, "") || 0),
      location: values.location,
      condition,
      hours: values.workingHours,
      origin: values.countryOfOrigin,
      status: nextStatus,
      seller: values.companyName || values.sellerName,
      badge: values.badge,
      priceNote: values.priceNote,
      ctaLabel: values.ctaLabel,
      images,
      description: values.description,
      overview: values.description ? [values.description] : [],
      additionalRemarks: values.additionalRemarks,
      requiredPhotos: photos,
      documents: docs,
      sellerInfo: {
        name: values.sellerName,
        company: values.companyName,
        mobile: values.mobile,
        whatsapp: values.whatsapp,
        email: values.email,
        gstNumber: values.gstNumber,
        panNumber: values.panNumber,
        address: values.address,
        city: values.city,
        state: values.state,
        pincode: values.pincode,
      },
      details: {
        machineType: values.machineType,
        installationYear: values.installationYear,
        countryOfOrigin: values.countryOfOrigin,
        controller: values.controller,
        numberOfAxis: values.numberOfAxis,
        machineCapacity: values.machineCapacity,
        powerRequirement: values.powerRequirement,
        maxSpindleSpeed: values.maxSpindleSpeed,
        weight: values.weight,
        workingStatus: working,
        maintenanceStatus: maintenance,
        lastServiceDate: values.lastServiceDate,
        accessoriesIncluded: values.accessoriesIncluded,
        serialNumber: values.serialNumber,
        location: values.location,
      },
      specs: {
        tableSize: values.tableSize,
        lubricationSystem: values.lubricationSystem,
        electricalPanelCondition: values.electricalPanelCondition,
        toolMagazineCapacity: values.toolMagazineCapacity,
        servoMotors: values.servoMotors,
        toolChangerType: values.toolChangerType,
        ballScrewCondition: values.ballScrewCondition,
        coolantSystem: values.coolantSystem,
        guideways: values.guideways,
        hydraulicSystem: values.hydraulicSystem,
        otherSpecifications: values.otherSpecifications,
      },
      commercial: {
        negotiable: yesNo.negotiable,
        gstAvailable: yesNo.gstAvailable,
        taxInvoiceAvailable: yesNo.taxInvoiceAvailable,
        financePending: yesNo.financePending,
        deliveryAvailable: yesNo.deliveryAvailable,
        loadingAvailable: yesNo.loadingAvailable,
        ownerType: owner,
      },
    };
  }

  async function save(nextStatus: string) {
    setSaving(true);
    setError(null);
    try {
      await onSubmit(payload(nextStatus));
    } catch (err) {
      setError((err as Error).message);
      setSaving(false);
    }
  }

  return (
    <>
      <PageHeader
        title={title}
        subtitle={subtitle}
        actions={
          <>
            <Link href="/products">
              <Button variant="secondary">Cancel</Button>
            </Link>
            <Button
              variant="secondary"
              disabled={saving}
              onClick={() => save("Pending Review")}
            >
              Save draft
            </Button>
            <Button disabled={saving} onClick={() => save("Live")}>
              {saving ? "Saving…" : submitLabel}
            </Button>
          </>
        }
      />

      {error && (
        <div className="mb-4 rounded-lg border border-rose-200 bg-rose-50 px-4 py-3 text-sm font-semibold text-rose-700">
          {error}
        </div>
      )}

      <form
        className="grid gap-4 xl:grid-cols-3"
        onSubmit={(e) => {
          e.preventDefault();
          save(status);
        }}
      >
        <div className="space-y-4 xl:col-span-2">
          {/* ---- Section 1 ------------------------------------------- */}
          <Card>
            <CardHeader
              title="1 · Seller Information"
              subtitle="Who owns the machine and how the desk reaches them"
            />
            <div className="grid gap-4 sm:grid-cols-2">
              <Field label="Seller / Contact Person Name">
                <Input
                  placeholder="Pappu Singh"
                  value={values.sellerName}
                  onChange={(e) => set("sellerName", e.target.value)}
                />
              </Field>
              <Field label="Company Name">
                <Input
                  placeholder="Fortune Gold Machine Tools"
                  value={values.companyName}
                  onChange={(e) => set("companyName", e.target.value)}
                />
              </Field>
              <Field label="Mobile Number">
                <Input
                  placeholder="84015 03169"
                  inputMode="tel"
                  value={values.mobile}
                  onChange={(e) => set("mobile", e.target.value)}
                />
              </Field>
              <Field label="WhatsApp Number">
                <Input
                  placeholder="Same as mobile"
                  inputMode="tel"
                  value={values.whatsapp}
                  onChange={(e) => set("whatsapp", e.target.value)}
                />
              </Field>
              <Field label="Email ID">
                <Input
                  placeholder="you@company.com"
                  type="email"
                  value={values.email}
                  onChange={(e) => set("email", e.target.value)}
                />
              </Field>
              <Field label="GST Number">
                <Input
                  placeholder="24AAACF1234K1ZV"
                  value={values.gstNumber}
                  onChange={(e) => set("gstNumber", e.target.value)}
                />
              </Field>
              <Field label="PAN Number">
                <Input
                  placeholder="AAACF1234K"
                  value={values.panNumber}
                  onChange={(e) => set("panNumber", e.target.value)}
                />
              </Field>
              <Field label="Pincode">
                <Input
                  placeholder="360021"
                  inputMode="numeric"
                  value={values.pincode}
                  onChange={(e) => set("pincode", e.target.value)}
                />
              </Field>
              <div className="sm:col-span-2">
                <Field label="Complete Address">
                  <textarea
                    rows={2}
                    placeholder="Plot / unit, area, landmark"
                    value={values.address}
                    onChange={(e) => set("address", e.target.value)}
                    className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                  />
                </Field>
              </div>
              <Field label="City">
                <Input
                  placeholder="Rajkot"
                  value={values.city}
                  onChange={(e) => set("city", e.target.value)}
                />
              </Field>
              <Field label="State">
                <Input
                  placeholder="Gujarat"
                  value={values.state}
                  onChange={(e) => set("state", e.target.value)}
                />
              </Field>
            </div>
          </Card>

          {/* ---- Section 2 ------------------------------------------- */}
          <Card>
            <CardHeader
              title="2 · Machine Details"
              subtitle="Identity, capacity and running condition"
            />

            <p className="mb-2 text-sm font-semibold text-navy-800">
              Machine Category (select all that apply)
            </p>
            <div className="mb-5 grid gap-2 sm:grid-cols-3">
              {[...catalogueCategories, ...CATEGORY_OPTIONS]
                .filter((c, i, list) => list.indexOf(c) === i)
                .map((c) => (
                  <Check
                    key={c}
                    checked={categories.includes(c)}
                    onChange={() => toggle(categories, setCategories, c)}
                  >
                    {c}
                  </Check>
                ))}
            </div>
            {categories.includes("Other") && (
              <div className="mb-5">
                <Field label="Other Category">
                  <Input
                    placeholder="Specify the machine category"
                    value={values.categoryOther}
                    onChange={(e) => set("categoryOther", e.target.value)}
                  />
                </Field>
              </div>
            )}

            <div className="grid gap-4 sm:grid-cols-2">
              <Field label="Machine Type">
                <Input
                  placeholder="Vertical Machining Center"
                  value={values.machineType}
                  onChange={(e) => set("machineType", e.target.value)}
                />
              </Field>
              <Field label="Brand / Make">
                <Input
                  placeholder="Haas Automation"
                  value={values.brand}
                  onChange={(e) => set("brand", e.target.value)}
                />
              </Field>
              <Field label="Model">
                <Input
                  placeholder="VF-2SS"
                  value={values.model}
                  onChange={(e) => set("model", e.target.value)}
                />
              </Field>
              <Field label="Manufacturing Year">
                <Input
                  placeholder="2021"
                  inputMode="numeric"
                  value={values.year}
                  onChange={(e) => set("year", e.target.value)}
                />
              </Field>
              <Field label="Installation Year">
                <Input
                  placeholder="2021"
                  inputMode="numeric"
                  value={values.installationYear}
                  onChange={(e) => set("installationYear", e.target.value)}
                />
              </Field>
              <Field label="Country of Origin">
                <Input
                  placeholder="USA"
                  value={values.countryOfOrigin}
                  onChange={(e) => set("countryOfOrigin", e.target.value)}
                />
              </Field>
              <Field label="Controller">
                <Input
                  placeholder="Fanuc 31i-B"
                  value={values.controller}
                  onChange={(e) => set("controller", e.target.value)}
                />
              </Field>
              <Field label="No. of Axis">
                <Input
                  placeholder="3 Axis"
                  value={values.numberOfAxis}
                  onChange={(e) => set("numberOfAxis", e.target.value)}
                />
              </Field>
              <Field label="Machine Capacity / Size">
                <Input
                  placeholder="762 / 406 / 508 mm"
                  value={values.machineCapacity}
                  onChange={(e) => set("machineCapacity", e.target.value)}
                />
              </Field>
              <Field label="Power Requirement">
                <Input
                  placeholder="3-Phase 415V, 22.4 kVA"
                  value={values.powerRequirement}
                  onChange={(e) => set("powerRequirement", e.target.value)}
                />
              </Field>
              <Field label="Maximum Spindle Speed">
                <Input
                  placeholder="12,000 RPM"
                  value={values.maxSpindleSpeed}
                  onChange={(e) => set("maxSpindleSpeed", e.target.value)}
                />
              </Field>
              <Field label="Weight of Machine">
                <Input
                  placeholder="3,175 kg"
                  value={values.weight}
                  onChange={(e) => set("weight", e.target.value)}
                />
              </Field>
              <Field label="Machine Location">
                <Input
                  placeholder="City, State"
                  value={values.location}
                  onChange={(e) => set("location", e.target.value)}
                />
              </Field>
              <Field label="Working Hours">
                <Input
                  placeholder="4200"
                  inputMode="numeric"
                  value={values.workingHours}
                  onChange={(e) => set("workingHours", e.target.value)}
                />
              </Field>
              <Field label="Last Service Date">
                <Input
                  placeholder="DD / MM / YYYY"
                  value={values.lastServiceDate}
                  onChange={(e) => set("lastServiceDate", e.target.value)}
                />
              </Field>
              <Field label="Serial Number">
                <Input
                  placeholder="Machine SN"
                  value={values.serialNumber}
                  onChange={(e) => set("serialNumber", e.target.value)}
                />
              </Field>
            </div>

            <ChipGroup
              label="Working Status"
              options={[...WORKING_STATUS]}
              value={working}
              onChange={setWorking}
            />
            <ChipGroup
              label="Machine Condition"
              options={[...CONDITIONS]}
              value={condition}
              onChange={setCondition}
            />
            <ChipGroup
              label="Maintenance Status"
              options={[...MAINTENANCE_STATUS]}
              value={maintenance}
              onChange={setMaintenance}
            />

            <div className="mt-5 grid gap-4">
              <Field label="Accessories Included">
                <textarea
                  rows={2}
                  placeholder="Tool holders, coolant pump, manuals…"
                  value={values.accessoriesIncluded}
                  onChange={(e) => set("accessoriesIncluded", e.target.value)}
                  className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                />
              </Field>
              <Field label="Machine Description">
                <textarea
                  rows={4}
                  placeholder="Provide details about specs, condition, included accessories, or known issues…"
                  value={values.description}
                  onChange={(e) => set("description", e.target.value)}
                  className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                />
              </Field>
            </div>
          </Card>

          {/* ---- Section 4 ------------------------------------------- */}
          <Card>
            <CardHeader
              title="4 · Machine Specifications"
              subtitle="Feeds the technical tables on the product page"
            />
            <div className="grid gap-4 sm:grid-cols-2">
              <Field label="Table Size">
                <Input
                  placeholder="914 x 356 mm"
                  value={values.tableSize}
                  onChange={(e) => set("tableSize", e.target.value)}
                />
              </Field>
              <Field label="Lubrication System">
                <Input
                  placeholder="Automatic centralised"
                  value={values.lubricationSystem}
                  onChange={(e) => set("lubricationSystem", e.target.value)}
                />
              </Field>
              <Field label="Tool Magazine Capacity">
                <Input
                  placeholder="24+1 side mount"
                  value={values.toolMagazineCapacity}
                  onChange={(e) => set("toolMagazineCapacity", e.target.value)}
                />
              </Field>
              <Field label="Electrical Panel Condition">
                <Input
                  placeholder="Excellent"
                  value={values.electricalPanelCondition}
                  onChange={(e) =>
                    set("electricalPanelCondition", e.target.value)
                  }
                />
              </Field>
              <Field label="Tool Changer Type">
                <Input
                  placeholder="Side mount ATC"
                  value={values.toolChangerType}
                  onChange={(e) => set("toolChangerType", e.target.value)}
                />
              </Field>
              <Field label="Servo Motors">
                <Input
                  placeholder="Make and health"
                  value={values.servoMotors}
                  onChange={(e) => set("servoMotors", e.target.value)}
                />
              </Field>
              <Field label="Coolant System">
                <Input
                  placeholder="Through spindle 300 psi"
                  value={values.coolantSystem}
                  onChange={(e) => set("coolantSystem", e.target.value)}
                />
              </Field>
              <Field label="Ball Screw Condition">
                <Input
                  placeholder="No backlash"
                  value={values.ballScrewCondition}
                  onChange={(e) => set("ballScrewCondition", e.target.value)}
                />
              </Field>
              <Field label="Hydraulic System">
                <Input
                  placeholder="Working"
                  value={values.hydraulicSystem}
                  onChange={(e) => set("hydraulicSystem", e.target.value)}
                />
              </Field>
              <Field label="Guideways">
                <Input
                  placeholder="Linear guideways"
                  value={values.guideways}
                  onChange={(e) => set("guideways", e.target.value)}
                />
              </Field>
              <div className="sm:col-span-2">
                <Field label="Other Specifications">
                  <textarea
                    rows={2}
                    placeholder="Anything else worth listing"
                    value={values.otherSpecifications}
                    onChange={(e) => set("otherSpecifications", e.target.value)}
                    className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                  />
                </Field>
              </div>
            </div>
          </Card>

          {/* ---- Section 6 ------------------------------------------- */}
          <Card>
            <CardHeader
              title="6 · Photos"
              subtitle="Up to 10 images — the first becomes the listing thumbnail"
            />
            <input
              ref={filePicker}
              type="file"
              accept="image/*"
              multiple
              hidden
              onChange={(e) => addImages(e.target.files)}
            />
            <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
              <button
                type="button"
                disabled={uploading}
                onClick={() => filePicker.current?.click()}
                className="grid aspect-square place-items-center rounded-lg border-2 border-dashed border-line text-muted transition-colors hover:border-navy-600 hover:text-navy-700 disabled:opacity-50"
              >
                <span className="text-center text-xs font-semibold">
                  <span className="mb-1 block text-2xl leading-none">+</span>
                  {uploading ? "Uploading…" : "Upload"}
                </span>
              </button>
              {images.map((url, index) => (
                <div
                  key={url}
                  className="relative grid aspect-square place-items-center overflow-hidden rounded-lg bg-navy-50 text-xs font-semibold text-navy-600"
                >
                  <Image
                    src={url}
                    alt={`Photo ${index + 1}`}
                    fill
                    sizes="200px"
                    className="object-cover"
                  />
                  <button
                    type="button"
                    onClick={() => dropImage(url)}
                    title="Remove photo"
                    className="absolute top-1.5 right-1.5 grid h-6 w-6 place-items-center rounded-full bg-white/90 text-navy-800 shadow hover:bg-rose-500 hover:text-white"
                  >
                    ×
                  </button>
                  {index === 0 && (
                    <span className="absolute bottom-1.5 left-1.5 rounded bg-navy-800 px-1.5 py-0.5 text-[10px] text-white">
                      Main
                    </span>
                  )}
                </div>
              ))}
            </div>

            <div className="mt-5 mb-2 flex items-baseline justify-between">
              <p className="text-sm font-semibold text-navy-800">
                Required Photos checklist
              </p>
              <p className="text-xs text-muted">
                {photos.length} of {REQUIRED_PHOTOS.length} ticked
              </p>
            </div>
            <div className="grid gap-2 sm:grid-cols-2">
              {REQUIRED_PHOTOS.map((v) => (
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

          {/* ---- Section 5 ------------------------------------------- */}
          <Card>
            <CardHeader
              title="5 · Documents"
              subtitle="Attached paperwork shows on the buyer's product page"
            />
            <div className="grid gap-2">
              {DOCUMENT_TYPES.map((type) => (
                <DocumentRow
                  key={type}
                  type={type}
                  file={docs.find((d) => d.category === type) ?? null}
                  onAttach={(file) =>
                    setDocs((prev) => [
                      ...prev.filter((d) => d.category !== type),
                      file,
                    ])
                  }
                  onRemove={() =>
                    setDocs((prev) => prev.filter((d) => d.category !== type))
                  }
                />
              ))}
            </div>
          </Card>
        </div>

        {/* ---- Right rail --------------------------------------------- */}
        <div className="space-y-4">
          <Card>
            <CardHeader title="3 · Commercial Information" />
            <Field label="Expected Selling Price (₹)">
              <Input
                placeholder="7050000"
                inputMode="numeric"
                value={values.price}
                onChange={(e) => set("price", e.target.value)}
              />
            </Field>

            <div className="mt-4 space-y-1">
              {[
                ["negotiable", "Negotiable"],
                ["gstAvailable", "GST Available"],
                ["taxInvoiceAvailable", "Tax Invoice Available"],
                ["financePending", "Finance / Loan Pending"],
                ["deliveryAvailable", "Delivery Available"],
                ["loadingAvailable", "Loading Available"],
              ].map(([key, label]) => (
                <YesNo
                  key={key}
                  label={label}
                  value={yesNo[key]}
                  onChange={(v) => setYesNo((p) => ({ ...p, [key]: v }))}
                />
              ))}
            </div>

            <ChipGroup
              label="Owner Type"
              options={[...OWNER_TYPES]}
              value={owner}
              onChange={setOwner}
            />

            <div className="mt-4">
              <Field label="Remark (If Any)">
                <textarea
                  rows={3}
                  placeholder="Anything a buyer should know before quoting"
                  value={values.additionalRemarks}
                  onChange={(e) => set("additionalRemarks", e.target.value)}
                  className="w-full resize-y rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none placeholder:text-faint focus:border-navy-600"
                />
              </Field>
            </div>
          </Card>

          <Card>
            <CardHeader
              title="Marketplace display"
              subtitle="Admin-only fields the seller wizard does not expose"
            />
            <div className="grid gap-4">
              <Field label="Catalogue category">
                <select
                  value={values.catalogueCategory}
                  onChange={(e) => set("catalogueCategory", e.target.value)}
                  className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
                >
                  <option value="">
                    {config.loading
                      ? "Loading categories…"
                      : "Select a category"}
                  </option>
                  {catalogueCategories.map((c) => (
                    <option key={c}>{c}</option>
                  ))}
                  {values.catalogueCategory &&
                    !catalogueCategories.includes(values.catalogueCategory) && (
                      <option>{values.catalogueCategory}</option>
                    )}
                </select>
              </Field>
              <Field label="Listing status">
                <select
                  value={status}
                  onChange={(e) =>
                    setStatus(e.target.value as Product["status"])
                  }
                  className="w-full rounded-lg border border-line bg-white px-3 py-2.5 text-sm outline-none focus:border-navy-600"
                >
                  {[
                    "Live",
                    "Pending Review",
                    "Under Offer",
                    "Sold",
                    "Rejected",
                  ].map((s) => (
                    <option key={s}>{s}</option>
                  ))}
                </select>
              </Field>
              <Field label="Badge">
                <Input
                  placeholder="EXCELLENT CONDITION"
                  value={values.badge}
                  onChange={(e) => set("badge", e.target.value)}
                />
              </Field>
              <Field label="Price note">
                <Input
                  placeholder="EXCL. SHIPPING"
                  value={values.priceNote}
                  onChange={(e) => set("priceNote", e.target.value)}
                />
              </Field>
              <Field label="Call to action label">
                <Input
                  placeholder="Request Technical Audit"
                  value={values.ctaLabel}
                  onChange={(e) => set("ctaLabel", e.target.value)}
                />
              </Field>
            </div>
          </Card>

          <Card className="bg-navy-800 text-white">
            <p className="text-sm font-bold">Ready to publish?</p>
            <p className="mt-1.5 text-xs text-white/70">
              Published listings appear in the buyer app immediately and are
              indexed for search.
            </p>
            <Button
              type="submit"
              disabled={saving}
              className="mt-4 w-full"
              onClick={(e) => {
                e.preventDefault();
                save("Live");
              }}
            >
              {saving ? "Saving…" : submitLabel}
            </Button>
          </Card>
        </div>
      </form>
    </>
  );
}

/** Human-readable size for a file the desk just picked. */
function readableSize(bytes: number): string {
  if (bytes >= 1024 * 1024) return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
  return `${Math.round(bytes / 1024)} KB`;
}

/**
 * One paperwork type, with the file attached to it.
 *
 * Ticking a box used to be the whole feature; the buyer's product page now
 * links to the actual document, so the file has to come with it.
 */
function DocumentRow({
  type,
  file,
  onAttach,
  onRemove,
}: {
  type: string;
  file: DocumentFile | null;
  onAttach: (file: DocumentFile) => void;
  onRemove: () => void;
}) {
  const picker = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);

  async function pick(files: FileList | null) {
    const chosen = files?.[0];
    if (!chosen) return;

    setUploading(true);
    try {
      const result = await api.upload([chosen]);
      onAttach({
        name: chosen.name,
        size: readableSize(chosen.size),
        category: type,
        uploadedOn: new Date().toISOString().slice(0, 10),
        url: result.files[0].url,
      });
    } catch (error) {
      window.alert((error as Error).message);
    } finally {
      setUploading(false);
      if (picker.current) picker.current.value = "";
    }
  }

  return (
    <div
      className={cx(
        "flex flex-wrap items-center gap-3 rounded-lg border px-3.5 py-2.5",
        file ? "border-accent-500 bg-accent-50" : "border-line bg-white",
      )}
    >
      <input
        ref={picker}
        type="file"
        accept=".pdf,image/*"
        hidden
        onChange={(e) => pick(e.target.files)}
      />

      <span
        className={cx(
          "grid h-5 w-5 shrink-0 place-items-center rounded-full text-[11px] font-bold text-white",
          file ? "bg-accent-500" : "bg-slate-300",
        )}
      >
        {file ? "✓" : ""}
      </span>

      <div className="min-w-0 flex-1">
        <p
          className={cx(
            "truncate text-sm",
            file ? "font-semibold text-accent-700" : "text-ink",
          )}
        >
          {type}
        </p>
        {file && (
          <p className="truncate text-xs text-muted">
            {file.name} · {file.size}
            {file.url ? "" : " · not uploaded"}
          </p>
        )}
      </div>

      {file?.url && (
        <a
          href={file.url}
          target="_blank"
          rel="noreferrer"
          className="text-xs font-semibold text-navy-700 underline"
        >
          View
        </a>
      )}
      <Button
        size="sm"
        variant="ghost"
        disabled={uploading}
        onClick={() => picker.current?.click()}
      >
        {uploading ? "Uploading…" : file ? "Replace" : "Attach file"}
      </Button>
      {file && (
        <Button size="sm" variant="ghost" onClick={onRemove}>
          Remove
        </Button>
      )}
    </div>
  );
}

/* ------------------------------------------------------------- controls -- */

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-sm font-semibold text-navy-800">
        {label}
      </span>
      {children}
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

function ChipGroup({
  label,
  options,
  value,
  onChange,
}: {
  label: string;
  options: string[];
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <div className="mt-5">
      <p className="mb-2 text-sm font-semibold text-navy-800">{label}</p>
      <div className="flex flex-wrap gap-2">
        {options.map((o) => (
          <button
            key={o}
            type="button"
            onClick={() => onChange(value === o ? "" : o)}
            className={cx(
              "rounded-full px-3.5 py-2 text-xs font-semibold transition-colors",
              value === o
                ? "bg-navy-800 text-white"
                : "bg-canvas text-muted ring-1 ring-line ring-inset hover:bg-navy-50 hover:text-navy-700",
            )}
          >
            {o}
          </button>
        ))}
      </div>
    </div>
  );
}

/** Yes / No pair with a blank third state, matching the paper form. */
function YesNo({
  label,
  value,
  onChange,
}: {
  label: string;
  value: boolean | null;
  onChange: (v: boolean | null) => void;
}) {
  return (
    <div className="flex items-center justify-between gap-3 border-b border-line py-2.5 last:border-0">
      <span className="text-sm text-ink">{label}</span>
      <div className="flex gap-1.5">
        {[true, false].map((option) => (
          <button
            key={String(option)}
            type="button"
            onClick={() => onChange(value === option ? null : option)}
            className={cx(
              "w-12 rounded-md py-1.5 text-xs font-bold transition-colors",
              value === option
                ? "bg-accent-500 text-white"
                : "bg-white text-muted ring-1 ring-line ring-inset hover:bg-canvas",
            )}
          >
            {option ? "Yes" : "No"}
          </button>
        ))}
      </div>
    </div>
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
