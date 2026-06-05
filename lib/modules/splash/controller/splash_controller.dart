import 'package:get/get.dart';
import 'package:elite_edition/data/api_repository.dart';
import 'package:elite_edition/routes/app_routes.dart';

class SplashController extends GetxController {
  final ApiRepository apiRepository;

  SplashController({required this.apiRepository});

  @override
  void onInit() {
    super.onInit();
    Future.delayed(
      Duration(seconds: 1),
      () {
        // Get.offAllNamed(AppRoutes.homePage);
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }
}
