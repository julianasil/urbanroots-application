import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  /// Adds a new order from the given cart items + total
  void addOrder(List<CartItem> cartItems, double total) {
    final newOrder = Order(
      id: DateTime.now().toIso8601String(),
      items: cartItems,
      total: total,
      dateTime: DateTime.now(),
    );
    _orders.insert(0, newOrder);
    notifyListeners();
  }
}
