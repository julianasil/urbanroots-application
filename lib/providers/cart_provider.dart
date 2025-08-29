// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  // _items map: key is productId, value is CartItem
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((_, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  /// Add an item to the cart. If the item exists, increment quantity.
  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      // update quantity
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      // add new
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toIso8601String(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  /// Remove the entire entry for a productId
  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  /// Remove a single quantity of the given product.
  /// If quantity becomes 0, remove the item.
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    final existing = _items[productId]!;
    if (existing.quantity > 1) {
      _items.update(
        productId,
        (old) => CartItem(
          id: old.id,
          title: old.title,
          price: old.price,
          quantity: old.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  /// Clear the cart
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
