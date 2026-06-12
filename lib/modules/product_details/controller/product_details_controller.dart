import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/constants/api_url.dart';
import 'package:elite_edition/data/api_repository.dart';
import 'package:elite_edition/model/product_datamodel.dart';
import 'package:http/http.dart' as http;
import 'package:elite_edition/model/report_datamodel.dart';
import 'package:elite_edition/shared_widget/app_pdfview.dart';
import 'package:elite_edition/shared_widget/app_share.dart';
import 'package:elite_edition/shared_widget/create_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';
import 'package:elite_edition/shared_widget/app_loader.dart';
import 'package:elite_edition/utils/pdf_helper.dart';
import 'package:flutter/foundation.dart';

class ProductDetailsController extends GetxController {
  final ApiRepository apiRepository;

  ProductDetailsController({required this.apiRepository});

  late final String skuCode;
  String? passedSkuName;
  Rxn<ProductDataModel> dataModel = Rxn();
  RxBool isLoading = true.obs;
  final TextEditingController startDateTxtController = TextEditingController(
      text:
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
  final TextEditingController endDateTxtController = TextEditingController(
      text:
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");

  DateTime selectStartDate = DateTime.now();
  DateTime selectEndDate = DateTime.now();
  RxList<ReportDataModel> reportDataList = RxList();
  RxString selectedReportType = "sales".obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      skuCode = (args['skuCode'] ?? "").toString();
      passedSkuName = (args['skuName'] ?? "").toString();
    } else {
      skuCode = (args ?? "").toString();
      passedSkuName = null;
    }
    fetchData();
  }

  int? _parsePrice(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty || str == "null") return null;
    try {
      return double.parse(str).round();
    } catch (e) {
      return null;
    }
  }

  fetchData() async {
    try {
      final baseSku = skuCode.split('_')[0];
      var res = await apiRepository
          .getProductDetailsData({"skuCode": baseSku}, isLog: false);
      debugPrint("fetchData() raw response: $res");
      if (res != null && res is List && res.isNotEmpty) {
        var data = List<ProductDataModel>.from(
            res.map((x) => ProductDataModel.fromJson(x)));
        
        // Fetch order details for fallback values if needed
        var orderRes = await apiRepository.getListData({"itemSKUCode": skuCode, "limit": "1"});
        Map<String, dynamic>? firstOrder;
        if (orderRes != false && orderRes['data'] != null && orderRes['data'] is List && orderRes['data'].isNotEmpty) {
          firstOrder = orderRes['data'][0];
        }

        // 1. Description/Name
        if (data[0].description.isEmpty || data[0].description == "null") {
          String fallbackName = passedSkuName ?? "";
          if (fallbackName.isEmpty && firstOrder != null) {
            fallbackName = firstOrder['skuName'] ?? '';
          }
          if (fallbackName.isNotEmpty) {
            data[0].description = fallbackName;
          } else {
            data[0].description = data[0].skuCode;
          }
        }

        // 2. Price/MRP
        if (data[0].price == 0) {
          int? fallbackPrice;
          if (firstOrder != null) {
            fallbackPrice = _parsePrice(firstOrder['mrp']) ?? _parsePrice(firstOrder['totalPrice']);
          }
          if (fallbackPrice != null) {
            data[0].price = fallbackPrice;
          }
        }

        // 3. Brand
        if (data[0].brand.isEmpty || data[0].brand == "null") {
          String? fallbackBrand;
          if (firstOrder != null) {
            fallbackBrand = firstOrder['itemTypeBrand'];
          }
          if (fallbackBrand != null && fallbackBrand.isNotEmpty && fallbackBrand != "null") {
            data[0].brand = fallbackBrand;
          } else {
            data[0].brand = "Elite Edition";
          }
        }

        // 4. CategoryName
        if (data[0].categoryName.isEmpty || data[0].categoryName == "null" || data[0].categoryName == "Default") {
          String? fallbackCategory;
          if (firstOrder != null) {
            fallbackCategory = firstOrder['category'];
          }
          if (fallbackCategory != null && fallbackCategory.isNotEmpty && fallbackCategory != "null") {
            data[0].categoryName = fallbackCategory;
          }
        }

        // 5. Color
        if (data[0].color.isEmpty || data[0].color.any((e) => e == "null" || e.isEmpty)) {
          String? fallbackColor;
          if (firstOrder != null) {
            fallbackColor = firstOrder['itemTypeColor'];
          }
          if (fallbackColor != null && fallbackColor.isNotEmpty && fallbackColor != "null") {
            data[0].color = [fallbackColor];
          } else {
            data[0].color = ["N/A"];
          }
        }

        // 6. Size
        if (data[0].size.isEmpty || data[0].size.any((e) => e == "null" || e.isEmpty)) {
          String? fallbackSize;
          if (firstOrder != null) {
            fallbackSize = firstOrder['itemTypeSize'];
          }
          if (fallbackSize != null && fallbackSize.isNotEmpty && fallbackSize != "null") {
            data[0].size = [fallbackSize];
          } else {
            data[0].size = ["N/A"];
          }
        }

        // 7. Image
        if (data[0].imageUrl.isEmpty || data[0].imageUrl == "null") {
          String? fallbackImage;
          if (firstOrder != null) {
            fallbackImage = firstOrder['productImage'];
          }
          if (fallbackImage != null && fallbackImage.isNotEmpty && fallbackImage != "null") {
            data[0].imageUrl = fallbackImage;
          }
        }
        
        dataModel.value = data[0];
        isLoading.value = false;
      } else {
        isLoading.value = false;
        AppSnacks.errorSnack(message: "Product details not found or failed to load");
      }
    } catch (e, s) {
      isLoading.value = false;
      debugPrint("Error on fetchData() => $e \n $s");
    }
  }

  selectedStartDate(DateTime date) {
    selectStartDate = date;
    startDateTxtController.text =
        "${selectStartDate.day}/${selectStartDate.month}/${selectStartDate.year}";
  }

  selectedEndDate(DateTime date) {
    selectEndDate = date;
    endDateTxtController.text =
        "${selectEndDate.day}/${selectEndDate.month}/${selectEndDate.year}";
  }

  Future<void> downloadImage(
      {required BuildContext context, required String image}) async {
    String? message;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(image));
      // Get temporary directory
      final dir = await getTemporaryDirectory();
      // Create an image name
      var filename = '${dir.path}/image.png';
      // Save to filesystem
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
      // // Ask the user to save it
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);
    } catch (e) {
      message = 'An error occurred while saving the image';
    }
    if (message != null) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> downloadImageWithWatermark(String url) async {
    // Download the image
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Decode the image
      final image = img.decodeImage(response.bodyBytes);

      if (image != null) {
        // Define the font size and other properties for the watermark
        final font = img.arial48;
        img.drawString(
          image,
          dataModel.value!.skuCode,
          font: font,
        );
        // final textHeight = font.lineHeight;

        // Calculate the position for the watermark (bottom center)
        // final x = (image.width - textWidth) ~/ 2;
        // final y = image.height - textHeight - 10;  // Adjust to place slightly above the bottom

        // Draw the watermark text onto the image
        // img.drawString(image, font, x, y, watermarkText, color: img.getColor(255, 255, 255));

        // Save the image to a file
        // final file = File('${dataModel.skuCode}.png');
        // file.writeAsBytesSync(img.encodePng(image));

        final dir = await getTemporaryDirectory();
        // Create an image name
        var filename = '${dir.path}/${dataModel.value!.skuCode}.png';
        // Save to filesystem
        final file = File(filename);
        await file.writeAsBytes(img.encodePng(image));
        // // Ask the user to save it
        final params = SaveFileDialogParams(sourceFilePath: file.path);
        final finalPath = await FlutterFileDialog.saveFile(params: params);

        debugPrint('Image downloaded and saved with watermark');
      } else {
        debugPrint('Failed to decode the image.');
      }
    } else {
      debugPrint('Failed to download the image.');
    }
  }

  getReport(bool isDownload) async {
    try {
      Get.back(); // close date select sheet/dialog
      AppLoader.show();

      final startStr = "${selectStartDate.year}-${selectStartDate.month.toString().padLeft(2, '0')}-${selectStartDate.day.toString().padLeft(2, '0')}";
      final endStr = "${selectEndDate.year}-${selectEndDate.month.toString().padLeft(2, '0')}-${selectEndDate.day.toString().padLeft(2, '0')}";

      String reportUrl;
      String fileName;
      if (selectedReportType.value == "brand") {
        reportUrl = "${ApiUrl.baseUrl}/salesList/report/pdf?type=brand&dateStart=$startStr&dateEnd=$endStr&searchCode=$skuCode";
        fileName = "Brand_Report_${skuCode}_$startStr.pdf";
      } else {
        reportUrl = "${ApiUrl.baseUrl}/salesList/report/pdf?type=sales&dateStart=$startStr&dateEnd=$endStr&searchCode=$skuCode";
        fileName = "Sales_Report_${skuCode}_$startStr.pdf";
      }

      final response = await http.get(Uri.parse(reportUrl));
      if (response.statusCode != 200) {
        throw Exception("Backend returned status code ${response.statusCode}");
      }
      final Uint8List pdfBytes = response.bodyBytes;
      await AppLoader.hide(); // close loading

      if (kIsWeb) {
        if (isDownload) {
          await saveAndDownloadPdf(pdfBytes, fileName);
          AppSnacks.successSnack(
              message: "${selectedReportType.value == "brand" ? "Brand" : "Sales"} report downloaded successfully");
        } else {
          await AppShare.shareFile(XFile.fromData(
            pdfBytes,
            mimeType: 'application/pdf',
            name: fileName,
          ));
        }
      } else {
        final filePath = await saveAndDownloadPdf(pdfBytes, fileName);
        if (filePath != null) {
          if (isDownload) {
            Get.to(() => AppPdfView(path: filePath));
          } else {
            AppShare.shareFile(XFile(filePath));
          }
        }
      }
    } catch (e, s) {
      await AppLoader.hide(); // close loading
      debugPrint("Error on getReport() => $e \n $s");
      AppSnacks.errorSnack(message: "Failed to download PDF: $e");
    }
  }
}
