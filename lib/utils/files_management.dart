import 'dart:io';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesManagement {
  static Future<String> get _pathToSaveData async {
    final directoryToSaveFile = Directory("/storage/self/primary/fm_ECG");
    final directoryToSaveData = directoryToSaveFile.path + '/fmECG_data';
    return directoryToSaveData;
  }

  static Future<void> createDirectoryFirstTimeWithDevice() async {
    final directoryPath = await _pathToSaveData;
    Directory(directoryPath).createSync(recursive: true);
  }

  static setUpFileToSaveDataMeasurement() async {
    final directoryPath = await _pathToSaveData;
    final String fileNameAsTimestamp = Utils.getCurrentTimestamp().toString();
    return File('$directoryPath/$fileNameAsTimestamp.csv');
  }

  static setUpFileSaveTxt() async {
    final directoryPath = await _pathToSaveData;
    final String fileNameAsTimestamp = Utils.getCurrentTimestamp().toString();
    return File('$directoryPath/pcg_ppg_$fileNameAsTimestamp.txt');
  }

  static convertRowToStringBeforeSaving(List<dynamic> row) {
    String dataRow = row.join(",");
    return dataRow;
  }

  static void appendDataToFile(File file, List<dynamic> row) {
    String data = convertRowToStringBeforeSaving(row);
    data = data + "\n"; //xuống dòng khi lưu dữ liệu 1 row
    file.writeAsStringSync(data, mode: FileMode.append);
  }

  static Future<void> handleSaveDataToFileV2(File file, List rawData, {String format = "csv"}) async {
    String dataConverted = format == "txt" ? convertDataToTxtFormat(rawData) : convertDataToCSVFormat(rawData);
    print('1233333333:$dataConverted');
    await appendDataToFileV2(file, dataConverted);
  }

  static String convertDataToCSVFormat(List data) {
    final removingBracketsRegex = RegExp(r'\[|\]');
    String dataConverted = data.join("\n").replaceAll(removingBracketsRegex, "");
    return dataConverted;
  }

  static String convertDataToTxtFormat(List data) {
    String dataConverted = data.join("\n");
    return dataConverted;
  }

  static Future<void> appendDataToFileV2(File file, String dataConverted) async {
    await file.writeAsString(dataConverted, mode: FileMode.append);
  }

  static void saveFilePathCaseNoInternet(String filePath) async {
    const String keyToSave = "files_not_upload";
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String existingFilePath;

    if (preferences.containsKey(keyToSave)) {
      existingFilePath = preferences.getString(keyToSave)!;
      existingFilePath = existingFilePath + '\n$filePath';
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
