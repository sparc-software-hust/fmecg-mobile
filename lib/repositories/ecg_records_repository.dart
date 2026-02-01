import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fmecg_api/fmecg_api.dart';
import 'package:built_value/json_object.dart';
import 'package:fmecg_mobile/config/env_config.dart';

/// Repository for managing ECG records via the API
class EcgRecordsRepository {
  final FmecgApi _api;

  EcgRecordsRepository({String? apiUrl}) : _api = FmecgApi(basePathOverride: apiUrl ?? EnvConfig.apiUrl);

  /// Upload an ECG recording file to the server
  ///
  /// [file] - The CSV file containing ECG data
  /// [metadata] - Optional metadata to attach (e.g., {"patient_id": "123", "device_id": "abc"})
  ///
  /// Returns the created Record on success
  /// Throws DioException on failure
  Future<Record?> uploadRecording({
    required File file,
    Map<String, dynamic>? metadata,
    ProgressCallback? onUploadProgress,
  }) async {
    try {
      // Create multipart file from the CSV file
      final multipartFile = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);

      // Convert metadata to JsonObject if provided
      JsonObject? jsonMetadata;
      if (metadata != null) {
        jsonMetadata = JsonObject(metadata);
      }

      // Call the API
      final response = await _api.getRecordsApi().fmecgWebRecordControllerCreate(
        file: multipartFile,
        metadata: jsonMetadata,
        onSendProgress: onUploadProgress,
      );

      return response.data?.data;
    } on DioException catch (e) {
      // Handle specific error cases
      if (e.response?.statusCode == 413) {
        throw Exception('File too large');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid file format or metadata');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      }
      rethrow;
    }
  }

  /// Get a record's file content by ID
  ///
  /// [recordId] - The ID of the record to retrieve
  ///
  /// Returns the file data as RecordFileResponse
  /// Throws DioException on failure
  Future<RecordFileResponse?> getRecordFile(int recordId) async {
    try {
      final response = await _api.getRecordsApi().fmecgWebRecordControllerShow(id: recordId);

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Record not found');
      }
      rethrow;
    }
  }
}
