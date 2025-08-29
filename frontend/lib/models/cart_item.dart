// lib/models/cart_item.dart
class CartItem {
  final String id; // unique id for the cart entry (not the product id)
  final String title;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });
}
