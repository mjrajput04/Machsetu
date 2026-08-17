"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { use, useState } from "react";
import { api, useApi } from "@/lib/api";
import type { Product } from "@/lib/types";
import { rupees, shortDate } from "@/lib/format";
import {
  Badge,
  Button,
  Card,
  CardHeader,
  EmptyState,
  PageHeader,
  statusTone,
} from "@/components/ui";
import {
  BackLink,
  CommercialCard,
  DetailsCard,
  DocumentsCard,
  Gallery,
  PhotosChecklistCard,
  SellerCard,
  SpecsCard,
} from "@/components/record";

export default function ProductDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  const record = useApi<{ product: Product }>(`/api/admin/products/${id}`);
  const product = record.data?.product;

  async function setStatus(status: string) {
    setBusy(true);
    try {
      await api.put(`/api/admin/products/${id}`, { status });
      record.reload();
    } catch (error) {
      window.alert((error as Error).message);
    } finally {
      setBusy(false);
    }
  }

  async function remove() {
    if (!window.confirm(`Delete ${product?.title}? This cannot be undone.`)) {
      return;
    }
    setBusy(true);
    try {
      await api.del(`/api/admin/products/${id}`);
      router.push("/products");
    } catch (error) {
      window.alert((error as Error).message);
      setBusy(false);
    }
  }

  if (!product) {
    return (
      <>
        <BackLink href="/products" label="Back to Products" />
        <Card>
          <EmptyState
            title={record.loading ? "Loading listing…" : "Listing not found"}
            message={
              record.error ?? `No machine is filed under ${id}.`
            }
          />
        </Card>
      </>
    );
  }

  return (
    <>
      <BackLink href="/products" label="Back to Products" />

      <PageHeader
        title={product.title}
        subtitle={`${product.id} · ${product.brand} · ${product.type}`}
        actions={
          <>
            <Link href={`/products/${product.id}/edit`}>
              <Button variant="secondary">Edit listing</Button>
            </Link>
            <Button
              variant="secondary"
              disabled={busy}
              onClick={() =>
                setStatus(product.status === "Live" ? "Pending Review" : "Live")
              }
            >
              {product.status === "Live" ? "Unpublish" : "Publish"}
            </Button>
            <Button variant="danger" disabled={busy} onClick={remove}>
              Delete
            </Button>
          </>
        }
      />

      <div className="grid gap-4 xl:grid-cols-5">
        <div className="space-y-4 xl:col-span-3">
          <Card>
            <Gallery images={product.images} alt={product.title} />

            <div className="mt-5 flex flex-wrap items-start justify-between gap-4">
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <Badge tone={statusTone(product.status)} dot>
                    {product.status}
                  </Badge>
                  <Badge tone="navy">{product.category}</Badge>
                  <Badge tone="accent">{product.badge}</Badge>
                </div>
                <h2 className="mt-3 text-2xl font-extrabold text-navy-800">
                  {product.title}
                </h2>
                <p className="mt-1 text-sm text-muted">
                  {product.type} · {product.year} · {product.condition}
                </p>
              </div>
              <div className="text-right">
                <p className="text-3xl font-extrabold text-accent-600">
                  {rupees(product.price)}
                </p>
                <p className="text-xs font-semibold text-muted">
                  {product.priceNote}
                </p>
              </div>
            </div>

            <div className="mt-5 grid grid-cols-2 gap-3 border-t border-line pt-5 sm:grid-cols-4">
              <Stat label="Views" value={`${product.views}`} />
              <Stat label="Inquiries" value={`${product.inquiries}`} />
              <Stat label="Working hours" value={product.hours} />
              <Stat label="Listed on" value={shortDate(product.listedOn)} />
            </div>
          </Card>

          <Card>
            <CardHeader
              title="Overview"
              subtitle="Marketing copy shown on the buyer product page"
            />
            {product.overview.map((para) => (
              <p
                key={para.slice(0, 24)}
                className="mb-3 text-sm leading-relaxed text-muted last:mb-0"
              >
                {para}
              </p>
            ))}
            <div className="mt-4 flex flex-wrap gap-2">
              {product.features.map((f) => (
                <span
                  key={f}
                  className="rounded-full bg-canvas px-3 py-1.5 text-xs font-semibold text-muted ring-1 ring-line ring-inset"
                >
                  {f}
                </span>
              ))}
            </div>
          </Card>

          <DetailsCard
            details={product.details}
            categories={product.categories}
            location={product.location}
            hours={product.hours}
            condition={product.condition}
            description={product.description}
          />

          <SpecsCard specs={product.specs} />
        </div>

        <div className="space-y-4 xl:col-span-2">
          <Card>
            <CardHeader title="Listing status" />
            <dl className="divide-y divide-line/70">
              {[
                ["Listing ID", product.id],
                ["Status", product.status],
                ["Seller", product.seller],
                ["Location", product.location],
                ["Country of origin", product.origin],
                ["Call to action", product.ctaLabel],
              ].map(([label, value]) => (
                <div
                  key={label}
                  className="flex items-center justify-between gap-4 py-2.5"
                >
                  <dt className="text-sm text-muted">{label}</dt>
                  <dd className="text-sm font-semibold text-navy-800">
                    {value}
                  </dd>
                </div>
              ))}
            </dl>
            <Link href="/requests" className="mt-4 block">
              <Button variant="secondary" className="w-full">
                View seller submission
              </Button>
            </Link>
          </Card>

          <CommercialCard
            commercial={product.commercial}
            price={product.price}
            remark={product.additionalRemarks}
          />

          <SellerCard
            seller={product.sellerInfo}
            subtitle={`Listed ${shortDate(product.listedOn)}`}
          />

          <DocumentsCard documents={product.documents} />

          <PhotosChecklistCard ticked={product.requiredPhotos} />
        </div>
      </div>
    </>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs font-bold tracking-wide text-muted uppercase">
        {label}
      </p>
      <p className="mt-1 text-lg font-extrabold text-navy-800">{value}</p>
    </div>
  );
}
