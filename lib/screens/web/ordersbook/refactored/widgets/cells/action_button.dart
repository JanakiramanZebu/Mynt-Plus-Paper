import 'package:flutter/material.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_font_web.dart';

class ActionButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? iconWeight;
  final VoidCallback? onPressed;
  final ThemesProvider theme;

  const ActionButton({
    super.key,
    this.label,
    this.icon,
    required this.color,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.iconWeight,
    required this.onPressed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isLongLabel = label != null && label!.length > 1;
    final borderRadiusValue = borderRadius ?? 5.0;

    return SizedBox(
      width: isLongLabel ? null : 25,
      height: 25,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadiusValue),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            padding: isLongLabel ? const EdgeInsets.symmetric(horizontal: 8) : null,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: borderColor != null
                  ? Border.all(color: borderColor!, width: 1.3)
                  : null,
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      size: 16,
                      color: color,
                      weight: iconWeight ?? 400,
                    )
                  : Text(
                      label ?? "",
                      style: WebTextStyles.buttonXs(
                        isDarkTheme: theme.isDarkMode,
                        color: color,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
