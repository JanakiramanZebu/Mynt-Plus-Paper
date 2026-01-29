import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/no_data_found.dart';


// Bond Table based on TableExample1 (hold_table.dart)
class BondsTableWeb extends ConsumerStatefulWidget {
  final List<dynamic> bondsData;
  final String? searchQuery;
  final String bondType; // 'G-Sec', 'T-Bill', etc. for display
  final Function(dynamic bond)? onApplyTap; // Callback when Apply/Buy is tapped

  const BondsTableWeb({
    super.key,
    required this.bondsData,
    this.searchQuery,
    required this.bondType,
    this.onApplyTap,
  });

  @override
  ConsumerState<BondsTableWeb> createState() => _BondsTableWebState();
}

class _BondsTableWebState extends ConsumerState<BondsTableWeb> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  // PERFORMANCE FIX: Use ValueNotifier for hover instead of setState
  // setState causes full widget rebuild, ValueNotifier only rebuilds hover-dependent parts
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);

  // Track the popover controller to close it when row is unhovered
  shadcn.PopoverController? _activePopoverController;
  int? _popoverRowIndex;
  bool _isHoveringDropdown = false;
  Timer? _popoverCloseTimer;

  // Scroll controllers - must be in state to persist across rebuilds
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();
    _hoveredRowIndex.addListener(_onHoverChanged);
  }

  void _onHoverChanged() {
    if (_activePopoverController != null) {
      final currentHover = _hoveredRowIndex.value;
      if (currentHover == _popoverRowIndex) {
        _cancelPopoverCloseTimer();
        return;
      }
      if (_isHoveringDropdown) {
        _cancelPopoverCloseTimer();
        return;
      }
      _startPopoverCloseTimer();
    }
  }

  void _startPopoverCloseTimer() {
    _cancelPopoverCloseTimer();
    _popoverCloseTimer = Timer(const Duration(milliseconds: 150), () {
      if (!_isHoveringDropdown && _hoveredRowIndex.value != _popoverRowIndex) {
        _closePopover();
      }
    });
  }

  void _cancelPopoverCloseTimer() {
    _popoverCloseTimer?.cancel();
    _popoverCloseTimer = null;
  }

  void _closePopover() {
    _cancelPopoverCloseTimer();
    try {
      _activePopoverController?.close();
    } catch (_) {}
    final needsRebuild = _activePopoverController != null || _popoverRowIndex != null;
    _activePopoverController = null;
    _popoverRowIndex = null;
    _isHoveringDropdown = false;
    if (needsRebuild && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cancelPopoverCloseTimer();
    _hoveredRowIndex.removeListener(_onHoverChanged);
    _hoveredRowIndex.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }




  // Standardized text style helpers
  TextStyle _getTextStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? WebColors.textPrimaryDark,
      lightColor: color ?? WebColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }

  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
      darkColor: color ?? WebColors.textSecondaryDark,
      lightColor: color ?? WebColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  // Builds a bordered cell; amounts can be right-aligned by passing true.
  shadcn.TableCell buildCell(Widget child, [bool alignRight = false]) {
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
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: alignRight ? Alignment.topRight : null,
        child: child,
      ),
    );
  }

  // Builds a cell with hover detection that covers the entire cell including padding
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
  }) {
    // Add extra horizontal padding for first and last columns
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 3; // Adjusted for 4 columns

    // For first column (Instrument), use more left padding, minimal right padding
    // For last column, use minimal left padding, more right padding (mirror of first)
    // For other columns, use minimal padding
    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding =
          const EdgeInsets.fromLTRB(16, 8, 4, 8); // More left, minimal right
    } else if (isLastColumn) {
      cellPadding =
          const EdgeInsets.fromLTRB(4, 8, 16, 8); // Minimal left, more right
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
    }

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
        onEnter: (_) => _hoveredRowIndex.value = rowIndex,
        onExit: (_) => _hoveredRowIndex.value = null,
        child: ValueListenableBuilder<int?>(
          valueListenable: _hoveredRowIndex,
          builder: (context, hoveredIndex, _) {
            final isRowHovered = hoveredIndex == rowIndex;

            return Container(
              padding: cellPadding,
              color: isRowHovered
                  ? resolveThemeColor(context,
                      dark: MyntColors.primary.withValues(alpha: 0.08),
                      light: MyntColors.primary.withValues(alpha: 0.08))
                  : null,
              alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft, // Changed to centerRight/Left for better vertical alignment
              child: child,
            );
          },
        ),
      ),
    );
  }

  // Builds a sortable header cell with sort indicator
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    // Add extra horizontal padding for first and last columns
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 3; // Adjusted for 4 columns

    // Match the cell padding logic - first column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding =
          const EdgeInsets.fromLTRB(16, 6, 8, 6); // More left, minimal right
    } else if (isLastColumn) {
      headerPadding =
          const EdgeInsets.fromLTRB(8, 6, 16, 6); // Minimal left, more right
    } else {
      headerPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6);
    }

    // Header Background Color Fix as requested
     final headerBgColor = resolveThemeColor(
      context,
      dark: const Color(0xff0D0D0D), // Dark header bg
      light: const Color(0xffF9FAFB), // Light header bg from image
    );

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
      child: Container( // Wrap with Container for background color
        color: headerBgColor,
        child: InkWell(
          onTap: () => _onSort(columnIndex),
          child: Container(
            padding: headerPadding,
            alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment:
                  alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (alignRight && _sortColumnIndex == columnIndex)
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: resolveThemeColor(context,
                        dark: WebColors.textSecondaryDark,
                        light: WebColors.textSecondary),
                  ),
                if (alignRight && _sortColumnIndex == columnIndex)
                  const SizedBox(width: 4),
                Text(
                  label,
                  style: _getHeaderStyle(context),
                ),
                if (!alignRight && _sortColumnIndex == columnIndex)
                  const SizedBox(width: 4),
                if (!alignRight && _sortColumnIndex == columnIndex)
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: resolveThemeColor(context,
                        dark: WebColors.textSecondaryDark,
                        light: WebColors.textSecondary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  // Builds the name cell with hover action buttons (Apply + Dropdown) - matching hold_table.dart style
  Widget _buildNameCellWithActions(dynamic bond, int index) {
    return ValueListenableBuilder<int?>(
      valueListenable: _hoveredRowIndex,
      builder: (context, hoveredIndex, _) {
        final isHovered = hoveredIndex == index || _popoverRowIndex == index;

        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Bond name and series - full width
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(right: isHovered ? 40.0 : 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bond.name ?? '',
                        style: _getTextStyle(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        bond.series ?? '',
                        style: MyntWebTextStyles.para(
                          context,
                          darkColor: WebColors.textSecondaryDark,
                          lightColor: WebColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              // Action button - positioned on the right (matching hold_table.dart style)
              if (isHovered)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildOptionsMenuButton(bond, index),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Build the 3-dot options menu button with shadcn dropdown
  Widget _buildOptionsMenuButton(dynamic bond, int rowIndex) {
    return Builder(
      builder: (buttonContext) {
        return GestureDetector(
          onTap: () {
            // Close any existing popover first
            _closePopover();

            // Build menu items
            List<shadcn.MenuItem> menuItems = [];
            final iconColor = resolveThemeColor(context,
                dark: WebColors.textPrimaryDark,
                light: WebColors.textPrimary);
            final textColor = resolveThemeColor(context,
                dark: WebColors.textPrimaryDark,
                light: WebColors.textPrimary);

            // Apply option
            menuItems.add(
              _buildMenuButton(
                icon: Icons.check_circle_outline,
                title: 'Apply',
                iconColor: iconColor,
                textColor: textColor,
                onPressed: (ctx) {
                  _closePopover();
                  if (widget.onApplyTap != null) {
                    widget.onApplyTap!(bond);
                  }
                },
              ),
            );

            // Create a controller for this popover
            final controller = shadcn.PopoverController();
            _activePopoverController = controller;
            _popoverRowIndex = rowIndex;

            // Show the shadcn popover menu anchored to this button
            controller.show(
              context: buttonContext,
              alignment: Alignment.topRight,
              offset: const Offset(0, 4),
              builder: (ctx) {
                return MouseRegion(
                  onEnter: (_) {
                    _isHoveringDropdown = true;
                    _cancelPopoverCloseTimer();
                  },
                  onExit: (_) {
                    _isHoveringDropdown = false;
                    // Start delayed close
                    _startPopoverCloseTimer();
                  },
                  child: shadcn.DropdownMenu(
                    children: menuItems,
                  ),
                );
              },
            );

            // Force rebuild to show row highlight
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: MyntColors.primary.withValues(alpha: 0.1),
                  light: MyntColors.primary.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.more_vert,
              size: 18,
              color: resolveThemeColor(context,
                  dark: WebColors.textPrimaryDark,
                  light: WebColors.textPrimary),
            ),
          ),
        );
      },
    );
  }

  // Helper method for building menu buttons
  shadcn.MenuButton _buildMenuButton({
    required IconData icon,
    required String title,
    required void Function(BuildContext) onPressed,
    required Color iconColor,
    required Color textColor,
  }) {
    return shadcn.MenuButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: MyntWebTextStyles.body(
                context,
                fontWeight: MyntFonts.medium,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to measure text width dynamically
  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  // Calculate minimum column widths dynamically based on header and data
  Map<int, double> _calculateMinWidths(
      List<dynamic> bonds, BuildContext context) {
    // Use table cell style for measurement (size 14, Geist)
    final textStyle = MyntWebTextStyles.tableCell(context);
    const padding =
        24.0; // Padding for cell content (8px on each side + some extra)
    const sortIconWidth =
        24.0; // Extra space for sort indicator icon (16px icon + 4px gap + buffer)

    // Header texts
    final headers = [
      'Bonds name',
      'BID date', // Merged Start/End date as BID date
      'Min. Invest',
      'Lot Size',
    ];

    final minWidths = <int, double>{};

    // Calculate width for each column (simplified logic for bonds)
    // 0: Bonds name
    // 1: BID date (Start & End)
    // 2: Min Invest
    // 3: Lot Size

    // Column 0: Name (Wide)
     double maxWidth0 = _measureTextWidth(headers[0], textStyle) + sortIconWidth + padding;
     for (final bond in bonds) {
        final name = bond.name ?? '';
         final series = bond.series ?? '';
         final w = _measureTextWidth(name, textStyle);
         final w2 = _measureTextWidth(series, textStyle);
         if(w > maxWidth0) maxWidth0 = w;
         if(w2 > maxWidth0) maxWidth0 = w2;
     }
     minWidths[0] = maxWidth0 + 100; // Extra Buffer for name

    // Column 1: BID Date (Wide, contains two dates)
    // Estimate width for two date columns text "Start date 27-01-2026" + spacing
    minWidths[1] = 250.0;

    // Column 2: Min Invest
    minWidths[2] = 120.0;

    // Column 3: Lot Size
    minWidths[3] = 100.0;

    return minWidths;
  }

  @override
  Widget build(BuildContext context) {
    var displayBonds = List.from(widget.bondsData);

     // Apply search filter if search query is provided
    final searchQuery = widget.searchQuery?.toLowerCase().trim() ?? '';
    if (searchQuery.isNotEmpty) {
      displayBonds = displayBonds.where((bond) {
        final name = bond.name?.toLowerCase() ?? '';
        final series = bond.series?.toLowerCase() ?? '';
        return name.contains(searchQuery) || series.contains(searchQuery);
      }).toList();
    }


    // Sort holdings based on selected column
    if (_sortColumnIndex != null) {
      displayBonds.sort((a, b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0: // Name
             comparison = (a.name ?? '').compareTo(b.name ?? '');
            break;
           // Add other cases if needed
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: shadcn.OutlinedContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically based on actual content
          final minWidths = _calculateMinWidths(displayBonds, context);

          // Available width
          final availableWidth = constraints.maxWidth;

          // Steps similar to hold_table.dart to distribute width...
          final columnWidths = <int, double>{};
          for (int i = 0; i < 4; i++) {
            columnWidths[i] = minWidths[i] ?? 100.0;
          }
          final totalMinWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
          if (totalMinWidth < availableWidth) {
              final extraSpace = availableWidth - totalMinWidth;
               // Distribute extra space mainly to Name and Date
              columnWidths[0] = columnWidths[0]! + extraSpace * 0.4;
               columnWidths[1] = columnWidths[1]! + extraSpace * 0.4;
               columnWidths[2] = columnWidths[2]! + extraSpace * 0.1;
               columnWidths[3] = columnWidths[3]! + extraSpace * 0.1;
          }

          return Column(
              children: [
                // Fixed Header
                SizedBox(
                  height: 50,
                  child: shadcn.Table(
                    columnWidths: {
                      0: shadcn.FixedTableSize(columnWidths[0]!),
                      1: shadcn.FixedTableSize(columnWidths[1]!),
                      2: shadcn.FixedTableSize(columnWidths[2]!),
                      3: shadcn.FixedTableSize(columnWidths[3]!),
                    },
                    defaultRowHeight: const shadcn.FixedTableSize(50),
                    rows: [
                      shadcn.TableHeader(
                        cells: [
                          buildHeaderCell('Bonds name', 0),
                          buildHeaderCell('BID date', 1),
                          buildHeaderCell('Min. Invest', 2, true),
                          buildHeaderCell('Lot Size', 3, true),
                        ],
                      ),
                    ],
                  ),
                ),
                // Scrollable Body (vertical scroll)
                Expanded(
                  child: displayBonds.isEmpty
                      ? Center(
                          child: NoDataFound(
                            title: searchQuery.isNotEmpty ? "No Bonds Found" : "No Bonds Listed",
                            subtitle: searchQuery.isNotEmpty
                                ? "No bonds match your search \"$searchQuery\"."
                                : "There are no active bond listings at the moment.",
                            primaryEnabled: false,
                            secondaryEnabled: false,
                          ),
                        )
                      : RawScrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          trackColor: resolveThemeColor(context,
                              dark: Colors.grey.withOpacity(0.1),
                              light: Colors.grey.withOpacity(0.1)),
                          thumbColor: resolveThemeColor(context,
                              dark: Colors.grey.withOpacity(0.3),
                              light: Colors.grey.withOpacity(0.3)),
                          thickness: 6,
                          radius: const Radius.circular(3),
                          interactive: true,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: shadcn.Table(
                              key: ValueKey(
                                  'table_${_sortColumnIndex}_$_sortAscending'),
                              columnWidths: {
                                0: shadcn.FixedTableSize(columnWidths[0]!),
                                1: shadcn.FixedTableSize(columnWidths[1]!),
                                2: shadcn.FixedTableSize(columnWidths[2]!),
                                3: shadcn.FixedTableSize(columnWidths[3]!),
                              },
                              defaultRowHeight: const shadcn.FixedTableSize(65), // Larger row height for content
                              rows: [
                                // Data Rows
                                ...displayBonds.asMap().entries.map((entry) {
                                  final index = entry.key;
                                   final bond = entry.value;

                                  return shadcn.TableRow(
                                    cells: [
                                      // Name & Series with hover action buttons
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 0,
                                        child: _buildNameCellWithActions(bond, index),
                                      ),
                                      // Bid Date (Start & End)
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 1,
                                        child: Row(
                                            children: [
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            Text("Start date", style: MyntWebTextStyles.caption(context, darkColor: WebColors.textSecondaryDark, lightColor: WebColors.textSecondary)),
                                                            Text(_formatDate(bond.biddingStartDate), style: _getTextStyle(context)),
                                                            Text(bond.dailyStartTime ?? '', style: MyntWebTextStyles.caption(context, darkColor: WebColors.textSecondaryDark, lightColor: WebColors.textSecondary)),
                                                        ],
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            Text("End date", style: MyntWebTextStyles.caption(context, darkColor: WebColors.textSecondaryDark, lightColor: WebColors.textSecondary)),
                                                            Text(_formatDate(bond.biddingEndDate), style: _getTextStyle(context)),
                                                            Text(bond.dailyEndTime ?? '', style: MyntWebTextStyles.caption(context, darkColor: WebColors.textSecondaryDark, lightColor: WebColors.textSecondary)),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        )
                                      ),
                                      // Min Invest
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 2,
                                        alignRight: true,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                Text("₹${_calculateMinInvest(bond)}", style: _getTextStyle(context)),
                                                Text("${_formatNumber(double.tryParse(bond.minBidQuantity?.toString() ?? '0') ?? 0)} Qty.", style: MyntWebTextStyles.para(context, darkColor: WebColors.textSecondaryDark, lightColor: WebColors.textSecondary)),
                                            ],
                                        ),
                                      ),
                                      // Lot Size (Use "Cr" format logic if needed, or simply display)
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 3,
                                        alignRight: true,
                                        child: Text(_formatLotSize(bond), style: _getTextStyle(context)),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            );
        },
      ),
      ),
    );
  }

  String _formatNumber(double nm) {
    // Format with commas for thousands
    return NumberFormat("#,##,###", "en_IN").format(nm);
  }

  // Helper to format date consistent with screenshot
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      // Try parsing typical formats
      DateTime? date;
      // Check if it's already in dd-MM-yyyy format
      if (RegExp(r'^\d{2}-\d{2}-\d{4}').hasMatch(dateString)) {
        // Assume format is dd-MM-yyyy HH:mm:ss or similar
         try {
             return dateString.substring(0, 10);
         } catch (_) {
             return dateString;
         }
      }

      // Try parsing as ISO or standard date string
      date = DateTime.tryParse(dateString);
      if (date == null) {
          // Attempt to parse "Thu, 29 Jan 2026..." format using DateFormat
          // EEE, d MMM yyyy HH:mm:ss
           try {
              date = DateFormat("EEE, d MMM yyyy HH:mm:ss").parse(dateString);
           } catch (_) {
               // Fallback: split by space and take first 3 parts? Risk.
               // Just return original if parsing fails.
           }
      }

      if (date != null) {
        return DateFormat('dd-MM-yyyy').format(date);
      }
    } catch (e) {
      // Ignore
    }
    // Return safe substring or original if all else fails
    return dateString.length > 10 ? dateString.substring(0, 10) : dateString;
  }



  String _formatLotSize(dynamic bond) {
      try {
          double val = double.tryParse(bond.issueSize?.toString() ?? '0') ?? 0;
          double inCr = val / 10000000;
          return "${inCr.toStringAsFixed(2)} Cr.";
      } catch (e) {
          return "0.00 Cr.";
      }
  }

  String _calculateMinInvest(dynamic bond) {
    try {
      double qty = double.tryParse(bond.minBidQuantity?.toString() ?? '0') ?? 0;
      double price = double.tryParse(bond.minPrice?.toString() ?? '0') ?? 0;
      
      // Fallback to faceValue if price is 0
      if (price == 0) {
        price = double.tryParse(bond.faceValue?.toString() ?? '0') ?? 0;
      }
      
      double total = qty * price;
      return _formatNumber(total);
    } catch (e) {
      return "0";
    }
  }

  // ignore: unused_element
  void _showBindingDetails(dynamic bond, BuildContext context) {
      // Implement bottom sheet or dialog to show details/Apply
      // Similar to mobile _showOrderBottomSheet but for Web (Dialog)
  }
}
