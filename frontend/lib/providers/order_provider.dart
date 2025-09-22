// frontend/lib/providers/order_provider.dart
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<Order> _sales = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => [..._orders];
  List<Order> get sales => [..._sales];
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches a user's own placed orders from the backend.
  Future<void> fetchAndSetOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify UI that loading has started
    try {
      final loadedOrders = await ApiService().getMyOrders();
      _orders = loadedOrders;
      _error = null; // Clear any previous errors on success
    } catch (e) {
      _error = e.toString(); // Store the error message
      print("Error fetching orders: $_error");
    }
    _isLoading = false;
    notifyListeners(); // Notify UI that loading is finished (with either data or an error)
  }
  
  /// Fetches sales received by the user from the backend.
  Future<void> fetchAndSetSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loadedSales = await ApiService().getMySales();
      _sales = loadedSales;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print("Error fetching sales: $_error");
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Cancels an order and updates its status in the local list.
  Future<void> cancelOrder(String orderId) async {
    try {
      await ApiService().cancelOrder(orderId);
      final index = _orders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: 'cancelled');
        notifyListeners();
      }
    } catch (e) {
      rethrow; // Here, rethrowing is OK because we want the UI action (button press) to report the failure.
    }
  }

  /// Updates the status of a sale in the local list.
  Future<void> manageSale(String orderId, {String? newStatus, String? trackingNumber}) async {
    try {
      final updatedSale = await ApiService().manageSale(orderId, newStatus: newStatus, trackingNumber: trackingNumber);
      final index = _sales.indexWhere((s) => s.orderId == orderId);
      if (index != -1) {
        _sales[index] = updatedSale;
        notifyListeners();
      }
    } catch (e) {
      rethrow; // Also OK to rethrow here for the button press.
    }
  }
}