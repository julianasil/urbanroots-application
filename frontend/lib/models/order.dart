// frontend/lib/models/order.dart
import 'product.dart';
import 'user_profile.dart';
import 'shipment.dart';

class OrderItem {
  final String orderItemId;
  final Product? product; 
  final BusinessProfile? sellerProfile;
  final int quantity;
  final double priceAtPurchase;
  final String status;
  final String? shipmentId;

  OrderItem({
    required this.orderItemId,
    this.product,
    this.sellerProfile,
    required this.quantity,
    required this.priceAtPurchase,
    required this.status,
    this.shipmentId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['order_item_id'] as String? ?? '',
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      sellerProfile: json['seller_profile'] != null
        ? BusinessProfile.fromJson(json['seller_profile'])
        : null,
      quantity: json['quantity'] as int? ?? 0,
      priceAtPurchase: double.tryParse(json['price_at_purchase'].toString()) ?? 0.0,
      status: json['status'] as String? ?? 'processing',
      shipmentId: json['shipment'] as String?,
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
  final BusinessProfile? buyerProfile;
  final List<Shipment> shipments;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    this.trackingNumber,
    required this.items,
    this.buyerProfile,
    required this.shipments,
  });

  Order copyWith({
    String? orderId,
    DateTime? orderDate,
    double? totalAmount,
    String? status,
    String? shippingAddress,
    String? trackingNumber,
    List<OrderItem>? items,
    BusinessProfile? buyerProfile,
    List<Shipment>? shipments,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      items: items ?? this.items,
      buyerProfile: buyerProfile ?? this.buyerProfile,
      shipments: shipments ?? this.shipments,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<OrderItem> parsedItems = itemsList.map((i) => OrderItem.fromJson(i)).toList();

    var shipmentsList = json['shipments'] as List? ?? [];
    List<Shipment> parsedShipments = shipmentsList.map((i) => Shipment.fromJson(i)).toList();

    return Order(
      orderId: json['order_id'] as String? ?? '',
      orderDate: DateTime.tryParse(json['order_date'] ?? '') ?? DateTime.now(),
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: json['status'] as String? ?? 'Unknown',
      shippingAddress: json['shipping_address'] as String? ?? 'No address yet',
      trackingNumber: json['tracking_number'],
      items: parsedItems,
      buyerProfile: json['buyer_profile'] != null
        ? BusinessProfile.fromJson(json['buyer_profile'])
        : null,
      shipments: parsedShipments,
    );
  }
}