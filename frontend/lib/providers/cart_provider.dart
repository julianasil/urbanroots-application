// frontend/lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  // We can keep userId as a placeholder for now.
  final String userId;
  
  // --- FIX #1: Change the map key from int to String ---
  // The key will now be the Product's UUID (productId).
  Map<String, CartItem> _items = {};

  CartProvider({required this.userId});

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount => _items.values
      .fold(0.0, (sum, item) => sum + item.price * item.quantity);

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      // If the item is already in the cart, increase its quantity.
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // If it's a new item, add it to the cart.
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(), // Use a unique ID for the cart item itself
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      // If quantity is more than 1, just decrease it.
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      // If quantity is 1, remove the item completely.
      _items.remove(productId);
    }
    notifyListeners();
  }

  // --- FIX #2: Add the missing removeItem method ---
  /// Removes an entire item from the cart, regardless of its quantity.
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }


  void clear() {
    _items = {};
    notifyListeners();
  }
}