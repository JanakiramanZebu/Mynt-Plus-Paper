import 'package:flutter/material.dart' show InkWell, Icons, Icon, TextPainter, TextSpan, TextStyle, TextDirection, GestureDetector, HitTestBehavior, Row, SizedBox, Widget, BuildContext, Color, EdgeInsets, Alignment, MainAxisAlignment, TextOverflow, Axis, FontWeight, Container, MouseRegion, Expanded, Align, Text, ScrollController, SingleChildScrollView, Scrollbar, Column, LayoutBuilder, ValueKey, Padding, BoxDecoration, BorderRadius, Border;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/order_provider.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../utils/responsive_snackbar.dart';
import 'mf_order_detail_screen_web.dart';

class MfOrderBookScreenWeb extends ConsumerStatefulWidget {
  const MfOrderBookScreenWeb({super.key});

  @override
  ConsumerState<MfOrderBookScreenWeb> createState() =>
      _MfOrderBookScreenWebState();
}

class _MfOrderBookScreenWebState extends ConsumerState<MfOrderBookScreenWeb> {
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
          ref.read(mfProvider).fetchMfOrderbook(context);
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
    final isLastColumn = columnIndex == 6;
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
          onTap: () => _openMfOrderDetail(_sortedMfOrders(_getOrders())[rowIndex]),
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
    final isLastColumn = columnIndex == 6;
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

  // Calculate minimum column widths dynamically based on header and data
  Map<int, double> _calculateMinWidths(List<dynamic> orders, BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14);
    const padding = 24.0; // Padding for cell content
    const sortIconWidth = 24.0; // Extra space for sort indicator icon

    final headers = ['Fund Name', 'Transaction Type', 'Type', 'Folio No', 'Invest.Amt', 'Time', 'Status'];
    final minWidths = <int, double>{};

    // Calculate width for each column
    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;

      // Measure header width and add space for sort icon
      final headerWidth = _measureTextWidth(headers[col], textStyle);
      maxWidth = headerWidth + sortIconWidth;

      // Measure widest value in this column (sample first 5 rows for performance)
      for (final order in orders.take(5)) {
        String cellText = '';
        switch (col) {
          case 0: // Scheme
            cellText = order.name ?? order.schemename ?? 'N/A';
            break;
          case 1: // Transaction Type
            cellText = (order.buySell == 'P') ? 'Purchase' : 'Redemption';
            break;
          case 2: // Type
            cellText = (order.orderType == 'NRM') ? 'ONE-TIME' : 'SIP';
            break;
          case 3: // Folio No
            final folioNo = order.folioNo ?? order.foliono;
            cellText = (folioNo == null || folioNo.isEmpty || folioNo == 'null' || folioNo == 'Null')
                ? '---' 
                : folioNo;
            break;
          case 4: // Amount
            final amount = order.orderVal ?? order.amount ?? '0';
            cellText = double.tryParse(amount.toString())?.toStringAsFixed(2) ?? amount.toString();
            break;
          case 5: // Time
            cellText = order.datetime ?? order.dateTime ?? '';
            break;
          case 6: // Status
            cellText = (order.status ?? order.orderstatus ?? '').toUpperCase();
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

  // Get orders list
  List<dynamic> _getOrders() {
    final mf = ref.watch(mfProvider);
    final orderBook = ref.watch(orderProvider);
    final isSearching = orderBook.orderSearchCtrl.text.isNotEmpty;
    return isSearching
        ? (mf.mfOrderSearch ?? [])
        : (mf.mflumpsumorderbook?.data ?? []);
  }

  List<dynamic> _sortedMfOrders(List<dynamic> orders) {
    if (_sortColumnIndex == null) return orders;
    final sorted = List<dynamic>.from(orders);
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
          r = cmp<String>(a.name ?? a.schemename, b.name ?? b.schemename);
          break;
        case 1: // Transaction Type
          String aTransType = (a.buySell == 'P' || a.buysell == 'P') ? 'Purchase' : 'Redemption';
          String bTransType = (b.buySell == 'P' || b.buysell == 'P') ? 'Purchase' : 'Redemption';
          r = cmp<String>(aTransType, bTransType);
          break;
        case 2: // Type
          String aType = ((a.orderType == 'NRM' || a.ordertype == 'NRM') ? 'ONE-TIME' : 'SIP');
          String bType = ((b.orderType == 'NRM' || b.ordertype == 'NRM') ? 'ONE-TIME' : 'SIP');
          r = cmp<String>(aType, bType);
          break;
        case 3: // Folio No
          String aFolio = _getFolioDisplay(a);
          String bFolio = _getFolioDisplay(b);
          r = cmp<String>(aFolio, bFolio);
          break;
        case 4: // Amount
          r = cmp<num>(parseNum(a.orderVal ?? a.amount),
              parseNum(b.orderVal ?? b.amount));
          break;
        case 5: // Time
          r = cmp<String>(a.datetime ?? a.dateTime, b.datetime ?? b.dateTime);
          break;
        case 6: // Status
          r = cmp<String>(a.status ?? a.orderstatus, b.status ?? b.orderstatus);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  String _getFolioDisplay(dynamic order) {
    final folioNo = order.folioNo ?? order.foliono;
    return (folioNo == null || folioNo.isEmpty || folioNo == 'null' || folioNo == 'Null')
        ? '---' 
        : folioNo;
  }

  Color _getStatusColor(String status) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final statusLower = status.toLowerCase();
    
    if (statusLower == 'completed' || statusLower == 'success' || statusLower == 'allocated') {
      return colorScheme.chart2;
    } else if (statusLower == 'rejected' || statusLower == 'cancelled' || statusLower == 'failed' || statusLower == 'payment declined') {
      return colorScheme.destructive;
    } else {
      return colorScheme.chart1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final orders = _getOrders();

    // Show loading or empty state
    if (orders.isEmpty) {
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

    final sortedOrders = _sortedMfOrders(orders);

    // Build data rows
    final dataRows = <shadcn.TableRow>[];
    for (var i = 0; i < sortedOrders.length; i++) {
      final order = sortedOrders[i];
      final colorScheme = shadcn.Theme.of(context).colorScheme;

      dataRows.add(
        shadcn.TableRow(
          cells: [
            // Scheme - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 0,
              child: Text(
                order.name ?? order.schemename ?? 'N/A',
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Transaction Type - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 1,
              child: Text(
                (order.buySell == 'P' || order.buysell == 'P') ? 'Purchase' : 'Redemption',
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Type - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 2,
              child: _buildTypeCell(order, theme),
            ),
            // Folio No - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 3,
              alignRight: true,
              child: Text(
                _getFolioDisplay(order),
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Amount - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 4,
              alignRight: true,
              child: Text(
                double.tryParse((order.orderVal ?? order.amount ?? '0').toString())?.toStringAsFixed(2) ?? (order.orderVal ?? order.amount ?? '0').toString(),
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
              ),
            ),
            // Time - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 5,
              alignRight: true,
              child: Text(
                order.datetime ?? order.dateTime ?? '',
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
              ),
            ),
            // Status - Make clickable for row tap
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 6,
              child: Text(
                (order.status ?? order.orderstatus ?? '').toUpperCase(),
                style: _geistTextStyle(
                  color: _getStatusColor(order.status ?? order.orderstatus ?? ''),
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
          final minWidths = _calculateMinWidths(sortedOrders, context);

          // Available width
          final availableWidth = constraints.maxWidth;

          // Step 1: Start with minimum widths (content-based, no wasted space)
          final columnWidths = <int, double>{};
          for (int i = 0; i < 7; i++) {
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

            for (int i = 0; i < 7; i++) {
              if (i == 0) {
                // Column 0: Scheme
                growthFactors[i] = schemeGrowthFactor;
                totalGrowthFactor += schemeGrowthFactor;
              } else if (i == 1 || i == 2 || i == 3 || i == 6) {
                // Columns 1, 2, 3, 6: Text columns (Transaction Type, Type, Folio No, Status)
                growthFactors[i] = textGrowthFactor;
                totalGrowthFactor += textGrowthFactor;
              } else {
                // Columns 4, 5: Numeric columns (Amount, Time)
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }

            // Distribute extra space proportionally
            if (totalGrowthFactor > 0) {
              for (int i = 0; i < 7; i++) {
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
                    6: shadcn.FixedTableSize(columnWidths[6]!),
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(40),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        buildHeaderCell('Scheme', 0),
                        buildHeaderCell('Transaction Type', 1),
                        buildHeaderCell('Type', 2),
                        buildHeaderCell('Folio No', 3, true),
                        buildHeaderCell('Amount', 4, true),
                        buildHeaderCell('Time', 5, true),
                        buildHeaderCell('Status', 6),
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
                          6: shadcn.FixedTableSize(columnWidths[6]!),
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

  Widget _buildTypeCell(dynamic order, ThemesProvider theme) {
    final type = (order.orderType == 'NRM' ? 'ONE-TIME' : 'SIP');

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: type == 'ONE-TIME'
              ? const Color.fromARGB(255, 88, 69, 147).withOpacity(0.1)
              : const Color(0xff016B61).withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: type == 'ONE-TIME'
                ? const Color.fromARGB(255, 88, 69, 147)
                : const Color(0xff016B61),
            width: 1,
          ),
        ),
        child: Text(
          type,
          style: _geistTextStyle(
            color: type == 'ONE-TIME'
                ? const Color.fromARGB(255, 88, 69, 147)
                : const Color(0xff016B61),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _openMfOrderDetail(dynamic orderData) async {
    try {
      // Fetch order details first
      final mforderbook = ref.read(mfProvider);

      await mforderbook.fetchorderdetails(orderData.orderId ?? "");

      if (!mounted) return;

      // Check if data was fetched successfully
      if (mforderbook.mforderdet?.stat == "Ok" &&
          mforderbook.mforderdet?.data != null &&
          mforderbook.mforderdet!.data!.isNotEmpty) {
        // Convert fetched order data to Data model
        final orderDetail = mforderbook.mforderdet!.data![0];

        // Open detail sheet (matching pattern from other order detail screens)
        shadcn.openSheet(
          context: context,
          builder: (sheetContext) => MFOrderDetailScreenWeb(
            mfOrderData: orderDetail,
          ),
          position: shadcn.OverlayPosition.end,
        );
      } else {
        // Show error message
        ResponsiveSnackBar.showError(
            context,
            'Failed to fetch order details: ${mforderbook.mforderdet?.stat ?? "Unknown error"}');
      }
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Error: ${e.toString()}');
      }
    }
  }
}
