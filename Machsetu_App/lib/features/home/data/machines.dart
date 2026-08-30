import 'package:flutter/material.dart';

class MachineSpec {
  const MachineSpec({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// One file the seller attached to a listing.
class MachineDocument {
  const MachineDocument({
    required this.title,
    required this.meta,
    required this.url,
  });

  final String title;

  /// "PDF • 1.4 MB • Purchase Invoice", as the card prints it.
  final String meta;
  final String url;

  bool get isPdf => url.toLowerCase().endsWith('.pdf');
}

class Machine {
  const Machine({
    required this.title,
    this.id = '',
    this.documents = const [],
    required this.brand,
    required this.subtitle,
    required this.category,
    required this.year,
    required this.price,
    required this.location,
    required this.condition,
    required this.hours,
    required this.origin,
    required this.badge,
    required this.note,
    required this.ctaLabel,
    required this.specs,
    required this.images,
    required this.machineDetails,
    required this.specifications,
    required this.overview,
    required this.features,
    this.icon = Icons.precision_manufacturing,
  });

  /// Catalogue id, e.g. `MS-1001`. Empty for the bundled demo entries.
  final String id;

  /// Invoices, manuals and certificates the seller uploaded.
  final List<MachineDocument> documents;

  final String title;

  /// Manufacturer, e.g. "DMG MORI".
  final String brand;

  /// Machine type, e.g. "5-Axis Universal Machining Center".
  final String subtitle;

  /// One of [MachineData.categories], excluding "All".
  final String category;
  final String year;

  /// Asking price, pre-formatted in the Indian lakh/crore grouping.
  final String price;
  final String location;
  final String condition;

  /// Spindle hours on the clock.
  final String hours;

  /// Country of manufacture.
  final String origin;

  /// Corner ribbon on the featured card.
  final String badge;

  /// Small qualifier under the price — "EXCL. SHIPPING", …
  final String note;
  final String ctaLabel;

  /// Three headline figures shown on the featured card strip.
  final List<MachineSpec> specs;

  /// Photos — the first is the card thumbnail and the detail-page hero.
  final List<String> images;

  /// Registration-form section 2 rows for the detail page.
  final List<(String, String)> machineDetails;

  /// Registration-form section 4 rows for the detail page.
  final List<(String, String)> specifications;

  /// Prose paragraphs for the Overview block.
  final List<String> overview;

  /// Capability chips.
  final List<String> features;
  final IconData icon;

  String? get image => images.isEmpty ? null : images.first;
}

/// Static catalogue used until the listings API is connected.
///
/// Specifications are representative of each model as published by the
/// manufacturer; verify against the machine's own plate before quoting.
/// Labels and chips the catalogue UI needs.
///
/// The machines themselves come from the API — this class deliberately holds
/// no listings, so nothing in the app can render a machine that is not
/// actually for sale. Demo machines live in `test/fixtures/` for the tests.
class MachineData {
  MachineData._();

  /// "All" is a filter, not a category a machine can belong to.
  static const String allCategory = 'All';

  /// Fallback chip row, used only until the panel's category list lands.
  static const List<(IconData, String)> categories = [
    (Icons.grid_view_rounded, allCategory),
  ];
}
