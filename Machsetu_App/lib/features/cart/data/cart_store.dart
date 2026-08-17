import 'package:flutter/foundation.dart';

import '../../../core/services/settings_service.dart';
import '../../product/data/product.dart';

class CartItem {
  const CartItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}

/// In-memory cart shared by the product page, the Cart tab and the nav badge.
///
/// Not persisted — reopening the app starts with an empty cart. Move this
/// behind the orders API (or SessionStore) when checkout becomes real.
class CartStore extends ChangeNotifier {
  CartStore._();

  static final CartStore instance = CartStore._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  bool contains(Product product) =>
      _items.any((item) => item.product.title == product.title);

  /// Sum of unit price × quantity across every line.
  double get subtotal => _items.fold(
    0,
    (sum, item) => sum + (item.product.amount * item.quantity),
  );

  /// Fee percentages set on the admin panel's Settings page.
  Commercials get _rates => SettingsService.instance.commercials;

  /// Freight estimate as a share of the goods value, waived on an empty cart.
  double get shipping =>
      _items.isEmpty ? 0 : subtotal * _rates.shippingRate / 100;

  double get brokerage =>
      _items.isEmpty ? 0 : subtotal * _rates.brokerageRate / 100;

  /// Shipping and brokerage combined — checkout shows them as one line, so
  /// this keeps its total identical to the cart's.
  double get freight => shipping + brokerage;

  /// GST as a fraction, e.g. 0.18. Drives the "GST (18%)" labels too.
  double get gstRate => _rates.gstRate / 100;

  /// GST applies to the goods plus the service charges, matching the quote
  /// sheet buyers receive.
  double get gst => (subtotal + shipping + brokerage) * gstRate;

  /// Rate as it appears in a label, without a trailing ".0".
  String get gstLabel {
    final rate = _rates.gstRate;
    final text = rate == rate.roundToDouble()
        ? rate.toStringAsFixed(0)
        : rate.toStringAsFixed(1);
    return '$text%';
  }

  double get total => subtotal + shipping + brokerage + gst;

  /// Stable per-basket reference shown on the summary card.
  String get transactionId {
    final seed = _items.fold<int>(
      count,
      (hash, item) => hash * 31 + item.product.title.hashCode,
    );
    return '#IN-${(seed.abs() % 900000 + 100000)}';
  }

  /// Checkout-facing reference for the same basket.
  String get orderReference =>
      '#ORD-2026-${transactionId.substring(transactionId.length - 4)}';

  /// Adds the machine, or bumps its quantity when it is already in the cart.
  void add(Product product) {
    final index = _items.indexWhere((i) => i.product.title == product.title);
    if (index == -1) {
      _items.add(CartItem(product: product));
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    }
    notifyListeners();
  }

  /// Drops the quantity by one, removing the line when it reaches zero.
  void decrement(Product product) {
    final index = _items.indexWhere((i) => i.product.title == product.title);
    if (index == -1) return;

    final quantity = _items[index].quantity - 1;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void remove(Product product) {
    _items.removeWhere((i) => i.product.title == product.title);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
