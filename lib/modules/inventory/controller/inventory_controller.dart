import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/data/api_repository.dart';
import 'package:elite_edition/modules/inventory/model/inventory_item_model.dart';
import 'package:elite_edition/modules/inventory/model/party_model.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';

class InventoryController extends GetxController {
  final ApiRepository apiRepository;

  InventoryController({required this.apiRepository});

  RxBool isLoading = false.obs;
  RxList<InventoryItemModel> inventoryList = RxList();
  RxString searchQuery = "".obs;

  RxBool isDarkMode = true.obs;
  RxBool isActionLoading = false.obs;
  RxBool isEditMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }

  // Catalog list options
  RxList<PartyModel> partiesList = RxList();
  RxList<dynamic> productsList = RxList();
  RxList<String> sizeOptionsList = RxList();

  // Selection states
  RxString selectedParty = "".obs;
  RxString selectedSkuCode = "".obs;
  RxString selectedImageUrl = "".obs;
  RxString selectedSize = "".obs;

  // Form controllers
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  // Inline Party Form Controllers
  final TextEditingController newPartyNameController = TextEditingController();
  final TextEditingController newPartyPhoneController = TextEditingController();
  final TextEditingController newPartyAddressController = TextEditingController();

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
    fetchParties();
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
    newPartyNameController.dispose();
    newPartyPhoneController.dispose();
    newPartyAddressController.dispose();
    newSkuController.dispose();
    newDescController.dispose();
    newImgUrlController.dispose();
    newSizesController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void clearForm() {
    isEditMode.value = false;
    selectedParty.value = "";
    selectedSkuCode.value = "";
    selectedImageUrl.value = "";
    selectedSize.value = "";
    sizeOptionsList.clear();
    
    itemNameController.clear();
    stockController.clear();
    salePriceController.clear();
    purchasePriceController.clear();
    qtyController.clear();
  }

  void populateForm(InventoryItemModel item) {
    isEditMode.value = true;
    selectedParty.value = item.party;
    itemNameController.text = item.itemName;
    selectedSkuCode.value = item.skuCode;
    selectedImageUrl.value = item.imageUrl;
    stockController.text = item.currentlyAvailableStock.toString();
    salePriceController.text = item.salePrice.toString();
    purchasePriceController.text = item.purchasePrice.toString();
    qtyController.text = item.qty.toString();

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
      print("Error fetching inventory: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchParties() async {
    try {
      var res = await apiRepository.getPartyList(null, isLog: false);
      if (res != false && res != null) {
        var list = List<PartyModel>.from(
            res.map((x) => PartyModel.fromJson(x)));
        partiesList.value = list;
      }
    } catch (e) {
      print("Error fetching parties: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      // Fetch products with a high limit to get all database options
      var res = await apiRepository.getProductList({"limit": "200"}, isLog: false);
      if (res != false && res != null) {
        productsList.value = List<dynamic>.from(res);
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<bool> addParty() async {
    final name = newPartyNameController.text.trim();
    if (name.isEmpty) {
      AppSnacks.errorSnack(message: "Party name is required.");
      return false;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "name": name,
        "phone": newPartyPhoneController.text.trim(),
        "address": newPartyAddressController.text.trim(),
      };

      var res = await apiRepository.createParty(body);

      if (res != false) {
        AppSnacks.successSnack(message: "Party '$name' added successfully.");
        newPartyNameController.clear();
        newPartyPhoneController.clear();
        newPartyAddressController.clear();
        await fetchParties();
        selectedParty.value = name;
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
    itemNameController.text = product["description"] ?? "";
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

  Future<void> addInventoryItem() async {
    if (selectedParty.value.trim().isEmpty ||
        itemNameController.text.trim().isEmpty ||
        selectedSize.value.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Party, Item Name, and Size are required.");
      return;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "party": selectedParty.value.trim(),
        "itemName": itemNameController.text.trim(),
        "size": selectedSize.value.trim(),
        "currentlyAvailableStock": int.tryParse(stockController.text.trim()) ?? 0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "purchasePrice": double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
        "qty": int.tryParse(qtyController.text.trim()) ?? 0,
        "imageUrl": selectedImageUrl.value,
        "skuCode": selectedSkuCode.value,
      };

      var res = await apiRepository.createInventory(body);

      if (res != false) {
        AppSnacks.successSnack(message: "Inventory item added successfully.");
        clearForm();
        Get.back(); // Pop add dialog
        fetchInventory();
      }
    } catch (e) {
      print("Error adding inventory item: $e");
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateInventoryItem(String id) async {
    if (selectedParty.value.trim().isEmpty ||
        itemNameController.text.trim().isEmpty ||
        selectedSize.value.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Party, Item Name, and Size are required.");
      return;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "party": selectedParty.value.trim(),
        "itemName": itemNameController.text.trim(),
        "size": selectedSize.value.trim(),
        "currentlyAvailableStock": int.tryParse(stockController.text.trim()) ?? 0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "purchasePrice": double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
        "qty": int.tryParse(qtyController.text.trim()) ?? 0,
        "imageUrl": selectedImageUrl.value,
        "skuCode": selectedSkuCode.value,
      };

      var res = await apiRepository.updateInventory(id, body);

      if (res != false) {
        AppSnacks.successSnack(message: "Inventory item updated successfully.");
        clearForm();
        Get.back(); // Pop edit dialog
        fetchInventory();
      }
    } catch (e) {
      print("Error updating inventory item: $e");
    } finally {
      isActionLoading.value = false;
    }
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
        
        // Auto-select the newly created product
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

  Future<void> deleteParty(String id) async {
    try {
      isActionLoading.value = true;
      var res = await apiRepository.deleteParty(id);
      if (res != false) {
        AppSnacks.successSnack(message: "Party deleted successfully.");
        await fetchParties();
        selectedParty.value = "";
      }
    } catch (e) {
      print("Error deleting party: $e");
    } finally {
      isActionLoading.value = false;
    }
  }

  void prefillPartyForm(PartyModel party) {
    newPartyNameController.text = party.name;
    newPartyPhoneController.text = party.phone;
    newPartyAddressController.text = party.address;
  }

  Future<bool> editParty(String id) async {
    final name = newPartyNameController.text.trim();
    if (name.isEmpty) {
      AppSnacks.errorSnack(message: "Party name is required.");
      return false;
    }

    try {
      isActionLoading.value = true;

      final Map<String, dynamic> body = {
        "name": name,
        "phone": newPartyPhoneController.text.trim(),
        "address": newPartyAddressController.text.trim(),
      };

      var res = await apiRepository.updateParty(id, body);

      if (res != false) {
        AppSnacks.successSnack(message: "Party updated successfully.");
        newPartyNameController.clear();
        newPartyPhoneController.clear();
        newPartyAddressController.clear();
        await fetchParties();
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
    final sizeList = product["size"] != null ? List<String>.from(product["size"]) : <String>[];
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
}
