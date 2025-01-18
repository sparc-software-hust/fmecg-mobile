// auth provider

import 'dart:convert';

import 'package:fmecg_mobile/constants/api_constant.dart';
import 'package:fmecg_mobile/networks/http_dio.dart';
import 'package:fmecg_mobile/providers/user_provider.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { dark, light }

UserProvider userProvider =
    Provider.of<UserProvider>(Utils.globalContext!, listen: false);

class AuthProvider extends ChangeNotifier {
  String _accessToken = "";
  String _refreshToken = "";
  Map<String, dynamic>? _userInfo;
  final String _firebaseToken = "";
  DateTime? _expiryDate;
  final int _userId = 0;
  int _roleId = -1;
  String _locale = 'en';
  bool _isDarkTheme = false;
  bool _isAutoTheme = false;

  String _email = "";

  String get email => _email;

  String get locale => _locale;
  int get userId => _userId;
  int get roleId => _roleId;

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _accessToken != "") {
      return _accessToken;
    } else {
      return "";
    }
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    print("${email}, ${password}");
    try {
      final url = Uri.parse("http://103.200.20.59:3003/auth/login");
      final response = await http.post(
        url,
        headers: {
          "Content-type": "application/x-www-form-urlencoded",
        },
        body: {
          "email": email,
          "password": password,
        },
      );
      //.timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        print("response: ${response.body}");
        final responseData = json.decode(response.body);
        _email = email;
        _accessToken = responseData['access_token'];
        _refreshToken = responseData['refresh_token'];
        _roleId = responseData['role'];
        _expiryDate =
            DateTime.fromMillisecondsSinceEpoch(responseData['expired_time']);
        print("_accessToken: ${_accessToken}");
        final url = Uri.parse("http://103.200.20.59:3000/users/user-info");
        final responseInfoData = await http.get(url, headers: {
          "Authorization": "Bearer $_accessToken",
          "Content-Type": "application/json",
        });
        if (responseInfoData.statusCode == 200) {
          final responseInfo = json.decode(responseInfoData.body);
          print("responseInfo: $responseInfo");
          _userInfo = responseInfo;
        }
        _saveToPrefs();
        return;
      } else {
        print(
            "Sai tài khoản mật khẩu: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      throw Exception('Failed to log in: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _accessToken);
    await prefs.setString('refresh_token', _refreshToken);
    await prefs.setString('email', _email);
    await prefs.setInt('role', _roleId);
    await prefs.setString('expiryDate', _expiryDate?.toIso8601String() ?? '');
    await prefs.setString('userInfo', json.encode(_userInfo));
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token') ?? '';
    _email = prefs.getString('email') ?? '';
    _roleId = prefs.getInt('roleId') ?? -1;
    _refreshToken = prefs.getString('refresh_token') ?? '';
    final expiryDateString = prefs.getString('expiryDate');
    if (expiryDateString != null && expiryDateString.isNotEmpty) {
      _expiryDate = DateTime.parse(expiryDateString);
    }
    notifyListeners();
  }

  Future<bool> get isAuth async {
    // final isExpiryDate = _roleId != -1 && _token != "";
    // if (!isExpiryDate) {
    //   return false;
    // } else {
    //   return true;
    // }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    _email = preferences.getString("userName") ?? "";

    return (_email != "");
  }

  AuthProvider() {
    _loadFromPrefs();
  }
  // set locale(lc) => setLocale(lc);
  // void setLocale(lc) async {
  //   S.load(Locale(lc));
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   _locale = lc ?? "en";
  //   bool status = await preferences.setString('locale', _locale);

  //   if (status) notifyListeners();
  // }

  ThemeType get theme => _isDarkTheme ? ThemeType.dark : ThemeType.light;
  set theme(ThemeType type) => setTheme(type, false);

  void setTheme(ThemeType type, bool isAuto) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _isDarkTheme = type == ThemeType.dark;
    await preferences.setBool('isAutoTheme', isAuto);
    bool status = await preferences.setBool('isDark', _isDarkTheme);

    if (status) notifyListeners();
  }

  Future<bool> getAutoTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _isAutoTheme = preferences.getBool('isAutoTheme') ?? false;
    return _isAutoTheme;
  }

  Future<ThemeType> getTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var theme = preferences.getBool('isDark');
    _isDarkTheme = theme ?? true;
    return _isDarkTheme ? ThemeType.dark : ThemeType.light;
  }

  bool get isAutoTheme => _isAutoTheme;
  set isAutoTheme(bool isAuto) => setIsAutoTheme(isAuto);

  void setIsAutoTheme(bool isAuto) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _isAutoTheme = isAuto;
    bool status = await preferences.setBool('isAutoTheme', _isAutoTheme);
    await preferences.setBool('isDark', false);

    if (status) notifyListeners();
  }

  Future<String> getLocale() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _locale = preferences.getString('locale') ?? "en";
    return _locale;
  }

  void _checkAndSaveFirebaseToken() async {
    // bool isFirebaseTokenExisted =
    //     await FmECGFirebaseMessage().checkFirebaseTokenExist(_firebaseToken);
    // if (!isFirebaseTokenExisted) {
    //   await FmECGFirebaseMessage().saveTokenToFirestore(_userId, _firebaseToken);
    // }
  }

  Future<void> registerUser(String email, String password) async {
    // call API with email and password
    String url = apiConstant.apiUrl + 'register';
    final bodyEncoded = jsonEncode({"email": email, "password": password});
    try {
      final response = await http.post(Uri.parse(url),
          headers: apiConstant.headers, body: bodyEncoded);
      final responseData = jsonDecode(response.body);
      if (responseData["status"] == "success") {
        // do something with data
        // print('heheh donee:${responseData["token"]}');
      }
    } catch (err) {
      debugPrint('error from register: $err');
    }
  }

  Future<void> logoutUser() async {
    // call API with email and password
    String url = apiConstant.apiUrl + 'logout';
    try {
      // final response = await http.get(
      //   Uri.parse(url),
      //   headers: {...apiConstant.headers, 'Cookie': 'token=$_accessToken'},
      // );
      // final responseData = jsonDecode(response.body);

      // if (responseData["status"] == "success") {
      //   // do something with data
      //   _accessToken = "";
      //   _refreshToken = '';
      //   _accessToken = "";
      //   _email = "";
      //   _roleId = -1;
      //   _expiryDate = null;
      //   final prefs = await SharedPreferences.getInstance();
      //   await prefs.clear();
      //   notifyListeners();
      // }
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      notifyListeners();
    } catch (err) {
      debugPrint('error from logout: $err');
    }
  }
}
