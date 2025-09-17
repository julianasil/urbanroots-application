// frontend/lib/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../widgets/order_progress_stepper.dart';
import '../widgets/order_items_card.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final bool isSellerView;

  const OrderDetailScreen({super.key, required this.orderId, this.isSellerView = false});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<Order> _orderFuture;

  @override
  void initState() {
    super.initState();
    if (widget.isSellerView) {
      _orderFuture = ApiService().getSaleDetails(widget.orderId);
    } else {
      _orderFuture = ApiService().getOrderDetails(widget.orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: FutureBuilder<Order>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Could not load order details.'));
          }

          final order = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Order ID
                Text('#S-${order.orderId.substring(0, 8).toUpperCase()}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // Main content in a Row for larger screens, Column for smaller
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) { // Example breakpoint for web/tablet
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildLeftColumn(order),
                          ),
                          const SizedBox(width: 24),
                        ],
                      );
                    } else { // Mobile layout
                      return Column(
                        children: [
                          _buildLeftColumn(order),
                        ],
                      );
                    }
                  }
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper to build the left column of the layout
  Widget _buildLeftColumn(Order order) {
    return Column(
      children: [
        OrderProgressStepper(currentStatus: order.status),
        const SizedBox(height: 24),
        OrderItemsCard(items: order.items),
        // Add a Timeline card later if needed
      ],
    );
  }
}