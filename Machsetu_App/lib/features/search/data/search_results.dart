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
