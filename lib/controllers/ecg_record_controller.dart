import 'package:fmecg_mobile/constants/api_constant.dart';
import 'package:fmecg_mobile/providers/ecg_provider.dart';
import 'package:fmecg_mobile/utils/files_management.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

ECGProvider ecgProvider = Utils.globalContext!.read<ECGProvider>();

class ECGRecordController {
  static Future<void> uploadFileToDB(Map fileUploadInformation) async {
    final url = apiConstant.apiUrl + 'api/record';

    final String filePath = fileUploadInformation["file_path"];
    final MultipartFile fileData = await MultipartFile.fromFile(
      filePath,
      filename: filePath.split('/').last,
      contentType: MediaType('text', 'csv'),
    );
    FormData fileToUpload = FormData.fromMap({...fileUploadInformation, "file": fileData});
    try {
      final response = await Dio().post(url, data: fileToUpload);
    } catch (e, t) {
      // save filePath to preferences
      print('error when upload file: $e $t');
    }
  }

  static Future<void> getAllECGRecords(int userId) async {
    try {
      final String url = apiConstant.apiUrl + 'ecg-records/patient/$userId';
      final Response response = await Dio().get(url);

      final responseData = response.data;
      if (responseData["status"] == "success") {
        List ecgRecordsPreview = responseData["data"];
        ecgProvider.setECGRecordsPreview(ecgRecordsPreview);
      }
    } catch (e) {
      print('error when get all records: $e');
    }
  }

  static Future<void> getDataECGRecordById(int recordId) async {
    try {
      final String url = apiConstant.apiUrl + 'ecg-records/record-data/$recordId';

      final Response response = await Dio().get(url);
      final responseData = response.data;
      if (responseData["status"] == "success") {
        List ecgRecordData = responseData["data"];
        ecgProvider.setECGRecordDataSelected(ecgRecordData);
      }
    } catch (e) {
      print('error when get all records: $e');
    }
  }
}
