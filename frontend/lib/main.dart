// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/login_screen.dart';
import 'screens/root_navigator.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://esnnxxoejubjrukpimsh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVzbm54eG9lanVianJ1a3BpbXNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwMTA5NTIsImV4cCI6MjA2OTU4Njk1Mn0.pgPf1tyMgu8gKYo7HdKQkhYVAZoxhrBygkgPd1XE0kY',
  );

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

final supabase = Supabase.instance.client;

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
          // Use 'isAuthenticated' which is the correct getter in the new UserProvider
          home: userProvider.isAuthenticated
              ? const RootNavigator()
              : const LoginScreen(),
        );
      },
    );
  }
}