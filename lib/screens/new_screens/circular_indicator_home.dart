import 'package:flutter/material.dart';

class CircularIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center, // Centers the text
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              value: 0.75, // This represents 75% progress, adjust accordingly
              strokeWidth: 10,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF0067FF)),
              backgroundColor: Colors.grey[200],
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '1284',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                'Left',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: Scaffold(body: CircularIndicator())));
