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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
            onPressed: () => Get.back(),
          ),
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
                hintText: "Search by item name or party",
                bgColor: searchBg,
                borderColor: isDark ? AppColor.transparent : const Color(0xFFD1D5DB),
                imgColor: textSecondary,
                hintTextColour: textSecondary,
                imgHeight: 25,
                imgWidth: 25,
                onChanged: (val) => controller.onSearchChanged(val),
              ),
            ),
            
            // Inventory List
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
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.inventoryList.length,
                  itemBuilder: (context, index) {
                    final item = controller.inventoryList[index];
                    return _buildInventoryCard(context, item);
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
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
                  _buildFormInput("Initial Total Qty", controller.qtyController, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildFormInput("Available Stock", controller.stockController, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildFormInput("Purchase Price (₹)", controller.purchasePriceController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 12),
                  _buildFormInput("Sale Price (₹)", controller.salePriceController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  
                  const SizedBox(height: 24),
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
                        if (controller.isActionLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.greenAccent),
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
                          onPressed: () {
                            if (isEdit) {
                              controller.updateInventoryItem(item.id);
                            } else {
                              controller.addInventoryItem();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              isEdit ? "Save" : "Add",
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
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
                        onPressed: () => Get.back(),
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
                              Get.back();
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
                        onPressed: () => Get.back(),
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
                              Get.back();
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

  Widget _buildFormInput(String label, TextEditingController txtController, {TextInputType keyboardType = TextInputType.text}) {
    final bool isDark = controller.isDarkMode.value;
    final Color textColor = isDark ? AppColor.white : const Color(0xFF1F2937);
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
          style: TextStyle(color: textColor, fontSize: 14),
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
                Text(
                  "Manage Parties",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
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
                    onPressed: () => Get.back(),
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
                  await controller.deleteParty(party.id);
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
                Text(
                  "Manage Products",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
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
                    onPressed: () => Get.back(),
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
                  await controller.deleteProduct(id);
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
}
