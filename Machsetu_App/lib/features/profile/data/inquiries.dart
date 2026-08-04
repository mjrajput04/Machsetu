import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Lifecycle of a request for quotation.
enum InquiryStatus {
  awaitingQuote('Awaiting Quote'),
  quoted('Quote Received'),
  negotiating('Negotiating'),
  closed('Closed'),
  expired('Expired');

  const InquiryStatus(this.label);

  final String label;

  Color get foreground => switch (this) {
    InquiryStatus.awaitingQuote => AppColors.accentDark,
    InquiryStatus.quoted => AppColors.success,
    InquiryStatus.negotiating => AppColors.brandBlue,
    InquiryStatus.closed => AppColors.textSecondary,
    InquiryStatus.expired => AppColors.danger,
  };

  Color get background => switch (this) {
    InquiryStatus.closed => AppColors.border.withValues(alpha: 0.7),
    _ => foreground.withValues(alpha: 0.13),
  };
}

class Inquiry {
  const Inquiry({
    required this.reference,
    required this.machine,
    required this.brand,
    required this.submittedOn,
    required this.status,
    required this.specs,
    this.quotedPrice,
    this.responseNote,
    this.image,
    this.icon = Icons.precision_manufacturing,
  });

  final String reference;
  final String machine;
  final String brand;
  final String submittedOn;
  final InquiryStatus status;

  /// Technical requirements submitted with the RFQ.
  final List<String> specs;

  /// Present once the vendor has responded.
  final String? quotedPrice;
  final String? responseNote;
  final String? image;
  final IconData icon;

  bool get isOpen =>
      status != InquiryStatus.closed && status != InquiryStatus.expired;
}

/// Static RFQ list until the inquiries API is connected.
class InquiryData {
  InquiryData._();

  static const String _photos = 'assets/images/machines';

  static const List<Inquiry> all = [
    Inquiry(
      reference: 'RFQ-4471',
      machine: '5-Axis Vertical Machining Center',
      brand: 'DMG MORI',
      submittedOn: 'Oct 26, 2026',
      status: InquiryStatus.quoted,
      quotedPrice: '₹1,12,50,000',
      responseNote: 'Vendor confirmed availability. Quote valid for 14 days.',
      specs: ['Travel 1100mm', '12,000 RPM', 'Fanuc 31i-B', 'Qty 1'],
      image: '$_photos/dmg_cmx_1100v.jpg',
      icon: Icons.precision_manufacturing,
    ),
    Inquiry(
      reference: 'RFQ-4468',
      machine: 'High-Speed Spindle Assembly',
      brand: 'BXG Components',
      submittedOn: 'Oct 24, 2026',
      status: InquiryStatus.awaitingQuote,
      responseNote: 'Technical sourcing team is verifying compatibility.',
      specs: ['BT-40 taper', '15,000 RPM', 'Qty 4'],
      icon: Icons.settings_suggest_outlined,
    ),
    Inquiry(
      reference: 'RFQ-4455',
      machine: 'Haas VF-2SS Super-Speed VMC',
      brand: 'Haas Automation',
      submittedOn: 'Oct 18, 2026',
      status: InquiryStatus.negotiating,
      quotedPrice: '₹70,50,000',
      responseNote: 'Counter-offer sent. Awaiting vendor confirmation.',
      specs: ['30" x 16" x 20"', '15,000 RPM', 'Qty 1'],
      image: '$_photos/haas_vf2ss.jpg',
      icon: Icons.speed_outlined,
    ),
    Inquiry(
      reference: 'RFQ-4402',
      machine: 'CNC Turning Center',
      brand: 'Yamazaki Mazak',
      submittedOn: 'Sep 30, 2026',
      status: InquiryStatus.closed,
      quotedPrice: '₹46,00,000',
      responseNote: 'Converted to order ORD-71044.',
      specs: ['Chuck 8"', 'Bar feed', 'Qty 2'],
      image: '$_photos/mazak_quick_turn.jpg',
      icon: Icons.rotate_right,
    ),
    Inquiry(
      reference: 'RFQ-4390',
      machine: 'Industrial Laser Cutter',
      brand: 'Trumpf',
      submittedOn: 'Sep 12, 2026',
      status: InquiryStatus.expired,
      responseNote: 'No vendor response within the 21-day window.',
      specs: ['6kW fiber', '3000 x 1500mm bed', 'Qty 1'],
      icon: Icons.flare_outlined,
    ),
  ];

  static List<Inquiry> get open => all.where((i) => i.isOpen).toList();

  static List<Inquiry> get closed => all.where((i) => !i.isOpen).toList();
}
