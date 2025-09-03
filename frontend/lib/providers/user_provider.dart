// frontend/lib/providers/user_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ... (User class remains the same)
class User {
  final String username;
  final String email;
  final String fullName;

  User({
    required this.username,
    required this.email,
    required this.fullName,
  });

   factory User.fromJson(Map<String, dynamic> json) {
    String firstName = json['first_name'] ?? '';
    String lastName = json['last_name'] ?? '';
    String fullName = '$firstName $lastName'.trim();

    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      // If the full name is empty after combining, fall back to the username.
      fullName: fullName.isEmpty ? (json['username'] ?? '') : fullName,
    );
  }
}


class UserProvider with ChangeNotifier {
  User? _currentUser;
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = 'http://127.0.0.1:8000/api/auth';

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> _fetchUserDetails(String token) async {
    final url = Uri.parse('$_baseUrl/user/');
    
    // --- ADD THIS PRINT STATEMENT ---
    // This will show us if the token is being correctly passed to this function.
    print('Attempting to fetch user details with token: $token');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token', 
      },
    );

    // This will show us what the server is responding with.
    print('User details response status: ${response.statusCode}');
    print('User details response body: ${response.body}');

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      _currentUser = User.fromJson(userData);
    } else {
      throw Exception('Failed to fetch user details.');
    }
  }

  Future<void> login({required String username, required String password}) async {
    final url = Uri.parse('$_baseUrl/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['key'];

        if (token == null) {
          throw Exception('Authentication token was not found in the response.');
        }

        // --- ADD THIS PRINT STATEMENT ---
        // This will show us if the token is being correctly received from Django.
        print('Login successful. Received Token: $token');

        await _storage.write(key: 'authToken', value: token);
        await _fetchUserDetails(token);
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['non_field_errors']?.join(', ') ?? 'Failed to log in');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ... (logout function remains the same)
  Future<void> logout() async {
    final token = await _storage.read(key: 'authToken');
    if (token == null) return;

    final url = Uri.parse('$_baseUrl/logout/');
    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
    } finally {
      _currentUser = null;
      await _storage.delete(key: 'authToken');
      notifyListeners();
    }
  }
}

