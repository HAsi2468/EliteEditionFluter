import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/modules/product_details/controller/product_details_controller.dart';
import 'package:elite_edition/shared_widget/app_button.dart';
import 'package:elite_edition/shared_widget/app_cache_image.dart';
import 'package:elite_edition/shared_widget/app_image.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';
import 'package:elite_edition/shared_widget/textfield_widget.dart';
import 'package:elite_edition/routes/app_routes.dart';
import 'package:elite_edition/controller/theme_controller.dart';

class ProductDetailsView extends StatelessWidget {
  ProductDetailsView({super.key});

  final ProductDetailsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      final bool isDark = themeController.isDarkMode.value;
      final Color scaffoldBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
      final Color cardBg = isDark ? AppColor.primary900 : Colors.white;
      final Color textColor = isDark ? AppColor.white : AppColor.primary900;
      final Color textSecondary = isDark ? AppColor.primary200 : AppColor.primary800;
      final Color appBarBg = isDark ? AppColor.primary800 : AppColor.primary900;

      final titleStyle = TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 17,
        color: isDark ? AppColor.primary200 : AppColor.primary800,
      );

      final subTitleStyle = TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 17,
        color: isDark ? AppColor.primary300 : AppColor.primary600,
      );

      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Get.back();
                } else {
                  Get.offAllNamed(AppRoutes.homePage);
                }
              },
              icon: Icon(
                CupertinoIcons.back,
                color: AppColor.white,
              ),
            ),
            backgroundColor: appBarBg,
            title: Text(
              "Loading...",
              style: TextStyle(
                color: AppColor.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final data = controller.dataModel.value!;

      return Scaffold(
        backgroundColor: scaffoldBg,
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: ExpandableFab(
            distance: 70,
            openCloseStackAlignment: Alignment.centerLeft,
            pos: ExpandableFabPos.right,
            type: ExpandableFabType.up,
            openButtonBuilder: RotateFloatingActionButtonBuilder(
              child: const Icon(
                Icons.add,
                size: 50,
              ),
              fabSize: ExpandableFabSize.regular,
              foregroundColor: AppColor.white,
              backgroundColor: isDark ? AppColor.primary900 : AppColor.primary900,
              shape: const CircleBorder(),
              heroTag: null,
            ),
            closeButtonBuilder: RotateFloatingActionButtonBuilder(
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: AppAssetImage(image: "assets/icons/back.png"),
              ),
              fabSize: ExpandableFabSize.regular,
              foregroundColor: AppColor.white,
              angle: 0,
              backgroundColor: isDark ? AppColor.primary900 : AppColor.primary900,
              shape: const CircleBorder(),
              heroTag: null,
            ),
            children: [
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  _showReportTypeSelection(context, true);
                },
                backgroundColor: isDark ? AppColor.primary900 : AppColor.primary100,
                shape: CircleBorder(
                  side: BorderSide(color: isDark ? AppColor.primary800 : AppColor.primary900),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppAssetImage(
                    image: "assets/icons/download.png",
                    imgColor: isDark ? AppColor.white : null,
                  ),
                ),
              ),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  _showReportTypeSelection(context, false);
                },
                backgroundColor: isDark ? AppColor.primary900 : AppColor.primary100,
                shape: CircleBorder(
                  side: BorderSide(color: isDark ? AppColor.primary800 : AppColor.primary900),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.share_rounded,
                    color: isDark ? AppColor.white : AppColor.primary800,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAllNamed(AppRoutes.homePage);
              }
            },
            icon: Icon(
              CupertinoIcons.back,
              color: AppColor.white,
            ),
          ),
          backgroundColor: appBarBg,
          title: Text(
            data.skuCode,
            style: TextStyle(
              color: AppColor.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  AppCacheImage(
                    imageUrl: data.imageUrl,
                    width: size.width,
                  ),
                  Positioned(
                    bottom: 0,
                    width: size.width,
                    child: Text(
                      data.skuCode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, top: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(17),
                          foregroundColor: AppColor.primary900,
                          backgroundColor: isDark ? AppColor.primary900 : AppColor.primary900,
                        ),
                        onPressed: () {
                          controller.downloadImageWithWatermark(data.imageUrl);
                        },
                        child: Icon(
                          Icons.download_rounded,
                          size: 30,
                          color: AppColor.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: cardBg,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.skuCode,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Product Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              detailTitleWidget("Item Name", titleStyle),
                              detailsSizedBox(),
                              detailTitleWidget("SKU Code", titleStyle),
                              detailsSizedBox(),
                              detailTitleWidget("Category", titleStyle),
                              detailsSizedBox(),
                              detailTitleWidget("MRP", titleStyle),
                              detailsSizedBox(),
                              detailTitleWidget("Color", titleStyle),
                              detailsSizedBox(),
                              detailTitleWidget("Size", titleStyle),
                              detailsSizedBox(),
                              detailTitleWidget("Brand", titleStyle),
                              detailsSizedBox(),
                              detailTitleWidget("LxBxH(HH)", titleStyle),
                              detailsSizedBox(),
                              detailTitleWidget("Weight(GM)", titleStyle),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              detailSubTitleWidget(data.description, subTitleStyle),
                              detailsSizedBox(),
                              detailSubTitleWidget(data.skuCode, subTitleStyle),
                              detailsSizedBox(),
                              detailSubTitleWidget(data.categoryName, subTitleStyle),
                              detailsSizedBox(),
                              detailSubTitleWidget("${data.price}", subTitleStyle),
                              detailsSizedBox(),
                              detailSubTitleWidget(data.color.map((e) => e).join(","), subTitleStyle),
                              detailsSizedBox(),
                              detailSubTitleWidget(data.size.map((e) => e).join(","), subTitleStyle),
                              detailsSizedBox(),
                              detailSubTitleWidget(data.brand.toString(), subTitleStyle),
                              detailsSizedBox(),
                              detailSubTitleWidget("${data.length}x${data.width}x${data.height}", subTitleStyle),
                              detailsSizedBox(),
                              detailSubTitleWidget("${data.weight}", subTitleStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget detailsSizedBox() => const SizedBox(
        height: 10,
      );

  Widget detailTitleWidget(String title, TextStyle style) => Text(
        title,
        style: style,
      );

  Widget detailSubTitleWidget(String subTitle, TextStyle style) => Text(
        subTitle,
        style: style,
      );

  _showReportTypeSelection(BuildContext context, bool isDownload) {
    final ThemeController themeController = Get.find<ThemeController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(() {
          final isDark = themeController.isDarkMode.value;
          final sheetBg = isDark ? AppColor.primary800 : AppColor.white;
          final txtColor = isDark ? AppColor.white : AppColor.primary900;
          final iconColor = isDark ? AppColor.primary200 : AppColor.primary800;
          final dividerColor = isDark ? AppColor.primary700 : Colors.grey.shade300;

          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Choose Report Type",
                    style: TextStyle(
                      color: txtColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.analytics_outlined, color: iconColor),
                    title: Text(
                      "Sales Report",
                      style: TextStyle(
                        color: txtColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "Standard sales report grouped by SKU",
                      style: TextStyle(color: isDark ? AppColor.primary300 : const Color(0xFF4B5563)),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: iconColor),
                    onTap: () {
                      Navigator.pop(context);
                      controller.selectedReportType.value = "sales";
                      _selectDate(context, isDownload);
                    },
                  ),
                  Divider(color: dividerColor),
                  ListTile(
                    leading: Icon(Icons.branding_watermark_outlined, color: iconColor),
                    title: Text(
                      "Brand Report",
                      style: TextStyle(
                        color: txtColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "Spreadsheet-style report grouped by Brand and SKU size variations",
                      style: TextStyle(color: isDark ? AppColor.primary300 : const Color(0xFF4B5563)),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: iconColor),
                    onTap: () {
                      Navigator.pop(context);
                      controller.selectedReportType.value = "brand";
                      _selectDate(context, isDownload);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  _selectDate(BuildContext context, bool isDownload) {
    final ThemeController themeController = Get.find<ThemeController>();
    return Get.dialog(
      Obx(() {
        final isDark = themeController.isDarkMode.value;
        final dialogBg = isDark ? AppColor.primary800 : AppColor.primary100;
        final txtColor = isDark ? AppColor.white : AppColor.primary900;
        final labelColor = isDark ? AppColor.primary200 : AppColor.primary800;

        return Dialog(
          backgroundColor: dialogBg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Date",
                  style: TextStyle(
                    color: txtColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Start Date",
                            style: TextStyle(
                              color: labelColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          TextFieldWidget(
                            controller: controller.startDateTxtController,
                            isPrefix: false,
                            textStyleColour: txtColor,
                            readOnly: true,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: controller.selectStartDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 1000),
                                ),
                                lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59),
                              ).then((val) {
                                if (val != null) {
                                  var selDate = DateTime(val.year, val.month, val.day);
                                  controller.selectedStartDate(selDate);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "End Date",
                            style: TextStyle(
                              color: labelColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          TextFieldWidget(
                            controller: controller.endDateTxtController,
                            isPrefix: false,
                            textStyleColour: txtColor,
                            readOnly: true,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: controller.selectEndDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 1000),
                                ),
                                lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59),
                              ).then((val) {
                                if (val != null) {
                                  var selDate = DateTime(val.year, val.month, val.day);
                                  controller.selectedEndDate(selDate);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: txtColor,
                          side: BorderSide(color: txtColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        onPressed: () {
                          _reportSave(isDownload);
                        },
                        bgColor: isDark ? AppColor.primary900 : AppColor.primary800,
                        textColor: AppColor.white,
                        text: "Save",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  _reportSave(bool isDownload) {
    var startDate = DateTime(
      controller.selectStartDate.year,
      controller.selectStartDate.month,
      controller.selectStartDate.day,
    );
    var endDate = DateTime(
      controller.selectEndDate.year,
      controller.selectEndDate.month,
      controller.selectEndDate.day,
    );
    if (endDate.isBefore(startDate)) {
      AppSnacks.errorSnack(message: "Enter correct date");
    } else {
      controller.getReport(isDownload);
    }
  }
}

