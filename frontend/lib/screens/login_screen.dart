// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/auth_layout.dart';
import 'root_navigator.dart';
// We no longer need to import signup_screen.dart
// import 'signup_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<UserProvider>(context, listen: false).login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RootNavigator()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to log in. Please check your credentials.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The AuthLayout widget from our previous steps is now simplified
    return AuthLayout(
      title: 'Welcome Back!',
      subtitle: 'Log in to your UrbanRoots account',
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter your username' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter your password' : null,
            ),
          ],
        ),
      ),
      mainButtonText: 'Log In',
      onMainButtonPressed: _handleLogin,
      
      // --- THIS IS THE FIX ---
      // By removing the secondary button properties, the "Sign Up" link will disappear.
      //
      // REMOVE THE FOLLOWING THREE LINES:
      // secondaryText: "Don't have an account?",
      // secondaryButtonText: 'Sign Up',
      // onSecondaryButtonPressed: () { ... },
    );
  }
}