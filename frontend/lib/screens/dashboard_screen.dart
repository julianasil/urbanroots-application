// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import 'edit_product_screen.dart';
import 'orders_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _shortId(String id) {
    return id.length > 8 ? id.substring(0, 8) : id;
  }

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);
    final cartProv = Provider.of<CartProvider>(context);
    final userProv = Provider.of<UserProvider>(context);

    final productsCount = productProv.items.length;
    final ordersCount = orderProv.orders.length;
    final cartCount = cartProv.items.length;
    final totalSales = orderProv.orders.fold<double>(
      0.0,
      (prev, order) => prev + (order.total ?? 0.0),
    );

    final recentOrders = orderProv.orders.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Make the whole body scrollable to avoid overflow on small screens
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top greeting + quick info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        (userProv.currentUser?.fullName ?? 'User')
                            .split(' ')
                            .first[0]
                            .toUpperCase(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${userProv.currentUser?.fullName ?? 'Guest'}',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Here is a quick summary of your store',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const EditProductScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      tooltip: 'Add product',
                    )
                  ],
                ),

                const SizedBox(height: 16),

                // Stats grid (shrinkWrap-style via a fixed-height GridView alternative)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: [
                    _StatCard(
                      title: 'Products',
                      value: productsCount.toString(),
                      icon: Icons.storefront,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'Orders',
                      value: ordersCount.toString(),
                      icon: Icons.receipt_long,
                      color: Colors.purple,
                    ),
                    _StatCard(
                      title: 'In Cart',
                      value: cartCount.toString(),
                      icon: Icons.shopping_cart,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Total Sales',
                      value: '₱${totalSales.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Actions row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const EditProductScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_box_outlined),
                        label: const Text('Add Product'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const OrdersScreen()),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('View Orders'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Recent orders header
                Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Recent orders list: make it shrinkWrap so the outer SingleChildScrollView handles scrolling.
                recentOrders.isEmpty
                    ? SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            'No orders yet.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentOrders.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (ctx, i) {
                          final order = recentOrders[i];
                          final formattedDate = order.dateTime != null
                              ? order.dateTime.toLocal().toString().split(' ')[0]
                              : '';
                          final itemsCount = (order.items ?? []).length;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              child: Text(_shortId(order.id)),
                            ),
                            title:
                                Text('₱${(order.total ?? 0.0).toStringAsFixed(2)}'),
                            subtitle: Text('$itemsCount items • $formattedDate'),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, size: 16),
                              onPressed: () {
                                // optional: open order details screen later
                              },
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
