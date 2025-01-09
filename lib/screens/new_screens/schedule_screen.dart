import 'package:fmecg_mobile/screens/schedule_appointments_screens/schedule_appointments.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; // Import the intl package

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedCategory = "Upcoming";
  DateTime _selectedDate = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday - 1;

  Future _fetcherSchedule() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My appointments',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.regular.plus,
                ),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      //isScrollControlled: true,
                      builder: (BuildContext context) {
                        return const ScheduleAppointmentScreen();
                      });
                },
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategorySection('Upcoming'),
                  const SizedBox(width: 20),
                  _buildCategorySection('Completed'),
                  const SizedBox(width: 20),
                  _buildCategorySection('Canceled')
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    DateTime currentDate = DateTime.now()
                        .add(Duration(days: index - _selectedDayIndex));
                    String dayLabel = DateFormat('E').format(currentDate);
                    String dateLabel = DateFormat('d').format(currentDate);
                    return _buildDayButton(dayLabel, dateLabel, currentDate);
                  },
                ),
              ),
              _buildAppointmentSection("Today", "Yarn Gerberg", "Cardiologist",
                  "August 4", "9:45 AM")
            ],
          ),
        ));
  }

  Widget _buildCategorySection(String category) {
    bool isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Text(category,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isSelected ? Colors.black : Colors.grey)),
    );
  }

  Widget _buildDayButton(String day, String date, DateTime dateTime) {
    bool isSelected = _selectedDate.year == dateTime.year &&
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue[700] : Colors.black,
              ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentSection(String day, String name,
      String specialization, String date, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 10),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        AssetImage('assets/images/doctor_image.png'),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 1, child: Text("Edit")),
                                const PopupMenuItem(
                                    value: 2, child: Text("Delete")),
                              ],
                              child: const Icon(Icons.more_vert),
                            )
                          ],
                        ),
                        Text(specialization,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 117, 117, 117))),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 5),
                            Text(date),
                            const SizedBox(width: 15),
                            Icon(Icons.access_time,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 5),
                            Text(time),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle Urgent Message action
              },
              child: const Text("Urgent message"),
            ),
          ),
        ],
      ),
    );
  }
}
