import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/data/api_repository.dart';
import 'package:elite_edition/modules/inventory/model/inventory_item_model.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';
import 'package:elite_edition/constants/app_color.dart';

class InventoryController extends GetxController {
  final ApiRepository apiRepository;

  InventoryController({required this.apiRepository});

  RxBool isLoading = false.obs;
  RxList<InventoryItemModel> inventoryList = RxList();
  RxString searchQuery = "".obs;

  // Form controllers
  final TextEditingController partyController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchInventory();
  }

  @override
  void onClose() {
    partyController.dispose();
    itemNameController.dispose();
    sizeController.dispose();
    stockController.dispose();
    salePriceController.dispose();
    purchasePriceController.dispose();
    qtyController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void clearForm() {
    partyController.clear();
    itemNameController.clear();
    sizeController.clear();
    stockController.clear();
    salePriceController.clear();
    purchasePriceController.clear();
    qtyController.clear();
  }

  void populateForm(InventoryItemModel item) {
    partyController.text = item.party;
    itemNameController.text = item.itemName;
    sizeController.text = item.size;
    stockController.text = item.currentlyAvailableStock.toString();
    salePriceController.text = item.salePrice.toString();
    purchasePriceController.text = item.purchasePrice.toString();
    qtyController.text = item.qty.toString();
  }

  Future<void> fetchInventory() async {
    try {
      isLoading.value = true;
      Map<String, String> params = {};
      if (searchQuery.value.isNotEmpty) {
        params["search"] = searchQuery.value;
      }
      
      var res = await apiRepository.getInventoryList(params, isLog: false);
      if (res != false && res != null) {
        var list = List<InventoryItemModel>.from(
            res.map((x) => InventoryItemModel.fromJson(x)));
        inventoryList.value = list;
      }
    } catch (e) {
      print("Error fetching inventory: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addInventoryItem() async {
    if (partyController.text.trim().isEmpty ||
        itemNameController.text.trim().isEmpty ||
        sizeController.text.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Party, Item Name, and Size are required.");
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final Map<String, dynamic> body = {
        "party": partyController.text.trim(),
        "itemName": itemNameController.text.trim(),
        "size": sizeController.text.trim(),
        "currentlyAvailableStock": int.tryParse(stockController.text.trim()) ?? 0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "purchasePrice": double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
        "qty": int.tryParse(qtyController.text.trim()) ?? 0,
      };

      var res = await apiRepository.createInventory(body);
      Get.back(); // Pop loading dialog

      if (res != false) {
        AppSnacks.successSnack(message: "Inventory item added successfully.");
        clearForm();
        Get.back(); // Pop add dialog
        fetchInventory();
      }
    } catch (e) {
      Get.back();
      print("Error adding inventory item: $e");
    }
  }

  Future<void> updateInventoryItem(String id) async {
    if (partyController.text.trim().isEmpty ||
        itemNameController.text.trim().isEmpty ||
        sizeController.text.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Party, Item Name, and Size are required.");
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final Map<String, dynamic> body = {
        "party": partyController.text.trim(),
        "itemName": itemNameController.text.trim(),
        "size": sizeController.text.trim(),
        "currentlyAvailableStock": int.tryParse(stockController.text.trim()) ?? 0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "purchasePrice": double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
        "qty": int.tryParse(qtyController.text.trim()) ?? 0,
      };

      var res = await apiRepository.updateInventory(id, body);
      Get.back(); // Pop loading dialog

      if (res != false) {
        AppSnacks.successSnack(message: "Inventory item updated successfully.");
        clearForm();
        Get.back(); // Pop edit dialog
        fetchInventory();
      }
    } catch (e) {
      Get.back();
      print("Error updating inventory item: $e");
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      var res = await apiRepository.deleteInventory(id);
      Get.back(); // Pop loading dialog

      if (res != false) {
        AppSnacks.successSnack(message: "Inventory item deleted successfully.");
        fetchInventory();
      }
    } catch (e) {
      Get.back();
      print("Error deleting inventory item: $e");
    }
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
    fetchInventory();
  }
}
