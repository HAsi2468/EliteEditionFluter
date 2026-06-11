import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String?> saveAndDownloadPdf(Uint8List bytes, String fileName) async {
  // Try to use Download directory on Android, otherwise use application documents directory
  Directory? directory;
  try {
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = Directory('/sdcard/Download');
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
  } catch (e) {
    directory = await getApplicationDocumentsDirectory();
  }

  // Fallback to temporary directory if documents/download is inaccessible
  if (!await directory.exists()) {
    directory = await getTemporaryDirectory();
  }

  final file = File("${directory.path}/$fileName");
  await file.writeAsBytes(bytes);
  return file.path;
}
