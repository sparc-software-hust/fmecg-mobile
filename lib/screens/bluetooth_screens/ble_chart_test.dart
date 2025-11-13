import 'dart:async';
import 'dart:io';
import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:fmecg_mobile/generated/l10n.dart';
import 'package:fmecg_mobile/utils/files_management.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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
  List<ChartData> chartDataChannel = [];
  List<ChartData> chartDataChannel2 = [];

  late int count;
  ChartSeriesController? _chartSeriesController;
  ChartSeriesController? _chartSeriesController2;

  late StreamSubscription<List<int>> subscribeStream;
  final ScrollController _scrollController = ScrollController();

  List samples = [];
  bool isMeasuring = false;
  bool isUploaded = false;
  bool isCalculated = false;

  CrosshairBehavior crosshairBehavior = CrosshairBehavior(
    enable: true,
    lineType: CrosshairLineType.vertical,
    activationMode: ActivationMode.none,
    lineColor: const Color(0xFF010101),
    lineWidth: 2,
  );

  int countX = 1000;

  @override
  void initState() {
    count = 0;
    chartDataChannel = <ChartData>[];
    chartDataChannel2 = <ChartData>[];
    super.initState();
  }

  @override
  void dispose() {
    _clearDataInChart();
    subscribeStream.cancel();
    super.dispose();
  }

  _resetMeasuring() {
    _clearDataInChart();
    samples.clear();
    // FilesManagement.deleteFileRecord(widget.fileToSave);
    setState(() {
      isMeasuring = false;
      isCalculated = false;
    });
  }

  _handleSaveRecordInFile() async {
    subscribeStream.cancel();
    _clearDataInChart();

    await FilesManagement.handleSaveDataToFileV2(widget.fileToSave, samples);

    setState(() {
      samples.clear();
    });
    return Utils.showDialogWarningError(context, false, "Lỗi khi xử lý dữ liệu với Python");
  }

  _clearDataInChart({bool pauseStream = true}) {
    setState(() {
      chartDataChannel.clear();
      chartDataChannel2.clear();
      count = 0;
    });
    if (pauseStream) subscribeStream.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(PhosphorIcons.regular.arrowLeft), onPressed: () => Navigator.pop(context)),
        title: Text(S.current.measurementPage),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OneChart(
                xCount: countX,
                legendTitle: "Channel 1",
                setChartSeriesController: (c) => _chartSeriesController = c,
                chartData: chartDataChannel,
                crosshairBehavior: crosshairBehavior,
              ),
              const SizedBox(height: 20),
              SfSlider(
                min: 500,
                max: 1000,
                stepSize: 50,
                value: countX,
                interval: 50,
                showTicks: true,
                showLabels: true,
                activeColor: const Color(0xFF4f6bff),
                enableTooltip: true,
                minorTicksPerInterval: 0,
                onChanged: (dynamic value) {
                  _clearDataInChart(pauseStream: false);
                  setState(() {
                    countX = value.toInt();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (isMeasuring) {
                        _resetMeasuring();
                      } else {
                        setState(() {
                          isMeasuring = true;
                        });
                        subscribeCharacteristic();
                      }
                    },
                    child: Text(isMeasuring ? S.current.reset : S.current.measure),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void updateChartData(List dataChannelsToShowOnChart) {
    final int index = count % countX;
    ChartData newDataPPG = ChartData(index, (dataChannelsToShowOnChart[0]).toDouble());
    // ChartData newDataPCG = ChartData(index, (dataChannelsToShowOnChart[1]).toDouble());

    if (chartDataChannel.length == countX) {
      crosshairBehavior.showByIndex(index);
      chartDataChannel[index] = newDataPPG;

      _chartSeriesController?.updateDataSource(updatedDataIndexes: <int>[index]);
    } else {
      chartDataChannel.add(newDataPPG);
      _chartSeriesController?.updateDataSource(addedDataIndexes: <int>[chartDataChannel.length - 1]);
    }
    count = count + 1;
  }

  subscribeCharacteristic() {
    subscribeStream = flutterReactiveBle.subscribeToCharacteristic(widget.bluetoothCharacteristic).listen((value) {
      print('value:$value');
      // List<double> packetHandled = ECGDataController.handleDataRowFromBluetooth(value);
      // List dataChannelsToShowOnChart = ECGDataController.calculateDataPointToShow(packetHandled);
      // samples.add([0,	0, 0, 0, 0, 0, ...packetHandled]);
      // if (samples.length == 50000) {
      //   FilesManagement.handleSaveDataToFileV2(
      //       widget.fileToSave, samples);
      //   samples.clear();
      // }
      // if (count % 5 == 0) {
      // updateChartData(dataChannelsToShowOnChart);
      // }
    });
  }
}
