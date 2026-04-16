import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';

class StockRowTableWeb extends ConsumerWidget {
  final String title;
  final String value;
  final bool showIcon;
  final String? metricType;

  const StockRowTableWeb({
    super.key,
    required this.title,
    required this.value,
    required this.showIcon,
    this.metricType,
  });

  // Helper function to clean symbol (remove exchange prefix)
  String _cleanSymbol(String symbol) {
    String cleaned = symbol.contains(':') ? symbol.split(':')[1] : symbol;
    // Remove -EQ suffix if present
    return cleaned.replaceAll('-EQ', '');
  }

  // Helper function to format value properly
  String _formatValue(String value) {
    // Handle null or "null" string
    if (value == "null" || value.isEmpty) {
      return 'N/A';
    }

    // Try to parse as double and format
    final parsedValue = double.tryParse(value);
    if (parsedValue != null) {
      return parsedValue.toStringAsFixed(2);
    }

    // Return as is if can't parse
    return value;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _cleanSymbol(title),
              style: MyntWebTextStyles.body(
                context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: MyntFonts.medium,
              ),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Text(
            _formatValue(value),
            style: MyntWebTextStyles.body(
              context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
              fontWeight: MyntFonts.regular,
            ),
          ),
        ],
      ),
    );
  }
}
