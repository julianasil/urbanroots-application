// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _addingToCart = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final product = widget.product;

    final priceFormatted = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
    ).format(product.price);

    final isOutOfStock = product.stockQuantity <= 0 || !product.isActive;

    String? fullImageUrl;
    if (product.image != null && product.image!.isNotEmpty) {
      if (product.image!.startsWith('http')) {
        // If the path is already a full URL, use it directly.
        fullImageUrl = product.image!;
      } else {
        // If the path is relative (e.g., /media/...), prepend the base server URL.
        fullImageUrl = 'http://127.0.0.1:8000${product.image}';
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(
              imageUrl: fullImageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(priceFormatted, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'In stock: ${product.stockQuantity}',
              style: TextStyle(
                color: isOutOfStock ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(product.description),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: _addingToCart
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add to Cart'),
                onPressed: isOutOfStock
                    ? null
                    : () async {
                        setState(() => _addingToCart = true);
                        try {
                          cart.addItem(
                            product.productId, // updated for backend
                            product.price,
                            product.name,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to add to cart. Please try again.'),
                            ),
                          );
                        } finally {
                          setState(() => _addingToCart = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
