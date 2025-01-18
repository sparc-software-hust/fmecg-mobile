import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fmecg_mobile/networks/http_dio.dart';
import 'package:fmecg_mobile/providers/auth_provider.dart';
import 'package:fmecg_mobile/screens/schedule_appointments_screens/date_picker_screens.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late Future<List<Doctor>> _futureDoctors;
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _futureDoctors = fetchDoctors();
  }

  void _openDatePicker(BuildContext context, String doctorId, String doctorName,
      String doctorDescription) {
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DatePicker(
                  doctorId: doctorId,
                  doctorName: doctorName,
                  doctorDescription: doctorDescription,
                  type: '1')));
    } catch (e) {
      print('Error navigating: $e');
    }
  }

  Future<List<Doctor>> fetchDoctors() async {
    final accessToken = Provider.of<AuthProvider>(context, listen: false).token;
    print(accessToken);
    try {
      final response = await dioConfigInterceptor.get('/users/doctors');
      setState(() {
        _allDoctors = (response.data as List)
            .map((doctor) => Doctor.fromJson(doctor as Map<String, dynamic>))
            .toList();
        _filteredDoctors = List.from(_allDoctors);
      });
      return _filteredDoctors;
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to load doctors: $e');
    }
  }

  void _filterDoctors(String searchText) {
    setState(() {
      _searchText = searchText.toLowerCase();
      _filteredDoctors = _allDoctors
          .where(
              (doctor) => doctor.username.toLowerCase().contains(_searchText))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'Search by name',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  )),
              onChanged: (value) {
                _filterDoctors(value);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Doctor>>(
              future: _futureDoctors,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No doctors found'));
                } else {
                  return ListView.builder(
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _filteredDoctors[index];
                      return InkWell(
                        onTap: () => _openDatePicker(context, doctor.id,
                            doctor.username, doctor.information),
                        child: Card(
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
                                  backgroundImage: AssetImage(
                                      'assets/images/doctor_image.png'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor.username,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        doctor.information,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
