import 'package:flutter/material.dart';

class ListViewInfo extends StatelessWidget {
  final String title;
  final String description;
  const ListViewInfo(
      {super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 2),
                Text(description,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: title == "Trạng thái" ? Colors.green : null,
                    )),
              ],
            ),
            const Spacer(),
            if (title == "Email")
              Opacity(
                  opacity: 0.5,
                  child: const Icon(Icons.edit_document, size: 20)),
          ],
        ));
  }
}
