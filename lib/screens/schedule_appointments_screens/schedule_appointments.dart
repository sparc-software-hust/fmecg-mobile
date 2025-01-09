import 'package:fmecg_mobile/screens/schedule_appointments_screens/date_picker_screens.dart';
import 'package:fmecg_mobile/screens/schedule_appointments_screens/doctor_list_screens.dart';
import 'package:flutter/material.dart';

class ScheduleAppointmentScreen extends StatelessWidget {
  const ScheduleAppointmentScreen({super.key});

  void _openDoctorList(BuildContext context) {
    try {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const DoctorListScreen()));
      print('Navigated to DoctorListScreen');
    } catch (e) {
      print('Error navigating: $e');
    }
  }

  void _openDatePicker(BuildContext context) {
    print('Date picker tapped');
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const DatePicker(
                  doctorId: '',
                  doctorName: '',
                  doctorDescription: '',
                  type: '2')));
      print('Navigated to DatePicker');
    } catch (e) {
      print('Error navigating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule Appointments',
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Doctor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _openDoctorList(context),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/doctor_image.png'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check Doctor List',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to view the list of available doctors.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _openDatePicker(context),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/schedule_image.png'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to select a date for the appointment.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
