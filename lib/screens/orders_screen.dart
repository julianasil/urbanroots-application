import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context);
    final orders = orderData.orders;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: orders.isEmpty
          ? const Center(child: Text('No orders placed yet.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (ctx, i) {
                final Order order = orders[i];
                return ExpansionTile(
                  title: Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${order.dateTime.toLocal()}'.split(' ')[0],
                  ),
                  children: order.items.map((cartItem) {
                    return ListTile(
                      title: Text(cartItem.title),
                      trailing: Text(
                        '${cartItem.quantity} x \$${cartItem.price.toStringAsFixed(2)}',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
