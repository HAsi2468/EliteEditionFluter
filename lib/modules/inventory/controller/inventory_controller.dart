import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/data/api_repository.dart';
import 'package:elite_edition/modules/inventory/model/inventory_item_model.dart';
import 'package:elite_edition/modules/inventory/model/vendor_model.dart';
import 'package:elite_edition/modules/inventory/model/party_model.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';

import 'package:elite_edition/controller/theme_controller.dart';

class InventoryController extends GetxController {
  final ApiRepository apiRepository;

  InventoryController({required this.apiRepository});

  RxBool isLoading = false.obs;
  RxList<InventoryItemModel> inventoryList = RxList();
  RxList<dynamic> stockOutList = RxList();
  RxString searchQuery = "".obs;

  RxBool get isDarkMode => Get.find<ThemeController>().isDarkMode;
  RxBool isActionLoading = false.obs;
  RxBool isEditMode = false.obs;
  RxList<Map<String, dynamic>> stagedItems = RxList();

  /// Groups inventoryList by skuCode, summing stock across all parties.
  /// Returns a list of maps with keys:
  ///   skuCode, itemName, imageUrl, totalStock, totalQty, entries (List<InventoryItemModel>)
  List<Map<String, dynamic>> get groupedBySku {
    final Map<String, Map<String, dynamic>> grouped = {};

    // CRITICAL FIX: Explicitly access searchQuery.value here so Obx knows to track changes!
    final query = searchQuery.value.toLowerCase().trim();

    // Filter the internal inventory list locally based on your search fields
    final filteredList = inventoryList.where((item) {
      if (query.isEmpty) return true;

      final matchesName = item.itemName.toLowerCase().contains(query);
      final matchesParty = item.party.toLowerCase().contains(query);
      final matchesSku =
          item.skuCode.toString().toLowerCase().trim().contains(query);

      return matchesName || matchesParty || matchesSku;
    }).toList();

    for (final item in filteredList) {
      final key = item.skuCode.isNotEmpty ? item.skuCode : item.itemName;
      if (!grouped.containsKey(key)) {
        grouped[key] = {
          'skuCode': item.skuCode,
          'itemName': item.itemName,
          'imageUrl': item.imageUrl,
          'totalStock': 0,
          'totalQty': 0,
          'entries': <InventoryItemModel>[],
        };
      }
      grouped[key]!['totalStock'] =
          (grouped[key]!['totalStock'] as int) + item.currentlyAvailableStock;
      grouped[key]!['totalQty'] = (grouped[key]!['totalQty'] as int) + item.qty;
      (grouped[key]!['entries'] as List<InventoryItemModel>).add(item);
    }
    return grouped.values.toList();
  }

  void toggleTheme() {
    Get.find<ThemeController>().toggleTheme();
  }

  // Catalog list options
  RxList<VendorModel> vendorsList = RxList();
  RxList<PartyModel> newPartiesList = RxList();
  RxList<dynamic> productsList = RxList();
  RxList<String> sizeOptionsList = RxList();

  // Selection states
  RxString selectedVendor = "".obs;
  RxString selectedSkuCode = "".obs;
  RxString selectedImageUrl = "".obs;
  RxString selectedSize = "".obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

  // Form controllers
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  // Inline Party Form Controllers
  final TextEditingController newVendorNameController = TextEditingController();
  final TextEditingController newVendorPhoneController = TextEditingController();
  final TextEditingController newVendorAddressController =
      TextEditingController();

  // Inline Product Form Controllers
  final TextEditingController newSkuController = TextEditingController();
  final TextEditingController newDescController = TextEditingController();
  final TextEditingController newImgUrlController = TextEditingController();
  final TextEditingController newSizesController = TextEditingController();

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchInventory();
    fetchVendors();
    fetchNewParties();
    fetchProducts();
    qtyController.addListener(() {
      if (!isEditMode.value) {
        stockController.text = qtyController.text;
      }
    });
  }

  @override
  void onClose() {
    itemNameController.dispose();
    stockController.dispose();
    salePriceController.dispose();
    purchasePriceController.dispose();
    qtyController.dispose();
    newVendorNameController.dispose();
    newVendorPhoneController.dispose();
    newVendorAddressController.dispose();
    newSkuController.dispose();
    newDescController.dispose();
    newImgUrlController.dispose();
    newSizesController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void clearForm() {
    isEditMode.value = false;
    stagedItems.clear();
    selectedVendor.value = "";
    selectedSkuCode.value = "";
    selectedImageUrl.value = "";
    selectedSize.value = "";
    sizeOptionsList.clear();
    selectedDate.value = DateTime.now();

    itemNameController.clear();
    stockController.clear();
    salePriceController.clear();
    purchasePriceController.clear();
    qtyController.clear();
  }

  void populateForm(InventoryItemModel item) {
    isEditMode.value = true;
    selectedVendor.value = item.party;
    itemNameController.text = item.itemName;
    selectedSkuCode.value = item.skuCode;
    selectedImageUrl.value = item.imageUrl;
    stockController.text = item.currentlyAvailableStock.toString();
    salePriceController.text = item.salePrice.toString();
    purchasePriceController.text = item.purchasePrice.toString();
    qtyController.text = item.qty.toString();
    selectedDate.value = item.date != null
        ? DateTime.parse(item.date!)
        : (item.createdDateTime != null
            ? DateTime.parse(item.createdDateTime!)
            : DateTime.now());

    // Populate sizes list based on product SKU if found
    sizeOptionsList.clear();
    if (item.skuCode.isNotEmpty) {
      final product = productsList.firstWhere(
        (p) => p["skuCode"] == item.skuCode,
        orElse: () => null,
      );
      if (product != null && product["size"] != null) {
        sizeOptionsList.value = List<String>.from(product["size"]);
      }
    }

    // Ensure current size is in sizeOptionsList as fallback
    if (item.size.isNotEmpty && !sizeOptionsList.contains(item.size)) {
      sizeOptionsList.add(item.size);
    }
    selectedSize.value = item.size;
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
      debugPrint("Error fetching inventory: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStockOutList() async {
    try {
      var res = await apiRepository.getStockOut();
      if (res != false && res != null) {
        stockOutList.value = List<dynamic>.from(res);
      }
    } catch (e) {
      debugPrint("Error fetching stock out list: $e");
    }
  }

  Future<void> fetchVendors() async {
    try {
      var res = await apiRepository.getVendorList(null, isLog: false);
      if (res != false && res != null) {
        var list =
            List<VendorModel>.from(res.map((x) => VendorModel.fromJson(x)));
        vendorsList.value = list;
      }
    } catch (e) {
      print("Error fetching parties: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      var res =
          await apiRepository.getProductList({"limit": "200"}, isLog: false);
      if (res != false && res != null) {
        productsList.value = List<dynamic>.from(res);
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<bool> addVendor() async {
    final name = newVendorNameController.text.trim();
    if (name.isEmpty) {
      AppSnacks.errorSnack(message: "Party name is required.");
      return false;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "name": name,
        "phone": newVendorPhoneController.text.trim(),
        "address": newVendorAddressController.text.trim(),
      };

      var res = await apiRepository.createVendor(body);

      if (res != false) {
        AppSnacks.successSnack(message: "Party '$name' added successfully.");
        newVendorNameController.clear();
        newVendorPhoneController.clear();
        newVendorAddressController.clear();
        await fetchVendors();
    fetchNewParties();
        selectedVendor.value = name;
        return true;
      }
    } catch (e) {
      print("Error adding party: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  void onProductSelected(dynamic product) {
    if (product == null) return;
    itemNameController.text = (product["description"]?.toString().isNotEmpty == true) 
        ? product["description"] 
        : (product["categoryName"]?.toString().isNotEmpty == true 
            ? product["categoryName"] 
            : (product["brand"]?.toString().isNotEmpty == true 
                ? product["brand"] 
                : (product["skuCode"] ?? "Unknown Item")));
    selectedSkuCode.value = product["skuCode"] ?? "";
    selectedImageUrl.value = product["imageUrl"] ?? "";

    sizeOptionsList.clear();
    if (product["size"] != null) {
      sizeOptionsList.value = List<String>.from(product["size"]);
    }
    if (sizeOptionsList.isNotEmpty) {
      selectedSize.value = sizeOptionsList[0];
    } else {
      selectedSize.value = "";
    }
  }

  Future<bool> addInventoryItem() async {
    if (selectedVendor.value.trim().isEmpty ||
        selectedSize.value.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Party and Size are required.");
      return false;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "party": selectedVendor.value.trim(),
        "itemName": itemNameController.text.trim(),
        "size": selectedSize.value.trim(),
        "currentlyAvailableStock":
            int.tryParse(stockController.text.trim()) ?? 0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "purchasePrice":
            double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
        "qty": int.tryParse(qtyController.text.trim()) ?? 0,
        "imageUrl": selectedImageUrl.value,
        "skuCode": selectedSkuCode.value,
        "date": selectedDate.value.toIso8601String(),
      };

      var res = await apiRepository.createInventory(body);

      if (res != false) {
        AppSnacks.successSnack(message: "Inventory item added successfully.");
        clearForm();
        fetchInventory();
        return true;
      }
    } catch (e) {
      print("Error adding inventory item: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> updateInventoryItem(String id) async {
    if (selectedVendor.value.trim().isEmpty ||
        selectedSize.value.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Vendor and Size are required.");
      return false;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "party": selectedVendor.value.trim(),
        "itemName": itemNameController.text.trim(),
        "size": selectedSize.value.trim(),
        "currentlyAvailableStock":
            int.tryParse(stockController.text.trim()) ?? 0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "purchasePrice":
            double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
        "qty": int.tryParse(qtyController.text.trim()) ?? 0,
        "imageUrl": selectedImageUrl.value,
        "skuCode": selectedSkuCode.value,
        "date": selectedDate.value.toIso8601String(),
      };

      var res = await apiRepository.updateInventory(id, body);

      if (res != false) {
        AppSnacks.successSnack(message: "Inventory item updated successfully.");
        clearForm();
        fetchInventory();
        return true;
      }
    } catch (e) {
      print("Error updating inventory item: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<void> deleteInventoryItem(String id) async {
    try {
      isActionLoading.value = true;

      var res = await apiRepository.deleteInventory(id);

      if (res != false) {
        AppSnacks.successSnack(message: "Inventory item deleted successfully.");
        fetchInventory();
      }
    } catch (e) {
      print("Error deleting inventory item: $e");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteStockOutItem(String id) async {
    try {
      isActionLoading.value = true;

      var res = await apiRepository.deleteStockOut(id);

      if (res != false) {
        AppSnacks.successSnack(message: "Stock out item deleted successfully.");
        fetchStockOutList();
      }
    } catch (e) {
      print("Error deleting stock out item: $e");
    } finally {
      isActionLoading.value = false;
    }
  }

  // CRITICAL FIX: Update the searchQuery value field directly inside this method!
  void onSearchChanged(String val) {
    searchQuery.value = val;
    fetchInventory();
  }

  Future<bool> addProduct() async {
    final sku = newSkuController.text.trim();
    final desc = newDescController.text.trim();
    if (sku.isEmpty || desc.isEmpty) {
      AppSnacks.errorSnack(message: "SKU Code and Product Name are required.");
      return false;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "skuCode": sku,
        "description": desc,
        "imageUrl": newImgUrlController.text.trim(),
        "size": newSizesController.text.trim(),
      };

      var res = await apiRepository.createProduct(body);

      if (res != false) {
        AppSnacks.successSnack(message: "Product '$sku' created successfully.");
        newSkuController.clear();
        newDescController.clear();
        newImgUrlController.clear();
        newSizesController.clear();
        await fetchProducts();

        final createdProduct = productsList.firstWhere(
          (p) => p["skuCode"] == sku,
          orElse: () => null,
        );
        if (createdProduct != null) {
          onProductSelected(createdProduct);
        }
        return true;
      }
    } catch (e) {
      print("Error creating product: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<void> syncProductsFromSaleOrders() async {
    try {
      isActionLoading.value = true;
      var res = await apiRepository.syncMissingProducts();
      
      if (res != null) {
        String msg = res["message"] ?? "Sync process started.";
        AppSnacks.successSnack(message: msg);
        // The background process may take time, but we can re-fetch anyway.
        await fetchProducts();
      } else {
        AppSnacks.errorSnack(message: "Failed to start sync process.");
      }
    } catch (e) {
      print("Error syncing products: $e");
      AppSnacks.errorSnack(message: "Error syncing products.");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteVendor(String id) async {
    try {
      isActionLoading.value = true;
      var res = await apiRepository.deleteVendor(id);
      if (res != false) {
        AppSnacks.successSnack(message: "Party deleted successfully.");
        await fetchVendors();
    fetchNewParties();
        selectedVendor.value = "";
      }
    } catch (e) {
      print("Error deleting party: $e");
    } finally {
      isActionLoading.value = false;
    }
  }

  void prefillVendorForm(VendorModel party) {
    newVendorNameController.text = party.name;
    newVendorPhoneController.text = party.phone;
    newVendorAddressController.text = party.address;
  }

  Future<bool> editVendor(String id) async {
    final name = newVendorNameController.text.trim();
    if (name.isEmpty) {
      AppSnacks.errorSnack(message: "Party name is required.");
      return false;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "name": name,
        "phone": newVendorPhoneController.text.trim(),
        "address": newVendorAddressController.text.trim(),
      };

      var res = await apiRepository.updateVendor(id, body);

      if (res != false) {
        AppSnacks.successSnack(message: "Party updated successfully.");
        newVendorNameController.clear();
        newVendorPhoneController.clear();
        newVendorAddressController.clear();
        await fetchVendors();
    fetchNewParties();
        return true;
      }
    } catch (e) {
      print("Error updating party: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  void prefillProductForm(dynamic product) {
    newSkuController.text = product["skuCode"] ?? "";
    newDescController.text = product["description"] ?? "";
    newImgUrlController.text = product["imageUrl"] ?? "";
    final sizeList = product["size"] != null
        ? List<String>.from(product["size"])
        : <String>[];
    newSizesController.text = sizeList.join(', ');
  }

  Future<bool> editProduct(String id) async {
    final sku = newSkuController.text.trim();
    final desc = newDescController.text.trim();
    if (sku.isEmpty || desc.isEmpty) {
      AppSnacks.errorSnack(message: "SKU Code and Product Name are required.");
      return false;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "skuCode": sku,
        "description": desc,
        "imageUrl": newImgUrlController.text.trim(),
        "size": newSizesController.text.trim(),
      };

      var res = await apiRepository.updateProduct(id, body);

      if (res != false) {
        AppSnacks.successSnack(message: "Product updated successfully.");
        newSkuController.clear();
        newDescController.clear();
        newImgUrlController.clear();
        newSizesController.clear();
        await fetchProducts();
        return true;
      }
    } catch (e) {
      print("Error updating product: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<void> deleteProduct(String id) async {
    try {
      isActionLoading.value = true;
      var res = await apiRepository.deleteProduct(id);
      if (res != false) {
        AppSnacks.successSnack(message: "Product deleted successfully.");
        await fetchProducts();
        selectedSkuCode.value = "";
        selectedImageUrl.value = "";
      }
    } catch (e) {
      print("Error deleting product: $e");
    } finally {
      isActionLoading.value = false;
    }
  }

  void stageCurrentItem() {
    if (selectedVendor.value.trim().isEmpty ||
        selectedSize.value.trim().isEmpty) {
      AppSnacks.errorSnack(
           message: "Vendor and Size are required for all staged items.");
      return;
    }

    final item = {
      "party": selectedVendor.value.trim(),
      "itemName": itemNameController.text.trim(),
      "size": selectedSize.value.trim(),
      "currentlyAvailableStock": int.tryParse(stockController.text.trim()) ?? 0,
      "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
      "purchasePrice":
          double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
      "qty": int.tryParse(qtyController.text.trim()) ?? 0,
      "imageUrl": selectedImageUrl.value,
      "skuCode": selectedSkuCode.value,
      "date": selectedDate.value.toIso8601String(),
    };

    stagedItems.add(item);

    selectedSkuCode.value = "";
    selectedImageUrl.value = "";
    selectedSize.value = "";
    sizeOptionsList.clear();

    itemNameController.clear();
    stockController.clear();
    salePriceController.clear();
    purchasePriceController.clear();
    qtyController.clear();

    AppSnacks.successSnack(message: "Item staged. You can add more.");
  }

  Future<bool> addStagedInventoryItems() async {
    if (stagedItems.isEmpty) return false;

    try {
      isActionLoading.value = true;

      var res = await apiRepository
          .createInventory(List<Map<String, dynamic>>.from(stagedItems));

      if (res != false) {
        AppSnacks.successSnack(
            message: "All staged inventory items added successfully.");
        clearForm();
        fetchInventory();
        return true;
      }
    } catch (e) {
      print("Error adding staged inventory items: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<void> fetchNewParties() async {
    try {
      var res = await apiRepository.getPartyList(null, isLog: false);
      if (res != false && res != null) {
        var list = List<PartyModel>.from(res.map((x) => PartyModel.fromJson(x)));
        newPartiesList.value = list;
      }
    } catch (e) {
      print("Error fetching new parties: $e");
    }
  }

  Future<bool> addNewParty(String name, String phone, String address) async {
    try {
      isActionLoading.value = true;
      var res = await apiRepository.createParty({
        "name": name,
        "phone": phone,
        "address": address,
      });
      if (res != false) {
        AppSnacks.successSnack(message: "Party added successfully.");
        await fetchNewParties();
        return true;
      }
    } catch (e) {
      print("Error adding party: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> editNewParty(String id, String name, String phone, String address) async {
    try {
      isActionLoading.value = true;
      var res = await apiRepository.updateParty(id, {
        "name": name,
        "phone": phone,
        "address": address,
      });
      if (res != false) {
        AppSnacks.successSnack(message: "Party updated successfully.");
        await fetchNewParties();
        return true;
      }
    } catch (e) {
      print("Error updating party: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<void> deleteNewParty(String id) async {
    try {
      isActionLoading.value = true;
      var res = await apiRepository.deleteParty(id);
      if (res != false) {
        AppSnacks.successSnack(message: "Party deleted successfully.");
        await fetchNewParties();
      }
    } catch (e) {
      print("Error deleting party: $e");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> submitStockOut(String skuCode, String party, {int qtyOut = 1}) async {
    try {
      isActionLoading.value = true;
      var res = await apiRepository.createStockOut({
        "skuCode": skuCode,
        "party": party,
        "qtyOut": qtyOut,
      });
      if (res != false) {
        AppSnacks.successSnack(message: "Stock out successful.");
        fetchInventory(); // Refresh stock
        return true;
      }
    } catch (e) {
      AppSnacks.errorSnack(message: "Not enough stock or item not found.");
      print("Error submitting stock out: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> updateStockOutItem(String id, String skuCode, String party, int qtyOut) async {
    try {
      isActionLoading.value = true;
      var res = await apiRepository.updateStockOut(id, {
        "skuCode": skuCode,
        "party": party,
        "qtyOut": qtyOut,
      });
      if (res != false) {
        AppSnacks.successSnack(message: "Stock out updated successfully.");
        fetchStockOutList();
        fetchInventory(); // Refresh stock
        return true;
      }
    } catch (e) {
      AppSnacks.errorSnack(message: "Error updating stock out: $e");
      print("Error updating stock out: $e");
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }
}

