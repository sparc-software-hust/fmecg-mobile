import 'dart:io';

import 'package:fmecg_mobile/components/live_chart.dart';
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
    final token = authProvider.token;
    print('token:$token');
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 310,
            color: const Color(0xFF0067FF),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hey, Safayet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: PhosphorIcon(
                                PhosphorIcons.regular.chatCircleDots,
                                color: Colors.white),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.white.withOpacity(0.2)),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationScreen()));
                            },
                            icon: PhosphorIcon(PhosphorIcons.regular.bell,
                                color: Colors.white),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.white.withOpacity(0.2))),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Have a refreshing evening!',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                    child: const Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('0-daily streak', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1)
                        ]),
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
                              child: PhosphorIcon(
                                PhosphorIcons.regular.smiley,
                                color: Colors.white,
                                size: 30,
                              ),
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
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Plus',
                                style: TextStyle(color: Colors.blue),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.add,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // _buildCaloriesSection(),
                  // const SizedBox(height: 20),
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TabBar(
                          indicatorColor: Colors.blue,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Calories'),
                            Tab(text: 'Measurement history'),
                          ],
                        ),
                        SizedBox(
                          height: 300,
                          child: TabBarView(
                            children: [
                              _buildCombinedSection(),
                              _buildMeasureHistory()
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
        ],
      ),
    );
  }

  Widget _buildCombinedSection() {
    return Column(
      children: [
        _buildCaloriesSection(),
        const SizedBox(height: 20),
        _buildMacronutrientSection(),
      ],
    );
  }

  Widget _buildMeasureHistory() {
    return const Column(
      children: [
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget _buildCaloriesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Today's calories",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text('Need to do playing football!'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: PhosphorIcon(
                              PhosphorIcons.regular.forkKnife,
                              color: Color(0xFF1565C0),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            children: [
                              Text(
                                '366',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(height: 4),
                              Text('Eaten'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: PhosphorIcon(
                              PhosphorIcons.regular.forkKnife,
                              color: Color(0xFF1565C0),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(height: 4),
                              Text('Burned'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 26),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //const SizedBox(height: 20),
              CircularIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const ProgressBar(
              title: 'CARBS',
              value: 14 / 196,
            )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const ProgressBar(
              title: 'PROTEIN',
              value: 112 / 118,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const ProgressBar(
                title: 'FAT',
                value: 29 / 61,
              )),
        ),
      ],
    );
  }

  Widget _buildGlucoseWeightSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Column(
              children: [
                Text('Glucose'),
                SizedBox(height: 8),
                Icon(Icons.show_chart, size: 40),
                SizedBox(height: 8),
                Text('No data'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Column(
              children: [
                Text('Weight'),
                SizedBox(height: 8),
                Text('90 kg',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                SizedBox(height: 4),
                Text('6:59 PM'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
