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
    this.url = '',
  });

  final String title;
  final String meta;
  final Color color;
  final IconData icon;

  /// Where the file lives, e.g. /uploads/invoice-ms1a2b.pdf. Empty on the
  /// sample entries that have no file behind them.
  final String url;
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
    this.id = '',
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

  /// Catalogue id, e.g. `MS-1001`. Carried into the cart and the order so
  /// the sourcing desk knows exactly which listing was bought.
  final String id;

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

  /// Builds a detail page straight from a catalogue entry, so every figure
  /// on screen belongs to that machine rather than a shared demo block.
  static Product fromMachine(Machine machine) {
    String detail(List<String> labels, String fallback) {
      for (final label in labels) {
        for (final row in [
          ...machine.machineDetails,
          ...machine.specifications,
        ]) {
          if (row.$1.toLowerCase() == label.toLowerCase()) return row.$2;
        }
      }
      return fallback;
    }

    return Product(
      id: machine.id,
      title: machine.title,
      brand: machine.brand,
      series: machine.category.toUpperCase(),
      price: machine.price,
      priceNote: machine.note.isEmpty
          ? 'SHIPPING & INSTALLATION'
          : machine.note,
      leadTime: '4-6 weeks',
      equipmentType: machine.subtitle,
      icon: machine.icon,
      images: machine.images,
      heroSpecs: [
        ProductSpec(
          icon: Icons.speed_outlined,
          label: 'SPINDLE SPEED',
          value: detail([
            'Spindle Speed',
            'Main Spindle Speed',
            'Grinding Wheel Speed',
            'Max Discharge Current',
            'Turning Spindle Speed',
          ], '—'),
        ),
        ProductSpec(
          icon: Icons.straighten,
          label: 'WORK ENVELOPE',
          value: detail([
            'Travels X/Y/Z',
            'Max Turning Diameter',
            'Max Cutting Diameter',
            'Table Working Surface',
            'Distance Between Centres',
            'Grinding Diameter Range',
            'Pallet Size',
          ], '—'),
        ),
        ProductSpec(
          icon: Icons.build_outlined,
          label: 'TOOLING',
          value: detail([
            'Tool Magazine Capacity',
            'Turret Stations',
            'Grinding Wheel Size',
            'Wire Diameter Range',
            'Electrode Materials',
          ], '—'),
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
        // Whatever the seller actually attached, in the order it was filed.
        for (final doc in machine.documents)
          ProductDocument(
            title: doc.title,
            meta: doc.meta,
            color: doc.isPdf
                ? const Color(0xFFDC2626)
                : const Color(0xFF2563EB),
            icon: doc.isPdf
                ? Icons.picture_as_pdf_outlined
                : Icons.image_outlined,
            url: doc.url,
          ),
        if (machine.documents.isEmpty)
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
    String id = '',
    String priceNote = 'SHIPPING & INSTALLATION',
    String series = 'PRECISION SERIES',
    String leadTime = '4-6 weeks',
    String equipmentType = 'Industrial Equipment',
    String? image,
    IconData icon = Icons.precision_manufacturing,
  }) {
    return Product(
      id: id,
      title: title,
      brand: brand,
      series: series,
      price: price,
      priceNote: priceNote,
      leadTime: leadTime,
      equipmentType: equipmentType,
      icon: icon,
      images: [?image],
      // Only what the caller actually knows. A listing the catalogue has not
      // loaded yet shows a short record rather than another machine's
      // specifications, marketing prose and documents.
      heroSpecs: const [],
      detailPairs: const [],
      machineDetails: [
        ProductDetailPair('Brand / Make', brand),
        if (equipmentType != 'Industrial Equipment')
          ProductDetailPair('Machine Type', equipmentType),
      ],
      specifications: const [],
      commercial: const [],
      overview: const [],
      tags: const [],
      documents: const [],
    );
  }
}
