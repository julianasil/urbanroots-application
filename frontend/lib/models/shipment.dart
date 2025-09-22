// frontend/lib/models/shipment.dart
import 'order.dart'; // We'll need the OrderItem

class LogisticsProvider {
  final String providerId;
  final String name;
  final String? trackingUrlTemplate;

  LogisticsProvider({
    required this.providerId,
    required this.name,
    this.trackingUrlTemplate,
  });

  factory LogisticsProvider.fromJson(Map<String, dynamic> json) {
    return LogisticsProvider(
      providerId: json['provider_id'],
      name: json['name'],
      trackingUrlTemplate: json['tracking_url_template'],
    );
  }
}

class Shipment {
  final String shipmentId;
  final String orderId;
  final String sellerProfileId;
  final LogisticsProvider? logisticsProvider;
  final String? trackingNumber;
  final String status;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
  // This will hold the specific items included in THIS shipment
  final List<OrderItem> items;

  Shipment({
    required this.shipmentId,
    required this.orderId,
    required this.sellerProfileId,
    this.logisticsProvider,
    this.trackingNumber,
    required this.status,
    this.shippedDate,
    this.deliveredDate,
    required this.items,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItem> parsedItems = itemsList.map((i) => OrderItem.fromJson(i)).toList();
    
    return Shipment(
      shipmentId: json['shipment_id'],
      orderId: json['order'], // The API sends the order UUID here
      sellerProfileId: json['seller_profile'], // The API sends the profile UUID
      logisticsProvider: json['logistics_provider'] != null
        ? LogisticsProvider.fromJson(json['logistics_provider'])
        : null,
      trackingNumber: json['tracking_number'],
      status: json['status'],
      shippedDate: json['shipped_date'] != null ? DateTime.parse(json['shipped_date']) : null,
      deliveredDate: json['delivered_date'] != null ? DateTime.parse(json['delivered_date']) : null,
      items: parsedItems,
    );
  }
}