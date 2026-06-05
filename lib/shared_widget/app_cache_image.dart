import 'package:flutter/material.dart';
import 'package:elite_edition/shared_widget/app_web_image.dart';
import 'package:elite_edition/constants/api_url.dart';

class AppCacheImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder;

  const AppCacheImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return buildWebImage(ApiUrl.getFullImageUrl(imageUrl), width, height, fit);
  }
}
