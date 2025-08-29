// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'root_navigator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _handleLogin(BuildContext context) {
    // Perform the fake login
    Provider.of<UserProvider>(context, listen: false).login();

    // Navigate to the main app
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RootNavigator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'UrbanRoots Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _handleLogin(context),
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
