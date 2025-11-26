// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/no_data_found.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import 'mf_stock_detail_screen.dart';

class SaveTaxesScreen extends ConsumerStatefulWidget {
  final String title;

  const SaveTaxesScreen({super.key, required this.title});

  @override
  ConsumerState<SaveTaxesScreen> createState() => _SaveTaxesScreenState();
}

class _SaveTaxesScreenState extends ConsumerState<SaveTaxesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  int selectedTab = 0;
  String selectedReturn = '3Y Returns'; // Track selected return period

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
    final isDarkMode = theme.isDarkMode;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          leadingWidth: 41,
          centerTitle: false,
          titleSpacing: 6,
          leading: CustomBackBtn(),
          title: TextWidget.titleText(
            text: "Collections",
            color:
                isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 1,
            theme: theme.isDarkMode,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            TransparentLoaderScreen(
              isLoading: mf.bestmfloader ?? false,
              child: Column(
                children: [
                  // Custom tabs section
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDarkMode
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
                              splashColor: isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                              highlightColor: isDarkMode
                                  ? Colors.white.withOpacity(0.01)
                                  : Colors.black.withOpacity(0.01),
                              onTap: () {
                                setState(() {
                                  selectedTab = tab;
                                });
                                _tabController.animateTo(tab);
                                // Update the selected chip in your provider
                                mf.changetitle(tabTitles[tab]);
                                // Scroll to center the active tab
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _scrollToActiveTab(tab);
                                });
                              },
                              child: tabConstruct(
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
                        left: 12, bottom: 8, top: 16, right: 8),
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
                          fw: 0,
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
                                  fw: 0,
                                )),
                            PopupMenuItem(
                                value: '3Y Returns',
                                child: TextWidget.paraText(
                                  text: '3Y Returns',
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 0,
                                )),
                            PopupMenuItem(
                                value: '5Y Returns',
                                child: TextWidget.paraText(
                                  text: '5Y Returns',
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 0,
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
                                  fw: 0,
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
                        return buildFundList(
                            tabTitle, mf, theme, context, selectedReturn);
                      }).toList(),
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

  Widget tabConstruct(String title, ThemesProvider theme, int tab) {
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
                : theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
            textOverflow: TextOverflow.ellipsis,
            maxLines: 1,
            theme: theme.isDarkMode,
            fw: isActive ? 2 : 2,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 2,
          width: isActive ? (tabWidth - 12) : 0,
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

  Widget buildFundList(String selectedTab, MFProvider mf, ThemesProvider theme,
      BuildContext context, String selectedReturn) {
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

    // Sort by selected return period
    final sortedList = newlisst != null ? List.from(newlisst) : null;
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

        return (double.tryParse(bValue ?? "0") ?? 0)
            .compareTo(double.tryParse(aValue ?? "0") ?? 0);
      });
    }

    if (sortedList == null || sortedList.isEmpty) {
      return const Center(child: NoDataFound(
        secondaryEnabled: false,
      ));
    }

    return ListView.separated(
      physics: ClampingScrollPhysics(),
      itemCount: sortedList.length,
      separatorBuilder: (_, __) => const ListDivider(),
      itemBuilder: (BuildContext context, int index) {
        final item = sortedList[index];
        final schemeGroupName = item.name ?? "Unknown Fund";
        final amcCode = item.aMCCode ?? "default";
        final isin = item.iSIN;
        final type = item.schemeType ?? "";
        final subType = item.subType ?? "";

        // Get the appropriate return data based on selected period
        String returnData;
        switch (selectedReturn) {
          case '1Y Returns':
            returnData = item.s1Year ?? "0.00";
            break;
          case '3Y Returns':
            returnData = item.s3Year ?? "0.00";
            break;
          case '5Y Returns':
            returnData = item.s5Year ?? "0.00";
            break;
          default:
            returnData = item.s3Year ?? "0.00";
        }

        // Parse performance data safely
        final performanceValue =
            double.tryParse(returnData.isEmpty ? "0.00" : returnData) ?? 0.0;

        // Determine if performance is positive or negative
        final isPositive = performanceValue >= 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              try {
                if (isin != null) {
                  mf.loaderfun();
                  await mf.fetchFactSheet(isin);
                  mf.fetchmatchisan(isin);

                  if (mf.factSheetDataModel?.stat != "Not Ok") {
                    Map<String, dynamic> jsonData = item.toJson();
                    MutualFundList bInstance =
                        MutualFundList.fromJson(jsonData);

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
                        
                    // Navigator.pushNamed(context, Routes.mfStockDetail,
                    //     arguments: bInstance);
                  } else {
                        successMessage(context, "No Single Page Data");

                    final jsondata = MutualFundList.fromJson(item.toJson());
                    Navigator.pushNamed(context, Routes.mforderScreen,
                        arguments: jsondata);

                    mf.orderchangetitle("One-time");
                    mf.chngOrderType("One-time");
                  }
                } else {
                      successMessage(context, "Invalid fund data");
                }
              } catch (e) {
                    successMessage(context, "Error loading fund details");
              }
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              dense: false,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://v3.mynt.in/mfapi/static/images/mf/$amcCode.png",
                ),
              ),
              title: Container(
                margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                ),
                child: TextWidget.subText(
                  align: TextAlign.start,
                  text: schemeGroupName,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  textOverflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  theme: theme.isDarkMode,
                  fw: 0,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextWidget.paraText(
                  fw: 0,
                  text: "${item.type ?? "Unknown"}",
                  textOverflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  theme: false,
                ),
              ),
              trailing: TextWidget.subText(
                align: TextAlign.right,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                text: _formatReturns(returnData),
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
          ),
        );
      },
    );
  }
}

String _formatReturns(String? returns) {
    if (returns == null || returns.isEmpty || returns == "0.0") {
      return "0.00%";
    }
    return "$returns%";
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
