import 'package:flutter/foundation.dart';

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

  /// Flat freight estimate, waived on an empty cart.
  double get shipping => _items.isEmpty ? 0 : 4250;

  double get brokerage => _items.isEmpty ? 0 : 1120;

  static const double gstRate = 0.18;

  /// GST applies to the goods plus the service charges, matching the quote
  /// sheet buyers receive.
  double get gst => (subtotal + shipping + brokerage) * gstRate;

  double get total => subtotal + shipping + brokerage + gst;

  /// Stable per-basket reference shown on the summary card.
  String get transactionId {
    final seed = _items.fold<int>(
      count,
      (hash, item) => hash * 31 + item.product.title.hashCode,
    );
    return '#IN-${(seed.abs() % 900000 + 100000)}';
  }

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
