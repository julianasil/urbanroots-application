// frontend/lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ApiService {
  // --- CONFIGURATION ---
  // The base URL for your Django backend API.
  // IMPORTANT: Make sure this is the correct IP for your testing setup.
  // Use 'http://10.0.2.2:8000' for the Android Emulator.
  // Use 'http://127.0.0.1:8000' for testing in a Chrome web browser.
  final String _baseUrl = 'http://127.0.0.1:8000/api/auth';

  // --- PRIVATE HELPER METHOD ---
  // This private function gets the Supabase JWT and creates the standard headers.
  // Using this in every API call prevents code duplication and makes your service cleaner.
  Future<Map<String, String>> _getAuthHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      // This will be caught by the calling function.
      throw Exception('Not authenticated with Supabase. No active session.');
    }
    
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  // --- API METHODS ---

  /// Fetches the authenticated user's detailed profile from your Django backend.
  Future<UserProfile> getMyProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/user/'), // This endpoint now points to your UserProfileView
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Successfully fetched the data, now parse it.
        return UserProfile.fromJson(json.decode(response.body));
      } else {
        // The server responded with an error, provide details for debugging.
        print('API Error - getMyProfile: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load profile from server.');
      }
    } catch (e) {
      // Catches errors from _getAuthHeaders (like no session) or network issues.
      print('Service Error - getMyProfile: $e');
      rethrow; // Pass the error up to the UI to be handled.
    }
  }

  /// Creates a new Business Profile for the currently authenticated user.
  /// The [profileData] parameter should be a Map containing keys like 'company_name',
  /// 'contact_number', 'address', and 'business_type'.
  Future<void> createMyProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/profile/create/'), // Endpoint for BusinessProfileCreateView
        headers: headers,
        body: json.encode(profileData),
      );

      // HTTP 201 "Created" is the standard success code for a POST request.
      if (response.statusCode != 201) {
        print('API Error - createMyProfile: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to create profile on server.');
      }
    } catch (e) {
      print('Service Error - createMyProfile: $e');
      rethrow;
    }
  }

  Future<List<BusinessProfile>> getUnclaimedProfiles() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/profiles/unclaimed/'), // New endpoint
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> profilesJson = json.decode(response.body);
      return profilesJson.map((json) => BusinessProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load unclaimed profiles.');
    }
  }

  Future<void> claimProfile(String profileId) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/profile/claim/'), // New endpoint
      headers: headers,
      body: json.encode({'profile_id': profileId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to claim profile.');
    }
  }
}