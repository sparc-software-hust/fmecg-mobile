import 'package:fmecg_mobile/controllers/ecg_record_controller.dart';
import 'package:fmecg_mobile/providers/ecg_provider.dart';
import 'package:fmecg_mobile/screens/history_screens/history_record_chart.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // getAllRecords();
  }

  void getAllRecords() async {
    final int userId = await Utils.getUserId(); 
    ECGRecordController.getAllECGRecords(userId);
  }

  @override
  Widget build(BuildContext context) {
    final List allECGRecordsPreview = context.watch<ECGProvider>().ecgRecordsPreview;

      return Scaffold(
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (allECGRecordsPreview.isNotEmpty)
            Expanded(
              // child: ListView(
              //   padding: EdgeInsets.all(16),
              //   children: [
              //     buildHistoryCard(1, 'Input Text', '2023-06-27'),
              //     SizedBox(height: 16),
              //     buildHistoryCard(2, 'Input Text', '2023-06-26'),
              //     SizedBox(height: 16),
              //     buildHistoryCard(3, 'Input Text', '2023-06-25'),
              //     SizedBox(height: 16),
              //     buildHistoryCard(4, 'Input Text', '2023-06-24'),
              //     SizedBox(height: 16),
              //     buildHistoryCard(5, 'Input Text', '2023-06-23'),
              //     SizedBox(height: 16),
              //     // buildLastRectangle(),
              //   ],
              // ),
              child: ListView.builder(
                itemCount: allECGRecordsPreview.length,
                itemBuilder: (contextECGRecords, index) {
                  final int recordId = allECGRecordsPreview[index]["record_id"];
                  final String recordName = allECGRecordsPreview[index]["data_directory"]
                                            .split("/").last.split('.').first;
                  final DateTime recordCreatedAt = DateTime.parse(allECGRecordsPreview[index]["created_at"]);
                  final String recordCreatedFormat = DateFormat("EEEE, dd-MM-yyyy", "vi").format(recordCreatedAt);

                  return buildHistoryCard(recordId, recordName, recordCreatedFormat);
                },
              ),
            ),
          ],
        ),
    );
  }

  Widget buildHistoryCard(int recordId, String inputText, String date) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => HistoryRecordChart(recordId: recordId),
          )
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_border,
                  color: Color.fromARGB(255, 57, 5, 243),
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$inputText $recordId',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '$recordId BPM',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLastRectangle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}