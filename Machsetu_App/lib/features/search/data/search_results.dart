import 'package:flutter/material.dart';

/// Visual weight of a badge pinned over a result photo.
enum BadgeTone {
  /// Orange — attention-grabbing ("New Listing").
  accent,

  /// Navy — informational emphasis ("Best Value").
  navy,

  /// White chip with navy text ("Certified").
  light,
}

class ResultBadge {
  const ResultBadge(this.label, this.tone);

  final String label;
  final BadgeTone tone;
}

class ResultSpec {
  const ResultSpec(this.label, this.value);

  final String label;
  final String value;
}

class SearchListing {
  const SearchListing({
    required this.title,
    required this.subtitle,
    required this.brand,
    required this.price,
    required this.specs,
    this.image,
    this.badges = const [],
    this.icon = Icons.precision_manufacturing,
  });

  final String title;
  final String subtitle;
  final String brand;

  /// Asking price, pre-formatted in the Indian lakh/crore grouping.
  final String price;
  final List<ResultSpec> specs;
  final String? image;
  final List<ResultBadge> badges;
  final IconData icon;
}

/// Static result set used until the listings/search API is connected.
class SearchData {
  SearchData._();

  static const String _photos = 'assets/images/machines';

  static const String defaultQuery = 'Vertical Machining Center';

  static const List<String> recentSearches = [
    '5-axis CNC Haas',
    'Mazak Lathe 2022',
    'Industrial Laser Cutter',
  ];

  static const List<SearchListing> results = [
    SearchListing(
      title: 'DMG Mori CMX 1100 V',
      subtitle: 'Vertical Machining Center • 2023',
      brand: 'DMG MORI',
      price: '₹1,15,00,000',
      image: '$_photos/dmg_cmx_1100v.jpg',
      icon: Icons.precision_manufacturing,
      badges: [
        ResultBadge('New Listing', BadgeTone.accent),
        ResultBadge('Certified', BadgeTone.light),
      ],
      specs: [
        ResultSpec('TRAVEL X/Y/Z', '1100/560/510mm'),
        ResultSpec('SPINDLE', '12,000 RPM'),
        ResultSpec('LOCATION', 'Pune, MH'),
      ],
    ),
    SearchListing(
      title: 'Haas VF-2SS',
      subtitle: 'Super-Speed VMC • 2021',
      brand: 'HAAS AUTOMATION',
      price: '₹70,50,000',
      image: '$_photos/haas_vf2ss.jpg',
      icon: Icons.settings_suggest_outlined,
      badges: [ResultBadge('Best Value', BadgeTone.navy)],
      specs: [
        ResultSpec('TRAVEL X/Y/Z', '30" x 16" x 20"'),
        ResultSpec('SPINDLE', '15,000 RPM'),
        ResultSpec('LOCATION', 'Bengaluru, KA'),
      ],
    ),
    SearchListing(
      title: 'Mazak VCN-530C',
      subtitle: 'SmoothG Control • 2019',
      brand: 'YAMAZAKI MAZAK',
      price: '₹93,00,000',
      image: '$_photos/okuma_genos.jpg',
      icon: Icons.build_circle_outlined,
      specs: [
        ResultSpec('TABLE SIZE', '1300 x 550mm'),
        ResultSpec('ATC', '30 Tools'),
        ResultSpec('LOCATION', 'Chennai, TN'),
      ],
    ),
  ];

  static const int totalResults = 142;
}
