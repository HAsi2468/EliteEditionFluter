import 'package:cross_scroll/cross_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/modules/home/controller/home_controller.dart';
import 'package:elite_edition/routes/app_routes.dart';
import 'package:elite_edition/shared_widget/app_button.dart';
import 'package:elite_edition/shared_widget/app_cache_image.dart';
import 'package:elite_edition/shared_widget/app_image.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';
import 'package:elite_edition/shared_widget/textfield_widget.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColor.primary800,
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
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.share_rounded,
                  color: AppColor.primary800,
                  size: 20,
                ),
                // child: AppAssetImage(image: "assets/icons/email.png"),
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
      body: Column(
        children: [
          Container(
            width: size.width,
            height: size.height * 0.17,
            decoration: BoxDecoration(color: AppColor.primary800),
            child: Column(
              children: [
                const SizedBox(
                  height: 60,
                ),
                // const AppAssetImage(
                //   image: "assets/icons/Logo.png",
                //   height: 50,
                //   // width: 50,
                //   // fit: BoxFit.fill,
                // ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFieldWidget(
                    imagePath: "assets/icons/Search.png",
                    controller: controller.searchTxtController,
                    hintText: "Search product item",
                    bgColor: AppColor.primary900,
                    borderColor: AppColor.transparent,
                    imgColor: AppColor.primary600,
                    hintTextColour: AppColor.primary600,
                    imgHeight: 25,
                    imgWidth: 25,
                    onChanged: (val) => controller.searchProduct(val),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: AppColor.white,
              ),
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: controller.dataList.isEmpty
                            ? Center(
                                child: Text(
                                  "No Data Found",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primary900,
                                  ),
                                ),
                              )
                            : LazyLoadScrollView(
                                onEndOfPage: () => controller.loadMore(),
                                child: ListView.builder(
                                  itemCount: controller.dataList.length,
                                  shrinkWrap: true,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  itemBuilder: (context, index) {
                                    var data = controller.dataList[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Get.toNamed(AppRoutes.productDetails,
                                            arguments: {
                                              "skuCode": data.itemSkuCode,
                                              "skuName": data.skuName,
                                            });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColor.primary100,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        margin: const EdgeInsets.only(
                                            bottom: 10,
                                            left: 7,
                                            right: 7,
                                            top: 5),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              child: AppCacheImage(
                                                imageUrl: data.productImage,
                                                height: 230,
                                                width: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data.skuName.isNotEmpty ? data.skuName : data.itemSkuCode,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColor.primary900,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                // Row(
                                                //   children: [
                                                //     Column(
                                                //       crossAxisAlignment:
                                                //           CrossAxisAlignment
                                                //               .start,
                                                //       children: [
                                                //         _cardRowDetails("Size",
                                                //             data.itemTypeSize),
                                                //         _cardRowDetails(
                                                //             "Category",
                                                //             data.category),
                                                //         _cardRowDetails("State",
                                                //             data.shippingAddressState),
                                                //         _cardRowDetails(
                                                //             "OrderDate",
                                                //             "${data.orderDate.day}-${data.orderDate.month}-${data.orderDate.year}"),
                                                //       ],
                                                //     ),
                                                //     Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                //       children: [
                                                //         _cardRowDetails(
                                                //             "Color",
                                                //             data.itemTypeColor),
                                                //         _cardRowDetails(
                                                //             "Brand",
                                                //             data.itemTypeBrand),
                                                //         _cardRowDetails(
                                                //             "City",
                                                //             data.shippingAddressCity),
                                                //         _cardRowDetails(
                                                //             "Sells",
                                                //             data.itemSKUCodeCount),
                                                //       ],
                                                //     ),
                                                //   ],
                                                // ),
                                                _cardRowDetails(
                                                    "SKU Code", data.itemSkuCode),
                                                _cardRowDetails(
                                                    "Size", data.itemTypeSize),
                                                _cardRowDetails(
                                                    "Category", data.category),
                                                _cardRowDetails("State",
                                                    data.shippingAddressState),
                                                _cardRowDetails("OrderDate",
                                                    "${data.orderDate.day}-${data.orderDate.month}-${data.orderDate.year} ${data.orderDate.hour}:${data.orderDate.minute}"),
                                                _cardRowDetails("Color",
                                                    data.itemTypeColor),
                                                _cardRowDetails("Brand",
                                                    data.itemTypeBrand),
                                                _cardRowDetails("City",
                                                    data.shippingAddressCity),
                                                _cardRowDetails(
                                                    "Sells",
                                                    data.itemSKUCodeCount
                                                        .toString()),
                                                _cardRowDetails(
                                                    "Price", data.totalPrice),
                                                _cardRowDetails("Status",
                                                    data.saleOrderStatus),
                                                // _detailText(data.itemTypeSize),
                                                // _detailText(data.category),
                                                // _detailText(
                                                //     data.shippingAddressState),
                                                // _detailText(
                                                //     "${data.orderDate.day}-${data.orderDate.month}-${data.orderDate.year}"),
                                                // _detailText(data.itemTypeColor),
                                                // _detailText(data.itemTypeBrand),
                                                // _detailText(
                                                //     data.shippingAddressCity),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(20),
              //   topRight: Radius.circular(20),
              // ),
              color: AppColor.white,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _filterOnTap(context, size),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppAssetImage(
                            image: "assets/icons/filter.png",
                            height: 25,
                            width: 25,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Filter",
                            style: TextStyle(
                              color: AppColor.primary700,
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(
                    color: AppColor.primary900,
                    thickness: 2,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _sortOnTap(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppAssetImage(
                            image: "assets/icons/sort-descending.png",
                            height: 25,
                            width: 25,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Sort",
                            style: TextStyle(
                              color: AppColor.primary700,
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardRowDetails(String title, String subTitle) {
    return Row(
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.primary900,
          ),
        ),
        Text(
          " : ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.primary800,
          ),
        ),
        // const SizedBox(
        //   width: 5,
        // ),
        Text(
          subTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.primary800,
          ),
        ),
      ],
    );
  }

  Widget _detailText(String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColor.primary900,
        ),
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

  _selectDate(BuildContext context, bool isDownload) {
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

  _filterOnTap(BuildContext context, Size size) async {
    Get.bottomSheet(
      Container(
        height: size.height / 1.2,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Obx(
          () => controller.isFilterLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 80,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColor.primary900,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: size.width,
                      height: 1,
                      decoration: BoxDecoration(
                        color: AppColor.black,
                        // borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: ListView.builder(
                              itemCount: controller.filterDataList.length,
                              // physics:
                              //     const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              itemBuilder: (context, index) {
                                var data = controller.filterDataList[index];
                                return InkWell(
                                  onTap: () => controller.selectFilter(data),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: controller.selectedFilter.value ==
                                              null
                                          ? AppColor.white
                                          : controller.selectedFilter.value
                                                      ?.name ==
                                                  data.name
                                              ? AppColor.primary200
                                              : AppColor.white,
                                    ),
                                    // padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          data.name,
                                          style: TextStyle(
                                            color: AppColor.primary900,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                          height: 1,
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          VerticalDivider(
                            color: AppColor.black,
                            width: 1,
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 5, right: 3),
                              child: controller.selectedFilter.value?.name
                                          .toLowerCase() ==
                                      "cities"
                                  ? ListView.builder(
                                      itemCount: controller
                                          .selectedFilter.value!.values.length,
                                      itemBuilder: (context, i) {
                                        var res = controller
                                            .selectedFilter.value!.values[i];
                                        return ExpansionTile(
                                          title: Text("${res['state']}"),
                                          children: [
                                            Wrap(
                                              spacing: 10,
                                              children: List.generate(
                                                res['cities'].length,
                                                (e) => Obx(
                                                  () => FilterChip(
                                                    label: Text(
                                                        "${res['cities'][e]}"),
                                                    backgroundColor:
                                                        AppColor.white,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    selectedColor:
                                                        AppColor.primary300,
                                                    selected: controller
                                                        .selectCity
                                                        .contains(
                                                            res['cities'][e]),
                                                    onSelected: (val) {
                                                      if (controller.selectCity
                                                          .contains(
                                                              res['cities']
                                                                  [e])) {
                                                        controller.selectCity
                                                            .remove(
                                                                res['cities']
                                                                    [e]);
                                                      } else {
                                                        controller.selectCity
                                                            .add(res['cities']
                                                                [e]);
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      })
                                  : controller.selectedFilter.value?.name
                                              .toLowerCase() ==
                                          "date"
                                      // ? Column(
                                      //     crossAxisAlignment:
                                      //         CrossAxisAlignment.start,
                                      //     children: [
                                      //       /*Expanded(
                                      //         child: DateRangePickerDialog(
                                      //           firstDate:
                                      //               DateTime.now().subtract(
                                      //             const Duration(days: 1000),
                                      //           ),
                                      //           lastDate: DateTime.now(),
                                      //           initialEntryMode: DatePickerEntryMode.calendarOnly,
                                      //         ),
                                      //       ),*/
                                      //       // Text(
                                      //       //   "Start Date",
                                      //       //   style: TextStyle(
                                      //       //     color: AppColor.primary800,
                                      //       //     fontWeight: FontWeight.w600,
                                      //       //     fontSize: 17,
                                      //       //   ),
                                      //       // ),
                                      //       // SizedBox(height: 5,),
                                      //       // TextFieldWidget(
                                      //       //   controller: controller
                                      //       //       .filterStartDateTxtController,
                                      //       //   isPrefix: false,
                                      //       //   textStyleColour:
                                      //       //       AppColor.primary900,
                                      //       //   readOnly: true,
                                      //       //   onTap: () {
                                      //       //     showDatePicker(
                                      //       //       context: context,
                                      //       //       firstDate:
                                      //       //           DateTime.now().subtract(
                                      //       //         const Duration(days: 1000),
                                      //       //       ),
                                      //       //       lastDate: DateTime.now(),
                                      //       //     ).then((val) {
                                      //       //       if (val != null) {
                                      //       //         var selDate = DateTime(
                                      //       //             val.year,
                                      //       //             val.month,
                                      //       //             val.day);
                                      //       //         controller
                                      //       //             .selectedFilterStartDate(
                                      //       //                 selDate);
                                      //       //       }
                                      //       //     });
                                      //       //   },
                                      //       // ),
                                      //       // SizedBox(
                                      //       //   height: 20,
                                      //       // ),
                                      //       // Text(
                                      //       //   "End Date",
                                      //       //   style: TextStyle(
                                      //       //     color: AppColor.primary800,
                                      //       //     fontWeight: FontWeight.w600,
                                      //       //     fontSize: 17,
                                      //       //   ),
                                      //       // ),
                                      //       // SizedBox(height: 5,),
                                      //       // TextFieldWidget(
                                      //       //   controller: controller
                                      //       //       .filterEndDateTxtController,
                                      //       //   isPrefix: false,
                                      //       //   textStyleColour:
                                      //       //       AppColor.primary900,
                                      //       //   readOnly: true,
                                      //       //   onTap: () {
                                      //       //     showDatePicker(
                                      //       //       context: context,
                                      //       //       firstDate:
                                      //       //           DateTime.now().subtract(
                                      //       //         const Duration(days: 1000),
                                      //       //       ),
                                      //       //       lastDate: DateTime.now(),
                                      //       //     ).then((val) {
                                      //       //       if (val != null) {
                                      //       //         var selDate = DateTime(
                                      //       //             val.year,
                                      //       //             val.month,
                                      //       //             val.day);
                                      //       //         controller.selectedFilterEndDate(
                                      //       //             selDate);
                                      //       //       }
                                      //       //     });
                                      //       //   },
                                      //       // ),
                                      //     ],
                                      //   )
                                      ? CrossScroll(
                                          child: Column(
                                            children: [
                                              DateRangePickerWidget(
                                                onDateRangeChanged: (val) {
                                                  print(
                                                      "Select date <><> $val");
                                                  if (val != null) {
                                                    controller
                                                        .selectedFilterStartDate(
                                                            val.start);
                                                    controller
                                                        .selectedFilterEndDate(
                                                            val.end);
                                                  }
                                                },
                                                allowSingleTapDaySelection:
                                                    true,
                                                doubleMonth: false,
                                                maxDate: DateTime.now(),
                                                minDate: DateTime(1950),
                                                height: 340,
                                                initialDateRange: DateRange(
                                                    controller
                                                            .selectFilterStartDate ??
                                                        DateTime.now(),
                                                    controller
                                                            .selectFilterEndDate ??
                                                        DateTime.now()),
                                                initialDisplayedDate:
                                                    DateTime.now(),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 10,
                                          children: List.generate(
                                              controller.selectedFilter.value!
                                                  .values.length, (i) {
                                            var e = controller.selectedFilter
                                                .value!.values[i];
                                            return FilterChip(
                                              label: Text("$e"),
                                              backgroundColor: AppColor.white,
                                              padding: const EdgeInsets.all(5),
                                              selectedColor:
                                                  AppColor.primary300,
                                              selected: controller
                                                          .selectedFilter
                                                          .value!
                                                          .name
                                                          .toLowerCase() ==
                                                      "category"
                                                  ? controller.selectCategory
                                                      .contains(e)
                                                  : controller.selectedFilter
                                                              .value!.name
                                                              .toLowerCase() ==
                                                          "colors"
                                                      ? controller.selectColor
                                                          .contains(e)
                                                      : controller.selectedFilter
                                                                  .value!.name
                                                                  .toLowerCase() ==
                                                              "order status"
                                                          ? controller
                                                              .selectStatus
                                                              .contains(e)
                                                          : controller
                                                                      .selectedFilter
                                                                      .value!
                                                                      .name
                                                                      .toLowerCase() ==
                                                                  "brands"
                                                              ? controller.selectBrand.contains(e)
                                                              : controller.selectSize.contains(e),
                                              onSelected: (val) {
                                                if (controller.selectedFilter
                                                        .value!.name
                                                        .toLowerCase() ==
                                                    "category") {
                                                  if (controller.selectCategory
                                                      .contains(e)) {
                                                    controller.selectCategory
                                                        .remove(e);
                                                  } else {
                                                    controller.selectCategory
                                                        .add(e);
                                                  }
                                                } else if (controller
                                                        .selectedFilter
                                                        .value!
                                                        .name
                                                        .toLowerCase() ==
                                                    "colors") {
                                                  if (controller.selectColor
                                                      .contains(e)) {
                                                    controller.selectColor
                                                        .remove(e);
                                                  } else {
                                                    controller.selectColor
                                                        .add(e);
                                                  }
                                                } else if (controller
                                                        .selectedFilter
                                                        .value!
                                                        .name
                                                        .toLowerCase() ==
                                                    "brands") {
                                                  if (controller.selectBrand
                                                      .contains(e)) {
                                                    controller.selectBrand
                                                        .remove(e);
                                                  } else {
                                                    controller.selectBrand
                                                        .add(e);
                                                  }
                                                } else if (controller
                                                        .selectedFilter
                                                        .value!
                                                        .name
                                                        .toLowerCase() ==
                                                    "order status") {
                                                  if (controller.selectStatus
                                                      .contains(e)) {
                                                    controller.selectStatus
                                                        .remove(e);
                                                  } else {
                                                    controller.selectStatus
                                                        .add(e);
                                                  }
                                                } else if (controller
                                                        .selectedFilter
                                                        .value!
                                                        .name
                                                        .toLowerCase() ==
                                                    "sizes") {
                                                  if (controller.selectSize
                                                      .contains(e)) {
                                                    controller.selectSize
                                                        .remove(e);
                                                  } else {
                                                    controller.selectSize
                                                        .add(e);
                                                  }
                                                }
                                              },
                                            );
                                          }),
                                        ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        border: const Border(
                          top: BorderSide(),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: controller.selectCategory.isEmpty &&
                                      controller.selectColor.isEmpty &&
                                      controller.selectBrand.isEmpty &&
                                      controller.selectSize.isEmpty &&
                                      controller.selectStatus.isEmpty &&
                                      controller.selectCity.isEmpty &&
                                      !controller.isFilterDateSelected.value
                                  ? null
                                  : () {
                                      Get.back();
                                      controller.clearFilter();
                                    },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColor.primary900,
                              ),
                              child: const Text("Clear All"),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: AppButton(
                              onPressed: controller.selectCategory.isEmpty &&
                                      controller.selectColor.isEmpty &&
                                      controller.selectBrand.isEmpty &&
                                      controller.selectSize.isEmpty &&
                                      controller.selectStatus.isEmpty &&
                                      controller.selectCity.isEmpty &&
                                      !controller.isFilterDateSelected.value
                                  ? null
                                  : () {
                                      Get.back();
                                      controller.applyFilter();
                                    },
                              text: "Apply",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
    );
  }

  _sortOnTap() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: ListView.separated(
          itemBuilder: (context, index) {
            var data = controller.sortList[index];
            return Obx(
              () => RadioListTile(
                value: data,
                groupValue: controller.selectedSort.value,
                onChanged: (val) {
                  controller.selectedSort.value = val.toString();
                  print("VALUE <> $val ||| ${controller.selectedSort.value}");
                  Get.back();
                  if (controller.selectedSort.value.toLowerCase() != "none") {
                    controller.applySort();
                  } else {
                    controller.clearSort();
                  }
                },
                title: Text(data),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          itemCount: controller.sortList.length,
          shrinkWrap: true,
        ),
      ),
      isScrollControlled: false,
    );
  }
}
