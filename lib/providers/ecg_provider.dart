import 'package:flutter/material.dart';

class ECGProvider extends ChangeNotifier {
  List ecgRecordsPreview = [];
  List ecgRecordDataSelected = [];
  
  setECGRecordsPreview(List ecgRecordsFromAPI) {
    ecgRecordsPreview = ecgRecordsFromAPI;
    notifyListeners();
  }

  setECGRecordDataSelected(List ecgRecordDataFromAPI) {
    ecgRecordDataSelected = ecgRecordDataFromAPI;
    notifyListeners();
  }
}