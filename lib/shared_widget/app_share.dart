

import 'package:share_plus/share_plus.dart';

class AppShare{
  static Future shareFile(XFile file) async {
    Share.shareXFiles([file],);
  }
}