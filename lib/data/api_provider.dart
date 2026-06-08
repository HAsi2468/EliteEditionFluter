import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:elite_edition/constants/api_url.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';

class ApiProvider extends GetxService {
  Future<dynamic> get(String endpoint, Map<String, String>? param,
      {bool isLog = false}) async {
    print("API CALL $endpoint");
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/$endpoint').replace(queryParameters: param),
    );
    print("API URL >>>>> ${response.request?.url}");
    if (isLog) {
      print("${ApiUrl.baseUrl}/$endpoint RESPONSE BODY ${response.statusCode} ===> ${response.body}");
    }
    var result = json.decode(response.body);

    if (response.statusCode == 200) {
      return result;
    } else {
      AppSnacks.errorSnack(message: result['message']);
      return false;
    }
  }

  Future<dynamic> post(String endpoint, dynamic body,
      {Map<String, String>? headers}) async {
    print("API CALL $endpoint => $body");
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: json.encode(body),
    );
    print("${ApiUrl.baseUrl}/$endpoint RESPONSE BODY ${response.statusCode} ===> ${response.body}");
    var result = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return result;
    } else {
      AppSnacks.errorSnack(message: result['message']);
      return false;
    }
  }

  Future<dynamic> put(String endpoint, Map body,
      {Map<String, String>? headers}) async {
    print("API CALL PUT $endpoint => $body");
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: json.encode(body),
    );
    print("${ApiUrl.baseUrl}/$endpoint RESPONSE BODY ${response.statusCode} ===> ${response.body}");
    var result = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return result;
    } else {
      AppSnacks.errorSnack(message: result['message'] ?? result['error'] ?? 'Update failed');
      return false;
    }
  }

  Future<dynamic> delete(String endpoint,
      {Map<String, String>? headers}) async {
    print("API CALL DELETE $endpoint");
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/$endpoint'),
    );
    print("${ApiUrl.baseUrl}/$endpoint RESPONSE BODY ${response.statusCode} ===> ${response.body}");
    var result = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return result;
    } else {
      AppSnacks.errorSnack(message: result['message'] ?? result['error'] ?? 'Delete failed');
      return false;
    }
  }
}
