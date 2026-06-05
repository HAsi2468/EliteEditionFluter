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

class ProductDetailsView extends StatelessWidget {
  ProductDetailsView({super.key});

  final ProductDetailsController controller = Get.find();

  final detailStyleTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 17,
    color: AppColor.primary800,
  );

  final detailStyleSubTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 17,
    color: AppColor.primary600,
  );

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColor.white,
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
            backgroundColor: AppColor.primary900,
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
            backgroundColor: AppColor.primary900,
            shape: const CircleBorder(),
            heroTag: null,
          ),
          children: [
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () {
                _showReportTypeSelection(context, true);
              },
              backgroundColor: AppColor.primary100,
              shape: CircleBorder(
                side: BorderSide(color: AppColor.primary900),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: AppAssetImage(image: "assets/icons/download.png"),
              ),
            ),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () {
                _showReportTypeSelection(context, false);
              },
              backgroundColor: AppColor.primary100,
              shape: CircleBorder(
                side: BorderSide(color: AppColor.primary900),
              ),
              child:  Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(Icons.share_rounded,color: AppColor.primary800,size: 20,),
              ),
            ),
            // FloatingActionButton.small(
            //   onPressed: () {
            //     _selectDate(context);
            //   },
            //   backgroundColor: AppColor.primary100,
            //   shape: CircleBorder(
            //     side: BorderSide(color: AppColor.primary900),
            //   ),
            //   child: const Padding(
            //     padding: EdgeInsets.all(8),
            //     child: AppAssetImage(image: "assets/icons/download.png"),
            //   ),
            // ),
          ],
          // closeButtonBuilder: FloatingActionButtonBuilder(
          //   size: 56,
          //   builder: (BuildContext context, void Function()? onPressed,
          //       Animation<double> progress) {
          //     return IconButton(
          //       onPressed: onPressed,
          //       icon: AppAssetImage(image: "assets/icons/back.png",height: 40,width: 40,),
          //     );
          //   },
          // ),
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
        backgroundColor: AppColor.primary900,
        title: Obx(
          () => controller.isLoading.value
              ? SizedBox()
              : Text(
                  controller.dataModel.value!.skuCode,
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        AppCacheImage(
                          imageUrl: controller.dataModel.value!.imageUrl,
                          width: size.width,
                        ),
                        Positioned(
                          bottom: 0,
                          width: size.width,
                          child: Text(
                            controller.dataModel.value!.skuCode,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: AppColor.white,
                            ),
                          ),
                        ),
                        Positioned(
                          // top: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, top: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(17),
                                foregroundColor: AppColor.primary900,
                                backgroundColor: AppColor.primary900,
                              ),
                              onPressed: () {
                                // controller.downloadImage(
                                //     context: context,
                                //     image: controller.dataModel.imageUrl);
                                controller.downloadImageWithWatermark(
                                    controller.dataModel.value!.imageUrl);
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
                        color: AppColor.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.dataModel.value!.skuCode,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: AppColor.primary900,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            controller.dataModel.value!.description,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: AppColor.primary800,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Product Details",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: AppColor.primary900,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    detailTitleWidget("Item Name"),
                                    detailsSizedBox(),
                                    detailTitleWidget("SKU Code"),
                                    // detailsSizedBox(),
                                    // detailTitleWidget("GST Tax Type"),
                                    detailsSizedBox(),
                                    detailTitleWidget("Category"),
                                    detailsSizedBox(),
                                    detailTitleWidget("MRP"),
                                    detailsSizedBox(),
                                    detailTitleWidget("Color"),
                                    detailsSizedBox(),
                                    detailTitleWidget("Size"),
                                    detailsSizedBox(),
                                    detailTitleWidget("Brand"),
                                    // detailsSizedBox(),
                                    // detailTitleWidget("Total Sales"),
                                    // detailsSizedBox(),
                                    // detailTitleWidget("Order Date"),
                                    detailsSizedBox(),
                                    detailTitleWidget("LxBxH(HH)"),
                                    detailsSizedBox(),
                                    detailTitleWidget("Weight(GM)"),
                                    // detailsSizedBox(),
                                    // detailTitleWidget("EAN"),
                                    // detailsSizedBox(),
                                    // detailTitleWidget("Product URL"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    detailSubTitleWidget(
                                        controller.dataModel.value!.description),
                                    detailsSizedBox(),
                                    detailSubTitleWidget(
                                        controller.dataModel.value!.skuCode),
                                    // detailsSizedBox(),
                                    // detailSubTitleWidget(
                                    //     controller.dataModel.value!.gstTaxTypeCode == null ? "-" :"${controller.dataModel.value!.gstTaxTypeCode}"),
                                    detailsSizedBox(),
                                    detailSubTitleWidget(
                                        controller.dataModel.value!.categoryName),
                                    detailsSizedBox(),
                                    detailSubTitleWidget(
                                        "${controller.dataModel.value!.price}"),
                                    detailsSizedBox(),
                                    detailSubTitleWidget(controller
                                        .dataModel.value!.color
                                        .map((e) => e)
                                        .join(",")),
                                    detailsSizedBox(),
                                    detailSubTitleWidget(controller
                                        .dataModel.value!.size
                                        .map((e) => e)
                                        .join(",")),
                                    detailsSizedBox(),
                                    detailSubTitleWidget(controller
                                        .dataModel.value!.brand.toString()),
                                    // detailsSizedBox(),
                                    // detailSubTitleWidget("-"),
                                    // detailsSizedBox(),
                                    // detailSubTitleWidget("-"),
                                    detailsSizedBox(),
                                    /// old
                                    // detailSubTitleWidget(controller
                                    //     .dataModel.value!.selseOfTheDay
                                    //     .map((e) => e.sleas)
                                    //     .join(",")),
                                    // detailsSizedBox(),
                                    // detailSubTitleWidget(controller
                                    //     .dataModel.value!.selseOfTheDay
                                    //     .map((e) => e.sleas)
                                    //     .reduce((a, b) => a + b)
                                    //     .toString()),
                                    // detailsSizedBox(),
                                    // detailSubTitleWidget(
                                    //     "${controller.dataModel.value!.orderDate.day}-${controller.dataModel.value!.orderDate.month}-${controller.dataModel.value!.orderDate.year}"),
                                    // detailsSizedBox(),
                                    detailSubTitleWidget(
                                        "${controller.dataModel.value!.length}x${controller.dataModel.value!.width}x${controller.dataModel.value!.height}"),
                                    detailsSizedBox(),
                                    detailSubTitleWidget(
                                        "${controller.dataModel.value!.weight}"),
                                    // detailsSizedBox(),
                                    // detailSubTitleWidget("-"),
                                    // detailsSizedBox(),
                                    // detailSubTitleWidget("-"),
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
      ),
    );
  }

  detailsSizedBox() => const SizedBox(
        height: 10,
      );

  detailTitleWidget(String title) => Text(
        title,
        style: detailStyleTitle,
      );

  detailSubTitleWidget(String subTitle) => Text(
        subTitle,
        style: detailStyleSubTitle,
      );

  _showReportTypeSelection(BuildContext context, bool isDownload) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Choose Report Type",
                  style: TextStyle(
                    color: AppColor.primary900,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.analytics_outlined, color: AppColor.primary800),
                  title: Text(
                    "Sales Report",
                    style: TextStyle(
                      color: AppColor.primary900,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text("Standard sales report grouped by SKU"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    controller.selectedReportType.value = "sales";
                    _selectDate(context, isDownload);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.branding_watermark_outlined, color: AppColor.primary800),
                  title: Text(
                    "Brand Report",
                    style: TextStyle(
                      color: AppColor.primary900,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text("Spreadsheet-style report grouped by Brand and SKU size variations"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
      },
    );
  }

  _selectDate(BuildContext context,bool isDownload) {
    return Get.dialog(
      Dialog(
        backgroundColor: AppColor.primary100,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Date",
                style: TextStyle(
                  color: AppColor.primary900,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Start Date",
                          style: TextStyle(
                            color: AppColor.primary800,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        TextFieldWidget(
                          controller: controller.startDateTxtController,
                          isPrefix: false,
                          textStyleColour: AppColor.primary900,
                          readOnly: true,
                          onTap: () {
                            showDatePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 1000),
                              ),
                              lastDate: DateTime.now(),
                            ).then((val) {
                              if (val != null) {
                                var selDate =
                                DateTime(val.year, val.month, val.day);
                                controller.selectedStartDate(selDate);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "End Date",
                          style: TextStyle(
                            color: AppColor.primary800,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        TextFieldWidget(
                          controller: controller.endDateTxtController,
                          isPrefix: false,
                          textStyleColour: AppColor.primary900,
                          readOnly: true,
                          onTap: () {
                            showDatePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 1000),
                              ),
                              lastDate: DateTime.now(),
                            ).then((val) {
                              if (val != null) {
                                var selDate =
                                DateTime(val.year, val.month, val.day);
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
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onPressed: () {
                        _reportSave(isDownload);
                      },
                      text: "Save",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
