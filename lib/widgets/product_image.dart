// lib/widgets/product_image.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../constants.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ProductImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  }) : super(key: key);

  bool _isAssetPath(String? url) => url != null && url.startsWith('assets/');
  bool _isNetworkUrl(String? url) =>
      url != null && (url.startsWith('http://') || url.startsWith('https://'));
  bool _isFilePath(String? url) => url != null && File(url).existsSync();

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ?? '';

    // Asset image
    if (_isAssetPath(url)) {
      return Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    // Network image
    if (_isNetworkUrl(url)) {
      return Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    // Local file image (existsSync used above)
    if (_isFilePath(url)) {
      return Image.file(
        File(url),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    // fallback placeholder
    return _placeholder();
  }

  Widget _placeholder() {
    return Image.network(
      kPlaceholderImage,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      ),
    );
  }
}
