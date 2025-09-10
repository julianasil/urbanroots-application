// lib/services/product_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  final String _baseUrl = 'http://127.0.0.1:8000/api/products';
  
  Future<Map<String, String>> _getAuthHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('User is not authenticated.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  Future<List<Product>> fetchProducts({Map<String, String>? queryParameters}) async {
    final uri = Uri.parse('$_baseUrl/').replace(queryParameters: queryParameters);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching products: $e');
    }
  }

  Future<Product> fetchProduct(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id/'));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch product');
    }
  }


  /// Creates a new product. Requires authentication.
  /// The backend will securely assign the seller based on the token.
  Future<Product> createProduct(Product product, {File? imageFile, Uint8List? imageBytes, String? imageName}) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/');
    
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({'Authorization': headers['Authorization']!});

    // Add text fields
    request.fields['name'] = product.name;
    request.fields['description'] = product.description;
    request.fields['price'] = product.price.toString();
    request.fields['unit'] = product.unit;
    request.fields['stock_quantity'] = product.stockQuantity.toString();
    request.fields['is_active'] = product.isActive.toString();
    
    // Add image file based on platform
    if (imageFile != null) {
      // Mobile platform
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    } else if (imageBytes != null && imageName != null) {
      // Web platform
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      print('Failed to create product. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to create product.');
    }
  }

  Future<Product> updateProduct(String productId, Product product, {File? imageFile, Uint8List? imageBytes, String? imageName}) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/$productId/');

    var request = http.MultipartRequest('PATCH', uri)
      ..headers.addAll({'Authorization': headers['Authorization']!});
      
    request.fields.addAll(product.toUpdateJson().map((key, value) => MapEntry(key, value.toString())));

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    } else if (imageBytes != null && imageName != null) {
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product.');
    }
  }

  Future<void> deleteProduct(String id) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id/'), 
      headers: headers
    );

    if (response.statusCode != 204) { // 204 No Content
      throw Exception('Failed to delete product: ${response.body}');
    }
  }
}
