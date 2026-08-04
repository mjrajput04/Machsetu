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

  bool get isSold => state == ListingState.sold;

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

/// Mutable form state carried across the four wizard steps.
///
/// Every field is optional by design — sellers can submit a partial listing
/// and the sourcing desk fills the gaps during verification.
class MachineDraft {
  String category = '';
  String brand = '';
  String model = '';
  String year = '';
  String condition = 'Good';
  String workingHours = '';
  String price = '';
  String location = '';
  String serialNumber = '';
  String description = '';

  final List<String> images = [];
  final List<SellDocument> documents = [];

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
            category: 'Service History/AMC',
            uploadedOn: 'Uploaded Oct 12',
          ),
        ],
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
