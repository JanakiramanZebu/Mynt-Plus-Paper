// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../models/ipo_model/ipo_mainstream_model.dart';
import '../../../../models/ipo_model/ipo_sme_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/stocks_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
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
      return ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) ==
          "Pre-open";
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
        color: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasPreCloseData(ipos)) ...[
              const ClosedIPOScreen(),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: _buildIPOTable(
                  sortedIpos, theme, ipos, ref.read(transcationProvider)),
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
        final width = constraints.maxWidth;
        // Allocation: Name (40%), Date (20%), Price (20%), Min (20%)
        final nameWidth = width * 0.40;
        final dateWidth = width * 0.20;
        final priceWidth = width * 0.20;
        final minWidth = width * 0.20;

        final columnWidths = {
          0: shadcn.FixedTableSize(nameWidth),
          1: shadcn.FixedTableSize(dateWidth),
          2: shadcn.FixedTableSize(priceWidth),
          3: shadcn.FixedTableSize(minWidth),
        };

        return shadcn.OutlinedContainer(
          child: Column(
            children: [
              shadcn.Table(
                columnWidths: columnWidths,
                defaultRowHeight: const shadcn.FixedTableSize(50),
                rows: [
                  shadcn.TableHeader(
                    cells: [
                      _buildHeaderCell("Stock name", 0, theme),
                      _buildHeaderCell("IPO date", 1, theme),
                      _buildHeaderCell("Price range", -1, theme,
                          alignRight: true),
                      _buildHeaderCell("Min. amount", -1, theme,
                          alignRight: true),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: shadcn.Table(
                    columnWidths: columnWidths,
                    defaultRowHeight: const shadcn.FixedTableSize(65),
                    rows: ipos.asMap().entries.map((entry) {
                      return _buildShadcnRow(entry.value, entry.key, theme,
                          ipoProvider, upiProvider);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Header text style
  // 14px, weight 600, MyntColors for text
  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
      darkColor: color ?? MyntColors.textSecondaryDark,
      lightColor: color ?? MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  shadcn.TableCell _buildHeaderCell(
      String text, int sortIndex, ThemesProvider theme,
      {bool alignRight = false}) {
    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: sortIndex >= 0
            ? () => _onSortTable(sortIndex, !_sortAscending)
            : null,
        child: Container(
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.03),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: _getHeaderStyle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  shadcn.TableRow _buildShadcnRow(dynamic ipo, int index, ThemesProvider theme,
      IPOProvider ipoProvider, TranctionProvider upiProvider) {
    final uniqueId = '${ipo.id ?? ""}$index';
    final isPreOpen =
        ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) == "Pre-open";
    final status =
        ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) ?? "Closed";
    final rowIsHovered = _hoveredRowId == uniqueId;

    return shadcn.TableRow(
      cells: [
        // Stock Name Cell
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: rowIsHovered,
          theme: theme,
          onTap: () => _onIPOTap(context, ipo, ipoProvider),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _toTitleCase(ipo.name ?? ""),
                      style: MyntWebTextStyles.bodyMedium(
                        context,
                        fontWeight: MyntFonts.medium,
                        color: rowIsHovered
                            ? resolveThemeColor(context,
                                dark: MyntColors.primary,
                                light: MyntColors.primary)
                            : resolveThemeColor(context,
                                dark: MyntColors.textPrimaryDark,
                                light: MyntColors.textPrimary),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (ipo.symbol != null) ...[
                          Text(
                            ipo.symbol ?? "",
                            style: MyntWebTextStyles.bodySmall(
                              context,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary),
                              fontWeight: MyntFonts.medium,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          ipo is SMEIPO ? "SME" : "IPO",
                          style: MyntWebTextStyles.bodySmall(
                            context,
                            color: resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary),
                            fontWeight: MyntFonts.medium,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: MyntWebTextStyles.bodySmall(
                            context,
                            color: resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary),
                            fontWeight: MyntFonts.medium,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                    backgroundColor: resolveThemeColor(context,
                        dark: MyntColors.primary, light: MyntColors.primary),
                    onPressed: () =>
                        _onApplyPressed(context, ipo, ipoProvider, upiProvider),
                    theme: theme,
                  ),
                ),
              ),
            ],
          ),
        ),
        // IPO Date Cell
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: rowIsHovered,
          theme: theme,
          onTap: () => _onIPOTap(context, ipo, ipoProvider),
          child: Text(
            _formatIPODate(ipo),
            style: MyntWebTextStyles.bodyMedium(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
              fontWeight: MyntFonts.medium,
            ),
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ),
        // Price Range Cell
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: rowIsHovered,
          theme: theme,
          alignRight: true,
          onTap: () => _onIPOTap(context, ipo, ipoProvider),
          child: Text(
            _formatPriceRange(ipo),
            style: MyntWebTextStyles.bodyMedium(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
              fontWeight: MyntFonts.medium,
            ),
          ),
        ),
        // Min Amount Cell
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: rowIsHovered,
          theme: theme,
          alignRight: true,
          onTap: () => _onIPOTap(context, ipo, ipoProvider),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatMinAmount(ipo),
                style: MyntWebTextStyles.bodyMedium(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
                  fontWeight: MyntFonts.medium,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (_getLotSize(ipo) != null) ...[
                const SizedBox(height: 1),
                Text(
                  "${_getLotSize(ipo)} Qty",
                  style: MyntWebTextStyles.bodySmall(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                    fontWeight: MyntFonts.medium,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  shadcn.TableCell _buildShadcnCell({
    required Widget child,
    required String uniqueId,
    required bool rowIsHovered,
    required ThemesProvider theme,
    VoidCallback? onTap,
    bool alignRight = false,
  }) {
    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredRowId = uniqueId),
        onExit: (_) => setState(() => _hoveredRowId = null),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: rowIsHovered
                ? resolveThemeColor(context,
                        dark: MyntColors.primary, light: MyntColors.primary)
                    .withOpacity(theme.isDarkMode ? 0.06 : 0.10)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            width: double.infinity,
            height: double.infinity,
            child: Align(
              alignment:
                  alignRight ? Alignment.centerRight : Alignment.centerLeft,
              child: child,
            ),
          ),
        ),
      ),
    );
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
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        color: color,
                        fontWeight: MyntFonts.bold,
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

  String _formatIPODate(dynamic ipo) {
    try {
      String? startDateStr = ipo.biddingStartDate;
      String? endDateStr = ipo.biddingEndDate;

      if (startDateStr == null ||
          startDateStr.isEmpty ||
          endDateStr == null ||
          endDateStr.isEmpty) {
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

      if (minPrice == null ||
          minPrice.isEmpty ||
          maxPrice == null ||
          maxPrice.isEmpty) {
        return "-";
      }

      // Remove any decimal points if they're .00
      double min = double.tryParse(minPrice) ?? 0;
      double max = double.tryParse(maxPrice) ?? 0;

      String minStr =
          min == min.toInt() ? min.toInt().toString() : min.toStringAsFixed(2);
      String maxStr =
          max == max.toInt() ? max.toInt().toString() : max.toStringAsFixed(2);

      return "₹$minStr - ₹$maxStr";
    } catch (e) {
      return "-";
    }
  }

  String _formatMinAmount(dynamic ipo) {
    try {
      String? minValue = ipo.minvalue;

      // Check if it's missing or effectively empty
      if (minValue == null ||
          minValue.isEmpty ||
          minValue == "null" ||
          minValue == "0") {
        minValue = ipo.minValue;
      }

      // Fallback: Calculate from price and quantity if direct field is missing
      if (minValue == null ||
          minValue.isEmpty ||
          minValue == "null" ||
          minValue == "0") {
        final minPrice = double.tryParse(ipo.minPrice ?? "0") ?? 0;
        // Search for minBidQuantity, fallback to lotSize
        final minQty =
            double.tryParse(ipo.minBidQuantity ?? ipo.lotSize ?? "0") ?? 0;

        if (minPrice > 0 && minQty > 0) {
          minValue = (minPrice * minQty).toString();
        }
      }

      if (minValue == null || minValue.isEmpty || minValue == "null") {
        return "-";
      }

      double amount = double.tryParse(minValue) ?? 0;
      if (amount <= 0) return "-";

      // Display as whole number if possible, otherwise 2 decimals
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
      // Priority: lotSize, fallback to minBidQuantity
      String? lotSize = ipo.lotSize ?? ipo.minBidQuantity;
      if (lotSize == null || lotSize.isEmpty || lotSize == "null") {
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
                        color: resolveThemeColor(context,
                            dark: MyntColors.backgroundColorDark,
                            light: MyntColors.backgroundColor),
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
                                final singlePageData =
                                    ipoProvider.iposinglepage?.data;

                                // Safely access the data - check if it's a Map
                                String companyName = ipo.name ?? '';
                                String? imageLink = ipo.imageLink;

                                if (singlePageData != null &&
                                    singlePageData is Map) {
                                  try {
                                    final name = singlePageData['Company Name'];
                                    if (name != null) {
                                      companyName = name.toString();
                                    }
                                  } catch (e) {
                                    // If access fails, use ipo.name
                                  }

                                  try {
                                    final imgLink =
                                        singlePageData['image_link'];
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: resolveThemeColor(context,
                                            dark: MyntColors.dividerDark,
                                            light: MyntColors.divider),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Company Logo
                                      if (imageLink != null &&
                                          imageLink.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 12),
                                          child: ClipOval(
                                            child: Container(
                                              color: resolveThemeColor(context,
                                                  dark: MyntColors.dividerDark,
                                                  light: MyntColors.divider),
                                              width: 50,
                                              height: 50,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: CachedNetworkImage(
                                                  imageUrl: imageLink,
                                                  memCacheWidth: 100,
                                                  memCacheHeight: 100,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const SizedBox(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Company Name and Status
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              companyName,
                                              style: MyntWebTextStyles.titlesub(
                                                context,
                                                color: resolveThemeColor(
                                                    context,
                                                    dark: MyntColors
                                                        .textPrimaryDark,
                                                    light:
                                                        MyntColors.textPrimary),
                                                fontWeight: MyntFonts.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  ipo.key ?? '',
                                                  style: MyntWebTextStyles
                                                      .bodySmall(
                                                    context,
                                                    color: resolveThemeColor(
                                                        context,
                                                        dark: MyntColors
                                                            .textSecondaryDark,
                                                        light: MyntColors
                                                            .textSecondary),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isOpen
                                                        ? resolveThemeColor(
                                                                context,
                                                                dark: MyntColors
                                                                    .profit,
                                                                light:
                                                                    MyntColors
                                                                        .profit)
                                                            .withOpacity(0.2)
                                                        : resolveThemeColor(
                                                                context,
                                                                dark: MyntColors
                                                                    .loss,
                                                                light:
                                                                    MyntColors
                                                                        .loss)
                                                            .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    status.toUpperCase(),
                                                    style: MyntWebTextStyles
                                                        .bodySmall(
                                                      context,
                                                      color: isOpen
                                                          ? resolveThemeColor(
                                                              context,
                                                              dark: MyntColors
                                                                  .profit,
                                                              light: MyntColors
                                                                  .profit)
                                                          : resolveThemeColor(
                                                              context,
                                                              dark: MyntColors
                                                                  .loss,
                                                              light: MyntColors
                                                                  .loss),
                                                      fontWeight:
                                                          MyntFonts.semiBold,
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
                                          highlightColor: currentTheme
                                                  .isDarkMode
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
                                              color: resolveThemeColor(context,
                                                  dark: MyntColors.iconDark,
                                                  light: MyntColors.icon),
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
                                mininv: convertCurrencyINRStandard(mininv(
                                        double.parse(ipo.minPrice ?? "0")
                                            .toDouble(),
                                        int.parse(ipo.minBidQuantity ?? "0")
                                            .toInt())
                                    .toInt()),
                                enddate: "${ipo.biddingEndDate ?? ""}",
                                startdate: "${ipo.biddingStartDate ?? ""}",
                                ipotype: "${ipo.key ?? ""}",
                                ipodetails: jsonEncode(ipo),
                                isDialog:
                                    true, // Mark as dialog to skip DraggableScrollableSheet
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
