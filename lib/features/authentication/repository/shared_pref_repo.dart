import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreprerencesRepo {
  static const keyData = 'user_data';

  static Future<String> getDataUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyData) ?? "";
  }

  static Future<bool> checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(keyData);
    final bool hasLoggedIn = data != "" && data != null;
    return hasLoggedIn;
  }

  static void setDataUser(Map dataLogin) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String userData = json.encode(dataLogin);
    preferences.setString(keyData, userData);
  }

  static void removeDataUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(keyData);
  }
}
