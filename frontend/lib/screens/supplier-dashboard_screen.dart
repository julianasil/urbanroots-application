// lib/screens/supplier_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_tile.dart';

class SupplierDashboardScreen extends StatelessWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser!;
    final products = Provider.of<ProductProvider>(context)
        .items
        .where((p) => p.ownerId == user.username && p.type == 'input')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Supplies')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to EditProductScreen(null, 'input')
        },
        child: const Icon(Icons.add),
      ),
      body: products.isEmpty
          ? const Center(child: Text('No inputs supplied yet.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3/2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (ctx, i) => ProductTile(product: products[i]),
            ),
    );
  }
}
