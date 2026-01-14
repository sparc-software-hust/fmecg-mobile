import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fmecg_mobile/components/ecg_chart_widget.dart';
import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:fmecg_mobile/controllers/high_frequency_data_saver.dart';
import 'package:fmecg_mobile/utils/files_management.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveChartDemo extends StatefulWidget {
  const LiveChartDemo({Key? key, this.callBackToPreview}) : super(key: key);
  final VoidCallback? callBackToPreview;

  @override
  State<LiveChartDemo> createState() => _LiveChartDemoState();
}

class _LiveChartDemoState extends State<LiveChartDemo> {
  Timer? dataCollectionTimer;
  List<List<EcgDataPoint>> channelChartData = [];
  List<ChartSeriesController?> chartSeriesControllers = [];
  List<CrosshairBehavior> crosshairBehaviors = [];

  late int count;
  List<bool> selectedChannels = [true, true, false, false, false, false];
  double timeWindowSeconds = 5.0;
  double samplingRateHz = 250.0;

  bool isMeasuring = false;
  DateTime? startTime;

  // File management
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
    _clearDataInChart();
    _dataSaver?.close();
    if (isMeasuring) {
      dataCollectionTimer?.cancel();
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

  _clearDataInChart({bool cancelTimer = false}) {
    // Clear chart data first
    for (int i = 0; i < channelChartData.length; i++) {
      channelChartData[i].clear();
    }

    count = 0;
    startTime = null;

    if (cancelTimer && isMeasuring) {
      dataCollectionTimer?.cancel();
    }

    // Reset chart controllers to null to avoid disposed controller errors
    for (int i = 0; i < chartSeriesControllers.length; i++) {
      chartSeriesControllers[i] = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  _resetMeasuring() async {
    _clearDataInChart(cancelTimer: true);

    // Close the data saver
    await _dataSaver?.close();
    _dataSaver = null;

    if (mounted) {
      setState(() {
        isMeasuring = false;
      });
    }
  }

  Future<void> _initializeFileAndDataSaver() async {
    // Create a new file for this recording session
    final file = await FilesManagement.getFilePath();

    // Delete existing file and create a fresh one
    if (await file.exists()) {
      await file.delete();
    }
    await file.create(recursive: true);

    // Initialize the high-frequency data saver
    _dataSaver = HighFrequencyDataSaver(
      file: file,
      bufferSize: 250, // Flush every 1 second at 250Hz
      headers: const ['time', 'ch1', 'ch2', 'ch3', 'ch4', 'ch5', 'ch6'],
    );
    await _dataSaver!.initialize();
  }

  double _getCurrentTimeInSeconds() {
    if (startTime == null) return 0.0;
    return DateTime.now().difference(startTime!).inMilliseconds / 1000.0;
  }

  void _generateAndProcessDemoData(Timer timer) {
    if (!mounted) return;

    final double currentTime = _getCurrentTimeInSeconds();

    // Generate 6 channels of demo ECG-like data
    for (int i = 0; i < 6; i++) {
      double frequency = 1.0 + (i * 0.5);
      double voltage = math.sin(2 * math.pi * frequency * currentTime);
      double highFrequencyNoise = 0.1 * math.sin(2 * math.pi * 50 * currentTime);
      _channelValuesBuffer[i] = voltage + highFrequencyNoise;
    }

    // Save to CSV using the isolate-based saver (high frequency, non-blocking)
    _dataSaver?.addDataPointTyped(currentTime, _channelValuesBuffer);

    // Update chart data
    _updateChartDataWithRealData(List<double>.from(_channelValuesBuffer));

    count++;
  }

  void _updateChartDataWithRealData(List<double> channelVoltageValues) {
    if (!mounted) return;

    final double currentTime = _getCurrentTimeInSeconds();
    final double maxTimeWindow = timeWindowSeconds;
    final int maxDataPoints = (maxTimeWindow * samplingRateHz / 5).toInt();

    for (int i = 0; i < selectedChannels.length && i < channelVoltageValues.length; i++) {
      if (!selectedChannels[i]) continue;

      if (channelChartData[i].length >= maxDataPoints) {
        EcgDataPoint newData = EcgDataPoint(currentTime, channelVoltageValues[i]);

        channelChartData[i].removeAt(0);
        channelChartData[i].add(newData);

        if (chartSeriesControllers[i] != null && mounted) {
          try {
            chartSeriesControllers[i]!.updateDataSource(
              removedDataIndexes: <int>[0],
              addedDataIndexes: <int>[channelChartData[i].length - 1],
            );
          } catch (e) {
            print('Chart controller $i disposed, resetting to null');
            chartSeriesControllers[i] = null;
          }
        }
      } else {
        EcgDataPoint newData = EcgDataPoint(currentTime, channelVoltageValues[i]);
        channelChartData[i].add(newData);

        if (chartSeriesControllers[i] != null && mounted) {
          try {
            chartSeriesControllers[i]!.updateDataSource(addedDataIndexes: <int>[channelChartData[i].length - 1]);
          } catch (e) {
            print('Chart controller $i disposed, resetting to null');
            chartSeriesControllers[i] = null;
          }
        }
      }
    }
  }

  Future<void> _startDemoMeasurement() async {
    startTime = DateTime.now();

    // Initialize file and data saver before starting measurement
    await _initializeFileAndDataSaver();

    // Start data collection timer at 250Hz (every 4ms)
    dataCollectionTimer = Timer.periodic(
      Duration(milliseconds: (1000 / samplingRateHz).round()),
      _generateAndProcessDemoData,
    );

    setState(() {
      isMeasuring = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
      }
    });
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
      child: Column(
        children: [
          // Channel selector - compact row
          Row(
            children: [
              Text("Channels:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: List.generate(6, (index) {
                    return InkWell(
                      onTap:
                          isMeasuring
                              ? null
                              : () {
                                setState(() {
                                  selectedChannels[index] = !selectedChannels[index];
                                  _clearDataInChart(cancelTimer: false);
                                });
                              },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedChannels[index] ? chartColors[index].withOpacity(0.3) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: selectedChannels[index] ? chartColors[index] : Colors.grey[400]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          channelNames[index],
                          style: TextStyle(
                            color: selectedChannels[index] ? chartColors[index] : Colors.grey[700],
                            fontWeight: selectedChannels[index] ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Time window and controls row
          Row(
            children: [
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
                    if (value != null && !isMeasuring) {
                      setState(() {
                        timeWindowSeconds = value;
                        _clearDataInChart();
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
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text('REC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red[700])),
                    ],
                  ),
                ),
              // Control buttons - compact
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMeasuring ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(0, 32),
                ),
                onPressed:
                    _numberOfSelectedChannels > 0
                        ? () async {
                          if (isMeasuring) {
                            await _resetMeasuring();
                          } else {
                            await _startDemoMeasurement();
                          }
                        }
                        : null,
                child: Text(
                  isMeasuring ? 'Stop' : 'Start',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          if (_numberOfSelectedChannels == 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text("Select at least one channel", style: TextStyle(color: Colors.red[600], fontSize: 11)),
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

    return Material(
      child: SafeArea(
        child: Container(
          color: const Color(0xFFF8F9FA),
          child: Column(
            children: [
              // Compact controls
              _buildCompactControls(),

              // Charts - maximized space
              Expanded(
                child:
                    selectedChannelIndices.isEmpty
                        ? Center(
                          child: Text(
                            "Please select at least one channel to display",
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        )
                        : SingleChildScrollView(
                          child: Column(
                            children:
                                selectedChannelIndices
                                    .map(
                                      (channelIndex) => Container(
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
                                                _numberOfSelectedChannels == 1
                                                    ? size.height * 0.7
                                                    : (_numberOfSelectedChannels <= 2
                                                        ? size.height * 0.35
                                                        : size.height * 0.25),
                                            child: ECGChartWidget(
                                              channelIndex: channelIndex,
                                              legendTitle: channelNames[channelIndex],
                                              chartColor: chartColors[channelIndex],
                                              chartData: channelChartData[channelIndex],
                                              crosshairBehavior: crosshairBehaviors[channelIndex],
                                              timeWindowSeconds: timeWindowSeconds,
                                              onRendererCreated: (controller) {
                                                if (mounted) {
                                                  chartSeriesControllers[channelIndex] = controller;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
