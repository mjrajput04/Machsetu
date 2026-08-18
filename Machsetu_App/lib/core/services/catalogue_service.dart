import 'package:flutter/material.dart';

import '../../features/home/data/machines.dart';
import '../../features/listings/data/listings.dart';
import '../../features/search/data/search_results.dart';
import 'api_client.dart';
import 'settings_service.dart';

/// Live catalogue backed by the MachSetu admin database.
///
/// The bundled [MachineData.all] list stays as the offline fallback, so the
/// home, search and listing screens render exactly as before whenever the API
/// is unreachable.
class CatalogueService extends ChangeNotifier {
  CatalogueService._();

  static final CatalogueService instance = CatalogueService._();

  List<Machine> _machines = MachineData.all;
  bool _loading = false;
  bool _loadedOnce = false;
  DateTime? _fetchedAt;

  /// Listings the desk publishes should appear without an app restart.
  static const Duration freshFor = Duration(seconds: 30);

  bool get _isStale {
    final at = _fetchedAt;
    return at == null || DateTime.now().difference(at) > freshFor;
  }

  List<Machine> get all => _machines;
  bool get loading => _loading;
  bool get isLive => _loadedOnce;

  List<Machine> forCategory(String category) {
    if (category == MachineData.allCategory) return _machines;
    return _machines.where((m) => m.category == category).toList();
  }

  /// Newest six, for the "Recently Added" grid.
  List<Machine> get recent => _machines.take(6).toList();

  Machine? byTitle(String title) {
    for (final machine in _machines) {
      if (machine.title == title) return machine;
    }
    return null;
  }

  /// Search page cards. Falls back to the bundled result set when offline.
  List<SearchListing> get searchResults =>
      _loadedOnce ? _machines.map(_toSearchListing).toList() : SearchData.results;

  /// Machine listing page cards, in the same shape the screen already draws.
  List<Listing> get listings =>
      _loadedOnce ? _machines.map(_toListing).toList() : ListingData.all;

  /// Category chips for the listing page — "All Machines" plus whatever the
  /// admin panel publishes, so an empty category still shows up.
  List<String> get listingCategories {
    final published = SettingsService.instance.categories;
    if (published.isNotEmpty) {
      return [ListingData.categories.first, ...published];
    }
    if (!_loadedOnce) return ListingData.categories;

    final seen = <String>{};
    for (final machine in _machines) {
      if (machine.category.trim().isNotEmpty) seen.add(machine.category);
    }
    return [ListingData.categories.first, ...seen];
  }

  List<Listing> listingsForCategory(String category) {
    if (category == ListingData.categories.first) return listings;
    if (!_loadedOnce) return ListingData.byCategory(category);
    return _machines
        .where((m) => m.category == category)
        .map(_toListing)
        .toList();
  }

  /// Pulls the catalogue, skipping the call while the last copy is fresh.
  Future<void> load({bool force = false}) async {
    if (_loading || (!force && !_isStale)) return;
    // No notification here — load() is called from initState, and notifying
    // mid-build would rebuild a widget that is already building.
    _loading = true;

    final result = await ApiClient.instance.get('/api/products?limit=200');
    if (result.ok) {
      final raw = result.data['products'];
      if (raw is List && raw.isNotEmpty) {
        final parsed = raw
            .whereType<Map<String, dynamic>>()
            .map(_toMachine)
            .toList();
        if (parsed.isNotEmpty) {
          _machines = parsed;
          _loadedOnce = true;
          _fetchedAt = DateTime.now();
        }
      }
    }

    _loading = false;
    notifyListeners();
  }
}

/* ------------------------------------------------------------- mapping -- */

String _text(dynamic value) => value == null ? '' : value.toString();

List<String> _strings(dynamic value) =>
    value is List ? value.map(_text).where((v) => v.isNotEmpty).toList() : [];

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const {};

/// Indian lakh/crore grouping, matching the bundled catalogue's price strings.
String _rupees(dynamic value) {
  final digits = _text(value).replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 'Price on request';
  if (digits.length <= 3) return '₹$digits';

  final last3 = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return '₹${groups.join(',')},$last3';
}

/// Only rows the seller actually filled in reach the detail page.
List<(String, String)> _rows(List<(String, String)> rows) =>
    rows.where((r) => r.$2.trim().isNotEmpty).toList();

/// Live catalogue entry in the shape the search page already draws.
SearchListing _toSearchListing(Machine machine) => SearchListing(
  title: machine.title,
  subtitle: [
    machine.subtitle,
    machine.year,
  ].where((v) => v.trim().isNotEmpty).join(' • '),
  brand: machine.brand.toUpperCase(),
  price: machine.price,
  image: machine.image,
  badges: [
    if (machine.badge.trim().isNotEmpty)
      ResultBadge(machine.badge, BadgeTone.accent),
    if (machine.condition.trim().isNotEmpty)
      ResultBadge(machine.condition, BadgeTone.light),
  ],
  specs: [
    for (final spec in machine.specs) ResultSpec(spec.label.toUpperCase(), spec.value),
    if (machine.location.trim().isNotEmpty)
      ResultSpec('LOCATION', machine.location),
  ],
);

/// Maps the free-text condition onto the listing page's three badge grades.
Condition _condition(String value) {
  final v = value.toLowerCase();
  if (v.contains('excellent')) return Condition.excellent;
  if (v.contains('like new') || v.contains('new')) return Condition.likeNew;
  return Condition.good;
}

Listing _toListing(Machine machine) => Listing(
  title: machine.title,
  brand: machine.brand,
  price: machine.price,
  priceNote: machine.note,
  year: machine.year,
  location: machine.location,
  condition: _condition(machine.condition),
  category: machine.category,
  image: machine.image,
);

/// Attached paperwork, skipping any row that has no file behind it.
List<MachineDocument> _documents(dynamic value) {
  if (value is! List) return const [];

  return [
    for (final entry in value.whereType<Map<String, dynamic>>())
      if (_text(entry['url']).isNotEmpty)
        MachineDocument(
          title: _text(entry['name']).isEmpty
              ? _text(entry['category'])
              : _text(entry['name']),
          meta: [
            _text(entry['url']).toLowerCase().endsWith('.pdf') ? 'PDF' : 'IMAGE',
            _text(entry['size']),
            _text(entry['category']),
          ].where((v) => v.isNotEmpty).join(' • '),
          url: _text(entry['url']),
        ),
  ];
}

Machine _toMachine(Map<String, dynamic> json) {
  final details = _map(json['details']);
  final specs = _map(json['specs']);
  final hours = _text(json['hours']);
  final year = _text(json['year']);

  return Machine(
    id: _text(json['id']),
    documents: _documents(json['documents']),
    title: _text(json['title']),
    brand: _text(json['brand']),
    subtitle: _text(json['type']),
    category: _text(json['category']),
    year: year,
    price: _rupees(json['price']),
    location: _text(json['location']),
    condition: _text(json['condition']),
    hours: hours,
    origin: _text(json['origin']),
    badge: _text(json['badge']),
    note: _text(json['priceNote']),
    ctaLabel: _text(json['ctaLabel']),
    specs: [
      MachineSpec(
        icon: Icons.calendar_today_outlined,
        label: 'Year',
        value: year.isEmpty ? '—' : year,
      ),
      MachineSpec(
        icon: Icons.schedule,
        label: 'Hours',
        value: hours.isEmpty ? '—' : hours,
      ),
      MachineSpec(
        icon: Icons.public,
        label: 'Origin',
        value: _text(json['origin']).isEmpty ? '—' : _text(json['origin']),
      ),
    ],
    images: _strings(json['images']),
    machineDetails: _rows([
      ('Machine Type', _text(details['machineType'])),
      ('Controller', _text(details['controller'])),
      ('No. of Axis', _text(details['numberOfAxis'])),
      ('Machine Capacity / Size', _text(details['machineCapacity'])),
      ('Maximum Spindle Speed', _text(details['maxSpindleSpeed'])),
      ('Power Requirement', _text(details['powerRequirement'])),
      ('Weight of Machine', _text(details['weight'])),
      ('Installation Year', _text(details['installationYear'])),
      ('Country of Origin', _text(details['countryOfOrigin'])),
      ('Working Status', _text(details['workingStatus'])),
      ('Maintenance Status', _text(details['maintenanceStatus'])),
      ('Last Service Date', _text(details['lastServiceDate'])),
      ('Serial Number', _text(details['serialNumber'])),
      ('Accessories Included', _text(details['accessoriesIncluded'])),
    ]),
    specifications: _rows([
      ('Table Size', _text(specs['tableSize'])),
      ('Lubrication System', _text(specs['lubricationSystem'])),
      ('Electrical Panel Condition', _text(specs['electricalPanelCondition'])),
      ('Tool Magazine Capacity', _text(specs['toolMagazineCapacity'])),
      ('Servo Motors', _text(specs['servoMotors'])),
      ('Tool Changer Type', _text(specs['toolChangerType'])),
      ('Ball Screw Condition', _text(specs['ballScrewCondition'])),
      ('Coolant System', _text(specs['coolantSystem'])),
      ('Guideways', _text(specs['guideways'])),
      ('Hydraulic System', _text(specs['hydraulicSystem'])),
      ('Other Specifications', _text(specs['otherSpecifications'])),
    ]),
    overview: _strings(json['overview']),
    features: _strings(json['features']),
  );
}
