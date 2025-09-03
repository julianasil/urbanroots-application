// lib/widgets/auth_layout.dart
import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final String mainButtonText;
  final VoidCallback onMainButtonPressed;
  final bool isLoading;
  final String? errorMessage;
  
  // --- FIX: Make these parameters optional by adding '?' and removing 'required' ---
  final String? secondaryText;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.mainButtonText,
    required this.onMainButtonPressed,
    this.isLoading = false,
    this.errorMessage,
    // No longer required
    this.secondaryText,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header...
                const Icon(Icons.eco, size: 60, color: Color(0xFF4CAF50)),
                const SizedBox(height: 20),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 40),

                // Form
                form,
                const SizedBox(height: 24),

                // Error Message...
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ),

                // Main Button...
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: onMainButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: Text(mainButtonText),
                      ),
                const SizedBox(height: 24),

                // --- FIX: Conditionally render the secondary action ---
                // This section will only be built if all the necessary parameters are provided.
                if (secondaryText != null && secondaryButtonText != null && onSecondaryButtonPressed != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(secondaryText!, style: TextStyle(color: Colors.grey[700])),
                      TextButton(
                        onPressed: onSecondaryButtonPressed,
                        child: Text(
                          secondaryButtonText!,
                          style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}