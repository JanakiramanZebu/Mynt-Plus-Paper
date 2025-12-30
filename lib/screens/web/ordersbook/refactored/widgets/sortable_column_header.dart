import 'package:flutter/material.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import '../models/sort_config.dart';

/// Reusable sortable column header widget
class SortableColumnHeader extends StatelessWidget {
  final String header;
  final int columnIndex;
  final SortConfig sortConfig;
  final ValueNotifier<int?> hoveredColumnIndex;
  final VoidCallback onSort;
  final ThemesProvider theme;
  final bool isNumeric;

  const SortableColumnHeader({
    super.key,
    required this.header,
    required this.columnIndex,
    required this.sortConfig,
    required this.hoveredColumnIndex,
    required this.onSort,
    required this.theme,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => hoveredColumnIndex.value = columnIndex,
        onExit: (_) => hoveredColumnIndex.value = null,
        child: Tooltip(
          message: 'Sort by $header',
          child: GestureDetector(
            onTap: onSort,
            behavior: HitTestBehavior.opaque,
            child: ValueListenableBuilder<int?>(
              valueListenable: hoveredColumnIndex,
              builder: (context, hoveredIndex, child) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: hoveredIndex == columnIndex
                        ? (theme.isDarkMode
                            ? WebDarkColors.primary.withOpacity(0.1)
                            : WebColors.primary.withOpacity(0.05))
                        : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              header,
                              style: WebTextStyles.tableHeader(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textSecondary,
                              ),
                              textAlign: isNumeric ? TextAlign.right : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 16,
                              child: _buildSortIcon(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortIcon() {
    IconData icon;
    Color color;

    if (sortConfig.sortColumnIndex == columnIndex) {
      icon = sortConfig.sortAscending ? Icons.arrow_upward : Icons.arrow_downward;
      color = theme.isDarkMode ? WebDarkColors.primary : WebColors.primary;
    } else {
      icon = Icons.unfold_more;
      color = theme.isDarkMode
          ? WebDarkColors.iconSecondary.withOpacity(0.6)
          : WebColors.iconSecondary.withOpacity(0.6);
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }
}

