import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLoader {
  static void show() {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> hide() async {
    // Try to dismiss the dialog. If it is still transitioning open,
    // we poll and check every 50ms for up to 1 second to ensure it is closed.
    for (int i = 0; i < 20; i++) {
      if (Get.isDialogOpen == true) {
        Get.back();
        return;
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}
