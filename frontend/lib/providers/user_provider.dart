// frontend/lib/providers/user_provider.dart
import 'dart:async';
import 'dart:convert'; // Required for http response decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Required for fetchUserProfile
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';

class UserProvider with ChangeNotifier {
  final UserService userService;
  late final StreamSubscription<supabase.AuthState> _authStateSubscription;
  final ProductProvider productProvider;
  final OrderProvider orderProvider;

  // --- NEW: State for the user's detailed profile ---
  UserProfile? _user;
  List<BusinessProfile> _myBusinessProfiles = [];
  bool _isLoadingProfiles = false;
  String? _profileError;
  BusinessProfile? _activeBusinessProfile;
  

  UserProvider({required this.userService, required this.productProvider, required this.orderProvider}) {
    _authStateSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      
       if (data.event == supabase.AuthChangeEvent.signedIn) {
        // When user signs in, trigger the master data fetch.
        fetchInitialData();
      } 
      else if (event == supabase.AuthChangeEvent.signedOut) {
        // Clear all user-related data
        _user = null;
        _myBusinessProfiles = [];
        _activeBusinessProfile = null;
        _profileError = null;
        notifyListeners();
      }
    });

    // Initial check on app startup
    if (currentUser != null) {
      fetchInitialData();
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  // --- Getters ---
  supabase.User? get currentUser => supabase.Supabase.instance.client.auth.currentUser;
  UserProfile? get user => _user; // Getter for our detailed user profile
  bool get isAuthenticated => currentUser != null;
  List<BusinessProfile> get myBusinessProfiles => _myBusinessProfiles;
  bool get isLoadingProfiles => _isLoadingProfiles;
  String? get profileError => _profileError;
  BusinessProfile? get activeBusinessProfile => _activeBusinessProfile;

  Future<void> fetchInitialData() async {
    _isLoadingProfiles = true;
    _profileError = null;
    notifyListeners();
    try {
      // 1. Fetch the user's core profile first.
      await fetchUserProfile();
      await fetchMyBusinessProfiles();

      // 2. AFTER the user profile is loaded, trigger the other data loads.
      // We don't need to await these, as their providers will handle loading state.
      productProvider.loadProducts();
      orderProvider.fetchAndSetOrders();
      orderProvider.fetchAndSetSales();

    } catch (e) {
      _profileError = "Failed to load initial data: ${e.toString()}";
    } finally {
      _isLoadingProfiles = false;
      notifyListeners();
    }
  }

  // --- NEW: Method to update the user's profile ---
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      // Call the service to send the data to the API
      final updatedUserData = await userService.updateUserProfile(profileData);
      
      // Update the local state with the response from the server
      _user = UserProfile.fromJson(updatedUserData);
      
      // Notify all listeners that the user data has changed
      notifyListeners();
    } catch (e) {
      // Rethrow to let the UI handle the error message
      rethrow;
    }
  }

  // --- NEW: Method to fetch the detailed user profile from our backend ---
  Future<void> fetchUserProfile() async {
    if (currentUser == null) return;
    
    try {
      final session = supabase.Supabase.instance.client.auth.currentSession;
      if (session == null) return;
      
      final headers = {
        'Authorization': 'Bearer ${session.accessToken}',
      };
      // This is a direct API call because it's a simple GET request.
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/users/me/'),
        headers: headers
      );

      if (response.statusCode == 200) {
        _user = UserProfile.fromJson(json.decode(response.body));
        notifyListeners();
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      _profileError = e.toString();
      notifyListeners();
    }
  }
  
  // --- Methods (Existing) ---
  Future<void> fetchMyBusinessProfiles() async {
    _isLoadingProfiles = true;
    _profileError = null;
    notifyListeners();
    try {
      _myBusinessProfiles = await userService.fetchMyBusinessProfiles();
      if (_myBusinessProfiles.isNotEmpty) {
        if (_activeBusinessProfile == null || !_myBusinessProfiles.any((p) => p.profileId == _activeBusinessProfile!.profileId)) {
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

  Future<void> joinBusinessProfile(String profileId) async {
    try {
      await userService.joinBusinessProfile(profileId);
      await fetchMyBusinessProfiles();
    } catch (e) {
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