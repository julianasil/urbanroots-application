// frontend/lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/order.dart';
import '../models/shipment.dart';

class ApiService {
  final String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, String>> _getAuthHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception('Not authenticated. No active session.');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  // --- USER & PROFILE METHODS ---
  Future<UserProfile> getMyProfile() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/auth/user/'), headers: headers);
    if (response.statusCode == 200) return UserProfile.fromJson(json.decode(response.body));
    throw Exception('Failed to load profile from server. Status: ${response.statusCode}');
  }

  // --- ORDER METHODS ---
  Future<void> createOrder(List<Map<String, dynamic>> cartItems, String shippingAddress) async {
    final headers = await _getAuthHeaders();
    final body = json.encode({'cart_items': cartItems, 'shipping_address': shippingAddress});
    final response = await http.post(Uri.parse('$_baseUrl/orders/'), headers: headers, body: body);
    if (response.statusCode != 201) throw Exception('Failed to create order: ${response.body}');
  }

  Future<List<Order>> getMyOrders() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/orders/'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> ordersJson = json.decode(response.body);
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch orders: ${response.body}');
  }
  
  Future<Order> getOrderDetails(String orderId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/orders/$orderId/'), headers: headers);
    if (response.statusCode == 200) return Order.fromJson(json.decode(response.body));
    throw Exception('Failed to load order details: ${response.body}');
  }

  Future<void> cancelOrder(String orderId) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/orders/$orderId/cancel/');
    final response = await http.post(uri, headers: headers);
    if (response.statusCode != 200) {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to cancel order.');
    }
  }

  // --- SALES METHODS ---
  Future<List<Order>> getMySales() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/orders/sales/'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> ordersJson = json.decode(response.body);
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch sales: ${response.body}');
  }

  Future<Order> getSaleDetails(String orderId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/orders/sales/$orderId/'), headers: headers);
    if (response.statusCode == 200) return Order.fromJson(json.decode(response.body));
    throw Exception('Failed to load sale details: ${response.body}');
  }

  Future<Order> manageSale(String orderId, {String? newStatus, String? trackingNumber}) async {
    final headers = await _getAuthHeaders();
    final bodyData = {'status': newStatus, 'tracking_number': trackingNumber}..removeWhere((key, value) => value == null);
    final response = await http.patch(Uri.parse('$_baseUrl/orders/sales/$orderId/manage/'), headers: headers, body: json.encode(bodyData));
    if (response.statusCode == 200) return Order.fromJson(json.decode(response.body));
    throw Exception('Failed to update sale: ${response.body}');
  }

  // --- SHIPMENT (LDMS) METHODS ---
  Future<List<LogisticsProvider>> getLogisticsProviders() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/shipments/providers/'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LogisticsProvider.fromJson(json)).toList();
    }
    throw Exception('Failed to load logistics providers.');
  }

  Future<Shipment> createShipment({
    required String orderId, required List<String> orderItemIds,
    required String logisticsProviderId, required String trackingNumber,
  }) async {
    final headers = await _getAuthHeaders();
    final body = json.encode({
      'order_id': orderId, 'order_item_ids': orderItemIds,
      'logistics_provider_id': logisticsProviderId, 'tracking_number': trackingNumber,
    });
    final response = await http.post(Uri.parse('$_baseUrl/shipments/create/'), headers: headers, body: body);
    if (response.statusCode == 201) return Shipment.fromJson(json.decode(response.body));
    throw Exception('Failed to create shipment: ${response.body}');
  }
  
  /// Allows the buyer to confirm a shipment has been delivered.
  Future<void> confirmDelivery(String shipmentId) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/shipments/$shipmentId/confirm-delivery/'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to confirm delivery: ${response.body}');
    }
  }
}