// lib/services/reports_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/seller_report.dart';

class ReportsService {
  final String _baseUrl = 'http://127.0.0.1:8000/api/reports';

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

  /// Fetches the seller summary report from the backend API.
  Future<SellerReport> fetchSellerReport() async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/seller-summary/');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SellerReport.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load report: ${errorData['detail'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('A network error occurred: $e');
    }
  }

  // --- NEW: Method to fetch the daily sales data for the chart ---
  Future<List<DailySale>> fetchDailySales() async {
    final headers = await _getAuthHeaders();
    // This calls the new endpoint we created on the backend.
    final uri = Uri.parse('$_baseUrl/daily-summary/');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        // The backend returns a list of objects directly.
        final List<dynamic> data = json.decode(response.body);
        // We map the list of JSON objects into a list of DailySale model instances.
        return data.map((item) => DailySale.fromJson(item)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load chart data: ${errorData['detail'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('A network error occurred while fetching chart data: $e');
    }
  }
}