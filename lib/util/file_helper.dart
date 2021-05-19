import 'dart:io';

import 'package:enough_media/enough_media.dart';
import 'package:path_provider/path_provider.dart' as pp;

class FileHelper {
  FileHelper._();

  static Future<File> saveAsFile(MemoryMediaProvider provider) async {
    final directory = await pp.getTemporaryDirectory();
    final file = File('${directory.path}/${provider.name}');
    await file.writeAsBytes(provider.data, flush: true);
    return file;
  }
}
