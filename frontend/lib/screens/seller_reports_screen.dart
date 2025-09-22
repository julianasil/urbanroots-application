// lib/screens/seller_reports_screen.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/seller_report.dart';
import '../providers/report_provider.dart';
import '../providers/user_provider.dart';
import '../services/report_pdf_service.dart';
import '../widgets/stat_card.dart';

class SellerReportsScreen extends StatefulWidget {
  const SellerReportsScreen({super.key});

  @override
  State<SellerReportsScreen> createState() => _SellerReportsScreenState();
}

class _SellerReportsScreenState extends State<SellerReportsScreen> {
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).getSellerReport();
    });
  }

  Future<void> _exportToPdf() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF...')),
    );
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final report = reportProvider.report;
    final businessProfile = userProvider.activeBusinessProfile;

    if (report == null || businessProfile == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No report data available to export.')),
      );
      return;
    }

    try {
      Uint8List? chartImageBytes;
      try {
        RenderRepaintBoundary boundary = _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        chartImageBytes = byteData?.buffer.asUint8List();
      } catch (e) {
        print("Could not capture chart image: $e");
      }

      final pdfService = ReportPdfService();
      final Uint8List pdfBytes = await pdfService.generateReportPdf(
        report, 
        businessProfile,
        chartImage: chartImageBytes,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'business_report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );

    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _exportToPdf,
            tooltip: 'Export as PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ReportProvider>(context, listen: false).getSellerReport();
            },
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.isLoading && reportProvider.report == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (reportProvider.error != null && reportProvider.report == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('An error occurred: ${reportProvider.error}', textAlign: TextAlign.center),
              ),
            );
          }
          if (reportProvider.report == null) {
            return const Center(child: Text('No report data available. Pull down to refresh.'));
          }

          final report = reportProvider.report!;
          return RefreshIndicator(
            onRefresh: () => reportProvider.getSellerReport(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _SummarySection(summary: report.summary),
                const SizedBox(height: 24),
                
                // --- MODIFIED: The title is now outside the RepaintBoundary ---
                // We use a helper widget to keep the build method clean.
                _buildChartAndTitle(context, reportProvider),
                
                const SizedBox(height: 24),
                _TopProductsSection(topProducts: report.topProducts),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- NEW: Helper widget to structure the title and the chart together ---
  // This improves code organization and allows us to move the RepaintBoundary.
  Widget _buildChartAndTitle(BuildContext context, ReportProvider reportProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The title is now here, so it won't be captured in the PDF image.
        Text(
          'Revenue (Last 30 Days)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // The RepaintBoundary wraps ONLY the chart card itself.
        RepaintBoundary(
          key: _chartKey,
          child: _DailySalesChart(
            dailySales: reportProvider.dailySales,
            isLoading: reportProvider.isChartLoading,
            error: reportProvider.chartError,
          ),
        ),
      ],
    );
  }
}

// --- (No changes are needed for _SummarySection or _TopProductsSection) ---
class _SummarySection extends StatelessWidget {
  final ReportSummary summary;
  const _SummarySection({required this.summary});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        StatCard(
          title: 'Total Revenue',
          value: '₱${NumberFormat('#,##0.00').format(summary.totalRevenue)}',
          icon: Icons.attach_money,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatCard(title: 'Total Orders', value: summary.totalOrders.toString())),
            const SizedBox(width: 12),
            Expanded(child: StatCard(title: 'Products Sold', value: summary.productsSold.toString())),
          ],
        ),
      ],
    );
  }
}

// Renamed for clarity: This widget is now ONLY the chart itself inside the card.
class _DailySalesChart extends StatelessWidget {
  final List<DailySale> dailySales;
  final bool isLoading;
  final String? error;

  const _DailySalesChart({
    required this.dailySales,
    required this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).cardColor,
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: _buildChartContent(context),
      ),
    );
  }

  Widget _buildChartContent(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Could not load chart: $error', textAlign: TextAlign.center)));
    }
    if (dailySales.isEmpty) {
      return const Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('No sales data in the last 30 days.')));
    }

    final maxRevenue = dailySales.map((sale) => sale.revenue).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxRevenue * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final sale = dailySales[groupIndex];
                return BarTooltipItem(
                  '${DateFormat('MMM d').format(sale.date)}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '₱${sale.revenue.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 7 == 0 && value.toInt() < dailySales.length) {
                    final date = dailySales[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(DateFormat('d').format(date), style: const TextStyle(fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                // --- THE FIX: Smarter Y-axis label formatting ---
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value >= meta.max) return const Text('');
                  
                  // If the max value on the chart is less than 1000,
                  // show the plain integer value for better precision.
                  if (meta.max < 1000) {
                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                  }
                  
                  // Otherwise, format as "k" for thousands to save space.
                  return Text('${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          barGroups: dailySales.asMap().entries.map((entry) {
            final index = entry.key;
            final sale = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: sale.revenue,
                  color: Theme.of(context).colorScheme.primary,
                  width: 5,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TopProductsSection extends StatelessWidget {
  final List<TopSellingProduct> topProducts;
  const _TopProductsSection({required this.topProducts});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Selling Products', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: topProducts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No sales data yet.')),
                )
              : Column(
                  children: topProducts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text('${product.totalQuantity} units sold'),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}