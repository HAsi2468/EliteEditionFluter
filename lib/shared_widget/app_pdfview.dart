import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class AppPdfView extends StatelessWidget {
  final String path;

  const AppPdfView({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer'),),
      body: PDFView(
        filePath: path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: false,
      ),
    );
  }
}