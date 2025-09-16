// lib/screens/product/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _addingToCart = false;

  void _addToCart() async {
    // Show loading indicator on the button
    setState(() => _addingToCart = true);
    
    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final product = widget.product;
      cart.addItem(product.productId, product.price, product.name);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add item. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() => _addingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;
    final isOutOfStock = product.stockQuantity <= 0 || !product.isActive;

    // We assume product.image is the full URL from the backend now
    final String? fullImageUrl = product.image;

    final priceFormatted = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
    ).format(product.price);

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      
      // --- KEY CHANGE: The "Add to Cart" button is now here ---
      // This makes it always visible and accessible, a crucial UX improvement.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          // Use the ElevatedButton style from our theme
          style: theme.elevatedButtonTheme.style?.copyWith(
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
          ),
          icon: _addingToCart
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.add_shopping_cart),
          label: Text(_addingToCart ? 'Adding...' : 'Add to Cart'),
          // Disable the button if the product is out of stock
          onPressed: isOutOfStock || _addingToCart ? null : _addToCart,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KEY CHANGE: Larger, more professional image display ---
            if (fullImageUrl != null)
              AspectRatio(
                aspectRatio: 4 / 3, // Ensures a consistent, pleasing image size
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: fullImageUrl,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),

            // --- KEY CHANGE: Better spacing and structure for details ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    priceFormatted,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isOutOfStock ? 'Out of Stock' : 'In Stock: ${product.stockQuantity}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isOutOfStock ? Colors.red.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    // Increased line height for better readability
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
             // Add padding at the bottom to ensure content isn't hidden by the button bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}