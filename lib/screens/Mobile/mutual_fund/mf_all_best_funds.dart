// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart' hide Table, TableRow, TableCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:flutter_svg/svg.dart';

import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';

// import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';

import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../utils/responsive_snackbar.dart';
import '../../../sharedWidget/mynt_loader.dart';

import '../../../sharedWidget/no_data_found.dart';
import 'mf_order_screen.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../sharedWidget/common_search_fields_web.dart';


class SaveTaxesScreen extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final String icon;
  final VoidCallback? onBack;
  final Function(MutualFundList)? onFundTap;

  const SaveTaxesScreen({
    super.key,
    required this.title,
    this.subtitle = "Explore our curated collections",
    this.icon = "",
    this.onBack,
    this.onFundTap,
  });

  @override
  ConsumerState<SaveTaxesScreen> createState() => _SaveTaxesScreenState();
}

class _SaveTaxesScreenState extends ConsumerState<SaveTaxesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollController _horizontalScrollController; // Added for Table
  int selectedTab = 0;
  // String selectedReturn = '3Y Returns'; // Removed as we show all columns

  // Sorting state
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();


  // Define the tabs
  final List<String> tabTitles = [
    'Tax Saving',
    'High Growth Equity',
    'Stable Debt',
    'Sectoral Thematic',
    'International  Exposure',
    'Balanced Hybrid',
  ];

  @override
  void initState() {
    super.initState();

    // Find the initial tab index based on the title passed as argument
    int initialIndex = 0;
    for (int i = 0; i < tabTitles.length; i++) {
      if (tabTitles[i] == widget.title) {
        initialIndex = i;
        break;
      }
    }

    _tabController = TabController(
        length: tabTitles.length, vsync: this, initialIndex: initialIndex);
    _scrollController = ScrollController();
    _horizontalScrollController = ScrollController();

    selectedTab = initialIndex;

    _tabController.animation!.addListener(() {
      final newIndex = _tabController.animation!.value.round();
      if (selectedTab != newIndex) {
        setState(() {
          selectedTab = newIndex;
        });
        // Scroll to center the active tab
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToActiveTab(newIndex);
        });
      }
    });

    // Scroll to center the initial tab after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveTab(selectedTab);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _hoveredRowIndex.dispose();

    super.dispose();
  }

  void _scrollToActiveTab(int index) {
    if (_scrollController.hasClients) {
      // Calculate cumulative width up to the current tab
      final double totalWidthUpToIndex = _calculateTotalWidthUpToIndex(index);
      final double currentTabWidth = _calculateTabWidth(tabTitles[index]);
      final double screenWidth = MediaQuery.of(context).size.width;

      // Calculate scroll position to center the active tab
      final double scrollPosition =
          totalWidthUpToIndex - (screenWidth / 2) + (currentTabWidth / 2);

      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  double _calculateTabWidth(String text) {
    // Base width for padding and minimum space
    const double baseWidth = 30.0; // Reduced from 40.0
    // Approximate character width (adjust based on your font)
    const double charWidth = 7.0; // Reduced from 8.0
    // Calculate width based on text length
    double textWidth = text.length * charWidth;
    // Add base width and ensure minimum width
    return (textWidth + baseWidth).clamp(100.0, 250.0); // Reduced min/max width
  }

  double _calculateTotalWidthUpToIndex(int index) {
    double totalWidth = 0.0;
    for (int i = 0; i < index && i < tabTitles.length; i++) {
      totalWidth += _calculateTabWidth(tabTitles[i]);
    }
    return totalWidth;
  }

  @override
  Widget build(BuildContext context) {
    final mf = ref.watch(mfProvider);
    final theme = ref.watch(themeProvider);


    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(context, theme),
            Expanded(
              child: Stack(
                children: [
                  MyntLoaderOverlay(
                    isLoading: mf.bestmfloader ?? false,
                    child: buildFundList(
                        tabTitles.isNotEmpty ? tabTitles[selectedTab] : '', 
                        mf, 
                        theme, 
                        context
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          CustomBackBtn(onBack: widget.onBack),
          const SizedBox(width: 8),
           Container(
             width: 40,
             height: 40,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: const Color(0xFFFFF6E5), // Light orange background
             ),
             child: widget.icon.contains('.svg') 
                 ? Center(child: SvgPicture.asset(widget.icon, width: 22, height: 22))
                 : widget.icon.contains('.png') || widget.icon.contains('.jpg')
                     ? Center(child: Image.asset(widget.icon, width: 22, height: 22))
                     : const Icon(Icons.collections_bookmark_outlined, color: Color(0xFFECAE14), size: 22),
           ),
           const SizedBox(width: 16),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 widget.title,
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.bold,
                   color: theme.isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                 ),
               ),
               const SizedBox(height: 2),
               Text(
                 widget.subtitle,
                 style: TextStyle(
                   color: resolveThemeColor(context,
                       dark: MyntColors.textSecondaryDark,
                       light: MyntColors.textSecondary),
                   fontSize: 13,
                 ),
               ),
             ],
           ),
           const Spacer(),
            SizedBox(
              width: 300,
              height: 40,
              child: MyntSearchTextField(
                controller: _searchController,
                placeholder: 'Search funds',
                leadingIcon: 'assets/icon/search.svg',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
           const SizedBox(width: 16), // Right padding
        ],
      ),
    );
  }

  // Standardized text style helpers
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

  // Builds a cell with hover detection
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    VoidCallback? onTap, // Added onTap
    bool alignRight = false,
  }) {
    // Add extra horizontal padding for first and last columns
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 4; // 5 columns (0-4)

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
            // final isRowHovered = hoveredIndex == rowIndex;

            return GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: cellPadding,
                color: null,
                alignment: alignRight ? Alignment.topRight : null,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }


  // Builds a sortable header cell
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 4;

    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 0, 8, 0); // Reduced to 0 vertical
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(8, 0, 16, 0); // Reduced to 0 vertical
    } else {
      headerPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 0); // Reduced to 0 vertical
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
              Text(
                label,
                style: _getHeaderStyle(context),
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

  Widget buildFundList(String selectedTab, MFProvider mf, ThemesProvider theme,
      BuildContext context) {
    dynamic newlisst;

    // Get the appropriate basket based on selected tab
    if (mf.newbestmodel?.data?.baskets != null) {
      switch (selectedTab) {
        case 'Tax Saving':
          newlisst = mf.newbestmodel?.data?.baskets?.taxSaving;
          break;
        case 'High Growth Equity':
          newlisst = mf.newbestmodel?.data?.baskets?.highGrowthEquity;
          break;
        case 'Stable Debt':
          newlisst = mf.newbestmodel?.data?.baskets?.stableDebt;
          break;
        case 'Sectoral Thematic':
          newlisst = mf.newbestmodel?.data?.baskets?.sectoralThematic;
          break;
        case 'International  Exposure':
          newlisst = mf.newbestmodel?.data?.baskets?.internationalExposure;
          break;
        case 'Balanced Hybrid':
          newlisst = mf.newbestmodel?.data?.baskets?.balancedHybrid;
          break;
        default:
          newlisst = null;
      }
    } else {
      newlisst = null;
    }

    List<dynamic>? filteredList = newlisst;
    if (_searchQuery.isNotEmpty && filteredList != null) {
      filteredList = filteredList.where((item) {
        final name = (item.name ?? '').toLowerCase();
        final search = _searchQuery.toLowerCase();
        return name.contains(search);
      }).toList();
    }

    final sortedList = filteredList != null ? List.from(filteredList) : null;

    if (sortedList != null && sortedList.isNotEmpty) {
      if (_sortColumnIndex != null) {
        sortedList.sort((a, b) {
          int compareResult = 0;
          switch (_sortColumnIndex) {
            case 0: // Name
              compareResult = (a.name ?? '').compareTo(b.name ?? '');
              break;
             case 1: // AUM
              compareResult = (double.tryParse(a.aUM ?? '0') ?? 0)
                  .compareTo(double.tryParse(b.aUM ?? '0') ?? 0);
              break;
            case 2: // 1Y
              compareResult = (double.tryParse(a.s1Year ?? '0') ?? 0)
                  .compareTo(double.tryParse(b.s1Year ?? '0') ?? 0);
              break;
            case 3: // 3Y
              compareResult = (double.tryParse(a.s3Year ?? '0') ?? 0)
                  .compareTo(double.tryParse(b.s3Year ?? '0') ?? 0);
              break;
             case 4: // Min Invest
              compareResult = (double.tryParse(a.minimumPurchaseAmount ?? '0') ?? 0)
                  .compareTo(double.tryParse(b.minimumPurchaseAmount ?? '0') ?? 0);
              break;
          }
          return _sortAscending ? compareResult : -compareResult;
        });
      }
    }


    if (sortedList == null || sortedList.isEmpty) {
      return const Center(child: NoDataFound(
        secondaryEnabled: false,
      ));
    }

    // Calculate widths - use equal spacing for data columns
    // Calculate widths - use equal spacing for data columns

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth - 32;
        final double fundNameWidth = totalWidth * 0.40;
        final double otherColumnWidth = totalWidth * 0.15;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: shadcn.OutlinedContainer(
            child: SingleChildScrollView(
              child: Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: false, // Hidden scrollbar
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: totalWidth),
                   child: Column(
                     children: [
                       shadcn.Table(
                        defaultRowHeight: const shadcn.FixedTableSize(50), // Reduced Header Height
                        columnWidths: {
                          0: shadcn.FixedTableSize(fundNameWidth),
                          1: shadcn.FixedTableSize(otherColumnWidth), // AUM
                          2: shadcn.FixedTableSize(otherColumnWidth), // 1yr CAGR
                          3: shadcn.FixedTableSize(otherColumnWidth), // 3yr CAGR
                          4: shadcn.FixedTableSize(otherColumnWidth), // Min. Invest
                        },
                        rows: [
                          shadcn.TableHeader(
                            cells: [
                               buildHeaderCell('Fund name', 0),
                               buildHeaderCell('AUM', 1, true),
                               buildHeaderCell('1yr CAGR', 2, true),
                               buildHeaderCell('3yr CAGR', 3, true),
                               buildHeaderCell('Min. Invest', 4, true),
                            ],
                          ),
                        ],
                      ),
                       shadcn.Table(
                        defaultRowHeight: const shadcn.FixedTableSize(70), // Data Row Height
                        columnWidths: {
                          0: shadcn.FixedTableSize(fundNameWidth),
                          1: shadcn.FixedTableSize(otherColumnWidth), // AUM
                          2: shadcn.FixedTableSize(otherColumnWidth), // 1yr CAGR
                          3: shadcn.FixedTableSize(otherColumnWidth), // 3yr CAGR
                          4: shadcn.FixedTableSize(otherColumnWidth), // Min. Invest
                        },
                        rows: [
                          ...sortedList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final amcCode = item.aMCCode ?? "default";

                            void onTap() async {
                              try {
                                if (item.iSIN != null) {
                                  mf.loaderfun();
                                  await mf.fetchFactSheet(item.iSIN);
                                  mf.fetchmatchisan(item.iSIN);

                                  if (mf.factSheetDataModel?.stat != "Not Ok") {
                                    Map<String, dynamic> jsonData = item.toJson();
                                    MutualFundList bInstance =
                                        MutualFundList.fromJson(jsonData);

                                    // Use callback for panel system, otherwise use Navigator
                                    if (widget.onFundTap != null) {
                                      widget.onFundTap!(bInstance);
                                    } else {
                                      Navigator.of(context, rootNavigator: true).pushNamed(
                                        Routes.mfStockDetail,
                                        arguments: bInstance,
                                      );
                                    }
                                  } else {
                                    ResponsiveSnackBar.show(context: context,  message: "No Single Page Data", type: SnackBarType.error);

                                    final jsondata =
                                        MutualFundList.fromJson(item.toJson());
                                    Navigator.pushNamed(context, Routes.mforderScreen,
                                        arguments: jsondata);

                                    mf.orderchangetitle("One-time");
                                    mf.chngOrderType("One-time");
                                  }
                                } else {
                                  ResponsiveSnackBar.show(context: context,  message: "Invalid fund data", type: SnackBarType.error);
                                }
                              } catch (e) {
                                ResponsiveSnackBar.show(context: context,  message: "Error loading fund details", type: SnackBarType.error);
                              }
                            }

                            return shadcn.TableRow(
                              cells: [
                                // Fund name column with tags and hover buttons
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 0,
                                  onTap: onTap,
                                  child: ValueListenableBuilder<int?>(
                                    valueListenable: _hoveredRowIndex,
                                    builder: (context, hoveredIndex, _) {
                                      final isHovered = hoveredIndex == index;
                                      return Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundImage: NetworkImage(
                                              "https://v3.mynt.in/mfapi/static/images/mf/$amcCode.png",
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  item.name ?? '--',
                                                  style: _getTextStyle(context),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "${item.type ?? 'Equity'}   ${item.subType ?? item.schemeType ?? ''}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: resolveThemeColor(context,
                                                        dark: MyntColors.textSecondaryDark,
                                                        light: MyntColors.textSecondary),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Buy/SIP buttons on hover
                                          if (isHovered) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: resolveThemeColor(context,
                                                    dark: MyntColors.searchBgDark,
                                                    light: MyntColors.backgroundColor),
                                                borderRadius: BorderRadius.circular(6),
                                                boxShadow: MyntShadows.card,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  _buildActionButton('Buy', const Color(0xff0037B7), () => _handleOrder(item, 'One-time', mf), filled: true),
                                                  const SizedBox(width: 6),
                                                  _buildActionButton('SIP', const Color(0xff0037B7), () => _handleOrder(item, 'SIP', mf), filled: true),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                // AUM column
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 1,
                                  alignRight: true,
                                  onTap: onTap,
                                  child: Text(
                                    _formatAUM(item.aUM),
                                    style: _getTextStyle(context),
                                  ),
                                ),
                                // 1yr CAGR column
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 2,
                                  alignRight: true,
                                  onTap: onTap,
                                  child: Text(_formatReturns(item.s1Year),
                                      style: _getTextStyle(context)),
                                ),
                                // 3yr CAGR column
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 3,
                                  alignRight: true,
                                  onTap: onTap,
                                  child: Text(
                                    _formatCAGR(item.s3Year),
                                    style: _getTextStyle(context,
                                        color: _getReturnColor(context, item.s3Year)),
                                  ),
                                ),
                                // Min. Invest column
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 4,
                                  alignRight: true,
                                  onTap: onTap,
                                  child: Text(
                                    '₹${item.minimumPurchaseAmount ?? '500.00'}',
                                    style: _getTextStyle(context),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                     ],
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

  String _formatReturns(String? returns) {
    if (returns == null || returns.isEmpty || returns == "0.0") {
      return "0.00%";
    }
    return "$returns%";
  }

  String _formatCAGR(String? returns) {
    return _formatReturns(returns);
  }

  String _formatAUM(String? aum) {
    if (aum == null || aum.isEmpty) return "--";
    try {
      double value = double.tryParse(aum) ?? 0;
      return value.toStringAsFixed(2);
    } catch (e) {
      return aum;
    }
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap, {bool filled = true}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), // Reduced vertical padding
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          border: filled ? null : Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _handleOrder(dynamic item, String orderType, MFProvider mf) async {
    // Show loader while fetching dependencies
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: MyntLoader(size: MyntLoaderSize.large)),
    );

    try {
      // Fetch bank details
      await ref.read(transcationProvider).fetchfundbank(context);

      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loader

      final isin = item.iSIN;
      final schemeCode = item.schemeCode;

      // Set up SIP if applicable
      if (item.sIPFLAG == "Y" && isin != null && schemeCode != null) {
        mf.invertfun(isin, schemeCode, context);
      }

      // Pre-fill amount based on order type
      if (orderType == "One-time") {
        String amt = item.minimumPurchaseAmount ?? "0";
        mf.invAmt.text = amt.split('.').first;
      } else {
        String amt = item.minimumPurchaseAmount ?? "0";
        mf.installmentAmt.text = amt.split('.').first;
      }

      // Convert item to MutualFundList
      Map<String, dynamic> jsonData = item.toJson();
      // Ensure fSchemeName is set from name if not present
      if (jsonData['f_scheme_name'] == null && jsonData['name'] != null) {
        jsonData['f_scheme_name'] = jsonData['name'];
      }
      MutualFundList mfItem = MutualFundList.fromJson(jsonData);

      if (context.mounted) {
        mf.chngOrderType(orderType);
        mf.orderchangetitle(orderType);
        
        // Get screen dimensions
        final screenSize = MediaQuery.of(context).size;
        final dialogWidth = screenSize.width * 0.25; // 25% width
        final dialogHeight = screenSize.height * 0.60; // 60% height
        
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MFOrderScreen(mfData: mfItem),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loader if still showing
        ResponsiveSnackBar.show(context: context,  message: "Error: ${e.toString()}", type: SnackBarType.error);
      }
    }
  }

  Color _getReturnColor(BuildContext context, String? returns) {
    if (returns == null || returns.isEmpty) {
      return Colors.grey;
    }
    try {
      final value = double.parse(returns);
      if (value > 0) {
        return resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit);
      }
      if (value < 0) {
        return resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }
}




//  Column(
//                               children: [
//                                 InkWell(
//                                   // onLongPress: () async {
//                                   //   if (isin != null) {
//                                   //     await mf.fetchMFWatchlist(
//                                   //       isin,
//                                   //       isAdd ? "delete" : "add",
//                                   //       context,
//                                   //       false,
//                                   //       "watch",
//                                   //     );
//                                   //   }
//                                   // },
//                                   onTap: () async {
//                                     try {
//                                       if (isin != null) {
//                                         mf.loaderfun();
//                                         await mf.fetchFactSheet(isin);
//                                         mf.fetchmatchisan(isin);
                                        
//                                         if (mf.factSheetDataModel?.stat != "Not Ok") {
//                                           Map<String, dynamic> jsonData = item.toJson();
//                                           MutualFundList bInstance = MutualFundList.fromJson(jsonData);
//                                           Navigator.pushNamed(
//                                             context, 
//                                             Routes.mfStockDetail,
//                                             arguments: bInstance
//                                           );
//                                         } else {
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             successMessage(context, "No Single Page Data")
//                                           );
                                          
//                                           final jsondata = MutualFundList.fromJson(item.toJson());
//                                           Navigator.pushNamed(
//                                             context, 
//                                             Routes.mforderScreen,
//                                             arguments: jsondata
//                                           );
                                          
//                                           mf.orderchangetitle("One-time");
//                                           mf.chngOrderType("One-time");
//                                         }
//                                       } else {
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                           successMessage(context, "Invalid fund data")
//                                         );
//                                       }
//                                     } catch (e) {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         successMessage(context, "Error loading fund details")
//                                       );
//                                     }
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.symmetric(
//                                         vertical: BorderSide(
//                                           color: isDarkMode
//                                             ? colors.darkGrey
//                                             : const Color(0xffEEF0F2),
//                                           width: 0,
//                                         ),
//                                       ),
//                                     ),
//                                     padding: const EdgeInsets.all(8),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Expanded(
//                                               child: Row(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
                                                  
//                                                   CircleAvatar(
//                                                     backgroundImage: NetworkImage(
//                                                       "https://v3.mynt.in/mfapi/static/images/mf/$amcCode.png",
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 16),
//                                                   Expanded(
//                                                     child: Column(
//                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                       children: [
//                                                         Row(
//                                                           children: [
//                                                             SizedBox(
//                                                               width: MediaQuery.of(context).size.width * 0.6,
//                                                               child: 
//                                                               TextWidget.subText(
//                                                     align: TextAlign.start,
//                                                     text: schemeGroupName,
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textPrimaryDark:
//                                                          colors.textPrimaryLight
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                                                              
                                                             
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         const SizedBox(height: 8),
//                                                         SizedBox(
//                                                           height: 16,
//                                                           child: ListView(
//                                                             scrollDirection: Axis.horizontal,
//                                                             children: [
//                                                               TextWidget.paraText(
//                                   fw: 3,
//                                   text: "${item.type ?? "Unknown"}",
//                                   textOverflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                   color: theme.isDarkMode
//                                       ? colors.textSecondaryDark
//                                       : colors.textSecondaryLight,
//                                   theme: false,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 5),
//                                   child: TextWidget.paraText(
//                                     fw: 3,
//                                     text: "${item.subType ?? "Unknown"}",
//                                     textOverflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                     color: theme.isDarkMode
//                                         ? colors.textSecondaryDark
//                                         : colors.textSecondaryLight,
//                                     theme: false,
//                                   ),
                                  
                                  
//                                 ),
                                                             
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             TextWidget.titleText(
//                                                     align: TextAlign.right,
//                                                     color: isPositive ? Colors.green : Colors.red,
//                                                     text: "$threeYearData%",
                                                              
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                                             
                                             
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Divider(
//                                           color: isDarkMode
//                                             ? colors.darkColorDivider
//                                             : colors.colorDivider,
//                                           thickness: 1.0,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );













// class SaveTaxesScreen extends ConsumerWidget {
//   final String title;

//   const SaveTaxesScreen({super.key, required this.title});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final mf = ref.watch(mfProvider);
//     final theme = ref.watch(themeProvider);
//     final isDarkMode = theme.isDarkMode;
//     final dynamic newlisst;

//     // Safely select the proper basket based on selected chip
//     if (mf.newbestmodel?.data?.baskets != null) {
//       switch (mf.selctedchip) {
//         case 'Tax Saving':
//           newlisst = mf.newbestmodel?.data?.baskets?.taxSaving;
//           break;
//         case 'High Growth Equity':
//           newlisst = mf.newbestmodel?.data?.baskets?.highGrowthEquity;
//           break;
//         case 'Stable Debt':
//           newlisst = mf.newbestmodel?.data?.baskets?.stableDebt;
//           break;
//         case 'Sectoral Thematic':
//           newlisst = mf.newbestmodel?.data?.baskets?.sectoralThematic;
//           break;
//         case 'International  Exposure':
//           newlisst = mf.newbestmodel?.data?.baskets?.internationalExposure;
//           break;
//         case 'Balanced Hybrid':
//           newlisst = mf.newbestmodel?.data?.baskets?.balancedHybrid;
//           break;
//         default:
//           newlisst = null;
//       }
//     } else {
//       newlisst = null;
//     }

//     // Sort by 3-year data if available
//     final sortedList = newlisst != null ? List.from(newlisst) : null;
//     if (sortedList != null) {
//       sortedList.sort((a, b) => (double.tryParse(b.s3Year ?? "0") ?? 0)
//           .compareTo(double.tryParse(a.s3Year ?? "0") ?? 0));
//     }

//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(50),
//         child: AppBar(
//           elevation: 0,
//           leadingWidth: 41,
//           centerTitle: false,
//           titleSpacing: 6,
//           leading: CustomBackBtn(),
//           title: TextWidget.titleText(
//             text: "Collections",
//             color:
//                 isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
//             fw: 1,
//             theme: theme.isDarkMode,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           TransparentLoaderScreen(
//             isLoading: mf.bestmfloader ?? false,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // const SizedBox(height: 10),
//                 buildSlidingPanelContent(
//                     mf.bestMFListStaticnew ?? [], mf, theme),
//                 Expanded(
//                   child: sortedList == null || sortedList.isEmpty
//                       ? const Center(child: NoDataFound())
//                       : ListView.separated(
//                           // padding: const EdgeInsets.all(8),
//                           itemCount: sortedList.length,
//                           separatorBuilder: (_, __) => const ListDivider(),
//                           itemBuilder: (BuildContext context, int index) {
//                             final item = sortedList[index];
//                             final schemeGroupName = item.name ?? "Unknown Fund";
//                             final amcCode = item.aMCCode ?? "default";
//                             final isin = item.iSIN;
//                             final type = item.schemeType ?? "";
//                             final subType = item.subType ?? "";
//                             final threeYearData = item.s3Year ?? "0.00";
//                             // final isAdd = item.isAdd == true;

//                             // Parse 3-year performance data safely
//                             final performanceValue = double.tryParse(
//                                     threeYearData.isEmpty
//                                         ? "0.00"
//                                         : threeYearData) ??
//                                 0.0;

//                             // Determine if performance is positive or negative
//                             final isPositive = performanceValue >= 0;

//                             return Material(
//                               color: Colors.transparent,
//                               child: InkWell(
//                                 onTap: () async {
//                                   try {
//                                     if (isin != null) {
//                                       mf.loaderfun();
//                                       await mf.fetchFactSheet(isin);
//                                       mf.fetchmatchisan(isin);

//                                       if (mf.factSheetDataModel?.stat !=
//                                           "Not Ok") {
//                                         Map<String, dynamic> jsonData =
//                                             item.toJson();
//                                         MutualFundList bInstance =
//                                             MutualFundList.fromJson(jsonData);
//                                         Navigator.pushNamed(
//                                             context, Routes.mfStockDetail,
//                                             arguments: bInstance);
//                                       } else {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(successMessage(
//                                                 context,
//                                                 "No Single Page Data"));

//                                         final jsondata =
//                                             MutualFundList.fromJson(
//                                                 item.toJson());
//                                         Navigator.pushNamed(
//                                             context, Routes.mforderScreen,
//                                             arguments: jsondata);

//                                         mf.orderchangetitle("One-time");
//                                         mf.chngOrderType("One-time");
//                                       }
//                                     } else {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(successMessage(
//                                               context, "Invalid fund data"));
//                                     }
//                                   } catch (e) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                         successMessage(context,
//                                             "Error loading fund details"));
//                                   }
//                                 },
//                                 child: ListTile(
//                                   contentPadding:
//                                       const EdgeInsets.symmetric(horizontal: 8),
//                                   dense: false,
//                                   leading: CircleAvatar(
//                                     backgroundImage: NetworkImage(
//                                       "https://v3.mynt.in/mfapi/static/images/mf/$amcCode.png",
//                                     ),
//                                   ),
//                                   title: Container(
//                                     margin: EdgeInsets.only(
//                                       right: MediaQuery.of(context).size.width *
//                                           0.1,
//                                     ),
//                                     child: TextWidget.subText(
//                                         align: TextAlign.start,
//                                         text: schemeGroupName,
//                                         color: theme.isDarkMode
//                                             ? colors.textPrimaryDark
//                                             : colors.textPrimaryLight,
//                                         textOverflow: TextOverflow.ellipsis,
//                                         maxLines: 2,
//                                         theme: theme.isDarkMode,
//                                         fw: 3),
//                                   ),
//                                   subtitle: Padding(
//                                     padding: const EdgeInsets.only(top: 8),
//                                     child: TextWidget.paraText(
//                                       fw: 3,
//                                       text: "${item.type ?? "Unknown"}",
//                                       textOverflow: TextOverflow.ellipsis,
//                                       maxLines: 1,
//                                       color: theme.isDarkMode
//                                           ? colors.textSecondaryDark
//                                           : colors.textSecondaryLight,
//                                       theme: false,
//                                     ),
//                                   ),
//                                   trailing: TextWidget.subText(
//                                       align: TextAlign.right,
//                                       color: theme.isDarkMode
//                                           ? colors.textPrimaryDark
//                                           : colors.textPrimaryLight,
//                                       text: "$threeYearData%",
//                                       textOverflow: TextOverflow.ellipsis,
//                                       theme: theme.isDarkMode,
//                                       fw: 3),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildSlidingPanelContent(
//       List bestMFList, MFProvider mfData, ThemesProvider theme) {
//     final isDarkMode = theme.isDarkMode;

//     return Container(
//       padding: const EdgeInsets.only(left: 0, right: 0),
//       height: 75,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Wrap(
//               spacing: 0,
//               children: bestMFList.map<Widget>((mf) {
//                 final title = mf['title'] ?? "";
//                 final isSelected = title == mfData.selctedchip;

//                 return GestureDetector(
//                   onTap: () => mfData.changetitle(title),
//                   child: Padding(
//                       padding: const EdgeInsets.only(left: 8),
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               color: isSelected
//                                   ? colors.primaryDark
//                                   : Colors.transparent,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                         child: TextWidget.subText(
//                             letterSpacing: 0.2,
//                             align: TextAlign.start,
//                             text: title,
//                             color:
//                                 isSelected ? colors.primaryLight : Colors.black,
//                             textOverflow: TextOverflow.ellipsis,
//                             theme: theme.isDarkMode,
//                             fw: isSelected ? 1 : 3),
//                       )),
//                 );
//               }).toList(),
//             ),
//           ),
//           // const SizedBox(height: 10),
//           Container(
//             // color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F8),
//             child: Padding(
//               padding:
//                   const EdgeInsets.only(left: 12, bottom: 8, top: 16, right: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextWidget.paraText(
//                       align: TextAlign.right,
//                       text: 'Funds',
//                       color: theme.isDarkMode
//                           ? colors.textSecondaryDark
//                           : colors.textSecondaryLight,
//                       textOverflow: TextOverflow.ellipsis,
//                       theme: theme.isDarkMode,
//                       fw: 3),
//                   TextWidget.paraText(
//                       align: TextAlign.right,
//                       text: '3Y Returns',
//                       color: theme.isDarkMode
//                           ? colors.textSecondaryDark
//                           : colors.textSecondaryLight,
//                       textOverflow: TextOverflow.ellipsis,
//                       theme: theme.isDarkMode,
//                       fw: 3),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
