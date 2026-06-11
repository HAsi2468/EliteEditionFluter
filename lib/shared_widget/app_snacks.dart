import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnacks {
  static errorSnack({String? title, String? message}) {
    try {
      Get.rawSnackbar(
        title: title ?? "Error",
        message: message ?? "Something went Wrong",
        backgroundColor: Colors.red.shade700,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint("Snackbar error: $e");
    }
  }

  static successSnack({String? title, String? message}) {
    try {
      Get.rawSnackbar(
        title: title ?? "SUCCESS",
        message: message ?? "Successfully..!!",
        backgroundColor: Colors.green.shade700,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint("Snackbar error: $e");
    }
  }
}
