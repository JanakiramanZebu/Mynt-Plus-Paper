import 'package:flutter/material.dart' hide Table, TableRow, TableCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:mynt_plus/models/desk_reports_model/unpledge_history_model.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';

class UnpledgeHistoryScreen extends StatefulWidget {
  final String searchQuery;
  const UnpledgeHistoryScreen({super.key, this.searchQuery = ''});

  @override
  State<UnpledgeHistoryScreen> createState() => _UnpledgeHistoryScreenState();
}

class _UnpledgeHistoryScreenState extends State<UnpledgeHistoryScreen> {
  final ScrollController _tableScrollController = ScrollController();
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);

  static const int _totalColumns = 8;

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

  List<Data> _sortList(List<Data> list) {
    if (_sortColumnIndex == null) return list;
    final sortedList = List<Data>.from(list);

    sortedList.sort((a, b) {
      int comparison = 0;
      switch (_sortColumnIndex) {
        case 0: // Clientid
          comparison = (a.clientid ?? '').compareTo(b.clientid ?? '');
          break;
        case 1: // ISIN
          comparison = (a.iSIN ?? '').toLowerCase().compareTo((b.iSIN ?? '').toLowerCase());
          break;
        case 2: // Script
          comparison = (a.script ?? '').toLowerCase().compareTo((b.script ?? '').toLowerCase());
          break;
        case 3: // Unpledge qty
          final qtyA = int.tryParse(a.unPlegeQty ?? '0') ?? 0;
          final qtyB = int.tryParse(b.unPlegeQty ?? '0') ?? 0;
          comparison = qtyA.compareTo(qtyB);
          break;
        case 4: // Requested date & time
          comparison = (a.reqDatTime ?? '').compareTo(b.reqDatTime ?? '');
          break;
        case 5: // Approved date & time
          comparison = (a.appDatTime ?? '').compareTo(b.appDatTime ?? '');
          break;
        case 6: // Status
          comparison = (a.status ?? '').compareTo(b.status ?? '');
          break;
        case 7: // Reason
          comparison = (a.reason ?? '').toLowerCase().compareTo((b.reason ?? '').toLowerCase());
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return sortedList;
  }

  @override
  void dispose() {
    _tableScrollController.dispose();
    _hoveredRowIndex.dispose();
    super.dispose();
  }

  // ── Text style helpers ──

  TextStyle _getTextStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }

  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
      darkColor: color ?? MyntColors.textSecondaryDark,
      lightColor: color ?? MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  // ── Cell builders ──

  shadcn.TableCell _buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == _totalColumns - 1;

    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 0, 8, 0);
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(8, 0, 16, 0);
    } else {
      headerPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 0);
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
      child: InkWell(
        onTap: () => _onSort(columnIndex),
        child: Container(
          padding: headerPadding,
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
              if (alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    style: _getHeaderStyle(context),
                    overflow: TextOverflow.ellipsis),
              ),
              if (!alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              if (!alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  shadcn.TableCell _buildDataCell({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == _totalColumns - 1;

    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 12, 12, 12);
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(12, 12, 16, 12);
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
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
        onEnter: (_) => _hoveredRowIndex.value = rowIndex,
        onExit: (_) => _hoveredRowIndex.value = null,
        child: ValueListenableBuilder<int?>(
          valueListenable: _hoveredRowIndex,
          builder: (context, hoveredIndex, _) {
            final isRowHovered = hoveredIndex == rowIndex;
            return Container(
              padding: cellPadding,
              color: isRowHovered
                  ? resolveThemeColor(context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary)
                      .withValues(alpha: 0.08)
                  : null,
              alignment: alignRight ? Alignment.topRight : null,
              child: child,
            );
          },
        ),
      ),
    );
  }

  // ── Status badge ──

  Widget _buildStatusBadge(BuildContext context, String? status) {
    final isApproved = status == 'Approved';

    final bgColor = isApproved
        ? resolveThemeColor(context,
                dark: MyntColors.profitDark, light: MyntColors.profit)
            .withValues(alpha: 0.1)
        : resolveThemeColor(context,
                dark: MyntColors.lossDark, light: MyntColors.loss)
            .withValues(alpha: 0.1);

    final textColor = isApproved
        ? resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit)
        : resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: bgColor,
      ),
      child: Text(
        status ?? '--',
        style: MyntWebTextStyles.tableCell(
          context,
          color: textColor,
          darkColor: textColor,
          lightColor: textColor,
          fontWeight: MyntFonts.medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final ledgerprovider = ref.watch(ledgerProvider);

      if (ledgerprovider.unPledgeHistoryData?.data?.isEmpty ?? true) {
        return const Center(
          child: NoDataFound(secondaryEnabled: false),
        );
      }

      var dataList = List<Data>.from(ledgerprovider.unPledgeHistoryData!.data!);

      // Apply search filter
      if (widget.searchQuery.isNotEmpty) {
        dataList = dataList.where((item) {
          final query = widget.searchQuery;
          return (item.clientid ?? '').toLowerCase().contains(query) ||
              (item.iSIN ?? '').toLowerCase().contains(query) ||
              (item.script ?? '').toLowerCase().contains(query) ||
              (item.reason ?? '').toLowerCase().contains(query);
        }).toList();
      }

      dataList = _sortList(dataList);

      if (dataList.isEmpty) {
        return const Center(
          child: NoDataFound(secondaryEnabled: false),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth - 32;
          final double clientIdWidth = totalWidth * 0.10;
          final double isinWidth = totalWidth * 0.13;
          final double scriptWidth = totalWidth * 0.12;
          final double qtyWidth = totalWidth * 0.10;
          final double reqDateWidth = totalWidth * 0.15;
          final double appDateWidth = totalWidth * 0.15;
          final double statusWidth = totalWidth * 0.10;
          final double reasonWidth = totalWidth * 0.15;

          final columnWidths = {
            0: shadcn.FixedTableSize(clientIdWidth),
            1: shadcn.FixedTableSize(isinWidth),
            2: shadcn.FixedTableSize(scriptWidth),
            3: shadcn.FixedTableSize(qtyWidth),
            4: shadcn.FixedTableSize(reqDateWidth),
            5: shadcn.FixedTableSize(appDateWidth),
            6: shadcn.FixedTableSize(statusWidth),
            7: shadcn.FixedTableSize(reasonWidth),
          };

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: shadcn.OutlinedContainer(
              child: Column(
                children: [
                  // Fixed Header
                  shadcn.Table(
                    defaultRowHeight: const shadcn.FixedTableSize(50),
                    columnWidths: columnWidths,
                    rows: [
                      shadcn.TableHeader(
                        cells: [
                          _buildHeaderCell('Client ID', 0),
                          _buildHeaderCell('ISIN', 1),
                          _buildHeaderCell('Script', 2),
                          _buildHeaderCell('Unpledge Qty', 3, true),
                          _buildHeaderCell('Requested Date', 4),
                          _buildHeaderCell('Approved Date', 5),
                          _buildHeaderCell('Status', 6),
                          _buildHeaderCell('Reason', 7),
                        ],
                      ),
                    ],
                  ),
                  // Scrollable data rows
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _tableScrollController,
                      child: shadcn.Table(
                        defaultRowHeight: const shadcn.FixedTableSize(52),
                        columnWidths: columnWidths,
                        rows: dataList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return shadcn.TableRow(
                            cells: [
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 0,
                                child: Text(item.clientid ?? '--',
                                    style: _getTextStyle(context)),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 1,
                                child: Text(item.iSIN ?? '--',
                                    style: _getTextStyle(context)),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 2,
                                child: Text(item.script ?? '--',
                                    style: _getTextStyle(context)),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 3,
                                alignRight: true,
                                child: Text(item.unPlegeQty ?? '--',
                                    style: _getTextStyle(context)),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 4,
                                child: Text(
                                  item.reqDatTime ?? '--',
                                  style: _getTextStyle(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 5,
                                child: Text(
                                  item.appDatTime ?? '--',
                                  style: _getTextStyle(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 6,
                                child: _buildStatusBadge(context, item.status),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 7,
                                child: Text(
                                  item.reason ?? '--',
                                  style: _getTextStyle(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
