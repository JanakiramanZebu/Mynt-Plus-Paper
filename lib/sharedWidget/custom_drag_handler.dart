import 'package:flutter/material.dart';

class CustomDragHandler extends StatelessWidget {
  const CustomDragHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 10),
            decoration: BoxDecoration(
                color: const Color(0xff999999),
                borderRadius: BorderRadius.circular(20)),
            height: 4,
            width: 36));
  }
}
