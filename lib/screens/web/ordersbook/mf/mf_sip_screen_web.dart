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
    final orderBook = ref.watch(orderProvider);
    
    // Use filtered results from provider (same pattern as other tabs)
    final isSearching = orderBook.orderSearchCtrl.text.isNotEmpty;
    final sipDetails = isSearching
        ? (mf.mfSipSearch ?? [])
        : (mf.mfsiporderlist?.data ?? []);

    if (sipDetails.isEmpty) {
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
        final responsiveConfig = _getResponsiveSipColumns(screenWidth);
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
                sortColumnIndex: _sipSortColumnIndex,
                sortAscending: _sipSortAscending,
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
                columns: _buildSipDataTable2Columns(headers, columnMinWidth, theme),
                rows: _buildSipDataTable2Rows(sipDetails, headers, theme),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to get responsive column configuration for SIP
  // Always show all columns - horizontal scroll handles overflow on small screens
  Map<String, dynamic> _getResponsiveSipColumns(double screenWidth) {
    return {
      'headers': ['Scheme', 'SIP Reg No', 'Amount', 'Frequency', 'Next Installment', 'Status'],
      'columnMinWidth': {
        'Scheme': 300,
        'SIP Reg No': 150,
        'Amount': 120,
        'Frequency': 130,
        'Next Installment': 220,
        'Status': 110,
      },
    };
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

  List<DataColumn2> _buildSipDataTable2Columns(
    List<String> headers,
    Map<String, double> columnMinWidth,
    ThemesProvider theme,
  ) {
    return headers.map((header) {
      final columnIndex = _getSipColumnIndexForHeader(header);
      final isScheme = header == 'Scheme';
      final isNextInstallment = header == 'Next Installment';
      
      return DataColumn2(
        label: Row(
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
            ),
            const SizedBox(width: 4),
            _buildSipSortIcon(columnIndex, theme),
          ],
        ),
        size: isScheme ? ColumnSize.L : ColumnSize.S,
        fixedWidth: isScheme ? 300.0 : (isNextInstallment ? 220.0 : null),
        onSort: (index, ascending) => _onSortSipTable(columnIndex, ascending),
      );
    }).toList();
  }

  List<DataRow2> _buildSipDataTable2Rows(
    List<dynamic> sipDetails,
    List<String> headers,
    ThemesProvider theme,
  ) {
    final sorted = _sortedSipDetails(sipDetails);
    return sorted.map((sipDetail) {
      final sipRegNo = sipDetail.sIPRegnNo ?? 
          '${sipDetail.name ?? ''}_${sorted.indexOf(sipDetail)}';
      final isHovered = _hoveredRowSipRegNo == sipRegNo;

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
          return _buildSipDataTable2Cell(
            header,
            sipDetail,
            theme,
            isHovered,
            sipRegNo,
          );
        }).toList(),
        onTap: () => _openSipDetail(sipDetail),
      );
    }).toList();
  }

  DataCell _buildSipDataTable2Cell(
    String column,
    dynamic sipDetail,
    ThemesProvider theme,
    bool isHovered,
    String sipRegNo,
  ) {
    Widget cellContent;
    
    switch (column) {
      case 'Scheme':
        cellContent = _buildSipSchemeCellContent(
          sipDetail,
          theme,
          isHovered,
          sipRegNo,
        );
        break;
      case 'SIP Reg No':
        final reg = sipDetail.sIPRegnNo ?? '';
        cellContent = _buildSipTextCell(
          reg,
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Amount':
        final amount = sipDetail.installmentAmount?.toString() ?? '0';
        final amountText = double.tryParse(amount)?.toStringAsFixed(2) ?? amount;
        cellContent = _buildSipTextCell(
          amountText,
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Frequency':
        final freq = sipDetail.frequencyType ?? '';
        cellContent = _buildSipTextCell(
          freq,
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Next Installment':
        final nextInst = sipDetail.NextSIPDate ?? '';
        cellContent = _buildSipTextCell(
          nextInst,
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Status':
        final status = (sipDetail.status ?? '').toUpperCase();
        final statusColor = _statusColor(status, theme);
        cellContent = _buildSipTextCell(
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
        onEnter: (_) => setState(() => _hoveredRowSipRegNo = sipRegNo),
        onExit: (_) => setState(() => _hoveredRowSipRegNo = null),
        child: SizedBox.expand(
          child: cellContent,
        ),
      ),
    );
  }

  Widget _buildSipSchemeCellContent(
    dynamic sipDetail,
    ThemesProvider theme,
    bool isHovered,
    String sipRegNo,
  ) {
    final scheme = sipDetail.name ?? 'N/A';

    return Row(
      children: [
        Expanded(
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
        // Action buttons fade in on hover
        IgnorePointer(
          ignoring: !isHovered,
          child: AnimatedOpacity(
            opacity: isHovered ? 1 : 0,
            duration: const Duration(milliseconds: 140),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_shouldShowSipActions(sipDetail)) ...[
                  _buildPauseButton(sipDetail, theme),
                  const SizedBox(width: 6),
                ],
                _buildCancelSipButton(sipDetail, theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSipSortIcon(int columnIndex, ThemesProvider theme) {
    if (_sipSortColumnIndex == columnIndex) {
      return const SizedBox(width: 16); // Reserve space for DataTable2's arrow
    } else {
      return Icon(
        Icons.unfold_more,
        size: 16,
        color: theme.isDarkMode
            ? WebDarkColors.iconSecondary
            : WebColors.iconSecondary,
      );
    }
  }


  Widget _buildSipTextCell(
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


  void _onSortSipTable(int columnIndex, bool ascending) {
    setState(() {
      _sipSortColumnIndex = columnIndex;
      _sipSortAscending = ascending;
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

  bool _shouldShowSipActions(dynamic sipDetail) {
    final status = (sipDetail.status ?? '').toUpperCase();
    return status == "ACTIVE" || status == "RUNNING";
  }

  Widget _buildPauseButton(dynamic sipDetail, ThemesProvider theme) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          backgroundColor: theme.isDarkMode
              ? WebDarkColors.tertiary
              : WebColors.tertiary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SipPauseDialogueWeb(sipData: sipDetail);
            },
          );
        },
        child: Text(
          'Pause',
          style: WebTextStyles.custom(
            fontSize: 12,
            isDarkTheme: theme.isDarkMode,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelSipButton(dynamic sipDetail, ThemesProvider theme) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          backgroundColor: theme.isDarkMode
              ? WebDarkColors.error
              : WebColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SipCancelDialogueWeb(sipData: sipDetail);
            },
          );
        },
        child: Text(
          'Cancel SIP',
          style: WebTextStyles.custom(
            fontSize: 12,
            isDarkTheme: theme.isDarkMode,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

