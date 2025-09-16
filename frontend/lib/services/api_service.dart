// frontend/lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ApiService {
  // MODIFIED: Base URL now points to the correct auth endpoint root
  final String _baseUrl = 'http://127.0.0.1:8000/api/users'; // Changed from /api/auth

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
      // MODIFIED: Corrected endpoint to /me/
      final response = await http.get(Uri.parse('$_baseUrl/me/'), headers: headers);

      if (response.statusCode == 200) {
        return UserProfile.fromJson(json.decode(response.body));
      } else {
        print('API Error - getMyProfile: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load profile from server.');
      }
    } catch (e) {
      print('Service Error - getMyProfile: $e');
      rethrow;
    }
  }

  // REMOVED: All business profile methods (create, getUnclaimed, claim) have been
  // moved to a dedicated BusinessProfileService for better organization.
}