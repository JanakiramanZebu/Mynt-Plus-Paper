import 'package:flutter/material.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';

// Hoverable navigation item widget
class HoverableNavItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDarkMode;

  const HoverableNavItem({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<HoverableNavItem> createState() => _HoverableNavItemState();
}

class _HoverableNavItemState extends State<HoverableNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDarkMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.title,
            style: WebTextStyles.sub(
              isDarkTheme: theme,
              color: widget.isActive
                  ? (theme ? WebDarkColors.primary : WebColors.primary)
                  : (_isHovered
                      ? (theme ? WebDarkColors.primary : WebColors.primary)
                          .withOpacity(0.8)
                      : (theme
                          ? WebDarkColors.textPrimary
                          : WebColors.textSecondary)),
              fontWeight: widget.isActive ? WebFonts.bold : WebFonts.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}
