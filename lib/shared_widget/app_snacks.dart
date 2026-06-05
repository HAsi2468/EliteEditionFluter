import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnacks {
  static errorSnack({String? title, String? message}) {
    return Get.snackbar(
      title ?? "Error",
      message ?? "Something went Wrong",
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static successSnack({String? title, String? message}) {
    return Get.snackbar(
      title ?? "SUCCESS",
      message ?? "Successfully..!!",
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
