import 'package:flutter/material.dart';
import 'package:mynt_plus/res/web_colors.dart';

class SwapButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onTap;

  const SwapButton({
    super.key,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: (isDarkMode ? WebDarkColors.primary : WebColors.primary)
            .withOpacity(0.2),
        highlightColor: (isDarkMode ? WebDarkColors.primary : WebColors.primary)
            .withOpacity(0.1),
        child: Icon(
          Icons.swap_horiz,
          color: isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}
