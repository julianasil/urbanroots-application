// frontend/lib/screens/market_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart'; // We need this to check ownership
import '../../services/api_service.dart'; // We need this to get our own profile
import '../../widgets/product_tile.dart'; // Import the new tile
import 'product_detail_screen.dart';
import 'edit_product_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // We now need to fetch both products and the user's own profile
  late Future<void> _dataFuture;
  UserProfile? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadInitialData();
  }

  // A single method to load all necessary data
  Future<void> _loadInitialData() async {
    // Use Future.wait to run both API calls in parallel for speed
    await Future.wait([
      Provider.of<ProductProvider>(context, listen: false).loadProducts(),
      _loadUserProfile(),
    ]);
  }
  
  // Helper to load the user's own profile to check ownership
  Future<void> _loadUserProfile() async {
    try {
      _currentUserProfile = await ApiService().getMyProfile();
    } catch(e) {
      print("Could not load user profile on market screen: $e");
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _dataFuture = _loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UrbanRoots Marketplace'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const EditProductScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add a new product',
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder(
          future: _dataFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('An error occurred: ${snapshot.error}'));
            }
            
            return Consumer<ProductProvider>(
              builder: (ctx, productData, child) {
                if (productData.items.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                // Use a ListView for a compact, scrollable list
                return ListView.builder(
                  itemCount: productData.items.length,
                  itemBuilder: (ctx, i) {
                    final product = productData.items[i];

                    final loggedInUserProfileId = _currentUserProfile?.businessProfile?.profileId.trim();
                    final productSellerProfileId = product.sellerProfile?.profileId.trim();
    
    // Also, ensure neither is null before comparing.
                    final bool canManage = loggedInUserProfileId != null &&
                                           productSellerProfileId != null &&
                                           loggedInUserProfileId == productSellerProfileId;


                    print('--- Ownership Check for Product: ${product.name} ---');
                    print('Logged-in User\'s Profile ID: $loggedInUserProfileId (Type: ${loggedInUserProfileId.runtimeType})');
                    print('Product\'s Seller Profile ID:   $productSellerProfileId (Type: ${productSellerProfileId.runtimeType})');
                    
                    // --- Ownership Check ---
                    // The Edit/Delete buttons will only show if the logged-in user's
                    // profile ID matches the product's seller profile ID.
                    //final bool canManage = _currentUserProfile?.businessProfile?.profileId == product.sellerProfile;

                    print('Can Manage? $canManage');
                    print('-----------------------------------------');
                    
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
                        // Show a confirmation dialog before deleting
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
                                  Provider.of<ProductProvider>(context, listen: false)
                                      .deleteProduct(product.productId);
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