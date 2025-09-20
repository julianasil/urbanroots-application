// lib/models/seller_report.dart

// Represents the main JSON object from /api/reports/seller-summary/
class SellerReport {
  final ReportSummary summary;
  final List<TopSellingProduct> topProducts;

  // --- MODIFIED: The chart data is no longer part of this main model ---
  // We've removed `dailySalesChartData` because it will be fetched separately
  // and managed directly in the ReportProvider for better state separation.
  SellerReport({
    required this.summary,
    required this.topProducts,
  });

  factory SellerReport.fromJson(Map<String, dynamic> json) {
    return SellerReport(
      summary: ReportSummary.fromJson(json['summary']),
      topProducts: (json['top_products'] as List)
          .map((item) => TopSellingProduct.fromJson(item))
          .toList(),
    );
  }
}

// --- (No changes are needed for the classes below) ---

// Represents the 'summary' object inside the main report
class ReportSummary {
  final double totalRevenue;
  final int productsSold;
  final int totalOrders;

  ReportSummary({
    required this.totalRevenue,
    required this.productsSold,
    required this.totalOrders,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      productsSold: json['products_sold'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
    );
  }
}

// Represents an item in the 'top_products' list
class TopSellingProduct {
  final String productName;
  final int totalQuantity;

  TopSellingProduct({required this.productName, required this.totalQuantity});

  factory TopSellingProduct.fromJson(Map<String, dynamic> json) {
    return TopSellingProduct(
      productName: json['product_name'] as String? ?? 'Unknown Product',
      totalQuantity: json['total_quantity'] as int? ?? 0,
    );
  }
}

// This class is now used independently by the chart data fetch.
// Its structure is correct and requires no changes.
class DailySale {
  final DateTime date;
  final double revenue;

  DailySale({required this.date, required this.revenue});

  factory DailySale.fromJson(Map<String, dynamic> json) {
    return DailySale(
      date: DateTime.parse(json['date']),
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}