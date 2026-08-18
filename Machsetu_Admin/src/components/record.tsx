import Image from "next/image";
import { REQUIRED_PHOTOS } from "@/lib/options";
import type {
  CommercialInfo,
  DocumentFile,
  InspectionReport,
  MachineDetails,
  MachineSpecs,
  SellerInfo,
} from "@/lib/types";
import { rupees } from "@/lib/format";
import { Avatar, Badge, Button, Card, CardHeader, cx } from "./ui";

/** Yes / No / blank, matching the app's tri-state commercial answers. */
export function yn(value: boolean | null) {
  return value === null ? "—" : value ? "Yes" : "No";
}

/** Two-column label/value list; blanks render as an em dash. */
export function Rows({ rows }: { rows: Array<[string, string]> }) {
  return (
    <dl className="divide-y divide-line/70">
      {rows.map(([label, value]) => (
        <div
          key={label}
          className="flex items-start justify-between gap-4 py-2.5"
        >
          <dt className="text-sm text-muted">{label}</dt>
          <dd className="max-w-[60%] text-right text-sm font-semibold text-navy-800">
            {value?.trim() ? value : "—"}
          </dd>
        </div>
      ))}
    </dl>
  );
}

export function SellerCard({
  seller,
  subtitle,
}: {
  seller: SellerInfo;
  subtitle?: string;
}) {
  return (
    <Card>
      <CardHeader
        title="1 · Seller Information"
        subtitle={subtitle}
        action={<Avatar name={seller.name || "Seller"} tone="accent" />}
      />
      <Rows
        rows={[
          ["Contact Person", seller.name],
          ["Company Name", seller.company],
          ["Mobile Number", seller.mobile],
          ["WhatsApp Number", seller.whatsapp],
          ["Email ID", seller.email],
          ["GST Number", seller.gstNumber],
          ["PAN Number", seller.panNumber],
          ["Address", seller.address],
          ["City", seller.city],
          ["State", seller.state],
          ["Pincode", seller.pincode],
        ]}
      />
    </Card>
  );
}

export function DetailsCard({
  details,
  categories,
  location,
  hours,
  condition,
  description,
}: {
  details: MachineDetails;
  categories: string[];
  location: string;
  hours: string;
  condition: string;
  description?: string;
}) {
  return (
    <Card>
      <CardHeader title="2 · Machine Details" />
      {categories.length > 0 && (
        <div className="mb-4 flex flex-wrap gap-1.5">
          {categories.map((c) => (
            <Badge key={c} tone="navy">
              {c}
            </Badge>
          ))}
        </div>
      )}
      <Rows
        rows={[
          ["Machine Type", details.machineType],
          ["Controller", details.controller],
          ["No. of Axis", details.numberOfAxis],
          ["Machine Capacity / Size", details.machineCapacity],
          ["Maximum Spindle Speed", details.maxSpindleSpeed],
          ["Power Requirement", details.powerRequirement],
          ["Weight of Machine", details.weight],
          ["Installation Year", details.installationYear],
          ["Country of Origin", details.countryOfOrigin],
          ["Machine Location", location],
          ["Working Hours", hours],
          ["Working Status", details.workingStatus],
          ["Machine Condition", condition],
          ["Maintenance Status", details.maintenanceStatus],
          ["Last Service Date", details.lastServiceDate],
          ["Serial Number", details.serialNumber],
          ["Accessories Included", details.accessoriesIncluded],
        ]}
      />
      {description && (
        <div className="mt-4 rounded-lg bg-canvas p-3.5">
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Machine Description
          </p>
          <p className="mt-1.5 text-sm leading-relaxed text-ink">
            {description}
          </p>
        </div>
      )}
    </Card>
  );
}

export function CommercialCard({
  commercial,
  price,
  remark,
}: {
  commercial: CommercialInfo;
  price: number;
  remark?: string;
}) {
  return (
    <Card>
      <CardHeader title="3 · Commercial Information" />
      <Rows
        rows={[
          ["Expected Selling Price", rupees(price)],
          ["Negotiable", yn(commercial.negotiable)],
          ["GST Available", yn(commercial.gstAvailable)],
          ["Tax Invoice Available", yn(commercial.taxInvoiceAvailable)],
          ["Finance / Loan Pending", yn(commercial.financePending)],
          ["Owner Type", commercial.ownerType],
          ["Delivery Available", yn(commercial.deliveryAvailable)],
          ["Loading Available", yn(commercial.loadingAvailable)],
        ]}
      />
      {remark && (
        <div className="mt-4 rounded-lg border-l-4 border-accent-500 bg-canvas p-4">
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Remark
          </p>
          <p className="mt-1.5 text-sm leading-relaxed text-ink">{remark}</p>
        </div>
      )}
    </Card>
  );
}

export function SpecsCard({ specs }: { specs: MachineSpecs }) {
  return (
    <Card>
      <CardHeader title="4 · Machine Specifications" />
      <Rows
        rows={[
          ["Table Size", specs.tableSize],
          ["Lubrication System", specs.lubricationSystem],
          ["Electrical Panel Condition", specs.electricalPanelCondition],
          ["Tool Magazine Capacity", specs.toolMagazineCapacity],
          ["Servo Motors", specs.servoMotors],
          ["Tool Changer Type", specs.toolChangerType],
          ["Ball Screw Condition", specs.ballScrewCondition],
          ["Coolant System", specs.coolantSystem],
          ["Guideways", specs.guideways],
          ["Hydraulic System", specs.hydraulicSystem],
          ["Other Specifications", specs.otherSpecifications],
        ]}
      />
    </Card>
  );
}

/** Three-letter badge for the file behind a document row. */
function fileKind(url: string): string {
  const ext = url.split(".").pop()?.toUpperCase() ?? "";
  return ext.length > 0 && ext.length <= 4 ? ext : "FILE";
}

export function DocumentsCard({ documents }: { documents: DocumentFile[] }) {
  return (
    <Card>
      <CardHeader
        title="5 · Documents"
        subtitle={`${documents.length} attached`}
      />
      {documents.length === 0 ? (
        <p className="text-sm text-muted">Nothing attached.</p>
      ) : (
        <ul className="space-y-2">
          {documents.map((d, index) => (
            <li
              key={`${d.name}-${index}`}
              className="flex items-center gap-3 rounded-lg border border-line p-2.5"
            >
              <span
                className={
                  d.url
                    ? "grid h-9 w-9 shrink-0 place-items-center rounded-md bg-rose-50 text-[10px] font-bold text-rose-600"
                    : "grid h-9 w-9 shrink-0 place-items-center rounded-md bg-canvas text-[10px] font-bold text-faint"
                }
              >
                {d.url ? fileKind(d.url) : "—"}
              </span>
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-semibold text-navy-800">
                  {d.name}
                </p>
                <p className="truncate text-xs text-muted">
                  {d.size} · {d.category} · {d.uploadedOn}
                </p>
              </div>
              {d.url ? (
                <a href={d.url} target="_blank" rel="noreferrer">
                  <Button size="sm" variant="ghost">
                    Open
                  </Button>
                </a>
              ) : (
                <span className="px-2 text-xs text-faint">No file</span>
              )}
            </li>
          ))}
        </ul>
      )}
    </Card>
  );
}

export function PhotosChecklistCard({ ticked }: { ticked: string[] }) {
  return (
    <Card>
      <CardHeader
        title="6 · Required Photos"
        subtitle={`${ticked.length} of ${REQUIRED_PHOTOS.length} ticked`}
      />
      <div className="flex flex-wrap gap-1.5">
        {REQUIRED_PHOTOS.map((v) => {
          const has = ticked.includes(v);
          return (
            <span
              key={v}
              className={cx(
                "rounded-md px-2 py-1 text-[11px] font-semibold",
                has
                  ? "bg-emerald-50 text-emerald-700"
                  : "bg-canvas text-faint line-through",
              )}
            >
              {has ? "✓ " : ""}
              {v}
            </span>
          );
        })}
      </div>
    </Card>
  );
}

function ratingTone(rating: string) {
  switch (rating) {
    case "Excellent":
      return "success" as const;
    case "Good":
      return "info" as const;
    case "Average":
      return "warning" as const;
    case "Poor":
      return "danger" as const;
    default:
      return "neutral" as const;
  }
}

export function InspectionCard({
  report,
  subtitle,
}: {
  report: InspectionReport | null;
  subtitle: string;
}) {
  return (
    <Card>
      <CardHeader title="7 · Inspection Report" subtitle={subtitle} />
      {!report ? (
        <div className="rounded-lg border border-dashed border-line px-4 py-8 text-center">
          <p className="text-sm font-semibold text-navy-800">
            No inspection on file
          </p>
          <p className="mt-1 text-sm text-muted">
            Schedule a site visit to capture the 12-point report.
          </p>
          <Button variant="secondary" className="mt-3">
            Schedule inspection
          </Button>
        </div>
      ) : (
        <>
          <ul className="space-y-1.5">
            {report.points.map((p) => (
              <li
                key={p.point}
                className="flex items-center justify-between gap-3 border-b border-line/70 py-2 last:border-0"
              >
                <div className="min-w-0">
                  <p className="text-sm text-ink">{p.point}</p>
                  {p.remark && (
                    <p className="text-xs text-faint">{p.remark}</p>
                  )}
                </div>
                <Badge tone={ratingTone(p.rating)}>{p.rating}</Badge>
              </li>
            ))}
          </ul>
          <div className="mt-4 rounded-lg bg-canvas p-3.5">
            <p className="text-xs font-bold tracking-wide text-muted uppercase">
              Inspector Remarks
            </p>
            <p className="mt-1.5 text-sm leading-relaxed text-ink">
              {report.remarks}
            </p>
          </div>
        </>
      )}
    </Card>
  );
}

/** Hero strip: large lead photo with the rest as thumbnails beneath. */
export function Gallery({ images, alt }: { images: string[]; alt: string }) {
  if (images.length === 0) {
    return (
      <div className="grid h-64 place-items-center rounded-xl bg-navy-50 text-sm text-muted">
        No photos attached
      </div>
    );
  }

  return (
    <div>
      <div className="relative aspect-16/9 overflow-hidden rounded-xl bg-navy-50">
        <Image
          src={images[0]}
          alt={alt}
          fill
          priority
          sizes="(max-width: 1280px) 100vw, 640px"
          className="object-cover"
        />
      </div>
      {images.length > 1 && (
        <div className="mt-2 grid grid-cols-4 gap-2">
          {images.slice(1, 5).map((src) => (
            <div
              key={src}
              className="relative aspect-4/3 overflow-hidden rounded-lg bg-navy-50"
            >
              <Image
                src={src}
                alt={alt}
                fill
                sizes="160px"
                className="object-cover"
              />
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

/** Small "‹ Back to …" link used at the top of every detail page. */
export function BackLink({ href, label }: { href: string; label: string }) {
  return (
    <a
      href={href}
      className="mb-4 inline-flex items-center gap-1.5 text-sm font-semibold text-muted transition-colors hover:text-navy-700"
    >
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
        className="h-4 w-4"
      >
        <path d="m15 18-6-6 6-6" />
      </svg>
      {label}
    </a>
  );
}
