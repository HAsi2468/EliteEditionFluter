import 'package:flutter/material.dart';
import 'package:elite_edition/constants/app_color.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.imagePath,
    this.borderColor,
    this.hintTextColour,
    this.bgColor,
    this.obscureText,
    this.obscuringCharacter,
    this.textInputType,
    this.onTap,
    this.textInputAction,
    this.textCapitalization,
    this.textSize,
    this.textColour,
    this.onChanged,
    this.readOnly,
    this.textAlign,
    this.autoFocus,
    this.minLines,
    this.imgColor,
    this.textStyleColour,
    this.maxLines,
    this.validator,
    this.isPrefix = true,
    this.imgHeight,
    this.imgWidth,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? imagePath;
  final Color? textStyleColour;
  final Color? hintTextColour;
  final Color? bgColor;
  final Color? imgColor;
  final Color? borderColor;
  final bool? obscureText;
  final bool isPrefix;
  final String? obscuringCharacter;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function()? onTap;
  final double? textSize;
  final double? imgHeight;
  final double? imgWidth;
  final Color? textColour;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final bool? readOnly;
  final TextAlign? textAlign;
  final bool? autoFocus;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? AppColor.black),
        borderRadius: BorderRadius.circular(30),
        color: bgColor ?? AppColor.primary100,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          isPrefix
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Image.asset(
                    imagePath ?? "",
                    height: imgHeight ?? 30,
                    width: imgWidth ?? 30,
                    color: imgColor ?? AppColor.primary900,
                  ),
                )
              : const SizedBox(),
          Expanded(
            child: TextFormField(
              autofocus: autoFocus ?? false,
              readOnly: readOnly ?? false,
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText ?? false,
              obscuringCharacter: obscuringCharacter ?? "•",
              textCapitalization: textCapitalization ?? TextCapitalization.none,
              keyboardType: textInputType,
              textInputAction: textInputAction ?? TextInputAction.next,
              textAlign: textAlign ?? TextAlign.start,
              minLines: minLines,
              style: TextStyle(
                color: textStyleColour ?? AppColor.primary200,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              maxLines: maxLines ?? 1,
              cursorColor: textStyleColour ?? AppColor.primary200,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: hintTextColour ?? AppColor.primary900,
                  fontSize: 17,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: onChanged,
              onTap: onTap,
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}
