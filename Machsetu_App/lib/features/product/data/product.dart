import 'package:flutter/material.dart';

import '../../../core/utils/currency.dart';

class ProductSpec {
  const ProductSpec({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class ProductDetailPair {
  const ProductDetailPair(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;

  /// Renders the value in green — used for the in-stock condition row.
  final bool highlight;
}

class ProductDocument {
  const ProductDocument({
    required this.title,
    required this.meta,
    required this.color,
    required this.icon,
  });

  final String title;
  final String meta;
  final Color color;
  final IconData icon;
}

/// Everything the product detail page renders.
///
/// The header (photos, series, title, brand, price) is carried over from the
/// card the buyer tapped, so the page always matches the listing they came
/// from. The technical sections below are shared demo content until the
/// listings API returns per-machine specs.
class Product {
  const Product({
    required this.title,
    required this.brand,
    required this.series,
    required this.price,
    required this.priceNote,
    required this.images,
    required this.heroSpecs,
    required this.detailPairs,
    required this.overview,
    required this.tags,
    required this.documents,
    this.leadTime = '4-6 weeks',
    this.icon = Icons.precision_manufacturing,
  });

  final String title;
  final String brand;
  final String series;
  final String price;
  final String priceNote;

  /// Carousel photos — at least one; the hero auto-advances when there is
  /// more than one.
  final List<String> images;
  final List<ProductSpec> heroSpecs;
  final List<ProductDetailPair> detailPairs;
  final List<String> overview;
  final List<String> tags;
  final List<ProductDocument> documents;

  /// Quoted delivery window, shown on the cart line.
  final String leadTime;
  final IconData icon;

  /// [price] as a number so the cart can total it up.
  double get amount => Rupees.parse(price);
}

/// Builds a [Product] from whatever a listing card knows about a machine.
class ProductCatalog {
  ProductCatalog._();

  static const String _photos = 'assets/images/machines';

  /// Extra shots appended to every carousel so the hero has something to
  /// rotate through until listings carry their own photo sets.
  static const List<String> _contextShots = [
    '$_photos/workshop_banner.jpg',
    '$_photos/dmg_cmx_1100v.jpg',
  ];

  static const List<ProductSpec> _heroSpecs = [
    ProductSpec(
      icon: Icons.speed_outlined,
      label: 'SPINDLE SPEED',
      value: '12,000 RPM',
    ),
    ProductSpec(
      icon: Icons.straighten,
      label: 'X-AXIS TRAVEL',
      value: '1,020 mm',
    ),
    ProductSpec(
      icon: Icons.fitness_center_outlined,
      label: 'LOAD CAPACITY',
      value: '1,200 KG',
    ),
    ProductSpec(
      icon: Icons.memory_outlined,
      label: 'CONTROL TYPE',
      value: 'Fanuc 31i-B',
    ),
  ];

  static const List<ProductDetailPair> _detailPairs = [
    ProductDetailPair('Tool Stations', '40 Positions'),
    ProductDetailPair('Power Supply', '3-Phase 400V'),
    ProductDetailPair('Coolant Pressure', '20 Bar (CTS)'),
    ProductDetailPair('Rapid Traverse', '36 m/min'),
    ProductDetailPair('Accuracy', '±0.003 mm'),
    ProductDetailPair('Condition', 'In Stock (New)', highlight: true),
  ];

  static const List<String> _tags = [
    'ISO 9001 Certified',
    'CE Compliant',
    'High Precision',
  ];

  static Product from({
    required String title,
    required String brand,
    required String price,
    String priceNote = 'SHIPPING & INSTALLATION',
    String series = 'PRECISION SERIES',
    String leadTime = '4-6 weeks',
    String? image,
    IconData icon = Icons.precision_manufacturing,
  }) {
    final shortName = title.split(' ').take(2).join(' ');

    return Product(
      title: title,
      brand: brand,
      series: series,
      price: price,
      priceNote: priceNote,
      leadTime: leadTime,
      icon: icon,
      images: [?image, ..._contextShots],
      heroSpecs: _heroSpecs,
      detailPairs: _detailPairs,
      overview: [
        'The $shortName represents the pinnacle of multi-axis machining '
            'efficiency. Engineered for high-volume automotive and aerospace '
            'components, this machine features a dual-contact spindle and '
            'reinforced casting for superior thermal stability.',
        'Equipped with the latest i-Series control logic, the $shortName '
            'reduces non-cutting time by up to 22% compared to previous '
            'generations, making it the most cost-effective solution in its '
            'class for Tier 1 manufacturers.',
      ],
      tags: _tags,
      documents: [
        ProductDocument(
          title: "Operator's Manual $shortName",
          meta: 'PDF • 14.5 MB • Updated 2024',
          color: const Color(0xFFDC2626),
          icon: Icons.picture_as_pdf_outlined,
        ),
        const ProductDocument(
          title: 'Audit Report & Certification',
          meta: 'PDF • 3.2 MB • Q1 2024',
          color: Color(0xFF2563EB),
          icon: Icons.verified_outlined,
        ),
      ],
    );
  }
}
