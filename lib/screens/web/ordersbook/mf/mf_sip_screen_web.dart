import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import 'mf_sip_detail_screen_web.dart';
import 'sip_pause_dialogue_web.dart';
import 'sip_cancel_dialogue_web.dart';
import '../../../../models/mf_model/sip_mf_list_model.dart';

class MFSipdetScreenWeb extends ConsumerStatefulWidget {
  const MFSipdetScreenWeb({super.key});

  @override
  ConsumerState<MFSipdetScreenWeb> createState() => _MFSipdetScreenWebState();
}

class _MFSipdetScreenWebState extends ConsumerState<MFSipdetScreenWeb> 
    with AutomaticKeepAliveClientMixin {
  int? _sipSortColumnIndex;
  bool _sipSortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  String? _hoveredRowSipRegNo; // Track which row is being hovered

  @override
  bool get wantKeepAlive => true;

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

    final sipDetails = mf.mfsiporderlist?.data ?? [];

    if (sipDetails.isEmpty) {
      return const Center(child: NoDataFound());
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the available height from the parent Expanded widget
        final availableHeight = constraints.maxHeight;
        
        return SizedBox(
          height: availableHeight,
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
                      sortColumnIndex: _sipSortColumnIndex,
                      sortAscending: _sipSortAscending,
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
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          numeric: true, // Right-align numeric column
                          label: _buildSortableColumnHeader('SIP Reg No', theme, 1),
                          onSort: (columnIndex, ascending) =>
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          numeric: true, // Right-align numeric column
                          label: _buildSortableColumnHeader('Amount', theme, 2),
                          onSort: (columnIndex, ascending) =>
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          numeric: false, // Left-align text column
                          label: _buildSortableColumnHeader('Frequency', theme, 3),
                          onSort: (columnIndex, ascending) =>
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          numeric: false, // Left-align text column
                          label: _buildSortableColumnHeader('Next Installment', theme, 4),
                          onSort: (columnIndex, ascending) =>
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          numeric: false, // Left-align text column
                          label: _buildSortableColumnHeader('Status', theme, 5),
                          onSort: (columnIndex, ascending) =>
                              _onSortSipTable(columnIndex, ascending),
                        ),
                      ],
                      rows: _sortedSipDetails(sipDetails).map((s) {
                        final scheme = s.name ?? '';
                        final reg = s.sIPRegnNo ?? '';
                        final amount = s.installmentAmount?.toString() ?? '0';
                        final freq = s.frequencyType ?? '';
                        final nextInst = s.NextSIPDate ?? '';
                        final status = (s.status ?? '').toUpperCase();
                        final statusColor = _statusColor(status, theme);
                        final sipRegNo = reg; // Use SIP Reg No as unique identifier

                        return DataRow(
                          onSelectChanged: (bool? selected) {
                            _openSipDetail(s);
                          },
                          cells: [
                            // Scheme with hover actions
                            _buildSchemeCellWithHover(s, scheme, sipRegNo, theme),
                            // SIP Reg No
                            _buildCellWithHover(s, sipRegNo, theme, DataCell(
                              Text(
                                reg,
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ), alignment: Alignment.centerRight),
                            // Amount
                            _buildCellWithHover(s, sipRegNo, theme, DataCell(
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
                            // Frequency
                            _buildCellWithHover(s, sipRegNo, theme, DataCell(
                              Text(
                                freq,
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ), alignment: Alignment.centerLeft),
                            // Next Installment
                            _buildCellWithHover(s, sipRegNo, theme, DataCell(
                              Text(
                                nextInst,
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ), alignment: Alignment.centerLeft),
                            // Status
                            _buildCellWithHover(s, sipRegNo, theme, DataCell(
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
    final isSorted = _sipSortColumnIndex == columnIndex;
    // Check if this is a numeric column (SIP Reg No index is 1, Amount index is 2)
    final isNumeric = columnIndex == 1 || columnIndex == 2; // SIP Reg No (1) or Amount (2)
    
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

  void _onSortSipTable(int columnIndex, bool ascending) {
    setState(() {
      if (_sipSortColumnIndex == columnIndex) {
        _sipSortAscending = !_sipSortAscending;
      } else {
        _sipSortColumnIndex = columnIndex;
        _sipSortAscending = ascending;
      }
    });
  }

  List<dynamic> _sortedSipDetails(List<dynamic> sipDetails) {
    if (_sipSortColumnIndex == null) return sipDetails;
    final sorted = [...sipDetails];
    int c = _sipSortColumnIndex!;
    bool asc = _sipSortAscending;

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
          r = cmp<String>(a.name, b.name);
          break;
        case 1: // SIP Reg No
          r = cmp<String>(a.sIPRegnNo, b.sIPRegnNo);
          break;
        case 2: // Amount
          r = cmp<num>(parseNum(a.installmentAmount?.toString()),
              parseNum(b.installmentAmount?.toString()));
          break;
        case 3: // Frequency
          r = cmp<String>(a.frequencyType, b.frequencyType);
          break;
        case 4: // Next Installment
          r = cmp<String>(a.NextSIPDate, b.NextSIPDate);
          break;
        case 5: // Status
          r = cmp<String>(a.status, b.status);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  Color _statusColor(String status, ThemesProvider theme) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'running':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'stopped':
      case 'cancelled':
      case 'rejected':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      default:
        return colors.pending;
    }
  }

  void _openSipDetail(Xsip sipDetail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MFSipDetailScreenWeb(sipData: sipDetail);
      },
    );
  }

  DataCell _buildSchemeCellWithHover(dynamic sipDetail, String scheme, String sipRegNo, ThemesProvider theme) {
    final isHovered = _hoveredRowSipRegNo == sipRegNo;

    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowSipRegNo = sipRegNo),
        onExit: (_) => setState(() => _hoveredRowSipRegNo = null),
        child: SizedBox.expand(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text that shows half when hovered
                Expanded(
                  flex: isHovered ? 1 : 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Tooltip(
                      message: scheme,
                      child: Text(
                        scheme,
                        style: WebTextStyles.tableDataCompact(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                // Buttons that appear on hover - Only show when status is ACTIVE
                IgnorePointer(
                  ignoring: !isHovered,
                  child: AnimatedOpacity(
                    opacity: isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_shouldShowSipActions(sipDetail)) ...[
                          _buildPauseButton(sipDetail, theme),
                          const SizedBox(width: 6),
                          _buildCancelSipButton(sipDetail, theme),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowSipActions(dynamic sipDetail) {
    final status = (sipDetail.status ?? '').toUpperCase();
    return status == "ACTIVE" || status == "RUNNING";
  }

  DataCell _buildCellWithHover(dynamic sipDetail, String sipRegNo, ThemesProvider theme, DataCell cell, {Alignment alignment = Alignment.centerRight}) {
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowSipRegNo = sipRegNo),
        onExit: (_) => setState(() => _hoveredRowSipRegNo = null),
        child: SizedBox.expand(
          child: Align(
            alignment: alignment,
            child: cell.child,
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton(dynamic sipDetail, ThemesProvider theme) {
    return SizedBox(
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.08),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SipPauseDialogueWeb(sipData: sipDetail);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? WebDarkColors.tertiary
                  : WebColors.tertiary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                "Pause",
                style: WebTextStyles.custom(
                  fontSize: 11,
                  isDarkTheme: theme.isDarkMode,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelSipButton(dynamic sipDetail, ThemesProvider theme) {
    return SizedBox(
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.08),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SipCancelDialogueWeb(sipData: sipDetail);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? WebDarkColors.error
                  : WebColors.error,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                "Cancel SIP",
                style: WebTextStyles.custom(
                  fontSize: 11,
                  isDarkTheme: theme.isDarkMode,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
