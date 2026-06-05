import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:elite_edition/model/report_datamodel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:elite_edition/constants/api_url.dart';

Future<Uint8List> generateProductPdf(
    {required List<ReportDataModel> reportList,
    required DateTime startDate,
    required DateTime endDate,
    required String sku}) async {
  // Load custom fonts
  final fontRegular =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
  final fontBold =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    ),
  );

  // Define the number of rows per page
  // const rowsPerPage = 6;
  // final pageCount = (reportList.length / rowsPerPage).ceil();
  var rto = reportList.map((item) => int.parse(item.rto)).reduce((x, y) => x + y);
  var cr = reportList.map((item) => int.parse(item.cr)).reduce((x, y) => x + y);
  var saleCount = reportList.map((item) => int.parse(item.salesCount)).reduce((x, y) => x + y);

  reportList.insert(
    reportList.length,
    ReportDataModel(
      itemSkuCode: "",
      salesCount: saleCount.toString(),
      sellableAmount: 0,
      avgRate: 0,
      avgAmt: 0,
      orderDate: "",
      productImage: null,
      skuName: "Total",
      brand: "",
      cr: cr,
      rto: rto,
    ),
  );

  // Fetch all images asynchronously
  final imageList = await Future.wait(
    reportList.map((item) => _fetchImage(item.productImage)).toList(),
  );

  // Load logo image
  final logoData = await rootBundle.load("assets/icons/Logo.png");
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      header: (context) {
        if (context.pageNumber == 1) {
          return pw.SizedBox();
        }
        return pw.Align(
          alignment: pw.Alignment.topRight,
          child: pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Image(logoImage, width: 40, height: 40),
          ),
        );
      },
      footer: (context) {
        return pw.Align(
          alignment: pw.Alignment.bottomCenter,
          child: pw.Container(
            margin: const pw.EdgeInsets.only(top: 15),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "Powered by ",
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    color: PdfColor.fromHex("31343A"),
                  ),
                ),
                _heartWidget(),
                pw.Text(
                  " HASI ",
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    color: PdfColor.fromHex("31343A"),
                  ),
                ),
                _heartWidget(),
              ],
            ),
          ),
        );
      },
      build: (context) {
        return [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Text(
                  startDate.day == endDate.day &&
                          startDate.month == endDate.month &&
                          startDate.year == endDate.year
                      ? '$sku (${startDate.day}-${startDate.month}-${startDate.year})'
                      : "$sku (${startDate.day}-${startDate.month}-${startDate.year} To ${endDate.day}-${endDate.month}-${endDate.year})",
                  style: pw.TextStyle(fontSize: 20, font: fontBold),
                ),
              ),
              pw.SizedBox(width: 15),
              pw.Image(logoImage, width: 60, height: 60),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(0.8), // Image
              1: pw.FlexColumnWidth(1.2), // Row labels
              2: pw.FlexColumnWidth(1.2), // Brand
              3: pw.FlexColumnWidth(0.8), // Sum of Qty
              4: pw.FlexColumnWidth(0.6), // CR
              5: pw.FlexColumnWidth(0.6), // RTO
              6: pw.FlexColumnWidth(0.8), // Total
              7: pw.FlexColumnWidth(0.8), // Inventory
            },
            children: [
              pw.TableRow(
                children: [
                  _titleTextWidget("", fontBold),
                  _titleTextWidget("Row labels", fontBold),
                  _titleTextWidget("Brand", fontBold),
                  _titleTextWidget("Sum of Qty", fontBold),
                  _titleTextWidget("CR", fontBold),
                  _titleTextWidget("RTO", fontBold),
                  _titleTextWidget("Total", fontBold),
                  _titleTextWidget("Inventory", fontBold),
                ],
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
              ),
              ...reportList.asMap().entries.map((entry) {
                final item = entry.value;
                final image = imageList[entry.key];
                // var avgAmt =
                // (item.sellableAmount / double.parse(item.salesCount))
                //     .toStringAsFixed(2);
                return pw.TableRow(
                  children: [
                    image != null
                        ? pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 5),
                            child: pw.Center(
                              child: pw.Image(image, width: 50, height: 50),
                            ),
                          )
                        : pw.Text(
                            'N/A',
                            textAlign: pw.TextAlign.center,
                          ),
                    _textWidget(item.skuName.toString()),
                    _textWidget((item.brand ?? '').toString()),
                    _textWidget(item.salesCount.toString()),
                    _textWidget(item.cr.toString()),
                    _textWidget(item.rto.toString()),
                    _textWidget("${int.parse(item.cr.toString()) + int.parse(item.rto.toString())}"),
                    _textWidget("0"),
                  ],
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                );
              }),
            ],
          ),
        ];
      },
    ),
  );
  /*for (int i = 0; i < pageCount; i++) {
    // Split data for each page
    final dataChunk =
        reportList.skip(i * rowsPerPage).take(rowsPerPage).toList();

    // Prepare table data with images for each row
    final tableData = dataChunk.asMap().entries.map((entry) {
      final item = entry.value;
      final image = imageList[i * rowsPerPage + entry.key];

      return [
        image != null ? pw.Image(image, width: 50, height: 50) : 'N/A',
        item.skuName,
        item.salesCount,
        item.cr,
        item.rto,
        item.rto,
        item.cr,
      ];
    }).toList();

    // Add each page to the PDF

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Product Sales Report (Page ${i + 1} of $pageCount)',
                style: pw.TextStyle(fontSize: 24, font: fontBold),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headerAlignment: pw.Alignment.center,
                cellAlignment: pw.Alignment.center,
                headers: [
                  '',
                  'Row labels',
                  'Sum of Qty',
                  'CR',
                  'RTO',
                  'Total',
                  'Inventory',
                ],
                data: tableData,
                cellStyle: pw.TextStyle(font: fontRegular),
                headerStyle: pw.TextStyle(fontSize: 10, font: fontBold),
              ),
            ],
          );
        },
      ),
    );
  }*/

  return pdf.save();
}

Future<Uint8List> generatePdf(
    {required List<ReportDataModel> reportList,
    required DateTime startDate,
    required DateTime endDate}) async {
  // Load custom fonts
  final fontRegular =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
  final fontBold =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    ),
  );

  // Fetch all images asynchronously
  final imageList = await Future.wait(
    reportList.map((item) => _fetchImage(item.productImage)).toList(),
  );

  // Define the number of rows per page
  // const rowsPerPage = 10;
  // final pageCount = (reportList.length / rowsPerPage).ceil();
  var a = reportList
      .map((item) => int.parse(item.salesCount))
      .reduce((x, y) => x + y);
  var b = reportList.map((item) => item.sellableAmount).reduce((x, y) => x + y);

  // Load logo image
  final logoData = await rootBundle.load("assets/icons/Logo.png");
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      header: (context) {
        if (context.pageNumber == 1) {
          return pw.SizedBox();
        }
        return pw.Align(
          alignment: pw.Alignment.topRight,
          child: pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Image(logoImage, width: 40, height: 40),
          ),
        );
      },
      footer: (context) {
        return pw.Align(
          alignment: pw.Alignment.bottomCenter,
          child: pw.Container(
            margin: const pw.EdgeInsets.only(top: 15),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "Powered by ",
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    color: PdfColor.fromHex("31343A"),
                  ),
                ),
                _heartWidget(),
                pw.Text(
                  " HASI ",
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    color: PdfColor.fromHex("31343A"),
                  ),
                ),
                _heartWidget(),
              ],
            ),
          ),
        );
      },
      build: (context) {
        return [
          // pw.Header(
          //   level: 0,
          //   child: pw.Text(
          //     'Product Sales Report',
          //     style: pw.TextStyle(fontSize: 24, font: fontBold),
          //   ),
          // ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    startDate.day == endDate.day &&
                            startDate.month == endDate.month &&
                            startDate.year == endDate.year
                        ? 'Report Date : ${startDate.day}-${startDate.month}-${startDate.year}'
                        : "Report Date : ${startDate.day}-${startDate.month}-${startDate.year} To ${endDate.day}-${endDate.month}-${endDate.year}",
                    style: pw.TextStyle(fontSize: 16, font: fontBold),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "Total Order Quantity : $a",
                    style: pw.TextStyle(fontSize: 16, font: fontBold),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "Total Sellable Amount : $b",
                    style: pw.TextStyle(fontSize: 16, font: fontBold),
                  ),
                ],
              ),
              pw.Image(logoImage, width: 60, height: 60),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(0.7), // Image
              1: pw.FlexColumnWidth(1.5), // SKU / Name
              2: pw.FlexColumnWidth(1.0), // Brand
              3: pw.FlexColumnWidth(0.8), // Sales Count
              4: pw.FlexColumnWidth(0.8), // Avg Amount
              5: pw.FlexColumnWidth(1.0), // Sellable Amount
              6: pw.FlexColumnWidth(0.8), // FOB Price
            },
            children: [
              pw.TableRow(
                children: [
                  _titleTextWidget("Image", fontBold),
                  _titleTextWidget("SKU", fontBold),
                  _titleTextWidget("Brand", fontBold),
                  _titleTextWidget("Sales\nCount", fontBold),
                  _titleTextWidget("Avg Amount", fontBold),
                  _titleTextWidget("Sellable\nAmount", fontBold),
                  _titleTextWidget("F.O.B.\nPrice", fontBold),
                  // pw.Text('Image', style: pw.TextStyle(font: fontBold)),
                ],
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
              ),
              ...reportList.asMap().entries.map((entry) {
                final item = entry.value;
                final image = imageList[entry.key];
                var avgAmt =
                    (item.sellableAmount / double.parse(item.salesCount))
                        .toStringAsFixed(2);
                return pw.TableRow(
                  children: [
                    // image != null ? pw.Image(image, width: 50, height: 50) : 'N/A',
                    // item.itemSkuCode,
                    // item.salesCount,
                    // item.sellableAmount,
                    // fob,
                    image != null
                        ? pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 5),
                            child: pw.Center(
                              child: pw.Image(image, width: 50, height: 50),
                            ),
                          )
                        : pw.Text(
                            'N/A',
                            textAlign: pw.TextAlign.center,
                          ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            item.itemSkuCode.toString(),
                            style: pw.TextStyle(font: fontBold),
                            textAlign: pw.TextAlign.center,
                          ),
                          if (item.skuName != null && item.skuName.toString().isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              item.skuName.toString(),
                              style: const pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                    _textWidget((item.brand ?? '').toString()),
                    _textWidget(item.salesCount.toString()),
                    _textWidget(avgAmt.toString()),
                    _textWidget(item.sellableAmount.toString()),
                    _textWidget(""),
                  ],
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                );
              }),
            ],
          ),
        ];
      },
    ),
  );

  // Loop through pages
  /*for (int i = 0; i < pageCount; i++) {
    // Split data for each page
    final dataChunk =
        reportList.skip(i * rowsPerPage).take(rowsPerPage).toList();

    // Prepare table data with images for each row
    // dynamic totalOrder  = 0;
    // dynamic totalSellAmt  = 0;
    final tableData = dataChunk.asMap().entries.map((entry) {
      final item = entry.value;
      final image = imageList[i * rowsPerPage + entry.key];
      var fob = (item.sellableAmount / double.parse(item.salesCount))
          .toStringAsFixed(2);
      // totalOrder += double.parse(item.salesCount);
      // totalSellAmt += item.sellableAmount;
      return [
        image != null ? pw.Image(image, width: 50, height: 50) : 'N/A',
        item.itemSkuCode,
        item.salesCount,
        fob,
        item.sellableAmount,
        fob,
        // item.orderDate,
      ];
    }).toList();

    // Add each page to the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // pw.SizedBox(height: 10),
              i == 0
                  ? pw.Text(
                      startDate.day == endDate.day &&
                              startDate.month == endDate.month &&
                              startDate.year == endDate.year
                          ? 'Report Date : ${startDate.day}-${startDate.month}-${startDate.year}'
                          : "Report Date : ${startDate.day}-${startDate.month}-${startDate.year} To ${endDate.day}-${endDate.month}-${endDate.year}",
                      style: pw.TextStyle(fontSize: 24, font: fontBold),
                    )
                  : pw.SizedBox(),
              i == 0
                  ? pw.Text(
                      "Total Order Quantity : $a",
                      style: pw.TextStyle(fontSize: 24, font: fontBold),
                    )
                  : pw.SizedBox(),
              i == 0
                  ? pw.Text(
                      "Total Sellable Amount : $b",
                      style: pw.TextStyle(fontSize: 24, font: fontBold),
                    )
                  : pw.SizedBox(),
              pw.SizedBox(height: i == 0 ? 10 : 5),
              pw.TableHelper.fromTextArray(
                context: context,
                headerAlignment: pw.Alignment.center,
                cellAlignment: pw.Alignment.center,
                headers: [
                  'Image',
                  'SKU',
                  'Sales Count',
                  'Avg Amount',
                  'Sellable Amount',
                  'FOB',
                  // 'Order Date',
                ],
                data: tableData,
                cellStyle: pw.TextStyle(font: fontRegular),
                headerStyle: pw.TextStyle(fontSize: 10, font: fontBold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Product Sales Report (Page ${i + 1} of $pageCount)',
                style: pw.TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          );
        },
      ),
    );
  }*/

  return pdf.save();
}

Future<pw.ImageProvider?> _fetchImage(String? url) async {
  final fullUrl = ApiUrl.getFullImageUrl(url);
  if (fullUrl.isEmpty) return null;
  try {
    final response = await http.get(Uri.parse(fullUrl));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    }
  } catch (e) {
    print("Error fetching image: $e");
  }
  return null;
}

_textWidget(String text) => pw.Center(
      child: pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: 7),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
        ),
      ),
    );

_titleTextWidget(String title, pw.Font fontBold) => pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Text(title,
          style: pw.TextStyle(font: fontBold), textAlign: pw.TextAlign.center),
    );

pw.Widget _heartWidget() {
  return pw.CustomPaint(
    size: const PdfPoint(10, 10),
    painter: (PdfGraphics canvas, PdfPoint size) {
      canvas.setColor(PdfColor.fromHex("DB372D"));
      // Left lobe
      canvas.drawEllipse(size.x * 0.35, size.y * 0.6, size.x * 0.25, size.y * 0.35);
      canvas.fillPath();
      // Right lobe
      canvas.drawEllipse(size.x * 0.65, size.y * 0.6, size.x * 0.25, size.y * 0.35);
      canvas.fillPath();
      // Bottom triangle
      canvas.moveTo(size.x * 0.1, size.y * 0.45);
      canvas.lineTo(size.x * 0.5, 0);
      canvas.lineTo(size.x * 0.9, size.y * 0.45);
      canvas.closePath();
      canvas.fillPath();
    },
  );
}

// Future<Uint8List> generateDocument(
//     {required List<ReportDataModel> reportList,required PdfPageFormat format}) async {
//   final pw.Document doc = pw.Document();
//
//   doc.addPage(
//     pw.Page(
//       pageFormat: format,
//       build: (context) {
//         return pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('Product Sales Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 20),
//             pw.Table.fromTextArray(
//               context: context,
//               headerAlignment: pw.Alignment.center,
//               cellAlignment: pw.Alignment.center,
//               headers: ['SKU', 'Sales Count', 'Sellable Amount', 'Avg Rate', 'Avg Amount', 'Order Date', 'Image'],
//               data: reportList.map((item) async {
//                 final image = await _fetchImage(item['productImage']);
//                 return [
//                   item.itemSKUCode,
//                   item.salesCount,
//                   item.sellableAmount,
//                   item.avgRate,
//                   item.avgAmt,
//                   item.orderDate,
//                   image != null ? pw.Image(image, width: 50, height: 50) : 'N/A',
//                 ];
//               }).toList(),
//             ),
//           ],
//         );
//       },
//     ),
//   );
//
//   return doc.save();
// }

Future<Uint8List> generateBrandPdf({
  required Map<String, dynamic> brandReportData,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final fontRegular =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
  final fontBold =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    ),
  );

  // Load logo image
  final logoData = await rootBundle.load("assets/icons/Logo.png");
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

  final int totalOrderQuantity = brandReportData['totalOrderQuantity'] ?? 0;
  final double totalSellableAmount = (brandReportData['totalSellableAmount'] ?? 0.0).toDouble();
  final brands = brandReportData['brands'] as List? ?? [];

  // Pre-fetch all images
  final Map<String, String?> skuToUrl = {};
  for (var brandObj in brands) {
    if (brandObj is Map) {
      final products = brandObj['products'] as List? ?? [];
      for (var product in products) {
        if (product is Map) {
          final sku = product['sku'] as String;
          final imageUrl = product['imageUrl'] as String?;
          skuToUrl[sku] = imageUrl;
        }
      }
    }
  }

  final skus = skuToUrl.keys.toList();
  final fetchedImages = await Future.wait(
    skus.map((sku) => _fetchImage(skuToUrl[sku])).toList(),
  );

  final Map<String, pw.ImageProvider?> skuToImage = {};
  for (int i = 0; i < skus.length; i++) {
    skuToImage[skus[i]] = fetchedImages[i];
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      header: (context) {
        if (context.pageNumber == 1) {
          return pw.SizedBox();
        }
        return pw.Align(
          alignment: pw.Alignment.topRight,
          child: pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Image(logoImage, width: 40, height: 40),
          ),
        );
      },
      footer: (context) {
        return pw.Align(
          alignment: pw.Alignment.bottomCenter,
          child: pw.Container(
            margin: const pw.EdgeInsets.only(top: 15),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "Powered by ",
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    color: PdfColor.fromHex("31343A"),
                  ),
                ),
                _heartWidget(),
                pw.Text(
                  " HASI ",
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    color: PdfColor.fromHex("31343A"),
                  ),
                ),
                _heartWidget(),
              ],
            ),
          ),
        );
      },
      build: (context) {
        final List<pw.Widget> children = [];

        // 1. Report Logo and Title
        children.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "Brand Sales Report",
                style: pw.TextStyle(font: fontBold, fontSize: 22, color: PdfColor.fromHex("1B365D")),
              ),
              pw.Image(logoImage, width: 50, height: 50),
            ],
          ),
        );
        children.add(pw.SizedBox(height: 15));

        // 2. Global summary table
        children.add(
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex("D3D3D3"), width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.0),
              1: const pw.FlexColumnWidth(4.0),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text("Report date", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      startDate.day == endDate.day &&
                              startDate.month == endDate.month &&
                              startDate.year == endDate.year
                          ? '${startDate.day}-${startDate.month}-${startDate.year}'
                          : "${startDate.day}-${startDate.month}-${startDate.year} To ${endDate.day}-${endDate.month}-${endDate.year}",
                      style: pw.TextStyle(font: fontRegular, fontSize: 10),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text("Total Order Quantity", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text("$totalOrderQuantity", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text("Total sellable Amount", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(totalSellableAmount.toStringAsFixed(2), style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
        );
        children.add(pw.SizedBox(height: 20));

        // 3. Render brand blocks
        for (var brandObj in brands) {
          if (brandObj is! Map) continue;
          final String brandName = brandObj['brand'] ?? "Unknown";
          final int brandQty = brandObj['totalOrderQuantity'] ?? 0;
          final double brandAmount = (brandObj['totalSellableAmount'] ?? 0.0).toDouble();
          final products = brandObj['products'] as List? ?? [];

          // Brand summary block
          children.add(
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex("D3D3D3"), width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.0),
                1: const pw.FlexColumnWidth(4.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text("Brand", style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColor.fromHex("1B365D"))),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(brandName, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text("Total Order Quantity", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text("$brandQty", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text("Total sellable Amount", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(brandAmount.toStringAsFixed(2), style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          );
          children.add(pw.SizedBox(height: 10));

          // Main brand products table
          final List<pw.TableRow> tableRows = [];
          
          // Header Row
          tableRows.add(
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _titleTextWidget("Image", fontBold),
                _titleTextWidget("Sku", fontBold),
                _titleTextWidget("Size", fontBold),
                _titleTextWidget("Total", fontBold),
                _titleTextWidget("Average count", fontBold),
                _titleTextWidget("Sallable Amount", fontBold),
              ],
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
            ),
          );

          // Product rows
          for (var product in products) {
            if (product is! Map) continue;
            final String sku = product['sku'] ?? "";
            final int total = product['total'] ?? 0;
            final double averageCount = (product['averageCount'] ?? 0.0).toDouble();
            final double sellableAmount = (product['sellableAmount'] ?? 0.0).toDouble();
            final variations = product['variations'] as List? ?? [];
            final image = skuToImage[sku];

            // Build the variation column
            final List<pw.Widget> variationWidgets = [];
            if (variations.isEmpty) {
              variationWidgets.add(
                pw.Container(
                  height: 25.0,
                  alignment: pw.Alignment.center,
                  child: pw.Text("N/A", style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                ),
              );
            } else {
              for (int i = 0; i < variations.length; i++) {
                final v = variations[i];
                final isLast = i == variations.length - 1;
                variationWidgets.add(
                  pw.Container(
                    height: 25.0,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      border: isLast ? null : const pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
                      ),
                    ),
                    child: pw.Text(
                      "${v['size']}-${v['quantity']}",
                      style: pw.TextStyle(font: fontRegular, fontSize: 9),
                    ),
                  ),
                );
              }
            }

            tableRows.add(
              pw.TableRow(
                children: [
                  // Image
                  pw.Center(
                    child: image != null
                        ? pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Image(image, width: 40, height: 40),
                          )
                        : pw.Text("N/A", style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                  ),
                  // SKU
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                      child: pw.Text(sku, style: pw.TextStyle(font: fontBold, fontSize: 9), textAlign: pw.TextAlign.center),
                    ),
                  ),
                  // Size variation column
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: variationWidgets,
                  ),
                  // Total Qty
                  pw.Center(
                    child: pw.Text("$total", style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                  ),
                  // Average Count
                  pw.Center(
                    child: pw.Text(averageCount.toStringAsFixed(2), style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                  ),
                  // Sellable Amount
                  pw.Center(
                    child: pw.Text(sellableAmount.toStringAsFixed(2), style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                  ),
                ],
                verticalAlignment: pw.TableCellVerticalAlignment.full,
              ),
            );
          }

          children.add(
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.0), // Image
                1: const pw.FlexColumnWidth(1.5), // SKU
                2: const pw.FlexColumnWidth(1.2), // Size
                3: const pw.FlexColumnWidth(0.8), // Total
                4: const pw.FlexColumnWidth(1.0), // Average count
                5: const pw.FlexColumnWidth(1.2), // Sellable Amount
              },
              children: tableRows,
            ),
          );

          children.add(pw.SizedBox(height: 25));
        }

        return children;
      },
    ),
  );

  return pdf.save();
}
