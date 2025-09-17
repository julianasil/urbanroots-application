// lib/providers/product_provider.dart
import 'dart:io';
import 'dart:typed_data';
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
      //notifyListeners(); // MODIFIED: Uncommented for better UI feedback on loading start.
      final products = await service.fetchProducts(queryParameters: filters);
      _items = products;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners(); // MODIFIED: Uncommented for better UI feedback on loading end.
    }
  }

  /// Create a new product on backend
  // MODIFIED: Added imageBytes and imageName to support web image uploads.
  Future<Product?> createProduct(
    Product product, {
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      // The service layer will handle sending the auth token.
      final created = await service.createProduct(
        product,
        imageFile: imageFile,
        imageBytes: imageBytes, // MODIFIED: Pass imageBytes to the service.
        imageName: imageName,   // MODIFIED: Pass imageName to the service.
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
  // MODIFIED: Added imageBytes and imageName to support web image uploads.
  Future<Product?> updateProduct(
    Product product, {
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final updated = await service.updateProduct(
        product.productId,
        product,
        imageFile: imageFile,
        imageBytes: imageBytes, // MODIFIED: Pass imageBytes to the service.
        imageName: imageName,   // MODIFIED: Pass imageName to the service.
      );
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
  // MODIFIED: Added imageBytes and imageName to keep this method consistent.
  Future<Product?> addProduct(
    Product product, {
    required String sellerProfileId,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) {
    return createProduct(
      product,
      imageFile: imageFile,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }
}