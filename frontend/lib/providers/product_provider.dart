import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final String _baseUrl = "http://127.0.0.1:8000/api/products/"; // adjust for emulator/device
  List<Product> _items = [];
  bool _loading = false;

  List<Product> get items => [..._items];
  bool get loading => _loading;

  /// Fetch products from Django backend
  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _items = data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch products: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching products: $e");
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Add a new product (POST)
  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(product.toJson()),
      );
      if (response.statusCode == 201) {
        final newProduct = Product.fromJson(json.decode(response.body));
        _items.add(newProduct);
        notifyListeners();
      } else {
        throw Exception("Failed to add product: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding product: $e");
      }
    }
  }

  /// Update an existing product (PUT)
  Future<void> updateProduct(Product updatedProduct) async {
    final url = Uri.parse("$_baseUrl${updatedProduct.id}/");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedProduct.toJson()),
      );
      if (response.statusCode == 200) {
        final index = _items.indexWhere((item) => item.id == updatedProduct.id);
        if (index != -1) {
          _items[index] = updatedProduct;
          notifyListeners();
        }
      } else {
        throw Exception("Failed to update product: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating product: $e");
      }
    }
  }

  /// Soft delete a product (mark inactive instead of removing completely)
  Future<void> deleteProduct(String id) async {
    final url = Uri.parse("$_baseUrl$id/");

    try {
      // Option A: If your backend expects DELETE (hard delete)
      final response = await http.delete(url);

      // Option B: If your backend uses soft delete -> use PATCH instead
      // final response = await http.patch(
      //   url,
      //   headers: {"Content-Type": "application/json"},
      //   body: json.encode({'is_active': false}),
      // );

      if (response.statusCode == 204 || response.statusCode == 200) {
        final index = _items.indexWhere((item) => item.id == id);
        if (index != -1) {
          final product = _items[index];
          _items[index] = product.copyWith(isActive: false);
          notifyListeners();
        }
      } else {
        throw Exception("Failed to delete product: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting product: $e");
      }
    }
  }

  /// Adjust stock quantity (positive = add, negative = subtract)
  void adjustStock(String id, int change) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final product = _items[index];
      final updated = product.copyWith(
        stockQuantity: product.stockQuantity + change,
      );
      _items[index] = updated;
      notifyListeners();
    }
  }
}
