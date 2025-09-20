// frontend/lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanroots_application/providers/report_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../screens/product/edit_product_screen.dart';
import 'orders_screen.dart';
import '../widgets/order_card.dart';
import 'seller_reports_screen.dart'; // <-- IMPORT THE REPORTS SCREEN

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData(context);
    });
  }
  
  Future<void> _refreshData(BuildContext context) async {
    // Also fetch report data on refresh for sellers
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isSeller = userProvider.activeBusinessProfile != null &&
        (userProvider.activeBusinessProfile!.businessType == 'seller' || userProvider.activeBusinessProfile!.businessType == 'both');

    List<Future<void>> futures = [
      Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders(),
      Provider.of<ProductProvider>(context, listen: false).loadProducts(),
    ];

    if (isSeller) {
      futures.add(Provider.of<ReportProvider>(context, listen: false).getSellerReport());
    }
    
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    // We listen to the UserProvider to reactively build the UI based on role.
    final userProv = Provider.of<UserProvider>(context);
    final cartProv = Provider.of<CartProvider>(context);
    
    final fullName = userProv.user?.fullName ?? 'Guest';
    
    // --- KEY LOGIC: Determine if the user is a seller ---
    final activeProfile = userProv.activeBusinessProfile;
    final bool isSeller = activeProfile != null &&
        (activeProfile.businessType == 'seller' || activeProfile.businessType == 'both');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Greeting Section (Unchanged) ---
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

                // --- NEW: Conditional Analytics Button ---
                // This block is the only new UI element. It only appears for sellers.
                if (isSeller) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('View Business Analytics'),
                    onPressed: () {
                      // Make sure the report data is fetched before navigating
                      Provider.of<ReportProvider>(context, listen: false).getSellerReport();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SellerReportsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), // Full-width
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // --- Stats Grid Section (Unchanged) ---
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

                // --- Action Buttons Section (Unchanged) ---
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

                // --- Recent Orders Section (Unchanged) ---
                Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                Consumer<OrderProvider>(
                  builder: (context, orderData, child) {
                    if (orderData.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (orderData.error != null) {
                      return Center(child: Text('An error occurred: ${orderData.error}'));
                    }
                    if (orderData.orders.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No recent orders found.')));
                    }
                    
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


// --- WIDGETS (Unchanged) ---
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