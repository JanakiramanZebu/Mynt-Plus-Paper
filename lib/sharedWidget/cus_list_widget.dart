
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../res/res.dart';
import '../provider/thems.dart';

class ListWidgets extends StatelessWidget {
  final String text;
  const ListWidgets({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme=context.read(themeProvider);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.circle, size: 9.5)),
      const SizedBox(width: 8),
      Expanded(
          child: Text(text,
              style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 12, FontWeight.w500)))
    ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}