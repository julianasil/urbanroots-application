// frontend/lib/screens/shipment_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart'; // We'll pass the Order to get context
import '../models/shipment.dart'; // We'll pass the Shipment to display
//import '../services/api_service.dart';

class ShipmentDetailScreen extends StatelessWidget {
  final Order order;
  final Shipment shipment;

  const ShipmentDetailScreen({
    super.key,
    required this.order,
    required this.shipment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoCard('Order Number', order.orderId.substring(0, 8).toUpperCase()),
          _buildInfoCard('Status', shipment.status.toUpperCase()),
          _buildInfoCard('Tracking Number', shipment.trackingNumber ?? 'Not available'),
          _buildInfoCard('Logistics Provider', shipment.logisticsProvider?.name ?? 'Not specified'),
          _buildInfoCard('Shipped On', 
            shipment.shippedDate != null 
              ? DateFormat('dd MMM, yyyy').format(shipment.shippedDate!)
              : 'Not yet shipped'
          ),
          const Divider(height: 32),
          Text('Items in this Shipment', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: shipment.items.map((item) {
                // Safely get product name and image
                final productName = item.product?.name ?? 'Product Not Found';
                final imageUrl = item.product?.image;
                final fullImageUrl = imageUrl != null && imageUrl.isNotEmpty
                    ? (imageUrl.startsWith('http') ? imageUrl : 'http://1227.0.0.1:8000$imageUrl')
                    : null;

                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: fullImageUrl != null
                      ? Image.network(fullImageUrl, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  ),
                  title: Text(productName),
                  subtitle: Text('₱${item.priceAtPurchase.toStringAsFixed(2)}'),
                  trailing: Text('Qty: ${item.quantity}'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to create consistent info cards
  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }
}