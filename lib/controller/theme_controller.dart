import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  RxBool isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _detectSystemTheme();
    
    // Listen to system theme changes dynamically
    final dispatcher = SchedulerBinding.instance.platformDispatcher;
    dispatcher.onPlatformBrightnessChanged = () {
      _detectSystemTheme();
    };
  }

  void _detectSystemTheme() {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode.value = brightness == Brightness.dark;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}
