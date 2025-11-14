import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ECGChartWidget extends StatefulWidget {
  final int channelIndex;
  final String legendTitle;
  final Color chartColor;
  final List<ChartData> chartData;
  final CrosshairBehavior crosshairBehavior;
  final double timeWindowSeconds;
  final Function(ChartSeriesController) onRendererCreated;

  const ECGChartWidget({
    Key? key,
    required this.channelIndex,
    required this.legendTitle,
    required this.chartColor,
    required this.chartData,
    required this.crosshairBehavior,
    required this.timeWindowSeconds,
    required this.onRendererCreated,
  }) : super(key: key);

  @override
  State<ECGChartWidget> createState() => _ECGChartWidgetState();
}

class _ECGChartWidgetState extends State<ECGChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A), // Dark background for ECG monitor look
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SfCartesianChart(
        backgroundColor: const Color(0xFF0A0A0A), // Dark ECG monitor background
        title: ChartTitle(
          text: widget.legendTitle,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(
            color: widget.chartColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        crosshairBehavior: widget.crosshairBehavior,
        plotAreaBorderWidth: 1,
        plotAreaBorderColor: Colors.grey[600],
        primaryXAxis: NumericAxis(
          title: AxisTitle(
            text: 'Time (seconds)',
            textStyle: TextStyle(color: Colors.grey[300], fontSize: 12),
          ),
          interval: widget.timeWindowSeconds / 5, // 5 intervals on x-axis
          interactiveTooltip: const InteractiveTooltip(enable: false),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[700]),
          minorGridLines: MinorGridLines(width: 0.3, color: Colors.grey[800]),
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 10),
          axisLine: AxisLine(color: Colors.grey[600]),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: 'Voltage (V)',
            textStyle: TextStyle(color: Colors.grey[300], fontSize: 12),
          ),
          interactiveTooltip: const InteractiveTooltip(enable: false),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[700]),
          minorGridLines: MinorGridLines(width: 0.3, color: Colors.grey[800]),
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 10),
          axisLine: AxisLine(color: Colors.grey[600]),
        ),
        series: [
          FastLineSeries<ChartData, double>(
            enableTooltip: false,
            onRendererCreated: (ChartSeriesController controller) {
              widget.onRendererCreated(controller);
            },
            legendItemText: widget.legendTitle,
            dataSource: widget.chartData,
            color: widget.chartColor,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            width: 1,
          ),
        ],
      ),
    );
  }
}
