import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../res/res.dart';
import '../../../../res/global_state_text.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mfProvider).fetchMfOrderbook(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mf = ref.watch(mfProvider);

    final orders = mf.mflumpsumorderbook?.data ?? [];

    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.kColorLightGreyDarkTheme
            : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: orders.isEmpty
          ? const SizedBox(
              height: 400,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: NoDataFound(),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: IntrinsicWidth(
                    child: DataTable(
                    showCheckboxColumn: false,
                    sortColumnIndex: _mfSortColumnIndex,
                    sortAscending: _mfSortAscending,
                    headingRowColor: WidgetStateProperty.all(
                      theme.isDarkMode
                          ? colors.kColorLightGreyDarkTheme
                          : colors.kColorLightGrey,
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return (theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight)
                              .withOpacity(0.1);
                        }
                        return null;
                      },
                    ),
                    columns: [
                      DataColumn(
                        label: _buildSortableColumnHeader('Time', theme,
                            isActive: _mfSortColumnIndex == 0,
                            ascending: _mfSortAscending),
                        onSort: (i, asc) => _onSortMfTable(0),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Scheme', theme,
                            isActive: _mfSortColumnIndex == 1,
                            ascending: _mfSortAscending),
                        onSort: (i, asc) => _onSortMfTable(1),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Type', theme,
                            isActive: _mfSortColumnIndex == 2,
                            ascending: _mfSortAscending),
                        onSort: (i, asc) => _onSortMfTable(2),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Amount', theme,
                            isActive: _mfSortColumnIndex == 3,
                            ascending: _mfSortAscending),
                        onSort: (i, asc) => _onSortMfTable(3),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Status', theme,
                            isActive: _mfSortColumnIndex == 4,
                            ascending: _mfSortAscending),
                        onSort: (i, asc) => _onSortMfTable(4),
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
                          DataCell(
                            Text(
                              time,
                              style: TextWidget.textStyle(
                                fontSize: 12,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                theme: theme.isDarkMode,
                                fw: 2,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              scheme,
                              style: TextWidget.textStyle(
                                fontSize: 12,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                theme: theme.isDarkMode,
                                fw: 2,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              type,
                              style: TextWidget.textStyle(
                                fontSize: 12,
                                color: type == 'ONE-TIME'
                                    ? (theme.isDarkMode
                                        ? colors.profitDark
                                        : colors.profitLight)
                                    : (theme.isDarkMode
                                        ? colors.lossDark
                                        : colors.lossLight),
                                theme: theme.isDarkMode,
                                fw: 2,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              double.parse(amount).toStringAsFixed(2),
                              style: TextWidget.textStyle(
                                fontSize: 12,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                theme: theme.isDarkMode,
                                fw: 2,
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () => _openMfOrderDetail(o),
                              child: Text(
                                status,
                                style: TextWidget.textStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  theme: theme.isDarkMode,
                                  fw: 2,
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

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme,
      {bool isActive = false, bool ascending = true}) {
    return Text(
      label,
      style: TextWidget.textStyle(
        fontSize: 12,
        color: theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight,
        theme: theme.isDarkMode,
        fw: 2,
      ),
    );
  }

  void _onSortMfTable(int columnIndex) {
    setState(() {
      if (_mfSortColumnIndex == columnIndex) {
        _mfSortAscending = !_mfSortAscending;
      } else {
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
        case 0: // Time
          r = cmp<String>(a.datetime, b.datetime);
          break;
        case 1: // Scheme
          r = cmp<String>(a.name ?? a.schemename, b.name ?? b.schemename);
          break;
        case 2: // Type
          String aType = (a.orderType == 'NRM' ? 'ONE-TIME' : 'SIP');
          String bType = (b.orderType == 'NRM' ? 'ONE-TIME' : 'SIP');
          r = cmp<String>(aType, bType);
          break;
        case 3: // Amount
          r = cmp<num>(parseNum(a.orderVal ?? a.amount),
              parseNum(b.orderVal ?? b.amount));
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
