import 'package:flutter/material.dart';

import 'functions.dart';

class CustBadge extends StatelessWidget {
  final String badgeName;
  const CustBadge({super.key,required this.badgeName});

  @override
  Widget build(BuildContext context) {
    return Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: const Color(0xffF1F3F8)),
                              child: Text(badgeName,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyle(const Color(0xff666666), 10,
                                      0)));
  }
}