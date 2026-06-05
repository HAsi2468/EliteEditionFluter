import 'package:flutter/material.dart';
import 'package:elite_edition/constants/app_color.dart';

class AppButton extends StatelessWidget {
  final Widget? child;
  final String? text;
  final Color? textColor;
  final Color? bgColor;
  final double width;
  final double height;
  final Function()? onPressed;

  const AppButton({
    super.key,
    this.child,
    this.bgColor,
    this.textColor,
    this.text,
    this.width = double.infinity,
    this.height = 50.0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: bgColor ?? (onPressed != null ? AppColor.primary900 : AppColor.primary800),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary600,
            offset: Offset(0.0, 1.5),
            blurRadius: 1.5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: child ??
                Text(
                  text ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: textColor ?? AppColor.white,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
