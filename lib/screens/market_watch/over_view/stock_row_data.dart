import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../provider/thems.dart';
import '../../../res/res.dart';

class StockRowTable extends ConsumerWidget {
  final String title;
  final String value;
  final bool showIcon;

  const StockRowTable(
      {super.key,
      required this.title,
      required this.value,
      required this.showIcon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack , 13, FontWeight.w500)),
          Text(
              showIcon
                  ? "₹${double.parse(value == "null" ? "0.00" : value).toStringAsFixed(2)}"
                  : double.parse(value == "null" ? "0.00" : value)
                      .toStringAsFixed(2),
              style: textStyle(const Color(0xff444444), 13, FontWeight.w500)),
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
