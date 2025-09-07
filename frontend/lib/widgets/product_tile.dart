import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductTile({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        product.imageUrl ?? '',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (ctx, error, stackTrace) =>
            const Icon(Icons.image_not_supported),
      ),
      title: Text(product.name),
      subtitle: Text('₱${product.price.toStringAsFixed(2)}'),
      onTap: onTap,
    );
  }
}
