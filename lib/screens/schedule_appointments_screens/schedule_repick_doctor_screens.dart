import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fmecg_mobile/networks/http_dio.dart';
import 'package:intl/intl.dart';

class SchedulePickByDoctor extends StatefulWidget {
  final String patientId;

  const SchedulePickByDoctor({super.key, required this.patientId});

  @override
  State<SchedulePickByDoctor> createState() => _SchedulePickByDoctorState();
}

class _SchedulePickByDoctorState extends State<SchedulePickByDoctor> {
  DateTime? _selectedDate;
  int? _selectedHour;

  final List<int> availableHours = List.generate(11, (index) => 8 + index);

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitSchedule() async {
    if (_selectedDate == null || _selectedHour == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày và giờ')));
      return;
    }

    final DateTime scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedHour!,
    );

    final int scheduleStartTime = (scheduledDateTime.millisecondsSinceEpoch / 1000).round();
    final int scheduleEndTime = scheduleStartTime + 30 * 60;

    final Map<String, dynamic> body = {
      "patient_id": widget.patientId,
      "schedule_start_time": scheduleStartTime,
      "schedule_end_time": scheduleEndTime,
      "schedule_type_id": 1,
    };
    print(body);
    try {
      final response = await dioConfigInterceptor.post('/schedules', data: jsonEncode(body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Thành công'),
              content: const Text('Lịch tái khám đã được tạo thành công.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, scheduledDateTime);
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
              content: Text('Không thể tạo lịch tái khám.\nLỗi: ${response.statusMessage}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Tạo lịch tái khám', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              _selectedDate != null ? 'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}' : 'Chọn ngày',
            ),
            onTap: _pickDate,
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: DropdownButton<int>(
              isExpanded: true,
              value: _selectedHour,
              hint: const Text('Chọn giờ'),
              items:
                  availableHours.map((hour) {
                    return DropdownMenuItem<int>(value: hour, child: Text('$hour:00'));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHour = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _submitSchedule, child: const Text('Xác nhận lịch tái khám')),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Hủy'),
            ),
          ),
        ],
      ),
    );
  }
}
