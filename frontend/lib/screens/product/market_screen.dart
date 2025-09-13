// frontend/lib/screens/market_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/product_tile.dart';
import 'product_detail_screen.dart';
import 'edit_product_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late Future<void> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<void> _loadProducts() {
    return Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  Future<void> _refreshData() async {
    // Refreshing the product list is all that's needed here.
    await _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    // MODIFIED: We only need to consume the providers directly in the builder now.
    return Scaffold(
      appBar: AppBar(
        title: const Text('UrbanRoots Marketplace'),
      ),
      // MODIFIED: The FAB is now built within a Consumer to react to state changes.
      floatingActionButton: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final activeProfile = userProvider.activeBusinessProfile;
          // Show the "Add Product" button only if there's an active profile
          // and its type is 'seller' or 'both'.
          final canSell = activeProfile != null &&
              (activeProfile.businessType == 'seller' || activeProfile.businessType == 'both');

          if (!canSell) {
            return const SizedBox.shrink(); // Return an empty widget if user can't sell
          }

          return FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const EditProductScreen()),
              );
            },
            child: const Icon(Icons.add),
            tooltip: 'Add a new product',
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder(
          future: _productsFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('An error occurred: ${snapshot.error}'));
            }
            
            return Consumer2<ProductProvider, UserProvider>(
              builder: (ctx, productProvider, userProvider, child) {
                if (productProvider.items.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                // MODIFIED: Get the single active profile ID.
                final activeProfileId = userProvider.activeBusinessProfile?.profileId;

                return ListView.builder(
                  itemCount: productProvider.items.length,
                  itemBuilder: (ctx, i) {
                    final product = productProvider.items[i];

                    // MODIFIED: The ownership check is now a simple string comparison.
                    // "Can the user manage this product if its seller ID matches their active profile ID?"
                    final bool canManage = product.sellerProfileId == activeProfileId;
                    
                    return ProductTile(
                      product: product,
                      canManage: canManage,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => EditProductScreen(product: product),
                          ),
                        );
                      },
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: Text('Do you want to delete "${product.name}"?'),
                            actions: [
                              TextButton(
                                child: const Text('No'),
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () {
                                  productProvider.deleteProduct(product.productId);
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}