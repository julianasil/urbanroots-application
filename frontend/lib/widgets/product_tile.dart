import 'package:flutter/material.dart';
import '../models/product.dart';
// Note: The 'user_profile.dart' import is not strictly needed here but is harmless.
import '../models/user_profile.dart';


class ProductTile extends StatelessWidget {
  final Product product;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProductTile({
    super.key,
    required this.product,
    required this.canManage,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stockQuantity <= 0 || !product.isActive;

    String? fullImageUrl;
    if (product.image != null && product.image!.isNotEmpty) {
      if (product.image!.startsWith('http')) {
        fullImageUrl = product.image!;
      } else {
        fullImageUrl = 'http://127.0.0.1:8000${product.image}';
      }
    }

    // MODIFIED: Changed product.sellerProfile to product.sellerProfileDetails
    final String sellerName = product.sellerProfileDetails?.companyName ?? 'Unknown Seller';

     return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: fullImageUrl != null
                      ? Image.network(fullImageUrl, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              
              // Product and Seller Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By: $sellerName', // Display the seller's company name
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₱${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stock: ${product.stockQuantity}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons (only shown if canManage is true)
              if (canManage)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue[600]),
                      onPressed: onEdit,
                      tooltip: 'Edit Product',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[600]),
                      onPressed: onDelete,
                      tooltip: 'Delete Product',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}