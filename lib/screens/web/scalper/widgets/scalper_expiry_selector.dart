import 'package:flutter/material.dart';

import '../../../../models/marketwatch_model/linked_scrips.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';

/// Dropdown selector for expiry dates
class ScalperExpirySelector extends StatelessWidget {
  final List<OptionExp> expiries;
  final OptionExp? selectedExpiry;
  final Function(OptionExp) onExpiryChanged;

  const ScalperExpirySelector({
    super.key,
    required this.expiries,
    required this.selectedExpiry,
    required this.onExpiryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: resolveThemeColor(
          context,
          dark: MyntColors.searchBgDark,
          light: MyntColors.searchBg,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: resolveThemeColor(
            context,
            dark: MyntColors.dividerDark,
            light: MyntColors.divider,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedExpiry?.exd,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary,
            ),
          ),
          dropdownColor: resolveThemeColor(
            context,
            dark: MyntColors.listItemBgDark,
            light: MyntColors.listItemBg,
          ),
          style: MyntWebTextStyles.body(
            context,
            fontWeight: MyntFonts.medium,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textPrimaryDark,
              light: MyntColors.textPrimary,
            ),
          ),
          items: expiries.map((exp) {
            return DropdownMenuItem<String>(
              value: exp.exd,
              child: Text(
                exp.exd ?? '',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.medium,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final expiry = expiries.firstWhere((e) => e.exd == value);
              onExpiryChanged(expiry);
            }
          },
        ),
      ),
    );
  }
}
