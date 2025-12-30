import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';

/// Base table widget that provides common DataTable2 structure
/// Used by all order book tables (Open, Executed, Trade, GTT)
class BaseOrderTable extends StatelessWidget {
  final List<DataColumn2> columns;
  final List<DataRow2> rows;
  final ScrollController? horizontalScrollController;
  final ScrollController? verticalScrollController;
  final int fixedLeftColumns;
  final double minWidth;
  final ThemesProvider theme;

  const BaseOrderTable({
    super.key,
    required this.columns,
    required this.rows,
    this.horizontalScrollController,
    this.verticalScrollController,
    this.fixedLeftColumns = 1,
    this.minWidth = 1200,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height
        final screenHeight = MediaQuery.of(context).size.height;
        final padding = 32.0;
        final headerHeight = 50.0;
        final spacing = 16.0;
        final bottomMargin = 20.0;
        final tableHeight = screenHeight - padding - headerHeight - spacing - bottomMargin;

        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            height: calculatedHeight.toDouble(),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.isDarkMode
                    ? WebDarkColors.divider
                    : WebColors.divider,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
              color: theme.isDarkMode
                  ? WebDarkColors.background
                  : Colors.white,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbVisibility: MaterialStateProperty.all(true),
                  trackVisibility: MaterialStateProperty.all(true),
                  thickness: MaterialStateProperty.all(6.0),
                  crossAxisMargin: 0.0,
                  mainAxisMargin: 0.0,
                  radius: const Radius.circular(3),
                  thumbColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode
                        ? WebDarkColors.textSecondary.withOpacity(0.3)
                        : WebColors.textSecondary.withOpacity(0.3);
                  }),
                  trackColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode
                        ? WebDarkColors.divider.withOpacity(0.1)
                        : WebColors.divider.withOpacity(0.1);
                  }),
                  trackBorderColor: MaterialStateProperty.all(Colors.transparent),
                  minThumbLength: 48.0,
                ),
              ),
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: minWidth,
                sortColumnIndex: null,
                sortAscending: true,
                fixedLeftColumns: fixedLeftColumns,
                fixedColumnsColor: theme.isDarkMode
                    ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                    : WebColors.backgroundSecondary.withOpacity(0.8),
                showBottomBorder: true,
                horizontalScrollController: horizontalScrollController,
                scrollController: verticalScrollController,
                showCheckboxColumn: false,
                headingRowColor: MaterialStateProperty.all(
                  theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary.withOpacity(0.05),
                ),
                headingTextStyle: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
                dataTextStyle: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
                border: TableBorder(
                  top: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  horizontalInside: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                ),
                columns: columns,
                rows: rows,
              ),
            ),
          ),
        );
      },
    );
  }
}

