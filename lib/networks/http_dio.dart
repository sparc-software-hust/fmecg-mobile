import 'package:fmecg_mobile/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// cách dùng
// đọc docs DIO trước khi sử dụng: https://pub.dev/packages/dio
// đọc thêm bài này để hiểu interceptor: https://viblo.asia/p/dio-flutter-tim-hieu-ve-interceptor-trong-dio-va-trien-khai-co-che-authentication-018J2vzqJYK
// với request cần auth: sử dụng dioConfigInterceptor.post/get/put/delete
// với request không cần auth: sử dụng Dio().post/get/put/delete

final dioConfigInterceptor = Dio()
  ..options.baseUrl = Utils.apiUrl
  ..options.connectTimeout = const Duration(seconds: 8)
  ..options.receiveTimeout = const Duration(seconds: 20)
  ..options.sendTimeout = const Duration(seconds: 15)
  ..interceptors.add(tokenInterceptor);

final Interceptor tokenInterceptor = InterceptorsWrapper(onRequest: (options, handler) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('access_token');
  final String? refreshToken = prefs.getString('refresh_token');
  final String? accessExp = prefs.getString('expiryDate');
  if (accessToken == null || accessExp == null || refreshToken == null) {
    return;
  }

  final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final int expiryTimestamp = int.tryParse(accessExp) ?? 0;

  final bool isExpired = now > expiryTimestamp;
  if (isExpired) {
    final retryDio = Dio()
      ..options.baseUrl = options.baseUrl
      ..options.headers['Authorization'] = "Bearer $refreshToken";
    final Response res = await retryDio.post(
        "http://103.200.20.59:3003/auth/refresh-token",
        data: {"refresh_token": refreshToken});
    if (res.statusCode != 200) {
      // print('false with logout');
      // logout
      // await AuthRepository.logoutNoCredentials();
      await _logout();
      return;
    } else {
      print('ágnsdjkg:${res.data}');
      //await AuthRepository.saveTokenDataIntoPrefs(res.data["data"]);
      final String accessToken = res.data["access_token"];
      await _saveTokenData(res.data);
      options.headers['Authorization'] = "Bearer $accessToken";
    }
  } else {
    options.headers['Authorization'] = "Bearer $accessToken";
  }
  return handler.next(options);
}, onResponse: (response, handler) {
  print('responseee:${response.data}');
  return handler.next(response);
}, onError: (error, handler) {
  print('errorr:${error.response?.data}');
  return handler.next(error);
});

Future<void> _logout() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // Implement navigation to login screen or other logout handling logic here.
}

Future<void> _saveTokenData(Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', data['access_token']);
  await prefs.setString('refresh_token', data['refresh_token']);
  final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final int expiryDate = now + (15 * 60);
  await prefs.setString('expiryDate', expiryDate.toString());
}
