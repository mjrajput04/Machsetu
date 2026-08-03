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
class ListingData {
  ListingData._();

  static const String _photos = 'assets/images/machines';

  static const List<String> categories = [
    'All Machines',
    'Milling',
    'Lathes',
    'Grinding',
  ];

  static const List<Listing> all = [
    Listing(
      title: 'Haas VF-2',
      brand: 'Haas Automation',
      price: '₹57,50,000',
      priceNote: 'Ex. GST',
      year: '2019',
      location: 'Pune',
      condition: Condition.excellent,
      category: 'Milling',
      image: '$_photos/haas_vf2.jpg',
      icon: Icons.precision_manufacturing,
    ),
    Listing(
      title: 'DMU 50 3rd Gen',
      brand: 'DMG MORI',
      price: '₹1,19,00,000',
      priceNote: 'Inc. Shipping',
      year: '2021',
      location: 'Bengaluru',
      condition: Condition.likeNew,
      category: 'Milling',
      image: '$_photos/dmg_cmx_1100v.jpg',
      icon: Icons.settings_suggest_outlined,
    ),
    Listing(
      title: 'Quick Turn 250',
      brand: 'Mazak',
      price: '₹46,00,000',
      priceNote: 'Certified',
      year: '2017',
      location: 'Coimbatore',
      condition: Condition.good,
      category: 'Lathes',
      image: '$_photos/mazak_quick_turn.jpg',
      icon: Icons.rotate_right,
    ),
    Listing(
      title: 'Puma GT2100',
      brand: 'Doosan Machine Tools',
      price: '₹68,80,000',
      priceNote: 'Negotiable',
      year: '2020',
      location: 'Chennai',
      condition: Condition.excellent,
      category: 'Lathes',
      image: '$_photos/doosan_lynx.jpg',
      icon: Icons.hardware_outlined,
    ),
  ];

  /// [category] of `All Machines` returns everything.
  static List<Listing> byCategory(String category) {
    if (category == categories.first) return all;
    return all.where((l) => l.category == category).toList();
  }
}
