// frontend/lib/providers/user_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_profile.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService userService;
  late final StreamSubscription<supabase.AuthState> _authStateSubscription;

  List<BusinessProfile> _myBusinessProfiles = [];
  bool _isLoadingProfiles = false;
  String? _profileError;
  BusinessProfile? _activeBusinessProfile;

  UserProvider({required this.userService}) {
    if (currentUser != null) {
      fetchMyBusinessProfiles();
    }
    _authStateSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == supabase.AuthChangeEvent.signedIn) {
        fetchMyBusinessProfiles();
      } 
      else if (event == supabase.AuthChangeEvent.signedOut) {
        _myBusinessProfiles = [];
        _activeBusinessProfile = null;
        _profileError = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  // --- Getters ---
  supabase.User? get currentUser => supabase.Supabase.instance.client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  List<BusinessProfile> get myBusinessProfiles => _myBusinessProfiles;
  bool get isLoadingProfiles => _isLoadingProfiles;
  String? get profileError => _profileError;
  BusinessProfile? get activeBusinessProfile => _activeBusinessProfile;

  // --- Methods ---
  Future<void> fetchMyBusinessProfiles() async {
    _isLoadingProfiles = true;
    _profileError = null;
    notifyListeners();
    try {
      _myBusinessProfiles = await userService.fetchMyBusinessProfiles();
      if (_myBusinessProfiles.isNotEmpty) {
        if (_activeBusinessProfile == null || !_myBusinessProfiles.contains(_activeBusinessProfile)) {
          _activeBusinessProfile = _myBusinessProfiles.first;
        }
      } else {
        _activeBusinessProfile = null;
      }
    } catch (e) {
      _profileError = e.toString();
    } finally {
      _isLoadingProfiles = false;
      notifyListeners();
    }
  }

  void setActiveBusinessProfile(BusinessProfile profile) {
    if (_myBusinessProfiles.contains(profile)) {
      _activeBusinessProfile = profile;
      notifyListeners();
    }
  }

  // MODIFIED: Renamed from claimBusinessProfile to joinBusinessProfile
  Future<void> joinBusinessProfile(String profileId) async {
    try {
      // Calls the corresponding 'join' method in the service
      await userService.joinBusinessProfile(profileId);
      
      // On success, refresh the list of the user's profiles, which will
      // also update the active profile.
      await fetchMyBusinessProfiles();

    } catch (e) {
      // Rethrow the error so the UI can catch it and show a message
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await supabase.Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await supabase.Supabase.instance.client.auth.signOut();
  }
}