import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';

class StockRowTable extends ConsumerWidget {
  final String title;
  final String value;
  final bool showIcon;
  final String? metricType; // Add metric type parameter

  const StockRowTable(
      {super.key,
      required this.title,
      required this.value,
      required this.showIcon,
      this.metricType});

  // Helper function to clean symbol (remove exchange prefix)
  String _cleanSymbol(String symbol) {
    String cleaned = symbol.contains(':') ? symbol.split(':')[1] : symbol;
    // Remove -EQ suffix if present
    return cleaned.replaceAll('-EQ', '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextWidget.subText(
              align: TextAlign.start,
              text: _cleanSymbol(title),
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              textOverflow: TextOverflow.ellipsis,
              maxLines: 1,
              theme: theme.isDarkMode,
              fw: 0,
            ),
          ),
          TextWidget.subText(
            text:  double.parse(value == "null" ? "0.00" : value).toStringAsFixed(2),
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 0,
          ),
        ],
      ),
    );
  }

 
}
