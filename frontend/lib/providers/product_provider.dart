import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  bool _loading = false;
  String _searchTerm = '';

  List<Product> get items => [..._items];
  bool get loading => _loading;

  // Returns filtered items based on the current search term
  List<Product> get filteredItems {
    if (_searchTerm.isEmpty) return items;
    return items.where((p) =>
        p.title.toLowerCase().contains(_searchTerm.toLowerCase())).toList();
  }

  // Updates the search term and notifies listeners
  void updateSearch(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();

    final data = await SupabaseService.getProducts();
    _items = data.map((e) => Product.fromMap(e)).toList();

    _loading = false;
    notifyListeners();
  }

  void addProduct(Product product) {
  _items.add(product);
  notifyListeners();
}

void updateProduct(Product updatedProduct) {
  final index = _items.indexWhere((p) => p.id == updatedProduct.id);
  if (index != -1) {
    _items[index] = updatedProduct;
    notifyListeners();
  }
}



}
