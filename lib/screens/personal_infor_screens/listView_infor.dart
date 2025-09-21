import 'package:flutter/material.dart';

class ListViewInfo extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController? controller;

  const ListViewInfo({super.key, required this.title, required this.description, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
                const SizedBox(height: 2),
                controller == null
                    ? Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: title == "Trạng thái" ? Colors.green : null,
                      ),
                    )
                    : SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(hintText: description, isDense: true),
                      ),
                    ),
              ],
            ),
          ),
          if (title == "Email") Opacity(opacity: 0.5, child: Icon(Icons.edit_document, size: 20)),
        ],
      ),
    );
  }
}
