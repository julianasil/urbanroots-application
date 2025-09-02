import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Mock signup method
  Future<void> signUp({
    required String fullName,
    required String username,
    String? email,
    required String password,
  }) async {
    // Simulate a network request delay
    await Future.delayed(const Duration(seconds: 2));

    // Create a dummy user (in a real case, you'd send data to the backend)
    _currentUser = User(username: username, fullName: fullName);
    notifyListeners();

    if (kDebugMode) {
      print("User signed up -> fullName: $fullName, username: $username, email: $email");
    }
  }

  /// Mock login method
  Future<void> login({
    required String username,
    required String password,
  }) async {
    // Simulate a backend authentication delay
    await Future.delayed(const Duration(seconds: 2));

    // Pretend login success if username & password are not empty
    if (username.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        username: username,
        fullName: "Full Name of $username",
      );
      notifyListeners();

      if (kDebugMode) {
        print("User logged in -> username: $username");
      }
    } else {
      throw Exception("Invalid username or password");
    }
  }

  /// Log out the current user
  void logout() {
    _currentUser = null;
    notifyListeners();

    if (kDebugMode) {
      print("User logged out");
    }
  }
}
