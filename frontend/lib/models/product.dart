// lib/models/product.dart
import 'package:urbanroots_application/models/user_profile.dart';
class Product {
  final String productId;
  
  // MODIFIED: This field is now for SENDING data. It holds the UUID of the seller.
  // When creating a new Product object in the app, you MUST provide this.
  final String sellerProfileId;

  // MODIFIED: This is for DISPLAYING data. It's the nested object from the API.
  // Renamed from `sellerProfile` to `sellerProfileDetails` for clarity.
  final BusinessProfile? sellerProfileDetails;

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
    required this.sellerProfileId, // MODIFIED: Made this required.
    this.sellerProfileDetails,      // MODIFIED: Renamed for clarity.
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
    // The nested details will come from the 'seller_profile_details' key we defined in the Django serializer
    final detailsData = json['seller_profile_details'];

    return Product(
      productId: json['product_id'] as String,
      
      // We get the seller's ID from within the nested details object.
      sellerProfileId: detailsData != null ? detailsData['profile_id'] as String : '',

      sellerProfileDetails: detailsData != null
          ? BusinessProfile.fromJson(detailsData)
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

  // REMOVED: The toCreateJson and toUpdateJson methods are no longer needed,
  // as the ProductService now builds the request manually using the object's properties.
}