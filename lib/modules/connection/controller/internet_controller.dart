import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/modules/connection/view/no_internet_connection.dart';

class InternetController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    debugPrint("InternetController initialized");
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen(NetStatus);
  }

  Future<void> _checkInitialConnection() async {
    debugPrint("Checking initial connection");
    final List<ConnectivityResult> result =
        await _connectivity.checkConnectivity();
    debugPrint("Initial connection status: $result");
    NetStatus(result);
  }

  void NetStatus(List<ConnectivityResult> result) {
    debugPrint("Network status changed: $result");
    // if (result == ConnectivityResult.none) {
    if (!(result.contains(ConnectivityResult.mobile)) && !(result.contains(ConnectivityResult.wifi))) {
      debugPrint("No internet connection <<<=>>> attempting to show snackbar");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint("Post frame callback - showing snackbar");
        Get.rawSnackbar(
          titleText: SizedBox(
              width: double.infinity,
              height: Get.size.height / 1.1,
              child: const Align(
                alignment: Alignment.bottomCenter,
                child: NoInternetConnection(),
              )),
          messageText: Container(),
          backgroundColor: Colors.transparent,
          isDismissible: false,
          duration: const Duration(days: 1),
        );
      });
    } else {
      if (Get.isSnackbarOpen) {
        debugPrint("Closing snackbar");
        Get.closeCurrentSnackbar();
      }
    }
  }
}
