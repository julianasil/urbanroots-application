// lib/services/product_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl;
  final String? authToken; // optional: pass token for write operations

  ProductService({required this.baseUrl, this.authToken});

  Uri _productsUrl([String path = '']) => Uri.parse('$baseUrl/api/products/$path');

  Map<String, String> _headers({bool jsonOnly = true}) {
    final headers = <String, String>{};
    if (authToken != null) headers['Authorization'] = 'Bearer $authToken';
    if (jsonOnly) headers['Content-Type'] = 'application/json';
    return headers;
  }

  Future<List<Product>> fetchProducts({Map<String, String>? queryParameters}) async {
    final url = _productsUrl();
    final uri = (queryParameters == null || queryParameters.isEmpty) ? url : url.replace(queryParameters: queryParameters);
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode != 200) throw Exception('Failed to fetch products: ${res.statusCode}');
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> fetchProduct(String id) async {
    final res = await http.get(_productsUrl('$id/'), headers: _headers());
    if (res.statusCode != 200) throw Exception('Failed to fetch product');
    return Product.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // Create product. If imageFile is provided, will upload as multipart.
  Future<Product> createProduct(Product product, {required String sellerProfileId, File? imageFile}) async {
    if (imageFile == null) {
      final body = jsonEncode(product.toCreateJson(sellerProfileId: sellerProfileId));
      final res = await http.post(_productsUrl(), headers: _headers(), body: body);
      if (res.statusCode != 201) throw Exception('Failed to create product: ${res.body}');
      return Product.fromJson(jsonDecode(res.body));
    } else {
      // multipart upload with image
      final uri = _productsUrl();
      final request = http.MultipartRequest('POST', uri);
      if (authToken != null) request.headers['Authorization'] = 'Bearer $authToken';
      // fields
      final fields = product.toCreateJson(sellerProfileId: sellerProfileId);
      fields.forEach((k, v) => request.fields[k] = v.toString());
      // image file
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode != 201) throw Exception('Failed to create product (multipart): ${res.body}');
      return Product.fromJson(jsonDecode(res.body));
    }
  }

  Future<Product> updateProduct(String id, Product product, {File? imageFile}) async {
    // If imageFile present -> PATCH multipart
    if (imageFile == null) {
      final body = jsonEncode(product.toUpdateJson());
      final res = await http.patch(_productsUrl('$id/'), headers: _headers(), body: body);
      if (res.statusCode != 200) throw Exception('Failed to update product: ${res.body}');
      return Product.fromJson(jsonDecode(res.body));
    } else {
      final uri = _productsUrl('$id/');
      final request = http.MultipartRequest('PATCH', uri);
      if (authToken != null) request.headers['Authorization'] = 'Bearer $authToken';
      product.toUpdateJson().forEach((k, v) => request.fields[k] = v.toString());
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode != 200) throw Exception('Failed to update product (multipart): ${res.body}');
      return Product.fromJson(jsonDecode(res.body));
    }
  }

  Future<void> deleteProduct(String id) async {
    final res = await http.delete(_productsUrl('$id/'), headers: _headers());
    if (res.statusCode != 204) throw Exception('Failed to delete product: ${res.body}');
  }
}
