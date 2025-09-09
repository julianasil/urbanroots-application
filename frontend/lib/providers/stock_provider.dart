// lib/providers/stock_provider.dart
import 'package:flutter/foundation.dart';
import '../services/stock_service.dart';

class StockProvider extends ChangeNotifier {
  final StockService service;
  List<StockLog> _logs = [];
  bool isLoading = false;
  String? error;

  StockProvider({required this.service});

  List<StockLog> get logs => _logs;

  Future<void> loadLogs({Map<String, String>? filters}) async {
    try {
      isLoading = true;
      notifyListeners();
      _logs = await service.fetchLogs(queryParameters: filters);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<StockLog> adjustStock({required String productId, required int change, String reason = ''}) async {
    final log = await service.adjustStock(productId: productId, change: change, reason: reason);
    _logs.insert(0, log);
    notifyListeners();
    return log;
  }
}
