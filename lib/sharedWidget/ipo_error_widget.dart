import 'package:flutter/material.dart';

import 'functions.dart';

class IpoErrorBadge extends StatelessWidget {
  final String errorName;
  const IpoErrorBadge({super.key, required this.errorName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: const Color(0xfffff3e0),
          borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xfffb8c00),
            size: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(errorName,
                style: textStyle(const Color(0xfffb8c00), 13, FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
