import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Notification {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final int scheduleStartTime;
  final bool isSeen;
  final int type;
  final int status;
  final String createdAt;

  Notification({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.scheduleStartTime,
    required this.isSeen,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      scheduleStartTime: json['schedule_start_time'],
      isSeen: json['is_seen'],
      type: json['type'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}

const accessToken =
    "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50SWQiOiI5ZGMzOGQ4OS01NWQxLTRkNDEtOGJmYi1jODg1YmM2ZmYwYmUiLCJyb2xlIjoxLCJpYXQiOjE3MzI4NjAwNzMsImV4cCI6MTczNTQ1MjA3M30.CnGWoUP_5yNkT9sYyaSa2Yc8Ksg-J3isVn_5K_3rMgV-Su2FZ5d55ff_lLEYSQHuCKuPcnMVDoWWK_T1HcRzs8IydskEczUlD2IlB_1j9kIr5aH7IHGOYR0sX-vzOptz1sDkeG8juAglOJ2yFWlLT_DbgDiK4hOE5t5GsS8Nu2f7uE6GhhASKB9g-g7bBRCqLgdR5wsvPEEZAa3lhDZTLMykoiWdTxrR3vFJRgMn7TpHD6HSPTpH_myw1CJfvhWrnvokpcoszeHKabF0VbEqqjtRA8tKNwNVMEsIkHzIpfN_51-8Zx10Y6ti-Z_O349eMO2GylSL6RZfNJuw7XDUXQ";

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<NotificationScreen> {
  List<Notification> _allNotifications = [];
  List<Notification> _filteredNotifications = [];
  bool isLoading = false;

  Future<List> fetcherNotifications() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.1.72:3000/notification/get'),
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer $accessToken"
          }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          _allNotifications = jsonResponse
              .map((notification) => Notification.fromJson(notification))
              .toList();
          _filteredNotifications = _allNotifications;
          isLoading = false;
        });
        return _filteredNotifications;
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load notifications: $e');
    }
  }

  void initState() {
    super.initState();
    fetcherNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _filteredNotifications.isEmpty
              ? const Center(
                  child: Text(
                    'Không có thông báo nào.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = _filteredNotifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          notification.status == 1
                              ? Icons.notifications
                              : Icons.notifications_active,
                          color: notification.status == 1
                              ? Colors.green
                              : notification.status == 2
                                  ? Colors.blueAccent
                                  : Colors.red,
                        ),
                        title: Text(
                          'Loại: ${notification.type}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bệnh nhân: ${notification.patientName}'),
                            Text('Bác sĩ: ${notification.doctorName}'),
                            Text(
                              'Thời gian: ${DateTime.fromMillisecondsSinceEpoch(notification.scheduleStartTime * 1000)}',
                            ),
                            Text(
                              notification.type == 0
                                  ? 'Description: Bạn đã đặt lịch với bác sĩ vào ngày: ${DateTime.fromMillisecondsSinceEpoch(notification.scheduleStartTime * 1000)}'
                                  : notification.status == 1
                                      ? 'Description: Bác sĩ đã chấp nhận yêu cầu.'
                                      : notification.status == 3
                                          ? 'Description: Bác sĩ đã từ chối yêu cầu.'
                                          : 'Description: Bác sĩ đã đặt lịch cho bạn vào ngày: ${DateTime.fromMillisecondsSinceEpoch(notification.scheduleStartTime * 1000)}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          notification.status == 1
                              ? Icons.check_circle
                              : Icons.circle,
                          color: notification.status == 1
                              ? Colors.green
                              : notification.status == 3
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                        onTap: () {
                          // setState(() {
                          //   notification.isSeen = true;
                          // });
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
