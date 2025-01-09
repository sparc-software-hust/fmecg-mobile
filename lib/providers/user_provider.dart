import 'package:fmecg_mobile/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User? user;
  bool isPatient = true;

  void setDataUser(Map data) {
    user = User.fromJson(data);
    print('gdgndfjkg:${user?.gender}');
    notifyListeners();
  }
}

