import 'dart:convert';

import 'package:fmecg_mobile/networks/http_dio.dart';
import 'package:fmecg_mobile/providers/auth_provider.dart';
import 'package:fmecg_mobile/providers/user_provider.dart';
import 'package:fmecg_mobile/screens/login_screen/log_in_screen.dart';
import 'package:fmecg_mobile/screens/personal_infor_screens/listView_infor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final class PersonalInfor extends StatefulWidget {
  const PersonalInfor({super.key});

  @override
  State<PersonalInfor> createState() => _PersonalInforState();
}

class _PersonalInforState extends State<PersonalInfor> {
  late TextEditingController fullNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController emailController;
  late TextEditingController informationController;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    fullNameController = TextEditingController(text: userProvider.user?.fullName ?? '');
    phoneNumberController = TextEditingController(text: userProvider.user?.phoneNumber as String ?? '');
    emailController = TextEditingController(text: authProvider.email ?? '');
    informationController = TextEditingController(text: userProvider.user?.information ?? '');

    dateController = TextEditingController(
      text:
          userProvider.user?.birth != null
              ? DateFormat(
                'dd-MM-yyyy',
              ).format(DateTime.fromMillisecondsSinceEpoch(userProvider.user!.birth!.toInt() * 1000))
              : "",
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    informationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin tài khoản', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [Opacity(opacity: 0.5, child: Icon(Icons.account_circle, size: 90))]),
                Column(
                  children: [
                    Opacity(opacity: 0.5, child: Icon(Icons.camera_enhance, size: 30)),
                    const SizedBox(height: 8),
                    const Text('Cài ảnh đại diện', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                  ],
                ),
                Column(
                  children: [
                    Opacity(opacity: 0.5, child: const Icon(Icons.qr_code, size: 30)),
                    const SizedBox(height: 8),
                    const Text('Mã Qr của tôi', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListViewInfo(title: "Họ và tên", description: fullNameController.text, controller: fullNameController),
            ListViewInfo(
              title: "Số điện thoại",
              description: phoneNumberController.text,
              controller: phoneNumberController,
            ),
            ListViewInfo(title: "Email", description: emailController.text, controller: emailController),
            ListViewInfo(
              title: "Information",
              description: informationController.text,
              controller: informationController,
            ),
            ListViewInfo(title: "Birth day", description: dateController.text, controller: dateController),
            const SizedBox(height: 12),
            const Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('Thông tin định danh', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('Chi tiết', style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const ListViewInfo(title: "Trạng thái", description: "Định danh thành công"),
            const Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 20, color: Colors.green),
                  Text(
                    'Bảo mật tuyệt đối mọi thông tin của bạn',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final body = {
                            "username": fullNameController.text,
                            "phone_number": phoneNumberController.text,
                            "information": informationController.text,
                            "birth":
                                dateController.text.isNotEmpty
                                    ? DateFormat('dd-MM-yyyy').parse(dateController.text).millisecondsSinceEpoch ~/ 1000
                                    : null,
                            "gender": userProvider.user?.gender == 'male' ? 1 : 2,
                            "status_id": userProvider.user?.status_id ?? 1,
                            "role_id": userProvider.user?.role,
                            "account_id": userProvider.user?.accountId,
                            "id": userProvider.user?.id,
                          };
                          print("body: $body");
                          final response = await dioConfigInterceptor.put('/users', data: (body));
                          print("response when update login: ${response.statusCode}");
                          if (response.statusCode == 200) {
                            userProvider.setDataUser(body);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Cập nhật thông tin thành công!',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          print("Error when update info user: $e");
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text(
                        'Cập nhật lại định danh',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Gọi hàm logout
                          // await Provider.of<AuthProvider>(context, listen: false).logoutUser();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                              (Route<dynamic> route) => false,
                            );
                          }
                        } catch (e) {
                          // Xử lý lỗi nếu cần
                          debugPrint('Error during logout: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
