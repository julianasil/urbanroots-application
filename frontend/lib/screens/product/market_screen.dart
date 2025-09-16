// frontend/lib/screens/product/market_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'edit_product_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the Provider is available when called.
    // This fetches products on the first load if the list is currently empty.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.items.isEmpty) {
        productProvider.loadProducts();
      }
    });
  }

  Future<void> _refreshData(BuildContext context) async {
    // This method is called by the RefreshIndicator.
    await Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UrbanRoots Marketplace'),
      ),
      floatingActionButton: _buildFab(context),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: Consumer<ProductProvider>(
          builder: (ctx, productProvider, child) {
            // --- ALIGNED WITH PROVIDER ---
            // On initial load (items are empty), show the skeleton loader.
            if (productProvider.isLoading && productProvider.items.isEmpty) {
              return _buildLoadingSkeleton();
            }

            // --- ALIGNED WITH PROVIDER ---
            // If an error string exists, show the error state.
            if (productProvider.error != null) {
              return _buildErrorState(productProvider.error!);
            }

            // If the list is empty and there's no error, show the empty state.
            if (productProvider.items.isEmpty) {
              return _buildEmptyState();
            }

            // If we have data, show the GridView.
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: productProvider.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (ctx, i) {
                final product = productProvider.items[i];
                
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  onAddToCart: () {
                    final cart = Provider.of<CartProvider>(context, listen: false);
                    cart.addItem(product.productId, product.price, product.name);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart!'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            cart.removeSingleItem(product.productId);
                          },
                        ),
                      ),
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

  // --- HELPER WIDGETS (No changes needed here) ---

  Widget _buildFab(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final activeProfile = userProvider.activeBusinessProfile;
        final canSell = activeProfile != null &&
            (activeProfile.businessType == 'seller' || activeProfile.businessType == 'both');

        if (!canSell) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const EditProductScreen()),
            );
          },
          tooltip: 'Add a new product',
          child: const Icon(Icons.add),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for skeleton
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[200],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No products in the market yet.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Could not load products. Please pull to refresh.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}