import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/data/api_repository.dart';
import 'package:elite_edition/model/filter_datamodel.dart';
import 'package:elite_edition/model/productlist_datamodel.dart';
import 'package:elite_edition/model/report_datamodel.dart';
import 'package:elite_edition/shared_widget/app_pdfview.dart';
import 'package:elite_edition/shared_widget/app_share.dart';
import 'package:elite_edition/shared_widget/create_pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:elite_edition/utils/pdf_helper.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';
import 'package:flutter/foundation.dart';

class HomeController extends GetxService {
  final ApiRepository apiRepository;

  HomeController({required this.apiRepository});

  final TextEditingController searchTxtController = TextEditingController();
  final TextEditingController startDateTxtController = TextEditingController(
      text:
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
  final TextEditingController endDateTxtController = TextEditingController(
      text:
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");

  // final TextEditingController filterStartDateTxtController =
  //     TextEditingController(text: "Select Date");
  // final TextEditingController filterEndDateTxtController =
  //     TextEditingController(text: "Select Date");
  RxBool isLoading = true.obs;
  RxBool isFilterLoading = true.obs;
  RxList<Product> dataList = RxList();
  RxList<Product> tempDataList = RxList();
  RxList<ReportDataModel> reportDataList = RxList();
  RxList<Filter> filterDataList = RxList();
  RxString selectedReportType = "sales".obs;

  // RxList<Filter> selectedFilterDataList = RxList();
  Rxn<Filter> selectedFilter = Rxn();
  RxList<String> selectColor = RxList();
  RxList<String> selectCategory = RxList();
  RxList<String> selectBrand = RxList();
  RxList<String> selectSize = RxList();
  RxList<String> selectCity = RxList();
  RxList<String> selectStatus = RxList();
  RxList<String> sortList = [
    "None",
    "Order (high to low)",
    "Order (low to high)",
    "Price (high to low)",
    "Price (low to high)"
  ].obs;
  RxString selectedSort = "None".obs;
  RxInt currentPage = 1.obs;
  RxInt selectedTabIndex = 0.obs;
  DateTime? startDateTime;
  DateTime? endDateTime;

  DateTime selectStartDate = DateTime.now();
  DateTime selectEndDate = DateTime.now();
  RxBool isFilterDateSelected = false.obs;
  DateTime? selectFilterStartDate;
  DateTime? selectFilterEndDate;

  DateTime now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void onInit() {
    super.onInit();
    fetchData();
    // fetchData({"page": "${currentPage.value}", "limit": "5"});
    getFilterValue();
  }

  selectFilter(Filter filter) {
    selectedFilter.value = filter;
    debugPrint("Selected filter >>> ${filter.name}");
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

  selectedFilterStartDate(DateTime date) {
    selectFilterStartDate = date;
    debugPrint("selectFilterStartDate --- $selectFilterStartDate");
    isFilterDateSelected.value = true;
    // startDateTxtController.text =
    //     "${selectFilterStartDate.day}/${selectFilterStartDate.month}/${selectFilterStartDate.year}";
  }

  selectedFilterEndDate(DateTime date) {
    selectFilterEndDate = date;
    debugPrint("selectFilterEndDate --- $selectFilterEndDate");
    isFilterDateSelected.value = true;
    // endDateTxtController.text =
    //     "${selectFilterEndDate.day}/${selectFilterEndDate.month}/${selectFilterEndDate.year}";
  }

  selectSave() {}

  final Map<String, Map<String, dynamic>> _skuDetailsCache = {};

  Future<void> enrichProducts(List<Product> products) async {
    final toFetch = products
        .map((p) => p.itemSkuCode)
        .where((sku) => sku.isNotEmpty && 
                        (!_skuDetailsCache.containsKey(sku) || 
                         (_skuDetailsCache[sku]?['imageUrl'] ?? '').toString().isEmpty || 
                         (_skuDetailsCache[sku]?['skuName'] ?? '').toString().isEmpty ||
                         (_skuDetailsCache[sku]?['brand'] ?? '').toString().isEmpty))
        .toSet()
        .toList();

    if (toFetch.isNotEmpty) {
      await Future.wait(toFetch.map((sku) async {
        try {
          final baseSku = sku.split('_')[0];
          var res = await apiRepository.getProductDetailsData({"skuCode": baseSku});
          String imageUrl = '';
          String skuName = '';
          String brand = '';
          if (res != null && res is List && res.isNotEmpty) {
            final details = res[0];
            imageUrl = (details['imageUrl'] ?? '').toString();
            skuName = (details['description'] ?? details['categoryName'] ?? '').toString();
            brand = (details['brand'] ?? '').toString();
          }

          // Fetch order details for fallback if needed
          var orderRes = await apiRepository.getListData({"itemSKUCode": sku, "limit": "1"});
          Map<String, dynamic>? firstOrder;
          if (orderRes != false && orderRes['data'] != null && orderRes['data'] is List && orderRes['data'].isNotEmpty) {
            firstOrder = orderRes['data'][0];
          }

          if (skuName.isEmpty || skuName == "Default" || skuName == "null") {
            if (firstOrder != null) {
              skuName = (firstOrder['skuName'] ?? '').toString();
            }
          }
          if (imageUrl.isEmpty || imageUrl == "null") {
            if (firstOrder != null) {
              imageUrl = (firstOrder['productImage'] ?? '').toString();
            }
          }
          if (brand.isEmpty || brand == "null") {
            if (firstOrder != null) {
              brand = (firstOrder['itemTypeBrand'] ?? '').toString();
            }
          }

          _skuDetailsCache[sku] = {
            'imageUrl': imageUrl,
            'skuName': skuName,
            'brand': brand,
          };
        } catch (e) {
          debugPrint("Error enriching SKU $sku: $e");
        }
      }));
    }

    for (var product in products) {
      if (_skuDetailsCache.containsKey(product.itemSkuCode)) {
        product.productImage = _skuDetailsCache[product.itemSkuCode]!['imageUrl'] ?? '';
        if (product.skuName.isEmpty) {
          product.skuName = _skuDetailsCache[product.itemSkuCode]!['skuName'] ?? '';
        }
        if (product.itemTypeBrand.isEmpty) {
          product.itemTypeBrand = _skuDetailsCache[product.itemSkuCode]!['brand'] ?? '';
        }
      }
    }
  }

  Future<void> enrichReports(List<ReportDataModel> reports) async {
    final toFetch = reports
        .map((r) => r.itemSkuCode)
        .where((sku) => sku.isNotEmpty && 
                        (!_skuDetailsCache.containsKey(sku) || 
                         (_skuDetailsCache[sku]?['imageUrl'] ?? '').toString().isEmpty || 
                         (_skuDetailsCache[sku]?['skuName'] ?? '').toString().isEmpty))
        .toSet()
        .toList();

    if (toFetch.isNotEmpty) {
      await Future.wait(toFetch.map((sku) async {
        try {
          final baseSku = sku.split('_')[0];
          var res = await apiRepository.getProductDetailsData({"skuCode": baseSku});
          String imageUrl = '';
          String skuName = '';
          String brand = '';
          if (res != null && res is List && res.isNotEmpty) {
            final details = res[0];
            imageUrl = (details['imageUrl'] ?? '').toString();
            skuName = (details['description'] ?? details['categoryName'] ?? '').toString();
            brand = (details['brand'] ?? '').toString();
          }

          // Fetch order details for fallback if needed
          var orderRes = await apiRepository.getListData({"itemSKUCode": sku, "limit": "1"});
          Map<String, dynamic>? firstOrder;
          if (orderRes != false && orderRes['data'] != null && orderRes['data'] is List && orderRes['data'].isNotEmpty) {
            firstOrder = orderRes['data'][0];
          }

          if (skuName.isEmpty || skuName == "Default" || skuName == "null") {
            if (firstOrder != null) {
              skuName = (firstOrder['skuName'] ?? '').toString();
            }
          }
          if (imageUrl.isEmpty || imageUrl == "null") {
            if (firstOrder != null) {
              imageUrl = (firstOrder['productImage'] ?? '').toString();
            }
          }
          if (brand.isEmpty || brand == "null") {
            if (firstOrder != null) {
              brand = (firstOrder['itemTypeBrand'] ?? '').toString();
            }
          }

          _skuDetailsCache[sku] = {
            'imageUrl': imageUrl,
            'skuName': skuName,
            'brand': brand,
          };
        } catch (e) {
          debugPrint("Error enriching SKU $sku: $e");
        }
      }));
    }

    for (var report in reports) {
      if (_skuDetailsCache.containsKey(report.itemSkuCode)) {
        report.productImage = _skuDetailsCache[report.itemSkuCode]!['imageUrl'] ?? '';
        if (report.skuName == null || report.skuName.toString().isEmpty) {
          report.skuName = _skuDetailsCache[report.itemSkuCode]!['skuName'] ?? '';
        }
        if (report.brand == null || report.brand.toString().isEmpty) {
          report.brand = _skuDetailsCache[report.itemSkuCode]!['brand'] ?? '';
        }
      }
    }
  }

  // fetchData(Map<String, String>? param) async {
  fetchData() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      var res = await apiRepository.getListData({
        "page": "${currentPage.value}",
        "limit": "10",
        "itemSKUCode": searchTxtController.text.trim(),
        "category": selectCategory.isEmpty
            ? ""
            : selectCategory.map((e) => e).join(","),
        "itemTypeColor":
            selectColor.isEmpty ? "" : selectColor.map((e) => e).join(","),
        "itemTypeSize":
            selectSize.isEmpty ? "" : selectSize.map((e) => e).join(","),
        "itemTypeBrand":
            selectBrand.isEmpty ? "" : selectBrand.map((e) => e).join(","),
        "shippingAddressCity":
            selectCity.isEmpty ? "" : selectCity.map((e) => e).join(","),
        "saleOrderStatus":
            selectStatus.isEmpty ? "" : selectStatus.map((e) => e).join(","),
        "dateStart": startDateTime == null && selectFilterStartDate == null
            ? ""
            : startDateTime != null
                ? startDateTime!.toIso8601String()
                : selectFilterStartDate!.toIso8601String(),
        "endDate": endDateTime == null && selectFilterEndDate == null
            ? ""
            : endDateTime != null
                ? endDateTime!.toIso8601String()
                : selectFilterEndDate!.toIso8601String(),
        "sortOrder": selectedSort.value == "None"
            ? ""
            : selectedSort.value == "Order (high to low)" ||
                    selectedSort.value == "Order (low to high)"
                ? (selectedSort.value == "Order (high to low)" ? "desc" : "asc")
                : (selectedSort.value == "Price (high to low)"
                    ? "desc"
                    : "asc"),
        "sortField": selectedSort.value == "None"
            ? ""
            : (selectedSort.value == "Price (high to low)" ||
                    selectedSort.value == "Price (low to high)"
                ? "totalPrice"
                : "itemSKUCode"),
      }, isLog: false);
      if (res != false) {
        var data = ProductListDataModel.fromJson(res);
        for (var p in data.product) {
          if (p.itemSkuCode.isNotEmpty) {
            final existing = _skuDetailsCache[p.itemSkuCode];
            final img = (p.productImage.isNotEmpty && p.productImage != "null") ? p.productImage : '';
            final name = (p.skuName.isNotEmpty && p.skuName != "null") ? p.skuName : '';
            if (img.isNotEmpty || name.isNotEmpty) {
              _skuDetailsCache[p.itemSkuCode] = {
                'imageUrl': img.isNotEmpty ? img : (existing?['imageUrl'] ?? ''),
                'skuName': name.isNotEmpty ? name : (existing?['skuName'] ?? ''),
              };
            }
          }
        }
        await enrichProducts(data.product);
        dataList.value = data.product;
        // dataList.addAll(data.product);
        debugPrint("List Length --->>> ${dataList.length}");
        isLoading.value = false;
      }
    } catch (e, s) {
      isLoading.value = false;
      debugPrint("Error on fetchData() => $e \n $s");
    }
  }

  loadMore() async {
    try {
      // print("currentPage.value : ${currentPage.value}");
      currentPage.value = currentPage.value + 1;
      // print("currentPage.value ::: ${currentPage.value}");
      var res = await apiRepository.getListData(
        {
          "page": "${currentPage.value}",
          "limit": "10",
          "itemSKUCode": searchTxtController.text.trim(),
          "category": selectCategory.isEmpty
              ? ""
              : selectCategory.map((e) => e).join(","),
          "itemTypeColor":
              selectColor.isEmpty ? "" : selectColor.map((e) => e).join(","),
          "itemTypeSize":
              selectSize.isEmpty ? "" : selectSize.map((e) => e).join(","),
          "itemTypeBrand":
              selectBrand.isEmpty ? "" : selectBrand.map((e) => e).join(","),
          "shippingAddressCity":
              selectCity.isEmpty ? "" : selectCity.map((e) => e).join(","),
          "saleOrderStatus":
              selectStatus.isEmpty ? "" : selectStatus.map((e) => e).join(","),
          "dateStart": startDateTime == null && selectFilterStartDate == null
              ? ""
              : startDateTime != null
                  ? startDateTime!.toIso8601String()
                  : selectFilterStartDate!.toIso8601String(),
          "endDate": endDateTime == null && selectFilterEndDate == null
              ? ""
              : endDateTime != null
                  ? endDateTime!.toIso8601String()
                  : selectFilterEndDate!.toIso8601String(),
          "sortOrder": selectedSort.value == "None"
              ? ""
              : selectedSort.value == "Order (high to low)" ||
                      selectedSort.value == "Order (low to high)"
                  ? (selectedSort.value == "Order (high to low)"
                      ? "desc"
                      : "asc")
                  : (selectedSort.value == "Price (high to low)"
                      ? "desc"
                      : "asc"),
          "sortField": selectedSort.value == "None"
              ? ""
              : (selectedSort.value == "Price (high to low)" ||
                      selectedSort.value == "Price (low to high)"
                  ? "totalPrice"
                  : "itemSKUCode"),
        },
        isLog: false,
      );
      if (res != false) {
        var data = ProductListDataModel.fromJson(res);
        for (var p in data.product) {
          if (p.itemSkuCode.isNotEmpty) {
            final existing = _skuDetailsCache[p.itemSkuCode];
            final img = (p.productImage.isNotEmpty && p.productImage != "null") ? p.productImage : '';
            final name = (p.skuName.isNotEmpty && p.skuName != "null") ? p.skuName : '';
            if (img.isNotEmpty || name.isNotEmpty) {
              _skuDetailsCache[p.itemSkuCode] = {
                'imageUrl': img.isNotEmpty ? img : (existing?['imageUrl'] ?? ''),
                'skuName': name.isNotEmpty ? name : (existing?['skuName'] ?? ''),
              };
            }
          }
        }
        // dataList.value = data.product;
        await enrichProducts(data.product);
        dataList.addAll(data.product);
        debugPrint("New List Length --->>> ${dataList.length}");
        isLoading.value = false;
      }
    } catch (e, s) {
      isLoading.value = false;
      debugPrint("Error on loadMore() => $e \n $s");
    }
  }

  getFilterValue() async {
    try {
      var res = await apiRepository.getFilterData(null, isLog: false);
      if (res != false) {
        var data = FilterDataModel.fromJson(res);
        filterDataList.value = data.filter;
        debugPrint("Filter Data List Length : ${filterDataList.length}");
        filterDataList.insert(
          filterDataList.length,
          Filter(
            name: "Date",
            values: [],
          ),
        );
        selectFilter(filterDataList.first);
        isFilterLoading.value = false;
      }
    } catch (e, s) {
      isFilterLoading.value = false;
      debugPrint("Error on getFilterValue() => $e \n $s");
    }
  }

  searchProduct(String text) async {
    if (text.trim().length > 2) {
      await fetchData();
      // await fetchData(
      //   {
      //     "page": "${currentPage.value}",
      //     "limit": "5",
      //     "itemSKUCode": text,
      //   },
      // );
    } else {
      await fetchData();
      // await fetchData({"page": "${currentPage.value}", "limit": "5"});
    }
  }

  applyFilter() async {
    await fetchData();
    // await fetchData(
    //   {
    //     "page": "${currentPage.value}",
    //     "limit": "5",
    //     "itemSKUCode": searchTxtController.text.trim(),
    //     "category": selectCategory.isEmpty
    //         ? ""
    //         : selectCategory.map((e) => e).join(","),
    //     "itemTypeColor":
    //         selectColor.isEmpty ? "" : selectColor.map((e) => e).join(","),
    //     "shippingAddressCity":
    //         selectCity.isEmpty ? "" : selectCity.map((e) => e).join(","),
    //   },
    // );
  }

  clearFilter() async {
    selectCity.clear();
    selectColor.clear();
    selectCategory.clear();
    selectStatus.clear();
    selectSize.clear();
    selectFilterStartDate = null;
    selectFilterEndDate = null;
    isFilterDateSelected.value = false;
    if (selectedSort.value != "None") {
      selectedSort.value = sortList.first;
      startDateTime = null;
      endDateTime = null;
    }
    await fetchData();
  }

  clearSort() async {
    selectedSort.value = sortList.first;
    startDateTime = null;
    endDateTime = null;

    await fetchData();
  }

  applySort() async {
    var now = DateTime.now();
    debugPrint("start date <><> ${startDateTime?.toIso8601String()}");
    if (selectedSort.value == "Order (low to high)" ||
        selectedSort.value == "Order (high to low)") {
      if(selectFilterStartDate == null){
        if (selectedSort.value == "Order (high to low)") {
          startDateTime = DateTime(
            now.year,
            now.month,
            now.day,
          );
        } else {
          startDateTime = DateTime(
            now.year,
            now.month,
            now.day,
          );
        }
        if (selectedSort.value == "Order (low to high)") {
          endDateTime = now;
        } else {
          endDateTime = now;
        }
      }
    }

    debugPrint("start date <><><> ${startDateTime?.toIso8601String()}");

    await fetchData();
  }

  getReport(bool isDownload) async {
    try {
      Get.back();
      Get.dialog(
        Column(
          // mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColor.white,
            ),
          ],
        ),
        barrierDismissible: false,
      );

      final Map<String, String> queryParams = {
        "dateStart":
            "${selectStartDate.year}-${selectStartDate.month}-${selectStartDate.day}",
        "dateEnd":
            "${selectEndDate.year}-${selectEndDate.month}-${selectEndDate.day}",
      };

      if (selectedReportType.value == "brand") {
        var res = await apiRepository.getBrandReport(queryParams, isLog: false);
        if (res != false && res != null) {
          final pdfBytes = await generateBrandPdf(
            brandReportData: res,
            startDate: selectStartDate,
            endDate: selectEndDate,
          );
          final fileName = "Brand_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
          Get.back();

          if (kIsWeb) {
            if (isDownload) {
              await saveAndDownloadPdf(pdfBytes, fileName);
              AppSnacks.successSnack(message: "Brand report downloaded successfully");
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
        } else {
          Get.back();
        }
      } else {
        var res = await apiRepository.getReport(queryParams, isLog: false);
        if (res != false) {
          var data = List<ReportDataModel>.from(
              res.map((x) => ReportDataModel.fromJson(x)));
          await enrichReports(data);
          reportDataList.value = data;

          final pdfBytes = await generatePdf(
            reportList: reportDataList.value,
            startDate: selectStartDate,
            endDate: selectEndDate,
          );
          final fileName = "Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
          Get.back();

          if (kIsWeb) {
            if (isDownload) {
              await saveAndDownloadPdf(pdfBytes, fileName);
              AppSnacks.successSnack(message: "Report downloaded successfully");
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
        } else {
          Get.back();
        }
      }
    } catch (e, s) {
      Get.back();
      debugPrint("Error on getReport() => $e \n $s");
    }
  }
}
