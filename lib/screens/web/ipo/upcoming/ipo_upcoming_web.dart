// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_font_web.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart';

class UpcomingIpo extends ConsumerStatefulWidget {
  const UpcomingIpo({super.key});

  @override
  ConsumerState<UpcomingIpo> createState() => _UpcomingIpoState();
}

class _UpcomingIpoState extends ConsumerState<UpcomingIpo> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
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

    // Get filtered upcoming IPOs based on search
    List<dynamic> filteredUpcomingIPOs = _getFilteredUpcomingIPOs(ipos);
    final hasUpcomingIPOs = filteredUpcomingIPOs.isNotEmpty;

    if (!hasUpcomingIPOs && ipos.ipocommonsearchcontroller.text.isNotEmpty) {
      return const Center(
        child: NoDataFound(),
      );
    }

    if (!hasUpcomingIPOs) {
      return const Center(
        child: NoDataFound(),
      );
    }

    // Apply sorting
    final sortedUpcomingIPOs = _getSortedUpcomingIPOs(filteredUpcomingIPOs);

    return Builder(
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        const padding = 16.0 * 2; // Top and bottom padding
        const headerHeight = 100.0;
        const spacing = 16.0;
        final tableHeight = screenHeight - padding - headerHeight - spacing;
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight =
            tableHeight > maxHeight ? maxHeight : (tableHeight > 400 ? tableHeight : 400.0);

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
              color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbVisibility: WidgetStateProperty.all(true),
                  trackVisibility: WidgetStateProperty.all(true),
                  thickness: WidgetStateProperty.all(6.0),
                  crossAxisMargin: 0.0,
                  mainAxisMargin: 0.0,
                  radius: const Radius.circular(3),
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    return theme.isDarkMode
                        ? WebDarkColors.textSecondary.withOpacity(0.3)
                        : WebColors.textSecondary.withOpacity(0.3);
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    return theme.isDarkMode
                        ? WebDarkColors.divider.withOpacity(0.1)
                        : WebColors.divider.withOpacity(0.1);
                  }),
                  trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                  minThumbLength: 48.0,
                ),
              ),
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1000,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                fixedLeftColumns: 1,
                fixedColumnsColor: theme.isDarkMode
                    ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                    : WebColors.backgroundSecondary.withOpacity(0.8),
                showBottomBorder: true,
                horizontalScrollController: _horizontalScrollController,
                scrollController: _verticalScrollController,
                showCheckboxColumn: false,
                dataRowHeight: 56.0,
                headingRowColor: WidgetStateProperty.all(
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
                ),
                columns: _buildDataTable2Columns(theme),
                rows: _buildDataTable2Rows(sortedUpcomingIPOs, theme),
              ),
            ),
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
        case 1: // Type
          final typeA = a.ipoType ?? '';
          final typeB = b.ipoType ?? '';
          comparison = typeA.compareTo(typeB);
          break;
        case 2: // Issue Size
          final sizeA = a.issueSize ?? '';
          final sizeB = b.issueSize ?? '';
          comparison = sizeA.compareTo(sizeB);
          break;
        case 3: // Last Updated
          final updatedA = a.lastUpdated ?? '';
          final updatedB = b.lastUpdated ?? '';
          comparison = updatedA.compareTo(updatedB);
          break;
        case 4: // Stock Exchanges
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

  Widget _buildSortIcon(int columnIndex, ThemesProvider theme) {
    if (_sortColumnIndex == columnIndex) {
      return const SizedBox(width: 16);
    } else {
      return Icon(
        Icons.unfold_more,
        size: 16,
        color: theme.isDarkMode
            ? WebDarkColors.textSecondary.withOpacity(0.6)
            : WebColors.textSecondary.withOpacity(0.6),
      );
    }
  }

  List<DataColumn2> _buildDataTable2Columns(ThemesProvider theme) {
    return [
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock name',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(0, theme),
          ],
        ),
        size: ColumnSize.L,
        fixedWidth: 300.0,
        onSort: (index, ascending) => _onSortTable(0, ascending),
      ),
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Type',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(1, theme),
          ],
        ),
        size: ColumnSize.S,
        onSort: (index, ascending) => _onSortTable(1, ascending),
      ),
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Issue Size',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(2, theme),
          ],
        ),
        size: ColumnSize.M,
        onSort: (index, ascending) => _onSortTable(2, ascending),
      ),
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Last Updated',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(3, theme),
          ],
        ),
        size: ColumnSize.M,
        onSort: (index, ascending) => _onSortTable(3, ascending),
      ),
      DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock Exchanges',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildSortIcon(4, theme),
          ],
        ),
        size: ColumnSize.S,
        onSort: (index, ascending) => _onSortTable(4, ascending),
      ),
      DataColumn2(
        label: Text(
          'DRHP',
          style: WebTextStyles.tableHeader(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        size: ColumnSize.S,
      ),
    ];
  }

  List<DataRow2> _buildDataTable2Rows(
      List<dynamic> upcomingIPOs, ThemesProvider theme) {
    return upcomingIPOs.map((ipo) {
      return DataRow2(
        cells: [
          // Stock name (fixed column)
          DataCell(
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                ipo.companyName ?? '',
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
          // Type (left aligned)
          DataCell(
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                ipo.ipoType ?? '',
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.regular,
                ),
              ),
            ),
          ),
          // Issue Size
          DataCell(
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                ipo.issueSize ?? '',
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.regular,
                ),
              ),
            ),
          ),
          // Last Updated
          DataCell(
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                ipo.lastUpdated ?? '',
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.regular,
                ),
              ),
            ),
          ),
          // Stock Exchanges
          DataCell(
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                ipo.stockExchanges ?? '',
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.regular,
                ),
              ),
            ),
          ),
          // DRHP
          DataCell(
            Container(
              alignment: Alignment.center,
              child: _buildDRHPButton(ipo, theme),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildDRHPButton(dynamic ipo, ThemesProvider theme) {
    final String? drhpUrl = ipo.drhp;
    final bool hasDRHP = drhpUrl != null && drhpUrl.isNotEmpty && drhpUrl != 'null';

    if (!hasDRHP) {
      return Text(
        '-',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textSecondary
              : WebColors.textSecondary,
          fontWeight: WebFonts.regular,
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onDRHPTap(drhpUrl),
          customBorder: const RoundedRectangleBorder(),
          splashColor: theme.isDarkMode
              ? colors.splashColorDark
              : colors.splashColorLight,
          highlightColor: theme.isDarkMode
              ? colors.highlightDark
              : colors.highlightLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'DRHP',
              style: WebTextStyles.custom(
                fontSize: 13,
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.primaryDark
                    : colors.primaryLight,
                fontWeight: WebFonts.semiBold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onDRHPTap(String url) async {
    try {
      // Ensure URL has a protocol
      String finalUrl = url.trim();
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'https://$finalUrl';
      }

      final Uri uri = Uri.parse(finalUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint("Could not launch $finalUrl");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open DRHP link: $finalUrl'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching DRHP URL: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening DRHP link: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
