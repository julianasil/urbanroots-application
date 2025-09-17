// frontend/lib/widgets/order_progress_stepper.dart
import 'package:flutter/material.dart';

// Assuming you have this extension defined, e.g., in user_profile.dart
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class OrderProgressStepper extends StatelessWidget {
  final String currentStatus;
  const OrderProgressStepper({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    // --- THIS IS THE MAIN LOGIC CHANGE ---
    // First, check for the special 'cancelled' case.
    if (currentStatus.toLowerCase() == 'cancelled') {
      return _buildCancelledView(context);
    }

    // If not cancelled, build the normal progress stepper.
    final statuses = ['pending', 'confirmed', 'shipped', 'completed'];
    int currentIndex = statuses.indexOf(currentStatus.toLowerCase());
    // If status is not in the list (e.g., 'ordered'), default to the first step.
    if (currentIndex == -1) currentIndex = 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Progress', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            // Use a Stack to draw connecting lines behind the icons
            Stack(
              alignment: Alignment.center,
              children: [
                // The grey background line
                Positioned(
                  left: 30, right: 30, top: 12,
                  child: Container(height: 2, color: Colors.grey[300]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(statuses.length, (index) {
                    return _buildStep(
                      context,
                      title: statuses[index].capitalize(),
                      icon: _getIconForStatus(statuses[index]),
                      isActive: index <= currentIndex,
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW WIDGET for the CANCELLED state ---
  Widget _buildCancelledView(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.red[50], // Give it a subtle red background
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red[700], size: 28),
            const SizedBox(width: 16),
            Text(
              'Order Cancelled',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper to get an appropriate icon for each step
  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'pending': return Icons.access_time;
      case 'confirmed': return Icons.check_circle_outline;
      case 'shipped': return Icons.local_shipping_outlined;
      case 'completed': return Icons.task_alt;
      default: return Icons.circle;
    }
  }

  // Improved step widget
  Widget _buildStep(BuildContext context, {required String title, required IconData icon, required bool isActive}) {
    final color = isActive ? Theme.of(context).primaryColor : Colors.grey;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}