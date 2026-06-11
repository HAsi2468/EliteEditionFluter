import 'package:flutter/material.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:elite_edition/shared_widget/app_image.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary800,
                  AppColor.primary900,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const Center(
            child: AppAssetImage(image: "assets/icons/Logo.png"),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text.rich(
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
                        color: AppColor.white,
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
                  color: AppColor.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
