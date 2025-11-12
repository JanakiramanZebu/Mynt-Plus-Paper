import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../res/global_state_text.dart';
import 'mf_sip_detail_screen_web.dart';
import 'sip_pause_dialogue_web.dart';
import 'sip_cancel_dialogue_web.dart';
import '../../../../models/mf_model/sip_mf_list_model.dart';

class MFSipdetScreenWeb extends ConsumerStatefulWidget {
  const MFSipdetScreenWeb({super.key});

  @override
  ConsumerState<MFSipdetScreenWeb> createState() => _MFSipdetScreenWebState();
}

class _MFSipdetScreenWebState extends ConsumerState<MFSipdetScreenWeb> {
  int? _sipSortColumnIndex;
  bool _sipSortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  String? _hoveredRowSipRegNo; // Track which row is being hovered

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
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          label: _buildSortableColumnHeader('SIP Reg No', theme, 1),
                          onSort: (columnIndex, ascending) =>
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          label: _buildSortableColumnHeader('Amount', theme, 2),
                          onSort: (columnIndex, ascending) =>
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          label: _buildSortableColumnHeader('Frequency', theme, 3),
                          onSort: (columnIndex, ascending) =>
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
                          label: _buildSortableColumnHeader('Next Installment', theme, 4),
                          onSort: (columnIndex, ascending) =>
                              _onSortSipTable(columnIndex, ascending),
                        ),
                        DataColumn(
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
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                  fontWeight: WebFonts.medium,
                                ),
                              ),
                            )),
                            // Amount
                            _buildCellWithHover(s, sipRegNo, theme, DataCell(
                              Text(
                                double.tryParse(amount)?.toStringAsFixed(2) ?? amount,
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                  fontWeight: WebFonts.medium,
                                ),
                              ),
                            )),
                            // Frequency
                            _buildCellWithHover(s, sipRegNo, theme, DataCell(
                              Text(
                                freq,
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                  fontWeight: WebFonts.medium,
                                ),
                              ),
                            )),
                            // Next Installment
                            _buildCellWithHover(s, sipRegNo, theme, DataCell(
                              Text(
                                nextInst,
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                  fontWeight: WebFonts.medium,
                                ),
                              ),
                            )),
                            // Status
                            _buildCellWithHover(s, sipRegNo, theme, DataCell(
                              InkWell(
                                onTap: () => _openSipDetail(s),
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
                            )),
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
                Flexible(
                  child: Tooltip(
                    message: scheme,
                    child: AnimatedOpacity(
                      opacity: isHovered ? 0.7 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Text(
                        scheme,
                        style: WebTextStyles.custom(
                          fontSize: 13,
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.medium,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                // Buttons that appear on hover - Only show when status is ACTIVE
                if (_shouldShowSipActions(sipDetail))
                  AnimatedOpacity(
                    opacity: isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 120),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 6),
                        _buildPauseButton(sipDetail, theme),
                        const SizedBox(width: 6),
                        _buildCancelSipButton(sipDetail, theme),
                      ],
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

  DataCell _buildCellWithHover(dynamic sipDetail, String sipRegNo, ThemesProvider theme, DataCell cell) {
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowSipRegNo = sipRegNo),
        onExit: (_) => setState(() => _hoveredRowSipRegNo = null),
        child: SizedBox.expand(
          child: Align(
            alignment: Alignment.centerRight,
            child: cell.child,
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton(dynamic sipDetail, ThemesProvider theme) {
    return SizedBox(
      height: 28,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.isDarkMode 
                ? colors.textSecondaryDark.withOpacity(0.6) 
                : colors.primaryLight,
            width: 1,
          ),
          color: theme.isDarkMode 
              ? colors.textSecondaryDark.withOpacity(0.6) 
              : colors.btnBg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            splashColor: theme.isDarkMode 
                ? colors.splashColorDark 
                : colors.splashColorLight,
            highlightColor: theme.isDarkMode 
                ? colors.highlightDark 
                : colors.highlightLight,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SipPauseDialogueWeb(sipData: sipDetail);
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  "Pause",
                  style: TextWidget.textStyle(
                    fontSize: 11,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode 
                        ? colors.colorWhite 
                        : colors.primaryLight,
                    fw: 2,
                  ),
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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.isDarkMode 
                ? colors.textSecondaryDark.withOpacity(0.6) 
                : colors.primaryLight,
            width: 1,
          ),
          color: theme.isDarkMode 
              ? colors.textSecondaryDark.withOpacity(0.6) 
              : colors.btnBg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            splashColor: theme.isDarkMode 
                ? colors.splashColorDark 
                : colors.splashColorLight,
            highlightColor: theme.isDarkMode 
                ? colors.highlightDark 
                : colors.highlightLight,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SipCancelDialogueWeb(sipData: sipDetail);
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  "Cancel SIP",
                  style: TextWidget.textStyle(
                    fontSize: 11,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode 
                        ? colors.colorWhite 
                        : colors.primaryLight,
                    fw: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
