import 'package:flutter/material.dart';

class CircularAvatar extends StatelessWidget {
  final String imageAsset;
  final double radius;

  const CircularAvatar({Key? key, required this.imageAsset, this.radius = 10.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.asset(imageAsset),
    );
  }
}