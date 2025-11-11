import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../res/res.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import 'mf_order_detail_screen_web.dart';

class MfOrderBookScreenWeb extends ConsumerStatefulWidget {
  const MfOrderBookScreenWeb({super.key});

  @override
  ConsumerState<MfOrderBookScreenWeb> createState() =>
      _MfOrderBookScreenWebState();
}

class _MfOrderBookScreenWebState extends ConsumerState<MfOrderBookScreenWeb> {
  int? _mfSortColumnIndex;
  bool _mfSortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mfProvider).fetchMfOrderbook(context);
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mf = ref.watch(mfProvider);

    final orders = mf.mflumpsumorderbook?.data ?? [];

    if (orders.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }

    // Calculate table height based on screen size (60% of available height)
    final screenHeight = MediaQuery.of(context).size.height;
    final tableHeight = screenHeight * 0.6;
    
    return SizedBox(
      height: tableHeight,
      child: Scrollbar(
        controller: _verticalScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: DataTable(
                columnSpacing: 10,
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
                          .withOpacity(0.05);
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
                        label: _buildSortableColumnHeader('Scheme', theme, 0),
                        onSort: (columnIndex, ascending) =>
                            _onSortMfTable(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Type', theme, 1),
                        onSort: (columnIndex, ascending) =>
                            _onSortMfTable(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Amount', theme, 2),
                        onSort: (columnIndex, ascending) =>
                            _onSortMfTable(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Time', theme, 3),
                        onSort: (columnIndex, ascending) =>
                            _onSortMfTable(columnIndex, ascending),
                      ),
                      DataColumn(
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

                      return DataRow(
                        onSelectChanged: (bool? selected) {
                          _openMfOrderDetail(o);
                        },
                        cells: [
                          // Scheme
                          DataCell(
                            Text(
                              scheme,
                              style: WebTextStyles.custom(
                                fontSize: 13,
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                                fontWeight: WebFonts.medium,
                              ),
                            ),
                          ),
                          // Type
                          DataCell(
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
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: type == 'ONE-TIME'
                                      ? Color.fromARGB(255, 88, 69, 147)
                                      : Color(0xff016B61),
                                  fontWeight: WebFonts.medium,
                                ),
                              ),
                            ),
                          ),
                          // Amount
                          DataCell(
                            Text(
                              double.parse(amount).toStringAsFixed(2),
                              style: WebTextStyles.custom(
                                fontSize: 13,
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                                fontWeight: WebFonts.medium,
                              ),
                            ),
                          ),
                          // Time
                          DataCell(
                            Text(
                              time,
                              style: WebTextStyles.custom(
                                fontSize: 13,
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                                fontWeight: WebFonts.medium,
                              ),
                            ),
                          ),
                          // Status
                          DataCell(
                            InkWell(
                              onTap: () => _openMfOrderDetail(o),
                              child: Text(
                                status,
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: statusColor,
                                  fontWeight: WebFonts.medium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _mfSortColumnIndex == columnIndex;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.custom(
            fontSize: 14,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
            fontWeight: WebFonts.bold,
          ),
        ),
        const SizedBox(width: 4),
        // Reserve fixed space for sort indicator
        // Show custom icon when not sorted, DataTable will show its icon when sorted
        SizedBox(
          width: 20, // Fixed width to prevent layout shift
          height: 16,
          child: !isSorted 
              ? Icon(
                  Icons.unfold_more,
                  size: 16,
                  color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(), // Hide when sorted, DataTable will show its indicator
        ),
      ],
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
