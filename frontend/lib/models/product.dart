// lib/models/product.dart
import 'user_profile.dart';

class Product {
  final String productId;
  final BusinessProfile? sellerProfile;  // returned read-only field from API
  final String name;
  final String description;
  final double price;
  final String unit;
  int stockQuantity;
  final String? image;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.productId,
    this.sellerProfile,
    required this.name,
    this.description = '',
    required this.price,
    required this.unit,
    required this.stockQuantity,
    this.image,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] as String,
      sellerProfile: json['seller_profile'] != null
          ? BusinessProfile.fromJson(json['seller_profile'])
          : null,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is String) ? double.parse(json['price']) : (json['price']?.toDouble() ?? 0.0),
      unit: json['unit'] ?? '',
      stockQuantity: (json['stock_quantity'] ?? 0) as int,
      image: json['image']?.toString(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  // toJson for creating a product: include seller_profile_id (write-only)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'description': description,
      'price': price.toString(), // Send price as a string for consistency with DecimalField
      'unit': unit,
      'stock_quantity': stockQuantity,
      'is_active': isActive,
    };
  }

  // toJson for updates: do not send seller_profile_id (server forbids changing seller)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'price': price.toString(),
      'unit': unit,
      'stock_quantity': stockQuantity,
      'is_active': isActive,
    };
  }
}
