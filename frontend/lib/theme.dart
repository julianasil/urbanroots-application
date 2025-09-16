// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A centralized class for your app's colors for easy access and consistency.
class AppColors {
  static const primaryGreen = Color(0xFF4CAF50);
  static const accentYellow = Color(0xFFFFEB3B);
  static const background = Colors.white;
  static const surface = Colors.white;
  static const textDark = Color(0xFF2E2E2E);
}

// The main theme definition for the UrbanRoots application.
final ThemeData urbanRootsTheme = ThemeData(
  // Use Material 3 design for a modern look.
  useMaterial3: true,
  
  // 1. Color Scheme
  // Defines the primary set of colors that widgets will use by default.
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryGreen,
    primary: AppColors.primaryGreen,
    secondary: AppColors.accentYellow,
    background: AppColors.background,
    surface: AppColors.surface,
    brightness: Brightness.light,
  ),

  // 2. Component Themes
  // Defines the default styles for specific widgets across the app.
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryGreen, // Button background color
      foregroundColor: Colors.white, // Text and icon color
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2.0),
    ),
  ),

  // 3. Typography (Optional but recommended)
  // Uses the 'google_fonts' package for beautiful, consistent text styles.
  // To use this, add `google_fonts: ^6.2.1` to your pubspec.yaml
  textTheme: GoogleFonts.robotoTextTheme(),
);