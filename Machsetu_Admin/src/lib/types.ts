import type { Category, InspectionRating } from "./options";

/**
 * Shared shapes for the admin console.
 *
 * Field-for-field mirrors of the Flutter app's models so nothing a seller
 * submits is lost on the way to the approval desk.
 */

/** Section 1 of the registration form. */
export interface SellerInfo {
  name: string;
  company: string;
  mobile: string;
  whatsapp: string;
  email: string;
  gstNumber: string;
  panNumber: string;
  address: string;
  city: string;
  state: string;
  pincode: string;
}

/** Section 3 of the registration form. */
export interface CommercialInfo {
  negotiable: boolean | null;
  gstAvailable: boolean | null;
  taxInvoiceAvailable: boolean | null;
  financePending: boolean | null;
  deliveryAvailable: boolean | null;
  loadingAvailable: boolean | null;
  ownerType: string;
}

/** Section 4 of the registration form. */
export interface MachineSpecs {
  tableSize: string;
  lubricationSystem: string;
  electricalPanelCondition: string;
  toolMagazineCapacity: string;
  servoMotors: string;
  toolChangerType: string;
  ballScrewCondition: string;
  coolantSystem: string;
  guideways: string;
  hydraulicSystem: string;
  otherSpecifications: string;
}

/** Section 2 of the registration form. */
export interface MachineDetails {
  machineType: string;
  installationYear: string;
  countryOfOrigin: string;
  controller: string;
  numberOfAxis: string;
  machineCapacity: string;
  powerRequirement: string;
  maxSpindleSpeed: string;
  weight: string;
  workingStatus: string;
  maintenanceStatus: string;
  lastServiceDate: string;
  accessoriesIncluded: string;
  serialNumber: string;
}

export interface DocumentFile {
  name: string;
  size: string;
  category: string;
  uploadedOn: string;
}

/** Section 7 — filled by the inspector after a site visit. */
export interface InspectionPoint {
  point: string;
  rating: InspectionRating;
  remark?: string;
}

export interface InspectionReport {
  points: InspectionPoint[];
  remarks: string;
  inspectorName: string;
  inspectedOn: string;
}

export type ProductStatus =
  | "Live"
  | "Pending Review"
  | "Under Offer"
  | "Sold"
  | "Rejected";

/**
 * A catalogue listing. Carries the full registration record plus the
 * marketplace-facing content the buyer app renders.
 */
export interface Product {
  id: string;
  title: string;
  brand: string;
  type: string;
  category: Category;
  /** Ticked category boxes from the registration form. */
  categories: string[];
  year: string;
  price: number;
  location: string;
  condition: string;
  hours: string;
  origin: string;
  status: ProductStatus;
  views: number;
  inquiries: number;
  seller: string;
  listedOn: string;

  /* --- buyer-app content ------------------------------------------------ */
  badge: string;
  priceNote: string;
  ctaLabel: string;
  images: string[];
  overview: string[];
  features: string[];
  description: string;

  /* --- registration record --------------------------------------------- */
  sellerInfo: SellerInfo;
  details: MachineDetails;
  specs: MachineSpecs;
  commercial: CommercialInfo;
  documents: DocumentFile[];
  requiredPhotos: string[];
  additionalRemarks: string;
}

export type RequestStatus =
  | "Awaiting Review"
  | "Inspection Scheduled"
  | "Approved"
  | "Rejected";

/**
 * A seller submission awaiting approval. Holds everything the wizard
 * captured, so the desk can review without leaving the screen.
 */
export interface SellRequest {
  id: string;
  machine: string;
  brand: string;
  model: string;
  category: Category;
  categories: string[];
  year: string;
  askingPrice: number;
  condition: string;
  hours: string;
  city: string;
  seller: string;
  status: RequestStatus;
  submittedOn: string;
  note: string;
  description: string;

  images: string[];
  documents: DocumentFile[];
  requiredPhotos: string[];

  sellerInfo: SellerInfo;
  details: MachineDetails;
  specs: MachineSpecs;
  commercial: CommercialInfo;
  inspection: InspectionReport | null;
}

export type UserRole = "Buyer" | "Seller" | "Both" | "Broker";
export type UserStatus = "Active" | "Pending KYC" | "Suspended";

export interface User {
  id: string;
  name: string;
  /** Free-text job title, matching the app's profile field. */
  designation: string;
  company: string;
  email: string;
  phone: string;
  whatsapp: string;
  address: string;
  city: string;
  state: string;
  pincode: string;
  gstin: string;
  pan: string;
  role: UserRole;
  status: UserStatus;
  listings: number;
  orders: number;
  joinedOn: string;
}

/**
 * Inquiry statuses — the union of the app's seller-facing labels and the
 * desk's pipeline stages, so one record serves both screens.
 */
export type InquiryStatus =
  | "New"
  | "Broker Assigned"
  | "Awaiting Quote"
  | "Quote Received"
  | "Negotiating"
  | "Closed"
  | "Lost"
  | "Expired";

export interface Inquiry {
  id: string;
  machine: string;
  brand: string;
  image: string | null;
  /** Technical requirements the buyer submitted with the RFQ. */
  specs: string[];
  buyer: string;
  company: string;
  city: string;
  budget: number;
  quoted: number | null;
  status: InquiryStatus;
  broker: string | null;
  responseNote: string;
  raisedOn: string;
  lastActivity: string;
}

/** The eight stops the app's tracking timeline draws, in order. */
export type OrderStage =
  | "Inquiry Received"
  | "Under Review"
  | "Broker Contacting You"
  | "Price Confirmed"
  | "Machine Reserved"
  | "Order Confirmed"
  | "Delivery Scheduled"
  | "Delivered";

export interface Order {
  id: string;
  machine: string;
  image: string | null;
  buyer: string;
  seller: string;
  amount: number;
  stage: OrderStage;
  placedOn: string;
  destination: string;
}

/** A live account as the console API returns it, straight from MongoDB. */
export interface AdminUser {
  id: string;
  name: string;
  /** Uploaded profile photo path, empty when they have not set one. */
  avatar: string;
  designation: string;
  company: string;
  email: string;
  phone: string;
  whatsapp: string;
  address: string;
  city: string;
  state: string;
  pincode: string;
  gstin: string;
  pan: string;
  role: UserRole;
  status: UserStatus;
  phoneVerified: boolean;
  twoFactor: boolean;
  biometrics: boolean;
  loginAlerts: boolean;
  listings: number;
  orders: number;
  joinedOn: string;
  lastLoginAt: string | null;
}
