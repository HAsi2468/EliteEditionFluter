import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:elite_edition/constants/api_url.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';

class ApiProvider extends GetxService {
  Future<dynamic> get(String endpoint, Map<String, String>? param,
      {bool isLog = false}) async {
    debugPrint("API CALL $endpoint");
    
    // Add timestamp to prevent browser caching
    final Map<String, dynamic> finalParams = {};
    if (param != null) {
      finalParams.addAll(param);
    }
    finalParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
    
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/$endpoint').replace(queryParameters: finalParams.cast<String, String>()),
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );
    debugPrint("API URL >>>>> ${response.request?.url}");
    if (isLog) {
      debugPrint("${ApiUrl.baseUrl}/$endpoint RESPONSE BODY ${response.statusCode} ===> ${response.body}");
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
    debugPrint("API CALL $endpoint => $body");
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: json.encode(body),
    );
    debugPrint("${ApiUrl.baseUrl}/$endpoint RESPONSE BODY ${response.statusCode} ===> ${response.body}");
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
    debugPrint("API CALL PUT $endpoint => $body");
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: json.encode(body),
    );
    debugPrint("${ApiUrl.baseUrl}/$endpoint RESPONSE BODY ${response.statusCode} ===> ${response.body}");
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
    debugPrint("API CALL DELETE $endpoint");
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/$endpoint'),
    );
    debugPrint("${ApiUrl.baseUrl}/$endpoint RESPONSE BODY ${response.statusCode} ===> ${response.body}");
    var result = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return result;
    } else {
      AppSnacks.errorSnack(message: result['message'] ?? result['error'] ?? 'Delete failed');
      return false;
    }
  }
}
