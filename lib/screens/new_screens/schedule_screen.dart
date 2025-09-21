import 'package:fmecg_mobile/controllers/user_controller.dart';
import 'package:fmecg_mobile/networks/http_dio.dart';
import 'package:fmecg_mobile/providers/user_provider.dart';
import 'package:fmecg_mobile/screens/schedule_appointments_screens/schedule_appointments.dart';
import 'package:flutter/material.dart';
import 'package:fmecg_mobile/screens/schedule_appointments_screens/schedule_repick_doctor_screens.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class Schedule {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final DateTime startTime;
  final DateTime endTime;
  final int scheduleTypeId;
  final int statusId;
  final int scheduleResult;

  Schedule({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.startTime,
    required this.endTime,
    required this.scheduleTypeId,
    required this.statusId,
    required this.scheduleResult,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      doctorName: json['doctor_name'],
      startTime: DateTime.fromMillisecondsSinceEpoch(json['schedule_start_time'] * 1000),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['schedule_end_time'] * 1000),
      scheduleTypeId: json['schedule_type_id'],
      statusId: json['status_id'],
      scheduleResult: json['schedule_result'],
    );
  }
  @override
  String toString() {
    return 'Schedule(id: $id, patientId: $patientId, patientName: $patientName, doctorName: $doctorName, startTime: $startTime, endTime: $endTime)';
  }
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedCategory = "Upcoming";
  DateTime _selectedDate = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday - 1;
  List<Schedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.user?.role ?? 1;
    final id = userProvider.user?.id ?? '';

    try {
      final schedules = await _fetchSchedule(id, role);
      setState(() {
        _schedules = schedules;
        print("schedule: ${_schedules[0]}");
      });
    } catch (e) {
      print('Error loading schedules: $e');
    }
  }

  Future<List<Schedule>> _fetchSchedule(String id, int role) async {
    try {
      String api = '';
      if (role == 1)
        api = '/schedules/patient-id';
      else
        api = '/schedules/doctor-id';
      final response = await dioConfigInterceptor.get(api);
      print("response: $response");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Schedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      print("Failed to fetch schedule: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> _fetchPatientInfo(String patientId) async {
    try {
      final response = await dioConfigInterceptor.get('/users/$patientId');
      print(response.statusCode);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch patient info');
      }
    } catch (e) {
      print("Error fetching patient info: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My appointments', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: PhosphorIcon(PhosphorIcons.regular.plus),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  //isScrollControlled: true,
                  builder: (BuildContext context) {
                    return const ScheduleAppointmentScreen();
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategorySection('Upcoming'),
                const SizedBox(width: 20),
                _buildCategorySection('Completed'),
                const SizedBox(width: 20),
                _buildCategorySection('Canceled'),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  DateTime currentDate = DateTime.now().add(Duration(days: index - _selectedDayIndex));
                  String dayLabel = DateFormat('E').format(currentDate);
                  String dateLabel = DateFormat('d').format(currentDate);
                  return _buildDayButton(dayLabel, dateLabel, currentDate);
                },
              ),
            ),
            Builder(
              builder: (context) {
                final filteredSchedules =
                    _schedules.where((schedule) {
                      if (_selectedCategory == 'Upcoming') {
                        return schedule.startTime.isAfter(DateTime.now());
                      } else if (_selectedCategory == 'Completed') {
                        return schedule.startTime.isBefore(DateTime.now());
                      } else {
                        return true;
                      }
                    }).toList();

                if (filteredSchedules.isEmpty) {
                  return Center(
                    child: Text(
                      'Không có lịch nào cả',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                  );
                } else {
                  return Column(
                    children:
                        filteredSchedules.map((schedule) {
                          final startTime = schedule.startTime;
                          final date = "${DateFormat('MMMM d').format(startTime)}";
                          final time = "${DateFormat('h:mm a').format(startTime)}";
                          return _buildAppointmentSection(
                            schedule.id,
                            schedule.patientName,
                            schedule.doctorName,
                            date,
                            time,
                            schedule.patientId,
                          );
                        }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    bool isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Text(
        category,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isSelected ? Colors.black : Colors.grey),
      ),
    );
  }

  Widget _buildDayButton(String day, String date, DateTime dateTime) {
    bool isSelected =
        _selectedDate.year == dateTime.year &&
        _selectedDate.month == dateTime.month &&
        _selectedDate.day == dateTime.day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = dateTime;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 9.0),
        child: Column(
          children: [
            Text(
              day,
              style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.blue[700] : Colors.black),
            ),
            const SizedBox(height: 5),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[700] : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  date,
                  style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentSection(
    String id,
    String name,
    String specialization,
    Object date,
    String time,
    String patientId,
  ) {
    return GestureDetector(
      onTap: () async {
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(child: CircularProgressIndicator());
            },
          );
          final patientInfo = await _fetchPatientInfo(patientId);
          print("patientData: $patientInfo");
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            builder: (BuildContext context) {
              return FractionallySizedBox(heightFactor: 0.4, child: _buildPatientInfoModal(patientInfo, id));
            },
          );
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load patient info')));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/images/doctor_image.png')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              PopupMenuButton(
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(value: 1, child: Text("Edit")),
                                      const PopupMenuItem(value: 2, child: Text("Delete")),
                                    ],
                                child: const Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                          Text(specialization, style: const TextStyle(color: Color.fromARGB(255, 117, 117, 117))),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 5),
                              Text(date as String),
                              const SizedBox(width: 15),
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 5),
                              Text(time),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () {}, child: const Text("Urgent message")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoModal(Map<String, dynamic> patientInfo, String scheduleId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.user?.role ?? 1;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Patient Information', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/images/doctor_image.png')),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${patientInfo['username'] ?? 'N/A'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Age: ${_formatBirthdate(patientInfo['birth']) ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gender: ${patientInfo['gender'] == 1 ? 'Male' : 'Female'}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Phone: ${patientInfo['phone_number'] ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    TextEditingController diagnosisController = TextEditingController();
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(child: CircularProgressIndicator());
                        },
                      );

                      final response = await dioConfigInterceptor.get('/diagnosis/schedule/$scheduleId');
                      Navigator.pop(context);

                      if (response.statusCode == 200) {
                        final diagnosisData = response.data;
                        diagnosisController.text = diagnosisData['information'] ?? '';
                      }
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildDiagnosisPopup(context, diagnosisController, scheduleId, 'update');
                        },
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      diagnosisController.text = '';
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildDiagnosisPopup(context, diagnosisController, scheduleId, 'post');
                        },
                      );
                    }
                  },
                  child: const Text('Chẩn đoán diag'),
                ),
              ),
              const SizedBox(width: 10),
              if (role == 2)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final DateTime? result = await showModalBottomSheet<DateTime>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext context) {
                          return SchedulePickByDoctor(patientId: patientInfo['id']);
                        },
                      );

                      if (result != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Lịch tái khám đã được tạo: $result')));
                      }
                    },
                    child: const Text('Tạo lịch tái khám'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBirthdate(dynamic birthTimestamp) {
    if (birthTimestamp == null) {
      return 'N/A';
    }
    final birthDate = DateTime.fromMillisecondsSinceEpoch(birthTimestamp * 1000);
    return DateFormat('MMMM d, yyyy').format(birthDate);
  }

  Widget _buildDiagnosisPopup(
    BuildContext context,
    TextEditingController diagnosisController,
    String scheduleId,
    String type,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Thông tin chẩn đoán'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chẩn đoán:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                TextField(
                  controller: diagnosisController,
                  maxLines: 3,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Nhập chẩn đoán...'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedDiagnosis = diagnosisController.text;

                if (updatedDiagnosis.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Chẩn đoán không được để trống')));
                  return;
                }

                try {
                  String api = '';
                  if (type == 'update') {
                    api = '/diagnosis/update';
                  } else {
                    api = '/diagnosis';
                  }
                  final updateResponse = await dioConfigInterceptor.post(
                    api,
                    data: jsonEncode({'schedule_id': scheduleId, 'information': updatedDiagnosis}),
                  );

                  if (updateResponse.statusCode == 200 || updateResponse.statusCode == 201) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Thành công'),
                          content: const Text('Cập nhật chẩn đoán thành công.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Lỗi'),
                          content: Text('Không thể cập nhật chẩn đoán.\nLỗi: ${updateResponse.statusMessage}'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
