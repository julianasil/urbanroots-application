// lib/services/product_service.dart
import 'dart:convert';
import 'dart:io'; // FIXED: Corrected the import from 'dart.io' to 'dart:io'
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  final String _baseUrl = 'http://127.0.0.1:8000/api/products';
  
  Future<Map<String, String>> _getAuthHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception('User is not authenticated.');
    return {'Authorization': 'Bearer ${session.accessToken}'};
  }

  // fetchProducts and fetchProduct are fine, no changes needed.
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
    if (response.statusCode == 200) return Product.fromJson(json.decode(response.body));
    throw Exception('Failed to fetch product');
  }

  Future<Product> createProduct(Product product, {File? imageFile, Uint8List? imageBytes, String? imageName}) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/');
    var request = http.MultipartRequest('POST', uri)..headers.addAll(headers);

    request.fields['seller_profile'] = product.sellerProfileId;
    request.fields['name'] = product.name;
    request.fields['description'] = product.description;
    request.fields['price'] = product.price.toString();
    request.fields['unit'] = product.unit;
    request.fields['stock_quantity'] = product.stockQuantity.toString();
    request.fields['is_active'] = product.isActive.toString();
    
    if (!kIsWeb && imageFile != null) request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    else if (kIsWeb && imageBytes != null && imageName != null) request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) return Product.fromJson(json.decode(response.body));
    throw Exception('Failed to create product: ${response.body}');
  }

  Future<Product> updateProduct(String productId, Product product, {File? imageFile, Uint8List? imageBytes, String? imageName}) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/$productId/');
    var request = http.MultipartRequest('PATCH', uri)..headers.addAll(headers);
      
    // FIXED: Manually add fields instead of using the removed toUpdateJson() method.
    request.fields['name'] = product.name;
    request.fields['description'] = product.description;
    request.fields['price'] = product.price.toString();
    request.fields['unit'] = product.unit;
    request.fields['stock_quantity'] = product.stockQuantity.toString();
    request.fields['is_active'] = product.isActive.toString();

    if (imageFile != null) request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    else if (imageBytes != null && imageName != null) request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) return Product.fromJson(json.decode(response.body));
    throw Exception('Failed to update product: ${response.body}');
  }

  Future<void> deleteProduct(String id) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(Uri.parse('$_baseUrl/$id/'), headers: headers);
    if (response.statusCode != 204) throw Exception('Failed to delete product: ${response.body}');
  }
}