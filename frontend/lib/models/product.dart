class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  //final String ownerId;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    //required this.ownerId,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['image_url'],
      //ownerId: map['ownerId'] ?? '',
    );
  }
}