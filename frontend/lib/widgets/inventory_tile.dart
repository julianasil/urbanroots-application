import 'package:flutter/material.dart';
import '../models/product.dart';

class InventoryTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InventoryTile({
    Key? key,
    required this.product,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Product name
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Price and unit
            Text(
              "₱${product.price.toStringAsFixed(2)} / ${product.unit}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            // Stock quantity
            Text(
              "Stock: ${product.stockQuantity}",
              style: TextStyle(
                fontSize: 12,
                color: product.stockQuantity > 0 ? Colors.green : Colors.red,
              ),
            ),

            // Active status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    product.isActive ? "Active" : "Inactive",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor:
                      product.isActive ? Colors.green : Colors.red,
                ),

                // Edit/Delete buttons (optional)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: onEdit,
                      tooltip: "Edit product",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: onDelete,
                      tooltip: "Delete product",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
