import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../../models/mf_model/mutual_fundmodel.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../sharedWidget/no_data_found_web.dart';

class MFComparisonTableWeb extends ConsumerStatefulWidget {
  final MutualFundList mfStockData;
  const MFComparisonTableWeb({super.key, required this.mfStockData});

  @override
  ConsumerState<MFComparisonTableWeb> createState() => _MFComparisonTableWebState();
}

class _MFComparisonTableWebState extends ConsumerState<MFComparisonTableWeb> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedYearIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSchemePeers();
    });
  }

  void _fetchSchemePeers() {
    if (!mounted) return;
    final isin = widget.mfStockData.iSIN;
    if (isin != null) {
      final mfProvide = ref.read(mfProvider);
      final comYears = mfProvide.comYears;
      if (comYears.isNotEmpty && _selectedYearIndex < comYears.length) {
        final yearValue = comYears[_selectedYearIndex]["year"] ?? "10Year";
        mfProvide.fetchSchemePeer(isin, yearValue);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final theme = ref.watch(themeProvider);
      final mfProvide = ref.watch(mfProvider);
      final factSheetData = mfProvide.factSheetDataModel?.data;
      final schemePeers = mfProvide.schemePeers;

      if (factSheetData == null) {
        return const SizedBox();
      }

      final isDarkMode = theme.isDarkMode;
      final fundName = factSheetData.name ?? widget.mfStockData.schemeName ?? 'Fund';
      final category = factSheetData.category ?? widget.mfStockData.type ?? 'Flexi Cap';

      final topSchemes = schemePeers?.topSchemes ?? [];

      final filteredSchemes = _searchQuery.isEmpty
          ? topSchemes
          : topSchemes
              .where((item) => (item.name ?? '')
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
              .toList();

      return Container(
      // color: isDarkMode ? Colors.black : Colors.white,
      color: isDarkMode ? MyntColors.backgroundColorDark : MyntColors.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Comparison with Equity: $category",
                          style: MyntWebTextStyles.title(
                            context,
                            color: isDarkMode
                                ? MyntColors.textPrimaryDark
                                : MyntColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Comparison breakdown of ${_truncateFundName(fundName)} Information",
                          style: MyntWebTextStyles.bodySmall(
                            context,
                            color: isDarkMode
                                ? MyntColors.textSecondaryDark
                                : MyntColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dropdown and Search
                  Row(
                    children: [
                      _buildDropdown(context, isDarkMode, mfProvide),
                      const SizedBox(width: 12),
                      _buildSearchField(context, isDarkMode),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Table Header
              _buildTableHeader(context, isDarkMode, mfProvide),

              Divider(
                color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                height: 1,
              ),

              // Table Rows
              if (filteredSchemes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: schemePeers == null
                        ? Text(
                            "Loading...",
                            style: MyntWebTextStyles.body(
                              context,
                              color: isDarkMode
                                  ? MyntColors.textSecondaryDark
                                  : MyntColors.textSecondary,
                            ),
                          )
                        : const NoDataFound(
                          secondaryEnabled: false,
                        ),
                  ),
                )
              else
                ...filteredSchemes.map((item) => _buildTableRow(context, isDarkMode, item)),
            ],
          ),
        ),
      ),
    );
    } catch (e) {
      return const SizedBox();
    }
  }

  Widget _buildDropdown(BuildContext context, bool isDarkMode, MFProvider mfProvide) {
    final comYears = mfProvide.comYears;
    if (comYears.isEmpty) {
      return const SizedBox();
    }

    // Ensure selected index is within bounds
    if (_selectedYearIndex >= comYears.length) {
      _selectedYearIndex = 0;
    }

    final selectedYearName = comYears[_selectedYearIndex]["yearName"] ?? "10 Years";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<int>(
        initialValue: _selectedYearIndex,
        onSelected: (int index) async {
          if (!mounted) return;
          setState(() {
            _selectedYearIndex = index;
          });

          final isin = widget.mfStockData.iSIN;
          if (isin != null && index < comYears.length) {
            final yearValue = comYears[index]["year"] ?? "10Year";
            final yearName = comYears[index]["yearName"] ?? "10 Years";
            await mfProvide.chngComYear(yearValue, yearName, isin);
          }
        },
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        itemBuilder: (BuildContext context) {
          return List.generate(comYears.length, (index) {
            final yearName = comYears[index]["yearName"] ?? "";
            return PopupMenuItem<int>(
              value: index,
              child: Text(
                yearName,
                style: MyntWebTextStyles.body(
                  context,
                  color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                ),
              ),
            );
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedYearName,
              style: MyntWebTextStyles.body(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, bool isDarkMode) {
    return Container(
      width: 200,
      height: 40,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          if (!mounted) return;
          setState(() {
            _searchQuery = value;
          });
        },
        style: MyntWebTextStyles.body(
          context,
          color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: MyntWebTextStyles.body(
            context,
            color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, bool isDarkMode, MFProvider mfProvide) {
    final comYears = mfProvide.comYears;
    String yearLabel = "10 Year";
    if (comYears.isNotEmpty && _selectedYearIndex < comYears.length) {
      yearLabel = (comYears[_selectedYearIndex]["yearName"] ?? "10 Years")
          .replaceAll(' Years', ' Year')
          .replaceAll('Years', 'Yr');
    }

    final headerColor = isDarkMode
        ? MyntColors.textSecondaryDark
        : MyntColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: isDarkMode ? MyntColors.cardDark : MyntColors.listItemBg,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Scheme',
              style: MyntWebTextStyles.bodySmall(
                context,
                color: headerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'AUM (Cr)',
              textAlign: TextAlign.right,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: headerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$yearLabel %',
              textAlign: TextAlign.right,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: headerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rating',
              textAlign: TextAlign.right,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: headerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, bool isDarkMode, dynamic item) {
    final double aum = double.tryParse(item.aum ?? "0") ?? 0.0;
    final double yearPer = double.tryParse(item.yearPer ?? "0") ?? 0.0;
    final int rating = int.tryParse(item.fundRat ?? "0") ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              item.name ?? "",
              style: MyntWebTextStyles.body(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              aum.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: MyntWebTextStyles.body(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              yearPer.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: MyntWebTextStyles.body(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildStarRating(rating),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarRating(int rating) {
    return List.generate(5, (index) {
      return Icon(
        Icons.star,
        size: 18,
        color: index < rating ? const Color(0xFFFFB800) : const Color(0xFFE0E0E0),
      );
    });
  }

  String _truncateFundName(String name) {
    if (name.length > 30) {
      return '${name.substring(0, 27)}...';
    }
    return name;
  }
}
