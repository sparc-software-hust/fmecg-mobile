import 'dart:async';
import 'dart:io';
import 'package:fmecg_mobile/components/one_perfect_chart.dart';
import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:fmecg_mobile/controllers/ecg_data_controller.dart';
import 'package:fmecg_mobile/generated/l10n.dart';
import 'package:fmecg_mobile/utils/files_management.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const platform = MethodChannel("com.example.method_channel/java");

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

  String _textSBP = '';
  String _textDBP = '';
  String _textHeartRate = '';
  String _textDeviation = '';

  CrosshairBehavior crosshairBehavior = CrosshairBehavior(
    enable: true,
    lineType: CrosshairLineType.vertical,
    activationMode: ActivationMode.none,
    lineColor: const Color(0xFF010101),
    lineWidth: 2,
  );

  int countX = 1000;

  bool isNotSetupPhoneNumber = false;

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

    // OverlayEntry overlayLoadingWidget = Utils.setOverlayLoadingWithHeavyTask();
    // try {
    //   Overlay.of(context).insert(overlayLoadingWidget);
    //   final bytesInFile = await widget.fileToSave.readAsBytes();
    //   final data = await platform.invokeMethod('helloWorldPython', {'bytes': bytesInFile});
    //   if (data != null) {
    //     setState(() {
    //       isCalculated = true;
    //       _textSBP = data!["sbp"].toString();
    //       _textDBP = data!["dbp"].toString();
    //       _textHeartRate = data!["heart_rate"].toString();
    //       _textDeviation = data!["standard_deviation"].toString();
    //     });
    //   }
    //   overlayLoadingWidget.remove();
    // } catch (e) {
    //   overlayLoadingWidget.remove();
    //   Utils.showDialogWarningError(context, false, "Lỗi khi xử lý dữ liệu với Python");
    // }
  }

  _clearDataInChart({bool pauseStream = true}) {
    setState(() {
      chartDataChannel.clear();
      chartDataChannel2.clear();
      count = 0;
    });
    if (pauseStream) subscribeStream.pause();
  }

  _getPhoneNumberFromPrefs() async {
    const String keyInit = "phone_number_warning";
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final bool isExistPhoneNumber = preferences.containsKey(keyInit);
    if (isExistPhoneNumber) {
      String phoneNumber = preferences.getString(keyInit)!;
      return phoneNumber;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(PhosphorIcons.regular.arrowLeft),
              onPressed: () => Navigator.pop(context)
          ),
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
                  crosshairBehavior: crosshairBehavior
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
                  onChanged: (dynamic value){
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
                        child: Text(isMeasuring ? S.current.reset : S.current.measure)
                    ),
                    // ElevatedButton(
                    //     onPressed: isMeasuring == false ? null : () async {
                    //
                    //       await _handleSaveRecordInFile();
                    //
                    //       if (isCalculated) {
                    //         final snackBar = SnackBar(
                    //           duration: const Duration(seconds: 2),
                    //           content: Text(S.current.saveDataToStorage),
                    //         );
                    //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    //
                    //         int sbpNumber = double.parse(_textSBP).round();
                    //         int dbpNumber = double.parse(_textDBP).round();
                    //         int heartRateNumber = double.parse(_textHeartRate).round();
                    //         int deviationNumber = double.parse(_textDeviation).round();
                    //         double position = calculateIndicatorPosition(sbpNumber, dbpNumber);
                    //
                    //         final bool isNormalPressure = sbpNumber < 120 && dbpNumber < 80;
                    //         final bool isHighPressure =  sbpNumber >= 120 && sbpNumber < 130 && dbpNumber < 80;
                    //         final bool isHighPressure1 =  sbpNumber >= 130 && sbpNumber < 140 && dbpNumber >= 80 && dbpNumber < 90;
                    //         final bool isHighPressure2 = sbpNumber > 140 && dbpNumber > 90;
                    //         final bool isHighPressure3 = sbpNumber > 180 && dbpNumber > 120;
                    //         final bool isNormalHeartRate = heartRateNumber >= 60 && heartRateNumber <= 100;
                    //         final bool isLowHeartRate = heartRateNumber < 60 ;
                    //         final bool isHighHeartRate = heartRateNumber > 100 ;
                    //         final bool isManyHeartRate = deviationNumber > 50 ;
                    //
                    //         String smsMessage = "";
                    //         if (isHighPressure || isHighPressure1 || isHighPressure2 || isHighPressure3 ||
                    //             isLowHeartRate || isHighHeartRate || isManyHeartRate) {
                    //           smsMessage = "Thông báo về tình trạng sức khỏe: ";
                    //           if (isHighPressure) {
                    //             smsMessage += "Huyết áp cao. ";
                    //           } else if (isHighPressure1) {
                    //             smsMessage += "Tăng huyết áp Độ 1. ";
                    //           } else if (isHighPressure2) {
                    //             smsMessage += "Tăng huyết áp Độ 2. ";
                    //           } else if (isHighPressure3) {
                    //             smsMessage += "Huyết áp cực kỳ cao! ";
                    //           }
                    //
                    //           if (isLowHeartRate) {
                    //             smsMessage += "Nhịp tim thấp. ";
                    //           } else if (isHighHeartRate) {
                    //             smsMessage += "Nhịp tim cao. ";
                    //           }
                    //
                    //           if (isManyHeartRate) {
                    //             smsMessage += "Sự chênh lệch lớn trong nhịp tim. ";
                    //           }
                    //
                    //           // _fetchAndSendLocation(smsMessage);
                    //         }
                    //
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (BuildContext ctxxx) {
                    //               return Scaffold(
                    //                 appBar: AppBar(
                    //                   title: Text(S.current.result),
                    //                   centerTitle: true,
                    //                 ),
                    //                 body: Container(
                    //                   padding: const EdgeInsets.all(20),
                    //                   child: SingleChildScrollView( // Sử dụng SingleChildScrollView để có thể cuộn nếu nội dung quá dài
                    //                     child: Column(
                    //                       children: [
                    //                         Container(
                    //                           alignment: Alignment.topLeft,
                    //                           child: Text(
                    //                             S.current.general,
                    //                             style: TextStyle(
                    //                                 color: ColorConstant.primary,
                    //                                 fontWeight: FontWeight.bold,
                    //                                 fontSize: 22),
                    //                           ),
                    //                         ),
                    //                         const SizedBox(height: 10),
                    //                         BloodPressureIndicator(indicatorPosition: position),
                    //                         const SizedBox(height: 40),
                    //                         Row(
                    //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //                           children: [
                    //                             NumberCard(number: sbpNumber, text: S.current.systolic, subText: "mmHg", color1: Colors.red, percentage: sbpNumber/250),
                    //                             NumberCard(number: dbpNumber, text: S.current.diastolic, subText: "mmHg", color1: Colors.blue, percentage: dbpNumber/200),
                    //                           ],
                    //                         ),
                    //                         const SizedBox(height: 30), // Khoảng cách giữa hai hàng
                    //                         Row(
                    //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //                           children: [
                    //                             NumberCard(number: heartRateNumber, text: S.current.heartbeat, subText: "bpm", color1: Colors.green, percentage: heartRateNumber/150),
                    //                             NumberCard(number: deviationNumber, text: S.current.variability, subText: "bpm", color1: Colors.purple, percentage: deviationNumber/150),
                    //                           ],
                    //                         ),
                    //                         const SizedBox(height: 10),
                    //                         const BloodPressureLegendTable(),
                    //                       ],
                    //                       mainAxisAlignment: MainAxisAlignment.center,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //         ); 
                    //         }
                    //       },
                    //       child: Text(S.current.saveAndCalculate)
                    //   )
                    ],
                  ),
                const SizedBox(height: 20),
                if (isCalculated)
                  Column(
                    children: [
                      Text("${S.current.dataProcessed}:"),
                      const SizedBox(height: 5),
                      Text("SBP: $_textSBP"),
                      Text("DBP: $_textDBP"),
                      Text("Heart Rate: $_textHeartRate"),
                      Text("Deviation: $_textDeviation"),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
              ],
            ),
          ),
        )
    );
  }

  void updateChartData(List dataChannelsToShowOnChart) {
    // ChartData newData = ChartData(microTimeInserted, dataChannelsToShowOnChart[0]);
    // ChartData newData2 = ChartData(microTimeInserted, dataChannelsToShowOnChart[2]);
    // chartDataChannel.add(newData);
    // chartDataChannel2!.add(newData2);

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
    subscribeStream = flutterReactiveBle.subscribeToCharacteristic(
      widget.bluetoothCharacteristic).listen((value) {
        List<double> packetHandled = ECGDataController.handleDataRowFromBluetooth(value);
        print('value:$value');
        List dataChannelsToShowOnChart = ECGDataController.calculateDataPointToShow(packetHandled);
        // samples.add([0,	0, 0, 0, 0, 0, ...packetHandled]);
        // if (samples.length == 50000) {
        //   FilesManagement.handleSaveDataToFileV2(
        //       widget.fileToSave, samples);
        //   samples.clear();
        // }
        // if (count % 5 == 0) {
        updateChartData(dataChannelsToShowOnChart);
        // }
      }
    );
  }
}

class NumberCard extends StatelessWidget {
  final int number;
  final String text;
  final String subText;
  final Color color1;
  final double percentage;

  const NumberCard({super.key, 
    required this.number,
    required this.text,
    required this.subText,
    required this.color1,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    // Tính toán góc cho phần tiến trình
    double progressAngle = 2 * 3.14 * percentage;
    return Center(
      child: CustomPaint(
        size: const Size(130, 130), // Kích thước của CustomPaint
        painter: CircleProgressPainter(
          progressAngle: progressAngle,
          progressColor: color1,
          backgroundColor: Colors.grey[300]!,
        ),
        child: Container(
          width: 110.0,
          height: 110.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 19.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progressAngle;
  final Color progressColor;
  final Color backgroundColor;

  CircleProgressPainter({
    required this.progressAngle,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    canvas.drawCircle(center, radius, backgroundPaint);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14 / 2, progressAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ImageCard extends StatelessWidget {
  final String imageAsset;
  final Function() functionScanBluetooth;
  final Function() temporaryNothing;

  const ImageCard({super.key, 
    required this.imageAsset,
    required this.functionScanBluetooth,
    required this.temporaryNothing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorConstant.quinary,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Image.asset(
            imageAsset,
            width: double.infinity,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 12.0),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: functionScanBluetooth,
                child: const Text("Thực hiện đo"),
              ),
              ElevatedButton(
                onPressed: temporaryNothing,
                child: const Text("Thử đo"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BloodPressureIndicatorPainter extends CustomPainter {
  final double indicatorPosition; // Giá trị từ 0 (bắt đầu) đến 1 (kết thúc) của thanh

  BloodPressureIndicatorPainter({required this.indicatorPosition});

  @override
  void paint(Canvas canvas, Size size) {
    const List<Color> colors = [
      Colors.green, // Bình thường
      Colors.yellow, // Huyết áp cao
      Colors.orange, // Tăng huyết áp Độ 1
      Colors.redAccent, // Tăng huyết áp Độ 2
      Colors.purple, // Huyết áp cực kỳ cao
    ];

    double sectionWidth = size.width / colors.length;

    // Vẽ thanh ngang đa màu
    for (int i = 0; i < colors.length; i++) {
      Paint paint = Paint()..color = colors[i];
      canvas.drawRect(
        Rect.fromLTWH(i * sectionWidth, 0, sectionWidth, size.height),
        paint,
      );
    }

    // Vẽ vạch chỉ thị
    double indicatorX = indicatorPosition * size.width;
    Paint indicatorPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(indicatorX, 0),
      Offset(indicatorX, size.height),
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BloodPressureIndicator extends StatelessWidget {
  final double indicatorPosition; // Value from 0 to 1 for blood pressure level

  const BloodPressureIndicator({Key? key, required this.indicatorPosition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the icon's horizontal position based on the indicatorPosition
    // Assuming the total width is the screen width for simplicity
    double screenWidth = MediaQuery.of(context).size.width;
    double iconPosition = screenWidth * indicatorPosition; // Adjust for the icon's size

    return Stack(
      children: [
        SizedBox(
          width: double.infinity, // Full width
          height: 20, // Increased height to accommodate the icon
          child: CustomPaint(
            painter: BloodPressureIndicatorPainter(indicatorPosition: indicatorPosition),
          ),
        ),
        Transform.translate(
          offset: Offset(screenWidth * indicatorPosition - 40 * indicatorPosition - 11.5, 25), // Giả sử icon có kích thước là 24x24 pixels
          child: const Icon(
            Icons.favorite,
            color: Colors.pink,
            size: 24, // Kích thước của icon
          ),
        ),
      ],
    );
  }
}

double calculateIndicatorPosition(int sbpNumber, int dbpNumber) {
  if (sbpNumber > 180 || dbpNumber > 120) {
    return 0.9; // Huyết áp cực kỳ cao
  } else if (sbpNumber >= 140 || dbpNumber >= 90) {
    return 0.7; // Tăng huyết áp Độ 2
  } else if (sbpNumber >= 130 || dbpNumber >= 80) {
    return 0.5; // Tăng huyết áp Độ 1
  } else if (sbpNumber >= 120) {
    return 0.3; // Huyết áp cao
  } else {
    return 0.1; // Bình thường
  }
}

class BloodPressureLegendTable extends StatelessWidget {
  const BloodPressureLegendTable({super.key});

  @override
  Widget build(BuildContext context) {
    // Tùy chỉnh cỡ chữ ở đây
    TextStyle textStyle = const TextStyle(fontSize: 10); // Giảm cỡ chữ xuống còn 14

    return DataTable(
      columns: [
        const DataColumn(label: Text('')),
        DataColumn(label: Text(S.current.status)),
        const DataColumn(label: Text('PPG/PCG')),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(CircleAvatar(backgroundColor: Colors.purple)),
          DataCell(Text(S.current.extremelyHigh, style: textStyle)),
          DataCell(Text('> 180 ${S.current.or} > 120', style: textStyle)),
        ]),
        DataRow(cells: [
          const DataCell(CircleAvatar(backgroundColor: Colors.redAccent)),
          DataCell(Text("${S.current.hypertension} ${S.current.level.toLowerCase()} 2", style: textStyle)),
          DataCell(Text('>= 140 ${S.current.or} >= 90', style: textStyle)),
        ]),
        DataRow(cells: [
          const DataCell(CircleAvatar(backgroundColor: Colors.orange)),
          DataCell(Text("${S.current.hypertension} ${S.current.level.toLowerCase()} 1", style: textStyle)),
          DataCell(Text('>= 130 ${S.current.or} >= 80', style: textStyle)),
        ]),
        DataRow(cells: [
          const DataCell(CircleAvatar(backgroundColor: Colors.yellow)),
          DataCell(Text(S.current.hypertension, style: textStyle)),
          DataCell(Text('>= 120', style: textStyle)),
        ]),
        DataRow(cells: [
          const DataCell(CircleAvatar(backgroundColor: Colors.green)),
          DataCell(Text(S.current.normal, style: textStyle)),
          DataCell(Text('< 120', style: textStyle)),
        ]),
      ],
    );
  }
}