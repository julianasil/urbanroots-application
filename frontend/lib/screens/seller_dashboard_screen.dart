// frontend/lib/screens/seller_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../widgets/sale_card.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely fetch data after the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("DEBUG: SellerDashboard initState is calling _loadSales...");
      _loadSales();
    });
  }

  // Helper method to trigger the data fetch in the provider.
  Future<void> _loadSales() {
    return Provider.of<OrderProvider>(context, listen: false).fetchAndSetSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sales'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderData, child) {
          print("DEBUG: SellerDashboard Consumer is building. Loading: ${orderData.isLoading}, Error: ${orderData.error}, Sales Count: ${orderData.sales.length}");
          if (orderData.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Check if the provider has an error.
          if (orderData.error != null) {
            return Center(child: Text('An error occurred: ${orderData.error}'));
          }
          // 3. Check if the sales list is empty.
          if (orderData.sales.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _loadSales(),
              child: Stack(
                children: [
                  ListView(), // Dummy ListView to make RefreshIndicator work on empty screen
                  const Center(child: Text('You have not received any sales yet.')),
                ],
              ),
            );
          }
          
          // 4. If we have data, display it in a RefreshIndicator and ListView.
          final sales = orderData.sales;
          return RefreshIndicator(
            onRefresh: () => _loadSales(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: sales.length,
              itemBuilder: (ctx, i) {
                return SaleCard(sale: sales[i]); 
              },
            ),
          );
        },
      ),
    );
  }
}