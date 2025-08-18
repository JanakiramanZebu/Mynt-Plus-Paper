import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../models/mf_model/mutual_fundmodel.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import 'mf_stock_detail_screen.dart';

class MFCategoryListScreen extends ConsumerStatefulWidget {
  final String title;
  const MFCategoryListScreen({super.key, required this.title});

  @override
  ConsumerState<MFCategoryListScreen> createState() =>
      _MFCategoryListScreenState();
}

class _MFCategoryListScreenState extends ConsumerState<MFCategoryListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  int selectedTab = 0;
  List<String> tabTitles = [];
  String selectedReturn = '3Y Returns'; // Track selected return period

  @override
  void initState() {
    super.initState();

    // Initialize tab titles based on the category data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTabs();
    });
  }

  void _initializeTabs() {
    final mfData = ref.read(mfProvider);
    final categoryData = mfData.mFCategoryTypesStatic;

    // Find the matching category and get its sub-tabs
    for (var category in categoryData) {
      if (category['title'] == widget.title) {
        List<dynamic> subTabs = category['sub'] ?? [];
        setState(() {
          tabTitles = subTabs.map((tab) => tab.toString()).toList();
        });
        break;
      }
    }

    // Initialize TabController after we have the tabs
    if (tabTitles.isNotEmpty) {
      _tabController =
          TabController(length: tabTitles.length, vsync: this, initialIndex: 0);
      _scrollController = ScrollController();
      selectedTab = 0;

      _tabController.animation!.addListener(() {
        final newIndex = _tabController.animation!.value.round();
        if (selectedTab != newIndex) {
          setState(() {
            selectedTab = newIndex;
          });
          // Update the selected chip in provider
          if (newIndex < tabTitles.length) {
            ref.read(mfProvider).changetitle(tabTitles[newIndex]);
            ref
                .read(mfProvider)
                .fetchcatdatanew(widget.title, tabTitles[newIndex]);
          }
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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
    const double baseWidth = 24.0; // Reduced from 30.0
    // Approximate character width (adjust based on your font)
    const double charWidth = 7.0;
    // Calculate width based on text length
    double textWidth = text.length * charWidth;
    // Add base width and ensure minimum width
    return (textWidth + baseWidth).clamp(100.0, 250.0);
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
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leadingWidth: 41,
          centerTitle: false,
          titleSpacing: 6,
          leading: CustomBackBtn(),
          shadowColor: const Color(0xffECEFF3),
          title: TextWidget.titleText(
            text: widget.title,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
            theme: theme.isDarkMode,
          ),
        ),
        body: TransparentLoaderScreen(
          isLoading: mfData.bestmfloader ?? false,
          child: tabTitles.isEmpty
              ? const Center(child: NoDataFound())
              : Column(
                  children: [
                    // Custom tabs section
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0,
                          ),
                        ),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(
                            tabTitles.length,
                            (tab) => Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.05),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.01)
                                    : Colors.black.withOpacity(0.01),
                                onTap: () {
                                  setState(() {
                                    selectedTab = tab;
                                  });
                                  _tabController.animateTo(tab);
                                  // Update the selected chip in your provider
                                  mfData.changetitle(tabTitles[tab]);
                                  mfData.fetchcatdatanew(
                                      widget.title, tabTitles[tab]);
                                  // Scroll to center the active tab
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _scrollToActiveTab(tab);
                                  });
                                },
                                child: _tabConstruct(
                                  tabTitles[tab],
                                  theme,
                                  tab,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Header row for "Funds" and "3Y Returns"
                    Container(
                      padding: const EdgeInsets.only(
                          left: 12, bottom: 8, top: 12, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget.paraText(
                            align: TextAlign.right,
                            text: 'Funds',
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 3,
                          ),
                          PopupMenuButton<String>(
                            color: theme.isDarkMode
                                ? colors.searchBgDark
                                : colors.searchBg,
                            onSelected: (value) {
                              setState(() {
                                selectedReturn = value;
                              });
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                  value: '1Y Returns',
                                  child: TextWidget.paraText(
                                    text: '1Y Returns',
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 3,
                                  )),
                              PopupMenuItem(
                                  value: '3Y Returns',
                                  child: TextWidget.paraText(
                                    text: '3Y Returns',
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 3,
                                  )),
                              PopupMenuItem(
                                  value: '5Y Returns',
                                  child: TextWidget.paraText(
                                    text: '5Y Returns',
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 3,
                                  )),
                            ],
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                        splashColor: theme.isDarkMode
                                            ? Colors.white.withOpacity(0.15)
                                            : Colors.black.withOpacity(0.15),
                                        highlightColor: theme.isDarkMode
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.black.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: TextWidget.paraText(
                                    align: TextAlign.right,
                                    text: selectedReturn,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 3,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // TabBarView with fund lists
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: tabTitles.map((tabTitle) {
                          return _buildFundList(
                              tabTitle, mfData, theme, context, selectedReturn);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _tabConstruct(String title, ThemesProvider theme, int tab) {
    final isActive = selectedTab == tab;
    final double tabWidth = _calculateTabWidth(title);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: tabWidth,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: TextWidget.subText(
            text: title,
            color: isActive
                ? theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight
                : colors.textSecondaryLight,
            textOverflow: TextOverflow.ellipsis,
            maxLines: 1,
            theme: theme.isDarkMode,
            fw: isActive ? 2 : null,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 2,
          width: isActive ? (tabWidth - 12) : 0, // Dynamic underline width
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? colors.secondaryDark
                : colors.secondaryLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFundList(String selectedTab, dynamic mfData,
      ThemesProvider theme, BuildContext context, String selectedReturn) {
    // Sort the list based on selected return period
    final sortedList = mfData.catnewlist?.toList();

    if (sortedList != null) {
      sortedList.sort((a, b) {
        String? aValue, bValue;

        switch (selectedReturn) {
          case '1Y Returns':
            aValue = a.s1Year;
            bValue = b.s1Year;
            break;
          case '3Y Returns':
            aValue = a.s3Year;
            bValue = b.s3Year;
            break;
          case '5Y Returns':
            aValue = a.s5Year;
            bValue = b.s5Year;
            break;
          default:
            aValue = a.s3Year;
            bValue = b.s3Year;
        }

        final aDouble = double.tryParse(aValue ?? '0.00') ?? 0.00;
        final bDouble = double.tryParse(bValue ?? '0.00') ?? 0.00;
        return bDouble.compareTo(aDouble); // Sort in descending order
      });
    }

    if (sortedList == null || sortedList.isEmpty) {
      return const Center(child: NoDataFound());
    }

    return ListView.separated(
      itemCount: sortedList.length,
      separatorBuilder: (_, __) => const ListDivider(),
      itemBuilder: (BuildContext context, int index) {
        final item = sortedList[index];
        if (item == null) return const SizedBox.shrink();

        return _buildListItem(context, item, theme, mfData, selectedReturn);
      },
    );
  }

  Widget _buildListItem(BuildContext context, dynamic item,
      ThemesProvider theme, dynamic mfData, String selectedReturn) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          splashColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.15),
          highlightColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
          onLongPress: () async {
            try {
              if (item.iSIN != null) {
                await mfData.fetchMFWatchlist(
                  item.iSIN,
                  item.isAdd ?? false ? "delete" : "add",
                  context,
                  false,
                  "watch",
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(successMessage(
                  context, "Error updating watchlist: ${e.toString()}"));
            }
          },
          onTap: () async {
            try {
              mfData.loaderfun();
              if (item.iSIN != null) {
                await mfData.fetchFactSheet(item.iSIN);

                if (mfData.factSheetDataModel?.stat != "Not Ok") {
                  Map<String, dynamic> jsonData = item.toJson();
                  MutualFundList bInstance = MutualFundList.fromJson(jsonData);

                  showModalBottomSheet(
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    isDismissible: true,
                    enableDrag: false,
                    useSafeArea: true,
                    context: context,
                    builder: (context) => Container(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: MFStockDetailScreen(mfStockData: bInstance)),
                  );
                  // Navigator.pushNamed(
                  //   context,
                  //   Routes.mfStockDetail,
                  //   arguments: bInstance,
                  // );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      successMessage(context, "No Single Page Data"));
                  final jsondata = MutualFundList.fromJson(item.toJson());
                  Navigator.pushNamed(context, Routes.mforderScreen,
                      arguments: jsondata);
                  mfData.orderchangetitle("One-time");
                  mfData.chngOrderType("One-time");
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    successMessage(context, "Missing fund information"));
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(successMessage(
                  context, "Error loading fund details: ${e.toString()}"));
            }
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            dense: false,
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://v3.mynt.in/mfapi/static/images/mf/${item.aMCCode ?? 'default'}.png",
              ),
            ),
            title: Container(
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.1,
              ),
              child: TextWidget.subText(
                text: item.name ?? "Unknown Scheme",
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                theme: theme.isDarkMode,
                fw: 3,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextWidget.paraText(
                text: "${item.type ?? "Unknown"}",
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                theme: theme.isDarkMode,
                fw: 3,
              ),
            ),
            trailing: TextWidget.subText(
              text: _formatReturns(item.s3Year),
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 3,
            ),
          )),
    );
  }

  String _getReturnValue(dynamic item, String selectedReturn) {
    switch (selectedReturn) {
      case '1Y Returns':
        return item.s1Year ?? "0.00";
      case '3Y Returns':
        return item.s3Year ?? "0.00";
      case '5Y Returns':
        return item.s5Year ?? "0.00";
      default:
        return item.s3Year ?? "0.00";
    }
  }

  String _formatReturns(String? returns) {
    if (returns == null || returns.isEmpty) {
      return "0.00%";
    }
    return "$returns%";
  }

  Color _getReturnColor(String? returns) {
    if (returns == null || returns.isEmpty) {
      return Colors.grey;
    }

    try {
      final value = double.parse(returns);
      return value >= 0 ? Colors.green : Colors.red;
    } catch (e) {
      // If parsing fails, return a neutral color
      return Colors.grey;
    }
  }
}
