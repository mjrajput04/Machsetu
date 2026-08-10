/**
 * Mock dataset for the admin panel.
 *
 * Mirrors the MachSetu buyer app so the two line up during demos. Everything
 * here is static — swap these arrays for API calls when the backend lands.
 */

export const CATEGORIES = [
  "CNC Machines",
  "VMC Centers",
  "Lathes",
  "Grinders",
  "EDM",
] as const;

export type Category = (typeof CATEGORIES)[number];

export type ProductStatus =
  | "Live"
  | "Pending Review"
  | "Under Offer"
  | "Sold"
  | "Rejected";

export interface Product {
  id: string;
  title: string;
  brand: string;
  type: string;
  category: Category;
  year: string;
  price: number;
  location: string;
  condition: "Excellent" | "Good" | "Average" | "Fair";
  hours: string;
  origin: string;
  status: ProductStatus;
  views: number;
  inquiries: number;
  seller: string;
  listedOn: string;
}

export const PRODUCTS: Product[] = [
  {
    id: "MS-1001",
    title: "DMG MORI DMU 50",
    brand: "DMG MORI",
    type: "5-Axis Universal Machining Center",
    category: "CNC Machines",
    year: "2019",
    price: 14500000,
    location: "Pune, MH",
    condition: "Excellent",
    hours: "6,400",
    origin: "Germany",
    status: "Live",
    views: 412,
    inquiries: 9,
    seller: "Aerotech Solutions",
    listedOn: "2026-06-12",
  },
  {
    id: "MS-1002",
    title: "Mazak INTEGREX i-200ST",
    brand: "Yamazaki Mazak",
    type: "Multi-Tasking Turning Center",
    category: "CNC Machines",
    year: "2018",
    price: 21000000,
    location: "Bengaluru, KA",
    condition: "Good",
    hours: "11,800",
    origin: "Japan",
    status: "Live",
    views: 356,
    inquiries: 7,
    seller: "Precision Dynamics",
    listedOn: "2026-06-28",
  },
  {
    id: "MS-1003",
    title: "Mazak HCN-4000",
    brand: "Yamazaki Mazak",
    type: "Horizontal Machining Center",
    category: "CNC Machines",
    year: "2017",
    price: 10500000,
    location: "Chennai, TN",
    condition: "Good",
    hours: "14,200",
    origin: "Japan",
    status: "Under Offer",
    views: 288,
    inquiries: 5,
    seller: "Southern Machine Tools",
    listedOn: "2026-05-30",
  },
  {
    id: "MS-1004",
    title: "Haas VF-2SS",
    brand: "Haas Automation",
    type: "Super-Speed Vertical Machining Center",
    category: "VMC Centers",
    year: "2021",
    price: 7050000,
    location: "Rajkot, GJ",
    condition: "Excellent",
    hours: "4,200",
    origin: "USA",
    status: "Live",
    views: 524,
    inquiries: 12,
    seller: "Fortune Gold Machine Tools",
    listedOn: "2026-07-02",
  },
  {
    id: "MS-1005",
    title: "Okuma GENOS M560-V",
    brand: "Okuma",
    type: "Vertical Machining Center",
    category: "VMC Centers",
    year: "2019",
    price: 9200000,
    location: "Coimbatore, TN",
    condition: "Excellent",
    hours: "7,100",
    origin: "Japan",
    status: "Live",
    views: 301,
    inquiries: 6,
    seller: "Kongu Engineering Works",
    listedOn: "2026-06-19",
  },
  {
    id: "MS-1006",
    title: "Doosan DNM 5700",
    brand: "Doosan Machine Tools",
    type: "Vertical Machining Center",
    category: "VMC Centers",
    year: "2020",
    price: 7800000,
    location: "Ahmedabad, GJ",
    condition: "Good",
    hours: "9,300",
    origin: "South Korea",
    status: "Pending Review",
    views: 0,
    inquiries: 0,
    seller: "Sabarmati Precision",
    listedOn: "2026-08-04",
  },
  {
    id: "MS-1007",
    title: "Mazak QUICK TURN 250MY",
    brand: "Yamazaki Mazak",
    type: "CNC Turning Center",
    category: "Lathes",
    year: "2018",
    price: 6200000,
    location: "Pune, MH",
    condition: "Good",
    hours: "12,600",
    origin: "Japan",
    status: "Live",
    views: 268,
    inquiries: 4,
    seller: "Aerotech Solutions",
    listedOn: "2026-05-14",
  },
  {
    id: "MS-1008",
    title: "Doosan PUMA 2600SY",
    brand: "Doosan Machine Tools",
    type: "CNC Turning Center",
    category: "Lathes",
    year: "2019",
    price: 5500000,
    location: "Chennai, TN",
    condition: "Good",
    hours: "15,400",
    origin: "South Korea",
    status: "Sold",
    views: 610,
    inquiries: 15,
    seller: "Southern Machine Tools",
    listedOn: "2026-03-08",
  },
  {
    id: "MS-1009",
    title: "Haas ST-20Y",
    brand: "Haas Automation",
    type: "CNC Lathe with Y-Axis",
    category: "Lathes",
    year: "2021",
    price: 4850000,
    location: "Ludhiana, PB",
    condition: "Excellent",
    hours: "3,800",
    origin: "USA",
    status: "Live",
    views: 195,
    inquiries: 3,
    seller: "Punjab Tooling Co.",
    listedOn: "2026-07-21",
  },
  {
    id: "MS-1010",
    title: "Studer S33",
    brand: "Fritz Studer AG",
    type: "Universal Cylindrical Grinder",
    category: "Grinders",
    year: "2017",
    price: 8800000,
    location: "Pune, MH",
    condition: "Excellent",
    hours: "8,900",
    origin: "Switzerland",
    status: "Live",
    views: 176,
    inquiries: 5,
    seller: "Deccan Grinding Systems",
    listedOn: "2026-06-05",
  },
  {
    id: "MS-1011",
    title: "Okamoto ACC-1224DX",
    brand: "Okamoto",
    type: "Precision Surface Grinder",
    category: "Grinders",
    year: "2019",
    price: 3200000,
    location: "Rajkot, GJ",
    condition: "Good",
    hours: "6,700",
    origin: "Japan",
    status: "Pending Review",
    views: 0,
    inquiries: 0,
    seller: "Fortune Gold Machine Tools",
    listedOn: "2026-08-06",
  },
  {
    id: "MS-1012",
    title: "Ghiringhelli M200 SP",
    brand: "Ghiringhelli",
    type: "Centreless Grinding Machine",
    category: "Grinders",
    year: "2016",
    price: 4100000,
    location: "Bengaluru, KA",
    condition: "Good",
    hours: "13,100",
    origin: "Italy",
    status: "Live",
    views: 143,
    inquiries: 2,
    seller: "Precision Dynamics",
    listedOn: "2026-04-27",
  },
  {
    id: "MS-1013",
    title: "Sodick AG400L",
    brand: "Sodick",
    type: "Wire Cut EDM",
    category: "EDM",
    year: "2019",
    price: 5800000,
    location: "Chennai, TN",
    condition: "Excellent",
    hours: "5,600",
    origin: "Japan",
    status: "Live",
    views: 232,
    inquiries: 6,
    seller: "Southern Machine Tools",
    listedOn: "2026-07-11",
  },
  {
    id: "MS-1014",
    title: "Mitsubishi MV1200R",
    brand: "Mitsubishi Electric",
    type: "Wire Cut EDM",
    category: "EDM",
    year: "2020",
    price: 6400000,
    location: "Pune, MH",
    condition: "Excellent",
    hours: "4,100",
    origin: "Japan",
    status: "Live",
    views: 209,
    inquiries: 4,
    seller: "Deccan Grinding Systems",
    listedOn: "2026-07-29",
  },
  {
    id: "MS-1015",
    title: "Makino EDNC6",
    brand: "Makino",
    type: "Sinker EDM / Small Hole Driller",
    category: "EDM",
    year: "2018",
    price: 3750000,
    location: "Ahmedabad, GJ",
    condition: "Good",
    hours: "10,200",
    origin: "Japan",
    status: "Rejected",
    views: 0,
    inquiries: 0,
    seller: "Sabarmati Precision",
    listedOn: "2026-07-18",
  },
];

export type UserRole = "Buyer" | "Seller" | "Both" | "Broker";
export type UserStatus = "Active" | "Pending KYC" | "Suspended";

export interface User {
  id: string;
  name: string;
  company: string;
  email: string;
  phone: string;
  city: string;
  role: UserRole;
  status: UserStatus;
  gstin: string;
  listings: number;
  orders: number;
  joinedOn: string;
}

export const USERS: User[] = [
  {
    id: "U-2201",
    name: "Pappu Singh",
    company: "Fortune Gold Machine Tools",
    email: "sales@fortunegold.in",
    phone: "+91 84015 03169",
    city: "Rajkot, GJ",
    role: "Seller",
    status: "Active",
    gstin: "24AAACF1234K1ZV",
    listings: 2,
    orders: 0,
    joinedOn: "2025-11-04",
  },
  {
    id: "U-2202",
    name: "Marcus V. Sterling",
    company: "Aerotech Solutions Inc.",
    email: "marcus@aerotech.in",
    phone: "+91 98220 41155",
    city: "Pune, MH",
    role: "Both",
    status: "Active",
    gstin: "27AABCA9021M1Z8",
    listings: 2,
    orders: 12,
    joinedOn: "2025-08-22",
  },
  {
    id: "U-2203",
    name: "Rajesh Kumar",
    company: "Punjab Tooling Co.",
    email: "rajesh@punjabtooling.in",
    phone: "+91 98761 20034",
    city: "Ludhiana, PB",
    role: "Seller",
    status: "Active",
    gstin: "03AACCP7781Q1ZK",
    listings: 1,
    orders: 2,
    joinedOn: "2026-01-17",
  },
  {
    id: "U-2204",
    name: "Anitha Raman",
    company: "Southern Machine Tools",
    email: "anitha@southernmt.in",
    phone: "+91 90031 77820",
    city: "Chennai, TN",
    role: "Both",
    status: "Active",
    gstin: "33AAFCS2210H1ZP",
    listings: 3,
    orders: 7,
    joinedOn: "2025-06-30",
  },
  {
    id: "U-2205",
    name: "Vikram Shetty",
    company: "Precision Dynamics",
    email: "vikram@precisiondyn.in",
    phone: "+91 98450 66712",
    city: "Bengaluru, KA",
    role: "Seller",
    status: "Active",
    gstin: "29AAGCP5567L1ZR",
    listings: 2,
    orders: 1,
    joinedOn: "2025-09-12",
  },
  {
    id: "U-2206",
    name: "Meera Patel",
    company: "Sabarmati Precision",
    email: "meera@sabarmatiprec.in",
    phone: "+91 99250 33418",
    city: "Ahmedabad, GJ",
    role: "Seller",
    status: "Pending KYC",
    gstin: "24AAJCS8890B1ZQ",
    listings: 2,
    orders: 0,
    joinedOn: "2026-07-28",
  },
  {
    id: "U-2207",
    name: "Suresh Nair",
    company: "Kongu Engineering Works",
    email: "suresh@konguworks.in",
    phone: "+91 94430 55219",
    city: "Coimbatore, TN",
    role: "Both",
    status: "Active",
    gstin: "33AAECK4432D1ZN",
    listings: 1,
    orders: 4,
    joinedOn: "2025-12-05",
  },
  {
    id: "U-2208",
    name: "Deepak Joshi",
    company: "Deccan Grinding Systems",
    email: "deepak@deccangrind.in",
    phone: "+91 98600 71144",
    city: "Pune, MH",
    role: "Seller",
    status: "Active",
    gstin: "27AAKCD6654F1ZT",
    listings: 2,
    orders: 0,
    joinedOn: "2026-02-19",
  },
  {
    id: "U-2209",
    name: "Farhan Qureshi",
    company: "Qureshi Auto Components",
    email: "farhan@qureshiauto.in",
    phone: "+91 93220 84470",
    city: "Mumbai, MH",
    role: "Buyer",
    status: "Active",
    gstin: "27AADCQ1102J1ZM",
    listings: 0,
    orders: 9,
    joinedOn: "2025-10-08",
  },
  {
    id: "U-2210",
    name: "Kavita Desai",
    company: "Desai Brokerage",
    email: "kavita@desaibrokers.in",
    phone: "+91 98795 21160",
    city: "Surat, GJ",
    role: "Broker",
    status: "Active",
    gstin: "24AAHCD3345N1ZY",
    listings: 0,
    orders: 0,
    joinedOn: "2026-03-14",
  },
  {
    id: "U-2211",
    name: "Imran Shaikh",
    company: "Shaikh Fabricators",
    email: "imran@shaikhfab.in",
    phone: "+91 90040 12298",
    city: "Nashik, MH",
    role: "Buyer",
    status: "Suspended",
    gstin: "27AAFCS9987R1ZL",
    listings: 0,
    orders: 1,
    joinedOn: "2026-04-02",
  },
  {
    id: "U-2212",
    name: "Nisha Verma",
    company: "Verma Toolroom",
    email: "nisha@vermatoolroom.in",
    phone: "+91 99100 45523",
    city: "Faridabad, HR",
    role: "Buyer",
    status: "Pending KYC",
    gstin: "06AAGCV2214P1ZB",
    listings: 0,
    orders: 0,
    joinedOn: "2026-08-01",
  },
];

export type RequestStatus =
  | "Awaiting Review"
  | "Inspection Scheduled"
  | "Approved"
  | "Rejected";

export interface SellRequest {
  id: string;
  machine: string;
  brand: string;
  category: Category;
  seller: string;
  city: string;
  askingPrice: number;
  year: string;
  photos: number;
  documents: number;
  status: RequestStatus;
  submittedOn: string;
  note: string;
}

export const SELL_REQUESTS: SellRequest[] = [
  {
    id: "REQ-5510",
    machine: "Doosan DNM 5700",
    brand: "Doosan Machine Tools",
    category: "VMC Centers",
    seller: "Sabarmati Precision",
    city: "Ahmedabad, GJ",
    askingPrice: 7800000,
    year: "2020",
    photos: 8,
    documents: 4,
    status: "Awaiting Review",
    submittedOn: "2026-08-04",
    note: "Complete documentation attached. Requesting priority listing.",
  },
  {
    id: "REQ-5511",
    machine: "Okamoto ACC-1224DX",
    brand: "Okamoto",
    category: "Grinders",
    seller: "Fortune Gold Machine Tools",
    city: "Rajkot, GJ",
    askingPrice: 3200000,
    year: "2019",
    photos: 6,
    documents: 3,
    status: "Awaiting Review",
    submittedOn: "2026-08-06",
    note: "Original chuck and spare wheel set included.",
  },
  {
    id: "REQ-5512",
    machine: "Hurco VMX42i",
    brand: "Hurco",
    category: "VMC Centers",
    seller: "Punjab Tooling Co.",
    city: "Ludhiana, PB",
    askingPrice: 5900000,
    year: "2018",
    photos: 10,
    documents: 5,
    status: "Inspection Scheduled",
    submittedOn: "2026-08-01",
    note: "Inspection booked for 12 Aug with R. Deshmukh.",
  },
  {
    id: "REQ-5513",
    machine: "Amada HFE 1003",
    brand: "Amada",
    category: "CNC Machines",
    seller: "Shaikh Fabricators",
    city: "Nashik, MH",
    askingPrice: 4200000,
    year: "2016",
    photos: 4,
    documents: 1,
    status: "Awaiting Review",
    submittedOn: "2026-08-07",
    note: "Invoice missing — seller contacted for proof of ownership.",
  },
  {
    id: "REQ-5514",
    machine: "Agie Charmilles CUT 200",
    brand: "GF Machining",
    category: "EDM",
    seller: "Precision Dynamics",
    city: "Bengaluru, KA",
    askingPrice: 5100000,
    year: "2017",
    photos: 9,
    documents: 4,
    status: "Inspection Scheduled",
    submittedOn: "2026-07-30",
    note: "Awaiting dielectric system report.",
  },
  {
    id: "REQ-5515",
    machine: "Makino EDNC6",
    brand: "Makino",
    category: "EDM",
    seller: "Sabarmati Precision",
    city: "Ahmedabad, GJ",
    askingPrice: 3750000,
    year: "2018",
    photos: 5,
    documents: 2,
    status: "Rejected",
    submittedOn: "2026-07-18",
    note: "Serial plate does not match the invoice. Rejected pending clarification.",
  },
  {
    id: "REQ-5516",
    machine: "Haas ST-20Y",
    brand: "Haas Automation",
    category: "Lathes",
    seller: "Punjab Tooling Co.",
    city: "Ludhiana, PB",
    askingPrice: 4850000,
    year: "2021",
    photos: 12,
    documents: 5,
    status: "Approved",
    submittedOn: "2026-07-21",
    note: "Approved and published as MS-1009.",
  },
];

export type InquiryStatus =
  | "New"
  | "Broker Assigned"
  | "Quoted"
  | "Negotiating"
  | "Closed"
  | "Lost";

export interface Inquiry {
  id: string;
  machine: string;
  buyer: string;
  company: string;
  city: string;
  budget: number;
  quoted: number | null;
  status: InquiryStatus;
  broker: string | null;
  raisedOn: string;
  lastActivity: string;
}

export const INQUIRIES: Inquiry[] = [
  {
    id: "RFQ-4471",
    machine: "DMG MORI DMU 50",
    buyer: "Marcus V. Sterling",
    company: "Aerotech Solutions Inc.",
    city: "Pune, MH",
    budget: 15000000,
    quoted: 14500000,
    status: "Quoted",
    broker: "Kavita Desai",
    raisedOn: "2026-07-26",
    lastActivity: "2026-08-05",
  },
  {
    id: "RFQ-4472",
    machine: "Haas VF-2SS",
    buyer: "Farhan Qureshi",
    company: "Qureshi Auto Components",
    city: "Mumbai, MH",
    budget: 7500000,
    quoted: 7050000,
    status: "Negotiating",
    broker: "Kavita Desai",
    raisedOn: "2026-07-24",
    lastActivity: "2026-08-06",
  },
  {
    id: "RFQ-4473",
    machine: "Okuma GENOS M560-V",
    buyer: "Suresh Nair",
    company: "Kongu Engineering Works",
    city: "Coimbatore, TN",
    budget: 9500000,
    quoted: null,
    status: "Broker Assigned",
    broker: "Kavita Desai",
    raisedOn: "2026-08-02",
    lastActivity: "2026-08-04",
  },
  {
    id: "RFQ-4474",
    machine: "Sodick AG400L",
    buyer: "Nisha Verma",
    company: "Verma Toolroom",
    city: "Faridabad, HR",
    budget: 6000000,
    quoted: null,
    status: "New",
    broker: null,
    raisedOn: "2026-08-07",
    lastActivity: "2026-08-07",
  },
  {
    id: "RFQ-4475",
    machine: "Studer S33",
    buyer: "Vikram Shetty",
    company: "Precision Dynamics",
    city: "Bengaluru, KA",
    budget: 9000000,
    quoted: 8800000,
    status: "Quoted",
    broker: "Kavita Desai",
    raisedOn: "2026-07-19",
    lastActivity: "2026-08-03",
  },
  {
    id: "RFQ-4476",
    machine: "Doosan PUMA 2600SY",
    buyer: "Anitha Raman",
    company: "Southern Machine Tools",
    city: "Chennai, TN",
    budget: 5600000,
    quoted: 5500000,
    status: "Closed",
    broker: "Kavita Desai",
    raisedOn: "2026-06-11",
    lastActivity: "2026-07-02",
  },
  {
    id: "RFQ-4477",
    machine: "Mazak HCN-4000",
    buyer: "Imran Shaikh",
    company: "Shaikh Fabricators",
    city: "Nashik, MH",
    budget: 9000000,
    quoted: 10500000,
    status: "Lost",
    broker: "Kavita Desai",
    raisedOn: "2026-06-02",
    lastActivity: "2026-06-28",
  },
  {
    id: "RFQ-4478",
    machine: "Mitsubishi MV1200R",
    buyer: "Farhan Qureshi",
    company: "Qureshi Auto Components",
    city: "Mumbai, MH",
    budget: 6800000,
    quoted: null,
    status: "New",
    broker: null,
    raisedOn: "2026-08-06",
    lastActivity: "2026-08-06",
  },
];

export type OrderStage =
  | "Inquiry Received"
  | "Under Review"
  | "Price Confirmed"
  | "Machine Reserved"
  | "Delivery Scheduled"
  | "Delivered";

export interface Order {
  id: string;
  machine: string;
  buyer: string;
  seller: string;
  amount: number;
  stage: OrderStage;
  placedOn: string;
  destination: string;
}

export const ORDERS: Order[] = [
  {
    id: "ORD-88219",
    machine: "DMG MORI DMU 50",
    buyer: "Aerotech Solutions Inc.",
    seller: "Deccan Grinding Systems",
    amount: 15412500,
    stage: "Under Review",
    placedOn: "2026-08-02",
    destination: "Pune, MH",
  },
  {
    id: "ORD-90122",
    machine: "Haas VF-2SS",
    buyer: "Qureshi Auto Components",
    seller: "Fortune Gold Machine Tools",
    amount: 7548150,
    stage: "Price Confirmed",
    placedOn: "2026-07-28",
    destination: "Mumbai, MH",
  },
  {
    id: "ORD-71044",
    machine: "Doosan PUMA 2600SY",
    buyer: "Southern Machine Tools",
    seller: "Punjab Tooling Co.",
    amount: 5893700,
    stage: "Delivered",
    placedOn: "2026-06-12",
    destination: "Chennai, TN",
  },
  {
    id: "ORD-66310",
    machine: "Ghiringhelli M200 SP",
    buyer: "Verma Toolroom",
    seller: "Precision Dynamics",
    amount: 4398530,
    stage: "Machine Reserved",
    placedOn: "2026-07-15",
    destination: "Faridabad, HR",
  },
  {
    id: "ORD-66450",
    machine: "Okuma GENOS M560-V",
    buyer: "Kongu Engineering Works",
    seller: "Kongu Engineering Works",
    amount: 9862300,
    stage: "Delivery Scheduled",
    placedOn: "2026-07-09",
    destination: "Coimbatore, TN",
  },
];

/** Twelve-month GMV trend for the dashboard chart, in rupees. */
export const REVENUE_TREND = [
  { month: "Sep", value: 18200000 },
  { month: "Oct", value: 21500000 },
  { month: "Nov", value: 19800000 },
  { month: "Dec", value: 26400000 },
  { month: "Jan", value: 24100000 },
  { month: "Feb", value: 29700000 },
  { month: "Mar", value: 33200000 },
  { month: "Apr", value: 28900000 },
  { month: "May", value: 35600000 },
  { month: "Jun", value: 41200000 },
  { month: "Jul", value: 38700000 },
  { month: "Aug", value: 44300000 },
];

export interface ActivityEntry {
  id: string;
  actor: string;
  action: string;
  target: string;
  at: string;
  tone: "accent" | "navy" | "success" | "danger";
}

export const ACTIVITY: ActivityEntry[] = [
  {
    id: "A1",
    actor: "Meera Patel",
    action: "submitted a listing",
    target: "Okamoto ACC-1224DX",
    at: "2026-08-07",
    tone: "accent",
  },
  {
    id: "A2",
    actor: "Nisha Verma",
    action: "raised an inquiry on",
    target: "Sodick AG400L",
    at: "2026-08-07",
    tone: "navy",
  },
  {
    id: "A3",
    actor: "R. Deshmukh",
    action: "completed inspection for",
    target: "Hurco VMX42i",
    at: "2026-08-06",
    tone: "success",
  },
  {
    id: "A4",
    actor: "Farhan Qureshi",
    action: "countered the quote on",
    target: "Haas VF-2SS",
    at: "2026-08-06",
    tone: "navy",
  },
  {
    id: "A5",
    actor: "Admin",
    action: "rejected the submission",
    target: "Makino EDNC6",
    at: "2026-08-05",
    tone: "danger",
  },
  {
    id: "A6",
    actor: "Marcus V. Sterling",
    action: "placed order",
    target: "ORD-88219",
    at: "2026-08-02",
    tone: "success",
  },
];
