// open_files.dart

import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';

class OpenFiles {
  final logger = Logger();
  Future<void> open(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      logger.e('Error opening file: $e');
    }
  }
}
