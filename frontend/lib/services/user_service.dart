// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart'; 

class UserService {
  final String _baseUrl = 'http://127.0.0.1:8000/api/users';
  
  Future<Map<String, String>> _getAuthHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('User is not authenticated.');
    }
    return {
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  /// Fetches a list of all business profiles the current user is a member of.
  Future<List<BusinessProfile>> fetchMyBusinessProfiles() async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/business/my-profiles/');
    
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BusinessProfile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch business profiles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while fetching business profiles: $e');
    }
  }

  // --- MODIFIED: Renamed and updated for the "Open Joining" flow ---

  /// Fetches a list of all business profiles that a user can join.
  Future<List<BusinessProfile>> fetchJoinableBusinessProfiles() async {
    final headers = await _getAuthHeaders();
    // MODIFIED: Calling the new '/joinable/' URL
    final uri = Uri.parse('$_baseUrl/business/joinable/');
    
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BusinessProfile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch joinable profiles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Sends a request for the current user to join a specific business profile.
  Future<void> joinBusinessProfile(String profileId) async {
    final headers = await _getAuthHeaders();
    headers['Content-Type'] = 'application/json; charset=UTF-8';
    
    // MODIFIED: Calling the new '/join/' URL
    final uri = Uri.parse('$_baseUrl/business/join/');
    final body = json.encode({'profile_id': profileId});
    
    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to join profile.');
      }
    } catch (e) {
      rethrow;
    }
  }
}