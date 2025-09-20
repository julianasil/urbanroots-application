// frontend/lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import '../models/product.dart';

// --- NEW: An enum for type-safe menu actions ---
enum _MenuAction { edit, delete }

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  // --- NEW: Added properties for admin actions ---
  // This flag determines if the "three-dot" menu should be shown.
  final bool showAdminActions;
  // The callback to execute when the "Edit" option is tapped.
  final VoidCallback? onEdit;
  // The callback to execute when the "Delete" option is tapped.
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onTap,
    // --- NEW: Initialize the new properties ---
    // We provide a default value of 'false' to make it non-breaking
    // for other parts of your app that might use ProductCard.
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
            // --- MODIFIED: The image section is now wrapped in a Stack ---
            // A Stack allows us to layer the menu button on top of the image.
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: fullImageUrl != null
                      ? FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: fullImageUrl,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, color: Colors.red);
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                        ),
                ),
                
                // --- NEW: This is the admin menu button ---
                // It's only included in the widget tree if showAdminActions is true.
                if (showAdminActions)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _buildAdminMenu(context),
                  ),
              ],
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  // ... (The rest of your card's content remains exactly the same)
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

  // --- NEW: A helper widget to build the PopupMenuButton ---
  Widget _buildAdminMenu(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      // The onSelected callback is triggered when a user taps an item.
      onSelected: (action) {
        switch (action) {
          case _MenuAction.edit:
            // Execute the onEdit callback passed from the MarketScreen.
            onEdit?.call();
            break;
          case _MenuAction.delete:
            // Execute the onDelete callback passed from the MarketScreen.
            onDelete?.call();
            break;
        }
      },
      // The itemBuilder creates the visual menu items.
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _MenuAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: _MenuAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      // This adds a semi-transparent background to the icon, making it
      // visible on both light and dark images.
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
      ),
    );
  }
}