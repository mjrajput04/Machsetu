"use client";

import { useRouter } from "next/navigation";
import ProductForm from "@/components/ProductForm";
import { api } from "@/lib/api";
import type { Product } from "@/lib/types";

export default function AddProductPage() {
  const router = useRouter();

  return (
    <ProductForm
      title="Add Product"
      subtitle="Same registration record as the seller app — every field optional."
      submitLabel="Publish listing"
      onSubmit={async (payload) => {
        const created = await api.post<{ product: Product }>(
          "/api/admin/products",
          payload,
        );
        router.push(`/products/${created.product.id}`);
      }}
    />
  );
}
