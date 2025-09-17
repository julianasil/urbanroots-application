// frontend/lib/widgets/order_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../screens/order_detail_screen.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isSellerView;

  const OrderCard({super.key, required this.order, this.isSellerView = false});

  // Helper to get a display-friendly status title
  String get _statusTitle {
    switch (order.status.toLowerCase()) {
      case 'pending': return "PENDING";
      case 'confirmed': return "CONFIRMED";
      case 'shipped': return "SHIPPED";
      case 'completed': return "DELIVERED";
      case 'cancelled': return "CANCELLED";
      default: return "ORDERED";
    }
  }

  // Helper to get a status color
  Color get _statusColor {
    switch (order.status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'shipped': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the first item in the order to show its image as a preview
    final firstItemImage = order.items.isNotEmpty 
      ? order.items.first.product?.image 
      : null;

    final String? fullImageUrl = firstItemImage != null && firstItemImage.isNotEmpty
      ? 'http://127.0.0.1:8000$firstItemImage'
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
            Text(_statusTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              'Order Date: ${DateFormat('dd MMM, yyyy').format(order.orderDate)}',
              style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // --- Item Preview and Details ---
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: firstItemImage != null
                        ? DecorationImage(image: NetworkImage(firstItemImage), fit: BoxFit.cover)
                        : null,
                  ),
                  child: firstItemImage == null ? const Icon(Icons.image_not_supported, color: Colors.grey) : null,
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
            const Divider(height: 24),

            // --- Action Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () { 
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => OrderDetailScreen(
                            orderId: order.orderId,
                            isSellerView: isSellerView,
                          ),
                        ),
                      );
                    },
                    child: const Text('View Order'),
                  ),
                ),
                const SizedBox(width: 12),
                if (order.status.toLowerCase() == 'shipped' || order.status.toLowerCase() == 'completed')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () { /* TODO: Navigate to Tracking Page */ },
                      child: const Text('TRACK PARCEL'),
                    ),
                  )
                else if (order.status.toLowerCase() == 'pending')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        // Show a confirmation dialog before proceeding
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: const Text('Do you want to cancel this order? This action cannot be undone.'),
                            actions: [
                              TextButton(child: const Text('No'), onPressed: () => Navigator.of(ctx).pop(false)),
                              TextButton(
                                child: const Text('Yes, Cancel'),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          ),
                        );

                        // If the user did not confirm, do nothing.
                        if (confirm != true) return;

                        // If confirmed, call the provider to cancel the order.
                        try {
                          await Provider.of<OrderProvider>(context, listen: false)
                              .cancelOrder(order.orderId);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order has been cancelled.'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                      child: const Text('CANCEL ORDER'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}