// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
//import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../screens/orders_screen.dart';
import '../widgets/product_image.dart';
import '../providers/order_provider.dart';
//import '../providers/user_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  // --- NEW METHOD to handle the checkout logic ---
  Future<void> _checkout(BuildContext context, CartProvider cart) async {

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    //final userProvider = Provider.of<UserProvider>(context, listen: false);

    //if (userProvider.activeBusinessProfile == null) {
      // If no profile, show a helpful dialog instead of trying to checkout.
      /*showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Profile Incomplete'),
          content: const Text('Please create or select a business profile from your account screen before placing an order.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                // TODO: You could navigate them directly to the Account tab here
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return; // Stop the checkout process
    }*/

    // 3. If the check passes, proceed with the existing checkout logic.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Format cart items for the API.
      final cartItemsForApi = cart.items.entries.map((entry) => {
        'product_id': entry.key,
        'quantity': entry.value.quantity,
      }).toList();

      // 3. Define the shipping address.
      const shippingAddress = '123 Flutter Lane, Dev City, 8000';

      // 4. Call the ApiService.
      await ApiService().createOrder(cartItemsForApi, shippingAddress);

      // 5. If successful, clear the local cart.
      cart.clear();

      // --- FIX: Use rootNavigator to ensure the dialog is popped ---
      navigator.pop();

      // Show a success message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the order history screen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
      );

      await Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders();

    } catch (e) {
      // Close the loading dialog.
      navigator.pop();

      // Show an error message if anything goes wrong.
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Checkout Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final productProv = Provider.of<ProductProvider>(context, listen: false);

    final cartItemsList = cart.items.values.toList();
    final cartProductIds = cart.items.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Summary Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₱${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: cart.items.isEmpty ? null : () => _checkout(context, cart),
                      icon: const Icon(Icons.payment),
                      label: const Text('CHECKOUT'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Empty state
          if (cart.items.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Browse products and add items to your cart.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            // Items List
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final cartItem = cartItemsList[i];
                  final productId = cartProductIds[i];

                  final product = productProv.items.firstWhere(
                    (p) => p.productId == productId,
                    orElse: () => Product(
                      productId: productId,
                      name: cartItem.title,
                      description: '',
                      price: cartItem.price,
                      stockQuantity: 9999, // fallback stock
                      unit: 'pcs',
                      image: '',
                      isActive: true,
                    ),
                  );

                  return Dismissible(
                    key: ValueKey(cartItem.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete,
                          color: Colors.white, size: 32),
                    ),
                    onDismissed: (_) => cart.removeItem(productId),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Product Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 78,
                                height: 68,
                                child: product.image?.isNotEmpty == true
                                    ? ProductImage(
                                        imageUrl: product.image!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: Text(
                                            '₱${cartItem.price.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Title + Subtotal
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItem.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Subtotal: ₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Controls
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    cart.removeSingleItem(productId);
                                  },
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: cartItem.quantity >=
                                          product.stockQuantity
                                      ? null
                                      : () {
                                          cart.addItem(
                                            productId,
                                            cartItem.price,
                                            cartItem.title,
                                          );
                                        },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
