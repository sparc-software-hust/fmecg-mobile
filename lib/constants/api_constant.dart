import 'package:fmecg_mobile/certs/secrets.dart';
import 'package:flutter/foundation.dart';

class APIConstant {
  static APIConstant instance = APIConstant._privateConstructor();
  APIConstant._privateConstructor();
  factory APIConstant() => instance;

  String apiUrl = "";
  String socketUrl = "";
  Map<String, String> headers = <String, String>{'Content-Type': 'application/json;charset=UTF-8'};

  getMode() {
    if (kDebugMode || kProfileMode) {
      // const String hostNormal = "192.168.1.200";
      const String hostNormal = Secrets.apiUrlProduction;
      // const String hostNormal = "192.168.1.200";
      apiUrl = "http://$hostNormal/api";
      socketUrl = 'ws://$hostNormal:80/socket/websocket';
    } else {
      const String hostNormal = Secrets.apiUrlProduction;
      // const String hostNormal = "192.168.1.200";
      apiUrl = "http://$hostNormal/api";
      socketUrl = 'ws://$hostNormal:80/socket/websocket';
    }
  }

  void addValueHeader(Map<String, String> item) {
    headers.addAll(item);
  }

  Map<String, String> getHeadersWithAuth(String token) {
    return {...headers, 'Authorization': 'Bearer $token'};
  }
}

final APIConstant apiConstant = APIConstant.instance;
