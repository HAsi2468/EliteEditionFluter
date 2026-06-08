import 'package:flutter/material.dart';

class AppAssetImage extends StatelessWidget {
  const AppAssetImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit,
    this.imgColor,
  });

  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? imgColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      height: height,
      width: width,
      fit: fit,
      color: imgColor,
    );
  }
}

