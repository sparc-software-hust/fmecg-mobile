import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:flutter/material.dart';

class PreviewCalculation extends StatefulWidget {
  const PreviewCalculation({super.key});

  @override
  State<PreviewCalculation> createState() => _PreviewCalculationState();
}

class _PreviewCalculationState extends State<PreviewCalculation> {
  int sbpNumber = 100;
  int dbpNumber = 100;
  int heartRateNumber = 100;
  int deviationNumber = 100;
  @override
  Widget build(BuildContext context) {
    double position = calculateIndicatorPosition(sbpNumber, dbpNumber);
    return Scaffold(
      appBar: AppBar(title: const Text("Kết quả đo"), centerTitle: true),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          // Sử dụng SingleChildScrollView để có thể cuộn nếu nội dung quá dài
          child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  "Tổng quan",
                  style: TextStyle(color: ColorConstant.primary, fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              const SizedBox(height: 10),
              BloodPressureIndicator(indicatorPosition: position),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberCard(
                    number: sbpNumber,
                    text: "Tâm thu",
                    subText: "mmHg",
                    color1: Colors.red,
                    percentage: sbpNumber / 250,
                  ),
                  NumberCard(
                    number: dbpNumber,
                    text: "Tâm trương",
                    subText: "mmHg",
                    color1: Colors.blue,
                    percentage: dbpNumber / 200,
                  ),
                ],
              ),
              const SizedBox(height: 40), // Khoảng cách giữa hai hàng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberCard(
                    number: heartRateNumber,
                    text: "Nhịp tim",
                    subText: "bpm",
                    color1: Colors.green,
                    percentage: heartRateNumber / 150,
                  ),
                  NumberCard(
                    number: deviationNumber,
                    text: "Biến thiên",
                    subText: "bpm",
                    color1: Colors.purple,
                    percentage: deviationNumber / 150,
                  ),
                ],
              ),
              const SizedBox(height: 10), // Thêm một khoảng cách nếu cần
              const BloodPressureLegendTable(),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
}

class NumberCard extends StatelessWidget {
  final int number;
  final String text;
  final String subText;
  final Color color1; // Màu sắc cho phần đã đạt
  final double percentage; // Phần trăm tiến độ, ví dụ: 170/200

  const NumberCard({
    super.key,
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
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0, color: Colors.black)),
                const SizedBox(height: 10),
                Text(
                  '$number',
                  style: const TextStyle(fontSize: 19.0, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Text(subText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0, color: Colors.black)),
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

  CircleProgressPainter({required this.progressAngle, required this.progressColor, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke;

    Paint progressPaint =
        Paint()
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
      canvas.drawRect(Rect.fromLTWH(i * sectionWidth, 0, sectionWidth, size.height), paint);
    }

    // Vẽ vạch chỉ thị
    double indicatorX = indicatorPosition * size.width;
    Paint indicatorPaint =
        Paint()
          ..color = Colors.black54
          ..strokeWidth = 3;
    canvas.drawLine(Offset(indicatorX, 0), Offset(indicatorX, size.height), indicatorPaint);
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
    // double iconPosition = screenWidth * indicatorPosition; // Adjust for the icon's size

    return Stack(
      children: [
        SizedBox(
          width: double.infinity, // Full width
          height: 20, // Increased height to accommodate the icon
          child: CustomPaint(painter: BloodPressureIndicatorPainter(indicatorPosition: indicatorPosition)),
        ),
        Transform.translate(
          offset: Offset(
            screenWidth * indicatorPosition - 45 * (indicatorPosition + 0.2),
            25,
          ), // Giả sử icon có kích thước là 24x24 pixels
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
      columns: const [
        DataColumn(label: Text('')),
        DataColumn(label: Text('Trạng thái')),
        DataColumn(label: Text('PPG/PCG')),
      ],
      rows: [
        DataRow(
          cells: [
            const DataCell(CircleAvatar(backgroundColor: Colors.purple)),
            DataCell(Text('Huyết Áp Cực Kỳ Cao', style: textStyle)),
            DataCell(Text('> 180 hoặc > 120', style: textStyle)),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(CircleAvatar(backgroundColor: Colors.redAccent)),
            DataCell(Text('Tăng Huyết Áp Độ 2', style: textStyle)),
            DataCell(Text('>= 140 hoặc >= 90', style: textStyle)),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(CircleAvatar(backgroundColor: Colors.orange)),
            DataCell(Text('Tăng Huyết Áp Độ 1', style: textStyle)),
            DataCell(Text('>= 130 hoặc >= 80', style: textStyle)),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(CircleAvatar(backgroundColor: Colors.yellow)),
            DataCell(Text('Huyết Áp Cao', style: textStyle)),
            DataCell(Text('>= 120', style: textStyle)),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(CircleAvatar(backgroundColor: Colors.green)),
            DataCell(Text('Bình Thường', style: textStyle)),
            DataCell(Text('< 120', style: textStyle)),
          ],
        ),
      ],
    );
  }
}
