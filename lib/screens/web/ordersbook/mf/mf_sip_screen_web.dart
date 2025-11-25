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
  
  // Responsive breakpoints
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

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
        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveSipColumns(screenWidth);
        final headers = List<String>.from(responsiveConfig['headers'] as List);
        final columnFlex = Map<String, int>.from(responsiveConfig['columnFlex'] as Map);
        final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
        
        // Calculate total minimum width
        final totalMinWidth =
            columnMinWidth.values.fold<double>(0.0, (a, b) => a + b);
        // Determine whether horizontal scroll is needed
        final needHorizontalScroll = constraints.maxWidth < totalMinWidth;

        // Build the Column (header + body)
        final tableColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Sticky header (fixed) ---
            Container(
              height: 48,
              decoration: BoxDecoration(
                color:
                    theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
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
                          final columnIndex = _getSipColumnIndexForHeader(label);

                          return _buildSipColumnCell(
                            needHorizontalScroll: needHorizontalScroll,
                            flex: flex,
                            minW: minW,
                            child: _buildSipHeaderWidget(
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
                        final columnIndex = _getSipColumnIndexForHeader(label);

                        return _buildSipColumnCell(
                          needHorizontalScroll: needHorizontalScroll,
                          flex: flex,
                          minW: minW,
                          child: _buildSipHeaderWidget(
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
                child: _buildSipBodyList(
                  theme,
                  sipDetails,
                  headers,
                  columnFlex,
                  columnMinWidth,
                  totalMinWidth: totalMinWidth,
                  needHorizontalScroll: needHorizontalScroll,
                ),
              ),
            ),
          ],
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

  // Helper method to get responsive column configuration for SIP
  Map<String, dynamic> _getResponsiveSipColumns(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) {
      // Mobile: Show only essential columns
      return {
        'headers': ['Scheme', 'Amount', 'Frequency', 'Status'],
        'columnFlex': {
          'Scheme': 3,
          'Amount': 2,
          'Frequency': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Scheme': 150,
          'Amount': 100,
          'Frequency': 110,
          'Status': 90,
        },
      };
    } else if (screenWidth < _tabletBreakpoint) {
      // Tablet: Show most columns
      return {
        'headers': ['Scheme', 'SIP Reg No', 'Amount', 'Frequency', 'Status'],
        'columnFlex': {
          'Scheme': 3,
          'SIP Reg No': 2,
          'Amount': 2,
          'Frequency': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Scheme': 160,
          'SIP Reg No': 120,
          'Amount': 105,
          'Frequency': 115,
          'Status': 100,
        },
      };
    } else {
      // Desktop: Full columns with optimal widths
      return {
        'headers': ['Scheme', 'SIP Reg No', 'Amount', 'Frequency', 'Next Installment', 'Status'],
        'columnFlex': {
          'Scheme': 3,
          'SIP Reg No': 2,
          'Amount': 2,
          'Frequency': 2,
          'Next Installment': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Scheme': 180,
          'SIP Reg No': 130,
          'Amount': 110,
          'Frequency': 120,
          'Next Installment': 140,
          'Status': 110,
        },
      };
    }
  }

  int _getSipColumnIndexForHeader(String header) {
    switch (header) {
      case 'Scheme': return 0;
      case 'SIP Reg No': return 1;
      case 'Amount': return 2;
      case 'Frequency': return 3;
      case 'Next Installment': return 4;
      case 'Status': return 5;
      default: return -1;
    }
  }

  Widget _buildSipHeaderWidget(
    String label,
    int columnIndex,
    ThemesProvider theme,
  ) {
    final isNumeric = columnIndex == 1 || columnIndex == 2; // SIP Reg No (1) or Amount (2)
    
    return InkWell(
      onTap: () => _onSortSipTable(columnIndex, !_sipSortAscending),
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
          if (_sipSortColumnIndex == columnIndex)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Icon(
                _sipSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
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

  Widget _buildSipColumnCell({
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

  Widget _buildSipBodyList(
    ThemesProvider theme,
    List<dynamic> sipDetails,
    List<String> headers,
    Map<String, int> columnFlex,
    Map<String, double> columnMinWidth, {
    required double totalMinWidth,
    required bool needHorizontalScroll,
  }) {
    final sorted = _sortedSipDetails(sipDetails);
    return ListView.builder(
      controller: _verticalScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final s = sorted[index];
        final sipRegNo = s.sIPRegnNo ?? '${s.name ?? ''}$index';
        final isHovered = _hoveredRowSipRegNo == sipRegNo;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRowSipRegNo = sipRegNo),
          onExit: (_) => setState(() => _hoveredRowSipRegNo = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openSipDetail(s),
            child: Container(
              decoration: BoxDecoration(
                color: isHovered
                    ? (theme.isDarkMode
                        ? WebDarkColors.primary.withOpacity(0.12)
                        : WebColors.primary.withOpacity(0.08))
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: needHorizontalScroll
                  ? IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: headers.map((label) {
                          final flex = columnFlex[label] ?? 1;
                          final minW = columnMinWidth[label] ?? 80.0;
                          return _buildSipColumnCell(
                            needHorizontalScroll: needHorizontalScroll,
                            flex: flex,
                            minW: minW,
                            child: _buildSipCellWidget(
                              label,
                              s,
                              theme,
                              isHovered,
                              sipRegNo,
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
                        return _buildSipColumnCell(
                          needHorizontalScroll: needHorizontalScroll,
                          flex: flex,
                          minW: minW,
                          child: _buildSipCellWidget(
                            label,
                            s,
                            theme,
                            isHovered,
                            sipRegNo,
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

  Widget _buildSipCellWidget(
    String column,
    dynamic s,
    ThemesProvider theme,
    bool isHovered,
    String sipRegNo, {
    required bool needHorizontalScroll,
  }) {
    switch (column) {
      case 'Scheme':
        return _buildSipSchemeWidget(
          s,
          theme,
          isHovered,
          sipRegNo,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'SIP Reg No':
        final reg = s.sIPRegnNo ?? '';
        return _buildSipTextCell(
          reg,
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Amount':
        final amount = s.installmentAmount?.toString() ?? '0';
        return _buildSipTextCell(
          double.tryParse(amount)?.toStringAsFixed(2) ?? amount,
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Frequency':
        final freq = s.frequencyType ?? '';
        return _buildSipTextCell(
          freq,
          theme,
          Alignment.centerLeft,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Next Installment':
        final nextInst = s.NextSIPDate ?? '';
        return _buildSipTextCell(
          nextInst,
          theme,
          Alignment.centerLeft,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Status':
        final status = (s.status ?? '').toUpperCase();
        final statusColor = _statusColor(status, theme);
        return _buildSipTextCell(
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

  Widget _buildSipSchemeWidget(
    dynamic s,
    ThemesProvider theme,
    bool isHovered,
    String sipRegNo, {
    required bool needHorizontalScroll,
  }) {
    final scheme = s.name ?? '';

    return ClipRect(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: isHovered ? 1 : 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: scheme,
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
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Buttons that appear on hover - always reserve space
          SizedBox(
            width: _shouldShowSipActions(s) ? 140 : 80, // Reserve space for buttons
            child: IgnorePointer(
              ignoring: !isHovered,
              child: AnimatedOpacity(
                opacity: isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 140),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_shouldShowSipActions(s)) ...[
                      // Show Pause button only for active/running SIPs
                      _buildPauseButton(s, theme),
                      const SizedBox(width: 6),
                    ],
                    // Show Cancel button for all SIPs
                    _buildCancelSipButton(s, theme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSipTextCell(
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
