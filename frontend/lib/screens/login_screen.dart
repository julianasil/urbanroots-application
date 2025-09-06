// frontend/lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/auth_layout.dart';
import 'root_navigator.dart';
import 'signup_screen.dart'; // Re-import the signup screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // FIX: Changed from _usernameController to _emailController
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // FIX: Call the provider's login method with email
      await Provider.of<UserProvider>(context, listen: false).login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // On successful login, the UserProvider's listener will trigger a rebuild
      // in main.dart, which will navigate to the RootNavigator automatically.
      // This explicit navigation is a good fallback.
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RootNavigator()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid email or password. Please try again.';
      });
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome Back!',
      subtitle: 'Log in to your UrbanRoots account',
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            // FIX: Updated the TextFormField to handle email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter your email' : null,
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
      
      // FIX: Re-added the secondary button to navigate to the SignUpScreen
      secondaryText: "Don't have an account?",
      secondaryButtonText: 'Sign Up',
      onSecondaryButtonPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      },
    );
  }
}