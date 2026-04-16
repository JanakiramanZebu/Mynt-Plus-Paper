import 'package:flutter/material.dart';

import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../scalper_provider.dart';

/// Tab selector for indices (Nifty 50, Nifty Bank, Sensex)
class ScalperIndexSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const ScalperIndexSelector({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        ScalperProvider.indices.length,
        (index) => _buildTab(context, index),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final isSelected = selectedIndex == index;
    final indexConfig = ScalperProvider.indices[index];

    return GestureDetector(
      onTap: () => onIndexChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? resolveThemeColor(
                  context,
                  dark: MyntColors.primaryDark,
                  light: MyntColors.primary,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? null
              : Border.all(
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.divider,
                  ),
                ),
        ),
        child: Text(
          indexConfig.name,
          style: MyntWebTextStyles.body(
            context,
            fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.medium,
            color: isSelected
                ? Colors.white
                : resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
          ),
        ),
      ),
    );
  }
}
