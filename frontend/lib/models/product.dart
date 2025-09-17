// frontend/lib/models/product.dart
import 'user_profile.dart'; // For BusinessProfile

class Product {
  final String productId;
  final BusinessProfile? sellerProfile; // This holds the nested seller details
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
      productId: json['product_id'],
      sellerProfile: json['seller_profile'] != null
          ? BusinessProfile.fromJson(json['seller_profile'])
          : null,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      unit: json['unit'] ?? '',
      stockQuantity: json['stock_quantity'] ?? 0,
      image: json['image'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  // Used by the service to build the multipart request for updates
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'price': price.toString(),
      'unit': unit,
      'stock_quantity': stockQuantity.toString(),
      'is_active': isActive.toString(),
    };
  }
}