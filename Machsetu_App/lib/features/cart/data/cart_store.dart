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
