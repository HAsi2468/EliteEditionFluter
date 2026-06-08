import 'package:get/get.dart';
import 'package:elite_edition/data/api_provider.dart';
import 'package:elite_edition/data/api_repository.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiProvider(), permanent: true);
    Get.put(
        ApiRepository(
          apiProvider: Get.find<ApiProvider>(),
        ),
        permanent: true);
  }
}

