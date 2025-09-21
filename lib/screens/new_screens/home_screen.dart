import 'dart:io';

import 'package:fmecg_mobile/components/live_chart.dart';
import 'package:fmecg_mobile/providers/user_provider.dart';
import 'package:fmecg_mobile/screens/bluetooth_screens/ble_chart_test.dart';
import 'package:fmecg_mobile/screens/bluetooth_screens/ble_screen.dart';
import 'package:fmecg_mobile/providers/auth_provider.dart';
import 'package:fmecg_mobile/screens/new_screens/circular_indicator_home.dart';
import 'package:fmecg_mobile/screens/new_screens/progress_home.dart';
import 'package:fmecg_mobile/screens/notification_screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class NewHomeScreen extends StatelessWidget {
  const NewHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final token = authProvider.token;
    print('token:$token');
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
                              'Hey, ${userProvider.user?.fullName.split(' ').first}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: PhosphorIcon(PhosphorIcons.regular.chatCircleDots, color: Colors.white),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                                    );
                                  },
                                  icon: PhosphorIcon(PhosphorIcons.regular.bell, color: Colors.white),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Have a refreshing evening!', style: TextStyle(color: Colors.grey[300], fontSize: 16)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, spreadRadius: 1)],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('0-daily streak', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 10, spreadRadius: 1),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: PhosphorIcon(PhosphorIcons.regular.smiley, color: Colors.white, size: 30),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chat with DIA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Personal AI assistant',
                                        style: TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Plus', style: TextStyle(color: Colors.blue)),
                                    SizedBox(width: 8),
                                    Icon(Icons.add, color: Colors.blue),
                                  ],
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
                          tabs: [Tab(text: 'Calories'), Tab(text: 'Measurement history')],
                        ),
                        SizedBox(
                          height: 700,
                          child: TabBarView(children: [_buildCaloriesSection(), _buildMeasureHistory()]),
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

  Widget _buildMeasureHistory() {
    return const Column(children: [SizedBox(height: 20)]);
  }

  Widget _buildCaloriesSection() {
    final ecgData = [
      {"label": "Lead I", "value": "1.0 mV"},
      {"label": "Lead II", "value": "0.8 mV"},
      {"label": "Lead III", "value": "1.2 mV"},
      {"label": "aVR", "value": "0.9 mV"},
      {"label": "aVL", "value": "1.1 mV"},
      {"label": "aVF", "value": "1.0 mV"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Overall Health", style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Good", style: TextStyle(fontSize: 28, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Last update: 5 min ago", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: ecgData.length,
            itemBuilder: (context, index) {
              final data = ecgData[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, spreadRadius: 1)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data["label"]!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data["value"]!,
                          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Icon(Icons.favorite, size: 24, color: Colors.blue),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
