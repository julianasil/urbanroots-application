// frontend/lib/providers/order_provider.dart
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart'; // Import the service that fetches orders

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<Order> _sales = [];
  bool _isLoading = false;
  String? _error;

  // Public getters to access the state
  List<Order> get orders => [..._orders];
  List<Order> get sales => [..._sales];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAndSetOrders() async {
    _isLoading = true;
    _error = null;
    // Notify listeners that loading has started.
    // This is safe if called from a user action like pull-to-refresh.
    //notifyListeners(); 

    try {
      // Fetch the data from the service
      final loadedOrders = await ApiService().getMyOrders();
      _orders = loadedOrders;
    } catch (e) {
      _error = e.toString();
      print(_error); // Print the error for debugging
    }

    _isLoading = false;
    // CRITICAL: Notify listeners that loading is finished and new data is available.
    notifyListeners();
  }

  Future<void> cancelOrder(String orderId) async {
  try {
    // Call the service to perform the action on the backend
    await ApiService().cancelOrder(orderId);
    
    // Find the order in our local list
    final index = _orders.indexWhere((order) => order.orderId == orderId);
    if (index != -1) {
      // Update its status locally to 'cancelled'
      // This avoids a full refresh and makes the UI feel instant
      _orders[index] = Order(
        // copy existing data
        orderId: _orders[index].orderId,
        orderDate: _orders[index].orderDate,
        totalAmount: _orders[index].totalAmount,
        shippingAddress: _orders[index].shippingAddress,
        trackingNumber: _orders[index].trackingNumber,
        items: _orders[index].items,
        // update the status
        status: 'cancelled',
      );
      notifyListeners(); // Update the UI
    }
  } catch (e) {
    // Re-throw the error so the UI can display it
    rethrow;
  }
}

  Future<void> fetchAndSetSales() async {
    _isLoading = true;
    _error = null;
    //notifyListeners();
    try {
      _sales = await ApiService().getMySales();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }
}