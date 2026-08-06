import 'package:flutter/material.dart';

import '../../../core/utils/currency.dart';
import '../../home/data/machines.dart';

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
    required this.machineDetails,
    required this.specifications,
    required this.commercial,
    required this.overview,
    required this.tags,
    required this.documents,
    this.leadTime = '4-6 weeks',
    this.equipmentType = 'Industrial Equipment',
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

  /// Section 2 of the registration form.
  final List<ProductDetailPair> machineDetails;

  /// Section 4 of the registration form.
  final List<ProductDetailPair> specifications;

  /// Section 3 of the registration form.
  final List<ProductDetailPair> commercial;
  final List<String> overview;
  final List<String> tags;
  final List<ProductDocument> documents;

  /// Quoted delivery window, shown on the cart line.
  final String leadTime;

  /// Machine category carried over from the listing — "Vertical Machining
  /// Center", "CNC Lathe", … Shown on the order confirmation.
  final String equipmentType;
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

  /// Section 2 — machine details. No overlap with [_heroSpecs] or
  /// [_detailPairs]; spindle speed, power and tool stations live there.
  static const List<ProductDetailPair> _machineDetails = [
    ProductDetailPair('Machine Type', 'Vertical Machining Center'),
    ProductDetailPair('Controller', 'Fanuc 31i-B'),
    ProductDetailPair('No. of Axis', '3 Axis'),
    ProductDetailPair('Machine Capacity / Size', '1020 x 560 x 510 mm'),
    ProductDetailPair('Weight of Machine', '3,175 kg'),
    ProductDetailPair('Installation Year', '2022'),
    ProductDetailPair('Country of Origin', 'Japan'),
    ProductDetailPair('Working Hours', '4,200 hrs'),
    ProductDetailPair('Working Status', 'Running'),
    ProductDetailPair('Maintenance Status', 'Regular'),
    ProductDetailPair('Last Service Date', '18 Aug 2026'),
    ProductDetailPair(
      'Accessories Included',
      'Tool holders, coolant pump, chip auger, manuals',
    ),
  ];

  /// Section 4 — machine specifications.
  static const List<ProductDetailPair> _specifications = [
    ProductDetailPair('Table Size', '914 x 356 mm'),
    ProductDetailPair('Lubrication System', 'Automatic centralised'),
    ProductDetailPair('Electrical Panel Condition', 'Excellent'),
    ProductDetailPair('Tool Changer Type', 'Side mount ATC'),
    ProductDetailPair('Servo Motors', 'AC servo — healthy'),
    ProductDetailPair('Ball Screw Condition', 'Excellent, no backlash'),
    ProductDetailPair('Coolant System', 'Through spindle + flood'),
    ProductDetailPair('Guideways', 'Linear guideways'),
    ProductDetailPair('Hydraulic System', 'Working'),
  ];

  /// Section 3 — commercial terms.
  static const List<ProductDetailPair> _commercial = [
    ProductDetailPair('Negotiable', 'Yes'),
    ProductDetailPair('GST Available', 'Yes'),
    ProductDetailPair('Tax Invoice Available', 'Yes'),
    ProductDetailPair('Owner Type', '1st Owner'),
    ProductDetailPair('Delivery Available', 'Yes'),
    ProductDetailPair('Loading Available', 'Yes'),
    ProductDetailPair('Finance / Loan Pending', 'No'),
  ];

  static const List<String> _tags = [
    'ISO 9001 Certified',
    'CE Compliant',
    'High Precision',
  ];

  /// Builds a detail page straight from a catalogue entry, so every figure
  /// on screen belongs to that machine rather than a shared demo block.
  static Product fromMachine(Machine machine) {
    String detail(List<String> labels, String fallback) {
      for (final label in labels) {
        for (final row in [...machine.machineDetails, ...machine.specifications]) {
          if (row.$1.toLowerCase() == label.toLowerCase()) return row.$2;
        }
      }
      return fallback;
    }

    return Product(
      title: machine.title,
      brand: machine.brand,
      series: machine.category.toUpperCase(),
      price: machine.price,
      priceNote: machine.note.isEmpty ? 'SHIPPING & INSTALLATION' : machine.note,
      leadTime: '4-6 weeks',
      equipmentType: machine.subtitle,
      icon: machine.icon,
      images: machine.images,
      heroSpecs: [
        ProductSpec(
          icon: Icons.speed_outlined,
          label: 'SPINDLE SPEED',
          value: detail(
            ['Spindle Speed', 'Main Spindle Speed', 'Grinding Wheel Speed',
             'Max Discharge Current', 'Turning Spindle Speed'],
            '—',
          ),
        ),
        ProductSpec(
          icon: Icons.straighten,
          label: 'WORK ENVELOPE',
          value: detail(
            ['Travels X/Y/Z', 'Max Turning Diameter', 'Max Cutting Diameter',
             'Table Working Surface', 'Distance Between Centres',
             'Grinding Diameter Range', 'Pallet Size'],
            '—',
          ),
        ),
        ProductSpec(
          icon: Icons.build_outlined,
          label: 'TOOLING',
          value: detail(
            ['Tool Magazine Capacity', 'Turret Stations', 'Grinding Wheel Size',
             'Wire Diameter Range', 'Electrode Materials'],
            '—',
          ),
        ),
        ProductSpec(
          icon: Icons.memory_outlined,
          label: 'CONTROL',
          value: detail(['Controller'], '—'),
        ),
      ],
      detailPairs: [
        ProductDetailPair('Year of Manufacture', machine.year),
        ProductDetailPair('Condition', machine.condition, highlight: true),
        ProductDetailPair('Working Hours', '${machine.hours} hrs'),
        ProductDetailPair('Location', machine.location),
        ProductDetailPair('Country of Origin', machine.origin),
        ProductDetailPair('Category', machine.category),
      ],
      machineDetails: [
        for (final row in machine.machineDetails)
          ProductDetailPair(row.$1, row.$2),
      ],
      specifications: [
        for (final row in machine.specifications)
          ProductDetailPair(row.$1, row.$2),
      ],
      commercial: const [],
      overview: machine.overview,
      tags: machine.features,
      documents: [
        ProductDocument(
          title: "Operator's Manual — ${machine.title}",
          meta: 'PDF • 14.5 MB • ${machine.brand}',
          color: const Color(0xFFDC2626),
          icon: Icons.picture_as_pdf_outlined,
        ),
        const ProductDocument(
          title: 'Technical Audit Report',
          meta: 'PDF • 3.2 MB • MachSetu verified',
          color: Color(0xFF2563EB),
          icon: Icons.verified_outlined,
        ),
      ],
    );
  }

  static Product from({
    required String title,
    required String brand,
    required String price,
    String priceNote = 'SHIPPING & INSTALLATION',
    String series = 'PRECISION SERIES',
    String leadTime = '4-6 weeks',
    String equipmentType = 'Industrial Equipment',
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
      equipmentType: equipmentType,
      icon: icon,
      images: [?image, ..._contextShots],
      heroSpecs: _heroSpecs,
      detailPairs: _detailPairs,
      machineDetails: [
        ProductDetailPair('Brand / Make', brand),
        if (equipmentType != 'Industrial Equipment')
          ProductDetailPair('Machine Type', equipmentType),
        // The static list already carries a Machine Type fallback.
        ..._machineDetails.where(
          (p) =>
              p.label != 'Machine Type' ||
              equipmentType == 'Industrial Equipment',
        ),
      ],
      specifications: _specifications,
      commercial: _commercial,
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
