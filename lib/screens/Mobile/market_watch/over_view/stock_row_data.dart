import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';

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
          

               TextWidget.paraText(
                      text:title ,                     
                      theme: theme.isDarkMode,
                      fw: 0),	
               TextWidget.paraText(
                      text: showIcon
                  ? "₹${double.parse(value == "null" ? "0.00" : value).toStringAsFixed(2)}"
                  : double.parse(value == "null" ? "0.00" : value)
                      .toStringAsFixed(2) ,
                      color:Color(0xff444444) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
        ],
      ),
    );
  }

 
}
