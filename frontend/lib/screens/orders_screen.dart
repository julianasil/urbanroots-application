// frontend/lib/screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<void> _ordersFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching orders as soon as the screen is created.
    _ordersFuture = Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (dataSnapshot.error != null) {
            return const Center(child: Text('An error occurred!'));
          } else {
            // Use a Consumer to get the list of orders from the provider.
            return Consumer<OrderProvider>(
              builder: (ctx, orderData, child) {
                final orders = orderData.orders;
                return orders.isEmpty
                    ? const Center(child: Text('No orders placed yet.'))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (ctx, i) {
                          final Order order = orders[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ExpansionTile(
                              // --- FIX #1: Use 'totalAmount' ---
                              title: Text(
                                '₱${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              // --- FIX #2: Use 'orderDate' and format it ---
                              subtitle: Text(
                                DateFormat('MMMM dd, yyyy').format(order.orderDate),
                              ),
                              // Display the order status
                              trailing: Text(
                                order.status.capitalize(),
                                style: TextStyle(color: _getStatusColor(order.status)),
                              ),
                              children: order.items.map((orderItem) {
                                final productName = orderItem.product?.name ?? 'Product Not Found';
                                return ListTile(
                                  // --- FIX #3: Access the product name ---
                                  title: Text(productName),
                                  // --- FIX #4: Use 'priceAtPurchase' ---
                                  trailing: Text(
                                    '${orderItem.quantity} x ₱${orderItem.priceAtPurchase.toStringAsFixed(2)}',
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      );
              },
            );
          }
        },
      ),
    );
  }

  // Helper function to color the status text
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'shipped': return Colors.blue;
      case 'cancelled': return Colors.red;
      case 'confirmed': return Colors.orange;
      default: return Colors.grey;
    }
  }
}

// You will need this extension if you haven't defined it elsewhere
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}