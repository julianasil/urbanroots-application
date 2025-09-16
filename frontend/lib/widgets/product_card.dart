// frontend/lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import '../models/product.dart';


class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const ProductCard({
    super.key, 
    required this.product, 
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- FIX: The product.image from the backend is already the full URL. ---
    // We no longer need to build it here. We just need to check if it exists.
    final String? fullImageUrl = product.image != null && product.image!.isNotEmpty
        ? product.image
        : null;

    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: fullImageUrl != null
                  ? FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: fullImageUrl,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        // Add a print statement here to see errors in the console
                        print("Image Load Error: $error");
                        return const Icon(Icons.error, color: Colors.red);
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                    ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'per ${product.unit}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '₱${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: onAddToCart,
                          icon: Icon(Icons.add_shopping_cart, color: theme.colorScheme.primary),
                          tooltip: 'Add to Cart',
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}