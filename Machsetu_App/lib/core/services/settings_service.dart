import 'package:flutter/material.dart';

import '../../features/home/data/machines.dart';
import 'api_client.dart';

/// One panel of the home-screen hero carousel.
class HeroContent {
  const HeroContent({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.image,
  });

  final String badge;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String image;

  static const HeroContent fallback = HeroContent(
    badge: 'VERIFIED LISTINGS',
    title: 'Mastering Precision,\nMarket-Ready.',
    subtitle:
        'Access 450+ certified CNC and VMC centers with full '
        'maintenance history and performance logs.',
    ctaLabel: 'Explore Manifest',
    image: MachineData.bannerPhoto,
  );
}

/// Fee percentages behind every cart and checkout total.
class Commercials {
  const Commercials({
    required this.gstRate,
    required this.brokerageRate,
    required this.shippingRate,
    required this.platformCommission,
  });

  /// All four are percentages, e.g. 18 for 18%.
  final double gstRate;
  final double brokerageRate;
  final double shippingRate;
  final double platformCommission;

  static const Commercials fallback = Commercials(
    gstRate: 18,
    brokerageRate: 1.5,
    shippingRate: 0.5,
    platformCommission: 2.5,
  );
}

/// One question and answer on the Help & Support screen.
class Faq {
  const Faq(this.question, this.answer);

  final String question;
  final String answer;
}

/// Help & Support contact details and the Terms copy.
class SupportContent {
  const SupportContent({
    required this.faqs,
    required this.phone,
    required this.email,
    required this.hours,
    required this.terms,
  });

  final List<Faq> faqs;
  final String phone;
  final String email;
  final String hours;
  final String terms;

  static const SupportContent fallback = SupportContent(
    faqs: [],
    phone: '+91 84015 03169',
    email: 'support@machsetu.in',
    hours: 'Mon–Sat, 9:30 AM – 7:00 PM IST',
    terms: '',
  );
}

/// Option lists the seller wizard ticks and chips are built from.
class SellOptionLists {
  const SellOptionLists({
    required this.requiredPhotos,
    required this.documentTypes,
    required this.workingStatus,
    required this.conditions,
    required this.maintenanceStatus,
    required this.ownerTypes,
  });

  final List<String> requiredPhotos;
  final List<String> documentTypes;
  final List<String> workingStatus;
  final List<String> conditions;
  final List<String> maintenanceStatus;
  final List<String> ownerTypes;

  static const SellOptionLists empty = SellOptionLists(
    requiredPhotos: [],
    documentTypes: [],
    workingStatus: [],
    conditions: [],
    maintenanceStatus: [],
    ownerTypes: [],
  );
}

/// Marketplace configuration owned by the admin panel's Settings page.
///
/// Category chips, the home hero and the fee percentages all come from here,
/// with the bundled values standing in whenever the API is unreachable.
class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  List<String> _categories = const [];
  List<HeroContent> _heroSlides = const [HeroContent.fallback];
  Commercials _commercials = Commercials.fallback;
  SupportContent _support = SupportContent.fallback;
  SellOptionLists _sellOptions = SellOptionLists.empty;
  bool _loading = false;
  bool _loadedOnce = false;
  DateTime? _fetchedAt;

  /// How long a fetched copy is trusted before the next read goes to the
  /// server again. Keeps a category the desk just added from waiting for an
  /// app restart to show up.
  static const Duration freshFor = Duration(seconds: 30);

  bool get _isStale {
    final at = _fetchedAt;
    return at == null || DateTime.now().difference(at) > freshFor;
  }

  /// Slides the home banner cycles through, never empty.
  List<HeroContent> get heroSlides => _heroSlides;

  /// First slide, for anything that only needs one.
  HeroContent get hero => _heroSlides.first;
  Commercials get commercials => _commercials;

  /// FAQs, contact details and the Terms text.
  SupportContent get support => _support;

  /// Wizard checklists; empty lists mean "use the bundled defaults".
  SellOptionLists get sellOptions => _sellOptions;
  bool get isLive => _loadedOnce;

  /// Home-screen chips: "All" first, then whatever the desk has published.
  ///
  /// Nothing is invented — before the settings call lands there is only
  /// "All", so a chip the marketplace does not offer can never appear.
  List<(IconData, String)> get categoryChips => [
    (Icons.grid_view_rounded, MachineData.allCategory),
    for (final name in _categories) (_iconFor(name), name),
  ];

  List<String> get categories => _categories;

  /// Fills the configuration without a round trip. Tests only.
  @visibleForTesting
  void seed({List<String> categories = const []}) {
    _categories = categories;
    _loadedOnce = true;
    _fetchedAt = DateTime.now();
  }

  /// Pulls the latest configuration, skipping the call while it is fresh.
  Future<void> load({bool force = false}) async {
    if (_loading || (!force && !_isStale)) return;
    // Called from initState, so no notification until the answer is in.
    _loading = true;

    final result = await ApiClient.instance.get('/api/settings');
    if (result.ok) {
      final raw = result.data['categories'];
      if (raw is List) {
        _categories = raw
            .map((v) => v.toString())
            .where((v) => v.isNotEmpty)
            .toList();
      }

      final slides = result.data['heroSlides'];
      if (slides is List) {
        final parsed = slides
            .whereType<Map<String, dynamic>>()
            .map(_slide)
            .toList();
        if (parsed.isNotEmpty) _heroSlides = parsed;
      } else {
        // Older servers answer with a single hero object.
        final hero = result.data['hero'];
        if (hero is Map<String, dynamic>) _heroSlides = [_slide(hero)];
      }

      final fees = result.data['commercials'];
      if (fees is Map<String, dynamic>) {
        _commercials = Commercials(
          gstRate: _rate(fees['gstRate'], Commercials.fallback.gstRate),
          brokerageRate: _rate(
            fees['brokerageRate'],
            Commercials.fallback.brokerageRate,
          ),
          shippingRate: _rate(
            fees['shippingRate'],
            Commercials.fallback.shippingRate,
          ),
          platformCommission: _rate(
            fees['platformCommission'],
            Commercials.fallback.platformCommission,
          ),
        );
      }
      final support = result.data['support'];
      if (support is Map<String, dynamic>) {
        final faqs = support['faqs'];
        _support = SupportContent(
          faqs: [
            if (faqs is List)
              for (final f in faqs.whereType<Map<String, dynamic>>())
                Faq(
                  _text(f['question'], ''),
                  _text(f['answer'], ''),
                ),
          ],
          phone: _text(support['phone'], SupportContent.fallback.phone),
          email: _text(support['email'], SupportContent.fallback.email),
          hours: _text(support['hours'], SupportContent.fallback.hours),
          terms: _text(support['terms'], ''),
        );
      }

      final options = result.data['sellOptions'];
      if (options is Map<String, dynamic>) {
        List<String> list(String key) {
          final value = options[key];
          return value is List
              ? value.map((v) => v.toString()).where((v) => v.isNotEmpty).toList()
              : const [];
        }

        _sellOptions = SellOptionLists(
          requiredPhotos: list('requiredPhotos'),
          documentTypes: list('documentTypes'),
          workingStatus: list('workingStatus'),
          conditions: list('conditions'),
          maintenanceStatus: list('maintenanceStatus'),
          ownerTypes: list('ownerTypes'),
        );
      }

      _loadedOnce = true;
      _fetchedAt = DateTime.now();
    }

    _loading = false;
    notifyListeners();
  }

  static HeroContent _slide(Map<String, dynamic> json) => HeroContent(
    badge: _text(json['badge'], HeroContent.fallback.badge),
    title: _text(json['title'], HeroContent.fallback.title),
    subtitle: _text(json['subtitle'], HeroContent.fallback.subtitle),
    ctaLabel: _text(json['ctaLabel'], HeroContent.fallback.ctaLabel),
    image: _text(json['image'], HeroContent.fallback.image),
  );

  /// Keeps the chip icons meaningful for whatever the desk names a category.
  static IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('vmc') || n.contains('machining')) {
      return Icons.auto_awesome_mosaic_outlined;
    }
    if (n.contains('lathe') || n.contains('turning')) {
      return Icons.rotate_90_degrees_ccw;
    }
    if (n.contains('grind')) return Icons.blur_circular;
    if (n.contains('edm') || n.contains('spark')) {
      return Icons.electric_bolt_outlined;
    }
    if (n.contains('press') || n.contains('punch')) return Icons.compress;
    if (n.contains('laser') || n.contains('cut')) return Icons.content_cut;
    if (n.contains('cnc')) return Icons.view_week_outlined;
    return Icons.precision_manufacturing;
  }

  static String _text(dynamic value, String fallback) {
    final v = value?.toString() ?? '';
    return v.isEmpty ? fallback : v;
  }

  static double _rate(dynamic value, double fallback) {
    final v = value is num ? value.toDouble() : double.tryParse('$value');
    return v == null || v < 0 ? fallback : v;
  }
}
