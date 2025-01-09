import "package:flutter/material.dart";

class ProgressBar extends StatelessWidget {
  final double value;
  final String title;

  const ProgressBar({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    Color progressColor;
    title == 'CARBS'
        ? progressColor = const Color(0xFFEFC10A)
        : title == 'PROTEIN'
            ? progressColor = const Color(0xFF67C7FF)
            : progressColor = const Color(0xFFF95454);
    String valueReal = value.toStringAsFixed(2) + 'g';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 16,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              height: 16,
              width: 100 * value,
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          valueReal,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
