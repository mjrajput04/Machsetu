import 'package:flutter/foundation.dart';

import '../../features/home/data/machines.dart';

/// How a filtered list is ordered.
enum MachineSort {
  newest('Newest first'),
  priceLowHigh('Price: low to high'),
  priceHighLow('Price: high to low'),
  yearNewest('Year: newest first'),
  nameAZ('Name: A to Z');

  const MachineSort(this.label);

  final String label;
}

/// A set of catalogue filters, applied together.
///
/// Immutable so a sheet can edit a copy and only hand it back on Apply.
@immutable
class MachineFilter {
  const MachineFilter({
    this.query = '',
    this.categories = const <String>{},
    this.conditions = const <String>{},
    this.brands = const <String>{},
    this.minPrice,
    this.maxPrice,
    this.sort = MachineSort.newest,
  });

  final String query;
  final Set<String> categories;
  final Set<String> conditions;
  final Set<String> brands;

  /// Rupees. Null means "no bound".
  final int? minPrice;
  final int? maxPrice;

  final MachineSort sort;

  /// How many constraints are active — drives the badge on the Filters button.
  int get activeCount =>
      categories.length +
      conditions.length +
      brands.length +
      (minPrice != null ? 1 : 0) +
      (maxPrice != null ? 1 : 0);

  bool get isEmpty => activeCount == 0 && query.trim().isEmpty;

  MachineFilter copyWith({
    String? query,
    Set<String>? categories,
    Set<String>? conditions,
    Set<String>? brands,
    int? minPrice,
    int? maxPrice,
    MachineSort? sort,
    bool clearMin = false,
    bool clearMax = false,
  }) {
    return MachineFilter(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      conditions: conditions ?? this.conditions,
      brands: brands ?? this.brands,
      minPrice: clearMin ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMax ? null : (maxPrice ?? this.maxPrice),
      sort: sort ?? this.sort,
    );
  }

  MachineFilter cleared() => MachineFilter(query: query, sort: sort);

  /// Runs the whole filter over [machines] and orders the survivors.
  List<Machine> apply(List<Machine> machines) {
    final q = query.trim().toLowerCase();

    final matched = machines.where((m) {
      if (q.isNotEmpty) {
        final haystack = [
          m.title,
          m.brand,
          m.subtitle,
          m.category,
          m.location,
          m.year,
          m.condition,
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      if (categories.isNotEmpty && !categories.contains(m.category)) {
        return false;
      }
      if (conditions.isNotEmpty && !conditions.contains(m.condition)) {
        return false;
      }
      if (brands.isNotEmpty && !brands.contains(m.brand)) return false;

      final price = priceOf(m);
      // A "price on request" machine is only hidden when a bound is set.
      if (minPrice != null && (price == null || price < minPrice!)) {
        return false;
      }
      if (maxPrice != null && (price == null || price > maxPrice!)) {
        return false;
      }

      return true;
    }).toList();

    return sorted(matched);
  }

  List<Machine> sorted(List<Machine> machines) {
    final rows = [...machines];
    switch (sort) {
      case MachineSort.newest:
        break; // the API already returns newest first
      case MachineSort.priceLowHigh:
        rows.sort(
          (a, b) => (priceOf(a) ?? 1 << 62).compareTo(priceOf(b) ?? 1 << 62),
        );
      case MachineSort.priceHighLow:
        rows.sort((a, b) => (priceOf(b) ?? -1).compareTo(priceOf(a) ?? -1));
      case MachineSort.yearNewest:
        rows.sort(
          (a, b) =>
              (int.tryParse(b.year) ?? 0).compareTo(int.tryParse(a.year) ?? 0),
        );
      case MachineSort.nameAZ:
        rows.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }
    return rows;
  }

  /// Digits out of a display price like "₹58,50,000". Null when on request.
  static int? priceOf(Machine machine) {
    final digits = machine.price.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  /// Distinct brands in the catalogue, for the sheet's brand chips.
  static List<String> brandsOf(List<Machine> machines) {
    final set = machines
        .map((m) => m.brand.trim())
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();
    set.sort();
    return set;
  }

  static List<String> conditionsOf(List<Machine> machines) {
    final set = machines
        .map((m) => m.condition.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    set.sort();
    return set;
  }

  static List<String> categoriesOf(List<Machine> machines) {
    final set = machines
        .map((m) => m.category.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    set.sort();
    return set;
  }
}
