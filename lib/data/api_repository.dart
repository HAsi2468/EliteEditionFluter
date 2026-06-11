import 'package:get/get.dart';
import 'package:elite_edition/constants/api_url.dart';
import 'package:elite_edition/data/api_provider.dart';

class ApiRepository extends GetxService {
  final ApiProvider apiProvider;

  ApiRepository({required this.apiProvider});

  Future<dynamic> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    var body = {"name": name, "email": email, "password": password};
    var res = await apiProvider.post(ApiUrl.register, body);
    return res;
  }

  Future<dynamic> loginUser({
    required String email,
    required String password,
  }) async {
    var body = {"email": email, "password": password};
    var res = await apiProvider.post(ApiUrl.login, body);
    return res;
  }

  Future<dynamic> getFilterData(Map<String, String>? param,
      {bool isLog = false}) async {
    var res = await apiProvider.get(ApiUrl.filter, param, isLog: isLog);
    return res;
  }

  Future<dynamic> getListData(Map<String, String>? param,
      {bool isLog = false}) async {
    var res = await apiProvider.get(ApiUrl.product, param, isLog: isLog);
    return res;
  }

  Future<dynamic> getProductDetailsData(Map<String, String>? param,
      {bool isLog = false}) async {
    var res = await apiProvider.get(ApiUrl.productDetails, param, isLog: isLog);
    return res;
  }

  Future<dynamic> getReport(Map<String, String>? param,
      {bool isLog = false}) async {
    var res = await apiProvider.get(ApiUrl.productReport, param, isLog: isLog);
    return res;
  }

  Future<dynamic> getBrandReport(Map<String, String>? param,
      {bool isLog = false}) async {
    var res = await apiProvider.get(ApiUrl.brandReport, param, isLog: isLog);
    return res;
  }

  Future<dynamic> getInventoryList(Map<String, String>? param,
      {bool isLog = false}) async {
    var res = await apiProvider.get(ApiUrl.inventory, param, isLog: isLog);
    return res;
  }

  Future<dynamic> getInventoryReport(String dateStart, String dateEnd) async {
    var res = await apiProvider.get("${ApiUrl.inventory}/report", {
      "dateStart": dateStart,
      "dateEnd": dateEnd,
    });
    return res;
  }

  Future<dynamic> createInventory(dynamic body) async {
    var res = await apiProvider.post(ApiUrl.inventory, body);
    return res;
  }

  Future<dynamic> updateInventory(String id, Map<String, dynamic> body) async {
    var res = await apiProvider.put("${ApiUrl.inventory}/$id", body);
    return res;
  }

  Future<dynamic> deleteInventory(String id) async {
    var res = await apiProvider.delete("${ApiUrl.inventory}/$id");
    return res;
  }

  Future<dynamic> getProductList(Map<String, String>? param,
      {bool isLog = false}) async {
    var res = await apiProvider.get(ApiUrl.productList, param, isLog: isLog);
    return res;
  }

  Future<dynamic> getVendorList(Map<String, String>? param,
      {bool isLog = false}) async {
    var res = await apiProvider.get(ApiUrl.vendor, param, isLog: isLog);
    return res;
  }

  Future<dynamic> createVendor(Map<String, dynamic> body) async {
    var res = await apiProvider.post(ApiUrl.vendor, body);
    return res;
  }

  Future<dynamic> updateVendor(String id, Map<String, dynamic> body) async {
    var res = await apiProvider.put("${ApiUrl.vendor}/$id", body);
    return res;
  }

  Future<dynamic> deleteVendor(String id) async {
    var res = await apiProvider.delete("${ApiUrl.vendor}/$id");
    return res;
  }

  Future<dynamic> createProduct(Map<String, dynamic> body) async {
    var res = await apiProvider.post(ApiUrl.productBase, body);
    return res;
  }

  Future<dynamic> deleteProduct(String id) async {
    var res = await apiProvider.delete("${ApiUrl.productBase}/$id");
    return res;
  }

  Future<dynamic> updateProduct(String id, Map<String, dynamic> body) async {
    var res = await apiProvider.put("${ApiUrl.productBase}/$id", body);
    return res;
  }

  Future<dynamic> syncMissingProducts() async {
    var res = await apiProvider.get("${ApiUrl.productBase}/fetchMissingProduct", null);
    return res;
  }

  // Party (Customer)
  Future<dynamic> getPartyList(Map<String, String>? param, {bool isLog = false}) async {
    var res = await apiProvider.get(ApiUrl.party, param, isLog: isLog);
    return res;
  }

  Future<dynamic> createParty(Map<String, dynamic> body) async {
    var res = await apiProvider.post(ApiUrl.party, body);
    return res;
  }

  Future<dynamic> updateParty(String id, Map<String, dynamic> body) async {
    var res = await apiProvider.put("${ApiUrl.party}/$id", body);
    return res;
  }

  Future<dynamic> deleteParty(String id) async {
    var res = await apiProvider.delete("${ApiUrl.party}/$id");
    return res;
  }

  // Stock Out
  Future<dynamic> createStockOut(Map<String, dynamic> body) async {
    var res = await apiProvider.post(ApiUrl.stockOut, body);
    return res;
  }

  Future<dynamic> getStockOut() async {
    var res = await apiProvider.get(ApiUrl.stockOut, null);
    return res;
  }
}
