// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../../../provider/iop_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/global_font_web.dart';
import '../../../../../res/web_colors.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/functions.dart';
import '../../../../../sharedWidget/no_data_found.dart';
import '../ipo_orderbook_details/open_order_details_web.dart';
import '../../ipo_cancel_alert/cancel_alert_web.dart';

class OpenOrdersTable extends ConsumerStatefulWidget {
  final List<dynamic>? filteredOrders;

  const OpenOrdersTable({super.key, this.filteredOrders});

  @override
  ConsumerState<OpenOrdersTable> createState() => _OpenOrdersTableState();
}

class _OpenOrdersTableState extends ConsumerState<OpenOrdersTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String? _hoveredRowToken; // Track which row is being hovered
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ipo = ref.watch(ipoProvide);
    final theme = ref.watch(themeProvider);
    final ordersToDisplay = widget.filteredOrders ?? ipo.openorder ?? [];

    if (ordersToDisplay.isEmpty) {
      return const Center(
        child: NoDataFound(),
      );
    }

    // Apply sorting
    final sortedOrders = _getSortedOrders(ordersToDisplay);

    return Builder(
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        const padding = 16.0 * 2;
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
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1000,
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
                      : WebColors.textSecondary,
                ),
                dataTextStyle: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textSecondary,
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
                rows: _buildDataTable2Rows(sortedOrders, theme),
              ),
            ),
          ),
        );
      },
    );
  }

  List<dynamic> _getSortedOrders(List<dynamic> orders) {
    if (_sortColumnIndex == null) {
      return orders;
    }

    final sorted = List<dynamic>.from(orders);
    sorted.sort((a, b) {
      int comparison = 0;
      switch (_sortColumnIndex) {
        case 0: // Company Name
          final nameA = a.companyName?.toString() ?? '';
          final nameB = b.companyName?.toString() ?? '';
          comparison = nameA.compareTo(nameB);
          break;
        case 1: // Date
          final dateA = a.responseDatetime?.toString() ?? '';
          final dateB = b.responseDatetime?.toString() ?? '';
          comparison = dateA.compareTo(dateB);
          break;
        case 2: // Status
          final statusA = a.reponseStatus?.toString() ?? '';
          final statusB = b.reponseStatus?.toString() ?? '';
          comparison = statusA.compareTo(statusB);
          break;
        case 3: // Amount
          final amountA = _getInvestedAmount(a);
          final amountB = _getInvestedAmount(b);
          comparison = amountA.compareTo(amountB);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return sorted;
  }

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      }
    });
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
                    : WebColors.textSecondary,
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
              'Date',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(1, theme),
          ],
        ),
        size: ColumnSize.M,
        onSort: (index, ascending) => _onSortTable(1, ascending),
      ),
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Status',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(2, theme),
          ],
        ),
        size: ColumnSize.S,
        onSort: (index, ascending) => _onSortTable(2, ascending),
      ),
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Amount',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(3, theme),
          ],
        ),
        size: ColumnSize.M,
        onSort: (index, ascending) => _onSortTable(3, ascending),
      ),
    ];
  }

  void _showOrderDetailsDialog(dynamic order) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry dialogOverlayEntry;

    dialogOverlayEntry = OverlayEntry(
      builder: (overlayContext) => Consumer(
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
                    width: 600,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: currentTheme.isDarkMode
                          ? WebDarkColors.surface
                          : WebColors.surface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${order.companyName} ${order.symbol}',
                                style: WebTextStyles.sub(
                                  isDarkTheme: currentTheme.isDarkMode,
                                  color: currentTheme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
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
                        ),
                        // Content
                        Flexible(
                          child: SingleChildScrollView(
                            child: IpoOpenOrderDetails(ipodetails: order),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    overlay.insert(dialogOverlayEntry);
  }

  Widget _buildHoverButton({
    String? label,
    IconData? icon,
    required Color color,
    Color? backgroundColor,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    final isLongLabel = label != null && label.length > 1;
    return SizedBox(
      width: isLongLabel ? null : 25,
      height: 25,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onPressed,
          child: Container(
            padding: isLongLabel ? const EdgeInsets.symmetric(horizontal: 8) : null,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 16, color: color)
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

  /// Determines if an order can be cancelled.
  /// Only Pending orders can be cancelled (not Success orders).
  /// The order must also have the IPO bidding period still "Open".
  bool _canCancelOrder(dynamic order) {
    // Only allow cancellation for Pending orders, not Success orders
    final orderStatus = order.reponseStatus?.toString().trim();
    if (orderStatus == "new success") {
      return false;
    }
    
    // Check if bidding start date exists and is not empty/null string
    final startDate = order.biddingstartdate?.toString().trim();
    if (startDate == null || startDate.isEmpty || startDate == "null" || startDate == "") {
      // If dates are not available, default to showing button for pending orders
      // The backend will handle validation
      return true;
    }
    
    // Get the correct end date based on exchange type (BSE vs NSE)
    final endDateStr = order.type == "BSE" 
        ? order.biddingendDate?.toString().trim()
        : order.biddingenddate?.toString().trim();
    
    if (endDateStr == null || endDateStr.isEmpty || endDateStr == "null" || endDateStr == "") {
      // If dates are not available, default to showing button for pending orders
      return true;
    }
    
    // Check if the IPO bidding period is currently "Open"
    try {
      final status = modifyButtonStatus(
        startDate,
        endDateStr,
      );
      
      // Only allow cancellation if IPO bidding is still open
      return status == "Open";
    } catch (e) {
      // If there's an error parsing dates, default to showing the button for pending orders
      return true;
    }
  }

  List<DataRow2> _buildDataTable2Rows(
      List<dynamic> orders, ThemesProvider theme) {
    return orders.asMap().entries.map((entry) {
      final index = entry.key;
      final order = entry.value;
      final orderToken = order.applicationNumber?.toString() ?? '';
      final uniqueId = '$orderToken$index';
      final isHovered = _hoveredRowToken == uniqueId;
      final canCancel = _canCancelOrder(order);
      final companyName = order.companyName?.toString() ?? '';

      return DataRow2(
        onTap: () {
          _showOrderDetailsDialog(order);
        },
        color: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered) || isHovered) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return Colors.transparent;
        }),
        cells: [
          // Stock name (fixed column) with hover actions
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
              onExit: (_) => setState(() => _hoveredRowToken = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: isHovered && canCancel ? 1 : 2,
                        child: Tooltip(
                          message: companyName,
                          child: Text(
                            companyName,
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textSecondary,
                              fontWeight: WebFonts.medium,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      // Cancel button fade in on hover (only if can cancel)
                      if (canCancel)
                        AnimatedOpacity(
                          opacity: isHovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          child: IgnorePointer(
                            ignoring: !isHovered,
                            child: _buildHoverButton(
                              label: 'Cancel',
                              color: Colors.white,
                              backgroundColor: theme.isDarkMode
                                  ? WebDarkColors.tertiary
                                  : WebColors.tertiary,
                              onPressed: isHovered ? () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return IpoCancelAlert(ipocancel: order);
                                  },
                                );
                              } : null,
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
          // Date
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
              onExit: (_) => setState(() => _hoveredRowToken = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    order.responseDatetime?.toString() == "" || order.responseDatetime == null
                        ? "----"
                        : ipodateres(order.responseDatetime.toString()),
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textSecondary,
                      fontWeight: WebFonts.regular,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Status
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
              onExit: (_) => setState(() => _hoveredRowToken = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    order.reponseStatus == "new success" ? "Success" : "Pending",
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: order.reponseStatus == "new success"
                          ? theme.isDarkMode
                              ? colors.profitDark
                              : colors.profitLight
                          : theme.isDarkMode
                              ? colors.pending
                              : colors.pending,
                      fontWeight: WebFonts.regular,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Amount
          DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
              onExit: (_) => setState(() => _hoveredRowToken = null),
              child: SizedBox.expand(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    _getInvestedAmount(order),
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textSecondary,
                      fontWeight: WebFonts.regular,
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

  String _getInvestedAmount(dynamic order) {
    if (order.bidDetail == null || order.bidDetail!.isEmpty) {
      return "0";
    }
    
    // Calculate max value from all bids
    List<String> stringList = [];
    for (var i = 0; i < order.bidDetail!.length; i++) {
      stringList.add(order.type == "BSE"
          ? (double.parse(order.bidDetail![i].rate ?? "0") *
                  double.parse(order.bidDetail![i].quantity ?? "0"))
              .toString()
          : order.bidDetail![i].amount?.toString() ?? "0");
    }
    
    if (stringList.isEmpty) {
      return "0";
    }
    
    String maxValue = stringList
        .reduce((curr, next) =>
            double.parse(curr) > double.parse(next) ? curr : next)
        .toString();
    return getFormatter(noDecimal: true, v4d: false, value: double.parse(maxValue));
  }
}

