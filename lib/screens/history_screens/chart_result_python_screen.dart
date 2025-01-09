import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsResultPythonScreen extends StatefulWidget {
  const ChartsResultPythonScreen({
    Key? key, required this.data,
  }) : super(key: key);
  final Map data;

  @override
  State<ChartsResultPythonScreen> createState() =>
      _ChartsResultPythonScreenState();
}

class _ChartsResultPythonScreenState extends State<ChartsResultPythonScreen> {
  // List? chartData;
  // TrackballBehavior? _trackballBehavior;
  List sbpData = [];
  List dbpData = [];
  List spo2Data = [];
  List heartRateData = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    setChartData();
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
  }

  setChartData() {
    setState(() => isLoading = true);
    sbpData = widget.data["sbp"] ?? [];
    dbpData = widget.data["dbp"] ?? [];
    spo2Data = widget.data["spo2"] ?? [];
    heartRateData = widget.data["heart_rate"] ?? [];
    setState(() => isLoading = false);
  }

  String getUnitByType(String type) {
    final String textTrimmed = type.toLowerCase();
    switch (textTrimmed) {
      case "sbp":
        return "mmHg";
      case "dbp":
        return "mmHg";
      case "spo2":
        return "%";
      case "heart rate":
        return "bpm";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: const EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildDefaultLineChart("SBP", sbpData),
                const SizedBox(height: 15),
                _buildDefaultLineChart("DBP", dbpData),
                const SizedBox(height: 15),
                _buildDefaultLineChart("SPO2", spo2Data),
                const SizedBox(height: 15),
                _buildDefaultLineChart("Heart rate", heartRateData),
                const SizedBox(height: 15),
              ],
            ))));
  }

  Widget _buildDefaultLineChart(String name, List result) {
    final String unit = getUnitByType(name);
    return SfCartesianChart(
      margin: const EdgeInsets.only(left: 5, right: 10, top: 5),
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      title: ChartTitle(
          text: name, textStyle: const TextStyle(fontWeight: FontWeight.w600)),
      legend:
          Legend(isVisible: false, overflowMode: LegendItemOverflowMode.wrap),
      primaryXAxis: NumericAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          // intervalType: DateTimeIntervalType.years,
          // dateFormat: DateFormat.y(),
          // name: 'Samples',
          // rangePadding: ChartRangePadding.round,
          title: AxisTitle(text: "Sample count"),
          majorGridLines: const MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(
          title: AxisTitle(text: unit),
          // minimum: 70,
          // maximum: 110,
          // interval: 10,
          // rangePadding: ChartRangePadding.none,
          // name: 'Price',
          // axisLine: const AxisLine(width: 0),
          majorTickLines:
              const MajorTickLines(color: Colors.transparent, width: 0)),
      series: _getDefaultLineSeries(result),
      // trackballBehavior: _trackballBehavior,
    );
  }

  /// The method returns line series to chart.
  List<LineSeries> _getDefaultLineSeries(List chartData) {
    return [
      LineSeries(
          dataSource: chartData,
          xValueMapper: (pieceData, index) => index,
          yValueMapper: (pieceData, _) => pieceData,
          ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }
}
