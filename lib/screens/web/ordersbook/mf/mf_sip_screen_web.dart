import 'package:flutter/material.dart' show InkWell, Icons, Icon, TextPainter, TextSpan, TextStyle, TextDirection, GestureDetector, HitTestBehavior, Row, SizedBox, Widget, BuildContext, Color, Colors, EdgeInsets, Alignment, MainAxisAlignment, TextOverflow, Axis, FontWeight, Container, MouseRegion, Expanded, Align, Text, ScrollController, SingleChildScrollView, Scrollbar, Column, LayoutBuilder, ValueKey, Padding, BoxDecoration, BorderRadius, Border, showDialog;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/order_provider.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../res/web_colors.dart';
import 'mf_sip_detail_screen_web.dart';
import 'sip_pause_dialogue_web.dart';
import 'sip_cancel_dialogue_web.dart';
import '../../../../models/mf_model/sip_mf_list_model.dart';

class MFSipdetScreenWeb extends ConsumerStatefulWidget {
  const MFSipdetScreenWeb({super.key});

  @override
  ConsumerState<MFSipdetScreenWeb> createState() => _MFSipdetScreenWebState();
}

class _MFSipdetScreenWebState extends ConsumerState<MFSipdetScreenWeb> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int? _hoveredRowIndex;
  bool _hasInitialized = false;

  // Scroll controllers - must be in state to persist across rebuilds
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();

    // Only fetch data once when widget is first created
    if (!_hasInitialized) {
      Future.microtask(() {
        if (mounted && !_hasInitialized) {
          _hasInitialized = true;
          ref.read(mfProvider).fetchmfsiplist();
        }
      });
    }
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // Helper method to ensure Geist font is always applied
  TextStyle _geistTextStyle({Color? color, double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      fontFamily: 'Geist',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  // Builds a cell with hover detection (matches holdings pattern)
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 5;
    final horizontalPadding = isFirstColumn || isLastColumn ? 16.0 : 8.0;

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
        onEnter: (_) => setState(() => _hoveredRowIndex = rowIndex),
        onExit: (_) => setState(() => _hoveredRowIndex = null),
        child: GestureDetector(
          onTap: () => _openSipDetail(_sortedSipDetails(_getSipDetails())[rowIndex]),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
            alignment: alignRight ? Alignment.topRight : null,
            child: child,
          ),
        ),
      ),
    );
  }

  // Builds a sortable header cell
  shadcn.TableCell buildHeaderCell(String label, int columnIndex, [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 5;
    final horizontalPadding = isFirstColumn || isLastColumn ? 16.0 : 6.0;

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
      child: InkWell(
        onTap: () => _onSort(columnIndex),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              if (alignRight && _sortColumnIndex == columnIndex) const SizedBox(width: 4),
              Text(
                label,
                style: _geistTextStyle(
                  color: shadcn.Theme.of(context).colorScheme.foreground,
                ),
              ),
              if (!alignRight && _sortColumnIndex == columnIndex) const SizedBox(width: 4),
              if (!alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
            ],
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

  // Helper method to measure text width dynamically
  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  // Get SIP details list
  List<dynamic> _getSipDetails() {
    final mf = ref.watch(mfProvider);
    final orderBook = ref.watch(orderProvider);
    final isSearching = orderBook.orderSearchCtrl.text.isNotEmpty;
    return isSearching
        ? (mf.mfSipSearch ?? [])
        : (mf.mfsiporderlist?.data ?? []);
  }

  // Calculate minimum column widths dynamically based on header and data
  Map<int, double> _calculateMinWidths(List<dynamic> sipDetails, BuildContext context) {
      final textStyle = const TextStyle(fontSize: 14);
      const padding = 24.0; // Padding for cell content
      const sortIconWidth = 24.0; // Extra space for sort indicator icon

      final headers = ['Scheme', 'SIP Reg No', 'Amount', 'Frequency', 'Next Installment', 'Status'];
      final minWidths = <int, double>{};

      // Calculate width for each column
      for (int col = 0; col < headers.length; col++) {
        double maxWidth = 0.0;

        // Measure header width and add space for sort icon
        final headerWidth = _measureTextWidth(headers[col], textStyle);
        maxWidth = headerWidth + sortIconWidth;

        // Measure widest value in this column (sample first 5 rows for performance)
        for (final sipDetail in sipDetails.take(5)) {
          String cellText = '';
          switch (col) {
            case 0: // Scheme
              cellText = sipDetail.name ?? 'N/A';
              break;
            case 1: // SIP Reg No
              cellText = sipDetail.sIPRegnNo ?? '';
              break;
            case 2: // Amount
              final amount = sipDetail.installmentAmount?.toString() ?? '0';
              cellText = double.tryParse(amount)?.toStringAsFixed(2) ?? amount;
              break;
            case 3: // Frequency
              cellText = sipDetail.frequencyType ?? '';
              break;
            case 4: // Next Installment
              cellText = sipDetail.NextSIPDate ?? '';
              break;
            case 5: // Status
              cellText = (sipDetail.status ?? '').toUpperCase();
              break;
          }

          final cellWidth = _measureTextWidth(cellText, textStyle);
          if (cellWidth > maxWidth) {
            maxWidth = cellWidth;
          }
        }

        // Set minimum width (max of header/data + padding)
        minWidths[col] = maxWidth + padding;
      }

      return minWidths;
    }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final sipDetails = _getSipDetails();

    if (sipDetails.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: NoDataFound(),
          ),
        ),
      );
    }

    final sortedSipDetails = _sortedSipDetails(sipDetails);

    // Build data rows
    final dataRows = <shadcn.TableRow>[];
    for (var i = 0; i < sortedSipDetails.length; i++) {
      final sipDetail = sortedSipDetails[i];
      final colorScheme = shadcn.Theme.of(context).colorScheme;
      final isHovered = _hoveredRowIndex == i;

      dataRows.add(
        shadcn.TableRow(
          cells: [
            // Scheme - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 0,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      sipDetail.name ?? 'N/A',
                      style: _geistTextStyle(
                        color: colorScheme.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Action buttons on hover
                  if (isHovered && _shouldShowSipActions(sipDetail)) ...[
                    const SizedBox(width: 8),
                    _buildPauseButton(sipDetail, theme),
                    const SizedBox(width: 6),
                    _buildCancelSipButton(sipDetail, theme),
                  ],
                ],
              ),
            ),
            // SIP Reg No - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 1,
              alignRight: true,
              child: Text(
                sipDetail.sIPRegnNo ?? '',
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Amount - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 2,
              alignRight: true,
              child: Text(
                double.tryParse((sipDetail.installmentAmount?.toString() ?? '0'))?.toStringAsFixed(2) ?? (sipDetail.installmentAmount?.toString() ?? '0'),
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
              ),
            ),
            // Frequency - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 3,
              child: Text(
                sipDetail.frequencyType ?? '',
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Next Installment - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 4,
              alignRight: true,
              child: Text(
                sipDetail.NextSIPDate ?? '',
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Status - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 5,
              child: Text(
                (sipDetail.status ?? '').toUpperCase(),
                style: _geistTextStyle(
                  color: _getStatusColor(sipDetail.status ?? ''),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Return shadcn Table with proper structure
    return shadcn.OutlinedContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically based on actual content
          final minWidths = _calculateMinWidths(sortedSipDetails, context);

          // Available width
          final availableWidth = constraints.maxWidth;

          // Step 1: Start with minimum widths (content-based, no wasted space)
          final columnWidths = <int, double>{};
          for (int i = 0; i < 6; i++) {
            columnWidths[i] = minWidths[i] ?? 100.0;
          }

          // Step 2: Calculate total minimum width needed
          final totalMinWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);

          // Step 3: If there's extra space, distribute it proportionally
          if (totalMinWidth < availableWidth) {
            final extraSpace = availableWidth - totalMinWidth;

            // Define which columns can grow and their growth priorities
            const schemeGrowthFactor = 2.5; // Scheme gets more growth
            const textGrowthFactor = 1.2; // Text columns get medium growth
            const numericGrowthFactor = 1.0; // Numeric columns get less growth

            // Calculate growth factors for each column
            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;

            for (int i = 0; i < 6; i++) {
              if (i == 0) {
                // Column 0: Scheme
                growthFactors[i] = schemeGrowthFactor;
                totalGrowthFactor += schemeGrowthFactor;
              } else if (i == 3 || i == 5) {
                // Columns 3, 5: Text columns (Frequency, Status)
                growthFactors[i] = textGrowthFactor;
                totalGrowthFactor += textGrowthFactor;
              } else {
                // Columns 1, 2, 4: Numeric columns (SIP Reg No, Amount, Next Installment)
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }

            // Distribute extra space proportionally
            if (totalGrowthFactor > 0) {
              for (int i = 0; i < 6; i++) {
                if (growthFactors[i]! > 0) {
                  final extraForThisColumn = (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                  columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                }
              }
            }
          }

          // Calculate total required width
          final totalRequiredWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);

          // If total width exceeds available width, enable horizontal scrolling
          final needsHorizontalScroll = totalRequiredWidth > availableWidth;

          // Build table content
          Widget buildTableContent() {
            return Column(
              children: [
                // Fixed Header (synced with horizontal scroll)
                shadcn.Table(
                  columnWidths: {
                    0: shadcn.FixedTableSize(columnWidths[0]!),
                    1: shadcn.FixedTableSize(columnWidths[1]!),
                    2: shadcn.FixedTableSize(columnWidths[2]!),
                    3: shadcn.FixedTableSize(columnWidths[3]!),
                    4: shadcn.FixedTableSize(columnWidths[4]!),
                    5: shadcn.FixedTableSize(columnWidths[5]!),
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(40),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        buildHeaderCell('Scheme', 0),
                        buildHeaderCell('SIP Reg No', 1, true),
                        buildHeaderCell('Amount', 2, true),
                        buildHeaderCell('Frequency', 3),
                        buildHeaderCell('Next Installment', 4, true),
                        buildHeaderCell('Status', 5),
                      ],
                    ),
                  ],
                ),
                // Scrollable Body (vertical scroll)
                Expanded(
                  child: Scrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      scrollDirection: Axis.vertical,
                      child: shadcn.Table(
                        key: ValueKey('table_${_sortColumnIndex}_$_sortAscending'),
                        columnWidths: {
                          0: shadcn.FixedTableSize(columnWidths[0]!),
                          1: shadcn.FixedTableSize(columnWidths[1]!),
                          2: shadcn.FixedTableSize(columnWidths[2]!),
                          3: shadcn.FixedTableSize(columnWidths[3]!),
                          4: shadcn.FixedTableSize(columnWidths[4]!),
                          5: shadcn.FixedTableSize(columnWidths[5]!),
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(40),
                        rows: dataRows,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Horizontal scroll wrapper (if needed)
          if (needsHorizontalScroll) {
            return Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalRequiredWidth,
                  child: buildTableContent(),
                ),
              ),
            );
          }

          return buildTableContent();
        },
      ),
    );
  }

  List<dynamic> _sortedSipDetails(List<dynamic> sipDetails) {
    if (_sortColumnIndex == null) return sipDetails;
    final sorted = List<dynamic>.from(sipDetails);
    int c = _sortColumnIndex!;
    bool asc = _sortAscending;

    int cmp<T extends Comparable>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return -1;
      if (b == null) return 1;
      return a.compareTo(b);
    }

    num parseNum(String? v) => double.tryParse(v ?? '') ?? 0;

    sorted.sort((a, b) {
      int r = 0;
      switch (c) {
        case 0: // Scheme
          r = cmp<String>(a.name, b.name);
          break;
        case 1: // SIP Reg No
          r = cmp<String>(a.sIPRegnNo, b.sIPRegnNo);
          break;
        case 2: // Amount
          r = cmp<num>(parseNum(a.installmentAmount?.toString()),
              parseNum(b.installmentAmount?.toString()));
          break;
        case 3: // Frequency
          r = cmp<String>(a.frequencyType, b.frequencyType);
          break;
        case 4: // Next Installment
          r = cmp<String>(a.NextSIPDate, b.NextSIPDate);
          break;
        case 5: // Status
          r = cmp<String>(a.status, b.status);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  Color _getStatusColor(String status) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final statusLower = status.toLowerCase();
    
    if (statusLower == 'active' || statusLower == 'running' || statusLower == 'live') {
      return colorScheme.chart2;
    } else if (statusLower == 'stopped' || statusLower == 'cancelled' || statusLower == 'rejected') {
      return colorScheme.destructive;
    } else {
      return colorScheme.chart1;
    }
  }

  void _openSipDetail(Xsip sipDetail) {
    // Open detail sheet (matching pattern from other order detail screens)
    shadcn.openSheet(
      context: context,
      builder: (sheetContext) => MFSipDetailScreenWeb(
        sipData: sipDetail,
      ),
      position: shadcn.OverlayPosition.end,
    );
  }

  bool _shouldShowSipActions(dynamic sipDetail) {
    final status = (sipDetail.status ?? '').toUpperCase();
    return status == "ACTIVE" || status == "RUNNING";
  }

  Widget _buildPauseButton(dynamic sipDetail, ThemesProvider theme) {
    final backgroundColor = theme.isDarkMode
        ? WebDarkColors.textSecondary.withOpacity(0.6)
        : WebColors.buttonSecondary;
    final textColor = theme.isDarkMode ? Colors.white : WebColors.primaryLight;
    final borderColor = theme.isDarkMode ? WebDarkColors.primaryLight : WebColors.primaryLight;
    
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: shadcn.TextButton(
        size: shadcn.ButtonSize.small,
        density: shadcn.ButtonDensity.dense,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SipPauseDialogueWeb(sipData: sipDetail);
            },
          );
        },
        shape: shadcn.ButtonShape.rectangle,
        child: Text(
          'Pause',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelSipButton(dynamic sipDetail, ThemesProvider theme) {
    final backgroundColor = theme.isDarkMode
        ? WebDarkColors.textSecondary.withOpacity(0.6)
        : WebColors.buttonSecondary;
    final textColor = theme.isDarkMode ? Colors.white : WebColors.primaryLight;
    final borderColor = theme.isDarkMode ? WebDarkColors.primaryLight : WebColors.primaryLight;
    
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: shadcn.TextButton(
        size: shadcn.ButtonSize.small,
        density: shadcn.ButtonDensity.dense,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SipCancelDialogueWeb(sipData: sipDetail);
            },
          );
        },
        shape: shadcn.ButtonShape.rectangle,
        child: Text(
          'Cancel SIP',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
