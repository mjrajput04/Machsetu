import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Condition grade shown as a coloured badge over the listing photo.
enum Condition {
  excellent('Excellent Condition', AppColors.accent),
  likeNew('Like New', AppColors.brandBlue),
  good('Good Condition', AppColors.success);

  const Condition(this.label, this.color);

  final String label;
  final Color color;
}

class Listing {
  const Listing({
    required this.title,
    required this.brand,
    required this.price,
    required this.priceNote,
    required this.year,
    required this.location,
    required this.condition,
    required this.category,
    this.image,
    this.icon = Icons.precision_manufacturing,
  });

  final String title;
  final String brand;

  /// Asking price, pre-formatted in the Indian lakh/crore grouping.
  final String price;

  /// Small qualifier under the price — "Ex. GST", "Inc. Shipping", …
  final String priceNote;
  final String year;
  final String location;
  final Condition condition;

  /// Drives the filter chips at the top of the listing page.
  final String category;
  final String? image;
  final IconData icon;
}

/// Static catalogue used until the listings API is connected.
/// Category labels for the listing page.
///
/// Holds no listings: the page renders whatever the API returns. The chip row
/// itself comes from the admin panel's Settings, with this as the first entry.
class ListingData {
  ListingData._();

  static const List<String> categories = ['All Machines'];
}
