/// Package import
import 'package:fmecg_mobile/controllers/ecg_record_controller.dart';
import 'package:fmecg_mobile/providers/ecg_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

class HistoryRecordChart extends StatefulWidget {
  const HistoryRecordChart({
    Key? key, 
    required this.recordId
  }) : super(key: key);
  final int recordId;

  @override
  State<HistoryRecordChart> createState() => _HistoryRecordChartState();
  
}

class _HistoryRecordChartState extends State<HistoryRecordChart>  {
  List? chartData;
  // TrackballBehavior? _trackballBehavior;

  @override
  void initState() {
    super.initState();
    // _trackballBehavior = TrackballBehavior(
    //   enable: true,
    //   lineColor: const Color.fromRGBO(255, 255, 255, 0.03),
    //   lineWidth: 15,
    //   activationMode: ActivationMode.singleTap,
    //   markerSettings: const TrackballMarkerSettings(
    //     borderWidth: 4,
    //     height: 10,
    //     width: 10,
    //     markerVisibility: TrackballVisibilityMode.visible)
    // );
    handleDataECGRecord();
  }

  void handleDataECGRecord() async {
    await ECGRecordController.getDataECGRecordById(widget.recordId);
    // print('ress:$dataECGRecord');
  }

  @override
  Widget build(BuildContext context) {
    final List dataECGRecord = context.watch<ECGProvider>().ecgRecordDataSelected;
    chartData = dataECGRecord;

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(15),
        child: Center(
          child: chartData != null && chartData!.isNotEmpty ?
            _buildDefaultLineChart() : const CircularProgressIndicator()
          )
      )
    );
  }

  /// Get the cartesian chart with default line series
  SfCartesianChart _buildDefaultLineChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      title: ChartTitle(text: 'Record ${widget.recordId}'),
      legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap),
      primaryXAxis: NumericAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          // intervalType: DateTimeIntervalType.years,
          // dateFormat: DateFormat.y(),
          name: 'Years',
          rangePadding: ChartRangePadding.round,
          majorGridLines: const MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(
          // minimum: 70,
          // maximum: 110,
          // interval: 10,
          // rangePadding: ChartRangePadding.none,
          // name: 'Price',
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(color: Colors.transparent)),
      series: _getDefaultLineSeries(),
      // trackballBehavior: _trackballBehavior,
    );
  }

  /// The method returns line series to chart.
  List<LineSeries> _getDefaultLineSeries() {
    return [
      LineSeries(
        dataSource: chartData!,
        xValueMapper: (pieceData, _) => pieceData["timestamp"],
        yValueMapper: (pieceData, _) => double.parse(pieceData["ch1"] ?? "0"),
        name: 'Channel 01'
      ),
      LineSeries(
        dataSource: chartData!,
        xValueMapper: (pieceData, _) => pieceData["timestamp"],
        yValueMapper: (pieceData, _) => double.parse(pieceData["ch2"] ?? "0"),
        name: 'Channel 02'
      ),
    ];
  }

  @override
  void dispose() {
    chartData!.clear();
    super.dispose();
  }
}
