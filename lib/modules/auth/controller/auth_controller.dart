import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/data/api_repository.dart';
import 'package:elite_edition/routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiRepository apiRepository;

  AuthController({required this.apiRepository});

  final TextEditingController regEmailTxtController = TextEditingController(text: "");
  final TextEditingController regNameTxtController = TextEditingController(text: "");
  final TextEditingController regPassTxtController = TextEditingController(text: "");
  final TextEditingController logPassTxtController = TextEditingController(text: "Parth@6070");
  final TextEditingController logEmailTxtController = TextEditingController(text: "ecom.eliteedition@gmail.com");
// final TextEditingController regEmailTxtController = TextEditingController(text: "demo@gmail.com");
//   final TextEditingController regNameTxtController = TextEditingController(text: "Demo");
//   final TextEditingController regPassTxtController = TextEditingController(text: "Demo@1234");
//   final TextEditingController logPassTxtController = TextEditingController(text: "Test@1234");
//   final TextEditingController logEmailTxtController = TextEditingController(text: "test@gmail.com");

  registerUser() async {
    var res = await apiRepository.registerUser(
      name: regNameTxtController.text.trim(),
      email: regEmailTxtController.text.trim(),
      password: regPassTxtController.text.trim(),
    );

    if (res != false) {
      Get.offAllNamed(AppRoutes.homePage);
    }
  }

  loginUser() async {
    var res = await apiRepository.loginUser(
      email: logEmailTxtController.text.trim(),
      password: logPassTxtController.text.trim(),
    );

    if (res != false) {
      Get.offAllNamed(AppRoutes.homePage);
    }
  }
}
