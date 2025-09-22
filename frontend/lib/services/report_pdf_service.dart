// lib/services/report_pdf_service.dart
//import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart'; // --- NEW: Required to load font assets from your project ---
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/seller_report.dart'; // Your data model
import '../models/user_profile.dart'; // For the business name

class ReportPdfService {
  
  Future<Uint8List> generateReportPdf(
    SellerReport report, 
    BusinessProfile businessProfile, {
    Uint8List? chartImage,
  }) async {
    final pdf = pw.Document();

    // --- NEW: Load the custom font from your local project assets ---
    // This loads the font files you added to the assets/fonts/ folder.
    // rootBundle is used to access files included in your app bundle.
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(boldFontData);

    // --- NEW: Create a PDF theme that uses these local fonts ---
    // By setting this theme, all text in the document will default to Roboto,
    // which has full Unicode support.
    final myTheme = pw.ThemeData.withFont(
      base: ttf,
      bold: boldTtf,
    );

    // Add a page to the document.
    pdf.addPage(
      pw.MultiPage(
        // --- MODIFIED: Apply the new theme to the entire page ---
        theme: myTheme,
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(context, businessProfile),
          pw.SizedBox(height: 20),
          _buildSummary(context, report.summary),
          pw.SizedBox(height: 30),

          if (chartImage != null) ...[
            _buildChartSection(context, chartImage),
            pw.SizedBox(height: 30),
          ],
          
          _buildTopProductsTable(context, report.topProducts),
        ],
      ),
    );

    return pdf.save();
  }

  // --- (No changes are needed for any of the _build... methods below) ---
  // The theme we applied to the page will automatically handle applying
  // the correct font (regular or bold) to all text widgets, fixing the '₱' issue.

  pw.Widget _buildHeader(pw.Context context, BusinessProfile businessProfile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          businessProfile.companyName ?? 'Business Report',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
        pw.Divider(thickness: 1, color: PdfColors.grey400),
      ],
    );
  }
  
  pw.Widget _buildSummary(pw.Context context, ReportSummary summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Performance Summary',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
        ),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildKpiCard('Total Revenue', '₱${NumberFormat('#,##0.00').format(summary.totalRevenue)}'),
            _buildKpiCard('Total Orders', summary.totalOrders.toString()),
            _buildKpiCard('Products Sold', summary.productsSold.toString()),
          ],
        )
      ],
    );
  }

  pw.Widget _buildKpiCard(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.SizedBox(height: 6),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  pw.Widget _buildChartSection(pw.Context context, Uint8List chartImage) {
    final image = pw.MemoryImage(chartImage);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Revenue (Last 30 Days)',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
      ],
    );
  }

  pw.Widget _buildTopProductsTable(pw.Context context, List<TopSellingProduct> topProducts) {
    const headers = ['Product Name', 'Total Quantity Sold'];
    final data = topProducts.map((product) => [
      product.productName,
      product.totalQuantity.toString(),
    ]).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Top Selling Products',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
        ),
        pw.SizedBox(height: 16),
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(color: PdfColors.grey400),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }
}