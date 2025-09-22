// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urbanroots_application/services/user_service.dart';
import 'services/product_service.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/login_screen.dart';
import 'screens/root_navigator.dart';
import 'theme.dart'; // <-- IMPORT YOUR NEW THEME FILE

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://esnnxxoejubjrukpimsh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVzbm54eG9lanVianJ1a3BpbXNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwMTA5NTIsImV4cCI6MjA2OTU4Njk1Mn0.pgPf1tyMgu8gKYo7HdKQkhYVAZoxhrBygkgPd1XE0kY',
  );

  //final productService = ProductService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider(service: ProductService())),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider(userId: 'temp_user_id')),
        
        // 2. The ProxyProvider creates a provider that depends on others.
        // It listens to ProductProvider and OrderProvider and provides a UserProvider.
        ChangeNotifierProxyProvider2<ProductProvider, OrderProvider, UserProvider>(
          // This is called once to create the initial UserProvider instance.
          create: (context) => UserProvider(
            userService: UserService(),
            // Get the other providers from the context.
            productProvider: Provider.of<ProductProvider>(context, listen: false),
            orderProvider: Provider.of<OrderProvider>(context, listen: false),
          ),
          // This is called whenever ProductProvider or OrderProvider updates.
          // It provides the existing UserProvider instance to the widget tree.
          update: (context, productProv, orderProv, userProv) => userProv!,
        ),
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
          debugShowCheckedModeBanner: false, // Recommended to hide the debug banner
          
          // --- THEME IS NOW APPLIED WITH ONE CLEAN LINE ---
          theme: urbanRootsTheme, 
          
          home: userProvider.isAuthenticated
              ? const RootNavigator()
              : const LoginScreen(),
        );
      },
    );
  }
}