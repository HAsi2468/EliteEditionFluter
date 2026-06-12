import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:get/get.dart';

class AppPdfView extends StatelessWidget {
  final String path;

  const AppPdfView({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "Share",
            onPressed: () async {
              try {
                await Share.shareXFiles([XFile(path)], text: 'PDF Document');
              } catch (e) {
                Get.snackbar("Error", "Could not share file: $e");
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Download/Save",
            onPressed: () async {
              if (Platform.isAndroid || Platform.isIOS) {
                try {
                  final params = SaveFileDialogParams(sourceFilePath: path, fileName: p.basename(path));
                  final filePath = await FlutterFileDialog.saveFile(params: params);
                  if (filePath != null) {
                    Get.snackbar("Success", "File saved to $filePath");
                  }
                } catch (e) {
                  Get.snackbar("Error", "Could not save file: $e");
                }
              } else {
                Get.snackbar("Info", "Download is not supported on this platform from the viewer.");
              }
            },
          ),
        ],
      ),
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