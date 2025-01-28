import 'package:flutter/material.dart';
import 'package:fmecg_mobile/networks/http_dio.dart';
import 'package:fmecg_mobile/providers/user_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
      startTime: DateTime.fromMillisecondsSinceEpoch(
          json['schedule_start_time'] * 1000),
      endTime:
          DateTime.fromMillisecondsSinceEpoch(json['schedule_end_time'] * 1000),
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

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  List<Schedule> _scheduleList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final doctorId = userProvider.user?.id;

      if (doctorId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await dioConfigInterceptor.get('/schedules/doctor-id');
      final List<dynamic> data = response.data;
      final List<Schedule> schedules =
          data.map((json) => Schedule.fromJson(json)).toList();
      schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      final List<Schedule> nearestSchedules = schedules.take(5).toList();
      setState(() {
        _scheduleList = nearestSchedules;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching schedule: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xFF0067FF),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hello, Dr. ${userProvider.user?.fullName.split(' ').first}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // Open chat with patients
                                  },
                                  icon: PhosphorIcon(
                                    PhosphorIcons.regular.chatCircleDots,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Open notifications
                                  },
                                  icon: PhosphorIcon(
                                    PhosphorIcons.regular.bell,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'You have 3 appointments today!',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pending approvals: 5',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to approvals screen
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'View',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tab Section
                DefaultTabController(
                  length: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TabBar(
                          indicatorColor: Colors.blue,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Appointments'),
                            Tab(text: 'Patients'),
                          ],
                        ),
                        SizedBox(
                          height: 700,
                          child: TabBarView(
                            children: [
                              _buildAppointmentsSection(),
                              _buildPatientsSection(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_scheduleList.isEmpty) {
      return const Center(
        child: Text('No appointments found.'),
      );
    }

    return ListView.builder(
      itemCount: _scheduleList.length,
      itemBuilder: (context, index) {
        final schedule = _scheduleList[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          tileColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            "${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')} - ${schedule.patientName}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Doctor: ${schedule.doctorName}"),
              Text(
                "Date: ${schedule.startTime.day}-${schedule.startTime.month}-${schedule.startTime.year}",
              ),
              Text(
                "Status: ${schedule.statusId == 1 ? "Confirmed" : "Pending"}",
              ),
            ],
          ),
          trailing: Icon(
            schedule.statusId == 1 ? Icons.check_circle : Icons.access_time,
            color: schedule.statusId == 1 ? Colors.green : Colors.orange,
          ),
          onTap: () {
            // Navigate to schedule details
          },
        );
      },
    );
  }

  Widget _buildPatientsSection() {
    if (_scheduleList.isEmpty) {
      return const Center(
        child: Text('No patients found.'),
      );
    }

    final patients = _scheduleList
        .map((schedule) => {
              "name": schedule.patientName.toString(),
              "lastCheck": schedule.startTime
            })
        .toSet()
        .toList();

    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          tileColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            patient["name"] as String,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // subtitle: Text(
          //   "Last check-up: ${patient["lastCheck"].day}-${patient["lastCheck"].month}-${patient["lastCheck"].year}",
          // ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
          onTap: () {
            // Navigate to patient details
          },
        );
      },
    );
  }
}
