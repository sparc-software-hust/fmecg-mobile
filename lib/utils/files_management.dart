import 'dart:io';
import 'package:fmecg_mobile/utils/platform_file_saver.dart';
import 'package:intl/intl.dart';

/// Class to manage file operations for saving ECG data.
/// Uses PlatformFileSaver to abstract platform-specific paths.
class FilesManagement {
  static Future<String> get _pathToSaveData async {
    final baseDirectory = await PlatformFileSaver.getStorageDirectory();
    final directoryToSaveData = '$baseDirectory/records';

    final isExists = await Directory(directoryToSaveData).exists();
    if (!isExists) {
      await Directory(directoryToSaveData).create(recursive: true);
    }
    return directoryToSaveData;
  }

  static Future<File> getFilePath() async {
    final directoryPath = await _pathToSaveData;
    final String fileName = DateFormat('dd-MM-yyyy-H-m-ss').format(DateTime.now());
    return File('$directoryPath/$fileName.csv');
  }
}
