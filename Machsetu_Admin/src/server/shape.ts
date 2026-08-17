/**
 * Fills in every field the console and the app read off a listing.
 *
 * Documents reach the catalogue from three directions — the seed import, an
 * approved seller submission, and the Add-product form — so they are levelled
 * out here rather than guarded at each render site.
 */
export function withProductDefaults(
  body: Record<string, unknown>,
): Record<string, unknown> {
  const text = (key: string, fallback = "") =>
    body[key] === undefined || body[key] === null
      ? fallback
      : String(body[key]);

  const arr = (key: string) => (Array.isArray(body[key]) ? body[key] : []);
  const obj = (key: string, shape: Record<string, unknown>) => ({
    ...shape,
    ...((body[key] as Record<string, unknown>) ?? {}),
  });

  const price = Number(
    String(body.price ?? "").replace(/[^0-9.]/g, "") || 0,
  );

  return {
    ...body,
    title: text("title", "Untitled machine"),
    brand: text("brand"),
    type: text("type"),
    category: text("category"),
    categories: arr("categories"),
    year: text("year"),
    price: Number.isFinite(price) ? price : 0,
    location: text("location"),
    condition: text("condition"),
    hours: text("hours"),
    origin: text("origin"),
    status: text("status", "Pending Review"),
    views: Number(body.views ?? 0),
    inquiries: Number(body.inquiries ?? 0),
    seller: text("seller"),
    listedOn: text("listedOn", new Date().toISOString().slice(0, 10)),
    badge: text("badge", "VERIFIED"),
    priceNote: text("priceNote", "EXCL. SHIPPING"),
    ctaLabel: text("ctaLabel", "Request Technical Audit"),
    images: arr("images"),
    overview: arr("overview"),
    features: arr("features"),
    description: text("description"),
    documents: arr("documents"),
    requiredPhotos: arr("requiredPhotos"),
    additionalRemarks: text("additionalRemarks"),
    sellerInfo: obj("sellerInfo", {
      name: "",
      company: "",
      mobile: "",
      whatsapp: "",
      email: "",
      gstNumber: "",
      panNumber: "",
      address: "",
      city: "",
      state: "",
      pincode: "",
    }),
    details: obj("details", {
      machineType: "",
      installationYear: "",
      countryOfOrigin: "",
      controller: "",
      numberOfAxis: "",
      machineCapacity: "",
      powerRequirement: "",
      maxSpindleSpeed: "",
      weight: "",
      workingStatus: "",
      maintenanceStatus: "",
      lastServiceDate: "",
      accessoriesIncluded: "",
      serialNumber: "",
      location: "",
    }),
    specs: obj("specs", {
      tableSize: "",
      lubricationSystem: "",
      electricalPanelCondition: "",
      toolMagazineCapacity: "",
      servoMotors: "",
      toolChangerType: "",
      ballScrewCondition: "",
      coolantSystem: "",
      guideways: "",
      hydraulicSystem: "",
      otherSpecifications: "",
    }),
    commercial: obj("commercial", {
      negotiable: null,
      gstAvailable: null,
      taxInvoiceAvailable: null,
      financePending: null,
      deliveryAvailable: null,
      loadingAvailable: null,
      ownerType: "",
    }),
  };
}
