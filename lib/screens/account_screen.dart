// lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/order_provider.dart';
import 'login_screen.dart'; // To navigate back after logout
import 'orders_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final orderProv = Provider.of<OrderProvider>(context);
    final ordersCount = orderProv.orders.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: user == null
          ? const Center(child: Text('No user logged in.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      (user.fullName.isNotEmpty ? user.fullName.substring(0, 1) : '?')
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  // Account details
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text('${user.username}@example.com'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Full Name'),
                          subtitle: Text(user.fullName),
                        ),
                        const Divider(height: 1),
                        // Orders ListTile - navigates to OrdersScreen
                        ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: const Text('My Orders'),
                          subtitle: Text('$ordersCount orders'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OrdersScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                    onPressed: () {
                      userProvider.logout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
