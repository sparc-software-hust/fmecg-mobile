import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:fmecg_mobile/controllers/ecg_packet_parser.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart' hide EdgeLabelPlacement;

class LiveChartSample extends StatefulWidget {
  const LiveChartSample({Key? key, this.fileToSave, this.callBackToPreview}) : super(key: key);
  final File? fileToSave;
  final VoidCallback? callBackToPreview;

  @override
  State<LiveChartSample> createState() => _LiveChartSampleState();
}

class _LiveChartSampleState extends State<LiveChartSample> {
  Timer? timer;
  List<List<ChartData>> channelChartData = [];
  List<ChartSeriesController?> chartSeriesControllers = [];
  List<CrosshairBehavior> crosshairBehaviors = [];
  
  late int count;
  int countX = 500;
  int numberOfChartsToShow = 2;
  double timeWindowSeconds = 10.0;
  double samplingRateHz = 250.0; // Assuming 250 Hz sampling rate
  
  List samples = [];
  bool isButtonEndMeasurement = true;
  DateTime? startTime;

  // Chart colors for different channels
  final List<Color> chartColors = [
    const Color(0XFF7BB4EA), // Blue
    const Color(0xFFE11239), // Red
    const Color(0xFF32CD32), // Green
    const Color(0xFFFF8C00), // Orange
    const Color(0xFF9932CC), // Purple
    const Color(0xFFFF1493), // Pink
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
    timer?.cancel();
    _clearChartData();
  }

  void _initializeChartData() {
    channelChartData.clear();
    chartSeriesControllers.clear();
    crosshairBehaviors.clear();
    
    for (int i = 0; i < 6; i++) {
      channelChartData.add([]);
      chartSeriesControllers.add(null);
      crosshairBehaviors.add(CrosshairBehavior(
        enable: true,
        lineType: CrosshairLineType.vertical,
        activationMode: ActivationMode.none,
        lineColor: chartColors[i],
        lineWidth: 2,
      ));
    }
  }

  _clearChartData({bool cancelTimer = true}) {
    if (cancelTimer) {
      timer?.cancel();
    }
    
    for (int i = 0; i < channelChartData.length; i++) {
      channelChartData[i].clear();
    }
    
    samples = [];
    count = 0;
    startTime = null;
    setState(() {});
  }

  _startUpdateData() {
    startTime = DateTime.now();
    timer = Timer.periodic(const Duration(milliseconds: 4), _updateDataSource);
  }

  double _getCurrentTimeInSeconds() {
    if (startTime == null) return 0.0;
    return DateTime.now().difference(startTime!).inMilliseconds / 1000.0;
  }

  void _processBluetoothData(List<int> bluetoothPacket) {
    try {
      // Use the ECGPacketParser to process the real Bluetooth data
      List<double> channelDecimalValues = EcgPacketParser.handleDataRowFromBluetooth(bluetoothPacket);
      List<double> channelVoltageValues = EcgPacketParser.calculateDataPointToShow(channelDecimalValues);
      
      // Store the sample data
      samples.add([_getCurrentTimeInSeconds(), ...channelDecimalValues]);
      
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
    
    for (int channelIndex = 0; channelIndex < numberOfChartsToShow && channelIndex < channelVoltageValues.length; channelIndex++) {
      ChartData newData = ChartData(currentTime, channelVoltageValues[channelIndex]);
      
      // Add new data point
      channelChartData[channelIndex].add(newData);
      
      // Remove old data points outside the time window
      channelChartData[channelIndex].removeWhere((data) => 
        (currentTime - data.x) > maxTimeWindow);
      
      // Update chart controller
      if (chartSeriesControllers[channelIndex] != null) {
        chartSeriesControllers[channelIndex]!.updateDataSource(
          addedDataIndexes: <int>[channelChartData[channelIndex].length - 1]
        );
      }
      
      // Update crosshair
      crosshairBehaviors[channelIndex].showByValue(currentTime, channelVoltageValues[channelIndex]);
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final double width = orientation == Orientation.portrait ? size.width : size.height;

    return Column(
      children: [
        // Number of charts selector
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("Number of charts:"),
              DropdownButton<int>(
                value: numberOfChartsToShow,
                items: List.generate(6, (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text("${index + 1} Chart${index == 0 ? '' : 's'}"),
                )),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      numberOfChartsToShow = value;
                      _clearChartData(cancelTimer: false);
                    });
                  }
                },
              ),
            ],
          ),
        ),
        
        // Time window selector
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("Time window:"),
              DropdownButton<double>(
                value: timeWindowSeconds,
                items: [5.0, 10.0, 15.0, 20.0, 30.0].map((seconds) => 
                  DropdownMenuItem(
                    value: seconds,
                    child: Text("${seconds.toInt()}s"),
                  )
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      timeWindowSeconds = value;
                      _clearChartData(cancelTimer: false);
                    });
                  }
                },
              ),
            ],
          ),
        ),

        // Charts
        ...List.generate(numberOfChartsToShow, (index) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: SizedBox(
              width: width - 50,
              height: numberOfChartsToShow == 1 ? 400 : (numberOfChartsToShow <= 3 ? 250 : 200),
              child: _buildECGChart(
                channelIndex: index,
                legendTitle: channelNames[index],
                chartColor: chartColors[index],
              ),
            ),
          ),
        ),

        // Control buttons
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  _startUpdateData();
                },
                child: const Text('Start Test'),
              ),
              ElevatedButton(
                onPressed: () async {
                  _clearChartData();
                },
                child: const Text('Stop & Clear'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildECGChart({
    required int channelIndex,
    required String legendTitle,
    required Color chartColor,
  }) {
    return SfCartesianChart(
      title: ChartTitle(
        text: legendTitle,
        alignment: ChartAlignment.center,
      ),
      crosshairBehavior: crosshairBehaviors[channelIndex],
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
        title: const AxisTitle(text: 'Time (seconds)'),
        minimum: startTime != null ? math.max(0, _getCurrentTimeInSeconds() - timeWindowSeconds) : 0,
        maximum: startTime != null ? math.max(timeWindowSeconds, _getCurrentTimeInSeconds()) : timeWindowSeconds,
        interval: timeWindowSeconds / 5, // 5 intervals on x-axis
        interactiveTooltip: const InteractiveTooltip(enable: false),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        majorGridLines: const MajorGridLines(width: 1),
      ),
      primaryYAxis: const NumericAxis(
        title: AxisTitle(text: 'Voltage (V)'),
        interactiveTooltip: InteractiveTooltip(enable: false),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        majorGridLines: MajorGridLines(width: 1),
      ),
      series: [
        LineSeries<ChartData, double>(
          enableTooltip: false,
          onRendererCreated: (ChartSeriesController controller) {
            chartSeriesControllers[channelIndex] = controller;
          },
          legendItemText: legendTitle,
          dataSource: channelChartData[channelIndex],
          color: chartColor,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          width: 2,
        ),
      ],
    );
  }

  void _updateDataSource(Timer timer) {
    // For demo purposes, use fake data
    // In real implementation, this would be called with actual Bluetooth data
    _updateWithDemoData();
    count = count + 1;
  }

  int _getRandomInt(int min, int max) {
    final math.Random random = math.Random();
    return min + random.nextInt(max - min);
  }
}
