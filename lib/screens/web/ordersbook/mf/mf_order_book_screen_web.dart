import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
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
        return Container(
          child: Scrollbar(
            controller: _verticalScrollController,
            thumbVisibility: true,
            radius: Radius.zero,
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(right: 16), // Space for vertical scrollbar
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DataTable(
                      columnSpacing: 10,
                      horizontalMargin: 0,
                      showCheckboxColumn: false,
                      sortColumnIndex: _mfSortColumnIndex,
                      sortAscending: _mfSortAscending,
                      headingRowHeight: 44,
                      headingRowColor: WidgetStateProperty.all(Colors.transparent),
                      dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return (theme.isDarkMode
                                    ? WebDarkColors.primary
                                    : WebColors.primary)
                                .withOpacity(0.15);
                          }
                          if (states.contains(WidgetState.selected)) {
                            return (theme.isDarkMode
                                    ? WebDarkColors.primary
                                    : WebColors.primary)
                                .withOpacity(0.1);
                          }
                          return null;
                        },
                      ),
                      columns: [
                        DataColumn(
                          numeric: false, // Left-align text column
                          label: _buildSortableColumnHeader('Scheme', theme, 0),
                          onSort: (columnIndex, ascending) =>
                              _onSortMfTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          numeric: false, // Left-align text column
                          label: _buildSortableColumnHeader('Type', theme, 1),
                          onSort: (columnIndex, ascending) =>
                              _onSortMfTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          numeric: true, // Right-align numeric column
                          label: _buildSortableColumnHeader('Amount', theme, 2),
                          onSort: (columnIndex, ascending) =>
                              _onSortMfTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          numeric: true, // Right-align numeric column
                          label: _buildSortableColumnHeader('Time', theme, 3),
                          onSort: (columnIndex, ascending) =>
                              _onSortMfTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          numeric: false, // Left-align text column
                          label: _buildSortableColumnHeader('Status', theme, 4),
                          onSort: (columnIndex, ascending) =>
                              _onSortMfTable(columnIndex, ascending),
                        ),
                      ],
                      rows: _sortedMfOrders(orders).map((o) {
                        final time = o.datetime ?? '';
                        final scheme = o.name ?? o.schemename ?? '';
                        final type = (o.orderType == 'NRM' ? 'ONE-TIME' : 'SIP');
                        final amount = o.orderVal ?? o.amount ?? '0';
                        final status = (o.status ?? '').toUpperCase();
                        final statusColor = _statusColor(status, theme);
                        final uniqueId = o.orderId?.toString() ?? scheme;

                        return DataRow(
                          onSelectChanged: (bool? selected) {
                            _openMfOrderDetail(o);
                          },
                          cells: [
                            // Scheme
                            _buildCellWithHover(o, theme, uniqueId, DataCell(
                              Text(
                                scheme,
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ), alignment: Alignment.centerLeft),
                            // Type
                            _buildCellWithHover(o, theme, uniqueId, DataCell(
                              Container(
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
                                  style: WebTextStyles.tableDataCompact(
                                    isDarkTheme: theme.isDarkMode,
                                    color: type == 'ONE-TIME'
                                        ? Color.fromARGB(255, 88, 69, 147)
                                        : Color(0xff016B61),
                                  ),
                                ),
                              ),
                            ), alignment: Alignment.centerLeft),
                            // Amount
                            _buildCellWithHover(o, theme, uniqueId, DataCell(
                              Text(
                                double.tryParse(amount)?.toStringAsFixed(2) ?? amount,
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ), alignment: Alignment.centerRight),
                            // Time
                            _buildCellWithHover(o, theme, uniqueId, DataCell(
                              Text(
                                time,
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ), alignment: Alignment.centerRight),
                            // Status
                            _buildCellWithHover(o, theme, uniqueId, DataCell(
                              Text(
                                status,
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: statusColor,
                                ),
                              ),
                            ), alignment: Alignment.centerLeft),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _mfSortColumnIndex == columnIndex;
    // Check if this is a numeric column (Time column index is 3)
    final isNumeric = columnIndex == 2 || columnIndex == 3; // Amount (2) or Time (3)
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: WebTextStyles.tableHeader(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        // Reserve fixed space for sort indicator
        SizedBox(
          width: 20,
          height: 16,
          child: !isSorted 
              ? Icon(
                  Icons.unfold_more,
                  size: 16,
                  color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  DataCell _buildCellWithHover(dynamic order, ThemesProvider theme, String token, DataCell cell, {Alignment alignment = Alignment.centerRight}) {
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() {}),
        onExit: (_) => setState(() {}),
        child: SizedBox.expand(
          child: Align(
            alignment: alignment,
            child: cell.child,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to fetch order details: ${mforderbook.mforderdet?.stat ?? "Unknown error"}'),
            backgroundColor: colors.lossLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading if still showing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: colors.lossLight,
          ),
        );
      }
    }
  }
}
