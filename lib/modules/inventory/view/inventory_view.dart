import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/modules/inventory/controller/inventory_controller.dart';
import 'package:elite_edition/modules/inventory/model/inventory_item_model.dart';
import 'package:elite_edition/modules/inventory/model/party_model.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/constants/api_url.dart';
import 'package:elite_edition/shared_widget/textfield_widget.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isDark = controller.isDarkMode.value;
      final Color scaffoldBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
      final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
      final Color textSecondary = isDark ? AppColor.primary600 : const Color(0xFF4B5563);
      final Color searchBg = isDark ? AppColor.primary900 : Colors.white;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
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
                    ? Icon(Icons.light_mode_rounded, color: Colors.amberAccent, key: const ValueKey('light'))
                    : Icon(Icons.dark_mode_rounded, color: Colors.indigo.shade800, key: const ValueKey('dark')),
              ),
              tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
              onPressed: () => controller.toggleTheme(),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline_rounded, color: textColor, size: 28),
              tooltip: "Add Stock Item",
              onPressed: () {
                controller.clearForm();
                _showAddEditDialog(context, null);
              },
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: textColor),
              color: isDark ? AppColor.primary900 : Colors.white,
              onSelected: (value) {
                if (value == 'parties') {
                  _showManagePartiesDialog(context);
                } else if (value == 'products') {
                  _showManageProductsDialog(context);
                } else if (value == 'history') {
                  _showHistoryDialog(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'parties',
                  child: Row(
                    children: [
                      Icon(Icons.business_outlined, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Manage Parties', style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'products',
                  child: Row(
                    children: [
                      Icon(Icons.category_outlined, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Manage Products', style: TextStyle(color: textColor)),
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
              child: TextFieldWidget(
                imagePath: "assets/icons/Search.png",
                controller: controller.searchController,
                hintText: "Search by item name, SKU or party",
                bgColor: searchBg,
                borderColor: isDark ? AppColor.transparent : const Color(0xFFD1D5DB),
                imgColor: textSecondary,
                hintTextColour: textSecondary,
                imgHeight: 25,
                imgWidth: 25,
                onChanged: (val) => controller.onSearchChanged(val),
              ),
            ),

            // Inventory List — grouped by SKU
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: isDark ? Colors.white : Colors.teal),
                  );
                }

                if (controller.inventoryList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, color: textSecondary, size: 60),
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
    final Color textSecondary = isDark ? AppColor.primary600 : const Color(0xFF6B7280);
    final Color dividerColor = isDark ? Colors.white10 : const Color(0xFFE5E7EB);
    final Color headerBg = isDark ? AppColor.primary800.withValues(alpha: 0.6) : const Color(0xFFF0FDF4);

    final int totalStock = group['totalStock'] as int;
    final int totalQty = group['totalQty'] as int;
    final String skuCode = group['skuCode'] as String;
    final String itemName = group['itemName'] as String;
    final String imageUrl = group['imageUrl'] as String;
    final List<InventoryItemModel> entries = group['entries'] as List<InventoryItemModel>;

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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColor.primary800 : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isDark ? AppColor.primary600 : const Color(0xFFBFDBFE),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    skuCode,
                    style: TextStyle(
                      color: isDark ? Colors.yellowAccent : const Color(0xFF1E40AF),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: stockColor.withValues(alpha: 0.4)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white10 : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 13, color: textSecondary),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white10 : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business_outlined, size: 13, color: textSecondary),
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
            ...entries.map((item) => _buildPartyEntryRow(context, item, dividerColor)),
          ],
        ),
      ),
    );
  }

  /// One row per party entry inside the expanded SKU card
  Widget _buildPartyEntryRow(BuildContext context, InventoryItemModel item, Color dividerColor) {
    final bool isDark = controller.isDarkMode.value;
    final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
    final Color textSecondary = isDark ? AppColor.primary600 : const Color(0xFF6B7280);
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
                          Icon(Icons.business_outlined, size: 12, color: textSecondary),
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
                            style: TextStyle(color: textSecondary, fontSize: 11),
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
                          color: isDark ? Colors.cyanAccent : const Color(0xFF0D9488),
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
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                      tooltip: "Edit",
                      onPressed: () {
                        controller.populateForm(item);
                        _showAddEditDialog(context, item);
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
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



  Widget _buildInventoryCard(BuildContext context, InventoryItemModel item) {
    final bool isDark = controller.isDarkMode.value;
    final Color cardBg = isDark ? AppColor.primary900 : Colors.white;
    final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
    final Color textSecondary = isDark ? AppColor.primary600 : const Color(0xFF6B7280);
    final Color dividerColor = isDark ? Colors.white10 : const Color(0xFFE5E7EB);
    final Color footerBg = isDark ? Colors.black12 : const Color(0xFFF9FAFB);


    // Determine color for available stock indicator
    Color stockColor;
    if (item.currentlyAvailableStock == 0) {
      stockColor = Colors.redAccent;
    } else if (item.currentlyAvailableStock <= 5) {
      stockColor = Colors.orangeAccent;
    } else {
      stockColor = isDark ? Colors.greenAccent : const Color(0xFF10B981);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading Image
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: isDark ? AppColor.primary800 : const Color(0xFFF3F4F6),
                      child: Image.network(
                        ApiUrl.getFullImageUrl(item.imageUrl),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported_outlined,
                          color: textSecondary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Details Column
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.itemName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? AppColor.primary800 : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isDark ? AppColor.primary600 : const Color(0xFFBFDBFE), width: 0.5),
                              ),
                              child: Text(
                                "Size: ${item.size}",
                                style: TextStyle(
                                  color: isDark ? Colors.yellowAccent : const Color(0xFF1E40AF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.business_outlined, color: textSecondary, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.party,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            Divider(color: dividerColor, height: 1),
            
            // Details Grid: Stocks and Prices
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stock column
                  _buildStatColumn(
                    "Stock Status",
                    "${item.currentlyAvailableStock} / ${item.qty}",
                    valueColor: stockColor,
                  ),
                  
                  // Sale Price
                  _buildStatColumn(
                    "Sale Price",
                    "₹${item.salePrice.toStringAsFixed(2)}",
                    valueColor: isDark ? Colors.cyanAccent : const Color(0xFF0D9488),
                  ),
                  
                  // Purchase Price
                  _buildStatColumn(
                    "Purchase Price",
                    "₹${item.purchasePrice.toStringAsFixed(2)}",
                    valueColor: isDark ? Colors.orangeAccent : const Color(0xFFD97706),
                  ),
                ],
              ),
            ),
            
            Divider(color: dividerColor, height: 1),
            
            // Actions Row
            Container(
              color: footerBg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      controller.populateForm(item);
                      _showAddEditDialog(context, item);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.blueAccent),
                    label: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.blueAccent, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context, item),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {required Color valueColor}) {
    final bool isDark = controller.isDarkMode.value;
    final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF6B7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAddEditDialog(BuildContext context, InventoryItemModel? item) {
    final bool isEdit = item != null;
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color inputBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
          final Color borderCol = isDark ? AppColor.primary800 : const Color(0xFFE5E7EB);
          final Color hintColor = isDark ? AppColor.primary600.withValues(alpha: 0.5) : const Color(0xFF9CA3AF);
          final Color textSecondary = isDark ? AppColor.primary600 : const Color(0xFF6B7280);

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
                  
                  // Party Select Dropdown + Add Party Button
                  Text(
                    "Party*",
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
                          final currentParty = controller.selectedParty.value;
                          final isInList = controller.partiesList.any((p) => p.name == currentParty);
                          return DropdownButtonFormField<String>(
                            dropdownColor: dialogBg,
                            value: isInList ? currentParty : null,
                            hint: Text("Select Party", style: TextStyle(color: hintColor, fontSize: 14)),
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
                            items: controller.partiesList.map((p) => DropdownMenuItem<String>(
                              value: p.name,
                              child: Text(p.name),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedParty.value = val;
                              }
                            },
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_business_rounded, color: Colors.greenAccent, size: 24),
                        tooltip: "Add New Party",
                        onPressed: () => _showAddPartyDialog(context),
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
                          final isInList = controller.productsList.any((p) => p["skuCode"] == currentSku);
                          return DropdownButtonFormField<dynamic>(
                            dropdownColor: dialogBg,
                            isExpanded: true,
                            value: isInList ? controller.productsList.firstWhere((p) => p["skuCode"] == currentSku) : null,
                            hint: Text("Select Product", style: TextStyle(color: hintColor, fontSize: 14)),
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
                            items: controller.productsList.map((p) {
                              final img = p["imageUrl"] ?? "";
                              final name = p["description"] ?? "";
                              final sku = p["skuCode"] ?? "";
                              return DropdownMenuItem<dynamic>(
                                value: p,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        color: isDark ? AppColor.primary800 : const Color(0xFFE5E7EB),
                                        child: Image.network(
                                          ApiUrl.getFullImageUrl(img),
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Icon(Icons.image, size: 14, color: textSecondary),
                                        ),
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
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.onProductSelected(val);
                              }
                            },
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_box_rounded, color: Colors.greenAccent, size: 24),
                        tooltip: "Add New Product",
                        onPressed: () => _showAddProductDialog(context),
                      ),
                    ],
                  ),
                  
                  // Image Preview
                  Obx(() {
                    if (controller.selectedImageUrl.value.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            ApiUrl.getFullImageUrl(controller.selectedImageUrl.value),
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
                        onChanged: (val) => controller.selectedSize.value = val,
                      );
                    }
                    
                    final currentSize = controller.selectedSize.value;
                    final isInList = controller.sizeOptionsList.contains(currentSize);
                    return DropdownButtonFormField<String>(
                      dropdownColor: dialogBg,
                      value: isInList ? currentSize : null,
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
                      items: controller.sizeOptionsList.map((sz) => DropdownMenuItem<String>(
                        value: sz,
                        child: Text(sz),
                      )).toList(),
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
                                    dialogBackgroundColor: AppColor.primary900,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                            style: TextStyle(color: textColor, fontSize: 14),
                          )),
                          Icon(Icons.calendar_today_rounded, color: labelColor, size: 18),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  _buildFormInput("Initial Total Qty", controller.qtyController, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildFormInput("Available Stock", controller.stockController, keyboardType: TextInputType.number, enabled: false),
                  const SizedBox(height: 12),
                  _buildFormInput("Purchase Price (₹)", controller.purchasePriceController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 12),
                  _buildFormInput("Sale Price (₹)", controller.salePriceController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  
                  const SizedBox(height: 24),
                  
                  // Staged items list
                  if (!isEdit) ...[
                    Obx(() {
                      if (controller.stagedItems.isEmpty) return const SizedBox.shrink();
                      
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
                                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 180),
                            decoration: BoxDecoration(
                              color: isDark ? AppColor.primary800 : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColor.primary600 : const Color(0xFFE5E7EB),
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
                                final purchasePrice = staged["purchasePrice"] ?? 0.0;
                                final salePrice = staged["salePrice"] ?? 0.0;

                                return Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        color: isDark ? AppColor.primary900 : const Color(0xFFE5E7EB),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                              color: textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            "Buy: ₹$purchasePrice | Sell: ₹$salePrice",
                                            style: TextStyle(
                                              color: isDark ? Colors.cyanAccent : const Color(0xFF0D9488),
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: labelColor, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        final isActionLoading = controller.isActionLoading.value;
                        final hasStaged = controller.stagedItems.isNotEmpty;
                        
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isEdit && !isActionLoading) ...[
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? Colors.greenAccent : Colors.green.shade800,
                                  side: BorderSide(color: isDark ? Colors.greenAccent : Colors.green.shade800),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  controller.stageCurrentItem();
                                },
                                icon: const Icon(Icons.playlist_add_rounded, size: 18),
                                label: const Text("Stage Item"),
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (isActionLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.greenAccent),
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
                                  final navigator = Navigator.of(context);
                                  if (isEdit) {
                                    final success = await controller.updateInventoryItem(item.id);
                                    if (success) {
                                      navigator.pop();
                                    }
                                  } else {
                                    if (hasStaged) {
                                      // If user typed details but hasn't clicked stage yet, auto-stage them
                                      final currentParty = controller.selectedParty.value.trim();
                                      final currentItem = controller.itemNameController.text.trim();
                                      final currentSize = controller.selectedSize.value.trim();
                                      if (currentParty.isNotEmpty && currentItem.isNotEmpty && currentSize.isNotEmpty) {
                                        controller.stageCurrentItem();
                                      }
                                      final success = await controller.addStagedInventoryItems();
                                      if (success) {
                                        navigator.pop();
                                      }
                                    } else {
                                      final success = await controller.addInventoryItem();
                                      if (success) {
                                        navigator.pop();
                                      }
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text(
                                    isEdit
                                        ? "Save"
                                        : (hasStaged
                                            ? "Save All (${controller.stagedItems.length})"
                                            : "Add"),
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

  void _showAddPartyDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);

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
                  _buildFormInput("Party Name*", controller.newPartyNameController),
                  const SizedBox(height: 12),
                  _buildFormInput("Phone Number", controller.newPartyPhoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildFormInput("Address", controller.newPartyAddressController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel", style: TextStyle(color: labelColor, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
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
                            final success = await controller.addParty();
                            if (success) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);

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
                  _buildFormInput("Product Name*", controller.newDescController),
                  const SizedBox(height: 12),
                  _buildFormInput("Image URL", controller.newImgUrlController),
                  const SizedBox(height: 12),
                  _buildFormInput("Sizes (comma separated, e.g. S,M,L)", controller.newSizesController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel", style: TextStyle(color: labelColor, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
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
                          child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final bool isDark = controller.isDarkMode.value;
    final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
    final Color disabledTextColor = isDark ? Colors.white38 : Colors.black38;
    final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);
    final Color inputBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
    final Color hintColor = isDark ? AppColor.primary600.withValues(alpha: 0.5) : const Color(0xFF9CA3AF);

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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: isDark ? AppColor.primary800 : const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: isDark ? AppColor.primary600 : const Color(0xFF9CA3AF)),
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, InventoryItemModel item) {
    Get.dialog(
      Obx(() {
        final bool isDark = controller.isDarkMode.value;
        final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
        final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
        final Color textSecondary = isDark ? AppColor.primary600 : const Color(0xFF4B5563);

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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                  ),
                );
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                onPressed: () async {
                  await controller.deleteInventoryItem(item.id);
                  Get.back();
                },
                child: const Text("Delete", style: TextStyle(color: Colors.white)),
              );
            }),
          ],
        );
      }),
    );
  }

  void _showManagePartiesDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color cardBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);

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
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _showAddPartyDialog(context),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.partiesList.isEmpty) {
                      return Center(
                        child: Text(
                          "No parties found",
                          style: TextStyle(color: labelColor, fontSize: 14),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.partiesList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final party = controller.partiesList[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                        style: TextStyle(color: labelColor, fontSize: 12),
                                      ),
                                    ],
                                    if (party.address.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        "Address: ${party.address}",
                                        style: TextStyle(color: labelColor, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                onPressed: () {
                                  controller.prefillPartyForm(party);
                                  _showEditPartyDialog(context, party);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                onPressed: () => _confirmDeleteParty(context, party),
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

  void _confirmDeleteParty(BuildContext context, PartyModel party) {
    Get.dialog(
      Obx(() {
        final bool isDark = controller.isDarkMode.value;
        final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
        final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
        final Color textSecondary = isDark ? AppColor.primary600 : const Color(0xFF4B5563);

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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                  ),
                );
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                onPressed: () async {
                  await controller.deleteParty(party.id);
                  Navigator.of(context).pop();
                },
                child: const Text("Delete", style: TextStyle(color: Colors.white)),
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
          final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color cardBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);

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
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _showAddProductDialog(context),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = controller.productsList[index];
                        final img = product["imageUrl"] ?? "";
                        final name = product["description"] ?? "";
                        final sku = product["skuCode"] ?? "";
                        final sizeList = product["size"] != null ? List<String>.from(product["size"]) : <String>[];

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
                                  color: isDark ? AppColor.primary900 : const Color(0xFFE5E7EB),
                                  child: Image.network(
                                    ApiUrl.getFullImageUrl(img),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Icon(Icons.image, size: 24, color: labelColor),
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
                                      style: TextStyle(color: labelColor, fontSize: 12),
                                    ),
                                    if (sizeList.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        "Sizes: ${sizeList.join(', ')}",
                                        style: TextStyle(color: labelColor, fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                onPressed: () {
                                  controller.prefillProductForm(product);
                                  _showEditProductDialog(context, product);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                onPressed: () => _confirmDeleteProduct(context, product),
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
        final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
        final Color textSecondary = isDark ? AppColor.primary600 : const Color(0xFF4B5563);

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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                  ),
                );
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                onPressed: () async {
                  await controller.deleteProduct(id);
                  Navigator.of(context).pop();
                },
                child: const Text("Delete", style: TextStyle(color: Colors.white)),
              );
            }),
          ],
        );
      }),
    );
  }

  void _showEditPartyDialog(BuildContext context, PartyModel party) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);

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
                  _buildFormInput("Party Name*", controller.newPartyNameController),
                  const SizedBox(height: 12),
                  _buildFormInput("Phone Number", controller.newPartyPhoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildFormInput("Address", controller.newPartyAddressController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel", style: TextStyle(color: labelColor, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
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
                            final success = await controller.editParty(party.id);
                            if (success) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);

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
                  _buildFormInput("Product Name*", controller.newDescController),
                  const SizedBox(height: 12),
                  _buildFormInput("Image URL", controller.newImgUrlController),
                  const SizedBox(height: 12),
                  _buildFormInput("Sizes (comma separated, e.g. S,M,L)", controller.newSizesController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel", style: TextStyle(color: labelColor, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
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
                          child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final RxString query = "".obs;
    final TextEditingController localSearchCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color cardBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
          final Color borderCol = isDark ? AppColor.primary800 : const Color(0xFFE5E7EB);
          final Color searchBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
          final Color hintColor = isDark ? AppColor.primary600.withValues(alpha: 0.5) : const Color(0xFF9CA3AF);

          // Get filtered and sorted list (most recent first)
          final filteredList = controller.inventoryList.where((item) {
            final q = query.value.toLowerCase();
            return item.itemName.toLowerCase().contains(q) ||
                item.party.toLowerCase().contains(q) ||
                (item.skuCode.toLowerCase().contains(q)) ||
                (item.date != null && item.date!.contains(q));
          }).toList();
          
          // Sort by date (descending)
          filteredList.sort((a, b) {
            final dateA = a.date != null ? DateTime.tryParse(a.date!) : null;
            final dateB = b.date != null ? DateTime.tryParse(b.date!) : null;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });

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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderCol),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isDark ? AppColor.primary600 : const Color(0xFF9CA3AF)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) => query.value = val,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Text(
                            "No history logs found",
                            style: TextStyle(color: labelColor, fontSize: 14),
                          ),
                        )
                      : ListView.separated(
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

                            return Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  // Index and Date Column
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
                                          item.party,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${item.itemName} (${item.skuCode})",
                                          style: TextStyle(
                                            color: labelColor,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Action Buttons
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // View Button (Green)
                                      IconButton(
                                        icon: const Icon(Icons.visibility_rounded, color: Colors.tealAccent, size: 20),
                                        tooltip: "View Details",
                                        onPressed: () => _showViewItemDetailsDialog(context, item),
                                      ),
                                      // Edit Button (Blue)
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, color: Colors.lightBlueAccent, size: 20),
                                        tooltip: "Edit Item",
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close History Dialog
                                          controller.populateForm(item);
                                          _showAddEditDialog(context, item);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showViewItemDetailsDialog(BuildContext context, InventoryItemModel item) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Obx(() {
          final bool isDark = controller.isDarkMode.value;
          final Color dialogBg = isDark ? AppColor.primary900 : Colors.white;
          final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
          final Color labelColor = isDark ? AppColor.primary600 : const Color(0xFF4B5563);
          final Color cardBg = isDark ? AppColor.primary800 : const Color(0xFFF3F4F6);
          final Color borderCol = isDark ? AppColor.primary800 : const Color(0xFFE5E7EB);
          final Color textSecondary = isDark ? AppColor.primary600 : const Color(0xFF6B7280);

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
                
                // Vendor Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColor.primary800 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColor.primary600 : Colors.green.shade100,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        color: isDark ? Colors.greenAccent : Colors.green.shade700,
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

                // Date and Product Card
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
                            style: TextStyle(color: labelColor, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            displayDate,
                            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 0.5),
                      Text(
                        "Product Description:",
                        style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.itemName,
                        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("SKU Code", style: TextStyle(color: labelColor, fontSize: 11)),
                              Text(item.skuCode.isNotEmpty ? item.skuCode : "N/A", style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Size", style: TextStyle(color: labelColor, fontSize: 11)),
                              Text(item.size, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Financials & Stock Breakdown Table
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow("Quantity Delivered", "${item.qty} units", textColor, labelColor),
                      const Divider(height: 1, thickness: 0.5),
                      _buildDetailRow("Purchase Price", "₹${item.purchasePrice.toStringAsFixed(2)}", textColor, labelColor),
                      const Divider(height: 1, thickness: 0.5),
                      _buildDetailRow("Total Cost", "₹${totalCost.toStringAsFixed(2)}", isDark ? Colors.greenAccent : Colors.green.shade800, labelColor, isBoldVal: true),
                      const Divider(height: 1, thickness: 0.5),
                      _buildDetailRow("Remaining Stock", "${item.currentlyAvailableStock} units", item.currentlyAvailableStock > 0 ? Colors.cyanAccent : Colors.redAccent, labelColor, isBoldVal: true),
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valColor, Color labelColor, {bool isBoldVal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: labelColor, fontSize: 13, fontWeight: FontWeight.w500),
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
}
