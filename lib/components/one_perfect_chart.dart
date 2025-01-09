import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OneChart extends StatefulWidget {
  const OneChart({
    super.key,
    required this.setChartSeriesController,
    required this.chartData,
    this.legendTitle = "",
    required this.crosshairBehavior,
    this.xCount = 500
  });

  final Function(ChartSeriesController) setChartSeriesController;
  final List<ChartData> chartData;
  final String legendTitle;
  final CrosshairBehavior crosshairBehavior;
  final int xCount;

  @override
  State<OneChart> createState() => _OneChartState();
}

class _OneChartState extends State<OneChart> {

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(
        text: "Channel 1",
        textStyle: const TextStyle(color: Colors.white),
        alignment: ChartAlignment.center,
      ),
      crosshairBehavior: widget.crosshairBehavior,
      backgroundColor: const Color(0xFF010101),
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
        labelStyle: const TextStyle(color: Colors.white),
        interactiveTooltip: const InteractiveTooltip(enable: false),
        axisLine: const AxisLine(width: 2, color: Color(0xFF7a935a)),
        minimum: 0,
        maximum: widget.xCount.toDouble(),
        interval: 50,
        edgeLabelPlacement: EdgeLabelPlacement.none,
        minorGridLines: const MinorGridLines(width: 0, color: Color(0xFF7a935a)),
        majorGridLines: const MajorGridLines(width: 1, color: Color(0xFF7a935a)),
        majorTickLines: const MajorTickLines(size: 5, width: 2, color: Color(0xFF7a935a))
      ),
      primaryYAxis: const NumericAxis(
        labelStyle: TextStyle(color: Colors.white),
        interactiveTooltip: InteractiveTooltip(enable: false),
        minimum: -0.05,
        maximum: 0.05,
        interval: 0.01,
        axisLine: AxisLine(width: 2, color: Color(0xFF7a935a)),
        majorGridLines: MajorGridLines(width: 1, color: Color(0xFF7a935a)),
        minorGridLines: MinorGridLines(width: 0, color: Color(0xFF7a935a)),
        majorTickLines: MajorTickLines(size: 5, width: 2, color: Color(0xFF7a935a)),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),
      series: [
        FastLineSeries<ChartData, int>(
          onRendererCreated: widget.setChartSeriesController,
          dataSource: widget.chartData,
          legendItemText: widget.legendTitle,
          xValueMapper: (ChartData d, _) => d.x,
          yValueMapper: (ChartData d, _) => d.y,
          animationDuration: 0,
          width: 2,
          color: const Color(0xFF2EC35D)
        )
      ]
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double y;
}
