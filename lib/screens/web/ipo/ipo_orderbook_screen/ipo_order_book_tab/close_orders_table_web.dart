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
import '../ipo_orderbook_details/close_order_details_web.dart';

class CloseOrdersTable extends ConsumerStatefulWidget {
  final List<dynamic>? filteredOrders;

  const CloseOrdersTable({super.key, this.filteredOrders});

  @override
  ConsumerState<CloseOrdersTable> createState() => _CloseOrdersTableState();
}

class _CloseOrdersTableState extends ConsumerState<CloseOrdersTable> {
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
    final ordersToDisplay = widget.filteredOrders ?? ipo.closeorder ?? [];

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
        // Allocation: Name (40%), Date (20%), Status (20%), Amount (20%)
        final nameWidth = width * 0.40;
        final dateWidth = width * 0.20;
        final statusWidth = width * 0.20;
        final amountWidth = width * 0.20;

        final columnWidths = {
          0: shadcn.FixedTableSize(nameWidth),
          1: shadcn.FixedTableSize(dateWidth),
          2: shadcn.FixedTableSize(statusWidth),
          3: shadcn.FixedTableSize(amountWidth),
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
                            _buildHeaderCell("Stock name", 0, theme),
                            _buildHeaderCell("Date", 1, theme,
                                alignRight: true),
                            _buildHeaderCell("Status", 2, theme,
                                centered: true),
                            _buildHeaderCell("Amount", 3, theme,
                                alignRight: true),
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
                        defaultRowHeight: const shadcn.FixedTableSize(60),
                        rows: sortedOrders.asMap().entries.map((entry) {
                          final order = entry.value;
                          final index = entry.key;
                          return _buildShadcnRow(order, index, theme);
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

  // Widget _buildSortIcon(int columnIndex, ThemesProvider theme) {
  //   if (_sortColumnIndex == columnIndex) {
  //     return const SizedBox(width: 16);
  //   } else {
  //     return Icon(
  //       Icons.unfold_more,
  //       size: 16,
  //       color: resolveThemeColor(
  //         context,
  //         dark: MyntColors.textSecondaryDark,
  //         light: MyntColors.textSecondary,
  //       ).withOpacity(0.6),
  //     );
  //   }
  // }

  shadcn.TableCell _buildHeaderCell(
      String text, int sortIndex, ThemesProvider theme,
      {bool alignRight = false, bool centered = false}) {
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: _getHeaderStyle(context),
              ),
              // if (sortIndex >= 0) ...[
              //   const SizedBox(width: 4),
              //   _buildSortIcon(sortIndex, theme),
              // ],
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
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                          ? Theme.of(context).colorScheme.background
                          : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: resolveThemeColor(
                                  context,
                                  dark: MyntColors.dividerDark,
                                  light: MyntColors.divider,
                                ),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${order.companyName} ${order.symbol}',
                                style: MyntWebTextStyles.bodySmall(
                                  context,
                                  color: resolveThemeColor(
                                    context,
                                    dark: MyntColors.textPrimaryDark,
                                    light: MyntColors.textPrimary,
                                  ),
                                  fontWeight: MyntFonts.bold,
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
                                      color: resolveThemeColor(
                                        context,
                                        dark: MyntColors.iconDark,
                                        light: MyntColors.icon,
                                      ),
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
                            child: IpoCloseOrderDetails(ipoclose: order),
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

  shadcn.TableRow _buildShadcnRow(
      dynamic order, int index, ThemesProvider theme) {
    final uniqueId = '$index';
    final isHovered = _hoveredRowToken == uniqueId;

    return shadcn.TableRow(
      cells: [
        // Stock Name
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: isHovered,
          theme: theme,
          onTap: () => _showOrderDetailsDialog(order),
          child: Text(
            order.companyName?.toString() ?? '',
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
        // Date
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: isHovered,
          theme: theme,
          alignRight: true,
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
              color: (order.reponseStatus == "cancel success"
                      ? MyntColors.pending
                      : resolveThemeColor(
                          context,
                          dark: MyntColors.lossDark,
                          light: MyntColors.loss,
                        ))
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              (order.reponseStatus == "cancel success" ? "Cancelled" : "Failed")
                  .toUpperCase(),
              style: MyntWebTextStyles.bodySmall(
                context,
                color: order.reponseStatus == "cancel success"
                    ? MyntColors.pending
                    : resolveThemeColor(
                        context,
                        dark: MyntColors.lossDark,
                        light: MyntColors.loss,
                      ),
                fontWeight: MyntFonts.medium,
              ),
            ),
          ),
        ),
        // Amount
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: isHovered,
          theme: theme,
          alignRight: true,
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
      ],
    );
  }

  String _getInvestedAmount(dynamic order) {
    if (order.bidDetail == null || order.bidDetail!.isEmpty) {
      return "0";
    }

    return order.type == "BSE"
        ? getFormatter(
            noDecimal: true,
            v4d: false,
            value: double.parse(order.bidDetail![0].rate ?? "0") *
                double.parse(order.bidDetail![0].quantity ?? "0"))
        : getFormatter(
            noDecimal: true,
            v4d: false,
            value: double.parse(order.bidDetail![0].amount?.toString() ?? "0"));
  }
}
