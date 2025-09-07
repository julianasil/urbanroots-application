class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stockQuantity;
  final String? imageUrl; // can be URL or local file path
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    this.imageUrl,
    required this.isActive,
  });

  /// Factory constructor to create a Product from Django JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      stockQuantity: json['stock_quantity'] ?? 0,
      imageUrl: json['image'], // remote URL from backend
      isActive: json['is_active'] ?? true,
    );
  }

  /// Convert Product to JSON (for POST/PUT requests)
  /// ⚠️ Important: local file paths are not sent to backend
  Map<String, dynamic> toJson() {
    return {
      'product_id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'stock_quantity': stockQuantity,
      'image': (imageUrl != null && imageUrl!.startsWith('http'))
          ? imageUrl
          : null, // only send remote URLs
      'is_active': isActive,
    };
  }

  /// CopyWith method for immutability
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? unit,
    int? stockQuantity,
    String? imageUrl,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Helper: check if image is local file
  bool get isLocalImage {
    return imageUrl != null && !imageUrl!.startsWith('http');
  }
}
