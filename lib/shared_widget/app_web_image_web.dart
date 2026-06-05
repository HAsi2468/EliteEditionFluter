import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import 'package:flutter/material.dart';

Widget buildWebImage(String url, double? width, double? height, BoxFit? fit) {
  if (url.isEmpty) {
    return const Icon(
      Icons.image_not_supported,
      size: 30,
    );
  }
  
  // Use a unique view type per URL to prevent caching/sharing issues
  final String viewType = 'img-${url.hashCode}';
  
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final html.ImageElement img = html.ImageElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
      
    if (fit == BoxFit.cover) {
      img.style.objectFit = 'cover';
    } else if (fit == BoxFit.contain) {
      img.style.objectFit = 'contain';
    } else if (fit == BoxFit.fill) {
      img.style.objectFit = 'fill';
    }
    return img;
  });

  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewType),
  );
}
