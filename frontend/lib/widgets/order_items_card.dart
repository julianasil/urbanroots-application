import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderItemsCard extends StatelessWidget {
  final List<OrderItem> items;
  const OrderItemsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Products Ordered', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Divider(),
            ...items.map((item) {
              String? fullImageUrl;
              final imagePath = item.product?.image;
              if (imagePath != null && imagePath.isNotEmpty) {
                if (imagePath.startsWith('http')) {
                  // If it's already a full URL, use it as is.
                  fullImageUrl = imagePath;
                } else {
                  // If it's a relative path, prepend the base server URL.
                  fullImageUrl = 'http://127.0.0.1:8000$imagePath';
                }
              }
              return ListTile(
                leading: SizedBox(
                  width: 50, // Give the image a fixed size
                  child: (fullImageUrl != null)
                      ? Image.network(fullImageUrl) // Use the corrected URL
                      : const Icon(Icons.image_not_supported),
                ),
                title: Text(item.product?.name ?? 'Product Not Found'),
                subtitle: Text('${item.quantity} x ₱${item.priceAtPurchase.toStringAsFixed(2)}'),
                trailing: Text('₱${(item.quantity * item.priceAtPurchase).toStringAsFixed(2)}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}