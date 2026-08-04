import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Where a seller's machine sits in the listing pipeline.
enum ListingState {
  pendingReview('Pending Review', Icons.pending_outlined),
  live('Live', Icons.circle),
  underOffer('Under Offer', Icons.handshake_outlined),
  sold('Sold', Icons.check_circle_outline);

  const ListingState(this.label, this.icon);

  final String label;
  final IconData icon;

  Color get foreground => switch (this) {
    ListingState.pendingReview => AppColors.accentDark,
    ListingState.live => AppColors.success,
    ListingState.underOffer => AppColors.brandBlue,
    ListingState.sold => AppColors.textSecondary,
  };

  Color get background => switch (this) {
    ListingState.sold => AppColors.border.withValues(alpha: 0.8),
    _ => foreground.withValues(alpha: 0.14),
  };
}

class SellDocument {
  const SellDocument({
    required this.name,
    required this.size,
    required this.category,
    required this.uploadedOn,
  });

  final String name;
  final String size;
  final String category;
  final String uploadedOn;
}

/// One row of the section 7 inspection report.
class InspectionPoint {
  const InspectionPoint({
    required this.point,
    required this.rating,
    this.remark = '',
  });

  final String point;
  final String rating;
  final String remark;
}

/// Inspector-filled portion of the registration form.
class InspectionReport {
  const InspectionReport({
    required this.points,
    this.remarks = '',
    this.inspectorName = '',
    this.inspectedOn = '',
  });

  final List<InspectionPoint> points;
  final String remarks;
  final String inspectorName;
  final String inspectedOn;

  bool get isEmpty => points.isEmpty;
}

class ListingEvent {
  const ListingEvent({
    required this.title,
    required this.detail,
    required this.icon,
    this.done = false,
    this.current = false,
  });

  final String title;
  final String detail;
  final IconData icon;
  final bool done;
  final bool current;
}

class SellListing {
  const SellListing({
    required this.reference,
    required this.title,
    required this.brand,
    required this.model,
    required this.year,
    required this.category,
    required this.condition,
    required this.price,
    required this.location,
    required this.state,
    required this.submittedOn,
    this.subtitle = '',
    this.workingHours = '',
    this.serialNumber = '',
    this.description = '',
    this.images = const [],
    this.documents = const [],
    this.specs = const [],
    this.features = const [],
    this.views = 0,
    this.activeInquiries = 0,
    this.soldOn,
    this.icon = Icons.precision_manufacturing,
    this.seller = const SellerInfo(),
    this.machineType = '',
    this.installationYear = '',
    this.countryOfOrigin = '',
    this.controller = '',
    this.numberOfAxis = '',
    this.machineCapacity = '',
    this.powerRequirement = '',
    this.maxSpindleSpeed = '',
    this.weight = '',
    this.workingStatus = '',
    this.maintenanceStatus = '',
    this.lastServiceDate = '',
    this.accessoriesIncluded = '',
    this.commercial = const CommercialInfo(),
    this.specifications = const MachineSpecs(),
    this.requiredPhotos = const [],
    this.additionalRemarks = '',
    this.inspection = const InspectionReport(points: []),
  });

  final String reference;
  final String title;
  final String brand;
  final String model;
  final String year;
  final String category;
  final String condition;
  final String price;
  final String location;
  final ListingState state;
  final String submittedOn;
  final String subtitle;
  final String workingHours;
  final String serialNumber;
  final String description;
  final List<String> images;
  final List<SellDocument> documents;
  final List<(String, String)> specs;
  final List<String> features;
  final int views;
  final int activeInquiries;
  final String? soldOn;
  final IconData icon;

  // ---- Registration-form sections carried through from the seller wizard ---
  final SellerInfo seller;
  final String machineType;
  final String installationYear;
  final String countryOfOrigin;
  final String controller;
  final String numberOfAxis;
  final String machineCapacity;
  final String powerRequirement;
  final String maxSpindleSpeed;
  final String weight;
  final String workingStatus;
  final String maintenanceStatus;
  final String lastServiceDate;
  final String accessoriesIncluded;
  final CommercialInfo commercial;
  final MachineSpecs specifications;
  final List<String> requiredPhotos;
  final String additionalRemarks;
  final InspectionReport inspection;

  bool get isSold => state == ListingState.sold;

  /// Section 2 rows that actually carry a value.
  List<(String, String)> get machineDetailRows => _nonEmpty([
    ('Machine Type', machineType),
    ('Controller', controller),
    ('No. of Axis', numberOfAxis),
    ('Machine Capacity / Size', machineCapacity),
    ('Maximum Spindle Speed', maxSpindleSpeed),
    ('Power Requirement', powerRequirement),
    ('Weight of Machine', weight),
    ('Installation Year', installationYear),
    ('Country of Origin', countryOfOrigin),
    ('Working Status', workingStatus),
    ('Maintenance Status', maintenanceStatus),
    ('Last Service Date', lastServiceDate),
    ('Serial Number', serialNumber),
    ('Accessories Included', accessoriesIncluded),
  ]);

  /// Section 4 rows that actually carry a value.
  List<(String, String)> get specificationRows =>
      _nonEmpty(specifications.rows);

  /// Section 3 rows.
  List<(String, String)> get commercialRows => _nonEmpty(commercial.rows);

  static List<(String, String)> _nonEmpty(List<(String, String)> rows) =>
      rows.where((r) => r.$2.trim().isNotEmpty).toList();

  /// Progress trail shown on the listing detail page.
  List<ListingEvent> get timeline {
    final reviewed = state != ListingState.pendingReview;
    final isLive = state == ListingState.live ||
        state == ListingState.underOffer ||
        state == ListingState.sold;

    return [
      ListingEvent(
        title: 'Listing Submitted',
        detail: submittedOn,
        icon: Icons.check,
        done: true,
      ),
      ListingEvent(
        title: 'Broker Review Completed',
        detail: reviewed ? 'Verified by the sourcing desk' : 'In progress',
        icon: Icons.check,
        done: reviewed,
        current: !reviewed,
      ),
      ListingEvent(
        title: 'Live on Marketplace',
        detail: isLive
            ? 'Since $submittedOn • $activeInquiries active inquiries'
            : 'Publishes after review',
        icon: Icons.visibility_outlined,
        done: state == ListingState.underOffer || state == ListingState.sold,
        current: state == ListingState.live,
      ),
      ListingEvent(
        title: isSold ? 'Sold' : 'Under Offer',
        detail: isSold
            ? 'Completed on ${soldOn ?? submittedOn}'
            : 'Pending buyer engagement',
        icon: isSold ? Icons.verified_outlined : Icons.handshake_outlined,
        done: isSold,
        current: state == ListingState.underOffer,
      ),
    ];
  }
}

/// Section 1 — seller and company identity.
class SellerInfo {
  const SellerInfo({
    this.name = '',
    this.company = '',
    this.mobile = '',
    this.whatsapp = '',
    this.email = '',
    this.gstNumber = '',
    this.panNumber = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
  });

  final String name;
  final String company;
  final String mobile;
  final String whatsapp;
  final String email;
  final String gstNumber;
  final String panNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;

  List<(String, String)> get rows => [
    ('Contact Person', name),
    ('Company Name', company),
    ('Mobile Number', mobile),
    ('WhatsApp Number', whatsapp),
    ('Email ID', email),
    ('GST Number', gstNumber),
    ('PAN Number', panNumber),
    ('Address', address),
    ('City', city),
    ('State', state),
    ('Pincode', pincode),
  ];
}

/// Section 3 — commercial terms.
class CommercialInfo {
  const CommercialInfo({
    this.negotiable,
    this.gstAvailable,
    this.taxInvoiceAvailable,
    this.financePending,
    this.deliveryAvailable,
    this.loadingAvailable,
    this.ownerType = '',
  });

  /// null means the seller left the Yes/No pair blank.
  final bool? negotiable;
  final bool? gstAvailable;
  final bool? taxInvoiceAvailable;
  final bool? financePending;
  final bool? deliveryAvailable;
  final bool? loadingAvailable;
  final String ownerType;

  static String _yn(bool? value) => value == null
      ? ''
      : value
      ? 'Yes'
      : 'No';

  List<(String, String)> get rows => [
    ('Negotiable', _yn(negotiable)),
    ('GST Available', _yn(gstAvailable)),
    ('Tax Invoice Available', _yn(taxInvoiceAvailable)),
    ('Finance / Loan Pending', _yn(financePending)),
    ('Owner Type', ownerType),
    ('Delivery Available', _yn(deliveryAvailable)),
    ('Loading Available', _yn(loadingAvailable)),
  ];
}

/// Section 4 — machine specifications.
class MachineSpecs {
  const MachineSpecs({
    this.tableSize = '',
    this.lubricationSystem = '',
    this.electricalPanelCondition = '',
    this.toolMagazineCapacity = '',
    this.servoMotors = '',
    this.toolChangerType = '',
    this.ballScrewCondition = '',
    this.coolantSystem = '',
    this.guideways = '',
    this.hydraulicSystem = '',
    this.otherSpecifications = '',
  });

  final String tableSize;
  final String lubricationSystem;
  final String electricalPanelCondition;
  final String toolMagazineCapacity;
  final String servoMotors;
  final String toolChangerType;
  final String ballScrewCondition;
  final String coolantSystem;
  final String guideways;
  final String hydraulicSystem;
  final String otherSpecifications;

  List<(String, String)> get rows => [
    ('Table Size', tableSize),
    ('Lubrication System', lubricationSystem),
    ('Electrical Panel Condition', electricalPanelCondition),
    ('Tool Magazine Capacity', toolMagazineCapacity),
    ('Servo Motors', servoMotors),
    ('Tool Changer Type', toolChangerType),
    ('Ball Screw Condition', ballScrewCondition),
    ('Coolant System', coolantSystem),
    ('Guideways', guideways),
    ('Hydraulic System', hydraulicSystem),
    ('Other Specifications', otherSpecifications),
  ];
}

/// Mutable form state carried across the four wizard steps.
///
/// Every field is optional by design — sellers can submit a partial listing
/// and the sourcing desk fills the gaps during verification.
class MachineDraft {
  // Section 1 — seller information.
  String sellerName = '';
  String companyName = '';
  String mobile = '';
  String whatsapp = '';
  String email = '';
  String gstNumber = '';
  String panNumber = '';
  String address = '';
  String city = '';
  String state = '';
  String pincode = '';

  // Section 2 — machine details.
  final Set<String> categories = {};
  String categoryOther = '';
  String machineType = '';
  String brand = '';
  String model = '';
  String year = '';
  String installationYear = '';
  String countryOfOrigin = '';
  String controller = '';
  String numberOfAxis = '';
  String machineCapacity = '';
  String powerRequirement = '';
  String maxSpindleSpeed = '';
  String weight = '';
  String location = '';
  String workingHours = '';
  String workingStatus = '';
  String condition = 'Good';
  String maintenanceStatus = '';
  String lastServiceDate = '';
  String accessoriesIncluded = '';
  String serialNumber = '';
  String description = '';

  // Section 3 — commercial information.
  String price = '';
  bool? negotiable;
  bool? gstAvailable;
  bool? taxInvoiceAvailable;
  bool? financePending;
  bool? deliveryAvailable;
  bool? loadingAvailable;
  String ownerType = '';
  String additionalRemarks = '';

  // Section 4 — machine specifications.
  String tableSize = '';
  String lubricationSystem = '';
  String electricalPanelCondition = '';
  String toolMagazineCapacity = '';
  String servoMotors = '';
  String toolChangerType = '';
  String ballScrewCondition = '';
  String coolantSystem = '';
  String guideways = '';
  String hydraulicSystem = '';
  String otherSpecifications = '';

  // Sections 5 & 6 — attachments.
  final List<String> images = [];
  final List<SellDocument> documents = [];
  final Set<String> requiredPhotos = {};

  /// Ticked categories, with the free-text "Other" value folded in.
  String get category {
    final picked = categories.where((c) => c != 'Other').toList();
    if (categories.contains('Other') && categoryOther.trim().isNotEmpty) {
      picked.add(categoryOther.trim());
    }
    return picked.join(' • ');
  }

  SellerInfo get sellerInfo => SellerInfo(
    name: sellerName,
    company: companyName,
    mobile: mobile,
    whatsapp: whatsapp,
    email: email,
    gstNumber: gstNumber,
    panNumber: panNumber,
    address: address,
    city: city,
    state: state,
    pincode: pincode,
  );

  CommercialInfo get commercialInfo => CommercialInfo(
    negotiable: negotiable,
    gstAvailable: gstAvailable,
    taxInvoiceAvailable: taxInvoiceAvailable,
    financePending: financePending,
    deliveryAvailable: deliveryAvailable,
    loadingAvailable: loadingAvailable,
    ownerType: ownerType,
  );

  MachineSpecs get machineSpecs => MachineSpecs(
    tableSize: tableSize,
    lubricationSystem: lubricationSystem,
    electricalPanelCondition: electricalPanelCondition,
    toolMagazineCapacity: toolMagazineCapacity,
    servoMotors: servoMotors,
    toolChangerType: toolChangerType,
    ballScrewCondition: ballScrewCondition,
    coolantSystem: coolantSystem,
    guideways: guideways,
    hydraulicSystem: hydraulicSystem,
    otherSpecifications: otherSpecifications,
  );

  String get displayTitle {
    final parts = [brand, model].where((p) => p.trim().isNotEmpty);
    return parts.isEmpty ? 'Untitled machine' : parts.join(' ');
  }

  String get displayPrice {
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 'Price on request';
    return '₹${_group(digits)}';
  }

  static String _group(String digits) {
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '${groups.join(',')},$last3';
  }
}

/// In-memory seller inventory. Replace with the listings API when it exists.
class SellStore extends ChangeNotifier {
  SellStore._();

  static final SellStore instance = SellStore._();

  static const String _photos = 'assets/images/machines';

  final List<SellListing> _listings = [];

  List<SellListing> get listings => List.unmodifiable(_listings);

  bool get isEmpty => _listings.isEmpty;

  List<SellListing> byState(ListingState? state) {
    if (state == null) return listings;
    return _listings.where((l) => l.state == state).toList();
  }

  List<SellListing> search(String query, {ListingState? state}) {
    final pool = byState(state);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return pool;
    return pool
        .where(
          (l) =>
              l.title.toLowerCase().contains(q) ||
              l.brand.toLowerCase().contains(q) ||
              l.category.toLowerCase().contains(q) ||
              l.location.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Turns a completed wizard draft into a pending-review listing.
  SellListing submit(MachineDraft draft) {
    final reference = 'SN-${_listings.length + 9827346}A';

    final listing = SellListing(
      reference: reference,
      title: draft.displayTitle,
      subtitle: draft.category.isEmpty ? 'Industrial machine' : draft.category,
      brand: draft.brand.isEmpty ? 'Not specified' : draft.brand,
      model: draft.model.isEmpty ? 'Not specified' : draft.model,
      year: draft.year.isEmpty ? '—' : draft.year,
      category: draft.category.isEmpty ? 'Uncategorised' : draft.category,
      condition: draft.condition,
      price: draft.displayPrice,
      location: draft.location.isEmpty ? 'Not specified' : draft.location,
      state: ListingState.pendingReview,
      submittedOn: 'Just now',
      workingHours: draft.workingHours,
      serialNumber: draft.serialNumber,
      description: draft.description,
      images: List.of(draft.images),
      documents: List.of(draft.documents),
      specs: const [],
      features: const [],
      seller: draft.sellerInfo,
      machineType: draft.machineType,
      installationYear: draft.installationYear,
      countryOfOrigin: draft.countryOfOrigin,
      controller: draft.controller,
      numberOfAxis: draft.numberOfAxis,
      machineCapacity: draft.machineCapacity,
      powerRequirement: draft.powerRequirement,
      maxSpindleSpeed: draft.maxSpindleSpeed,
      weight: draft.weight,
      workingStatus: draft.workingStatus,
      maintenanceStatus: draft.maintenanceStatus,
      lastServiceDate: draft.lastServiceDate,
      accessoriesIncluded: draft.accessoriesIncluded,
      commercial: draft.commercialInfo,
      specifications: draft.machineSpecs,
      requiredPhotos: draft.requiredPhotos.toList(),
      additionalRemarks: draft.additionalRemarks,
    );

    _listings.insert(0, listing);
    notifyListeners();
    return listing;
  }

  void clear() {
    _listings.clear();
    notifyListeners();
  }

  /// Sample inventory so My Listings has content before the API exists.
  /// Called once from `main()`; drop that call to start empty.
  void seedDemoListings() {
    if (_listings.isNotEmpty) return;

    _listings.addAll([
      SellListing(
        reference: 'SN-9827346A',
        title: 'Haas VF-2SS',
        subtitle: 'Super-Speed Vertical Machining Center',
        brand: 'Haas Automation',
        model: 'VF-2SS',
        year: '2021',
        category: 'VMC',
        condition: 'Excellent',
        price: '₹70,50,000',
        location: 'Pune, MH',
        state: ListingState.live,
        submittedOn: 'Oct 12, 2026',
        workingHours: '4,200',
        serialNumber: 'SN-9827346A',
        description: 'Excellent working condition. Spindle replaced in 2024. '
            'Regular maintenance logged. Minor cosmetic scratches on the '
            'front door panel.',
        images: const [
          '$_photos/haas_vf2ss.jpg',
          '$_photos/dmg_cmx_1100v.jpg',
          '$_photos/workshop_banner.jpg',
        ],
        views: 124,
        activeInquiries: 3,
        specs: const [
          ('X-Axis Travel', '30.0"'),
          ('Y-Axis Travel', '16.0"'),
          ('Z-Axis Travel', '20.0"'),
          ('Spindle Speed', '12,000 RPM'),
          ('Spindle Taper', 'CT 40'),
          ('Tool Changer Capacity', '30+1 Side Mount'),
        ],
        features: const [
          'Through Spindle Coolant',
          'Programmable Coolant',
          'Rigid Tapping',
        ],
        documents: const [
          SellDocument(
            name: 'Original Invoice.pdf',
            size: '1.2 MB',
            category: 'Original Invoice',
            uploadedOn: 'Uploaded Oct 12',
          ),
          SellDocument(
            name: 'Service History Log.pdf',
            size: '3.4 MB',
            category: 'Service History',
            uploadedOn: 'Uploaded Oct 12',
          ),
        ],
        seller: const SellerInfo(
          name: 'Pappu Singh',
          company: 'Fortune Gold Machine Tools',
          mobile: '84015 03169',
          whatsapp: '84015 03169',
          email: 'sales@fortunegold.in',
          gstNumber: '24AAACF1234K1ZV',
          panNumber: 'AAACF1234K',
          address: 'Fortune Gold, Metoda, Lodhika',
          city: 'Rajkot',
          state: 'Gujarat',
          pincode: '360021',
        ),
        machineType: 'Vertical Machining Center',
        installationYear: '2021',
        countryOfOrigin: 'USA',
        controller: 'Haas Next Gen Control',
        numberOfAxis: '3 Axis',
        machineCapacity: '760 x 406 x 508 mm',
        powerRequirement: '3-Phase 415V, 22.4 kVA',
        maxSpindleSpeed: '12,000 RPM',
        weight: '3,175 kg',
        workingStatus: 'Running',
        maintenanceStatus: 'Regular',
        lastServiceDate: '18 Aug 2026',
        accessoriesIncluded: 'Tool holders (20), coolant pump, chip auger, '
            'operator manual, levelling pads',
        additionalRemarks: 'Machine is under power and can be demonstrated '
            'under load at the seller site.',
        commercial: const CommercialInfo(
          negotiable: true,
          gstAvailable: true,
          taxInvoiceAvailable: true,
          financePending: false,
          deliveryAvailable: true,
          loadingAvailable: true,
          ownerType: '1st Owner',
        ),
        specifications: const MachineSpecs(
          tableSize: '914 x 356 mm',
          lubricationSystem: 'Automatic centralised',
          electricalPanelCondition: 'Excellent',
          toolMagazineCapacity: '30+1 Side Mount',
          servoMotors: 'Yaskawa AC servo — healthy',
          toolChangerType: 'Side mount ATC',
          ballScrewCondition: 'Excellent, no backlash',
          coolantSystem: 'Through spindle + flood',
          guideways: 'Linear guideways',
          hydraulicSystem: 'Not applicable',
          otherSpecifications: 'Rigid tapping, programmable coolant',
        ),
        requiredPhotos: const [
          'Front View',
          'Back View',
          'Controller Panel',
          'Name Plate',
          'Chuck / Spindle',
          'Working Condition',
        ],
        inspection: const InspectionReport(
          inspectorName: 'R. Deshmukh',
          inspectedOn: '13 Oct 2026',
          remarks: 'Machine holds tolerance within spec. Minor cosmetic wear '
              'on the front door. Recommended for listing without reservation.',
          points: [
            InspectionPoint(point: 'Machine Accuracy', rating: 'Excellent'),
            InspectionPoint(point: 'Spindle Condition', rating: 'Excellent'),
            InspectionPoint(
              point: 'Axis Movement (X/Y/Z)',
              rating: 'Excellent',
            ),
            InspectionPoint(point: 'Ball Screw Condition', rating: 'Good'),
            InspectionPoint(point: 'Tool Changer Condition', rating: 'Good'),
            InspectionPoint(point: 'Coolant System', rating: 'Good'),
            InspectionPoint(
              point: 'Hydraulic System',
              rating: 'Not Applicable',
            ),
            InspectionPoint(point: 'Electrical Panel', rating: 'Excellent'),
            InspectionPoint(
              point: 'Leakage',
              rating: 'Good',
              remark: 'No active leaks observed',
            ),
            InspectionPoint(point: 'Noise', rating: 'Good'),
            InspectionPoint(point: 'Vibration', rating: 'Excellent'),
            InspectionPoint(point: 'Overall Condition', rating: 'Excellent'),
          ],
        ),
      ),
      SellListing(
        reference: 'SN-7741220B',
        title: 'Mazak Integrex i-200ST',
        subtitle: 'Multi-Tasking Turning Center',
        brand: 'Yamazaki Mazak',
        model: 'Integrex i-200ST',
        year: '2019',
        category: 'Multi-Tasking',
        condition: 'Good',
        price: '₹1,45,00,000',
        location: 'Bengaluru, KA',
        state: ListingState.pendingReview,
        submittedOn: 'Submitted 2 hrs ago',
        workingHours: '11,800',
        serialNumber: 'SN-7741220B',
        description: 'Twin-spindle multi-tasking centre with milling turret. '
            'Under AMC until 2027.',
        images: const ['$_photos/okuma_genos.jpg'],
        views: 0,
        specs: const [
          ('Max Turning Diameter', '658 mm'),
          ('Spindle Speed', '5,000 RPM'),
          ('Tool Capacity', '36 Tools'),
        ],
        features: const ['Y-Axis', 'Sub Spindle', 'Bar Feeder Ready'],
      ),
      SellListing(
        reference: 'SN-5510983C',
        title: 'Doosan Puma 2600SY',
        subtitle: 'CNC Turning Center',
        brand: 'Doosan Machine Tools',
        model: 'Puma 2600SY',
        year: '2018',
        category: 'Lathes',
        condition: 'Good',
        price: '₹55,00,000',
        location: 'Chennai, TN',
        state: ListingState.sold,
        submittedOn: 'Aug 02, 2026',
        soldOn: '12 Oct 2026',
        workingHours: '15,400',
        serialNumber: 'SN-5510983C',
        description: 'Sold to a verified buyer through MachSetu escrow.',
        images: const ['$_photos/doosan_lynx.jpg'],
        views: 318,
        specs: const [
          ('Chuck Size', '10"'),
          ('Max Turning Length', '640 mm'),
        ],
        features: const ['Y-Axis', 'Sub Spindle'],
      ),
    ]);
    notifyListeners();
  }
}
