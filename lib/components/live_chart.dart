import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:fmecg_mobile/controllers/ecg_data_controller.dart';
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
  List<ChartData> chartDataPPG = [];
  List<ChartData> chartDataPCG = [];
  late int count;
  ChartSeriesController? _chartSeriesControllerPPG;
  ChartSeriesController? _chartSeriesControllerPCG;
  CrosshairBehavior crosshairBehavior = CrosshairBehavior(
    enable: true,
    lineType: CrosshairLineType.vertical,
    activationMode: ActivationMode.none,
    lineColor: Color(0xFF010101),
    lineWidth: 2,
  );

  CrosshairBehavior crosshairBehavior2 = CrosshairBehavior(
    enable: true,
    lineType: CrosshairLineType.vertical,
    activationMode: ActivationMode.none,
    lineColor: Colors.blue,
    lineWidth: 2,
  );
  int countX = 500;
  List samples = [];
  bool isButtonEndMeasurement = true;

  @override
  void initState() {
    super.initState();
    count = 0;
    // _startUpdateData();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    _clearChartData();
  }

  _clearChartData({bool cancelTimer = true}) {
    if (cancelTimer) {
      timer?.cancel();
    }
    chartDataPPG.clear();
    chartDataPCG.clear();
    samples = [];
    count = 0;
    setState(() {});
  }

  _startUpdateData() {
    timer = Timer.periodic(const Duration(milliseconds: 4), _updateDataSource);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final double width = orientation == Orientation.portrait ? size.width : size.height;

    return Column(
      children: [
        SizedBox(
          width: width - 50,
          height: 300,
          child: OneChart(
            legendTitle: "PPG",
            crosshairBehavior: crosshairBehavior,
            chartData: chartDataPPG,
            xCount: countX,
            setChartSeriesController: (ChartSeriesController controller) {
              _chartSeriesControllerPPG = controller;
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          width: width - 50,
          child: OneChart(
            legendTitle: "PCG",
            crosshairBehavior: crosshairBehavior2,
            chartData: chartDataPCG,
            xCount: countX,
            setChartSeriesController: (ChartSeriesController controller) {
              _chartSeriesControllerPCG = controller;
            },
          ),
        ),

        SfSlider(
          min: 50,
          max: 500,
          stepSize: 50,
          value: countX,
          interval: 50,
          showTicks: true,
          showLabels: true,
          activeColor: const Color(0xFF4f6bff),
          enableTooltip: true,
          minorTicksPerInterval: 0,
          onChanged: (dynamic value) {
            _clearChartData(cancelTimer: false);
            setState(() {
              countX = value.toInt();
            });
          },
        ),
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // ElevatedButton(
              //   onPressed: () {
              //     if (widget.callBackToPreview != null) {
              //       widget.callBackToPreview!.call();
              //     }
              //   },
              //   child: const Text('Quay lại')
              // ),
              ElevatedButton(
                onPressed: () {
                  _startUpdateData();
                },
                child: const Text('Bắt đầu test'),
              ),
              ElevatedButton(
                onPressed: () async {
                  _clearChartData();
                  // if (isButtonEndMeasurement) {
                  //   _clearChartData();
                  //   // await _saveDataAndSendToServer();
                  // } else {
                  //   setState(() {
                  //     _startUpdateData();
                  //     isButtonEndMeasurement = true;
                  //   });
                  // }
                },
                child: Text(!isButtonEndMeasurement ? "Start Demo Chart" : "Kết thúc đo"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SfCartesianChart _buildLiveLineChart() {
    return SfCartesianChart(
      // title: ChartTitle(
      //   text: "BIỂU ĐỒ HUYẾT ÁP REAL-TIME",
      //   alignment: ChartAlignment.center,
      // ),
      crosshairBehavior: crosshairBehavior,
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
        minimum: 0,
        maximum: countX.toDouble(),
        interval: 50,
        interactiveTooltip: const InteractiveTooltip(enable: false),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),

      primaryYAxis: const NumericAxis(
        interactiveTooltip: InteractiveTooltip(enable: false),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        majorGridLines: MajorGridLines(width: 1),
      ),
      legend: const Legend(isVisible: true, isResponsive: true, position: LegendPosition.top),
      series: [
        LineSeries<ChartData, int>(
          enableTooltip: false,
          onRendererCreated: (ChartSeriesController controller) {
            _chartSeriesControllerPPG = controller;
          },
          legendItemText: "PPG",
          dataSource: chartDataPPG,
          color: const Color(0XFF7BB4EA),
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.y,
          // animationDuration: 0,
        ),
      ],
    );
  }

  SfCartesianChart _buildLiveLineChart1() {
    return SfCartesianChart(
      title: const ChartTitle(alignment: ChartAlignment.center),
      // enableAxisAnimation: true,
      plotAreaBorderWidth: 0,
      primaryXAxis: const NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
      primaryYAxis: const NumericAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        majorGridLines: MajorGridLines(width: 1),
      ),
      legend: const Legend(isVisible: true, isResponsive: true, position: LegendPosition.top),
      series: [
        LineSeries<ChartData, int>(
          onRendererCreated: (ChartSeriesController controller) {
            _chartSeriesControllerPCG = controller;
          },
          legendItemText: "PCG",
          dataSource: chartDataPCG,
          color: const Color(0xFFE11239),
          xValueMapper: (ChartData d, _) => d.x,
          yValueMapper: (ChartData d, _) => d.y,
          // animationDuration: 0,
        ),
      ],
    );
  }

  void _updateDataSource(Timer timer) {
    List<int> fakeRows = List.generate(16, (_) => _getRandomInt(1, 244));
    List<double> dataChannelsToSave = ECGDataController.handleDataRowFromBluetooth(fakeRows);
    List dataChannelsToShowOnChart = ECGDataController.calculateDataPointToShow(dataChannelsToSave);
    samples.add([0, 0, 0, 0, 0, 0, ...dataChannelsToSave]);

    final int index = count % countX;
    ChartData newDataPPG = ChartData(index, (dataChannelsToShowOnChart[0]).toDouble());
    ChartData newDataPCG = ChartData(index, (dataChannelsToShowOnChart[1]).toDouble());

    if (chartDataPPG.length == countX) {
      crosshairBehavior.showByIndex(index);
      crosshairBehavior2.showByIndex(index);
      chartDataPPG[index] = newDataPPG;
      chartDataPCG[index] = newDataPCG;

      _chartSeriesControllerPPG?.updateDataSource(updatedDataIndexes: <int>[index]);
      _chartSeriesControllerPCG?.updateDataSource(updatedDataIndexes: <int>[index]);
    } else {
      chartDataPPG.add(newDataPPG);
      chartDataPCG.add(newDataPCG);
      _chartSeriesControllerPPG?.updateDataSource(addedDataIndexes: <int>[chartDataPPG.length - 1]);
      _chartSeriesControllerPCG?.updateDataSource(addedDataIndexes: <int>[chartDataPCG.length - 1]);
    }
    count = count + 1;
  }

  int _getRandomInt(int min, int max) {
    final math.Random random = math.Random();
    return min + random.nextInt(max - min);
  }
}
