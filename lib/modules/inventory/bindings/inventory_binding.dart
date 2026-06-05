import 'package:get/get.dart';
import 'package:elite_edition/data/api_repository.dart';
import 'package:elite_edition/modules/inventory/controller/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InventoryController(apiRepository: Get.find<ApiRepository>()));
  }
}
