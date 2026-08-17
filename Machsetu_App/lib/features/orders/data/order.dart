import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../cart/data/cart_store.dart';
import 'order_api.dart';

/// Where an order sits in the procurement pipeline.
enum OrderStatus {
  inquiryReceived('Inquiry Received'),
  underReview('Under Review'),
  brokerContact('Broker Contacting You'),
  confirmed('Order Confirmed'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  final String label;

  /// Delivered and cancelled orders drop into the history section.
  bool get isClosed => this == delivered || this == cancelled;

  Color get foreground => switch (this) {
    OrderStatus.inquiryReceived => AppColors.brandBlue,
    OrderStatus.underReview => AppColors.accentDark,
    OrderStatus.brokerContact => AppColors.accentDark,
    OrderStatus.confirmed => AppColors.success,
    OrderStatus.delivered => AppColors.textSecondary,
    OrderStatus.cancelled => AppColors.danger,
  };

  Color get background => switch (this) {
    OrderStatus.delivered => AppColors.border.withValues(alpha: 0.7),
    _ => foreground.withValues(alpha: 0.13),
  };
}

/// One stop on the procurement timeline.
class TrackingStage {
  const TrackingStage({
    required this.title,
    required this.icon,
    this.detail,
    this.stamp,
  });

  final String title;
  final IconData icon;

  /// Body copy — only the reached and in-progress stages carry one.
  final String? detail;

  /// Timestamp shown beside a completed stage.
  final String? stamp;
}

class Order {
  const Order({
    required this.reference,
    required this.placedOn,
    required this.title,
    required this.status,
    required this.location,
    required this.items,
    required this.subtotal,
    required this.freight,
    required this.gst,
    required this.total,
    required this.equipmentType,
    required this.logisticsMode,
    required this.stages,
    this.thumbnail,
    this.note,
    this.stageIndex = 1,
    this.icon = Icons.precision_manufacturing,
    this.deliveryAddress = '',
    this.contactName = '',
    this.contactPhone = '',
    this.contactCompany = '',
    this.contactGstin = '',
  });

  /// Buyer-facing order number, e.g. `#CP-99203`.
  final String reference;

  /// Pre-formatted placement date, e.g. `Oct 24, 2026`.
  final String placedOn;

  /// Headline machine name.
  final String title;
  final OrderStatus status;

  /// Delivery destination shown on the order card.
  final String location;
  final List<CartItem> items;
  final double subtotal;
  final double freight;
  final double gst;
  final double total;
  final String equipmentType;
  final String logisticsMode;
  final List<TrackingStage> stages;
  final String? thumbnail;

  /// Extra line on closed orders — "Quality Verified", "Replaced by …".
  final String? note;

  /// Index of the stage currently in progress; everything before it is done.
  final int stageIndex;
  final IconData icon;

  // ---- Taken from the checkout form, shown on the tracking screen --------

  /// Street, city, state and pincode as one line.
  final String deliveryAddress;
  final String contactName;
  final String contactPhone;
  final String contactCompany;
  final String contactGstin;

  /// Longer id used on the tracking screen, e.g. `#CP-99203-AX`.
  String get trackingId => '$reference-AX';

  /// Name of the last completed stage — drives the tracking status banner.
  String get currentStatus =>
      stages[(stageIndex - 1).clamp(0, stages.length - 1)].title;
}

/// The buyer's order history, backed by the orders API.
///
/// What the sourcing desk has on file wins; the local list is only a cache so
/// the Orders tab still renders while offline.
class OrderStore extends ChangeNotifier {
  OrderStore._();

  static final OrderStore instance = OrderStore._();

  static const String _photos = 'assets/images/machines';

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  bool get isEmpty => _orders.isEmpty;

  /// Open inquiries, newest first.
  List<Order> get active => _orders.where((o) => !o.status.isClosed).toList();

  /// Delivered and cancelled orders.
  List<Order> get history => _orders.where((o) => o.status.isClosed).toList();

  bool _loading = false;
  DateTime? _fetchedAt;

  /// A stage the desk changes should reach the buyer without a restart.
  static const Duration freshFor = Duration(seconds: 20);

  bool get _isStale {
    final at = _fetchedAt;
    return at == null || DateTime.now().difference(at) > freshFor;
  }

  /// Replaces the cached history with what the server holds.
  Future<void> loadMine({bool force = false}) async {
    if (_loading || (!force && !_isStale)) return;
    // Set without notifying — loadMine() runs from initState.
    _loading = true;

    final fetched = await OrderApi.mine();
    if (fetched != null) {
      _orders
        ..clear()
        ..addAll(fetched);
      _fetchedAt = DateTime.now();
    }

    _loading = false;
    notifyListeners();
  }

  /// The server's current copy of an order, by reference.
  Order? byReference(String reference) {
    for (final order in _orders) {
      if (order.reference == reference) return order;
    }
    return null;
  }

  /// Sends the cart to the desk, then mirrors the order locally.
  ///
  /// Falls back to a local-only order when the server cannot be reached, so
  /// the buyer still reaches the confirmation screen.
  Future<({Order order, String? error})> submit(
    CartStore cart, {
    String location = 'India',
    Map<String, dynamic> customer = const {},
  }) async {
    final sent = await OrderApi.place(
      cart,
      destination: location,
      customer: customer,
    );
    final order = place(
      cart,
      location: location,
      reference: sent.reference,
      customer: customer,
    );

    if (sent.reference != null) {
      await loadMine(force: true);
      return (
        order: byReference(sent.reference!) ?? order,
        error: null,
      );
    }
    return (order: order, error: sent.error);
  }

  /// Snapshots the cart into a new order. The caller clears the cart.
  Order place(
    CartStore cart, {
    String location = 'India',
    String? reference,
    Map<String, dynamic> customer = const {},
  }) {
    final first = cart.items.isEmpty ? null : cart.items.first.product;

    final order = Order(
      reference: reference ?? _reference(cart),
      placedOn: _today(),
      title: first?.title ?? 'Industrial equipment',
      status: OrderStatus.inquiryReceived,
      location: location,
      items: List.of(cart.items),
      subtotal: cart.subtotal,
      freight: cart.freight,
      gst: cart.gst,
      total: cart.total,
      equipmentType: first?.equipmentType ?? 'Industrial Equipment',
      logisticsMode: 'Expedited Freight',
      thumbnail: first != null && first.images.isNotEmpty
          ? first.images.first
          : null,
      icon: first?.icon ?? Icons.precision_manufacturing,
      stages: _stages(),
      deliveryAddress: [
        customer['street'],
        customer['city'],
        customer['state'],
        customer['zip'],
      ].map((v) => (v ?? '').toString()).where((v) => v.isNotEmpty).join(', '),
      contactName: (customer['name'] ?? '').toString(),
      contactPhone: (customer['phone'] ?? '').toString(),
      contactCompany: (customer['company'] ?? '').toString(),
      contactGstin: (customer['gstin'] ?? '').toString(),
    );

    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  void remove(Order order) {
    _orders.remove(order);
    notifyListeners();
  }

  void clear() {
    _orders.clear();
    notifyListeners();
  }

  /// Sample pipeline so the Orders screen has content before the API exists.
  /// Called once from `main()`; drop that call to start with a clean slate.
  void seedDemoOrders() {
    if (_orders.isNotEmpty) return;

    _orders.addAll([
      Order(
        reference: '#ORD-88219',
        placedOn: 'Oct 24, 2026',
        title: 'AX-900 Precision Lathe',
        status: OrderStatus.underReview,
        location: 'Pune Industrial Area',
        items: const [],
        subtotal: 5750000,
        freight: 5370,
        gst: 1035966.6,
        total: 6791336.6,
        equipmentType: 'CNC Precision Lathe',
        logisticsMode: 'Expedited Freight',
        thumbnail: '$_photos/mazak_quick_turn.jpg',
        icon: Icons.rotate_right,
        stageIndex: 1,
        stages: _stages(),
      ),
      Order(
        reference: '#ORD-90122',
        placedOn: 'Oct 28, 2026',
        title: 'Cobot Series Z-4',
        status: OrderStatus.inquiryReceived,
        location: 'Bengaluru Hub',
        items: const [],
        subtotal: 2890000,
        freight: 5370,
        gst: 521166.6,
        total: 3416536.6,
        equipmentType: 'Collaborative Robot Cell',
        logisticsMode: 'Standard Freight',
        thumbnail: '$_photos/fanuc_robodrill.jpg',
        icon: Icons.smart_toy_outlined,
        stages: _stages(),
      ),
      Order(
        reference: '#ORD-71044',
        placedOn: 'Sep 12, 2026',
        title: 'Terraform Gen-SET 500',
        status: OrderStatus.delivered,
        location: 'Chennai Plant',
        note: 'Quality Verified',
        items: const [],
        subtotal: 4200000,
        freight: 5370,
        gst: 756966.6,
        total: 4962336.6,
        equipmentType: 'Power Generation Unit',
        logisticsMode: 'Expedited Freight',
        thumbnail: '$_photos/okuma_genos.jpg',
        icon: Icons.bolt_outlined,
        stageIndex: 8,
        stages: _stages(),
      ),
      Order(
        reference: '#ORD-66310',
        placedOn: 'Aug 05, 2026',
        title: 'Laser-Cut V3 Pro',
        status: OrderStatus.cancelled,
        location: 'Rajkot Works',
        note: 'Replaced by ORD-772',
        items: const [],
        subtotal: 3150000,
        freight: 5370,
        gst: 567966.6,
        total: 3723336.6,
        equipmentType: 'Laser Cutting System',
        logisticsMode: 'Standard Freight',
        thumbnail: '$_photos/dmg_mori_nhx.jpg',
        icon: Icons.flare_outlined,
        stages: _stages(),
      ),
    ]);
    notifyListeners();
  }

  String _reference(CartStore cart) {
    final seed = cart.items.fold<int>(
      cart.count * 7919,
      (hash, item) => hash * 31 + item.product.title.hashCode,
    );
    return '#CP-${seed.abs() % 90000 + 10000}';
  }

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _today() {
    final now = DateTime.now();
    return '${_months[now.month - 1].substring(0, 3)} '
        '${now.day.toString().padLeft(2, '0')}, ${now.year}';
  }

  String _stamp() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '${_months[now.month - 1].substring(0, 3)} ${now.day}, '
        '$hour:$minute $period';
  }

  /// The tracking timeline, shared with orders rebuilt from the API.
  List<TrackingStage> timelineStages() => _stages();

  List<TrackingStage> _stages() {
    return [
      TrackingStage(
        title: 'Inquiry Received',
        icon: Icons.check,
        stamp: _stamp(),
        detail:
            'Your industrial machine inquiry has been logged. Our '
            'technical sourcing team is reviewing the specifications for '
            'compatibility.',
      ),
      const TrackingStage(
        title: 'Under Review',
        icon: Icons.pending_outlined,
        detail:
            'Detailed audit of manufacturing capability and lead times is '
            'currently in progress. Estimated completion: Today, 5:00 PM.',
      ),
      const TrackingStage(
        title: 'Broker Contacting You',
        icon: Icons.headset_mic_outlined,
        detail:
            'A dedicated equipment specialist will reach out to finalize '
            'logistics details.',
      ),
      const TrackingStage(title: 'Price Confirmed', icon: Icons.currency_rupee),
      const TrackingStage(
        title: 'Machine Reserved',
        icon: Icons.bookmark_border,
      ),
      const TrackingStage(title: 'Order Confirmed', icon: Icons.task_alt),
      const TrackingStage(
        title: 'Delivery Scheduled',
        icon: Icons.local_shipping_outlined,
      ),
      const TrackingStage(title: 'Delivered', icon: Icons.place_outlined),
    ];
  }
}
