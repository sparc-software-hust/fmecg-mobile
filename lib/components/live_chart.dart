import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:fmecg_mobile/components/ecg_chart_widget.dart';
import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:fmecg_mobile/controllers/ecg_packet_parser.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveChartSample extends StatefulWidget {
  const LiveChartSample({Key? key, this.fileToSave, this.callBackToPreview}) : super(key: key);
  final File? fileToSave;
  final VoidCallback? callBackToPreview;

  @override
  State<LiveChartSample> createState() => _LiveChartSampleState();
}

class _LiveChartSampleState extends State<LiveChartSample> {
  Timer? dataCollectionTimer;
  Timer? uiUpdateTimer;
  List<List<ChartData>> channelChartData = [];
  List<ChartSeriesController?> chartSeriesControllers = [];
  List<CrosshairBehavior> crosshairBehaviors = [];

  // Buffer for batching data updates
  List<List<ChartData>> pendingDataUpdates = [];

  late int count;
  int numberOfChartsToShow = 2;
  double timeWindowSeconds = 10.0;
  double samplingRateHz = 250.0; // Assuming 250 Hz sampling rate

  List samples = [];
  bool isButtonEndMeasurement = true;
  DateTime? startTime;

  // ECG-style chart colors for different channels
  final List<Color> chartColors = [
    const Color(0xFF00FF41), // Bright green - classic ECG monitor color
    const Color(0xFF00D4FF), // Cyan blue
    const Color(0xFFFF6B35), // Orange red
    const Color(0xFFFFD23F), // Golden yellow
    const Color(0xFFFF3366), // Pink red
    const Color(0xFF9B59B6), // Purple
  ];

  // Channel names
  final List<String> channelNames = ["Channel 1", "Channel 2", "Channel 3", "Channel 4", "Channel 5", "Channel 6"];

  @override
  void initState() {
    super.initState();
    count = 0;
    _initializeChartData();
  }

  @override
  void dispose() {
    super.dispose();
    dataCollectionTimer?.cancel();
    uiUpdateTimer?.cancel();
    _clearChartData();
  }

  void _initializeChartData() {
    channelChartData.clear();
    chartSeriesControllers.clear();
    crosshairBehaviors.clear();
    pendingDataUpdates.clear();

    for (int i = 0; i < 6; i++) {
      channelChartData.add([]);
      chartSeriesControllers.add(null);
      crosshairBehaviors.add(
        CrosshairBehavior(
          enable: true,
          lineType: CrosshairLineType.vertical,
          activationMode: ActivationMode.none,
          lineColor: chartColors[i],
          lineWidth: 2,
        ),
      );
      pendingDataUpdates.add([]);
    }
  }

  _clearChartData({bool cancelTimer = true}) {
    if (cancelTimer) {
      dataCollectionTimer?.cancel();
      uiUpdateTimer?.cancel();
    }

    for (int i = 0; i < channelChartData.length; i++) {
      channelChartData[i].clear();
      if (i < pendingDataUpdates.length) {
        pendingDataUpdates[i].clear();
      }
    }

    samples = [];
    count = 0;
    startTime = null;
    for (int i = 0; i < chartSeriesControllers.length; i++) {
      chartSeriesControllers[i]?.updateDataSource(
        removedDataIndexes: List<int>.generate(channelChartData[i].length, (index) => index),
      );
    }
    setState(() {});
  }

  _startUpdateData() {
    startTime = DateTime.now();
    // Timer 1 (Fast): Runs at 250Hz (every 4ms) and only collects data
    dataCollectionTimer = Timer.periodic(const Duration(milliseconds: 4), _collectDataOnly);
    // Timer 2 (Slower): Runs at 25Hz (every 40ms) and updates the UI with batched data
    uiUpdateTimer = Timer.periodic(const Duration(milliseconds: 40), _updateUI);
  }

  double _getCurrentTimeInSeconds() {
    if (startTime == null) return 0.0;
    return DateTime.now().difference(startTime!).inMilliseconds / 1000.0;
  }

  void _processBluetoothData(List<int> bluetoothPacket) {
    try {
      // Use the ECGPacketParser to process the real Bluetooth data
      List<double> channelDecimalValues = EcgPacketParser.processECGDataPacketFromBluetooth(bluetoothPacket);
      List<double> channelVoltageValues = EcgPacketParser.convertDecimalValuesToVoltageForDisplay(channelDecimalValues);

      // Store the sample data
      samples.add([_getCurrentTimeInSeconds(), ...channelDecimalValues]);

      // Add data to pending updates buffer instead of updating UI directly
      _addDataToPendingBuffer(channelVoltageValues);
    } catch (e) {
      print('Error processing Bluetooth data: $e');
      // Fallback to demo data if there's an error
      _collectDemoData();
    }
  }

  void _addDataToPendingBuffer(List<double> channelVoltageValues) {
    final double currentTime = _getCurrentTimeInSeconds();

    for (
      int channelIndex = 0;
      channelIndex < numberOfChartsToShow && channelIndex < channelVoltageValues.length;
      channelIndex++
    ) {
      ChartData newData = ChartData(currentTime, channelVoltageValues[channelIndex]);
      pendingDataUpdates[channelIndex].add(newData);
    }
  }

  void _updateChartDataWithBufferedData() {
    final double maxTimeWindow = timeWindowSeconds;
    final int maxDataPoints = (maxTimeWindow * samplingRateHz).toInt();

    for (int channelIndex = 0; channelIndex < numberOfChartsToShow; channelIndex++) {
      if (pendingDataUpdates[channelIndex].isEmpty) continue;

      List<int> removedIndexes = [];
      List<int> addedIndexes = [];

      for (ChartData newData in pendingDataUpdates[channelIndex]) {
        if (channelChartData[channelIndex].length >= maxDataPoints) {
          // Remove the oldest point
          channelChartData[channelIndex].removeAt(0);
          removedIndexes.add(0);
        }

        // Add the new point
        channelChartData[channelIndex].add(newData);
        addedIndexes.add(channelChartData[channelIndex].length - 1);
      }

      // Clear the pending updates for this channel
      pendingDataUpdates[channelIndex].clear();

      // Update the chart controller with all changes at once
      if (chartSeriesControllers[channelIndex] != null) {
        chartSeriesControllers[channelIndex]!.updateDataSource(
          removedDataIndexes: removedIndexes,
          addedDataIndexes: addedIndexes,
        );
      }
    }
  }

  void _collectDemoData() {
    // Generate fake Bluetooth packet for demo
    List<int> fakeBluetoothPacket = List.generate(22, (index) {
      if (index < 3) return _getRandomInt(192, 194); // Status bytes
      if (index >= 21) return count % 256; // Count byte
      return _getRandomInt(1, 255); // Data bytes
    });

    _processBluetoothData(fakeBluetoothPacket);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final double width = orientation == Orientation.portrait ? size.width : size.height;

    return Material(
      child: SafeArea(
        child: Container(
          color: const Color(0xFFF8F9FA), // Light gray background
          child: Column(
            children: [
              // Number of charts selector
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Number of charts:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<int>(
                        value: numberOfChartsToShow,
                        underline: Container(),
                        items: List.generate(
                          6,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text("${index + 1} Chart${index == 0 ? '' : 's'}"),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              numberOfChartsToShow = value;
                              _clearChartData(cancelTimer: false);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Time window selector
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Time window:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<double>(
                        value: timeWindowSeconds,
                        underline: Container(),
                        items:
                            [5.0, 10.0, 15.0, 20.0, 30.0]
                                .map((seconds) => DropdownMenuItem(value: seconds, child: Text("${seconds.toInt()}s")))
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              timeWindowSeconds = value;
                              _clearChartData(cancelTimer: false);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Charts
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      numberOfChartsToShow,
                      (index) => Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: width - 50,
                            height: numberOfChartsToShow == 1 ? 400 : (numberOfChartsToShow <= 3 ? 250 : 200),
                            child: ECGChartWidget(
                              channelIndex: index,
                              legendTitle: channelNames[index],
                              chartColor: chartColors[index],
                              chartData: channelChartData[index],
                              crosshairBehavior: crosshairBehaviors[index],
                              timeWindowSeconds: timeWindowSeconds,
                              onRendererCreated: (controller) {
                                chartSeriesControllers[index] = controller;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Control buttons
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        _startUpdateData();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {});
                        });
                      },
                      child: const Text('Start Test', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        _clearChartData();
                      },
                      child: const Text('Stop & Clear', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fast data collection timer (250Hz) - only collects data, no UI updates
  void _collectDataOnly(Timer timer) {
    final double currentTime = _getCurrentTimeInSeconds();

    // Generate 6 channels of data
    List<double> channelVoltageValues = [];
    for (int i = 0; i < 6; i++) {
      // Create 6 different sine waves with different frequencies
      double frequency = 1.0 + (i * 0.5);
      double voltage = math.sin(2 * math.pi * frequency * currentTime);

      // Add higher-frequency component to make it look more like ECG
      double highFrequencyNoise = 0.1 * math.sin(2 * math.pi * 50 * currentTime);

      channelVoltageValues.add(voltage + highFrequencyNoise);
    }
    
    _addDataToPendingBuffer(channelVoltageValues);
    count = count + 1;
  }

  // Slower UI update timer (25Hz) - updates the UI with batched data
  void _updateUI(Timer timer) {
    _updateChartDataWithBufferedData();
  }

  int _getRandomInt(int min, int max) {
    final math.Random random = math.Random();
    return min + random.nextInt(max - min);
  }
}
