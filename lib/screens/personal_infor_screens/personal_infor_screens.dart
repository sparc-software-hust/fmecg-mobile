import 'package:fmecg_mobile/providers/auth_provider.dart';
import 'package:fmecg_mobile/screens/login_screen/log_in_screen.dart';
import 'package:fmecg_mobile/screens/personal_infor_screens/listView_infor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final List<Map<String, String>> listInfo = [
  {"title": "Họ và tên", "description": "Đồng Minh Thái"},
  {"title": "Số điện thoại", "description": "0967827856"},
  {
    "title": "Email",
    "description": "thai.dm279@gmail.com",
  }
];

final class PersonalInfor extends StatelessWidget {
  const PersonalInfor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Thông tin tài khoản',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: Icon(
                          Icons.account_circle,
                          size: 90,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: Icon(
                          Icons.camera_enhance,
                          size: 30,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        'Cài ảnh đại diện',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: const Icon(
                          Icons.qr_code,
                          size: 30,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text('Mã Qr của tôi',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ))
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              ...listInfo.map((item) => ListViewInfo(
                    title: item['title']!,
                    description: item['description']!,
                  )),
              const SizedBox(
                height: 12,
              ),
              const Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Thông tin định danh',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Chi tiết',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              ListViewInfo(
                  title: "Trạng thái", description: "Định danh thành công"),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.security,
                      size: 20,
                      color: Colors.green,
                    ),
                    const Text('Bảo mật tuyệt đối mọi thông tin của bạn',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w200,
                        )),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Cập nhật lại định danh',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            // Gọi hàm logout
                            await Provider.of<AuthProvider>(context,
                                    listen: false)
                                .logoutUser();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const SignInScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          } catch (e) {
                            // Xử lý lỗi nếu cần
                            debugPrint('Error during logout: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
