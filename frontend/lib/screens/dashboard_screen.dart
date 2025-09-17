// frontend/lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../screens/product/edit_product_screen.dart';
import 'orders_screen.dart';
import '../widgets/order_card.dart';  // Import the new, styled order card

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //late Future<void> _dataLoadingFuture;

  void initState() {
    super.initState();
    // Use a post-frame callback to ensure the context is ready before fetching.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Call the provider methods to fetch initial data.
      // We don't need to await them here. The UI will update via the Consumer.
      Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }
  
  // A single method to fetch all necessary data for the dashboard
  Future<void> _refreshData(BuildContext context) async {
    // We can call both fetches in parallel for a faster refresh.
    await Future.wait([
      Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders(),
      Provider.of<ProductProvider>(context, listen: false).loadProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer widgets to get the latest data from providers and rebuild the UI
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final cartProv = Provider.of<CartProvider>(context);
    
    // Get fullName from the UserProfile object for better consistency
    final fullName = userProv.user?.fullName ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(context), // Pull-to-refresh calls the same load method
          child: SingleChildScrollView(
            // Always allow scrolling to prevent overflow on small devices
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Greeting Section ---
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Text((fullName.isNotEmpty ? fullName[0] : 'G').toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $fullName',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Here is a quick summary of your store'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProductScreen()));
                      },
                      icon: const Icon(Icons.add),
                      tooltip: 'Add product',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Stats Grid Section ---
                // Use Consumers to ensure these stats update when data changes
                Consumer2<ProductProvider, OrderProvider>(
                  builder: (context, productData, orderData, child) {
                    final totalSales = orderData.orders.fold<double>(0.0, (prev, order) => prev + order.totalAmount);
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.2,
                      children: [
                        _StatCard(title: 'Products', value: productData.items.length.toString(), icon: Icons.storefront, color: Colors.blue),
                        _StatCard(title: 'Orders', value: orderData.orders.length.toString(), icon: Icons.receipt_long, color: Colors.purple),
                        _StatCard(title: 'In Cart', value: cartProv.itemCount.toString(), icon: Icons.shopping_cart, color: Colors.orange),
                        _StatCard(title: 'Total Sales', value: '₱${totalSales.toStringAsFixed(2)}', icon: Icons.attach_money, color: Colors.green),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // --- Action Buttons Section ---
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProductScreen()));
                        },
                        icon: const Icon(Icons.add_box_outlined),
                        label: const Text('Add Product'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersScreen()));
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('View Orders'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Recent Orders Section ---
                Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Use a Consumer for the order list to handle loading and empty states
                Consumer<OrderProvider>(
                  builder: (context, orderData, child) {
                    // 1. Check if the provider is currently loading data
                    if (orderData.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // 2. Check if there was an error during the fetch
                    if (orderData.error != null) {
                      return Center(child: Text('An error occurred: ${orderData.error}'));
                    }
                    // 3. Check if the orders list is empty
                    if (orderData.orders.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No recent orders found.')));
                    }
                    
                    // 4. If we have data, display it
                    final recentOrders = orderData.orders.take(3).toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentOrders.length,
                      itemBuilder: (ctx, i) => OrderCard(order: recentOrders[i]),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- WIDGETS ---
// It's best practice to keep these in their own files in a 'widgets' directory.

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

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
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}