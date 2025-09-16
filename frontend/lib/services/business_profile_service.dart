// lib/services/business_profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class BusinessProfileService {
  // The base URL for business-related endpoints
  final String _baseUrl = 'http://127.0.0.1:8000/api/users';
  
  Future<Map<String, String>> _getAuthHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception('Not authenticated. No active session.');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  /// Creates a new Business Profile.
  Future<BusinessProfile> createProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getAuthHeaders();
      // CORRECT URL: /api/users/business/create/
      final response = await http.post(
        Uri.parse('$_baseUrl/business/create/'),
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode == 201) {
        return BusinessProfile.fromJson(json.decode(response.body));
      } else {
        print('API Error - createProfile: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to create profile on server.');
      }
    } catch (e) {
      print('Service Error - createProfile: $e');
      rethrow;
    }
  }

  /// Updates an existing Business Profile.
  Future<BusinessProfile> updateProfile(String profileId, Map<String, dynamic> profileData) async {
    try {
      final headers = await _getAuthHeaders();
      // CORRECT URL: /api/users/business/<profile_id>/
      final response = await http.patch( // Use PATCH for partial updates
        Uri.parse('$_baseUrl/business/$profileId/'),
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        return BusinessProfile.fromJson(json.decode(response.body));
      } else {
        print('API Error - updateProfile: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to update profile on server.');
      }
    } catch (e) {
      print('Service Error - updateProfile: $e');
      rethrow;
    }
  }
}