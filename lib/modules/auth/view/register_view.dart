import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/modules/auth/controller/auth_controller.dart';
import 'package:elite_edition/shared_widget/app_button.dart';
import 'package:elite_edition/shared_widget/app_image.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';
import 'package:elite_edition/shared_widget/textfield_widget.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final AuthController controller = Get.find<AuthController>();

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
                const SizedBox(
                  height: 60,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        CupertinoIcons.lessthan_square_fill,
                        color: AppColor.primary900,
                        size: 35,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 200,
                  width: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primary900,
                  ),
                  margin: const EdgeInsets.only(top: 30),
                  child: const AppAssetImage(
                    image: "assets/icons/Logo.png",
                    width: 200,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFieldWidget(
                  hintText: "username",
                  imagePath: "assets/icons/user.png",
                  controller: controller.regNameTxtController,
                  textStyleColour: AppColor.primary900,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  hintText: "email",
                  imagePath: "assets/icons/email.png",
                  controller: controller.regEmailTxtController,
                  textStyleColour: AppColor.primary900,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                  hintText: "password",
                  imagePath: "assets/icons/Lock.png",
                  controller: controller.regPassTxtController,
                  textStyleColour: AppColor.primary900,
                ),
                const SizedBox(
                  height: 30,
                ),
                AppButton(
                  onPressed: _regUser,
                  text: "Register",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _regUser() {
    if (controller.regNameTxtController.text.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Enter use name");
    } else if (controller.regEmailTxtController.text.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Enter email");
    } else if (controller.regPassTxtController.text.trim().isEmpty) {
      AppSnacks.errorSnack(message: "Enter password");
    } else {
      controller.registerUser();
    }
  }
}
