import 'package:flutter/material.dart' hide Table, TableRow, TableCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:mynt_plus/models/desk_reports_model/pledge_history_model.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';

class PledgeHistoryScreen extends StatefulWidget {
  final String searchQuery;
  const PledgeHistoryScreen({super.key, this.searchQuery = ''});

  @override
  State<PledgeHistoryScreen> createState() => _PledgeHistoryScreenState();
}

class _PledgeHistoryScreenState extends State<PledgeHistoryScreen> {
  final ScrollController _tableScrollController = ScrollController();
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);

  static const int _totalColumns = 7;

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

  List<ReqList> _sortList(List<ReqList> list) {
    if (_sortColumnIndex == null) return list;
    final sortedList = List<ReqList>.from(list);

    sortedList.sort((a, b) {
      int comparison = 0;
      switch (_sortColumnIndex) {
        case 0: // ISIN
          comparison = (a.isin ?? '').toLowerCase().compareTo((b.isin ?? '').toLowerCase());
          break;
        case 1: // Script
          comparison = (a.symbol ?? '').toLowerCase().compareTo((b.symbol ?? '').toLowerCase());
          break;
        case 2: // ISIN Request Id
          comparison = (a.isinreqid ?? '').toLowerCase().compareTo((b.isinreqid ?? '').toLowerCase());
          break;
        case 3: // Quantity
          final qtyA = int.tryParse(a.quantity ?? '0') ?? 0;
          final qtyB = int.tryParse(b.quantity ?? '0') ?? 0;
          comparison = qtyA.compareTo(qtyB);
          break;
        case 4: // Segments
          comparison = (a.segments ?? '').toLowerCase().compareTo((b.segments ?? '').toLowerCase());
          break;
        case 5: // Status
          comparison = (a.status ?? '').compareTo(b.status ?? '');
          break;
        case 6: // Reason (datetime as fallback)
          comparison = (a.datetime ?? '').compareTo(b.datetime ?? '');
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
              Text(label, style: _getHeaderStyle(context)),
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
    String label;
    Color bgColor;
    Color textColor;

    if (status == '0') {
      label = 'Success';
      bgColor = resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit)
          .withValues(alpha: 0.1);
      textColor = resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (status == '1') {
      label = 'Rejected';
      bgColor = resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss)
          .withValues(alpha: 0.1);
      textColor = resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else {
      label = 'Pending';
      bgColor = const Color(0xffF9B039).withValues(alpha: 0.1);
      textColor = const Color(0xffF9B039);
    }

    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: bgColor,
        ),
        child: Text(
          label,
          style: MyntWebTextStyles.tableCell(
            context,
            color: textColor,
            darkColor: textColor,
            lightColor: textColor,
            fontWeight: MyntFonts.medium,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final ledgerprovider = ref.watch(ledgerProvider);

      if (ledgerprovider.pledgeHistoryData?.data?.isEmpty ?? true) {
        return const Center(
          child: NoDataFound(secondaryEnabled: false),
        );
      }

      var dataList = List<ReqList>.from(ledgerprovider.historyalterlist);

      // Apply search filter
      if (widget.searchQuery.isNotEmpty) {
        dataList = dataList.where((item) {
          final query = widget.searchQuery;
          return (item.isin ?? '').toLowerCase().contains(query) ||
              (item.symbol ?? '').toLowerCase().contains(query) ||
              (item.isinreqid ?? '').toLowerCase().contains(query) ||
              (item.segments ?? '').toLowerCase().contains(query);
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
          final double isinWidth = totalWidth * 0.15;
          final double scriptWidth = totalWidth * 0.13;
          final double reqIdWidth = totalWidth * 0.20;
          final double qtyWidth = totalWidth * 0.10;
          final double segmentsWidth = totalWidth * 0.10;
          final double statusWidth = totalWidth * 0.12;
          final double reasonWidth = totalWidth * 0.20;

          final columnWidths = {
            0: shadcn.FixedTableSize(isinWidth),
            1: shadcn.FixedTableSize(scriptWidth),
            2: shadcn.FixedTableSize(reqIdWidth),
            3: shadcn.FixedTableSize(qtyWidth),
            4: shadcn.FixedTableSize(segmentsWidth),
            5: shadcn.FixedTableSize(statusWidth),
            6: shadcn.FixedTableSize(reasonWidth),
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
                          _buildHeaderCell('Date & Time', 0),
                          _buildHeaderCell('ISIN', 1),
                          _buildHeaderCell('Script', 2),
                          _buildHeaderCell('ISIN Request Id', 3),
                          _buildHeaderCell('Quantity', 4, true),
                          _buildHeaderCell('Segments', 5),
                          _buildHeaderCell('Status', 6),
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
                                child: Text(
                                  item.datetime ?? '--',
                                  style: _getTextStyle(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 1,
                                child: Text(item.isin ?? '--',
                                    style: _getTextStyle(context)),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 2,
                                child: Text(item.symbol ?? '--',
                                    style: _getTextStyle(context)),
                              ),

                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 3,
                                child: Text(
                                  item.isinreqid ?? '--',
                                  style: _getTextStyle(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 4,
                                alignRight: true,
                                child: Text(item.quantity ?? '--',
                                    style: _getTextStyle(context)),
                              ),
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 5,
                                child: Text(item.segments ?? '--',
                                    style: _getTextStyle(context)),
                              ),
                              
                              _buildDataCell(
                                rowIndex: index,
                                columnIndex: 6,
                                child: _buildStatusBadge(context, item.status),
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
