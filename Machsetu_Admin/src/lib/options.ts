/**
 * Option lists mirrored 1:1 from the Flutter app's `sell_options.dart`, so a
 * machine registered in either place carries identical vocabulary.
 */

/** Section 2 — machine category (multi-select). */
export const CATEGORY_OPTIONS = [
  "CNC",
  "VMC",
  "Lathe",
  "Sliding Head",
  "HMC",
  "Drilling",
  "Milling",
  "Grinding",
  "Press",
  "EDM",
  "Multi-Tasking",
  "Other",
] as const;

/** Top-level buckets used for catalogue filtering. */
export const CATEGORIES = [
  "CNC Machines",
  "VMC Centers",
  "Lathes",
  "Grinders",
  "EDM",
] as const;

export type Category = (typeof CATEGORIES)[number];

export const WORKING_STATUS = [
  "Running",
  "Idle",
  "Under Repair",
  "Not Working",
] as const;

export const CONDITIONS = [
  "Excellent",
  "Good",
  "Average",
  "Like New",
  "Fair",
  "Needs Repair",
] as const;

export const MAINTENANCE_STATUS = [
  "Regular",
  "Irregular",
  "Not Maintained",
] as const;

export const OWNER_TYPES = ["1st Owner", "Dealer", "Reseller"] as const;

/** Section 5 — documents checklist, doubles as the upload categories. */
export const DOCUMENT_TYPES = [
  "GST Certificate",
  "Ownership Proof",
  "Purchase Invoice",
  "AMC Details",
  "Original Invoice",
  "Maintenance Records",
  "Machine Manual",
  "Warranty (If Any)",
  "Service History",
  "Other Documents",
] as const;

/** Section 6 — required photos checklist. */
export const REQUIRED_PHOTOS = [
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
  "Servo Motors",
  "Coolant System",
  "Working Condition",
  "Machine Running Video",
  "Other Photos",
] as const;

/** Section 7 — inspection report points. */
export const INSPECTION_POINTS = [
  "Machine Accuracy",
  "Spindle Condition",
  "Axis Movement (X/Y/Z)",
  "Ball Screw Condition",
  "Tool Changer Condition",
  "Coolant System",
  "Hydraulic System",
  "Electrical Panel",
  "Leakage",
  "Noise",
  "Vibration",
  "Overall Condition",
] as const;

export const INSPECTION_RATINGS = [
  "Excellent",
  "Good",
  "Average",
  "Poor",
  "Not Applicable",
] as const;

export type InspectionRating = (typeof INSPECTION_RATINGS)[number];
