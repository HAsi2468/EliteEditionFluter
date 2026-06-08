import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/bindings/initial_binding.dart';
import 'package:elite_edition/modules/connection/controller/internet_controller.dart';
import 'package:elite_edition/routes/app_pages.dart';
import 'package:elite_edition/controller/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(InternetController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      return GetMaterialApp(
        title: 'Elite Edition',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Futura',
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Futura',
          brightness: Brightness.dark,
        ),
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        initialBinding: InitialBindings(),
        initialRoute: AppPages.initialRoute,
        debugShowCheckedModeBanner: false,
        getPages: AppPages.routes,
      );
    });
  }
}

