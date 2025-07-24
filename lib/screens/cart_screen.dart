// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'orders_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  TextButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () {
                            // 1) Add the order
                            Provider.of<OrderProvider>(context, listen: false)
                                .addOrder(
                                  cart.items.values.toList(),
                                  cart.totalAmount,
                                );
                            // 2) Clear the cart
                            cart.clear();
                            // 3) Navigate to OrdersScreen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OrdersScreen(),
                              ),
                            );
                          },
                    child: const Text(
                      'CHECKOUT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('No items in cart.'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      final productId = cart.items.keys.toList()[i];
                      return Dismissible(
                        key: ValueKey(cartItem.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          cart.removeItem(productId);
                        },
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: FittedBox(
                              child: Text('\$${cartItem.price}'),
                            ),
                          ),
                          title: Text(cartItem.title),
                          subtitle: Text(
                            'Total: \$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                          ),
                          trailing: Text('${cartItem.quantity} x'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
