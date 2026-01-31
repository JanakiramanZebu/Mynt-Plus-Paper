// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/sharedWidget/no_data_found_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../sharedWidget/no_data_found.dart';

class UpcomingIpo extends ConsumerStatefulWidget {
  const UpcomingIpo({super.key});

  @override
  ConsumerState<UpcomingIpo> createState() => _UpcomingIpoState();
}

class _UpcomingIpoState extends ConsumerState<UpcomingIpo> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String? _hoveredRowId;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ipos = ref.watch(ipoProvide);
    final theme = ref.watch(themeProvider);

    // Show loader while data is being fetched
    if (ipos.loading) {
      return const Center(
        child: MyntLoader(size: MyntLoaderSize.large),
      );
    }

    // Get filtered upcoming IPOs based on search
    List<dynamic> filteredUpcomingIPOs = _getFilteredUpcomingIPOs(ipos);

    // Apply sorting
    final sortedUpcomingIPOs = _getSortedUpcomingIPOs(filteredUpcomingIPOs);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Allocation: All columns 25%
        final nameWidth = width * 0.25;
        final sizeWidth = width * 0.25;
        final updatedWidth = width * 0.25;
        final excWidth = width * 0.25;

        final columnWidths = {
          0: shadcn.FixedTableSize(nameWidth),
          1: shadcn.FixedTableSize(sizeWidth),
          2: shadcn.FixedTableSize(updatedWidth),
          3: shadcn.FixedTableSize(excWidth),
        };

        return shadcn.OutlinedContainer(
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: shadcn.Table(
                  columnWidths: columnWidths,
                  defaultRowHeight: const shadcn.FixedTableSize(50),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        _buildHeaderCell("Stock name", 0, theme),
                        _buildHeaderCell("Issue Size", 1, theme),
                        _buildHeaderCell("Last Updated", 2, theme),
                        _buildHeaderCell("Stock Exchanges", 3, theme),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredUpcomingIPOs.isEmpty
                    ? const Center(child: NoDataFoundWeb())
                    : SingleChildScrollView(
                        child: shadcn.Table(
                          columnWidths: columnWidths,
                          defaultRowHeight: const shadcn.FixedTableSize(50),
                          rows: sortedUpcomingIPOs.asMap().entries.map((entry) {
                            return _buildShadcnRow(entry.value, entry.key, theme);
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<dynamic> _getFilteredUpcomingIPOs(IPOProvider ipos) {
    final upcomingIPOs = ipos.upcomingModel?.upcoming ?? [];

    // If there's a search query, filter the upcoming IPOs
    if (ipos.ipocommonsearchcontroller.text.isNotEmpty) {
      final searchQuery = ipos.ipocommonsearchcontroller.text.toLowerCase();
      return upcomingIPOs.where((ipo) {
        final companyName = ipo.companyName?.toLowerCase() ?? '';
        final ipoType = ipo.ipoType?.toLowerCase() ?? '';
        return companyName.contains(searchQuery) ||
            ipoType.contains(searchQuery);
      }).toList();
    }

    // Otherwise, return all upcoming IPOs
    return upcomingIPOs;
  }

  List<dynamic> _getSortedUpcomingIPOs(List<dynamic> upcomingIPOs) {
    if (_sortColumnIndex == null) {
      return upcomingIPOs;
    }

    final sorted = List<dynamic>.from(upcomingIPOs);
    sorted.sort((a, b) {
      int comparison = 0;
      switch (_sortColumnIndex) {
        case 0: // Company Name
          final nameA = a.companyName ?? '';
          final nameB = b.companyName ?? '';
          comparison = nameA.compareTo(nameB);
          break;
        case 1: // Issue Size
          final sizeA = a.issueSize ?? '';
          final sizeB = b.issueSize ?? '';
          comparison = sizeA.compareTo(sizeB);
          break;
        case 2: // Last Updated
          final updatedA = a.lastUpdated ?? '';
          final updatedB = b.lastUpdated ?? '';
          comparison = updatedA.compareTo(updatedB);
          break;
        case 3: // Stock Exchanges
          final exchangeA = a.stockExchanges ?? '';
          final exchangeB = b.stockExchanges ?? '';
          comparison = exchangeA.compareTo(exchangeB);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return sorted;
  }

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      }
    });
  }

  // Header text style
  // 14px, weight 600, MyntColors for text
  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
      darkColor: color ?? MyntColors.textSecondaryDark,
      lightColor: color ?? MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  shadcn.TableCell _buildHeaderCell(
      String text, int sortIndex, ThemesProvider theme,
      {bool alignRight = false, bool centered = false}) {
    Alignment alignment;
    if (centered) {
      alignment = Alignment.center;
    } else {
      alignment = alignRight ? Alignment.centerRight : Alignment.centerLeft;
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
      child: GestureDetector(
        onTap: sortIndex >= 0
            ? () => _onSortTable(sortIndex, !_sortAscending)
            : null,
        child: Container(
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          // decoration: BoxDecoration(
          //   color: theme.isDarkMode
          //       ? Colors.white.withOpacity(0.04)
          //       : Colors.black.withOpacity(0.03),
          // ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: _getHeaderStyle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  shadcn.TableRow _buildShadcnRow(
      dynamic ipo, int index, ThemesProvider theme) {
    final uniqueId = '${ipo.companyName ?? ""}$index';
    final rowIsHovered = _hoveredRowId == uniqueId;

    final cellTextStyle = MyntWebTextStyles.tableCell(
      context,
      fontWeight: MyntFonts.medium,
      color: resolveThemeColor(context,
          dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
    );

    return shadcn.TableRow(
      cells: [
        // Name
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: rowIsHovered,
          theme: theme,
          child: Text(
            ipo.companyName ?? '',
            style: cellTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Issue Size
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: rowIsHovered,
          theme: theme,
          child: Text(
            ipo.issueSize ?? '',
            style: cellTextStyle,
          ),
        ),
        // Last Updated
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: rowIsHovered,
          theme: theme,
          child: Text(
            ipo.lastUpdated ?? '',
            style: cellTextStyle,
          ),
        ),
        // Stock Exchanges
        _buildShadcnCell(
          uniqueId: uniqueId,
          rowIsHovered: rowIsHovered,
          theme: theme,
          child: Text(
            ipo.stockExchanges ?? '',
            style: cellTextStyle,
          ),
        ),
      ],
    );
  }

  shadcn.TableCell _buildShadcnCell({
    required Widget child,
    required String uniqueId,
    required bool rowIsHovered,
    required ThemesProvider theme,
    VoidCallback? onTap,
    bool alignRight = false,
    bool centered = false,
  }) {
    Alignment alignment;
    if (centered) {
      alignment = Alignment.center;
    } else {
      alignment = alignRight ? Alignment.centerRight : Alignment.centerLeft;
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
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredRowId = uniqueId),
        onExit: (_) => setState(() => _hoveredRowId = null),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.transparent,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            width: double.infinity,
            height: double.infinity,
            child: Align(
              alignment: alignment,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
