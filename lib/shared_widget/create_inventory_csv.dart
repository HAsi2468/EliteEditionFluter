import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:elite_edition/utils/pdf_helper.dart'; // To reuse saveAndDownloadPdf logic but with .csv

Future<dynamic> generateInventoryReportCsv({
  required Map<String, dynamic> reportData,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final StringBuffer csv = StringBuffer();

  // Add BOM for Excel compatibility (UTF-8)
  csv.write('\uFEFF');

  // Add Report Header
  csv.writeln('Inventory Report');
  csv.writeln('Date:,${startDate.day}-${startDate.month}-${startDate.year} To ${endDate.day}-${endDate.month}-${endDate.year}');
  csv.writeln('');

  void _buildSectionCsv(String title, Map<String, dynamic> sectionData) {
    final int totalOrderQuantity = sectionData['totalOrderQuantity'] ?? 0;
    final double totalSellableAmount = (sectionData['totalSellableAmount'] ?? 0).toDouble();
    final List<dynamic> items = sectionData['items'] ?? [];

    csv.writeln('Section:,$title');
    csv.writeln('Total Order Quantity:,$totalOrderQuantity');
    csv.writeln('Total Sellable Amount:,$totalSellableAmount');
    csv.writeln('');

    if (items.isEmpty) {
      csv.writeln('No data available for this section.');
      csv.writeln('');
      return;
    }

    // Table Header
    csv.writeln('SKU,Vendor,Size,Size Quantity,Total Quantity,Purchase Amount,Sellable Amount,Profit');

    for (var item in items) {
      final sku = item['sku']?.toString().replaceAll(',', ' ') ?? '';
      final party = item['party']?.toString().replaceAll(',', ' ') ?? '-';
      final sizes = item['sizes'] as List<dynamic>? ?? [];
      final total = item['total']?.toString() ?? '0';
      final purchaseAmt = item['totalPurchaseAmount'] as num? ?? 0;
      final sellableAmt = item['totalSellableAmount'] as num? ?? 0;
      final profit = sellableAmt - purchaseAmt;

      if (sizes.isEmpty) {
        csv.writeln('$sku,$party,-,0,$total,$purchaseAmt,$sellableAmt,$profit');
      } else {
        for (int i = 0; i < sizes.length; i++) {
          final s = sizes[i];
          final sizeName = s['size']?.toString().replaceAll(',', ' ') ?? '';
          final sizeQty = s['qty']?.toString() ?? '0';
          
          if (i == 0) {
            // First row contains the full data
            csv.writeln('$sku,$party,$sizeName,$sizeQty,$total,$purchaseAmt,$sellableAmt,$profit');
          } else {
            // Subsequent rows for sizes only need size and sizeQty, others can be blank
            csv.writeln(',,$sizeName,$sizeQty,,,,');
          }
        }
      }
    }
    csv.writeln('');
  }

  _buildSectionCsv("Current stock", reportData['currentStock'] ?? {});
  _buildSectionCsv("Stock in", reportData['stockIn'] ?? {});
  _buildSectionCsv("Stock out", reportData['stockOut'] ?? {});

  final List<int> bytes = utf8.encode(csv.toString());
  final Uint8List csvData = Uint8List.fromList(bytes);

  final fileName = "Inventory_Report_${startDate.day}-${startDate.month}-${startDate.year}.csv";

  // Reusing the saveAndDownloadPdf logic since it just saves bytes with a given filename
  return await saveAndDownloadPdf(csvData, fileName);
}
