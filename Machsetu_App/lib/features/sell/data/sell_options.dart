/// Option lists for the machine registration form.
///
/// Mirrors the printed MachSetu second-hand machine registration sheet so the
/// app and the paper form stay in step.
class SellOptions {
  SellOptions._();

  /// Section 2 — Machine Category (multi-select).
  static const List<String> categories = [
    'CNC',
    'VMC',
    'Lathe',
    'Sliding Head',
    'HMC',
    'Drilling',
    'Milling',
    'Grinding',
    'Press',
    'EDM',
    'Multi-Tasking',
    'Other',
  ];

  /// Section 2 — Working Status.
  static const List<String> workingStatus = [
    'Running',
    'Idle',
    'Under Repair',
    'Not Working',
  ];

  /// Section 2 — Machine Condition.
  static const List<String> conditions = [
    'Excellent',
    'Good',
    'Average',
    'Like New',
    'Fair',
    'Needs Repair',
  ];

  /// Section 2 — Maintenance Status.
  static const List<String> maintenanceStatus = [
    'Regular',
    'Irregular',
    'Not Maintained',
  ];

  /// Section 3 — Owner Type.
  static const List<String> ownerTypes = [
    '1st Owner',
    'Dealer',
    'Reseller',
  ];

  /// Section 5 — Documents Checklist. Doubles as the upload categories, so a
  /// ticked box always means a file is actually attached.
  static const List<String> documentTypes = [
    'GST Certificate',
    'Ownership Proof',
    'Purchase Invoice',
    'AMC Details',
    'Original Invoice',
    'Maintenance Records',
    'Machine Manual',
    'Warranty (If Any)',
    'Service History',
    'Other Documents',
  ];

  /// Section 6 — Required Photos checklist.
  static const List<String> requiredPhotos = [
    'Front View',
    'Back View',
    'Left Side View',
    'Right Side View',
    'Controller Panel',
    'Electrical Panel',
    'Name Plate',
    'Tool Magazine',
    'Chuck / Spindle',
    'Hydraulic Unit',
    'Servo Motors',
    'Coolant System',
    'Working Condition',
    'Machine Running Video',
    'Other Photos',
  ];

  /// Section 7 — Inspection Report points.
  static const List<String> inspectionPoints = [
    'Machine Accuracy',
    'Spindle Condition',
    'Axis Movement (X/Y/Z)',
    'Ball Screw Condition',
    'Tool Changer Condition',
    'Coolant System',
    'Hydraulic System',
    'Electrical Panel',
    'Leakage',
    'Noise',
    'Vibration',
    'Overall Condition',
  ];

  /// Section 7 — Inspection ratings.
  static const List<String> inspectionRatings = [
    'Excellent',
    'Good',
    'Average',
    'Poor',
    'Not Applicable',
  ];
}
