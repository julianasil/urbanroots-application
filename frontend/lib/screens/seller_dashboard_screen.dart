// frontend/lib/screens/seller_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart'; // We can reuse this card for displaying sales

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
    // This will run every time the screen is newly created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      // --- THIS IS THE FIX ---
      // We wrap the body in a Consumer to listen for state changes from the OrderProvider.
      body: Consumer<OrderProvider>(
        builder: (context, orderData, child) {
          // 1. Check if the provider is currently in a loading state.
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
              child: Stack( // Stack allows the ListView to be scrollable for the refresh indicator
                children: [
                  ListView(), // Dummy ListView
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
              padding: const EdgeInsets.all(16.0),
              itemCount: sales.length,
              itemBuilder: (ctx, i) {
                // For now, we can reuse the OrderCard.
                // Later, you might create a custom SaleCard to show buyer info.
                return OrderCard(order: sales[i], isSellerView: true);
              },
            ),
          );
        },
      ),
    );
  }
}