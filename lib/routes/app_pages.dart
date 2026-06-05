import 'package:get/get.dart';
import 'package:elite_edition/modules/auth/bindings/auth_binding.dart';
import 'package:elite_edition/modules/auth/view/login_view.dart';
import 'package:elite_edition/modules/auth/view/register_view.dart';
import 'package:elite_edition/modules/home/bindings/home_binding.dart';
import 'package:elite_edition/modules/home/view/homepage.dart';
import 'package:elite_edition/modules/product_details/bindings/product_details_binding.dart';
import 'package:elite_edition/modules/product_details/view/product_details_view.dart';
import 'package:elite_edition/modules/splash/bindings/splash_binding.dart';
import 'package:elite_edition/modules/splash/view/splash_view.dart';
import 'package:elite_edition/routes/app_routes.dart';
import 'package:elite_edition/modules/inventory/bindings/inventory_binding.dart';
import 'package:elite_edition/modules/inventory/view/inventory_view.dart';

class AppPages {
  AppPages._();

  static const initialRoute = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.homePage,
      page: () => Homepage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => ProductDetailsView(),
      binding: ProductDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.inventory,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
  ];
}
