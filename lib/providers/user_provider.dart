import 'dart:convert';

import 'package:fmecg_mobile/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  User? user;
  bool isPatient = true;

  void setDataUser(Map data) async {
    user = User.fromJson(data);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userInfo', jsonEncode(data));
    //print('gdgndfjkg:${user}');
    notifyListeners();
  }
}
