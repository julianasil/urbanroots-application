// frontend/lib/widgets/sale_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../screens/manage_shipment_screen.dart';
import '../screens/shipment_detail_screen.dart';

class SaleCard extends StatelessWidget {
  final Order sale;
  const SaleCard({super.key, required this.sale});

  String get _statusTitle {
    switch (sale.status.toLowerCase()) {
      case 'pending': return "New Sale - Action Required";
      case 'processing': return "Processing";
      case 'confirmed': return "Processing";
      case 'shipped': return "Shipped";
      case 'completed': return "Completed";
      case 'cancelled': return "Cancelled";
      default: 
        print("DEBUG: Encountered unknown sale status: '${sale.status}'");
        return sale.status.toUpperCase();
    }
  }

  Color get _statusColor {
    switch (sale.status.toLowerCase()) {
      case 'pending': return Colors.red;
      case 'processing': return Colors.orange;
      case 'shipped': return Colors.blue;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- THIS IS THE MISSING UI LOGIC ---
    final buyerName = sale.buyerProfile?.companyName ?? 'Unknown Buyer';
    final firstItem = sale.items.isNotEmpty ? sale.items.first.product : null;
    final fullImageUrl = firstItem?.image != null && firstItem!.image!.isNotEmpty
        ? (firstItem.image!.startsWith('http') ? firstItem.image! : 'http://127.0.0.1:8000${firstItem.image}')
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Status Header ---
            Text('SALE STATUS', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              _statusTitle.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _statusColor),
            ),
            const SizedBox(height: 4),
            Text('Order Date: ${DateFormat('dd MMM, yyyy').format(sale.orderDate)}'),
            const Divider(height: 24),

            // --- Item Preview and Buyer Details ---
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: fullImageUrl != null ? DecorationImage(image: NetworkImage(fullImageUrl), fit: BoxFit.cover) : null,
                  ),
                  child: fullImageUrl == null ? const Icon(Icons.image_not_supported, color: Colors.grey) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ORDER NO.: ${sale.orderId.substring(0, 8).toUpperCase()}'),
                      Text('BUYER: $buyerName'),
                      Text('${sale.items.length} item(s)'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Action Buttons ---
            _buildActionButtons(context, sale),
          ],
        ),
      ),
    );
  }

  // --- THIS IS THE CORRECTED WIDGET BUILDER ---
  Widget _buildActionButtons(BuildContext context, Order sale) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final textStyle = TextStyle(color: Theme.of(context).primaryColor);

    Widget actionButton;

    switch (sale.status.toLowerCase()) {
      case 'pending':
        actionButton = ElevatedButton(
          onPressed: () async {
            try {
              // This correctly changes the status from 'pending' to 'processing'
              await orderProvider.manageSale(sale.orderId, newStatus: 'processing');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Confirmed! Ready for shipment.')));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.orange,
          ),
          child: const Text('CONFIRM ORDER'),
        );
        break;

      case 'processing': // The status after confirming is 'processing'
        actionButton = ElevatedButton(
          onPressed: () {
            // --- THIS IS THE FIX ---
            // This button now navigates to the ManageShipmentScreen.
            Navigator.of(context).push(
              MaterialPageRoute(
                // We pass the 'sale' (which is an Order object) to the new screen's constructor.
                builder: (ctx) => ManageShipmentScreen(order: sale),
              ),
            );
          },
          child: const Text('CREATE SHIPMENT'),
        );
        break;

      case 'shipped':
        actionButton = OutlinedButton.icon(
          icon: const Icon(Icons.local_shipping, size: 18),
          label: Text('SHIPMENT DETAILS', style: textStyle),
          onPressed: () { if (sale.shipments.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ShipmentDetailScreen(
                    order: sale,
                    shipment: sale.shipments.first, // Pass the first shipment
                  ),
                ),
              );
            }
          },
        );
        break;

      default: // For completed or cancelled orders
        actionButton = OutlinedButton(
          onPressed: () { /* TODO: Navigate to Sale Detail Screen */ },
          child: Text('VIEW DETAILS', style: textStyle),
        );
    }
    
    return Row(
      children: [Expanded(child: actionButton)],
    );
  }
}