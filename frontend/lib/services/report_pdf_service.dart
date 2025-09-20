// lib/services/report_pdf_service.dart
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/seller_report.dart'; // Your data model
import '../models/user_profile.dart'; // For the business name

class ReportPdfService {
  
  // --- MODIFIED: The method now accepts an optional 'chartImage' parameter ---
  Future<Uint8List> generateReportPdf(
    SellerReport report, 
    BusinessProfile businessProfile, {
    Uint8List? chartImage, // This is the captured image data from the UI.
  }) async {
    // Create a new PDF document.
    final pdf = pw.Document();

    // Add a page to the document.
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // The build method returns a list of widgets to draw on the page.
        build: (context) => [
          _buildHeader(context, businessProfile),
          pw.SizedBox(height: 20),
          _buildSummary(context, report.summary),
          pw.SizedBox(height: 30),

          // --- NEW: Conditionally add the chart image section ---
          // This 'if' statement checks if the chart image was successfully captured
          // and passed to this method.
          if (chartImage != null) ...[
            _buildChartSection(context, chartImage),
            pw.SizedBox(height: 30),
          ],
          
          _buildTopProductsTable(context, report.topProducts),
        ],
      ),
    );

    // The save() method returns the PDF document as a Uint8List of bytes.
    return pdf.save();
  }

  // Helper method to build the PDF header.
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
  
  // Helper method to build the summary KPI section.
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

  // Reusable widget for the KPI cards in the summary.
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

  // --- NEW: A helper widget to build the chart section in the PDF ---
  pw.Widget _buildChartSection(pw.Context context, Uint8List chartImage) {
    // The pdf library uses its own ImageProvider type, so we wrap our bytes in a MemoryImage.
    final image = pw.MemoryImage(chartImage);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Revenue (Last 30 Days)',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
        ),
        pw.SizedBox(height: 16),
        // We put the image inside a decorated container to give it a border,
        // matching the style of the KPI cards.
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

  // Helper method to build the table of top-selling products.
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