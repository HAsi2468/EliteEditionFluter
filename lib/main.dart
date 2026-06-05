import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/bindings/initial_binding.dart';
import 'package:elite_edition/modules/connection/controller/internet_controller.dart';
import 'package:elite_edition/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(InternetController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Elite Edition',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Futura',
      ),
      initialBinding: InitialBindings(),
      initialRoute: AppPages.initialRoute,
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
    );
  }
}
