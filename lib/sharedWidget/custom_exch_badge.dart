import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/thems.dart'; 

class CustomExchBadge extends StatelessWidget {
  final String exch;
  const CustomExchBadge({super.key, required this.exch});

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: theme.isDarkMode
              ? const Color(0xff666666).withOpacity(.1)
              : const Color(0xffF1F3F8)),
      child: Text(exch,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: textStyle(
              theme.isDarkMode
                  ? const Color(0xffFFFFFF)
                  : const Color(0xff666666),
              10,
              FontWeight.w500)),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
