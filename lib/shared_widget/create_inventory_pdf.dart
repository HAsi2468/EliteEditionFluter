import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:elite_edition/constants/api_url.dart';

Future<Uint8List> generateInventoryReportPdf({
  required Map<String, dynamic> reportData,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  // Load fonts
  final fontRegular = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
  final fontBold = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

  final pdf = pw.Document();

  // Helper to fetch images
  Future<pw.MemoryImage?> _fetchImage(String imageUrl) async {
    if (imageUrl.isEmpty) return null;
    try {
      final String fullUrl = ApiUrl.getFullImageUrl(imageUrl);
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (e) {
      print("Error fetching image for PDF: $e");
    }
    return null;
  }

  // Pre-fetch images
  Map<String, pw.MemoryImage?> imageCache = {};
  
  Future<void> prefetchAllImages() async {
    final Set<String> uniqueUrls = {};
    
    for (var sectionKey in ['currentStock', 'stockIn', 'stockOut']) {
      final section = reportData[sectionKey] ?? {};
      if (section['items'] != null) {
        for (var item in section['items']) {
          if (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty) {
            uniqueUrls.add(item['imageUrl'].toString());
          }
        }
      }
    }

    // Process concurrently in chunks of 50 to avoid connection limits
    final urls = uniqueUrls.toList();
    for (var i = 0; i < urls.length; i += 50) {
      final chunk = urls.sublist(i, i + 50 > urls.length ? urls.length : i + 50);
      await Future.wait(chunk.map((url) async {
        imageCache[url] = await _fetchImage(url);
      }));
    }
  }

  await prefetchAllImages();

  List<pw.Widget> _buildSectionTable(String title, Map<String, dynamic> sectionData) {
    final int totalOrderQuantity = sectionData['totalOrderQuantity'] ?? 0;
    final double totalSellableAmount = (sectionData['totalSellableAmount'] ?? 0).toDouble();
    final List<dynamic> items = sectionData['items'] ?? [];

    if (items.isEmpty) {
      return [
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            color: PdfColors.grey300,
            width: double.infinity,
            child: pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 12)),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
            width: double.infinity,
            child: pw.Text("No data available for this section.", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
          ),
          pw.SizedBox(height: 10),
      ];
    }
    return [
      // Section Header
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
          child: pw.Column(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                color: PdfColors.grey200,
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 2, child: pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 12))),
                  ]
                )
              ),
              pw.Container(
                decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey))),
                padding: const pw.EdgeInsets.all(5),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text("Total Order Quantity", style: pw.TextStyle(font: fontBold, fontSize: 10))),
                    pw.Expanded(flex: 1, child: pw.Text(totalOrderQuantity.toString(), style: pw.TextStyle(font: fontRegular, fontSize: 10))),
                  ]
                )
              ),
              pw.Container(
                decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey))),
                padding: const pw.EdgeInsets.all(5),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text("Total sellable Amount", style: pw.TextStyle(font: fontBold, fontSize: 10))),
                    pw.Expanded(flex: 1, child: pw.Text(totalSellableAmount.toStringAsFixed(2), style: pw.TextStyle(font: fontRegular, fontSize: 10))),
                  ]
                )
              ),
            ]
          )
        ),

        // Table Header
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
          ),
          padding: const pw.EdgeInsets.all(5),
          child: pw.Row(
            children: [
              pw.Expanded(flex: 1, child: pw.Text("Image", style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
              pw.Expanded(flex: 2, child: pw.Text("Sku", style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
              pw.Expanded(flex: 2, child: pw.Text("Vendor", style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
              pw.Expanded(flex: 1, child: pw.Text("Size", style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
              pw.Expanded(flex: 1, child: pw.Text("Total", style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
              pw.Expanded(flex: 2, child: pw.Text("Purchase Amount", style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
              pw.Expanded(flex: 2, child: pw.Text("Sellable Amount", style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
              pw.Expanded(flex: 2, child: pw.Text("Profit", style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
            ]
          )
        ),

        // Table Rows
        ...items.map((item) {
          final sizes = item['sizes'] as List<dynamic>? ?? [];
          final int rowSpan = sizes.isEmpty ? 1 : sizes.length;
          
          return pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey),
                left: pw.BorderSide(color: PdfColors.grey),
                right: pw.BorderSide(color: PdfColors.grey),
              )
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Image
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.grey))),
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: item['imageUrl'] != null && imageCache[item['imageUrl']] != null
                        ? pw.Image(imageCache[item['imageUrl']]!, height: 40, width: 40, fit: pw.BoxFit.contain)
                        : pw.Text("No Image", style: pw.TextStyle(font: fontRegular, fontSize: 8))
                  )
                ),
                // Sku
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.grey))),
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: pw.Text(item['sku'].toString(), style: pw.TextStyle(font: fontRegular, fontSize: 10))
                  )
                ),
                // Vendor
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.grey))),
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: pw.Text(item['party']?.toString() ?? '-', style: pw.TextStyle(font: fontRegular, fontSize: 10))
                  )
                ),
                // Sizes & inner Qtys
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.grey))),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: sizes.asMap().entries.map((entry) {
                        final s = entry.value;
                        final bool isLast = entry.key == sizes.length - 1;
                        return pw.Container(
                          decoration: pw.BoxDecoration(
                            border: isLast ? null : const pw.Border(bottom: pw.BorderSide(color: PdfColors.grey))
                          ),
                          padding: const pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text("${s['size']} - ${s['qty']}", style: pw.TextStyle(font: fontRegular, fontSize: 10))
                        );
                      }).toList(),
                    )
                  )
                ),
                // Total
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.grey))),
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: pw.Text(item['total'].toString(), style: pw.TextStyle(font: fontRegular, fontSize: 10))
                  )
                ),
                // Total Purchase
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.grey))),
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: pw.Text(item['totalPurchaseAmount'].toString(), style: pw.TextStyle(font: fontRegular, fontSize: 10))
                  )
                ),
                // Total Sellable
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.grey))),
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: pw.Text(item['totalSellableAmount'].toString(), style: pw.TextStyle(font: fontRegular, fontSize: 10))
                  )
                ),
                // Profit
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      ((item['totalSellableAmount'] as num? ?? 0) - (item['totalPurchaseAmount'] as num? ?? 0)).toStringAsFixed(2),
                      style: pw.TextStyle(font: fontRegular, fontSize: 10)
                    )
                  )
                ),
              ]
            )
          );
        }).toList(),
        pw.SizedBox(height: 20),
    ];
  }

  // Build Pages
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      maxPages: 200,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          // Report Date Header
          pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
            padding: const pw.EdgeInsets.all(5),
            child: pw.Row(
              children: [
                pw.Expanded(flex: 1, child: pw.Text("Report date", style: pw.TextStyle(font: fontBold, fontSize: 10))),
                pw.Expanded(flex: 3, child: pw.Text("${startDate.day}-${startDate.month}-${startDate.year} To ${endDate.day}-${endDate.month}-${endDate.year}", style: pw.TextStyle(font: fontRegular, fontSize: 10))),
              ]
            )
          ),
          pw.SizedBox(height: 10),
          
          ..._buildSectionTable("Current stock", reportData['currentStock'] ?? {}),
          ..._buildSectionTable("Stock in", reportData['stockIn'] ?? {}),
          ..._buildSectionTable("Stock out", reportData['stockOut'] ?? {}),
        ];
      },
    ),
  );

  return pdf.save();
}
