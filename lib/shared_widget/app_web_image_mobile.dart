import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elite_edition/constants/app_color.dart';
import 'package:flutter/cupertino.dart';

Widget buildWebImage(String url, double? width, double? height, BoxFit? fit) {
  if (url.isEmpty) {
    return const Icon(
      Icons.image_not_supported,
      size: 30,
    );
  }
  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    errorWidget: (context, val, _) => const Icon(
      Icons.error,
      size: 30,
    ),
    placeholder: (context, val) => Center(
      child: CupertinoActivityIndicator(
        color: AppColor.black,
      ),
    ),
  );
}
