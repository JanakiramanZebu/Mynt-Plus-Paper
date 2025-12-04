import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/order_provider.dart';
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
  int? _hoveredColumnIndex; // Track which column is being hovered

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
    final orderBook = ref.watch(orderProvider);
    
    // Use filtered results from provider (same pattern as other tabs)
    final isSearching = orderBook.orderSearchCtrl.text.isNotEmpty;
    final orders = isSearching
        ? (mf.mfOrderSearch ?? [])
        : (mf.mflumpsumorderbook?.data ?? []);

    // Show loading indicator if data is being fetched and no existing data
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height
        final screenHeight = MediaQuery.of(context).size.height;
        final padding = 32.0; // Top and bottom padding (16 * 2)
        final headerHeight = 50.0; // Header height (tabs + search bar)
        final spacing = 16.0; // Spacing between header and content
        final bottomMargin = 20.0; // Bottom margin
        final tableHeight =
            screenHeight - padding - headerHeight - spacing - bottomMargin;

        // Ensure we don't exceed 75% of screen height
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveMfOrderColumns(screenWidth);
        final headers = List<String>.from(responsiveConfig['headers'] as List);
        final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
        
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
                  // Make both scrollbars always visible
                  thumbVisibility: MaterialStateProperty.all(true),
                  trackVisibility: MaterialStateProperty.all(true),
                  
                  // Consistent thickness for both horizontal and vertical
                  thickness: MaterialStateProperty.all(6.0),
                  crossAxisMargin: 0.0,
                  mainAxisMargin: 0.0,
                  
                  // Consistent radius
                  radius: const Radius.circular(3),
                  
                  // Consistent colors for both scrollbars
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
                minWidth: 1200,
                sortColumnIndex: null, // Disable DataTable2's built-in sorting
                sortAscending: _mfSortAscending,
                fixedLeftColumns: 1, // Fix the first column (Scheme)
                fixedColumnsColor: theme.isDarkMode 
                    ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                    : WebColors.backgroundSecondary.withOpacity(0.8),
                showBottomBorder: true,
                horizontalScrollController: _horizontalScrollController,
                scrollController: _verticalScrollController,
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
                  // Remove vertical lines
                ),
                columns: _buildMfOrderDataTable2Columns(headers, columnMinWidth, theme),
                rows: _buildMfOrderDataTable2Rows(orders, headers, theme),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to get responsive column configuration for MF Orders
  // Always show all columns - horizontal scroll handles overflow on small screens
  Map<String, dynamic> _getResponsiveMfOrderColumns(double screenWidth) {
    return {
      'headers': ['Scheme', 'Type', 'Amount', 'Time', 'Status'],
      'columnMinWidth': {
        'Scheme': 300,
        'Type': 120,
        'Amount': 120,
        'Time': 220,
        'Status': 110,
      },
    };
  }

  bool _isNumericColumnMfOrder(String header) {
    return header == 'Amount' || header == 'Time'; // Amount and Time are numeric/right-aligned
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

  List<DataColumn2> _buildMfOrderDataTable2Columns(
    List<String> headers,
    Map<String, double> columnMinWidth,
    ThemesProvider theme,
  ) {
    return headers.map((header) {
      final columnIndex = _getMfOrderColumnIndexForHeader(header);
      final isNumeric = _isNumericColumnMfOrder(header);
      final isScheme = header == 'Scheme';
      final isTime = header == 'Time';
      
      return DataColumn2(
        label: SizedBox.expand(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoveredColumnIndex = columnIndex),
            onExit: (_) => setState(() => _hoveredColumnIndex = null),
            child: Tooltip(
              message: 'Sort by $header',
              child: GestureDetector(
                onTap: () => _onSortMfTable(columnIndex),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: _hoveredColumnIndex == columnIndex
                        ? (theme.isDarkMode
                            ? WebDarkColors.primary.withOpacity(0.1)
                            : WebColors.primary.withOpacity(0.05))
                        : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              header,
                              style: WebTextStyles.tableHeader(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                              ),
                              textAlign: isNumeric ? TextAlign.right : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 16, // Fixed width for the icon
                              child: _buildMfOrderSortIcon(columnIndex, theme),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        size: isScheme ? ColumnSize.L : ColumnSize.S,
        fixedWidth: isScheme ? 300.0 : (isTime ? 220.0 : null),
        onSort: null, // Disable DataTable2's default sort
      );
    }).toList();
  }

  List<DataRow2> _buildMfOrderDataTable2Rows(
    List<dynamic> orders,
    List<String> headers,
    ThemesProvider theme,
  ) {
    final sorted = _sortedMfOrders(orders);
    return sorted.map((order) {
      final uniqueId = order.orderId?.toString() ?? 
          (order.name ?? order.schemename ?? '') + sorted.indexOf(order).toString();
      final isHovered = _hoveredRowToken == uniqueId;

      return DataRow2(
        color: MaterialStateProperty.resolveWith((states) {
          if (isHovered) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return null;
        }),
        cells: headers.map((header) {
          return _buildMfOrderDataTable2Cell(
            header,
            order,
            theme,
            isHovered,
            uniqueId,
          );
        }).toList(),
        onTap: () => _openMfOrderDetail(order),
      );
    }).toList();
  }

  DataCell _buildMfOrderDataTable2Cell(
    String column,
    dynamic order,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId,
  ) {
    Widget cellContent;
    
    switch (column) {
      case 'Scheme':
        final scheme = order.name ?? order.schemename ?? 'N/A';
        cellContent = _buildMfOrderTextCell(
          scheme,
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Type':
        final type = (order.orderType == 'NRM' ? 'ONE-TIME' : 'SIP');
        cellContent = _buildMfOrderTypeCell(type, theme);
        break;
      case 'Amount':
        final amount = order.orderVal ?? order.amount ?? '0';
        final amountText = double.tryParse(amount.toString())?.toStringAsFixed(2) ?? amount.toString();
        cellContent = _buildMfOrderTextCell(
          amountText,
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Time':
        final time = order.datetime ?? '';
        cellContent = _buildMfOrderTextCell(
          time,
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Status':
        final status = (order.status ?? '').toUpperCase();
        final statusColor = _statusColor(status, theme);
        cellContent = _buildMfOrderTextCell(
          status,
          theme,
          Alignment.centerLeft,
          color: statusColor,
        );
        break;
      default:
        cellContent = const SizedBox.shrink();
    }

    // Wrap with MouseRegion to detect hover anywhere on the cell
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: cellContent,
        ),
      ),
    );
  }

  Widget _buildMfOrderSortIcon(int columnIndex, ThemesProvider theme) {
    IconData icon;
    Color color;

    if (_mfSortColumnIndex == columnIndex) {
      // Column is currently sorted
      icon = _mfSortAscending ? Icons.arrow_upward : Icons.arrow_downward;
      color = theme.isDarkMode ? WebDarkColors.primary : WebColors.primary;
    } else {
      // Column is not sorted
      icon = Icons.unfold_more;
      color = theme.isDarkMode
          ? WebDarkColors.iconSecondary.withOpacity(0.6)
          : WebColors.iconSecondary.withOpacity(0.6);
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  Widget _buildMfOrderTypeCell(String type, ThemesProvider theme) {
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
  }


  Widget _buildMfOrderTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
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
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }


  void _onSortMfTable(int columnIndex) {
    setState(() {
      if (_mfSortColumnIndex == columnIndex) {
        // If the same column is tapped, toggle the sort order
        _mfSortAscending = !_mfSortAscending;
      } else {
        // If a new column is tapped, sort it ascending by default
        _mfSortColumnIndex = columnIndex;
        _mfSortAscending = true;
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
