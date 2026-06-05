import 'package:get/get.dart';
import 'package:elite_edition/data/api_repository.dart';
import 'package:elite_edition/modules/home/controller/home_controller.dart';
import 'package:elite_edition/modules/inventory/controller/inventory_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController(apiRepository: Get.find<ApiRepository>()));
    Get.lazyPut(() => InventoryController(apiRepository: Get.find<ApiRepository>()));
  }
}
