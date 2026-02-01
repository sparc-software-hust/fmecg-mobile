import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fmecg_mobile/repositories/ecg_records_repository.dart';
import 'package:fmecg_mobile/config/env_config.dart';
import 'package:fmecg_api/fmecg_api.dart';

/// Provider for managing ECG record uploads and retrievals
class EcgRecordsProvider extends ChangeNotifier {
  final EcgRecordsRepository _repository;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  Record? _lastUploadedRecord;

  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  Record? get lastUploadedRecord => _lastUploadedRecord;

  EcgRecordsProvider({String? baseUrl}) : _repository = EcgRecordsRepository(apiUrl: baseUrl ?? EnvConfig.apiBaseUrl);

  /// Upload an ECG recording file to the server
  ///
  /// Returns true if upload was successful, false otherwise
  Future<bool> uploadRecording({required File file, Map<String, dynamic>? metadata}) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final record = await _repository.uploadRecording(
        file: file,
        metadata: metadata,
        onUploadProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );

      _lastUploadedRecord = record;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get a record's file content by ID
  Future<RecordFileResponse?> getRecordFile(int recordId) async {
    try {
      return await _repository.getRecordFile(recordId);
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Check if the server is reachable
  Future<bool> checkServerConnection() async {
    try {
      return await _repository.checkServerConnection();
    } catch (e) {
      _errorMessage = "Failed to connect to server";
      notifyListeners();
      return false;
    }
  }

  /// Clear the error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset the provider state
  void reset() {
    _isUploading = false;
    _uploadProgress = 0.0;
    _errorMessage = null;
    _lastUploadedRecord = null;
    notifyListeners();
  }

  String _formatErrorMessage(dynamic error) {
    final errorStr = error.toString();

    // Extract meaningful error messages
    if (errorStr.contains('File too large')) {
      return 'File is too large to upload';
    } else if (errorStr.contains('Invalid file format')) {
      return 'Invalid file format or metadata';
    } else if (errorStr.contains('Server error')) {
      return 'Server error. Please try again later';
    } else if (errorStr.contains('Record not found')) {
      return 'Record not found';
    } else if (errorStr.contains('SocketException') || errorStr.contains('Connection')) {
      return 'Cannot connect to server. Please check your internet connection';
    } else {
      return 'An error occurred: $errorStr';
    }
  }
}
