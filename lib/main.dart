import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ Add Supabase

import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/login_screen.dart';
import 'screens/root_navigator.dart';

// ✅ Config class to keep Supabase keys in one place
class SupabaseConfig {
  static const String supabaseUrl = 'https://<your-project-id>.supabase.co';
  static const String supabaseAnonKey = '<your-anon-public-key>';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase before running the app
  await SupabaseConfig.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (ctx, userProvider, _) {
        return MaterialApp(
          title: 'UrbanRoots E-Commerce',
          theme: ThemeData(
            useMaterial3: true,

            // Core ColorScheme
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF50),
              primary: const Color(0xFF4CAF50),
              secondary: const Color(0xFFFFEB3B),
              background: Colors.white,
              surface: Colors.white,
            ),

            // Universal AppBar styling
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF4CAF50), // Green
              foregroundColor: Colors.white,       // Text & icons
              elevation: 2,
              centerTitle: true,
            ),
          ),
          home: userProvider.isLoggedIn
              ? const RootNavigator()
              : const LoginScreen(),
        );
      },
    );
  }
}
