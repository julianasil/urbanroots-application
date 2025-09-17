import 'product.dart';

class OrderItem {
  final String orderItemId;
  // Use a simplified Product object for display within an order
  final Product? product; 
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    required this.orderItemId,
    required this.product,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['order_item_id'] as String? ?? '',
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      quantity: json['quantity'] as int? ?? 0,
      priceAtPurchase: double.tryParse(json['price_at_purchase'].toString()) ?? 0.0,
    );
  }
}

class Order {
  final String orderId;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final String? trackingNumber;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    this.trackingNumber,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<OrderItem> parsedItems = itemsList.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      orderId: json['order_id'] as String? ?? '',
      orderDate: DateTime.tryParse(json['order_date'] ?? '') ?? DateTime.now(),
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: json['status'] as String? ?? 'Unknown',
      shippingAddress: json['shipping_address'] as String? ?? 'No address yet',
      trackingNumber: json['tracking_number'],
      items: parsedItems,
    );
  }
}