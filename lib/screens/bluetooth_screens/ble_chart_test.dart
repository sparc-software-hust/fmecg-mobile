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
  List<bool> selectedChannels = [true, true, false, false, false, false]; // Which channels to show
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

  List<int> get _getSelectedChannelIndices {
    List<int> indices = [];
    for (int i = 0; i < selectedChannels.length; i++) {
      if (selectedChannels[i]) {
        indices.add(i);
      }
    }
    return indices;
  }

  int get _numberOfSelectedChannels {
    return selectedChannels.where((selected) => selected).length;
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

      // Update chart data for selected channels only
      _updateChartDataWithRealData(channelVoltageValues);
    } catch (e) {
      print('Error processing Bluetooth data: $e');
    }
  }

  void _updateChartDataWithRealData(List<double> channelVoltageValues) {
    print('🪵KWH channelVoltageValues: ${channelVoltageValues} KWH');
    final double currentTime = _getCurrentTimeInSeconds();
    final double maxTimeWindow = timeWindowSeconds;
    final int maxDataPoints = (maxTimeWindow * samplingRateHz).toInt();

    // Update only selected channels
    for (int i = 0; i < selectedChannels.length && i < channelVoltageValues.length; i++) {
      if (!selectedChannels[i]) continue; // Skip unselected channels

      if (channelChartData[i].length == maxDataPoints) {
        ChartData newData = ChartData(currentTime, channelVoltageValues[i]);

        // Remove the first data point and add new one (sliding window)
        channelChartData[i].removeAt(0);
        channelChartData[i].add(newData);

        if (chartSeriesControllers[i] != null) {
          chartSeriesControllers[i]!.updateDataSource(
            removedDataIndexes: <int>[0],
            addedDataIndexes: <int>[channelChartData[i].length - 1],
          );
        }
      } else {
        ChartData newData = ChartData(currentTime, channelVoltageValues[i]);
        channelChartData[i].add(newData);

        if (chartSeriesControllers[i] != null) {
          chartSeriesControllers[i]!.updateDataSource(
            addedDataIndexes: <int>[channelChartData[i].length - 1],
          );
        }
      }
    }
  }

  void subscribeCharacteristic() {
    startTime = DateTime.now();
    subscribeStream = flutterReactiveBle.subscribeToCharacteristic(widget.bluetoothCharacteristic).listen((value) {
      // print('BLE data received: $value');

      // Process the received Bluetooth data
      _processBluetoothData(value);
      count++;
    });
  }

  Widget _buildChannelSelector() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Channels:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800]),
              ),
              Text(
                "${_numberOfSelectedChannels} selected",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(6, (index) {
              return FilterChip(
                label: Text(channelNames[index]),
                selected: selectedChannels[index],
                onSelected: isMeasuring ? null : (bool selected) {
                  setState(() {
                    selectedChannels[index] = selected;
                    _clearDataInChart();
                  });
                },
                selectedColor: chartColors[index].withOpacity(0.3),
                checkmarkColor: chartColors[index],
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: selectedChannels[index] ? chartColors[index] : Colors.grey[700],
                  fontWeight: selectedChannels[index] ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }),
          ),
          if (_numberOfSelectedChannels == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Please select at least one channel",
                style: TextStyle(color: Colors.red[600], fontSize: 12),
              ),
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
    final List<int> selectedChannelIndices = _getSelectedChannelIndices;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(PhosphorIcons.regular.arrowLeft), onPressed: () => Navigator.pop(context)),
        title: Text(S.current.measurementPage),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: Column(
          children: [
            // Channel selector
            _buildChannelSelector(),

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
                  children: selectedChannelIndices.map((channelIndex) => Container(
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
                        height: _numberOfSelectedChannels == 1 ? 400 : (_numberOfSelectedChannels <= 3 ? 250 : 200),
                        child: ECGChartWidget(
                          channelIndex: channelIndex,
                          legendTitle: channelNames[channelIndex],
                          chartColor: chartColors[channelIndex],
                          chartData: channelChartData[channelIndex],
                          crosshairBehavior: crosshairBehaviors[channelIndex],
                          timeWindowSeconds: timeWindowSeconds,
                          onRendererCreated: (controller) {
                            chartSeriesControllers[channelIndex] = controller;
                          },
                        ),
                      ),
                    ),
                  )).toList(),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _numberOfSelectedChannels > 0 ? () {
                      if (isMeasuring) {
                        _resetMeasuring();
                      } else {
                        setState(() {
                          isMeasuring = true;
                        });
                        subscribeCharacteristic();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {});
                        });
                      }
                    } : null,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: samples.isNotEmpty ? _handleSaveRecordInFile : null,
                    child: const Text('Save Data', style: TextStyle(fontWeight: FontWeight.w600)),
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
