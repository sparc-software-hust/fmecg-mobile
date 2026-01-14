import 'dart:io';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:fmecg_mobile/utils/platform_file_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class to manage file operations for saving ECG data.
/// Uses PlatformFileSaver to abstract platform-specific paths.
class FilesManagement {
  static Future<String> get _pathToSaveData async {
    final baseDirectory = await PlatformFileSaver.getStorageDirectory();
    final directoryToSaveData = '$baseDirectory/records';
    return directoryToSaveData;
  }

  static Future<void> createDirectoryFirstTimeWithDevice() async {
    final directoryPath = await _pathToSaveData;
    Directory(directoryPath).createSync(recursive: true);
  }

  static Future<File> setUpFileToSaveDataMeasurement() async {
    final directoryPath = await _pathToSaveData;
    final String fileNameAsTimestamp = Utils.getCurrentTimestamp().toString();
    return File('$directoryPath/$fileNameAsTimestamp.csv');
  }

  static Future<File> setUpFileSaveTxt() async {
    final directoryPath = await _pathToSaveData;
    final String fileNameAsTimestamp = Utils.getCurrentTimestamp().toString();
    return File('$directoryPath/pcg_ppg_$fileNameAsTimestamp.txt');
  }

  static void appendDataToFile(File file, List<dynamic> row) {
    String data = row.join(",");
    data = "$data\n";
    file.writeAsStringSync(data, mode: FileMode.append);
  }

  static Future<void> handleSaveDataToFileV2(File file, List rawData, {String format = "csv"}) async {
    String dataConverted = format == "txt" 
        ? rawData.join("\n") 
        : rawData.join("\n").replaceAll(RegExp(r'\[|\]'), "");
    print('1233333333:$dataConverted');
    await file.writeAsString(dataConverted, mode: FileMode.append);
  }

  static void saveFilePathCaseNoInternet(String filePath) async {
    const String keyToSave = "files_not_upload";
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String existingFilePath;

    if (preferences.containsKey(keyToSave)) {
      existingFilePath = preferences.getString(keyToSave)!;
      existingFilePath = '$existingFilePath\n$filePath';
      preferences.setString(keyToSave, existingFilePath);
    } else {
      existingFilePath = filePath;
      preferences.setString(keyToSave, existingFilePath);
    }
  }

  static Future<void> deleteFileRecord(File file) async {
    await file.delete();
  }
}
