import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/modules/inventory/controller/inventory_controller.dart';
import 'package:elite_edition/modules/inventory/model/inventory_item_model.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/shared_widget/textfield_widget.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColor.primary800,
      appBar: AppBar(
        backgroundColor: AppColor.primary800,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Inventory Management",
          style: TextStyle(
            color: AppColor.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: AppColor.white, size: 28),
            onPressed: () {
              controller.clearForm();
              _showAddEditDialog(context, null);
            },
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
              bgColor: AppColor.primary900,
              borderColor: AppColor.transparent,
              imgColor: AppColor.primary600,
              hintTextColour: AppColor.primary600,
              imgHeight: 25,
              imgWidth: 25,
              onChanged: (val) => controller.onSearchChanged(val),
            ),
          ),
          
          // Inventory List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              
              if (controller.inventoryList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, color: AppColor.primary600, size: 60),
                      const SizedBox(height: 12),
                      Text(
                        "No inventory items found",
                        style: TextStyle(color: AppColor.primary600, fontSize: 16),
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
  }

  Widget _buildInventoryCard(BuildContext context, InventoryItemModel item) {
    // Determine color for available stock indicator
    Color stockColor;
    if (item.currentlyAvailableStock == 0) {
      stockColor = Colors.redAccent;
    } else if (item.currentlyAvailableStock <= 5) {
      stockColor = Colors.orangeAccent;
    } else {
      stockColor = Colors.greenAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColor.primary900,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top section: Item Name and Size
            Padding(
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
                            color: AppColor.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.primary800,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColor.primary600, width: 0.5),
                        ),
                        child: Text(
                          "Size: ${item.size}",
                          style: const TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.business_outlined, color: AppColor.primary600, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        item.party,
                        style: TextStyle(
                          color: AppColor.primary600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.white10, height: 1),
            
            // Details Grid: Stocks and Prices
            Padding(
              padding: const EdgeInsets.all(16),
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
                    valueColor: Colors.cyanAccent,
                  ),
                  
                  // Purchase Price
                  _buildStatColumn(
                    "Purchase Price",
                    "₹${item.purchasePrice.toStringAsFixed(2)}",
                    valueColor: Colors.orangeAccent,
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.white10, height: 1),
            
            // Actions Row
            Container(
              color: Colors.black12,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      controller.populateForm(item);
                      _showAddEditDialog(context, item);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                    label: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context, item),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.redAccent),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.primary600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
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
        backgroundColor: AppColor.primary900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEdit ? "Edit Stock Item" : "Add Stock Item",
                  style: TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                _buildFormInput("Party Name", controller.partyController, keyboardType: TextInputType.text),
                const SizedBox(height: 12),
                _buildFormInput("Item Name", controller.itemNameController, keyboardType: TextInputType.text),
                const SizedBox(height: 12),
                _buildFormInput("Size", controller.sizeController, keyboardType: TextInputType.text),
                const SizedBox(height: 12),
                _buildFormInput("Initial Total Qty", controller.qtyController, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildFormInput("Available Stock", controller.stockController, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildFormInput("Purchase Price (₹)", controller.purchasePriceController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                _buildFormInput("Sale Price (₹)", controller.salePriceController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: AppColor.primary600, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (isEdit) {
                          controller.updateInventoryItem(item!.id);
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormInput(String label, TextEditingController txtController, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.primary600,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: txtController,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColor.white, fontSize: 15),
          decoration: InputDecoration(
            fillColor: AppColor.primary800,
            filled: true,
            hintText: "Enter $label",
            hintStyle: TextStyle(color: AppColor.primary600.withOpacity(0.5), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.primary800),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.primary600),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, InventoryItemModel item) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.primary900,
        title: Text(
          "Delete Item",
          style: TextStyle(color: AppColor.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete '${item.itemName}' from inventory?",
          style: TextStyle(color: AppColor.primary600),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColor.primary600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Get.back();
              controller.deleteInventoryItem(item.id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
