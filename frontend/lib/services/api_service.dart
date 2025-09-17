// frontend/lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/order.dart';

class ApiService {
  // MODIFIED: Base URL now points to the correct auth endpoint root
  final String _baseUrl = 'http://127.0.0.1:8000/api'; // Changed from /api/auth

  Future<Map<String, String>> _getAuthHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception('Not authenticated. No active session.');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  /// Fetches the authenticated user's detailed profile from your Django backend.
  Future<UserProfile> getMyProfile() async {
    try {
      final headers = await _getAuthHeaders();
      // MODIFIED: The endpoint for user details is now under /users/me/
      final response = await http.get(Uri.parse('$_baseUrl/auth/user/'), headers: headers);

      if (response.statusCode == 200) {
        return UserProfile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load profile from server. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createOrder(List<Map<String, dynamic>> cartItems, String shippingAddress) async {
    final headers = await _getAuthHeaders();
    final body = json.encode({
      'cart_items': cartItems,
      'shipping_address': shippingAddress,
    });
    
    final response = await http.post(
      Uri.parse('$_baseUrl/orders/'), // The new endpoint
      headers: headers,
      body: body,
    );
    
    if (response.statusCode != 201) {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<List<Order>> getMyOrders() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/'), // The endpoint for the OrderListCreateView
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = json.decode(response.body);
        // Map the JSON list to a list of Order objects
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch orders: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
  final headers = await _getAuthHeaders();
  // The endpoint includes the orderId
  final uri = Uri.parse('$_baseUrl/orders/$orderId/cancel/');
  
  // We use a POST request for actions that change state.
  final response = await http.post(uri, headers: headers);

  if (response.statusCode != 200) {
    // Try to parse the error message from the backend for a better user experience
    final errorBody = json.decode(response.body);
    final errorMessage = errorBody['error'] ?? 'Failed to cancel order.';
    throw Exception(errorMessage);
    }
  }

  Future<Order> getOrderDetails(String orderId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      // We need to build the Django endpoint for this next
      Uri.parse('$_baseUrl/orders/$orderId/'), 
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load order details: ${response.body}');
    }
  }

  Future<List<Order>> getMySales() async {
  final headers = await _getAuthHeaders();
  final response = await http.get(
    Uri.parse('$_baseUrl/orders/sales/'), // The new endpoint
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> ordersJson = json.decode(response.body);
    return ordersJson.map((json) => Order.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch sales: ${response.body}');
    }
  }

  Future<Order> getSaleDetails(String orderId) async {
  final headers = await _getAuthHeaders();
  // Call the new, dedicated endpoint
  final response = await http.get(
    Uri.parse('$_baseUrl/orders/sales/$orderId/'), 
    headers: headers,
  );

  if (response.statusCode == 200) {
    return Order.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load sale details: ${response.body}');
  }
}
}