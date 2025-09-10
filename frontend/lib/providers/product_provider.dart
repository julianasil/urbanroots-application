// lib/providers/product_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService service;
  List<Product> _items = [];
  bool isLoading = false;
  String? error;

  ProductProvider({required this.service});

  List<Product> get items => _items;

  /// Fetch products from backend
  Future<void> loadProducts({Map<String, String>? filters}) async {
    isLoading = true;
    try {
      //notifyListeners();
      final products = await service.fetchProducts(queryParameters: filters);
      _items = products;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      //notifyListeners();
    }
  }

  /// Create a new product on backend
    Future<Product?> createProduct(Product product, {File? imageFile}) async {
    try {
      // The service layer will handle sending the auth token.
      final created = await service.createProduct(
        product,
        imageFile: imageFile,
      );
      _items.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow; // Rethrowing is good for letting the UI know about the error.
    }
  }

  /// Update an existing product
  Future<Product?> updateProduct(Product product, {File? imageFile}) async {
    try {
      final updated = await service.updateProduct(product.productId, product, imageFile: imageFile);
      final idx = _items.indexWhere((p) => p.productId == updated.productId);
      if (idx >= 0) _items[idx] = updated;
      notifyListeners();
      return updated;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      await service.deleteProduct(id);
      _items.removeWhere((p) => p.productId == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update local stock after an adjustment
  void updateLocalStock(String productId, int delta) {
    final idx = _items.indexWhere((p) => p.productId == productId);
    if (idx >= 0) {
      _items[idx].stockQuantity += delta;
      notifyListeners();
    }
  }

  /// Redirect addProduct to createProduct for consistency
  Future<Product?> addProduct(Product product, {required String sellerProfileId, File? imageFile}) {
    return createProduct(product, imageFile: imageFile);
  }
}
