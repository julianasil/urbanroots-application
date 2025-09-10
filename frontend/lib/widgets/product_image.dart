// lib/widgets/product_image.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    // If the URL is null or empty, immediately show a placeholder.
    if (url == null || url.isEmpty) {
      return _placeholder();
    }

    // --- THIS IS THE NEW, PLATFORM-AWARE LOGIC ---

    // 1. Check for Network URLs (http:// or https://)
    if (url.startsWith('http')) {
      // Check if it's an SVG
      if (url.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(
          url,
          fit: fit,
          width: width,
          height: height,
          placeholderBuilder: (context) => _loadingIndicator(),
        );
      } else {
        // It's a regular network image (PNG, JPG, etc.)
        return Image.network(
          url,
          fit: fit,
          width: width,
          height: height,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return _loadingIndicator();
          },
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      }
    } 
    // 2. Check for Asset URLs (assets/)
    else if (url.startsWith('assets/')) {
      if (url.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          url,
          fit: fit,
          width: width,
          height: height,
          placeholderBuilder: (context) => _loadingIndicator(),
        );
      } else {
        return Image.asset(
          url,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      }
    }
    // 3. Check for Local File URLs (ONLY if not on web)
    else if (!kIsWeb) {
      // This block will not run on the web, preventing the crash.
      final file = File(url);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      }
    }

    // If none of the above conditions are met, show a placeholder.
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Widget _loadingIndicator() {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
