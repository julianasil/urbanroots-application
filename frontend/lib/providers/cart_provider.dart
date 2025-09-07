import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final int userId; // optional for now
  Map<int, CartItem> _items = {}; // key = productId

  CartProvider({required this.userId});

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount => _items.values
      .fold(0.0, (sum, item) => sum + item.price * item.quantity);

  void addItem(int productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += 1;
    } else {
      _items[productId] = CartItem(
        id: productId.toString(),
        title: title,
        quantity: 1,
        price: price,
      );
    }
    notifyListeners();
  }

  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
