/*

import 'package:flutter/foundation.dart';
import '../models/product.dart';

class InventoryProvider with ChangeNotifier {
  final List<Product> _items = [];
  bool _loading = false;

  List<Product> get items => [..._items];
  bool get loading => _loading;

  // Fetch inventory (dummy data for now)
  Future<void> fetchInventory() async {
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // simulate delay
    _items.clear();
    _items.addAll([
      Product(
        productId: 'p1',
        sellerProfileId: 's1',
        name: 'Hydroponic Lettuce',
        description: 'Fresh lettuce grown in hydroponics.',
        price: 50.0,
        unit: 'kg',
        stockQuantity: 25,
        imageUrl: 'https://via.placeholder.com/150',
        isActive: true,
      ),
      Product(
        productId: 'p2',
        sellerProfileId: 's1',
        name: 'Tomato Seeds',
        description: 'High-yield tomato seeds.',
        price: 100.0,
        unit: 'pack',
        stockQuantity: 200,
        imageUrl: 'https://via.placeholder.com/150',
        isActive: false,
      ),
    ]);

    _loading = false;
    notifyListeners();
  }

  void addItem(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void updateItem(Product updatedProduct) {
    final index = _items.indexWhere((item) => item.productId == updatedProduct.productId);
    if (index != -1) {
      _items[index] = updatedProduct;
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }
}

*/