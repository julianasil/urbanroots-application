// lib/providers/report_provider.dart
import 'package:flutter/foundation.dart';
import '../models/seller_report.dart';
import '../services/reports_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportsService _reportsService;
  
  // --- State for the main summary report ---
  SellerReport? _report;
  bool _isLoading = false;
  String? _error;

  // --- NEW: State specifically for the chart data ---
  List<DailySale> _dailySales = [];
  bool _isChartLoading = false;
  String? _chartError;

  // The constructor requires a ReportsService instance.
  ReportProvider({required ReportsService reportsService}) : _reportsService = reportsService;

  // --- Public Getters for summary state ---
  SellerReport? get report => _report;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // --- NEW: Public Getters for chart state ---
  List<DailySale> get dailySales => _dailySales;
  bool get isChartLoading => _isChartLoading;
  String? get chartError => _chartError;

  /// Fetches BOTH the summary report and the daily sales data in parallel.
  Future<void> getSellerReport() async {
    // Set loading states for both parts of the UI.
    _isLoading = true;
    _isChartLoading = true;
    // Clear previous errors.
    _error = null;
    _chartError = null;
    notifyListeners();

    try {
      // Use Future.wait to fetch both sets of data concurrently for better performance.
      // This kicks off both API calls at the same time.
      final results = await Future.wait([
        _reportsService.fetchSellerReport(),
        _reportsService.fetchDailySales(),
      ]);

      // The results list will contain the return values in the same order.
      // We safely cast them to their expected types.
      _report = results[0] as SellerReport;
      _dailySales = results[1] as List<DailySale>;

    } catch (e) {
      // If either fetch fails, we'll record the error for both.
      // For a more advanced app, you might want separate error handling.
      final errorMessage = e.toString();
      _error = errorMessage;
      _chartError = errorMessage;
      
      // Also clear the data on failure to avoid showing stale info.
      _report = null;
      _dailySales = [];

    } finally {
      // Always set loading states to false when the operation is complete.
      _isLoading = false;
      _isChartLoading = false;
      notifyListeners();
    }
  }
}