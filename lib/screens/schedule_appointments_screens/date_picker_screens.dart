import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class Doctor {
  final String id;
  final String accountId;
  final String username;
  final int gender;
  final int birth;
  final String phoneNumber;
  final String? image;
  final int statusId;
  final String information;
  final int roleId;

  Doctor({
    required this.id,
    required this.accountId,
    required this.username,
    required this.gender,
    required this.birth,
    required this.phoneNumber,
    this.image,
    required this.statusId,
    required this.information,
    required this.roleId,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      username: json['username'] as String,
      gender: json['gender'] as int,
      birth: json['birth'] as int,
      phoneNumber: json['phone_number'] as String,
      image: json['image'] as String?,
      statusId: json['status_id'] as int,
      information: json['information'] as String,
      roleId: json['role_id'] as int,
    );
  }
}

class DatePicker extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorDescription;
  final String type;
  const DatePicker(
      {super.key,
      required this.doctorId,
      required this.doctorName,
      required this.doctorDescription,
      required this.type});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

const accessToken =
    "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50SWQiOiI5ZGMzOGQ4OS01NWQxLTRkNDEtOGJmYi1jODg1YmM2ZmYwYmUiLCJyb2xlIjoxLCJpYXQiOjE3MzI4NjAwNzMsImV4cCI6MTczNTQ1MjA3M30.CnGWoUP_5yNkT9sYyaSa2Yc8Ksg-J3isVn_5K_3rMgV-Su2FZ5d55ff_lLEYSQHuCKuPcnMVDoWWK_T1HcRzs8IydskEczUlD2IlB_1j9kIr5aH7IHGOYR0sX-vzOptz1sDkeG8juAglOJ2yFWlLT_DbgDiK4hOE5t5GsS8Nu2f7uE6GhhASKB9g-g7bBRCqLgdR5wsvPEEZAa3lhDZTLMykoiWdTxrR3vFJRgMn7TpHD6HSPTpH_myw1CJfvhWrnvokpcoszeHKabF0VbEqqjtRA8tKNwNVMEsIkHzIpfN_51-8Zx10Y6ti-Z_O349eMO2GylSL6RZfNJuw7XDUXQ";

class _DatePickerState extends State<DatePicker> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late Future<List> _busyDay = Future.value([]);

  void initState() {
    super.initState();
    _busyDay = fetcherDate();
  }

  Future<List<Map<String, dynamic>>> fetcherDate() async {
    try {
      final url = Uri.parse(
          'http://192.168.100.71:3000/schedules/doctor-id/${widget.doctorId}');

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print("Request successful");
        List<dynamic> jsonData = json.decode(response.body);
        List<Map<String, dynamic>> formattedData =
            jsonData.map((item) => item as Map<String, dynamic>).toList();
        return formattedData;
      } else {
        print("Request failed with status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching busy dates: $e");
      return [];
    }
  }

  Future _sendTimePicker(
      BigInt selectedTime, String doctorName, String doctorId) async {
    final url = Uri.parse("http://192.168.100.71:3000/schedules/create/doctor");
    final DateTime startDateTime =
        DateTime.fromMillisecondsSinceEpoch(selectedTime.toInt() * 1000);

    final DateTime endDateTime = startDateTime.add(const Duration(minutes: 30));

    final BigInt endTime =
        BigInt.from(endDateTime.millisecondsSinceEpoch ~/ 1000);

    final body = {
      "doctor_id": widget.doctorId == '' ? doctorId : widget.doctorId,
      "schedule_start_time": selectedTime.toString(),
      "schedule_end_time": endTime.toString(),
      "schedule_type_id": 1,
    };
    print(body);
    try {
      final response = await http.post(url,
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
          body: jsonEncode(body));
      if (response.statusCode == 201) {
        _showSuccess(true);
      } else {
        print("Lỗi khi gửi lịch hẹn: ${response.statusCode}, ${response.body}");
        _showSuccess(false);
      }
    } catch (e) {
      throw Exception('Failed to post schedule: $e');
    }
  }

  void _showTimePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return TimePickerModal(
          selectedDate: _selectedDay,
          onTimeSelected: (selectedTime) {
            final DateTime combinedDateTime = DateTime(
              _selectedDay.year,
              _selectedDay.month,
              _selectedDay.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            final int scheduleTime =
                combinedDateTime.millisecondsSinceEpoch ~/ 1000;
            if (widget.type == '1') {
              Future.delayed(const Duration(milliseconds: 100), () {
                _confirmTime(BigInt.from(scheduleTime), widget.doctorName,
                    widget.doctorId);
              });
            } else {
              Future.delayed(const Duration(milliseconds: 100), () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return DoctorPickerModal(
                      scheduleTime: BigInt.from(scheduleTime),
                      onDoctorSelected: _confirmTime,
                    );
                  },
                );
              });
            }
          },
          type: widget.type,
          busyDate: _busyDay,
        );
      },
    );
  }

  void _confirmTime(
      final BigInt selectedTime, String doctorName, String doctorId) async {
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(selectedTime.toInt() * 1000);

    final String formattedTime =
        "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} - ${dateTime.day}-${dateTime.month}-${dateTime.year}";

    print("Selected time: $formattedTime");

    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Xác nhận đặt lịch'),
            content: Text(
                "Bạn có chắc chắn muốn đặt lịch vào $formattedTime với bác sĩ $doctorName?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Hủy"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Đồng ý"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendTimePicker(selectedTime, doctorName, doctorId);
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _showSuccess(bool isSuccess) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isSuccess ? 'Thành công' : 'Thất bại'),
            content: Text(
              isSuccess
                  ? 'Lịch hẹn của bạn đã được đặt thành công!'
                  : 'Đã xảy ra lỗi khi đặt lịch. Vui lòng thử lại.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Date picker',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              if (selectedDay
                  .isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
                _showTimePicker();
              }
            },
            calendarStyle: const CalendarStyle(
                selectedDecoration:
                    BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                    color: Colors.blueAccent, shape: BoxShape.circle)),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronVisible: false,
              rightChevronVisible: false,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        if (widget.type == '1')
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage('assets/images/doctor_image.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.doctorDescription,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Please select the date you want to set',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ]),
    );
  }
}

class TimePickerModal extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(TimeOfDay) onTimeSelected;
  final Future<List> busyDate;
  final String type;

  const TimePickerModal({
    Key? key,
    required this.selectedDate,
    required this.onTimeSelected,
    required this.busyDate,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Select a time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: FutureBuilder<List>(
            future: busyDate,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("${snapshot.error}"),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return ListView.builder(
                  itemCount: 21,
                  itemBuilder: (context, index) {
                    final hour = 8 + index ~/ 2;
                    final minute = (index % 2) * 30;
                    final time = TimeOfDay(hour: hour, minute: minute);
                    return ListTile(
                      title: Center(
                        child: Text(time.format(context)),
                      ),
                      onTap: () {
                        onTimeSelected(time);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              } else {
                // If we have busy dates, check against them
                List busyHours = snapshot.data!;
                return ListView.builder(
                  itemCount: 21,
                  itemBuilder: (context, index) {
                    final hour = 8 + index ~/ 2;
                    final minute = (index % 2) * 30;
                    final time = TimeOfDay(hour: hour, minute: minute);
                    final timeDate = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                hour,
                                minute)
                            .millisecondsSinceEpoch ~/
                        1000;
                    final isBusy = busyHours
                        .any((item) => item['schedule_start_time'] == timeDate);
                    return ListTile(
                      title: Center(
                        child: Text(
                          time.format(context),
                          style: TextStyle(
                            color: isBusy ? Colors.red : Colors.black,
                          ),
                        ),
                      ),
                      onTap: isBusy
                          ? null
                          : () {
                              onTimeSelected(time);
                              Navigator.pop(context);
                            },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class DoctorPickerModal extends StatelessWidget {
  final BigInt scheduleTime;
  final void Function(BigInt scheduleTime, String doctorName, String doctorId)
      onDoctorSelected;
  const DoctorPickerModal(
      {Key? key, required this.scheduleTime, required this.onDoctorSelected})
      : super(key: key);

  Future<List<Doctor>> fetcherDoctor() async {
    print(scheduleTime);
    try {
      final url = Uri.parse(
          'http://192.168.100.71:3000/schedules/time/available-doctor/$scheduleTime');
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print("Request successful");
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => Doctor.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print("Request failed with status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load doctor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Select a Doctor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Doctor>>(
        future: fetcherDoctor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No doctors available"));
          } else {
            List<Doctor> doctors = snapshot.data!;

            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return ListTile(
                  leading: const CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        AssetImage('assets/images/doctor_image.png'),
                  ),
                  title: Text(doctor.username),
                  subtitle: Text(doctor.information),
                  onTap: () {
                    onDoctorSelected(scheduleTime, doctor.username, doctor.id);
                    // Navigator.pop(context);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
