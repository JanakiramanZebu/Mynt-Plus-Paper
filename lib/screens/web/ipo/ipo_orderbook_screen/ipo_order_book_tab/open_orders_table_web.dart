// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../../../provider/iop_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/mynt_web_text_styles.dart';
import '../../../../../res/mynt_web_color_styles.dart';
import '../../../../../sharedWidget/functions.dart';
import '../../../../../sharedWidget/no_data_found.dart';
import '../../ipo_cancel_alert/cancel_alert_web.dart';
import '../ipo_orderbook_details/ipo_order_details_sheet_web.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Allocation: Name (25%), Date (25%), Amount (25%), Status (25%)
        final nameWidth = width * 0.25;
        final dateWidth = width * 0.25;
        final amountWidth = width * 0.25;
        final statusWidth = width * 0.25;

        final columnWidths = {
          0: shadcn.FixedTableSize(nameWidth),
          1: shadcn.FixedTableSize(dateWidth),
          2: shadcn.FixedTableSize(amountWidth),
          3: shadcn.FixedTableSize(statusWidth),
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.divider,
                ),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: theme.isDarkMode
                  ? Theme.of(context).colorScheme.surface
                  : Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  // Header
                  Container(
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.primaryDark.withOpacity(0.05),
                      light: MyntColors.primary.withOpacity(0.05),
                    ),
                    child: shadcn.Table(
                      columnWidths: columnWidths,
                      defaultRowHeight: const shadcn.FixedTableSize(48),
                      rows: [
                        shadcn.TableHeader(
                          cells: [
                            _buildHeaderCell("Date", 0, theme),
                            _buildHeaderCell("Stock name", 1, theme),
                            _buildHeaderCell("Amount", 2, theme,
                                centered: true),
                            _buildHeaderCell("Status", 3, theme,
                                centered: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      child: shadcn.Table(
                        columnWidths: columnWidths,
                        defaultRowHeight: const shadcn.FixedTableSize(50),
                        rows: sortedOrders.asMap().entries.map((entry) {
                          return _buildShadcnRow(entry.value, entry.key, theme);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
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
        case 0: // Date
          final dateA = a.responseDatetime?.toString() ?? '';
          final dateB = b.responseDatetime?.toString() ?? '';
          comparison = dateA.compareTo(dateB);
          break;
        case 1: // Company Name
          final nameA = a.companyName?.toString() ?? '';
          final nameB = b.companyName?.toString() ?? '';
          comparison = nameA.compareTo(nameB);
          break;
        case 2: // Amount
          final amountA = _getInvestedAmount(a);
          final amountB = _getInvestedAmount(b);
          comparison = amountA.compareTo(amountB);
          break;
        case 3: // Status
          final statusA = a.reponseStatus?.toString() ?? '';
          final statusB = b.reponseStatus?.toString() ?? '';
          comparison = statusA.compareTo(statusB);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return sorted;
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

  shadcn.TableCell _buildHeaderCell(
      String text, int sortIndex, ThemesProvider theme,
      {bool alignRight = false, bool centered = false, EdgeInsets? padding}) {
    Alignment alignment;
    if (centered) {
      alignment = Alignment.center;
    } else {
      alignment = alignRight ? Alignment.centerRight : Alignment.centerLeft;
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
      child: GestureDetector(
        onTap: sortIndex >= 0
            ? () => _onSortTable(sortIndex, !_sortAscending)
            : null,
        child: Container(
          alignment: alignment,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8.0),
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

  shadcn.TableCell _buildShadcnCell({
    required Widget child,
    required String uniqueId,
    required bool rowIsHovered,
    required ThemesProvider theme,
    VoidCallback? onTap,
    bool alignRight = false,
    bool centered = false,
    EdgeInsets? padding,
  }) {
    Alignment alignment;
    if (centered) {
      alignment = Alignment.center;
    } else {
      alignment = alignRight ? Alignment.centerRight : Alignment.centerLeft;
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
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: rowIsHovered
                ? resolveThemeColor(context,
                        dark: MyntColors.primary, light: MyntColors.primary)
                    .withOpacity(theme.isDarkMode ? 0.06 : 0.10)
                : Colors.transparent,
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            width: double.infinity,
            height: double.infinity,
            child: Align(
              alignment: alignment,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(dynamic order) {
    shadcn.openSheet(
      context: context,
      builder: (sheetContext) {
        final screenWidth = MediaQuery.of(sheetContext).size.width;
        final sheetWidth = screenWidth < 1300 ? screenWidth * 0.3 : 480.0;
        return Container(
          width: sheetWidth,
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: IpoOrderDetailsSheetWeb(order: order),
        );
      },
      position: shadcn.OverlayPosition.end,
      barrierColor: Colors.transparent,
    );
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
            padding:
                isLongLabel ? const EdgeInsets.symmetric(horizontal: 8) : null,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 16, color: color)
                  : Text(
                      label ?? "",
                      style: MyntWebTextStyles.buttonSm(
                        context,
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
    final orderStatus = order.reponseStatus?.toString().toLowerCase().trim();
    if (orderStatus != "new success") {
      // For any status other than "new success" (e.g., Pending), always allow cancellation.
      return true;
    }

    // For "new success" orders, we only allow cancellation if the bidding period is still open.
    // We proceed to the date/status check below.

    // Check if bidding start date exists and is not empty/null string
    final startDate = order.biddingstartdate?.toString().trim();
    if (startDate == null ||
        startDate.isEmpty ||
        startDate == "null" ||
        startDate == "") {
      // If dates are not available, default to showing button for pending orders
      // The backend will handle validation
      return true;
    }

    // Get the correct end date based on exchange type (BSE vs NSE)
    final endDateStr = order.type == "BSE"
        ? order.biddingendDate?.toString().trim()
        : order.biddingenddate?.toString().trim();

    if (endDateStr == null ||
        endDateStr.isEmpty ||
        endDateStr == "null" ||
        endDateStr == "") {
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

  shadcn.TableRow _buildShadcnRow(
      dynamic order, int index, ThemesProvider theme) {
    final orderToken = order.applicationNumber?.toString() ?? '';
    final uniqueId = '$orderToken$index';
    final isHovered = _hoveredRowToken == uniqueId;
    final canCancel = _canCancelOrder(order);
    final companyName = order.companyName?.toString() ?? '';

    return shadcn.TableRow(
      cells: [
        // Date
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: isHovered,
          theme: theme,
          onTap: () => _showOrderDetailsDialog(order),
          child: Text(
            order.responseDatetime?.toString() == "" ||
                    order.responseDatetime == null
                ? "----"
                : ipodateres(order.responseDatetime.toString()),
            style: MyntWebTextStyles.body(
              context,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary,
              ),
              fontWeight: MyntFonts.medium,
            ),
          ),
        ),
        // Stock Name
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: isHovered,
          theme: theme,
          onTap: () => _showOrderDetailsDialog(order),
          child: Row(
            children: [
              Expanded(
                flex: isHovered && canCancel ? 1 : 2,
                child: Text(
                  companyName,
                  style: MyntWebTextStyles.body(
                    context,
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary,
                    ),
                    fontWeight: MyntFonts.medium,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              // Cancel button fade in on hover
              if (canCancel)
                AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: IgnorePointer(
                    ignoring: !isHovered,
                    child: _buildHoverButton(
                      label: 'Cancel',
                      color: Colors.white,
                      backgroundColor: resolveThemeColor(
                        context,
                        dark: MyntColors.tertiary,
                        light: MyntColors.tertiary,
                      ),
                      onPressed: isHovered
                          ? () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return IpoCancelAlert(ipocancel: order);
                                },
                              );
                            }
                          : null,
                      theme: theme,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Amount
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: isHovered,
          theme: theme,
          centered: true,
          onTap: () => _showOrderDetailsDialog(order),
          child: Text(
            _getInvestedAmount(order),
            style: MyntWebTextStyles.body(
              context,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary,
              ),
              fontWeight: MyntFonts.medium,
            ),
          ),
        ),
        // Status
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: isHovered,
          theme: theme,
          centered: true,
          onTap: () => _showOrderDetailsDialog(order),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (order.reponseStatus == "new success"
                      ? resolveThemeColor(
                          context,
                          dark: MyntColors.profitDark,
                          light: MyntColors.profit,
                        )
                      : MyntColors.pending)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              (order.reponseStatus == "new success" ? "Success" : "Pending")
                  .toUpperCase(),
              style: MyntWebTextStyles.bodySmall(
                context,
                color: order.reponseStatus == "new success"
                    ? resolveThemeColor(
                        context,
                        dark: MyntColors.profitDark,
                        light: MyntColors.profit,
                      )
                    : MyntColors.pending,
                fontWeight: MyntFonts.medium,
              ),
            ),
          ),
        ),
      ],
    );
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
    return getFormatter(
        noDecimal: true, v4d: false, value: double.parse(maxValue));
  }
}
