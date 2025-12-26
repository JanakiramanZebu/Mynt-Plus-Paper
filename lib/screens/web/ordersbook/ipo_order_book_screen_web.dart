import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../sharedWidget/functions.dart';
import '../../../res/res.dart';
import '../../../res/global_state_text.dart';

class IpoOrderBookScreenWeb extends ConsumerStatefulWidget {
  const IpoOrderBookScreenWeb({super.key});

  @override
  ConsumerState<IpoOrderBookScreenWeb> createState() => _IpoOrderBookScreenWebState();
}

class _IpoOrderBookScreenWebState extends ConsumerState<IpoOrderBookScreenWeb> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _selectedOrderType = 'Open'; // 'Open' or 'Closed'


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ipoProvide).getipoorderbookmodel(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final ipo = ref.watch(ipoProvide);

    final openOrders = ipo.openorder ?? [];
    final closeOrders = ipo.closeorder ?? [];
    final currentOrders = _selectedOrderType == 'Open' ? openOrders : closeOrders;

    return _buildAdaptiveContainer(
      theme: theme,
      child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderTypeSelector(theme),
              currentOrders.isEmpty
          ? _buildNoDataWidget()
          :  _buildOrdersTable(currentOrders, theme),
              ],
            ),
    );
  }

  Widget _buildAdaptiveContainer({required ThemesProvider theme, required Widget child}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // Adaptive height
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
       
      ),
      child: child,
    );
  }

  Widget _buildNoDataWidget() {
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

  Widget _buildOrderTypeSelector(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Order Type:',
          style: TextWidget.textStyle(
            fontSize: 14,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            theme: theme.isDarkMode,
            fw: 2,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.darkGrey : colors.colorWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedOrderType,
            underline: const SizedBox(),
            style: TextWidget.textStyle(
              fontSize: 12,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 2,
            ),
            items: ['Open', 'Closed'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedOrderType = newValue;
                  _sortColumnIndex = null; // Reset sorting when changing order type
                });
              }
            },
          ),
        ),
      ],
    ));
  }

  Widget _buildOrdersTable(List<dynamic> orders, ThemesProvider theme) {
    return Expanded(
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              headingRowColor: WidgetStateProperty.all(
                theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
              ),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return (theme.isDarkMode ? colors.primaryDark : colors.primaryLight).withOpacity(0.1);
                  }
                  return null;
                },
              ),
              columns: _buildTableColumns(theme),
              rows: _buildTableRows(orders, theme),
            ),
          ),
        ),
      ),
    );
  }

 

  List<DataColumn> _buildTableColumns(ThemesProvider theme) {
    return [
      DataColumn(
        label: _buildSortableColumnHeader('Company Name', theme,
            isActive: _sortColumnIndex == 0, ascending: _sortAscending),
        onSort: (i, asc) => _onSortTable(0),
      ),
      DataColumn(
        label: _buildSortableColumnHeader('Symbol', theme,
            isActive: _sortColumnIndex == 1, ascending: _sortAscending),
        onSort: (i, asc) => _onSortTable(1),
      ),
      DataColumn(
        label: _buildSortableColumnHeader('Type', theme,
            isActive: _sortColumnIndex == 2, ascending: _sortAscending),
        onSort: (i, asc) => _onSortTable(2),
      ),
      DataColumn(
        label: _buildSortableColumnHeader('Amount', theme,
            isActive: _sortColumnIndex == 3, ascending: _sortAscending),
        onSort: (i, asc) => _onSortTable(3),
      ),
      DataColumn(
        label: _buildSortableColumnHeader('Date', theme,
            isActive: _sortColumnIndex == 4, ascending: _sortAscending),
        onSort: (i, asc) => _onSortTable(4),
      ),
      DataColumn(
        label: _buildSortableColumnHeader('Status', theme,
            isActive: _sortColumnIndex == 5, ascending: _sortAscending),
        onSort: (i, asc) => _onSortTable(5),
      ),
    ];
  }

  List<DataRow> _buildTableRows(List<dynamic> orders, ThemesProvider theme) {
    return _sortedOrders(orders).map((order) {
      return DataRow(
        cells: [
          _buildDataCell(order.companyName?.toString() ?? '', theme, isPrimary: true),
          _buildDataCell(order.symbol?.toString() ?? '', theme),
          _buildDataCell(order.type?.toString() ?? '', theme),
          _buildDataCell(_getInvestedAmount(order), theme),
          _buildDataCell(
            order.responseDatetime?.toString() == "" 
                ? "----" 
                : ipodateres(order.responseDatetime.toString()), 
            theme, 
            isSecondary: true
          ),
          _buildStatusCell(order, theme),
        ],
      );
    }).toList();
  }

  DataCell _buildDataCell(String text, ThemesProvider theme, {bool isPrimary = false, bool isSecondary = false}) {
    return DataCell(
      Text(
        text,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: isSecondary 
              ? (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight)
              : (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
          theme: theme.isDarkMode,
          fw: isPrimary ? 3 : 2,
        ),
      ),
    );
  }

  DataCell _buildStatusCell(dynamic order, ThemesProvider theme) {
    final status = _getStatusText(order);
    final statusColor = _getStatusColor(status, theme);
    
    return DataCell(
      Text(
        status,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: statusColor,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }


  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, {bool isActive = false, bool ascending = true}) {
    return Text(
      label,
      style: TextWidget.textStyle(
        fontSize: 12,
        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
        theme: theme.isDarkMode,
        fw: 2,
      ),
    );
  }

  void _onSortTable(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  List<dynamic> _sortedOrders(List<dynamic> orders) {
    if (_sortColumnIndex == null) return orders;
    final sorted = [...orders];
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
        case 0: // Company Name
          r = cmp<String>(a.companyName, b.companyName);
          break;
        case 1: // Symbol
          r = cmp<String>(a.symbol, b.symbol);
          break;
        case 2: // Type
          r = cmp<String>(a.type, b.type);
          break;
        case 3: // Amount
          r = cmp<num>(parseNum(_getInvestedAmount(a)), parseNum(_getInvestedAmount(b)));
          break;
        case 4: // Date
          r = cmp<String>(a.responseDatetime, b.responseDatetime);
          break;
        case 5: // Status
          String aStatus = _getStatusText(a);
          String bStatus = _getStatusText(b);
          r = cmp<String>(aStatus, bStatus);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  String _getInvestedAmount(dynamic order) {
    if (order.bidDetail == null || order.bidDetail.isEmpty) return "0";
    
    if (order.type == "BSE") {
      return getFormatter(noDecimal: true, v4d: false, value: double.parse(order.bidDetail![0].rate!) * double.parse(order.bidDetail![0].quantity!)).toString();
    } else {
      return getFormatter(noDecimal: true, v4d: false, value: double.parse(order.bidDetail![0].amount.toString()));
    }
  }

  String _getStatusText(dynamic order) {
    if (_selectedOrderType == 'Open') {
      return order.reponseStatus == "new success" ? "Success" : "Pending";
    } else {
      return order.reponseStatus == "cancel success" ? "Cancelled" : "Failed";
    }
  }

  Color _getStatusColor(String status, ThemesProvider theme) {
    switch (status.toLowerCase()) {
      case 'success':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'pending':
        return colors.pending;
      case 'cancelled':
        return colors.pending;
      case 'failed':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      default:
        return theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight;
    }
  }

  // Utility methods for reusability
  bool get hasOpenOrders {
    final ipo = ref.read(ipoProvide);
    return (ipo.openorder ?? []).isNotEmpty;
  }

  bool get hasClosedOrders {
    final ipo = ref.read(ipoProvide);
    return (ipo.closeorder ?? []).isNotEmpty;
  }

  int get totalOrdersCount {
    final ipo = ref.read(ipoProvide);
    final openCount = (ipo.openorder ?? []).length;
    final closedCount = (ipo.closeorder ?? []).length;
    return openCount + closedCount;
  }

  String get currentOrderType => _selectedOrderType;
  
  int get currentOrdersCount {
    final ipo = ref.read(ipoProvide);
    if (_selectedOrderType == 'Open') {
      return (ipo.openorder ?? []).length;
    } else {
      return (ipo.closeorder ?? []).length;
    }
  }
}
