"use client";

import { useRouter } from "next/navigation";
import { use } from "react";
import ProductForm from "@/components/ProductForm";
import { BackLink } from "@/components/record";
import { Card, EmptyState } from "@/components/ui";
import { api, useApi } from "@/lib/api";
import type { Product } from "@/lib/types";

export default function EditProductPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const router = useRouter();
  const record = useApi<{ product: Product }>(`/api/admin/products/${id}`);
  const product = record.data?.product;

  if (!product) {
    return (
      <>
        <BackLink href="/products" label="Back to Products" />
        <Card>
          <EmptyState
            title={record.loading ? "Loading listing…" : "Listing not found"}
            message={record.error ?? `No machine is filed under ${id}.`}
          />
        </Card>
      </>
    );
  }

  return (
    <>
      <BackLink href={`/products/${id}`} label="Back to listing" />
      <ProductForm
        title={`Edit ${product.title}`}
        subtitle={`${product.id} · changes go live in the buyer app immediately`}
        submitLabel="Save changes"
        product={product}
        onSubmit={async (payload) => {
          await api.put(`/api/admin/products/${id}`, payload);
          router.push(`/products/${id}`);
        }}
      />
    </>
  );
}
