import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/modules/auth/controller/auth_controller.dart';
import 'package:elite_edition/routes/app_routes.dart';
import 'package:elite_edition/shared_widget/app_button.dart';
import 'package:elite_edition/shared_widget/app_image.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';
import 'package:elite_edition/shared_widget/textfield_widget.dart';

class LoginView extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primary900,
                  ),
                  margin: const EdgeInsets.only(top: 80),
                  child: const AppAssetImage(
                    image: "assets/icons/Logo.png",
                    width: 200,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFieldWidget(
                  hintText: "email",
                  imagePath: "assets/icons/email.png",
                  controller: controller.logEmailTxtController,
                  textStyleColour: AppColor.primary900,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                  hintText: "password",
                  imagePath: "assets/icons/Lock.png",
                  controller: controller.logPassTxtController,
                  textStyleColour: AppColor.primary900,
                ),
                const SizedBox(
                  height: 30,
                ),
                AppButton(
                  onPressed: _loginUser,
                  text: "Login",
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.register);
                  },
                  style: TextButton.styleFrom(
                    // padding: EdgeInsets.zero,
                    foregroundColor: AppColor.primary700,
                  ),
                  child: const Text(
                    "Don't have account, Register!",
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Text.rich(
                  TextSpan(
                    text: "Powered by ",
                    children: [
                      const TextSpan(
                        text: "❤️ ",
                        style: TextStyle(color: Color(0xFFDB372D)),
                      ),
                      TextSpan(
                        text: "HASI",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary900,
                        ),
                      ),
                      const TextSpan(
                        text: " ❤️",
                        style: TextStyle(color: Color(0xFFDB372D)),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _loginUser() {
    if (controller.logEmailTxtController.text.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Enter email");
    } else if (controller.logPassTxtController.text.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Enter password");
    } else {
      controller.loginUser();
    }
  }
}
