// frontend/lib/providers/user_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// We no longer need the old User model defined here, as we rely on
// the Supabase User object for authentication status.

class UserProvider with ChangeNotifier {
  late final StreamSubscription<supabase.AuthState> _authStateSubscription;

  UserProvider() {
    // Start listening for authentication changes (login, logout, token refresh)
    _authStateSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  supabase.User? get currentUser => supabase.Supabase.instance.client.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<void> login({required String email, required String password}) async {
    try {
      // Use the Supabase SDK for login
      await supabase.Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    // Use the Supabase SDK for logout
    await supabase.Supabase.instance.client.auth.signOut();
  }
}