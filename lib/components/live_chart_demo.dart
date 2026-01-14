import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fmecg_mobile/components/ecg_chart_widget.dart';
import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:fmecg_mobile/controllers/ecg_packet_parser.dart';
import 'package:fmecg_mobile/controllers/high_frequency_data_saver.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveChartDemo extends StatefulWidget {
  const LiveChartDemo({Key? key, this.fileToSave, this.callBackToPreview}) : super(key: key);
  final File? fileToSave;
  final VoidCallback? callBackToPreview;

  @override
  State<LiveChartDemo> createState() => _LiveChartDemoState();
}

class _LiveChartDemoState extends State<LiveChartDemo> {
  Timer? dataCollectionTimer;
  Timer? uiUpdateTimer;
  List<List<EcgDataPoint>> channelChartData = [];
  List<ChartSeriesController?> chartSeriesControllers = [];
  List<CrosshairBehavior> crosshairBehaviors = [];

  // Buffer for collecting data between UI updates
  List<List<double>> dataBuffer = [];
  List<double> timeBuffer = [];

  late int count;
  int numberOfChartsToShow = 2;
  double timeWindowSeconds = 10.0;
  double samplingRateHz = 250.0; // Sampling rate for data collection
  double uiUpdateRateHz = 20.0; // UI update rate (20Hz = every 50ms)

  List samples = [];
  bool isButtonEndMeasurement = true;
  DateTime? startTime;

  // High-frequency data saver with isolate
  HighFrequencyDataSaver? _dataSaver;

  // Pre-allocated typed array for channel values (used in data collection)
  final Float64List _channelValuesBuffer = Float64List(6);

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
  final List<String> channelNames = ["CH1", "CH2", "CH3", "CH4", "CH5", "CH6"];

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
    _dataSaver?.close();
    _clearChartData();
  }

  void _initializeChartData() {
    channelChartData.clear();
    chartSeriesControllers.clear();
    crosshairBehaviors.clear();
    dataBuffer.clear();
    timeBuffer.clear();

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
    }
  }

  Future<void> _clearChartData({bool cancelTimer = true}) async {
    if (cancelTimer) {
      dataCollectionTimer?.cancel();
      uiUpdateTimer?.cancel();
    }

    // Close the data saver and flush remaining data
    await _dataSaver?.close();
    _dataSaver = null;

    for (int i = 0; i < channelChartData.length; i++) {
      channelChartData[i].clear();
    }

    samples = [];
    count = 0;
    startTime = null;
    dataBuffer.clear();
    timeBuffer.clear();

    for (int i = 0; i < chartSeriesControllers.length; i++) {
      chartSeriesControllers[i]?.updateDataSource(
        removedDataIndexes: List<int>.generate(channelChartData[i].length, (index) => index),
      );
    }
    setState(() {});
  }

  Future<void> _startUpdateData() async {
    startTime = DateTime.now();

    // Initialize the high-frequency data saver if a file is provided
    if (widget.fileToSave != null) {
      _dataSaver = HighFrequencyDataSaver(
        file: widget.fileToSave!,
        bufferSize: 250, // Flush every 1 second at 250Hz
        headers: const ['time', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6'],
      );
      await _dataSaver!.initialize();
    }

    // Timer 1 (Fast): Data collection at 250Hz (every 4ms)
    dataCollectionTimer = Timer.periodic(Duration(milliseconds: (1000 / samplingRateHz).round()), _collectDataOnly);

    // Timer 2 (Slower): UI updates at 20Hz (every 50ms)
    uiUpdateTimer = Timer.periodic(Duration(milliseconds: (1000 / uiUpdateRateHz).round()), _updateUIWithBufferedData);
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

      final double currentTime = _getCurrentTimeInSeconds();

      // Store the sample data
      samples.add([currentTime, ...channelDecimalValues]);

      // Save to CSV using the isolate-based saver (high frequency, non-blocking)
      _dataSaver?.addDataPoint(currentTime, channelDecimalValues);

      // Update chart data for each channel
      _updateChartDataWithRealData(channelVoltageValues);
    } catch (e) {
      print('Error processing Bluetooth data: $e');
      // Fallback to demo data if there's an error
      _updateWithDemoData();
    }
  }

  void _updateChartDataWithRealData(List<double> channelVoltageValues) {
    final double currentTime = _getCurrentTimeInSeconds();
    final double maxTimeWindow = timeWindowSeconds;
    final int maxDataPoints = (maxTimeWindow * samplingRateHz).toInt();
    print('🪵M6A maxDataPoints: ${maxDataPoints} M6A');
    print('🪵JH2 channelChartData[channelIndex].length: ${channelChartData.first.length} JH2');

    for (
      int channelIndex = 0;
      channelIndex < numberOfChartsToShow && channelIndex < channelVoltageValues.length;
      channelIndex++
    ) {
      if (channelChartData[channelIndex].length == maxDataPoints) {
        EcgDataPoint newData = EcgDataPoint(currentTime, channelVoltageValues[channelIndex]);
        channelChartData[channelIndex].removeAt(0);

        // Add the new point (at the end)
        channelChartData[channelIndex].add(newData);

        // Tell the controller ONE was removed and ONE was added
        if (chartSeriesControllers[channelIndex] != null) {
          chartSeriesControllers[channelIndex]!.updateDataSource(
            removedDataIndexes: <int>[0], // Index 0 was removed
            addedDataIndexes: <int>[channelChartData[channelIndex].length - 1], // New index was added
          );
        }
      } else {
        EcgDataPoint newData = EcgDataPoint(currentTime, channelVoltageValues[channelIndex]);
        channelChartData[channelIndex].add(newData);

        if (chartSeriesControllers[channelIndex] != null) {
          chartSeriesControllers[channelIndex]!.updateDataSource(
            addedDataIndexes: <int>[channelChartData[channelIndex].length - 1],
          );
        }
      }
    }
  }

  void _updateWithDemoData() {
    // Generate fake Bluetooth packet for demo
    List<int> fakeBluetoothPacket = List.generate(22, (index) {
      if (index < 3) return _getRandomInt(192, 194); // Status bytes
      if (index >= 21) return count % 256; // Count byte
      return _getRandomInt(1, 255); // Data bytes
    });

    _processBluetoothData(fakeBluetoothPacket);
  }

  Widget _buildCompactControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Text("Charts:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<int>(
              value: numberOfChartsToShow,
              isDense: true,
              underline: Container(),
              style: const TextStyle(fontSize: 12, color: Colors.black),
              items: List.generate(6, (index) => DropdownMenuItem(value: index + 1, child: Text("${index + 1}"))),
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
          const SizedBox(width: 16),
          Text("Window:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<double>(
              value: timeWindowSeconds,
              isDense: true,
              underline: Container(),
              style: const TextStyle(fontSize: 12, color: Colors.black),
              items:
                  [
                    5.0,
                    10.0,
                    15.0,
                    20.0,
                    30.0,
                  ].map((seconds) => DropdownMenuItem(value: seconds, child: Text("${seconds.toInt()}s"))).toList(),
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
          const Spacer(),
          // Show recording indicator if data saver is active
          if (_dataSaver?.isInitialized == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'REC',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              minimumSize: const Size(0, 32),
            ),
            onPressed: () {
              _startUpdateData();
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {});
              });
            },
            child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              minimumSize: const Size(0, 32),
            ),
            onPressed: () async {
              await _clearChartData();
            },
            child: const Text('Stop', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
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
              // Compact controls
              _buildCompactControls(),

              // Charts - maximized space
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      numberOfChartsToShow,
                      (index) => Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: SizedBox(
                            width: width - 20,
                            height:
                                numberOfChartsToShow == 1
                                    ? size.height *
                                        0.7 // Use 70% of screen height for single chart
                                    : (numberOfChartsToShow <= 2
                                        ? size.height *
                                            0.35 // Use 35% for 2 charts
                                        : size.height * 0.25), // Use 25% for 3+ charts
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
            ],
          ),
        ),
      ),
    );
  }

  // Timer 1 (Fast): Collects data at 250Hz without updating UI
  void _collectDataOnly(Timer timer) {
    final double currentTime = _getCurrentTimeInSeconds();

    // Generate 6 channels of data using pre-allocated typed array
    for (int i = 0; i < 6; i++) {
      double frequency = 1.0 + (i * 0.5);
      double voltage = math.sin(2 * math.pi * frequency * currentTime);
      double highFrequencyNoise = 0.1 * math.sin(2 * math.pi * 50 * currentTime);
      _channelValuesBuffer[i] = voltage + highFrequencyNoise;
    }

    // Save to CSV at 250Hz using the isolate-based saver (non-blocking)
    // This uses the typed Float64List for better performance
    _dataSaver?.addDataPointTyped(currentTime, _channelValuesBuffer);

    // Buffer the data for UI updates (convert to List<double> for compatibility)
    dataBuffer.add(List<double>.from(_channelValuesBuffer));
    timeBuffer.add(currentTime);

    count++;
    print('🪵PPR count: ${count} ---- $currentTime PPR');
  }

  // Timer 2 (Slower): Updates UI with buffered data at 20Hz
  void _updateUIWithBufferedData(Timer timer) {
    if (dataBuffer.isEmpty) return;

    final double maxTimeWindow = timeWindowSeconds;
    final int maxDataPoints = (maxTimeWindow * samplingRateHz).toInt();

    // Process all buffered data
    for (int bufferIndex = 0; bufferIndex < dataBuffer.length; bufferIndex++) {
      final List<double> channelVoltageValues = dataBuffer[bufferIndex];
      final double currentTime = timeBuffer[bufferIndex];

      for (
        int channelIndex = 0;
        channelIndex < numberOfChartsToShow && channelIndex < channelVoltageValues.length;
        channelIndex++
      ) {
        EcgDataPoint newData = EcgDataPoint(currentTime, channelVoltageValues[channelIndex]);

        if (channelChartData[channelIndex].length >= maxDataPoints) {
          // Remove the oldest data point and add the new one (sliding window)
          channelChartData[channelIndex].removeAt(0);
          channelChartData[channelIndex].add(newData);
        } else {
          // Just add the new data point if we haven't reached capacity
          channelChartData[channelIndex].add(newData);
        }
      }
    }

    // Update all chart controllers once with the batch of changes
    for (int channelIndex = 0; channelIndex < numberOfChartsToShow; channelIndex++) {
      if (chartSeriesControllers[channelIndex] != null) {
        if (channelChartData[channelIndex].length >= maxDataPoints) {
          // For sliding window, update with removed and added data
          final int dataPointsAdded = dataBuffer.length;
          chartSeriesControllers[channelIndex]!.updateDataSource(
            removedDataIndexes: List.generate(dataPointsAdded, (index) => index),
            addedDataIndexes: List.generate(
              dataPointsAdded,
              (index) => channelChartData[channelIndex].length - dataPointsAdded + index,
            ),
          );
        } else {
          // For initial filling, just add the new data points
          final int startIndex = channelChartData[channelIndex].length - dataBuffer.length;
          chartSeriesControllers[channelIndex]!.updateDataSource(
            addedDataIndexes: List.generate(dataBuffer.length, (index) => startIndex + index),
          );
        }
      }
    }

    // Clear the buffer after processing
    dataBuffer.clear();
    timeBuffer.clear();
  }

  int _getRandomInt(int min, int max) {
    final math.Random random = math.Random();
    return min + random.nextInt(max - min);
  }
}
