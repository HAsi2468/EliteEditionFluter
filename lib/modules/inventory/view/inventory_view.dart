import 'package:elite_edition/modules/inventory/view/stock_out_scanner_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:elite_edition/modules/inventory/controller/inventory_controller.dart';
import 'package:elite_edition/modules/inventory/model/inventory_item_model.dart';
import 'package:elite_edition/modules/inventory/model/vendor_model.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/constants/api_url.dart';
import 'package:elite_edition/shared_widget/textfield_widget.dart';
import 'package:elite_edition/shared_widget/create_pdf.dart';
import 'package:elite_edition/utils/pdf_helper.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';
import 'package:elite_edition/shared_widget/app_pdfview.dart';
import 'package:elite_edition/shared_widget/create_inventory_csv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isDark = controller.isDarkMode.value;
      final Color scaffoldBg =
          isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
      final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
      final Color textSecondary =
          isDark ? AppColor.primary600 : const Color(0xFF4B5563);
      final Color searchBg = isDark ? AppColor.primary900 : Colors.white;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon:
                      Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                  onPressed: () => Get.back(),
                )
              : null,
          title: Text(
            "Inventory Management",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          actions: [
            // Theme Toggle Button
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: child.key == const ValueKey('dark')
                      ? Tween<double>(begin: 0.75, end: 1.0).animate(anim)
                      : Tween<double>(begin: 0.25, end: 1.0).animate(anim),
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: isDark
                    ? const Icon(Icons.light_mode_rounded,
                        color: Colors.amberAccent, key: ValueKey('light'))
                    : Icon(Icons.dark_mode_rounded,
                        color: Colors.indigo.shade800,
                        key: const ValueKey('dark')),
              ),
              tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
              onPressed: () => controller.toggleTheme(),
            ),

            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: textColor),
              color: isDark ? AppColor.primary900 : Colors.white,
              onSelected: (value) {
                if (value == 'vendors') {
                  _showManageVendorsDialog(context);
                } else if (value == 'parties') {
                  _showManageNewPartiesDialog(context);
                } else if (value == 'products') {
                  _showManageProductsDialog(context);
                } else if (value == 'history') {
                  _showHistoryDialog(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'vendors',
                  child: Row(
                    children: [
                      Icon(Icons.business_outlined, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Manage Vendors',
                          style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'parties',
                  child: Row(
                    children: [
                      Icon(Icons.people_alt_outlined, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Manage Parties',
                          style: TextStyle(color: textColor)),
                    ],
                  ),
                ),

                PopupMenuItem<String>(
                  value: 'products',
                  child: Row(
                    children: [
                      Icon(Icons.category_outlined, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Manage Products',
                          style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text('History', style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFieldWidget(
                      imagePath: "assets/icons/Search.png",
                      controller: controller.searchController,
                      hintText: "Search by item name, SKU or party",
                      bgColor: searchBg,
                      borderColor:
                          isDark ? AppColor.transparent : const Color(0xFFD1D5DB),
                      imgColor: textSecondary,
                      hintTextColour: textSecondary,
                      imgHeight: 25,
                      imgWidth: 25,
                      onChanged: (val) => controller.onSearchChanged(val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => _showReportDateSelection(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.teal.withOpacity(0.5) : Colors.teal.shade200)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_rounded, color: isDark ? Colors.tealAccent : Colors.teal, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Report",
                            style: TextStyle(
                              color: isDark ? Colors.tealAccent : Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            )
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Inventory List — grouped by SKU
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: isDark ? Colors.white : Colors.teal),
                  );
                }

                if (controller.inventoryList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            color: textSecondary, size: 60),
                        const SizedBox(height: 12),
                        Text(
                          "No inventory items found",
                          style: TextStyle(color: textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final grouped = controller.groupedBySku;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final group = grouped[index];
                    return _buildSkuGroupCard(context, group);
                  },
                );
              }),
            ),

            // Action Buttons at the bottom (Stock In & Stock Out)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.clearForm();
                          _showAddEditDialog(context, null);
                        },
                        icon: const Icon(Icons.add_box_rounded, color: Colors.white, size: 22),
                        label: const Text(
                          "Stock In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => const StockOutScannerView());
                        },
                        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
                        label: const Text(
                          "Stock Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// SKU-grouped card: shows total stock, expands to per-party entries
  Widget _buildSkuGroupCard(BuildContext context, Map<String, dynamic> group) {
    final bool isDark = controller.isDarkMode.value;
    final Color cardBg = isDark ? AppColor.primary900 : Colors.white;
    final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
    final Color textSecondary =
        isDark ? AppColor.primary600 : const Color(0xFF6B7280);
    final Color dividerColor =
        isDark ? Colors.white10 : const Color(0xFFE5E7EB);
    final Color headerBg = isDark
        ? AppColor.primary800.withValues(alpha: 0.6)
        : const Color(0xFFF0FDF4);

    final int totalStock = group['totalStock'] as int;
    final int totalQty = group['totalQty'] as int;
    final String skuCode = group['skuCode'] as String;
    final String itemName = group['itemName'] as String;
    final String imageUrl = group['imageUrl'] as String;
    final List<InventoryItemModel> entries =
        group['entries'] as List<InventoryItemModel>;

    Color stockColor;
    if (totalStock == 0) {
      stockColor = Colors.redAccent;
    } else if (totalStock <= 5) {
      stockColor = Colors.orangeAccent;
    } else {
      stockColor = isDark ? Colors.greenAccent : const Color(0xFF10B981);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          backgroundColor: cardBg,
          collapsedBackgroundColor: cardBg,
          iconColor: textSecondary,
          collapsedIconColor: textSecondary,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: isDark ? AppColor.primary800 : const Color(0xFFF3F4F6),
              child: Image.network(
                ApiUrl.getFullImageUrl(imageUrl),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Icon(
                  Icons.inventory_2_outlined,
                  color: textSecondary,
                  size: 28,
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (skuCode.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColor.primary800 : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isDark
                          ? AppColor.primary600
                          : const Color(0xFFBFDBFE),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    skuCode,
                    style: TextStyle(
                      color: isDark
                          ? Colors.yellowAccent
                          : const Color(0xFF1E40AF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                itemName,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                // Total stock badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: stockColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.layers_rounded, size: 13, color: stockColor),
                      const SizedBox(width: 4),
                      Text(
                        "Stock: $totalStock",
                        style: TextStyle(
                          color: stockColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Total qty badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white10 : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 13, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        "Total: $totalQty",
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Party count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white10 : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business_outlined,
                          size: 13, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        "${entries.length} ${entries.length == 1 ? 'party' : 'parties'}",
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          children: [
            Divider(color: dividerColor, height: 1),
            Container(
              color: headerBg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.expand_more, size: 14, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    "Per-party breakdown",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ...entries.map(
                (item) => _buildPartyEntryRow(context, item, dividerColor)),
          ],
        ),
      ),
    );
  }

  /// One row per party entry inside the expanded SKU card
  Widget _buildPartyEntryRow(
      BuildContext context, InventoryItemModel item, Color dividerColor) {
    final bool isDark = controller.isDarkMode.value;
    final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
    final Color textSecondary =
        isDark ? AppColor.primary600 : const Color(0xFF6B7280);
    final Color rowBg = isDark ? AppColor.primary900 : Colors.white;

    Color stockColor;
    if (item.currentlyAvailableStock == 0) {
      stockColor = Colors.redAccent;
    } else if (item.currentlyAvailableStock <= 5) {
      stockColor = Colors.orangeAccent;
    } else {
      stockColor = isDark ? Colors.greenAccent : const Color(0xFF10B981);
    }

    return Container(
      color: rowBg,
      child: Column(
        children: [
          Divider(color: dividerColor, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Party name
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business_outlined,
                              size: 12, color: textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.party,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (item.size.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            "Size: ${item.size}",
                            style:
                                TextStyle(color: textSecondary, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
                // Stock / Qty
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${item.currentlyAvailableStock}/${item.qty}",
                        style: TextStyle(
                          color: stockColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "avail/total",
                        style: TextStyle(color: textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                // Prices
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${item.salePrice.toStringAsFixed(0)}",
                        style: TextStyle(
                          color: isDark
                              ? Colors.cyanAccent
                              : const Color(0xFF0D9488),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "sale",
                        style: TextStyle(color: textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 18, color: Colors.blueAccent),
                      tooltip: "Edit",
                      onPressed: () {
                        controller.populateForm(item);
                        _showAddEditDialog(context, item);
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.redAccent),
                      tooltip: "Delete",
                      onPressed: () => _confirmDelete(context, item),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, InventoryItemModel? item) {
    final bool isEdit = item != null;

    if (isEdit) {
      controller.selectedVendor.value = item.party;
      controller.itemNameController.text = item.itemName;
      controller.selectedSize.value = item.size;
      controller.stockController.text = item.qty.toString();
      controller.salePriceController.text = item.salePrice.toString();
      controller.purchasePriceController.text = item.purchasePrice.toString();
      controller.qtyController.text = item.qty.toString();
      controller.selectedSkuCode.value = item.skuCode ?? '';
      controller.selectedImageUrl.value = item.imageUrl ?? '';
      if (item.date != null) {
        controller.selectedDate.value = DateTime.tryParse(item.date!) ?? DateTime.now();
      } else {
        controller.selectedDate.value = DateTime.now();
      }
    } else {
      controller.clearForm();
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color inputBg =
              isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
          final Color borderCol =
              isDark ? AppColor.primary800 : const Color(0xFFE5E7EB);
          final Color hintColor = isDark
              ? AppColor.primary600.withValues(alpha: 0.5)
              : const Color(0xFF9CA3AF);

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? "Edit Stock Item" : "Add Stock Item",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Vendor Select Dropdown + Add Vendor Button
                  Text(
                    "Vendor*",
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final currentParty = controller.selectedVendor.value;
                          final isInList = controller.vendorsList
                              .any((p) => p.name == currentParty);
                          return DropdownSearch<String>(
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: TextStyle(color: textColor, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: "Search Vendor",
                                  hintStyle: TextStyle(color: hintColor, fontSize: 14),
                                  filled: true,
                                  fillColor: inputBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              menuProps: MenuProps(backgroundColor: dialogBg),
                            ),
                            items: (filter, loadProps) {
                              final query = filter.toLowerCase();
                              return controller.vendorsList
                                .map((p) => p.name)
                                .where((name) => name.toLowerCase().contains(query))
                                .toList();
                            },
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                hintText: "Select Vendor",
                                hintStyle: TextStyle(color: hintColor, fontSize: 14),
                                fillColor: inputBg,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: borderCol),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isDark
                                          ? AppColor.primary600
                                          : const Color(0xFF9CA3AF)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            selectedItem: isInList ? currentParty : null,
                            onSelected: (val) {
                              if (val != null) {
                                controller.selectedVendor.value = val;
                              }
                            },
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_business_rounded,
                            color: Colors.greenAccent, size: 24),
                        tooltip: "Add New Vendor",
                        onPressed: () => _showAddVendorDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Item Product Dropdown
                  Text(
                    "Product*",
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final currentSku = controller.selectedSkuCode.value;
                          final isInList = controller.productsList
                              .any((p) => p["skuCode"] == currentSku);
                          return DropdownSearch<dynamic>(
                            compareFn: (item, selectedItem) => item["skuCode"] == selectedItem["skuCode"],
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: TextStyle(color: textColor, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: "Search Product",
                                  hintStyle: TextStyle(color: hintColor, fontSize: 14),
                                  filled: true,
                                  fillColor: inputBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              menuProps: MenuProps(backgroundColor: dialogBg),
                              itemBuilder: (context, item, isSelected, isFocused) {
                                final img = item["imageUrl"] ?? "";
                                final name = item["description"] ?? "";
                                final sku = item["skuCode"] ?? "";
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      ApiUrl.getFullImageUrl(img),
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.image, size: 20, color: Colors.grey),
                                    ),
                                  ),
                                  title: Text(name, style: TextStyle(fontSize: 14, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: Text(sku, style: TextStyle(fontSize: 12, color: hintColor)),
                                );
                              },
                            ),
                            items: (filter, loadProps) {
                              final query = filter.toLowerCase();
                              return controller.productsList.where((p) {
                                final name = (p["description"] ?? "").toString().toLowerCase();
                                final sku = (p["skuCode"] ?? "").toString().toLowerCase();
                                return name.contains(query) || sku.contains(query);
                              }).toList();
                            },
                            dropdownBuilder: (context, selectedItem) {
                              if (selectedItem == null) {
                                return Text("Select Product", style: TextStyle(color: hintColor, fontSize: 14));
                              }
                              final img = selectedItem["imageUrl"] ?? "";
                              final name = selectedItem["description"] ?? "";
                              final sku = selectedItem["skuCode"] ?? "";
                              return Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      ApiUrl.getFullImageUrl(img),
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.image, size: 14, color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "$name ($sku)",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: textColor, fontSize: 13),
                                    ),
                                  ),
                                ],
                              );
                            },
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                fillColor: inputBg,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: borderCol),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isDark
                                          ? AppColor.primary600
                                          : const Color(0xFF9CA3AF)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            selectedItem: isInList
                                ? controller.productsList.firstWhere(
                                    (p) => p["skuCode"] == currentSku)
                                : null,
                            onSelected: (val) {
                              if (val != null) {
                                controller.onProductSelected(val);
                              }
                            },
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_box_rounded,
                            color: Colors.greenAccent, size: 24),
                        tooltip: "Add New Product",
                        onPressed: () => _showAddProductDialog(context),
                      ),
                    ],
                  ),

                  // Image Preview
                  Obx(() {
                    if (controller.selectedImageUrl.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            ApiUrl.getFullImageUrl(
                                controller.selectedImageUrl.value),
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Size Dropdown or Text Box
                  Text(
                    "Size*",
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    if (controller.sizeOptionsList.isEmpty) {
                      return TextField(
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          fillColor: inputBg,
                          filled: true,
                          hintText: "Enter Size manually",
                          hintStyle: TextStyle(color: hintColor, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: borderCol),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isDark
                                    ? AppColor.primary600
                                    : const Color(0xFF9CA3AF)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (val) => controller.selectedSize.value = val,
                      );
                    }

                    final currentSize = controller.selectedSize.value;
                    final isInList =
                        controller.sizeOptionsList.contains(currentSize);
                    return DropdownButtonFormField<String>(
                      dropdownColor: dialogBg,
                      initialValue: isInList ? currentSize : null,
                      hint: Text("Select Size",
                          style: TextStyle(color: hintColor, fontSize: 14)),
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        fillColor: inputBg,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderCol),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDark
                                  ? AppColor.primary600
                                  : const Color(0xFF9CA3AF)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: controller.sizeOptionsList
                          .map((sz) => DropdownMenuItem<String>(
                                value: sz,
                                child: Text(sz),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedSize.value = val;
                        }
                      },
                    );
                  }),

                  const SizedBox(height: 12),

                  // Date Picker Row
                  Text(
                    "Date*",
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: isDark
                                ? ThemeData.dark().copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: Colors.greenAccent,
                                      onPrimary: AppColor.primary900,
                                      surface: AppColor.primary800,
                                      onSurface: Colors.white,
                                    ),
                                    dialogTheme: DialogThemeData(
                                        backgroundColor: AppColor.primary900),
                                  )
                                : ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.green.shade700,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        controller.selectedDate.value = picked;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                                "${controller.selectedDate.value.day.toString().padLeft(2, '0')}-${controller.selectedDate.value.month.toString().padLeft(2, '0')}-${controller.selectedDate.value.year}",
                                style:
                                    TextStyle(color: textColor, fontSize: 14),
                              )),
                          Icon(Icons.calendar_today_rounded,
                              color: labelColor, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  _buildFormInput("Initial Total Qty", controller.qtyController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildFormInput("Available Stock", controller.stockController,
                      keyboardType: TextInputType.number, enabled: false),
                  const SizedBox(height: 12),
                  _buildFormInput(
                      "Purchase Price (₹)", controller.purchasePriceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 12),
                  _buildFormInput(
                      "Sale Price (₹)", controller.salePriceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true)),

                  const SizedBox(height: 24),

                  // Staged items list
                  if (!isEdit) ...[
                    Obx(() {
                      if (controller.stagedItems.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Staged Items (${controller.stagedItems.length})",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => controller.stagedItems.clear(),
                                child: const Text(
                                  "Clear All",
                                  style: TextStyle(
                                      color: Colors.redAccent, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 180),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? AppColor.primary600
                                    : const Color(0xFFE5E7EB),
                                width: 0.5,
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(8),
                              itemCount: controller.stagedItems.length,
                              separatorBuilder: (context, index) => Divider(
                                color: isDark ? Colors.white10 : Colors.black12,
                                height: 8,
                              ),
                              itemBuilder: (context, idx) {
                                final staged = controller.stagedItems[idx];
                                final img = staged["imageUrl"] ?? "";
                                final name = staged["itemName"] ?? "";
                                final sku = staged["skuCode"] ?? "";
                                final size = staged["size"] ?? "";
                                final qty = staged["qty"] ?? 0;
                                final purchasePrice =
                                    staged["purchasePrice"] ?? 0.0;
                                final salePrice = staged["salePrice"] ?? 0.0;

                                return Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        color: isDark
                                            ? AppColor.primary900
                                            : const Color(0xFFE5E7EB),
                                        child: Image.network(
                                          ApiUrl.getFullImageUrl(img),
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Icon(
                                            Icons.image,
                                            size: 16,
                                            color: labelColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "SKU: $sku | Size: $size | Qty: $qty",
                                            style: TextStyle(
                                              color: isDark
                                                  ? AppColor.primary600
                                                  : const Color(0xFF6B7280),
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            "Buy: ₹$purchasePrice | Sell: ₹$salePrice",
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.cyanAccent
                                                  : const Color(0xFF0D9488),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        controller.stagedItems.removeAt(idx);
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: labelColor, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        final isActionLoading =
                            controller.isActionLoading.value;
                        final hasStaged = controller.stagedItems.isNotEmpty;

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isEdit && !isActionLoading) ...[
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark
                                      ? Colors.greenAccent
                                      : Colors.green.shade800,
                                  side: BorderSide(
                                      color: isDark
                                          ? Colors.greenAccent
                                          : Colors.green.shade800),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  controller.stageCurrentItem();
                                },
                                icon: const Icon(Icons.playlist_add_rounded,
                                    size: 18),
                                label: const Text("Add more item"),
                              ),
                              const SizedBox(width: 12),
                            ],

                            if (isActionLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.greenAccent),
                                ),
                              )
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  if (isEdit) {
                                    final success = await controller
                                        .updateInventoryItem(item.id ?? '');
                                    if (success) {
                                      Get.back();
                                    }
                                  } else {
                                    if (hasStaged) {
                                      final currentParty = controller
                                          .selectedVendor.value
                                          .trim();
                                      final currentSize =
                                          controller.selectedSize.value.trim();
                                      if (currentParty.isNotEmpty &&
                                          currentSize.isNotEmpty) {
                                        controller.stageCurrentItem();
                                      }
                                      final success = await controller
                                          .addStagedInventoryItems();
                                      if (success) {
                                        Get.back();
                                      }
                                    } else {
                                      final success =
                                          await controller.addInventoryItem();
                                      if (success) {
                                        Get.back();
                                      }
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Text(
                                    isEdit
                                        ? "Save"
                                        : (hasStaged
                                            ? "Save All (${controller.stagedItems.length})"
                                            : "Add"),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showAddVendorDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Add New Vendor",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildFormInput(
                      "Vendor Name*", controller.newVendorNameController),
                  const SizedBox(height: 12),
                  _buildFormInput(
                      "Phone Number", controller.newVendorPhoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildFormInput(
                      "Address", controller.newVendorAddressController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel",
                            style: TextStyle(color: labelColor, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.greenAccent),
                            ),
                          );
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final success = await controller.addVendor();
                            if (success) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text("Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        );
                      }),
                    ],
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Add New Product",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildFormInput("SKU Code*", controller.newSkuController),
                  const SizedBox(height: 12),
                  _buildFormInput(
                      "Product Name*", controller.newDescController),
                  const SizedBox(height: 12),
                  _buildFormInput("Image URL", controller.newImgUrlController),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setState) {
                      final Color inputBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
                      final Color hintColor = isDark ? AppColor.primary600.withValues(alpha: 0.5) : const Color(0xFF9CA3AF);
                      final Color borderCol = isDark ? AppColor.primary600 : const Color(0xFFE5E7EB);
                      final List<String> sizesList = ['3XS', 'XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL', '6XL', '7XL', '8XL', '9XL', '10XL'];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Size*",
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            dropdownColor: dialogBg,
                            value: controller.newSizesController.text.isEmpty ? null : controller.newSizesController.text,
                            hint: Text("Select Size", style: TextStyle(color: hintColor, fontSize: 14)),
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              fillColor: inputBg,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderCol),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isDark ? AppColor.primary600 : const Color(0xFF9CA3AF)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: sizesList.map((sz) => DropdownMenuItem(value: sz, child: Text(sz))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  controller.newSizesController.text = val;
                                });
                              }
                            },
                          ),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel",
                            style: TextStyle(color: labelColor, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.greenAccent),
                            ),
                          );
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final success = await controller.addProduct();
                            if (success) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text("Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        );
                      }),
                    ],
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFormInput(
    String label,
    TextEditingController txtController, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Obx(() {
      final bool isDark = controller.isDarkMode.value;
      final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
      final Color disabledTextColor = isDark ? Colors.white38 : Colors.black38;
      final Color labelColor =
          isDark ? AppColor.primary600 : const Color(0xFF4B5563);
      final Color inputBg =
          isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
      final Color hintColor = isDark
          ? AppColor.primary600.withValues(alpha: 0.5)
          : const Color(0xFF9CA3AF);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: txtController,
            keyboardType: keyboardType,
            enabled: enabled,
            style: TextStyle(
              color: enabled ? textColor : disabledTextColor,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              fillColor: inputBg,
              filled: true,
              hintText: "Enter ${label.replaceAll('*', '')}",
              hintStyle: TextStyle(color: hintColor, fontSize: 13),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color:
                        isDark ? AppColor.primary800 : const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color:
                        isDark ? AppColor.primary600 : const Color(0xFF9CA3AF)),
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _confirmDelete(BuildContext context, InventoryItemModel item) {
    Get.dialog(
      Obx(() {
        final bool isDark = controller.isDarkMode.value;
        final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
        final Color textColor =
            isDark ? AppColor.white : const Color(0xFF1F2937);
        final Color textSecondary =
            isDark ? AppColor.primary600 : const Color(0xFF4B5563);

        return AlertDialog(
          backgroundColor: dialogBg,
          title: Text(
            "Delete Item",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete '${item.itemName}' from inventory?",
            style: TextStyle(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel",
                style: TextStyle(color: textSecondary),
              ),
            ),
            Obx(() {
              if (controller.isActionLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.redAccent),
                  ),
                );
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700),
                onPressed: () async {
                  await controller.deleteInventoryItem(item.id);
                  Get.back();
                },
                child:
                    const Text("Delete", style: TextStyle(color: Colors.white)),
              );
            }),
          ],
        );
      }),
    );
  }

  void _showManageVendorsDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color cardBg =
              isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Manage Vendors",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _showAddVendorDialog(context),
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text("Add",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.vendorsList.isEmpty) {
                      return Center(
                        child: Text(
                          "No vendors found",
                          style: TextStyle(color: labelColor, fontSize: 14),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.vendorsList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final party = controller.vendorsList[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      party.name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (party.phone.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        "Phone: ${party.phone}",
                                        style: TextStyle(
                                            color: labelColor, fontSize: 12),
                                      ),
                                    ],
                                    if (party.address.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        "Address: ${party.address}",
                                        style: TextStyle(
                                            color: labelColor, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.blueAccent),
                                onPressed: () {
                                  controller.prefillVendorForm(party);
                                  _showEditPartyDialog(context, party);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    _confirmDeleteParty(context, party),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Close",
                      style: TextStyle(color: labelColor, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _confirmDeleteParty(BuildContext context, VendorModel party) {
    Get.dialog(
      Obx(() {
        final bool isDark = controller.isDarkMode.value;
        final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
        final Color textColor =
            isDark ? AppColor.white : const Color(0xFF1F2937);
        final Color textSecondary =
            isDark ? AppColor.primary600 : const Color(0xFF4B5563);

        return AlertDialog(
          backgroundColor: dialogBg,
          title: Text(
            "Delete Party",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete the party '${party.name}'? This cannot be undone.",
            style: TextStyle(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: textSecondary),
              ),
            ),
            Obx(() {
              if (controller.isActionLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.redAccent),
                  ),
                );
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700),
                onPressed: () async {
                  await controller.deleteVendor(party.id);
                  Navigator.of(context).pop();
                },
                child:
                    const Text("Delete", style: TextStyle(color: Colors.white)),
              );
            }),
          ],
        );
      }),
    );
  }

  void _showManageProductsDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color cardBg =
              isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Manage Products",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () => controller.syncProductsFromSaleOrders(),
                          icon: const Icon(Icons.sync, color: Colors.white, size: 18),
                          label: const Text("Sync",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () => _showAddProductDialog(context),
                          icon:
                              const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text("Add",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.productsList.isEmpty) {
                      return Center(
                        child: Text(
                          "No products found",
                          style: TextStyle(color: labelColor, fontSize: 14),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.productsList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = controller.productsList[index];
                        final img = product["imageUrl"] ?? "";
                        final name = product["description"] ?? "";
                        final sku = product["skuCode"] ?? "";
                        final sizeList = product["size"] != null
                            ? List<String>.from(product["size"])
                            : <String>[];

                        return Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: isDark
                                      ? AppColor.primary900
                                      : const Color(0xFFE5E7EB),
                                  child: Image.network(
                                    ApiUrl.getFullImageUrl(img),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Icon(Icons.image,
                                        size: 24, color: labelColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "SKU: $sku",
                                      style: TextStyle(
                                          color: labelColor, fontSize: 12),
                                    ),
                                    if (sizeList.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        "Sizes: ${sizeList.join(', ')}",
                                        style: TextStyle(
                                            color: labelColor, fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.blueAccent),
                                onPressed: () {
                                  controller.prefillProductForm(product);
                                  _showEditProductDialog(context, product);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    _confirmDeleteProduct(context, product),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Close",
                      style: TextStyle(color: labelColor, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, dynamic product) {
    final sku = product["skuCode"] ?? "";
    final id = product["id"] ?? product["_id"] ?? "";
    Get.dialog(
      Obx(() {
        final bool isDark = controller.isDarkMode.value;
        final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
        final Color textColor =
            isDark ? AppColor.white : const Color(0xFF1F2937);
        final Color textSecondary =
            isDark ? AppColor.primary600 : const Color(0xFF4B5563);

        return AlertDialog(
          backgroundColor: dialogBg,
          title: Text(
            "Delete Product",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete the product with SKU '$sku'? This cannot be undone.",
            style: TextStyle(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: textSecondary),
              ),
            ),
            Obx(() {
              if (controller.isActionLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.redAccent),
                  ),
                );
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700),
                onPressed: () async {
                  await controller.deleteProduct(id);
                  Navigator.of(context).pop();
                },
                child:
                    const Text("Delete", style: TextStyle(color: Colors.white)),
              );
            }),
          ],
        );
      }),
    );
  }

  void _showEditPartyDialog(BuildContext context, VendorModel party) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Edit Party",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildFormInput(
                      "Party Name*", controller.newVendorNameController),
                  const SizedBox(height: 12),
                  _buildFormInput(
                      "Phone Number", controller.newVendorPhoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildFormInput(
                      "Address", controller.newVendorAddressController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel",
                            style: TextStyle(color: labelColor, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.greenAccent),
                            ),
                          );
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final success =
                                await controller.editVendor(party.id);
                            if (success) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text("Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        );
                      }),
                    ],
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, dynamic product) {
    final id = product["id"] ?? product["_id"] ?? "";
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Edit Product",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildFormInput("SKU Code*", controller.newSkuController),
                  const SizedBox(height: 12),
                  _buildFormInput(
                      "Product Name*", controller.newDescController),
                  const SizedBox(height: 12),
                  _buildFormInput("Image URL", controller.newImgUrlController),
                  const SizedBox(height: 12),
                  _buildFormInput("Sizes (comma separated, e.g. S,M,L)",
                      controller.newSizesController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel",
                            style: TextStyle(color: labelColor, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.greenAccent),
                            ),
                          );
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final success = await controller.editProduct(id);
                            if (success) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text("Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        );
                      }),
                    ],
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    controller.fetchStockOutList(); // Fetch stock out data when opening dialog
    final RxString query = "".obs;
    final TextEditingController localSearchCtrl = TextEditingController();
    final RxString historyTab = 'stockIn'.obs; // 'stockIn' or 'stockOut'

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color cardBg =
              isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
          final Color borderCol =
              isDark ? AppColor.primary800 : const Color(0xFFE5E7EB);
          final Color searchBg =
              isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
          final Color hintColor = isDark
              ? AppColor.primary600.withValues(alpha: 0.5)
              : const Color(0xFF9CA3AF);

          // SAFE STRINGS & SAFE SKU FILTERING:
          final q = query.value.toLowerCase().trim();
          
          // Stock In List
          final stockInList = controller.inventoryList.where((item) {
            return item.itemName.toLowerCase().contains(q) ||
                item.party.toLowerCase().contains(q) ||
                item.skuCode.toString().toLowerCase().trim().contains(q) ||
                (item.date != null && item.date!.toLowerCase().contains(q));
          }).toList();

          stockInList.sort((a, b) {
            final dateA = a.date != null ? DateTime.tryParse(a.date!) : null;
            final dateB = b.date != null ? DateTime.tryParse(b.date!) : null;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });

          // Stock Out List
          final stockOutList = controller.stockOutList.where((item) {
            final sku = item['skuCode']?.toString().toLowerCase() ?? '';
            final pty = item['party']?.toString().toLowerCase() ?? '';
            final date = item['created_date_time']?.toString().toLowerCase() ?? '';
            return sku.contains(q) || pty.contains(q) || date.contains(q);
          }).toList();

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delivery History",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Tabs
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => historyTab.value = 'stockIn',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: historyTab.value == 'stockIn' ? Colors.blueAccent : searchBg,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                            border: Border.all(color: historyTab.value == 'stockIn' ? Colors.blueAccent : borderCol),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Stock In",
                            style: TextStyle(
                              color: historyTab.value == 'stockIn' ? Colors.white : textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => historyTab.value = 'stockOut',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: historyTab.value == 'stockOut' ? Colors.teal.shade700 : searchBg,
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                            border: Border.all(color: historyTab.value == 'stockOut' ? Colors.teal.shade700 : borderCol),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Stock Out",
                            style: TextStyle(
                              color: historyTab.value == 'stockOut' ? Colors.white : textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Local Search bar
                TextField(
                  controller: localSearchCtrl,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    fillColor: searchBg,
                    filled: true,
                    hintText: "Search history...",
                    hintStyle: TextStyle(color: hintColor, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: labelColor, size: 20),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderCol),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColor.primary600
                              : const Color(0xFF9CA3AF)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) => query.value = val,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: historyTab.value == 'stockIn' 
                    ? _buildStockInHistoryList(stockInList, isDark, cardBg, textColor)
                    : _buildStockOutHistoryList(stockOutList, isDark, cardBg, textColor),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showEditStockOutDialog(BuildContext context, dynamic item, Color dialogBg, Color textColor, Color borderCol, Color labelColor) {
    final TextEditingController qtyCtrl = TextEditingController(text: item['qtyOut']?.toString() ?? '1');
    final RxBool isLoading = false.obs;

    Get.dialog(
      Dialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Edit Stock Out", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text("SKU Code: ${item['skuCode']}", style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              Text("Party: ${item['party']}", style: TextStyle(color: textColor)),
              const SizedBox(height: 16),
              Text("Quantity Out", style: TextStyle(color: labelColor, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderCol)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: isLoading.value ? null : () async {
                      final int? qty = int.tryParse(qtyCtrl.text.trim());
                      if (qty == null || qty <= 0) {
                        AppSnacks.errorSnack(message: "Enter a valid quantity.");
                        return;
                      }
                      isLoading.value = true;
                      bool success = await controller.updateStockOutItem(
                        item['_id'] ?? item['id'] ?? '', 
                        item['skuCode'], 
                        item['party'], 
                        qty
                      );
                      isLoading.value = false;
                      if (success) {
                        Get.back(); // Close dialog
                      }
                    },
                    child: isLoading.value
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Save", style: TextStyle(color: Colors.white)),
                  )),
                ],
              )
            ],
          ),
        )
      )
    );
  }

  Widget _buildStockInHistoryList(List<dynamic> filteredList, bool isDark, Color cardBg, Color textColor) {
    if (filteredList.isEmpty) {
      return const Center(child: Text("No Stock In history logs found", style: TextStyle(fontSize: 14)));
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final String displayDate = item.date != null
            ? () {
                try {
                  final dt = DateTime.parse(item.date!);
                  return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
                } catch (_) {
                  return item.date!;
                }
              }()
            : "N/A";

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedBackgroundColor: cardBg,
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            title: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "#${filteredList.length - index} ($displayDate)",
                        style: TextStyle(
                          color: isDark ? Colors.greenAccent : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.party ?? 'Unknown Party',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${item.itemName ?? 'Unknown'} (${item.skuCode ?? 'Unknown'})",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "+${item.qty ?? item.currentlyAvailableStock ?? 0}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Qty In",
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 10),
                      )
                    ],
                  ),
                ),
              ],
            ),
            children: [
              const Divider(height: 1),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.qr_code, size: 16),
                      label: const Text("Barcode", style: TextStyle(fontSize: 12)),
                      onPressed: () async {
                        try {
                          final pdfData = await generateBarcodePdf(item: item);
                          final fileName = "Barcode_${item.skuCode}.pdf";
                          final filePath = await saveAndDownloadPdf(pdfData, fileName);
                          if (filePath != null) {
                            AppSnacks.successSnack(message: "Barcode downloaded successfully");
                            Get.to(() => AppPdfView(path: filePath));
                          }
                        } catch(e) {
                          AppSnacks.errorSnack(message: "Failed to download barcode: $e");
                        }
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text("View", style: TextStyle(fontSize: 12)),
                      onPressed: () => _showViewItemDetailsDialog(context, item),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit", style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Get.back(); // close history dialog
                        _showAddEditDialog(context, item);
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text("Delete", style: TextStyle(fontSize: 12, color: Colors.red)),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text("Are you sure you want to delete this stock in log?"),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () {
                                  Get.back(); // close confirmation
                                  if (item.id != null) {
                                    controller.deleteInventoryItem(item.id!);
                                  }
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          )
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
  Widget _buildStockOutHistoryList(List<dynamic> filteredList, bool isDark, Color cardBg, Color textColor) {
    if (filteredList.isEmpty) {
      return const Center(child: Text("No Stock Out history logs found", style: TextStyle(fontSize: 14)));
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final String displayDate = item['created_date_time'] != null
            ? () {
                try {
                  final dt = DateTime.parse(item['created_date_time']);
                  return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
                } catch (_) {
                  return item['created_date_time'];
                }
              }()
            : "N/A";

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedBackgroundColor: cardBg,
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            title: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "#${filteredList.length - index} ($displayDate)",
                        style: TextStyle(
                          color: isDark ? Colors.redAccent : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['party'] ?? 'Unknown Party',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "SKU: ${item['skuCode']} | Qty Out: ${item['qtyOut']}",
                        style: TextStyle(
                          color: isDark ? AppColor.primary600 : const Color(0xFF4B5563),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              const Divider(height: 1),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text("View", style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Get.dialog(
                          Dialog(
                            backgroundColor: cardBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Stock Out Details", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Text("Party: ${item['party']}", style: TextStyle(color: textColor)),
                                  const SizedBox(height: 8),
                                  Text("SKU Code: ${item['skuCode']}", style: TextStyle(color: textColor)),
                                  const SizedBox(height: 8),
                                  Text("Quantity Out: ${item['qtyOut']}", style: TextStyle(color: textColor)),
                                  const SizedBox(height: 8),
                                  Text("Date: $displayDate", style: TextStyle(color: textColor)),
                                  const SizedBox(height: 24),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () => Get.back(),
                                      child: const Text("Close"),
                                    ),
                                  )
                                ],
                              ),
                            )
                          )
                        );
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit", style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Get.back(); // close history dialog first
                        // Pass colors for dialog
                        final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
                        final Color borderCol = isDark ? AppColor.primary800 : const Color(0xFFE5E7EB);
                        final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);
                        _showEditStockOutDialog(context, item, dialogBg, textColor, borderCol, labelColor);
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text("Delete", style: TextStyle(fontSize: 12, color: Colors.red)),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text("Are you sure you want to delete this stock out log?"),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () {
                                  Get.back(); // close confirmation
                                  final id = item['_id'] ?? item['id'];
                                  if (id != null) {
                                    controller.deleteStockOutItem(id.toString());
                                  }
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          )
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showViewItemDetailsDialog(
      BuildContext context, InventoryItemModel item) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color cardBg =
              isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
          final Color borderCol =
              isDark ? AppColor.primary800 : const Color(0xFFE5E7EB);
          final Color textSecondary =
              isDark ? AppColor.primary600 : const Color(0xFF6B7280);

          final double totalCost = item.qty * item.purchasePrice;

          final String displayDate = item.date != null
              ? () {
                  try {
                    final dt = DateTime.parse(item.date!);
                    return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
                  } catch (_) {
                    return item.date!;
                  }
                }()
              : "N/A";

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delivery Details",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColor.primary800 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isDark ? AppColor.primary600 : Colors.green.shade100,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        color:
                            isDark ? Colors.greenAccent : Colors.green.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Vendor/Party Name",
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              item.party,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Delivery Date:",
                            style: TextStyle(
                                color: labelColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            displayDate,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 0.5),
                      Text(
                        "Product Description:",
                        style: TextStyle(
                            color: labelColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.itemName,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("SKU Code",
                                  style: TextStyle(
                                      color: labelColor, fontSize: 11)),
                              Text(
                                  item.skuCode.isNotEmpty
                                      ? item.skuCode
                                      : "N/A",
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Size",
                                  style: TextStyle(
                                      color: labelColor, fontSize: 11)),
                              Text(item.size,
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow("Quantity Delivered", "${item.qty} units",
                          textColor, labelColor),
                      const Divider(height: 1, thickness: 0.5),
                      _buildDetailRow(
                          "Purchase Price",
                          "₹${item.purchasePrice.toStringAsFixed(2)}",
                          textColor,
                          labelColor),
                      const Divider(height: 1, thickness: 0.5),
                      _buildDetailRow(
                          "Total Cost",
                          "₹${totalCost.toStringAsFixed(2)}",
                          isDark ? Colors.greenAccent : Colors.green.shade800,
                          labelColor,
                          isBoldVal: true),
                      const Divider(height: 1, thickness: 0.5),
                      _buildDetailRow(
                          "Remaining Stock",
                          "${item.currentlyAvailableStock} units",
                          item.currentlyAvailableStock > 0
                              ? Colors.cyanAccent
                              : Colors.redAccent,
                          labelColor,
                          isBoldVal: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, Color valColor, Color labelColor,
      {bool isBoldVal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                color: labelColor, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: valColor,
              fontSize: 14,
              fontWeight: isBoldVal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showManageNewPartiesDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color cardBg =
              isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Manage Parties",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _showAddNewPartyDialog(context),
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text("Add",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.newPartiesList.isEmpty) {
                      return Center(
                        child: Text(
                          "No parties found",
                          style: TextStyle(color: labelColor, fontSize: 14),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.newPartiesList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final party = controller.newPartiesList[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      party.name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (party.phone.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        "Phone: ${party.phone}",
                                        style: TextStyle(
                                            color: labelColor, fontSize: 12),
                                      ),
                                    ],
                                    if (party.address.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        "Address: ${party.address}",
                                        style: TextStyle(
                                            color: labelColor, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  controller.deleteNewParty(party.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Close",
                      style: TextStyle(color: labelColor, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showAddNewPartyDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor =
              isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor =
              isDark ? AppColor.primary600 : const Color(0xFF4B5563);

          return Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Add New Party",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildFormInput("Party Name*", nameController),
                  const SizedBox(height: 12),
                  _buildFormInput("Phone Number", phoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildFormInput("Address", addressController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel",
                            style: TextStyle(color: labelColor, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.greenAccent),
                            ),
                          );
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final success = await controller.addNewParty(
                              nameController.text,
                              phoneController.text,
                              addressController.text,
                            );
                            if (success) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text("Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        );
                      }),
                    ],
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showReportDateSelection(BuildContext context) {
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = controller.isDarkMode.value;
            final textColor = isDark ? Colors.white : Colors.black87;

            return AlertDialog(
              backgroundColor: isDark ? AppColor.primary800 : Colors.white,
              title: Text("Select Report Date Range", style: TextStyle(color: textColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: Icon(Icons.calendar_today, color: textColor),
                          label: Text("${startDate.day}-${startDate.month}-${startDate.year}", style: TextStyle(color: textColor)),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startDate = picked;
                                if (endDate.isBefore(startDate)) {
                                  endDate = startDate;
                                }
                              });
                            }
                          },
                        ),
                      ),
                      Text(" to ", style: TextStyle(color: textColor)),
                      Expanded(
                        child: TextButton.icon(
                          icon: Icon(Icons.calendar_today, color: textColor),
                          label: Text("${endDate.day}-${endDate.month}-${endDate.year}", style: TextStyle(color: textColor)),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: startDate,
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    // Show loading
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false
                    );
                    
                    try {
                      var response = await controller.apiRepository.getInventoryReport(
                        startDate.toIso8601String(), 
                        endDate.toIso8601String()
                      );
                      
                      // Generate CSV
                      final filePath = await generateInventoryReportCsv(
                        reportData: response,
                        startDate: startDate,
                        endDate: endDate,
                      );
                      
                      Get.back(); // close loading
                      
                      if (kIsWeb) {
                        AppSnacks.successSnack(message: "CSV Report downloaded successfully");
                      } else {
                        AppSnacks.successSnack(message: "CSV Report saved to $filePath");
                      }
                    } catch (e, stacktrace) {
                      Get.back(); // close loading
                      print("Exception in generateInventoryReportCsv: $e\n$stacktrace");
                      AppSnacks.errorSnack(message: "Failed to generate CSV: $e");
                    }
                  },
                  child: const Text("Download CSV", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary600),
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    // Show loading
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false
                    );
                    
                    try {
                      final startStr = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
                      final endStr = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
                      final reportUrl = "${ApiUrl.baseUrl}/inventory/report/pdf?dateStart=$startStr&dateEnd=$endStr";
                      
                      final response = await http.get(Uri.parse(reportUrl));
                      if (response.statusCode != 200) {
                        throw Exception("Backend returned status code ${response.statusCode}");
                      }
                      final Uint8List pdfData = response.bodyBytes;
                      
                      Get.back(); // close loading
                      
                      final fileName = "Inventory_Report_${startDate.day}-${startDate.month}-${startDate.year}.pdf";
                      if (kIsWeb) {
                        await saveAndDownloadPdf(pdfData, fileName);
                        AppSnacks.successSnack(message: "Report downloaded successfully");
                      } else {
                        final filePath = await saveAndDownloadPdf(pdfData, fileName);
                        if (filePath != null) {
                          Get.to(() => AppPdfView(path: filePath));
                        }
                      }
                    } catch (e, stacktrace) {
                      Get.back(); // close loading
                      print("Exception in downloading backend PDF: $e\n$stacktrace");
                      AppSnacks.errorSnack(message: "Failed to download PDF: $e");
                    }
                  },
                  child: const Text("Download PDF", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

