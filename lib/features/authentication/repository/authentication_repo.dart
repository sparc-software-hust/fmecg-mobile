import 'dart:convert';

import 'package:fmecg_mobile/constants/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<Map?> loginUser(String email, String password) async {
    String url = apiConstant.apiUrl + '/auth/login';
    final bodyEncoded = jsonEncode({"email": email, "password": password});
    try {
      final response = await http.post(Uri.parse(url),
          headers: apiConstant.headers, body: bodyEncoded);
      final Map responseData = jsonDecode(response.body);
      return responseData;
    } catch (err) {
      debugPrint('error from login: $err');
      return null;
    }
  }

  Future<Map?> registerUser(String email, String password) async {
    String url = apiConstant.apiUrl + '/auth/register';
    final bodyEncoded = jsonEncode({"email": email, "password": password});
    try {
      final response = await http.post(Uri.parse(url),
          headers: apiConstant.headers, body: bodyEncoded);
      final Map responseData = jsonDecode(response.body);
      return responseData;
    } catch (err) {
      debugPrint('error from register: $err');
      return null;
    }
  }
}
