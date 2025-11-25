import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../utils/responsive_snackbar.dart';
import 'mf_order_detail_screen_web.dart';

class MfOrderBookScreenWeb extends ConsumerStatefulWidget {
  const MfOrderBookScreenWeb({super.key});

  @override
  ConsumerState<MfOrderBookScreenWeb> createState() =>
      _MfOrderBookScreenWebState();
}

class _MfOrderBookScreenWebState extends ConsumerState<MfOrderBookScreenWeb> 
    with AutomaticKeepAliveClientMixin {
  int? _mfSortColumnIndex;
  bool _mfSortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  bool _hasInitialized = false;
  String? _hoveredRowToken;
  
  // Responsive breakpoints
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = ref.watch(themeProvider);
    final mf = ref.watch(mfProvider);

    final orders = mf.mflumpsumorderbook?.data ?? [];

    if (orders.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveMfOrderColumns(screenWidth);
        final headers = List<String>.from(responsiveConfig['headers'] as List);
        final columnFlex = Map<String, int>.from(responsiveConfig['columnFlex'] as Map);
        final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
        
        // Calculate total minimum width
        final totalMinWidth =
            columnMinWidth.values.fold<double>(0.0, (a, b) => a + b);
        // Determine whether horizontal scroll is needed
        final needHorizontalScroll = constraints.maxWidth < totalMinWidth;

        // Build the Column (header + body)
        final tableColumn = Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Sticky header (fixed) ---
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                      width: 1,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              child: needHorizontalScroll
                  ? IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: headers.map((label) {
                          final flex = columnFlex[label] ?? 1;
                          final minW = columnMinWidth[label] ?? 80.0;
                          final columnIndex = _getMfOrderColumnIndexForHeader(label);

                          return _buildMfOrderColumnCell(
                            needHorizontalScroll: needHorizontalScroll,
                            flex: flex,
                            minW: minW,
                            child: _buildMfOrderHeaderWidget(
                              label, 
                              columnIndex, 
                              theme, 
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.max,
                      children: headers.map((label) {
                        final flex = columnFlex[label] ?? 1;
                        final minW = columnMinWidth[label] ?? 80.0;
                        final columnIndex = _getMfOrderColumnIndexForHeader(label);

                        return _buildMfOrderColumnCell(
                          needHorizontalScroll: needHorizontalScroll,
                          flex: flex,
                          minW: minW,
                          child: _buildMfOrderHeaderWidget(
                            label, 
                            columnIndex, 
                            theme, 
                          ),
                        );
                      }).toList(),
                    ),
            ),

            // --- Scrollable body (vertical) ---
            Expanded(
              child: Scrollbar(
                controller: _verticalScrollController,
                thumbVisibility: true,
                radius: Radius.zero,
                child: _buildMfOrderBodyList(
                  theme,
                  orders,
                  headers,
                  columnFlex,
                  columnMinWidth,
                  totalMinWidth: totalMinWidth,
                  needHorizontalScroll: needHorizontalScroll,
                ),
              ),
            ),
          ],
          ),
        );

        // If horizontal scroll needed, wrap the entire column inside SingleChildScrollView
        if (needHorizontalScroll) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: SizedBox(
                  width: totalMinWidth,
                  child: tableColumn,
                ),
              ),
            ),
          );
        }

        // else (no horizontal scroll)
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: tableColumn,
          ),
        );
      },
    );
  }

  // Helper method to get responsive column configuration for MF Orders
  Map<String, dynamic> _getResponsiveMfOrderColumns(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) {
      // Mobile: Show only essential columns
      return {
        'headers': ['Scheme', 'Type', 'Amount', 'Status'],
        'columnFlex': {
          'Scheme': 3,
          'Type': 2,
          'Amount': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Scheme': 150,
          'Type': 100,
          'Amount': 100,
          'Status': 90,
        },
      };
    } else {
      // Tablet/Desktop: Full columns with optimal widths
      return {
        'headers': ['Scheme', 'Type', 'Amount', 'Time', 'Status'],
        'columnFlex': {
          'Scheme': 3,
          'Type': 2,
          'Amount': 2,
          'Time': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Scheme': 180,
          'Type': 110,
          'Amount': 110,
          'Time': 120,
          'Status': 100,
        },
      };
    }
  }

  int _getMfOrderColumnIndexForHeader(String header) {
    switch (header) {
      case 'Scheme': return 0;
      case 'Type': return 1;
      case 'Amount': return 2;
      case 'Time': return 3;
      case 'Status': return 4;
      default: return -1;
    }
  }

  Widget _buildMfOrderHeaderWidget(
    String label,
    int columnIndex,
    ThemesProvider theme,
  ) {
    final isNumeric = columnIndex == 2 || columnIndex == 3; // Amount (2) or Time (3)
    
    return InkWell(
      onTap: () => _onSortMfTable(columnIndex, !_mfSortAscending),
      child: Row(
        mainAxisAlignment: isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6),
              child: Text(
                label,
                style: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
                overflow: TextOverflow.visible,
                textAlign: isNumeric ? TextAlign.right : TextAlign.left,
              ),
            ),
          ),
          // Sort icon
          if (_mfSortColumnIndex == columnIndex)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Icon(
                _mfSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: theme.isDarkMode
                    ? WebDarkColors.iconPrimary
                    : WebColors.iconPrimary,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(
                Icons.unfold_more,
                size: 16,
                color: theme.isDarkMode
                    ? WebDarkColors.iconSecondary
                    : WebColors.iconSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMfOrderColumnCell({
    required bool needHorizontalScroll,
    required int flex,
    required double minW,
    required Widget child,
  }) {
    if (needHorizontalScroll) {
      return SizedBox(
        width: minW,
        child: child,
      );
    }

    return Expanded(
      flex: flex,
      child: SizedBox(
        width: minW,
        child: child,
      ),
    );
  }

  Widget _buildMfOrderBodyList(
    ThemesProvider theme,
    List<dynamic> orders,
    List<String> headers,
    Map<String, int> columnFlex,
    Map<String, double> columnMinWidth, {
    required double totalMinWidth,
    required bool needHorizontalScroll,
  }) {
    final sorted = _sortedMfOrders(orders);
    return ListView.builder(
      controller: _verticalScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final o = sorted[index];
        final uniqueId = o.orderId?.toString() ?? (o.name ?? o.schemename ?? '') + index.toString();
        final isHovered = _hoveredRowToken == uniqueId;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
          onExit: (_) => setState(() => _hoveredRowToken = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openMfOrderDetail(o),
            child: Container(
              decoration: BoxDecoration(
                color: isHovered
                    ? (theme.isDarkMode
                        ? WebDarkColors.primary.withOpacity(0.06)
                        : WebColors.primary.withOpacity(0.10))
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: needHorizontalScroll
                  ? IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: headers.map((label) {
                          final flex = columnFlex[label] ?? 1;
                          final minW = columnMinWidth[label] ?? 80.0;
                          return _buildMfOrderColumnCell(
                            needHorizontalScroll: needHorizontalScroll,
                            flex: flex,
                            minW: minW,
                            child: _buildMfOrderCellWidget(
                              label,
                              o,
                              theme,
                              needHorizontalScroll: needHorizontalScroll,
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.max,
                      children: headers.map((label) {
                        final flex = columnFlex[label] ?? 1;
                        final minW = columnMinWidth[label] ?? 80.0;
                        return _buildMfOrderColumnCell(
                          needHorizontalScroll: needHorizontalScroll,
                          flex: flex,
                          minW: minW,
                          child: _buildMfOrderCellWidget(
                            label,
                            o,
                            theme,
                            needHorizontalScroll: needHorizontalScroll,
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMfOrderCellWidget(
    String column,
    dynamic o,
    ThemesProvider theme, {
    required bool needHorizontalScroll,
  }) {
    switch (column) {
      case 'Scheme':
        final scheme = o.name ?? o.schemename ?? '';
        return _buildMfOrderTextCell(
          scheme,
          theme,
          Alignment.centerLeft,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Type':
        final type = (o.orderType == 'NRM' ? 'ONE-TIME' : 'SIP');
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: type == 'ONE-TIME'
                    ? Color.fromARGB(255, 88, 69, 147).withOpacity(0.1)
                    : Color(0xff016B61).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: type == 'ONE-TIME'
                      ? Color.fromARGB(255, 88, 69, 147)
                      : Color(0xff016B61),
                  width: 1,
                ),
              ),
              child: Text(
                type,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: type == 'ONE-TIME'
                      ? Color.fromARGB(255, 88, 69, 147)
                      : Color(0xff016B61),
                  fontWeight: WebFonts.medium,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      case 'Amount':
        final amount = o.orderVal ?? o.amount ?? '0';
        return _buildMfOrderTextCell(
          double.tryParse(amount.toString())?.toStringAsFixed(2) ?? amount.toString(),
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Time':
        final time = o.datetime ?? '';
        return _buildMfOrderTextCell(
          time,
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Status':
        final status = (o.status ?? '').toUpperCase();
        final statusColor = _statusColor(status, theme);
        return _buildMfOrderTextCell(
          status,
          theme,
          Alignment.centerLeft,
          color: statusColor,
          needHorizontalScroll: needHorizontalScroll,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMfOrderTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
    bool needHorizontalScroll = false,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        child: Text(
          text,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: color ??
                (theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary),
            fontWeight: WebFonts.medium,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }


  void _onSortMfTable(int columnIndex, bool ascending) {
    setState(() {
      if (_mfSortColumnIndex == columnIndex) {
        _mfSortAscending = !_mfSortAscending;
      } else {
        _mfSortColumnIndex = columnIndex;
        _mfSortAscending = ascending;
      }
    });
  }

  List<dynamic> _sortedMfOrders(List<dynamic> orders) {
    if (_mfSortColumnIndex == null) return orders;
    final sorted = [...orders];
    int c = _mfSortColumnIndex!;
    bool asc = _mfSortAscending;

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
        case 1: // Type
          String aType = (a.orderType == 'NRM' ? 'ONE-TIME' : 'SIP');
          String bType = (b.orderType == 'NRM' ? 'ONE-TIME' : 'SIP');
          r = cmp<String>(aType, bType);
          break;
        case 2: // Amount
          r = cmp<num>(parseNum(a.orderVal ?? a.amount),
              parseNum(b.orderVal ?? b.amount));
          break;
        case 3: // Time
          r = cmp<String>(a.datetime, b.datetime);
          break;
        case 4: // Status
          r = cmp<String>(a.status, b.status);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  Color _statusColor(String status, ThemesProvider theme) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'rejected':
      case 'cancelled':
      case 'failed':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      default:
        return colors.pending;
    }
  }

  void _openMfOrderDetail(dynamic orderData) async {
    try {
      // Fetch order details first
      final mforderbook = ref.read(mfProvider);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      await mforderbook.fetchorderdetails(orderData.orderId ?? "");

      // Dismiss loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      // Check if data was fetched successfully
      if (mforderbook.mforderdet?.stat == "Ok" &&
          mforderbook.mforderdet?.data != null &&
          mforderbook.mforderdet!.data!.isNotEmpty) {
        // Convert fetched order data to Data model
        final orderDetail = mforderbook.mforderdet!.data![0];

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return MFOrderDetailScreenWeb(mfOrderData: orderDetail);
          },
        );
      } else {
        // Show error or fallback
        if (!mounted) return;

        // Show error message
        ResponsiveSnackBar.showError(
            context,
            'Failed to fetch order details: ${mforderbook.mforderdet?.stat ?? "Unknown error"}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading if still showing
        ResponsiveSnackBar.showError(context, 'Error: ${e.toString()}');
      }
    }
  }
}
