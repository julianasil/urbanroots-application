// frontend/lib/widgets/order_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../services/api_service.dart';
import '../screens/order_detail_screen.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  // Constructor is simplified; it's now only for buyers.
  const OrderCard({super.key, required this.order});

  // Helper to get a display-friendly status title
  String get _statusTitle {
    switch (order.status.toLowerCase()) {
      case 'pending': return "Order Placed";
      case 'confirmed': return "Processing";
      case 'processing': return "Processing";
      case 'shipped': return "Shipped";
      case 'completed': return "Delivered";
      case 'cancelled': return "Cancelled";
      default: return "Ordered";
    }
  }

  // Helper to get a status color
  Color get _statusColor {
    switch (order.status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'shipped': return Colors.blue;
      case 'cancelled': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  // Helper to launch the tracking URL
  Future<void> _trackParcel(BuildContext context, String trackingNumber, String? trackingUrlTemplate) async {
    if (trackingUrlTemplate == null || trackingUrlTemplate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tracking URL not available for this provider.')));
      return;
    }
    final Uri url = Uri.parse('$trackingUrlTemplate$trackingNumber');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open tracking page.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstItemImage = order.items.isNotEmpty ? order.items.first.product?.image : null;
    final fullImageUrl = firstItemImage != null && firstItemImage.isNotEmpty
      ? (firstItemImage.startsWith('http') ? firstItemImage : 'http://127.0.0.1:8000$firstItemImage')
      : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Status Header ---
            Text('ORDER STATUS:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 4),
            Text(_statusTitle.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              'Order Date: ${DateFormat('dd MMM, yyyy').format(order.orderDate)}',
              style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),

            // --- Item Preview and Details ---
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: fullImageUrl != null
                        ? DecorationImage(image: NetworkImage(fullImageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: fullImageUrl == null ? const Icon(Icons.image_not_supported, color: Colors.grey) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ORDER NO.: ${order.orderId.substring(0, 8).toUpperCase()}'),
                      Text('TOTAL: ₱${order.totalAmount.toStringAsFixed(2)}'),
                      Text('${order.items.length} item(s)'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Action Buttons ---
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }
  
  // --- Helper widget for BUYER-specific action buttons ---
  Widget _buildActionButtons(BuildContext context) {
    final status = order.status.toLowerCase();
    // For simplicity, we'll still assume the first shipment is the primary one
    final shipment = order.shipments.isNotEmpty ? order.shipments.first : null;

    // --- PENDING State ---
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: () { /* Navigate to detail */ }, child: const Text('VIEW ORDER'))),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () async { /* ... Your existing cancel logic ... */ },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
              child: const Text('CANCEL ORDER'),
            ),
          ),
        ],
      );
    }

    // --- SHIPPED State ---
    if (status == 'shipped' && shipment != null) {
      return Column( // Use a Column for multiple actions
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService().confirmDelivery(shipment.shipmentId);
                  await Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery Confirmed!'), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('CONFIRM DELIVERY'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _trackParcel(context, shipment.trackingNumber!, shipment.logisticsProvider?.trackingUrlTemplate),
              child: const Text('TRACK PARCEL'),
            ),
          ),
        ],
      );
    }

    // --- DELIVERED / COMPLETED State ---
    if ((status == 'completed' || status == 'delivered') && shipment != null) {
       return Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: () { /* Navigate to detail */ }, child: const Text('VIEW ORDER'))),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _trackParcel(context, shipment.trackingNumber!, shipment.logisticsProvider?.trackingUrlTemplate),
              child: const Text('TRACK PARCEL'),
            ),
          ),
        ],
      );
    }

    // --- PROCESSING / CANCELLED / OTHER State ---
    // For all other cases, just show a single "View Order" button.
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => OrderDetailScreen(orderId: order.orderId)));
            },
            child: const Text('VIEW ORDER'),
          ),
        ),
      ],
    );
  }
}