import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../provider/thems.dart';
import '../res/global_font_web.dart';
import '../res/web_colors.dart';

class CustomTextBtnWeb extends ConsumerWidget {
  final String label;
  final Function onPress;
  final String icon;
  const CustomTextBtnWeb({
    super.key,
    required this.label,
    required this.onPress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        hoverColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.1),
        splashColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.2),
        onTap: () {
          onPress();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: WebTextStyles.sub(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                icon,
                width: 16,
                height: 16,
                color: theme.isDarkMode
                    ? WebDarkColors.iconSecondary
                    : WebColors.iconSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
