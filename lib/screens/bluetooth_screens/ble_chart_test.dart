import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:fmecg_mobile/components/ecg_chart_widget.dart';
import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:fmecg_mobile/controllers/ecg_packet_parser.dart';
import 'package:fmecg_mobile/generated/l10n.dart';
import 'package:fmecg_mobile/utils/files_management.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BleLiveChartTest extends StatefulWidget {
  const BleLiveChartTest({
    Key? key,
    required this.bluetoothCharacteristic,
    required this.fileToSave,
    required this.deviceConnected,
  }) : super(key: key);

  final QualifiedCharacteristic bluetoothCharacteristic;
  final DiscoveredDevice deviceConnected;
  final File fileToSave;

  @override
  State<BleLiveChartTest> createState() => _BleLiveChartTestState();
}

class _BleLiveChartTestState extends State<BleLiveChartTest> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<List<ChartData>> channelChartData = [];
  List<ChartSeriesController?> chartSeriesControllers = [];
  List<CrosshairBehavior> crosshairBehaviors = [];

  late int count;
  int numberOfChartsToShow = 2;
  double timeWindowSeconds = 10.0;
  double samplingRateHz = 250.0;

  late StreamSubscription<List<int>> subscribeStream;
  List samples = [];
  bool isMeasuring = false;
  bool isUploaded = false;
  bool isCalculated = false;
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
  final List<String> channelNames = [
    "Channel 1", "Channel 2", "Channel 3", 
    "Channel 4", "Channel 5", "Channel 6"
  ];

  @override
  void initState() {
    super.initState();
    count = 0;
    _initializeChartData();
  }

  @override
  void dispose() {
    super.dispose();
    _clearDataInChart();
    if (isMeasuring) {
      subscribeStream.cancel();
    }
  }

  void _initializeChartData() {
    channelChartData.clear();
    chartSeriesControllers.clear();
    crosshairBehaviors.clear();

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

  _clearDataInChart({bool cancelStream = false}) {
    for (int i = 0; i < channelChartData.length; i++) {
      channelChartData[i].clear();
    }

    samples = [];
    count = 0;
    startTime = null;

    if (cancelStream && isMeasuring) {
      subscribeStream.cancel();
    }

    for (int i = 0; i < chartSeriesControllers.length; i++) {
      chartSeriesControllers[i]?.updateDataSource(
        removedDataIndexes: List<int>.generate(channelChartData[i].length, (index) => index),
      );
    }

    setState(() {});
  }

  _resetMeasuring() {
    _clearDataInChart(cancelStream: true);
    setState(() {
      isMeasuring = false;
      isCalculated = false;
    });
  }

  _handleSaveRecordInFile() async {
    if (isMeasuring) {
      subscribeStream.cancel();
    }
    _clearDataInChart();

    await FilesManagement.handleSaveDataToFileV2(widget.fileToSave, samples);

    setState(() {
      samples.clear();
      isMeasuring = false;
    });
    return Utils.showDialogWarningError(context, false, "Data saved successfully");
  }

  double _getCurrentTimeInSeconds() {
    if (startTime == null) return 0.0;
    return DateTime.now().difference(startTime!).inMilliseconds / 1000.0;
  }

  void _processBluetoothData(List<int> bluetoothPacket) {
    try {
      // Use ECGPacketParser to process real Bluetooth data
      List<double> channelDecimalValues = EcgPacketParser.processECGDataPacketFromBluetooth(bluetoothPacket);
      List<double> channelVoltageValues = EcgPacketParser.convertDecimalValuesToVoltageForDisplay(channelDecimalValues);

      // Store the sample data with timestamp
      samples.add([_getCurrentTimeInSeconds(), ...channelDecimalValues]);

      // Save to file periodically to prevent memory overflow
      if (samples.length >= 10000) {
        FilesManagement.handleSaveDataToFileV2(widget.fileToSave, samples);
        samples.clear();
      }

      // Update chart data for each channel
      _updateChartDataWithRealData(channelVoltageValues);
    } catch (e) {
      print('Error processing Bluetooth data: $e');
    }
  }

  void _updateChartDataWithRealData(List<double> channelVoltageValues) {
    final double currentTime = _getCurrentTimeInSeconds();
    final double maxTimeWindow = timeWindowSeconds;
    final int maxDataPoints = (maxTimeWindow * samplingRateHz).toInt();

    for (
      int channelIndex = 0;
      channelIndex < numberOfChartsToShow && channelIndex < channelVoltageValues.length;
      channelIndex++
    ) {
      if (channelChartData[channelIndex].length == maxDataPoints) {
        ChartData newData = ChartData(currentTime, channelVoltageValues[channelIndex]);
        
        // Remove the first data point and add new one (sliding window)
        channelChartData[channelIndex].removeAt(0);
        channelChartData[channelIndex].add(newData);

        if (chartSeriesControllers[channelIndex] != null) {
          chartSeriesControllers[channelIndex]!.updateDataSource(
            removedDataIndexes: <int>[0],
            addedDataIndexes: <int>[channelChartData[channelIndex].length - 1],
          );
        }
      } else {
        ChartData newData = ChartData(currentTime, channelVoltageValues[channelIndex]);
        channelChartData[channelIndex].add(newData);

        if (chartSeriesControllers[channelIndex] != null) {
          chartSeriesControllers[channelIndex]!.updateDataSource(
            addedDataIndexes: <int>[channelChartData[channelIndex].length - 1],
          );
        }
      }
    }
  }

  void subscribeCharacteristic() {
    startTime = DateTime.now();
    subscribeStream = flutterReactiveBle.subscribeToCharacteristic(widget.bluetoothCharacteristic).listen((value) {
      print('BLE data received: $value');

      // Process the received Bluetooth data
      _processBluetoothData(value);
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final double width = orientation == Orientation.portrait ? size.width : size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(PhosphorIcons.regular.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(S.current.measurementPage),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
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
                        if (value != null && !isMeasuring) {
                          setState(() {
                            numberOfChartsToShow = value;
                            _clearDataInChart();
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
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
                      items: [5.0, 10.0, 15.0, 20.0, 30.0]
                          .map((seconds) => DropdownMenuItem(
                              value: seconds, child: Text("${seconds.toInt()}s")))
                          .toList(),
                      onChanged: (value) {
                        if (value != null && !isMeasuring) {
                          setState(() {
                            timeWindowSeconds = value;
                            _clearDataInChart();
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
                      backgroundColor: isMeasuring ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (isMeasuring) {
                        _resetMeasuring();
                      } else {
                        setState(() {
                          isMeasuring = true;
                        });
                        subscribeCharacteristic();
                      }
                    },
                    child: Text(
                      isMeasuring ? 'Stop & Reset' : 'Start Measurement',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: samples.isNotEmpty ? _handleSaveRecordInFile : null,
                    child: const Text(
                      'Save Data',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
