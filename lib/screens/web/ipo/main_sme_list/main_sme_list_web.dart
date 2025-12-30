// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';

import '../../../../models/ipo_model/ipo_mainstream_model.dart';
import '../../../../models/ipo_model/ipo_sme_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/stocks_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_font_web.dart';
import '../../../../res/web_colors.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'single_page_web.dart';
import '../../../Mobile/ipo/preclose_ipo/preclose_ipo_screen.dart';
import '../IPO_order_screen/ipo_order_screen_web.dart';

class MainSmeListCard extends ConsumerStatefulWidget {
  const MainSmeListCard({super.key});

  @override
  ConsumerState<MainSmeListCard> createState() => _MainSmeListCardState();
}

class _MainSmeListCardState extends ConsumerState<MainSmeListCard> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  String? _hoveredRowId;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      final ipos = ref.watch(ipoProvide);
      final mainstreamipo = ref.watch(ipoProvide);
      final theme = ref.watch(themeProvider);

      // Get filtered IPOs based on search
    final filteredIpos = _getFilteredIPOs(ipos, mainstreamipo, ref);

      List<dynamic> openIpos = filteredIpos.where((ipo) {
        if (ipo is! SMEIPO && ipo is! MainIPO) {
        return false;
        }
        return ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) == "Open";
      }).toList();

      List<dynamic> preOpenIpos = filteredIpos.where((ipo) {
        if (ipo is! SMEIPO && ipo is! MainIPO) {
        return false;
        }
      return ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) == "Pre-open";
      }).toList();

    // Combine all IPOs for table display
    List<dynamic> allIpos = [...openIpos, ...preOpenIpos];

    final preCloseMsg = ipos.ipoPreClose?.msg;
      final hasAnyData = openIpos.isNotEmpty ||
          preOpenIpos.isNotEmpty ||
        (preCloseMsg != null && preCloseMsg.isNotEmpty);

    if (ref.watch(stocksProvide).searchController.text.isNotEmpty &&
        ipos.ipoCommonSearchList.isEmpty) {
      return const Center(
          child: NoDataFound(),
        );
       }

      if (!hasAnyData) {
      return const Center(
          child: NoDataFound(),
        );
      }

    // Apply sorting
    final sortedIpos = _getSortedIPOs(allIpos);

    return SizedBox.expand(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            if (_hasPreCloseData(ipos)) ...[
              const ClosedIPOScreen(),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: _buildIPOTable(sortedIpos, theme, ipos, ref.read(transcationProvider)),
            ),
                ],
              ),
            ),
      );
  }

  List<dynamic> _getFilteredIPOs(
      IPOProvider ipos, IPOProvider mainstreamipo, WidgetRef ref) {
    if (ref.watch(stocksProvide).searchController.text.isNotEmpty &&
        ipos.ipoCommonSearchList.isNotEmpty) {
      return ipos.ipoCommonSearchList;
    }
    return mainstreamipo.mainsme;
  }

  bool _hasPreCloseData(IPOProvider ipos) {
    final preCloseMsg = ipos.ipoPreClose?.msg;
    return preCloseMsg != null && preCloseMsg.isNotEmpty;
  }

  List<dynamic> _getSortedIPOs(List<dynamic> ipos) {
    if (_sortColumnIndex == null) return ipos;

    final sorted = List<dynamic>.from(ipos);
    sorted.sort((a, b) {
      int comparison = 0;

      switch (_sortColumnIndex) {
        case 0: // Stock name
          final aName = _toTitleCase(a.name ?? "");
          final bName = _toTitleCase(b.name ?? "");
          comparison = aName.compareTo(bName);
          break;
        case 1: // Type
          final aType = a.key ?? "";
          final bType = b.key ?? "";
          comparison = aType.compareTo(bType);
          break;
        case 2: // IPO date
          final aDate = a.biddingEndDate ?? a.biddingStartDate ?? "";
          final bDate = b.biddingEndDate ?? b.biddingStartDate ?? "";
          comparison = aDate.compareTo(bDate);
          break;
        case 5: // Subscription (index 5 after Price range and Min. amount)
          final aSub = double.tryParse(a.totalsub ?? "0") ?? 0.0;
          final bSub = double.tryParse(b.totalsub ?? "0") ?? 0.0;
          comparison = aSub.compareTo(bSub);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  String _toTitleCase(String input) {
      return input
          .toLowerCase()
          .split(' ')
          .map((word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');
    }

  Widget _buildIPOTable(List<dynamic> ipos, ThemesProvider theme,
      IPOProvider ipoProvider, TranctionProvider upiProvider) {
    if (ipos.isEmpty) {
      return const Center(
        child: NoDataFound(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        const padding = 32.0;
        const headerHeight = 100.0;
        const spacing = 16.0;
        final tableHeight = screenHeight - padding - headerHeight - spacing;
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight =
            tableHeight > maxHeight ? maxHeight : (tableHeight > 400 ? tableHeight : 400.0);

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
              color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbVisibility: WidgetStateProperty.all(true),
                  trackVisibility: WidgetStateProperty.all(true),
                  thickness: WidgetStateProperty.all(6.0),
                  crossAxisMargin: 0.0,
                  mainAxisMargin: 0.0,
                  radius: const Radius.circular(3),
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    return theme.isDarkMode
                        ? WebDarkColors.textSecondary.withOpacity(0.3)
                        : WebColors.textSecondary.withOpacity(0.3);
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    return theme.isDarkMode
                        ? WebDarkColors.divider.withOpacity(0.1)
                        : WebColors.divider.withOpacity(0.1);
                  }),
                  trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                  minThumbLength: 48.0,
                ),
              ),
              child:               DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1200,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                fixedLeftColumns: 1,
                fixedColumnsColor: theme.isDarkMode
                    ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                    : WebColors.backgroundSecondary.withOpacity(0.8),
                showBottomBorder: true,
                horizontalScrollController: _horizontalScrollController,
                scrollController: _verticalScrollController,
                showCheckboxColumn: false,
                dataRowHeight: 56.0,
                headingRowColor: WidgetStateProperty.all(
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
                columns: _buildDataTable2Columns(theme),
                rows: _buildDataTable2Rows(ipos, theme, ipoProvider, upiProvider),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn2> _buildDataTable2Columns(ThemesProvider theme) {
    return [
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock name',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(0, theme),
          ],
        ),
        size: ColumnSize.L,
        fixedWidth: 300.0,
        onSort: (index, ascending) => _onSortTable(0, ascending),
      ),
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Type',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(1, theme),
          ],
        ),
        size: ColumnSize.S,
        onSort: (index, ascending) => _onSortTable(1, ascending),
      ),
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'IPO date',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(2, theme),
          ],
        ),
        size: ColumnSize.M,
        onSort: (index, ascending) => _onSortTable(2, ascending),
      ),
      DataColumn2(
        label: Text(
          'Price range (₹)',
          style: WebTextStyles.tableHeader(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text(
          'Min. amount',
          style: WebTextStyles.tableHeader(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Subscription',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(5, theme),
          ],
        ),
        size: ColumnSize.S,
        onSort: (index, ascending) => _onSortTable(5, ascending),
      ),
    ];
  }

  Widget _buildSortIcon(int columnIndex, ThemesProvider theme) {
    if (_sortColumnIndex == columnIndex) {
      return const SizedBox(width: 16);
    } else {
      return Icon(
        Icons.unfold_more,
        size: 16,
        color: theme.isDarkMode
            ? WebDarkColors.textSecondary.withOpacity(0.6)
            : WebColors.textSecondary.withOpacity(0.6),
      );
    }
  }

  List<DataRow2> _buildDataTable2Rows(List<dynamic> ipos, ThemesProvider theme,
      IPOProvider ipoProvider, TranctionProvider upiProvider) {
    return ipos.asMap().entries.map((entry) {
      final index = entry.key;
      final ipo = entry.value;
      final uniqueId = '${ipo.id ?? ""}$index';
      final isPreOpen = ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) == "Pre-open";
      final rowIsHovered = _hoveredRowId == uniqueId;

      return DataRow2(
        onTap: () => _onIPOTap(context, ipo, ipoProvider),
        color: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered) ||
              _hoveredRowId == uniqueId) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return Colors.transparent;
        }),
        cells: [
          // Stock name column with hover button
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowId = uniqueId),
              onExit: (_) => setState(() => _hoveredRowId = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
      children: [
        Expanded(
                        flex: rowIsHovered ? 1 : 2,
                        child: Tooltip(
                          message: _toTitleCase(ipo.name ?? ""),
                          child: Text(
                            _toTitleCase(ipo.name ?? ""),
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: WebFonts.medium,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      // Apply button on hover
                      IgnorePointer(
                        ignoring: !rowIsHovered,
                        child: AnimatedOpacity(
                          opacity: rowIsHovered ? 1 : 0,
                          duration: const Duration(milliseconds: 140),
                          child: _buildHoverButton(
                            label: isPreOpen ? 'Pre Apply' : 'Apply',
                            color: Colors.white,
                            backgroundColor: theme.isDarkMode
                                ? WebDarkColors.primary
                                : WebColors.primary,
                            onPressed: () => _onApplyPressed(context, ipo, ipoProvider, upiProvider),
                            theme: theme,
                          ),
                        ),
              ),
            ],
          ),
        ),
              ),
            ),
          ),
          // Type column (left-aligned)
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowId = uniqueId),
              onExit: (_) => setState(() => _hoveredRowId = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    ipo.key ?? "",
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                      fontWeight: WebFonts.medium,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // IPO date column
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowId = uniqueId),
              onExit: (_) => setState(() => _hoveredRowId = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    _formatIPODate(ipo),
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                      fontWeight: WebFonts.medium,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: false,
                  ),
                ),
              ),
            ),
          ),
          // Price range column
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowId = uniqueId),
              onExit: (_) => setState(() => _hoveredRowId = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    _formatPriceRange(ipo),
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                      fontWeight: WebFonts.medium,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Min. amount column
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowId = uniqueId),
              onExit: (_) => setState(() => _hoveredRowId = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMinAmount(ipo),
                        style: WebTextStyles.custom(
                          fontSize: 13,
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.medium,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_getLotSize(ipo) != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          "${_getLotSize(ipo)} Qty",
                          style: WebTextStyles.custom(
                            fontSize: 12,
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                            fontWeight: WebFonts.medium,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Subscription column
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowId = uniqueId),
              onExit: (_) => setState(() => _hoveredRowId = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    ipo.totalsub != null && ipo.totalsub.toString().isNotEmpty
                        ? "${ipo.totalsub}x"
                        : "-",
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                      fontWeight: WebFonts.medium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildHoverButton({
    String? label,
    IconData? icon,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    double? iconWeight,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    final isLongLabel = label != null && label.length > 1;
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
            padding:
                isLongLabel ? const EdgeInsets.symmetric(horizontal: 8) : null,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor,
                      width: 1.3,
                    )
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

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  String _formatDate(dynamic ipo, bool isPreOpen) {
    if (isPreOpen) {
      if (ipo.biddingStartDate == null || ipo.biddingStartDate.isEmpty) {
        return "-";
      }
      try {
        List<String> parts = ipo.biddingStartDate.split('-');
        if (parts.length >= 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          DateTime parsedDate = DateTime(year, month, day);
          return DateFormat('d MMM').format(parsedDate);
        }
      } catch (e) {
        return "-";
      }
    } else {
      if (ipo.biddingEndDate == null || ipo.biddingEndDate.isEmpty) {
        return "-";
      }
      try {
        if (ipo.biddingEndDate.length >= 11) {
          return ipo.biddingEndDate.substring(5, 11);
        }
      } catch (e) {
        return "-";
      }
    }
    return "-";
  }

  String _formatIPODate(dynamic ipo) {
    try {
      String? startDateStr = ipo.biddingStartDate;
      String? endDateStr = ipo.biddingEndDate;

      if (startDateStr == null || startDateStr.isEmpty ||
          endDateStr == null || endDateStr.isEmpty) {
        return "-";
      }

      // Parse start date (format: dd-MM-yyyy)
      List<String> startParts = startDateStr.split('-');
      if (startParts.length >= 3) {
        int startDay = int.parse(startParts[0]);
        int startMonth = int.parse(startParts[1]);
        int startYear = int.parse(startParts[2]);
        DateTime startDate = DateTime(startYear, startMonth, startDay);

        // Parse end date (format: EEE, dd MMM yyyy HH:mm:ss)
        DateTime endDate;
        try {
          endDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss").parse(endDateStr);
        } catch (e) {
          // Try alternative format if the above fails
          try {
            // Try parsing as dd-MM-yyyy if it's in that format
            List<String> endParts = endDateStr.split('-');
            if (endParts.length >= 3) {
              int endDay = int.parse(endParts[0]);
              int endMonth = int.parse(endParts[1]);
              int endYear = int.parse(endParts[2]);
              endDate = DateTime(endYear, endMonth, endDay);
            } else {
              return "-";
            }
          } catch (e2) {
            return "-";
          }
        }

        // Format with ordinal suffix
        String startDayStr = _getOrdinalSuffix(startDay);
        String endDayStr = _getOrdinalSuffix(endDate.day);

        // Format month and year
        String startMonthYear = DateFormat('MMM yyyy').format(startDate);
        String endMonthYear = DateFormat('MMM yyyy').format(endDate);

        // Check if same day
        bool isSameDay = startDate.year == endDate.year &&
            startDate.month == endDate.month &&
            startDate.day == endDate.day;

        // If same day, show: "28th Nov 2025"
        if (isSameDay) {
          return "$startDayStr $startMonthYear";
        }
        // If same month, show: "28th - 30th Nov 2025"
        else if (startMonthYear == endMonthYear) {
          return "$startDayStr - $endDayStr $endMonthYear";
        }
        // If different months, show: "28th Nov - 1st Dec 2025"
        else {
          return "$startDayStr $startMonthYear - $endDayStr $endMonthYear";
        }
      }
    } catch (e) {
      return "-";
    }
    return "-";
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "${day}th";
    }
    switch (day % 10) {
      case 1:
        return "${day}st";
      case 2:
        return "${day}nd";
      case 3:
        return "${day}rd";
      default:
        return "${day}th";
    }
  }

  String _formatPriceRange(dynamic ipo) {
    try {
      String? minPrice = ipo.minPrice;
      String? maxPrice = ipo.maxPrice;

      if (minPrice == null || minPrice.isEmpty || maxPrice == null || maxPrice.isEmpty) {
        return "-";
      }

      // Remove any decimal points if they're .00
      double min = double.tryParse(minPrice) ?? 0;
      double max = double.tryParse(maxPrice) ?? 0;

      String minStr = min == min.toInt() ? min.toInt().toString() : min.toStringAsFixed(2);
      String maxStr = max == max.toInt() ? max.toInt().toString() : max.toStringAsFixed(2);

      return "$minStr - $maxStr";
    } catch (e) {
      return "-";
    }
  }

  String _formatMinAmount(dynamic ipo) {
    try {
      String? minValue = ipo.minvalue ?? ipo.minValue;
      if (minValue == null || minValue.isEmpty) {
        return "-";
      }

      double amount = double.tryParse(minValue) ?? 0;
      String amountStr = amount == amount.toInt() 
          ? amount.toInt().toString() 
          : amount.toStringAsFixed(2);

      return "₹$amountStr";
    } catch (e) {
      return "-";
    }
  }

  String? _getLotSize(dynamic ipo) {
    try {
      String? lotSize = ipo.lotSize;
      if (lotSize == null || lotSize.isEmpty) {
        return null;
      }
      return lotSize;
    } catch (e) {
      return null;
    }
  }

  Future<void> _onIPOTap(
      BuildContext context, dynamic ipo, IPOProvider ipoProvider) async {
    await ipoProvider.getIpoSinglePage(ipoName: "${ipo.name}");

      if (context.mounted) {
      _showIPODetailsDialog(
        context,
        ipo,
        ipoProvider,
      );
    }
  }

  void _showIPODetailsDialog(
    BuildContext context,
    dynamic ipo,
    IPOProvider ipoProvider,
  ) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry dialogOverlayEntry;

    dialogOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Consumer(
          builder: (context, ref, _) {
            final currentTheme = ref.watch(themeProvider);
            return Stack(
          children: [
                // Backdrop
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      dialogOverlayEntry.remove();
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                // Dialog centered
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 700,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.85,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: currentTheme.isDarkMode
                            ? WebDarkColors.surface
                            : WebColors.surface,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.85,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Header with Company Info
                            Consumer(
                              builder: (context, ref, _) {
                                final ipoProvider = ref.watch(ipoProvide);
                                final singlePageData = ipoProvider.iposinglepage?.data;
                                
                                // Safely access the data - check if it's a Map
                                String companyName = ipo.name ?? '';
                                String? imageLink = ipo.imageLink;
                                
                                if (singlePageData != null && singlePageData is Map) {
                                  try {
                                    final name = singlePageData['Company Name'];
                                    if (name != null) {
                                      companyName = name.toString();
                                    }
                                  } catch (e) {
                                    // If access fails, use ipo.name
                                  }
                                  
                                  try {
                                    final imgLink = singlePageData['image_link'];
                                    if (imgLink != null) {
                                      imageLink = imgLink.toString();
                                    }
                                  } catch (e) {
                                    // If access fails, use ipo.imageLink
                                  }
                                }
                                final status = ipostartdate(
                                  ipo.biddingStartDate ?? '',
                                  ipo.biddingEndDate ?? '',
                                );
                                final isOpen = status == "Open";
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: currentTheme.isDarkMode
                                            ? WebDarkColors.divider
                                            : WebColors.divider,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Company Logo
                                      if (imageLink != null && imageLink.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: ClipOval(
                                            child: Container(
                                              color: currentTheme.isDarkMode
                                                  ? WebDarkColors.divider
                                                  : WebColors.divider,
                                              width: 50,
                                              height: 50,
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                child: CachedNetworkImage(
                                                  imageUrl: imageLink,
                                                  memCacheWidth: 100,
                                                  memCacheHeight: 100,
                                                  placeholder: (context, url) => const Center(
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                  errorWidget: (context, url, error) => const SizedBox(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Company Name and Status
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              companyName,
                                              style: WebTextStyles.sub(
                                                isDarkTheme: currentTheme.isDarkMode,
                                                color: currentTheme.isDarkMode
                                                    ? WebDarkColors.textPrimary
                                                    : WebColors.textPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  ipo.key ?? '',
                                                  style: WebTextStyles.bodySmall(
                                                    isDarkTheme: currentTheme.isDarkMode,
                                                    color: currentTheme.isDarkMode
                                                        ? WebDarkColors.textSecondary
                                                        : WebColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isOpen
                                                        ? (currentTheme.isDarkMode
                                                            ? WebDarkColors.profit
                                                            : WebColors.profit)
                                                            .withOpacity(0.2)
                                                        : (currentTheme.isDarkMode
                                                            ? WebDarkColors.loss
                                                            : WebColors.loss)
                                                            .withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    status.toUpperCase(),
                                                    style: WebTextStyles.bodySmall(
                                                      isDarkTheme: currentTheme.isDarkMode,
                                                      color: isOpen
                                                          ? (currentTheme.isDarkMode
                                                              ? WebDarkColors.profit
                                                              : WebColors.profit)
                                                          : (currentTheme.isDarkMode
                                                              ? WebDarkColors.loss
                                                              : WebColors.loss),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Close Button
                                      Material(
                                        color: Colors.transparent,
                                        shape: const CircleBorder(),
                                        child: InkWell(
                                          customBorder: const CircleBorder(),
                                          splashColor: currentTheme.isDarkMode
                                              ? Colors.white.withOpacity(.15)
                                              : Colors.black.withOpacity(.15),
                                          highlightColor: currentTheme.isDarkMode
                                              ? Colors.white.withOpacity(.08)
                                              : Colors.black.withOpacity(.08),
                                          onTap: () {
                                            dialogOverlayEntry.remove();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.close,
                                              size: 18,
                                              color: currentTheme.isDarkMode
                                                  ? WebDarkColors.iconSecondary
                                                  : WebColors.iconSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // Content
                            Flexible(
            child: MainSmeSinglePage(
              pricerange:
                                    "${double.parse(ipo.minPrice ?? "0").toInt()} - ${double.parse(ipo.maxPrice ?? "0").toInt()}",
              mininv:
                                    convertCurrencyINRStandard(mininv(double.parse(ipo.minPrice ?? "0").toDouble(), int.parse(ipo.minBidQuantity ?? "0").toInt()).toInt()),
                                enddate: "${ipo.biddingEndDate ?? ""}",
                                startdate: "${ipo.biddingStartDate ?? ""}",
                                ipotype: "${ipo.key ?? ""}",
                                ipodetails: jsonEncode(ipo),
                                isDialog: true, // Mark as dialog to skip DraggableScrollableSheet
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    overlay.insert(dialogOverlayEntry);
  }

  Future<void> _onApplyPressed(BuildContext context, dynamic ipo,
      IPOProvider ipoProvider, TranctionProvider upiProvider) async {
    ipoProvider.setisSMEPlaceOrderBtnActiveValue = false;
    ipoProvider.setisMainIPOPlaceOrderBtnActiveValue = false;

    await upiProvider.fetchupiIdView(
      upiProvider.bankdetails?.dATA?[upiProvider.indexss][1] ?? "",
      upiProvider.bankdetails?.dATA?[upiProvider.indexss][2] ?? "",
    );

    if (ipo.key == "SME") {
      await ipoProvider.smeipocategory();
      if (context.mounted) {
        UnifiedIpoOrderScreen.showDraggable(
          context: context,
          ipoData: ipo,
        );
      }
    } else {
      await ipoProvider.mainipocategory();
      if (context.mounted) {
        UnifiedIpoOrderScreen.showDraggable(
          context: context,
          ipoData: ipo,
        );
      }
    }
  }
}
