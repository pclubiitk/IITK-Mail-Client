///android 29+
/// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadFiles extends ChangeNotifier {
  Future<String?> downloadFileFromBytes(
    Uint8List bytes,
    String fileName, {
    bool keepDuplicate = false,
  }) async {
    try {
      var savedPath = await _saveFileToAppDir(
        bytes,
        fileName,
        keepDuplicate: keepDuplicate,
      );
      if (savedPath != null) {
        return savedPath;
      } else {
        throw Exception('Failed to save file');
      }
    } catch (e) {
      print('Error during file download: $e');
      return null;
    }
  }

  Future<String?> _saveFileToAppDir(
    Uint8List bytes,
    String fileName, {
    bool keepDuplicate = false,
  }) async {
    try {
      /// Get the app-specific directory for storing files
      Directory? appDir = await getExternalStorageDirectory();
      if (appDir == null) {
        throw Exception('External storage directory not found');
      }

      /// Create the file path within the app-specific directory
      String filePath = '${appDir.path}/$fileName';

      /// Handle file duplicates
      if (keepDuplicate) {
        int count = 1;
        while (await File(filePath).exists()) {
          filePath = '${appDir.path}/${_renameFile(fileName, count)}';
          count++;
        }
      } else {
        if (await File(filePath).exists()) {
          await File(filePath).delete();
        }
      }

      /// Save the file
      File file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  String _renameFile(String name, int count) {
    String extension = name.split('.').last;
    String ogName = name.split(".").first;
    return '${ogName}_$count.$extension';
  }
}
