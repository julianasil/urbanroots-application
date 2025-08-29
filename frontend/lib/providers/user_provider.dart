import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Fake login triggered by tapping the Login button
  void login() {
    // Create a dummy user; you can customize these details later
    _currentUser = User(username: 'demo_user', fullName: 'Demo User');
    notifyListeners();
  }

  /// Log out the current user
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
