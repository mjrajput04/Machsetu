import 'package:flutter/material.dart';

import '../../cart/data/cart_store.dart';

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
    required this.items,
    required this.subtotal,
    required this.freight,
    required this.gst,
    required this.total,
    required this.equipmentType,
    required this.logisticsMode,
    required this.stages,
    this.stageIndex = 1,
  });

  /// Buyer-facing order number, e.g. `#CP-99203`.
  final String reference;

  /// Pre-formatted placement date, e.g. `October 24, 2026`.
  final String placedOn;
  final List<CartItem> items;
  final double subtotal;
  final double freight;
  final double gst;
  final double total;
  final String equipmentType;
  final String logisticsMode;
  final List<TrackingStage> stages;

  /// Index of the stage currently in progress; everything before it is done.
  final int stageIndex;

  /// Longer id used on the tracking screen, e.g. `#CP-99203-AX`.
  String get trackingId => '$reference-AX';

  /// Headline machine for the order summary line.
  String get headline =>
      items.isEmpty ? 'Industrial equipment' : items.first.product.title;

  /// Name of the last completed stage — drives the status banner.
  String get currentStatus =>
      stages[(stageIndex - 1).clamp(0, stages.length - 1)].title;
}

/// In-memory order history.
///
/// Not persisted — placed orders are lost on restart. Move this behind the
/// orders API when the backend exists.
class OrderStore extends ChangeNotifier {
  OrderStore._();

  static final OrderStore instance = OrderStore._();

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  bool get isEmpty => _orders.isEmpty;

  /// Snapshots the cart into a new order. The caller clears the cart.
  Order place(CartStore cart) {
    final first = cart.items.isEmpty ? null : cart.items.first.product;

    final order = Order(
      reference: _reference(cart),
      placedOn: _today(),
      items: List.of(cart.items),
      subtotal: cart.subtotal,
      freight: cart.freight,
      gst: cart.gst,
      total: cart.total,
      equipmentType: first?.equipmentType ?? 'Industrial Equipment',
      logisticsMode: 'Expedited Freight',
      stages: _stages(),
    );

    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  void clear() {
    _orders.clear();
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
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _stamp() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '${_months[now.month - 1].substring(0, 3)} ${now.day}, '
        '$hour:$minute $period';
  }

  List<TrackingStage> _stages() {
    return [
      TrackingStage(
        title: 'Inquiry Received',
        icon: Icons.check,
        stamp: _stamp(),
        detail: 'Your industrial machine inquiry has been logged. Our '
            'technical sourcing team is reviewing the specifications for '
            'compatibility.',
      ),
      const TrackingStage(
        title: 'Under Review',
        icon: Icons.pending_outlined,
        detail: 'Detailed audit of manufacturing capability and lead times is '
            'currently in progress. Estimated completion: Today, 5:00 PM.',
      ),
      const TrackingStage(
        title: 'Broker Contacting You',
        icon: Icons.headset_mic_outlined,
        detail: 'A dedicated equipment specialist will reach out to finalize '
            'logistics details.',
      ),
      const TrackingStage(
        title: 'Price Confirmed',
        icon: Icons.currency_rupee,
      ),
      const TrackingStage(
        title: 'Machine Reserved',
        icon: Icons.bookmark_border,
      ),
      const TrackingStage(
        title: 'Order Confirmed',
        icon: Icons.task_alt,
      ),
      const TrackingStage(
        title: 'Delivery Scheduled',
        icon: Icons.local_shipping_outlined,
      ),
      const TrackingStage(
        title: 'Delivered',
        icon: Icons.place_outlined,
      ),
    ];
  }
}
