// lib/services/stock_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockLog {
  final String logId;
  final String product;
  final int change;
  final String? reason;
  final String? createdBy;
  final DateTime createdAt;

  StockLog({
    required this.logId,
    required this.product,
    required this.change,
    this.reason,
    this.createdBy,
    required this.createdAt,
  });

  factory StockLog.fromJson(Map<String, dynamic> json) {
    return StockLog(
      logId: json['log_id'] as String,
      product: json['product'].toString(),
      change: (json['change'] ?? 0) as int,
      reason: json['reason']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class StockService {
  final String baseUrl;
  final String? authToken;

  StockService({required this.baseUrl, this.authToken});

  Uri get _logsUrl => Uri.parse('$baseUrl/api/inventory/logs/');
  Uri get _adjustUrl => Uri.parse('$baseUrl/api/inventory/adjust/');

  Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken != null) headers['Authorization'] = 'Bearer $authToken';
    return headers;
  }

  Future<List<StockLog>> fetchLogs({Map<String, String>? queryParameters}) async {
    final uri = (_logsUrl).replace(queryParameters: queryParameters ?? {});
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode != 200) throw Exception('Failed to fetch logs');
    final list = jsonDecode(res.body) as List;
    return list.map((e) => StockLog.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StockLog> adjustStock({required String productId, required int change, String reason = ''}) async {
    final body = jsonEncode({'product': productId, 'change': change, 'reason': reason});
    final res = await http.post(_adjustUrl, headers: _headers(), body: body);
    if (res.statusCode != 201) {
      throw Exception('Failed to adjust stock: ${res.statusCode} ${res.body}');
    }
    return StockLog.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
