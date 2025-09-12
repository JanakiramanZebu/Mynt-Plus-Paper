import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/snack_bar.dart';
import '../../sharedWidget/splash_loader.dart';
import 'bottom_sheets/pledge_details.dart';
import 'bottom_sheets/pledge_list.dart';
import 'pledge_and_unpledge/pledge_filter_screen.dart';
import 'tax_pnl_screens/charges_value_screen.dart';
import 'tax_pnl_screens/pnl_value_screen.dart';
import 'tax_pnl_screens/turnover_value_screen.dart';

class PledgenUnpledge extends StatefulWidget {
  final String ddd;
  const PledgenUnpledge({super.key, required this.ddd});

  @override
  State<PledgenUnpledge> createState() => _PledgenUnpledgeState();
}

class _PledgenUnpledgeState extends State<PledgenUnpledge>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int activeTab = 0;

  // Search functionality variables
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    // tabController.animation!.addListener(_onTabChanged);

    // Add listener to search controller to update UI when text changes
    searchController.addListener(() {
      setState(() {});
    });
  }

  void _onTabChanged(index) {
    final newIndex = index;
    if (activeTab != newIndex) {
      setState(() {
        activeTab = newIndex;
      });
    }
    print("${activeTab}pledgevavavavava");
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (isSearching) {
        searchFocusNode.requestFocus();
      } else {
        searchController.clear();
        searchQuery = '';
        searchFocusNode.unfocus();
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
    print("Search value: $value");
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    List<Tab> orderTabName = [
      Tab(text: "Pledge"),
      Tab(text: " Unpledge"),
      Tab(text: "Un-Approved"),
    ];

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      var cashstat = 0.0;
      var noncash = 0.0;
      var pledgedvalue = [];
      final ledgerprovider = ref.watch(ledgerProvider);
      Future<void> _refresh() async {
        await Future.delayed(Duration(seconds: 0)); // simulate refresh delay
        print("refresh ");
        ledgerprovider.getCurrentDate("pandu");
        ledgerprovider.fetchpledgeandunpledge(context);
      }

      String displayValue = (ledgerprovider.pledgeandunpledge?.estTotalAvailable
                      ?.toString() ==
                  null ||
              ledgerprovider.pledgeandunpledge?.estTotalAvailable?.toString() ==
                  'null')
          ? '0.00'
          : ledgerprovider.pledgeandunpledge!.estTotalAvailable!.toString();

      // if (ledgerprovider.pledgeandunpledge?.data != null) {
      //   for (var i = 0;
      //       i < ledgerprovider.pledgeandunpledge!.data!.length;
      //       i++) {
      //     if (double.tryParse(ledgerprovider.pledgeandunpledge!.data![i].cOLQTY
      //                 .toString())!
      //             .toInt() >
      //         0) {
      //       pledgedvalue.add(ledgerprovider.pledgeandunpledge!.data![i].cOLQTY);
      //       print("${pledgedvalue} pledgedvaluepledgedvalue");
      //     }
      //     print(
      //         "${double.tryParse(ledgerprovider.pledgeandunpledge!.data![i].cOLQTY.toString())!.toInt()} ledgerprovider.pledgeandunpledge!.data![i].plegeQtyefeefefeefe");

      //     if ((ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.foCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.foCashEq ==
      //                 'True'
      //             : true) &&
      //         (ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.cdCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.cdCashEq ==
      //                 'True'
      //             : true) &&
      //         (ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.comCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.comCashEq ==
      //                 'True'
      //             : true)) {
      //       cashstat += (ledgerprovider
      //                       .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS !=
      //                   'nan' &&
      //               ledgerprovider
      //                       .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS !=
      //                   '')
      //           ? (double.tryParse(ledgerprovider
      //                   .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS
      //                   .toString()) ??
      //               0.0)
      //           : 0.0;
      //     }
      //     if ((ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.foCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.foCashEq ==
      //                 'False'
      //             : true) &&
      //         (ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.cdCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.cdCashEq ==
      //                 'False'
      //             : true) &&
      //         (ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.comCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.comCashEq ==
      //                 'False'
      //             : true)) {
      //       noncash += (ledgerprovider
      //                       .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS !=
      //                   'nan' &&
      //               ledgerprovider
      //                       .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS !=
      //                   '')
      //           ? (double.tryParse(ledgerprovider
      //                   .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS
      //                   .toString()) ??
      //               0.0)
      //           : 0.0;
      //     }
      //   }
      // }

      final List<dynamic> displaypledgedvalue = pledgedvalue;

      return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: const CustomBackBtn(),
          elevation: 0.2,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.titleText(
                  text: "Pledge",
                  textOverflow: TextOverflow.ellipsis,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                  fw: 1),
              // IconButton(
              //     onPressed: () async {
              //       await ledgerprovider.fetchunpledgehistory(context);
              //       ledgerprovider.fetchpledgehistory(context);
              //       ledgerprovider.taxpnlExTabchange(0);
              //       Navigator.pushNamed(context, Routes.pledgehistorymainscreen,
              //           arguments: "DDDDD");
              //     },
              //     icon: const Icon(Icons.history))
            ],
          ),
      
          // leading: InkWell(
          //   onTap: () {
      
          //   },
          //   child: Icon(Icons.ios_share)),
        ),
        body: ledgerprovider.pledgeloader
            ? Center(
                child: Container(
                  color: Colors.white,
                  child: CircularLoaderImage(),
                ),
              )
            : SafeArea(
              child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text("${ddd}")
                          // Padding(
                          //     padding: EdgeInsets.only(left: 4.0, top: 10.0),
                          //     child: Text(
                          //       "Financial activities through debits and credits ",
                          //       style: textStyle(colors.colorBlack, 14, FontWeight.w600),
                          //     )),
                          // Container(
                          //   width: screenWidth,
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //         color: theme.isDarkMode
                          //             ? const Color(0xffB5C0CF).withOpacity(.15)
                          //             : const Color(0xffF1F3F8)),
                          //     child: Column(
                          //       children: [
                          //         Padding(
                          //           padding: const EdgeInsets.all(16.0),
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               headingstat(
                          //                   "Total value",
                          //                   '${ledgerprovider.pledgeandunpledge?.stocksValue ?? 0}',
                          //                   theme,
                          //                   "left"),
                          //               headingstat(
                          //                   "Est/Ava Mrg",
                          //                   "${ledgerprovider.pledgeandunpledge?.estTotalAvailable ?? 0} / ${ledgerprovider.pledgeandunpledge?.marginTotalAvailable ?? 0} ",
                          //                   theme,
                          //                   "right"),
                          //             ],
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.only(
                          //               left: 16.0, right: 16.0, bottom: 16.0),
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               headingstat(
                          //                   "Cash Equivalent ",
                          //                   "${ledgerprovider.pledgeandunpledge?.cashEquivalent ?? 0}",
                          //                   theme,
                          //                   "left"),
                          //               headingstat(
                          //                   "Total/Pledged",
                          //                   "${ledgerprovider.pledgeandunpledge?.noOfStocks ?? 0} / ${displaypledgedvalue.length}",
                          //                   theme,
                          //                   "right"),
                          //             ],
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.only(
                          //               left: 16.0, right: 16.0, bottom: 16.0),
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               headingstat(
                          //                   "Cash Equivalent ",
                          //                   "${ledgerprovider.pledgeandunpledge?.noncashEquivalent ?? 0}",
                          //                   theme,
                          //                   "left"),
                          //               headingstat(
                          //                   "Non-approved",
                          //                   '${ledgerprovider.pledgeandunpledge?.noOfNonApprovedStocks ?? 0}',
                          //                   theme,
                          //                   "right"),
                          //             ],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    TextWidget.subText(
                                        text: 'Est Margin',
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 3),
                                    SizedBox(height: 5),
                                    TextWidget.headText(
                                        text: "${displayValue}",
                                        maxLines: 1,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textPrimaryLight,
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          RepaintBoundary(
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 10, bottom: 22),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            color: theme.isDarkMode
                                                ? colors.searchBgDark
                                                : colors.searchBg,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    if (!isSearching)
                                                      Material(
                                                        color:
                                                            Colors.transparent,
                                                        shape:
                                                            const CircleBorder(),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        child: InkWell(
                                                          customBorder:
                                                              const CircleBorder(),
                                                          splashColor: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .splashColorDark
                                                              : colors
                                                                  .splashColorLight,
                                                          highlightColor: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .highlightDark
                                                              : colors
                                                                  .highlightLight,
                                                          onTap: () {
                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        150),
                                                                () async {
                                                              _toggleSearch();
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: SvgPicture
                                                                .asset(
                                                              assets.searchIcon,
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .textSecondaryDark
                                                                  : colors
                                                                      .textSecondaryLight,
                                                              width: 20,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (isSearching)
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                              width: 4),
                                                          SvgPicture.asset(
                                                            assets.searchIcon,
                                                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                            width: 20,
                                                            fit: BoxFit
                                                                .scaleDown,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.6,
                                                            child: TextField(
                                                              controller:
                                                                  searchController,
                                                              focusNode:
                                                                  searchFocusNode,
                                                              onChanged:
                                                                  _onSearchChanged,
                                                              style: TextWidget
                                                                  .textStyle(
                                                                fontSize: 16,
                                                                color: theme.isDarkMode
                                                                    ? colors
                                                                        .textPrimaryDark
                                                                    : colors
                                                                        .textPrimaryLight,
                                                                theme: theme
                                                                    .isDarkMode,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    'Search...',
                                                                hintStyle:
                                                                    TextWidget
                                                                        .textStyle(
                                                                  fontSize: 14,
                                                                  theme: theme
                                                                      .isDarkMode,
                                                                  color: theme.isDarkMode
                                                                      ? colors
                                                                          .textSecondaryDark
                                                                      : colors
                                                                          .textSecondaryLight,
                                                                ),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          // if (searchController
                                                          //     .text.isNotEmpty)
                                                          //   Material(
                                                          //     color: Colors
                                                          //         .transparent,
                                                          //     shape:
                                                          //         const CircleBorder(),
                                                          //     clipBehavior:
                                                          //         Clip.hardEdge,
                                                          //     child: InkWell(
                                                          //       customBorder:
                                                          //           const CircleBorder(),
                                                          //       splashColor: theme
                                                          //               .isDarkMode
                                                          //           ? colors
                                                          //               .splashColorDark
                                                          //           : colors
                                                          //               .splashColorLight,
                                                          //       highlightColor: theme
                                                          //               .isDarkMode
                                                          //           ? colors
                                                          //               .highlightDark
                                                          //           : colors
                                                          //               .highlightLight,
                                                          //       onTap: () {
                                                          //         searchController
                                                          //             .clear();
                                                          //         _onSearchChanged(
                                                          //             '');
                                                          //       },
                                                          //       child: Padding(
                                                          //         padding:
                                                          //             const EdgeInsets
                                                          //                 .all(
                                                          //                 8.0),
                                                          //         child: Icon(
                                                          //           Icons.clear,
                                                          //           color: colors
                                                          //               .textPrimaryLight,
                                                          //           size: 16,
                                                          //         ),
                                                          //       ),
                                                          //     ),
                                                          //   ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  isSearching
                                                      ?
                                                      // if (hasHoldings && showEdis)
                                                      Row(
                                                          children: [
                                                            Material(
                                                              color: Colors
                                                                  .transparent,
                                                              shape:
                                                                  const CircleBorder(),
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              child: InkWell(
                                                                customBorder:
                                                                    const CircleBorder(),
                                                                splashColor: theme
                                                                        .isDarkMode
                                                                    ? colors
                                                                        .splashColorDark
                                                                    : colors
                                                                        .splashColorLight,
                                                                highlightColor: theme
                                                                        .isDarkMode
                                                                    ? colors
                                                                        .highlightDark
                                                                    : colors
                                                                        .highlightLight,
                                                                onTap:
                                                                    () async {
                                                                  Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              150),
                                                                      () {
                                                                    _toggleSearch();
                                                                  });
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: SvgPicture.asset(
                                                                      assets
                                                                          .removeIcon,
                                                                      fit: BoxFit
                                                                          .scaleDown,
                                                                      color: theme.isDarkMode
                                                                          ? colors
                                                                              .textSecondaryDark
                                                                          : colors
                                                                              .textSecondaryLight,
                                                                      width:
                                                                          20),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                          ],
                                                        )
                                                      : Material(
                                                          color: Colors
                                                              .transparent,
                                                          shape:
                                                              const RoundedRectangleBorder(),
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          child: InkWell(
                                                            customBorder:
                                                                const RoundedRectangleBorder(),
                                                            splashColor: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .splashColorDark
                                                                : colors
                                                                    .splashColorLight,
                                                            highlightColor: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .highlightDark
                                                                : colors
                                                                    .highlightLight,
                                                            onTap: () async {
                                                              ledgerprovider
                                                                  .fetchunpledgehistory(
                                                                      context);
                                                              ledgerprovider
                                                                  .fetchpledgehistory(
                                                                      context);
                                                              ledgerprovider
                                                                  .taxpnlExTabchange(
                                                                      0);
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  Routes
                                                                      .pledgehistorymainscreen,
                                                                  arguments:
                                                                      "DDDDD");
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          5),
                                                              child: TextWidget
                                                                  .subText(
                                                                text: "History",
                                                                theme: false,
                                                                color: theme.isDarkMode
                                                                    ? colors
                                                                        .secondaryDark
                                                                    : colors
                                                                        .secondaryLight,
                                                                fw: 2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //     top: 2.0,
                          //     bottom: 0.0,
                          //   ),
                          //   child: Divider(
                          //     color: theme.isDarkMode
                          //         ? const Color(0xffB5C0CF).withOpacity(.15)
                          //         : const Color(0xffF1F3F8),
                          //     thickness: 7.0,
                          //   ),
                          // ),
                    
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 30 , right: 30),
                          //   child: Row(
                          //     children: [
                          //       // Static Column
                          //       Column(
                          //         children: [
                          //           Container(
                          //             margin: EdgeInsets.only(top: 20),
                          //             width: 100,
                          //             color: Colors
                          //                 .cardbgrey, // Header cell for the static column
                          //             padding: EdgeInsets.all(8.0),
                          //             child: Text(
                          //               'Exchange',
                          //               style: TextStyle(fontWeight: FontWeight.bold),
                          //             ),
                          //           ),
                          //           for (var item in ledgerprovider.ledgerAllData!.fullStat!)
                          //             Container(
                          //               width: 100, // Fixed width for the static column
                          //               height: 50,
                    
                          //               padding: EdgeInsets.all(8.0),
                          //               decoration: BoxDecoration(
                          //                 border: Border.all(color: const Color.fromARGB(255, 224, 224, 224)),
                          //               ),
                          //               child: Text("${item.cOCD}",
                          //               style: textStyle(Colors.black, 14, FontWeight.w600),
                          //               ),
                          //             ),
                          //         ],
                          //       ),
                          //       // Scrollable Content
                    
                          //       Expanded(
                          //         child: SingleChildScrollView(
                          //           scrollDirection: Axis.horizontal,
                          //           child: Column(
                          //             children: [
                          //               // Header Row for the scrollable content
                          //               Row(
                          //                 children: [
                          //                   for (int i = 0; i < Header.length; i++)
                          //                     Container(
                          //                        margin: EdgeInsets.only(top: 20),
                          //                       width: i == 4 ? 275 : 100, // Column width
                    
                          //                       padding: EdgeInsets.all(8.0),
                          //                       color: Color(0xFFEEEEEE),
                          //                       child: Text(
                          //                         '${Header[i]}',
                          //                         style:
                          //                             TextStyle(fontWeight: FontWeight.bold),
                          //                       ),
                          //                     ),
                          //                 ],
                          //               ),
                          //               // Data Rows for the scrollable content
                          //               for (int rowIndex = 0;
                          //                   rowIndex <
                          //                       ledgerprovider
                          //                           .ledgerAllData!.fullStat!.length;
                          //                   rowIndex++)
                          //                 Row(
                          //                   children: [
                          //                     for (int colIndex = 0; colIndex < 5; colIndex++)
                          //                       Container(
                          //                          width: colIndex == 4 ? 275 : 100,  // Column width
                          //                         height: 50,
                          //                         padding: EdgeInsets.all(8.0),
                          //                         decoration: BoxDecoration(
                          //                           border: Border.all(color: Color.fromARGB(255, 224, 224, 224)),
                          //                         ),
                          //                         child: Text(colIndex == 0 ? dateFormatChangeForLedger(ledgerprovider
                          //                             .tablearray[rowIndex][colIndex]) : ledgerprovider
                          //                             .tablearray[rowIndex][colIndex] ,
                          //                             textAlign: colIndex == 1 ||colIndex == 2 || colIndex == 3  ? TextAlign.right : TextAlign.start ,
                          //                             ) ,
                          //                         //  child: Text(  ledgerprovider
                          //                         //     .tablearray[rowIndex][colIndex] ) ,
                          //                       ),
                          //                   ],
                          //                 ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            height: 35,
                            // decoration: BoxDecoration(
                            //   border: Border(
                            //     bottom: BorderSide(
                            //       color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                            //       width: 1,
                            //     ),
                            //   ),
                            // ),
                            child: TabBar(
                              onTap: (int index) {
                                print("Tab tapped: $index");
                                activeTab = index;
                                // Do something on tap
                              },
                              controller: tabController,
                              tabAlignment: TabAlignment.start,
                              isScrollable: true,
                              indicatorSize: TabBarIndicatorSize.label,
                              indicatorColor:
                                  colors.colorWhite, // hide default underline
                              indicator: BoxDecoration(
                                // pill-shaped highlight[4]
                               color: theme.isDarkMode ? colors.searchBgDark : const Color(0xffF1F3F8),
                          borderRadius: BorderRadius.circular(5),
                                // border: Border.all(
                                //   color: theme.isDarkMode
                                //       ? colors.darkColorDivider
                                //       : colors.colorDivider,
                                // ),
                              ),
                              // labelColor: theme.isDarkMode
                              //     ? colors.colorLightBlue
                              //     : colors.colorBlue,
                              unselectedLabelColor: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        labelStyle: TextWidget.textStyle(
                            fontSize: 14, theme: false, fw: 1, color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
                        unselectedLabelStyle: TextWidget.textStyle(
                            fontSize: 14,
                            theme: false,
                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                            fw: 0,
                            letterSpacing: -0.28),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    
                    
                              // build the "Open 4" badge and the rest of the tabs
                              tabs: orderTabName.map((tabString) {
                                /// If the value looks like "Open 4", split it once on the space
                    
                                final title =
                                    tabString.text.toString(); // "Open"
                    
                                return Tab(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 0, bottom: 0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextWidget.paraText(
                                            text: "${title}",
                                            theme: false,
                                          color :  theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                            
                                            fw: 3),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                              child: TabBarView(
                                  controller: tabController,
                                  children: [
                                PledgeFilter(
                                    activetabe: '0', searchQuery: searchQuery),
                                PledgeFilter(
                                    activetabe: '1', searchQuery: searchQuery),
                                PledgeFilter(
                                    activetabe: '2', searchQuery: searchQuery),
                                // OrderBook(orderBook: orderBook.allOrder!),
                              ])),
                    
                          if (ledgerprovider.listforpledge.length > 0)
                            Container(
                              height: screenheight * 0.07,
                              decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8)),
                            ),
                        ],
                      ),
                      if (ledgerprovider.listforpledge.length > 0)
                        Positioned(
                          bottom: 1,
                          left: 1,
                          right: 1,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: TextWidget.subText(
                                        text:
                                            "You ${ledgerprovider.listforpledge.length} Script For ${ledgerprovider.pledgeoruppledgedelete == 'unpledgedelete' ? 'Delete' : ledgerprovider.screenpledge == 'pledge' ? "Pledge" : "Unpledge"}",
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 3),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Container(
                                            height: 35,
                                            width: 75,
                                            margin: const EdgeInsets.only(
                                                right: 12, top: 15),
                                            child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                    side: BorderSide(
                                                      color: theme.isDarkMode
                                                          ? colors.primaryDark
                                                          : colors.primaryLight,
                                                    ),
                                                    elevation: 0,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                onPressed: () {
                                                  ledgerprovider
                                                      .cancelpledgetotal(
                                                          ledgerprovider
                                                              .screenpledge);
                                                  ledgerprovider
                                                      .changesegvaldummy('');
                                                  // ledgerprovider.screenclickedpledge = '';
                                                },
                                                child: Text("Cancel",
                                                    textAlign: TextAlign.center,
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.primaryDark
                                                            : colors
                                                                .primaryLight,
                                                        12,
                                                        FontWeight.w500)))),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Container(
                                            height: 35,
                                            width: 75,
                                            margin: const EdgeInsets.only(
                                                right: 12, top: 15),
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    backgroundColor: theme
                                                            .isDarkMode
                                                        ? colors.primaryDark
                                                        : colors.primaryLight,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                onPressed: () {
                                                  ledgerprovider
                                                      .changesegvaldummy('');
                                                  print(
                                                      "${ledgerprovider.pledgeoruppledgedelete} ${ledgerprovider.pledgeorunpledge == 'unpledge'} loakdsdejkvh ");
                                                  if (ledgerprovider
                                                          .pledgeoruppledgedelete ==
                                                      'unpledgedelete') {
                                                    print("loakdsdejkvh");
                                                    ledgerprovider
                                                        .unpldgedeletefun(
                                                            context,
                                                            ledgerprovider
                                                                .pledgeandunpledge!
                                                                .cLIENTCODE
                                                                .toString(),
                                                            ledgerprovider
                                                                .listforpledge);
                                                  } else {
                                                    if (ledgerprovider
                                                            .pledgeorunpledge ==
                                                        'unpledge') {
                                                      ledgerprovider.sendunpledgerequest(
                                                          context,
                                                          ledgerprovider
                                                              .pledgeandunpledge!
                                                              .cLIENTCODE
                                                              .toString(),
                                                          ledgerprovider
                                                              .pledgeandunpledge!
                                                              .bOID
                                                              .toString(),
                                                          ledgerprovider
                                                              .pledgeandunpledge!
                                                              .cLIENTNAME
                                                              .toString(),
                                                          ledgerprovider
                                                              .listforpledge);
                                                    } else if (ledgerprovider
                                                            .pledgeorunpledge ==
                                                        'pledge') {
                                                      _showBottomSheet(context,
                                                          PledgeList());
                                                    }
                                                  }
                                                },
                                                child: Text("Submit",
                                                    textAlign: TextAlign.center,
                                                    style: textStyle(
                                                        !theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        12,
                                                        FontWeight.w500)))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ),
      );
    });
  }

  _mainpage(
      LDProvider ledgerprovider, ThemesProvider theme, BuildContext context) {
    return ledgerprovider.pledgeandunpledge == null ||
            ledgerprovider.pledgeandunpledge?.data == null
        // Handle the null or empty case
        ? Center(
            child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: NoDataFound(),
          ))
        : Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ListView.separated(
                  physics: ScrollPhysics(),
                  itemCount:
                      ledgerprovider.pledgeandunpledge?.data?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final value =
                        ledgerprovider.pledgeandunpledge!.data![index];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.55,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget.subText(
                                            align: TextAlign.start,
                                            text: value.nSESYMBOL ?? '-',
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            fw: 3),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        value.status == "Not_ok"
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                    right: 4),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                    color: const Color.fromARGB(
                                                            255, 236, 214, 214)
                                                        .withOpacity(.3)),
                                                child: Text("Un-Approved",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: textStyle(
                                                        const Color.fromARGB(
                                                            255, 255, 60, 60),
                                                        10,
                                                        FontWeight.w500)),
                                              )
                                            : SizedBox(),
                                        ((((value.cashEqColl!.foCashEq != null
                                                            ? value.cashEqColl!
                                                                    .foCashEq ==
                                                                'True'
                                                            : true) &&
                                                        (value.cashEqColl!.cdCashEq != null
                                                            ? value.cashEqColl!
                                                                    .cdCashEq ==
                                                                'True'
                                                            : true) &&
                                                        (value.cashEqColl!.comCashEq !=
                                                                null
                                                            ? value.cashEqColl!
                                                                    .comCashEq ==
                                                                'True'
                                                            : true)) &&
                                                    value.cOLQTY != '0.000') ||
                                                (((value.cashEqColl!.foCashEq !=
                                                                null
                                                            ? value.cashEqColl!
                                                                    .foCashEq ==
                                                                'False'
                                                            : true) &&
                                                        (value.cashEqColl!.cdCashEq != null
                                                            ? value.cashEqColl!
                                                                    .cdCashEq ==
                                                                'False'
                                                            : true) &&
                                                        (value.cashEqColl!
                                                                    .comCashEq !=
                                                                null
                                                            ? value.cashEqColl!
                                                                    .comCashEq ==
                                                                'False'
                                                            : true)) &&
                                                    value.cOLQTY != '0.000'))
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                    right: 4),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(10),
                                                    color:
                                                        value.cRnc == 'noncash'
                                                            ? const Color(
                                                                0xff007B7B)
                                                            : const Color(
                                                                0xff2069BB)),
                                                child: Text(
                                                    ((value.cashEqColl!
                                                                        .foCashEq !=
                                                                    null
                                                                ? value.cashEqColl!
                                                                        .foCashEq ==
                                                                    'True'
                                                                : true) &&
                                                            (value.cashEqColl!.cdCashEq != null
                                                                ? value.cashEqColl!.cdCashEq ==
                                                                    'True'
                                                                : true) &&
                                                            (value.cashEqColl!.comCashEq != null
                                                                ? value.cashEqColl!.comCashEq ==
                                                                    'True'
                                                                : true))
                                                        ? 'Cash'
                                                        : 'Non Cash',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: textStyle(
                                                        const Color.fromARGB(
                                                            255, 255, 255, 255),
                                                        10,
                                                        FontWeight.w500)),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              value.initiated == "0" &&
                                      value.status == 'Ok' &&
                                      (double.parse(value.nSOHQTY.toString())
                                                  .toInt()) +
                                              (double.parse(
                                                      value.sOHQTY.toString())
                                                  .toInt()) !=
                                          0
                                  ? InkWell(
                                      onTap: () {
                                        print(
                                            "${ledgerprovider.pledgeorunpledge} fdaedfaefwef");
                                        if (ledgerprovider.pledgeorunpledge !=
                                            'unpledge') {
                                          print(double.parse(
                                                  value.initiated.toString())
                                              .toInt());
                                          if (double.parse(value.initiated
                                                      .toString())
                                                  .toInt() ==
                                              0) {
                                            ledgerprovider.screenclickedpledge =
                                                'pledge';
                                            String val =
                                                "${double.parse(value.nSOHQTY.toString()).toInt() + double.parse(value.sOHQTY.toString()).toInt()}";
                                            String val2 =
                                                "${value.dummvalue != 'null' ? double.parse(value.dummvalue.toString()).toInt() : "null"}";
                                            ledgerprovider.setselectnetpledge(
                                                val2 == 'null' ? val : val2,
                                                val2 == 'null' ? val : val2);
                                            _showBottomSheet(
                                                context,
                                                PledgeDeytails(
                                                  data: index,
                                                ));
                                          } else {
                                            showResponsiveWarningMessage(context,
                                                  '${value.initiated} Qty is processing');
                                          }
                                        } else {
                                          showResponsiveWarningMessage(context,
                                                'Unpledged initiated so can\'t pledge');
                                        }
                                        // ledgerprovider
                                        //     .changesegval("");
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(right: 16),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextWidget.titleText(
                                            text:
                                                "${value.dummvalue != 'null' ? "${value.dummvalue!} /" : ''} ${(double.parse(value.nSOHQTY.toString()).toInt()) + (double.parse(value.sOHQTY.toString()).toInt())} +",
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            color: value.dummvalue == 'null'
                                                ? const Color(0xff2F6AD9)
                                                : const Color(0xffFFC107),
                                            fw: 3,
                                          ),
                                        ),
                                      ),
                                    )
                                  : int.tryParse(value.initiated.toString()) !=
                                              0 &&
                                          value.status == 'Ok' &&
                                          (double.parse(value.nSOHQTY
                                                          .toString())
                                                      .toInt()) +
                                                  (double.parse(value.sOHQTY
                                                          .toString())
                                                      .toInt()) !=
                                              0
                                      ? Container(
                                          margin:
                                              const EdgeInsets.only(right: 16),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: const Color.fromARGB(
                                                  255, 216, 226, 248)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextWidget.subText(
                                              text:
                                                  "${(double.parse(value.nSOHQTY.toString()).toInt()) + (double.parse(value.sOHQTY.toString()).toInt())} / ${value.initiated} +",
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              color: const Color.fromARGB(
                                                  255, 162, 191, 247),
                                              fw: 1,
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      TextWidget.paraText(
                                          text: (double.parse(value.cOLQTY
                                                          .toString())
                                                      .toInt()) ==
                                                  0
                                              ? 'Est : '
                                              : "Mrg : ",
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 3),
                                      TextWidget.paraText(
                                          text: (double.parse(value.cOLQTY
                                                          .toString())
                                                      .toInt()) ==
                                                  0
                                              ? value.estimated != null
                                                  ? "${double.parse(value.estimated.toString()).toStringAsFixed(2)} "
                                                  : "0.0"
                                              : value.margin != null
                                                  ? "${double.parse(value.margin.toString()).toStringAsFixed(2)} "
                                                  : "0.0",
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 3),
                                      TextWidget.paraText(
                                          text: value.estimated != null
                                              ? "(${double.parse(value.estPercentage.toString()).toInt()}%)"
                                              : "0.0",
                                          color: theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 3),
                                    ],
                                  ),
                                ],
                              ),
                              (double.parse(value.cOLQTY.toString()).toInt()) !=
                                      0
                                  ? Row(
                                      children: [
                                        TextWidget.subText(
                                            text: "Pledged Qty : ",
                                            color: Color(0xFF696969),
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 0),
                                        (double.parse(value.cOLQTY.toString())
                                                    .toInt()) !=
                                                0
                                            ? InkWell(
                                                onTap: () {
                                                  print(
                                                      "${ledgerprovider.pledgeorunpledge} fdaedfaefwef");
                                                  if (value.deleteselected !=
                                                          'selected' &&
                                                      value.unPlegeQty == '') {
                                                    if (ledgerprovider
                                                            .pledgeorunpledge !=
                                                        'pledge') {
                                                      ledgerprovider
                                                              .screenclickedpledge =
                                                          'unpledge';
                                                      String val =
                                                          "${double.parse(value.cOLQTY.toString()).toInt()}";
                                                      String val2 =
                                                          "${value.dummunpledgevalue != 'null' ? double.parse(value.dummunpledgevalue.toString()).toInt() : "null"}";
                                                      ledgerprovider
                                                          .setselectnetpledge(
                                                              val2 == 'null'
                                                                  ? val
                                                                  : val2,
                                                              val2 == 'null'
                                                                  ? val
                                                                  : val2);
                                                      _showBottomSheet(
                                                          context,
                                                          PledgeDeytails(
                                                            data: index,
                                                          ));
                                                      // ledgerprovider
                                                      //     .setselectnetpledge(
                                                      //         "${(double.parse(value.cOLQTY.toString()).toInt())}",
                                                      //         "${(double.parse(value.cOLQTY.toString()).toInt())}");
                                                    } else {
                                                      showResponsiveWarningMessage(context,
                                                            'Pledged initiated so can\'t unpledge');
                                                    }
                                                  } else {
                                                    showResponsiveWarningMessage(context,
                                                          'Already pledged cant edit');
                                                  }

                                                  print(
                                                      "value.cOLQTY.toString() ${value.cOLQTY.toString()}");
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: value.dummunpledgevalue !=
                                                                  'null' ||
                                                              value.deleteselected ==
                                                                  'selected'
                                                          ? const Color(
                                                              0xffF6EFD9)
                                                          : const Color
                                                              .fromARGB(255,
                                                              255, 196, 196)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextWidget.paraText(
                                                      text:
                                                          "${(value.unPlegeQty != "0" && value.unPlegeQty != "") ? "${value.unPlegeQty! + " /"} " : value.dummunpledgevalue != 'null' ? "${value.dummunpledgevalue!} /" : ''} ${(double.parse(value.cOLQTY.toString()).toInt())} -",
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      color: value.dummunpledgevalue !=
                                                                  'null' ||
                                                              value.deleteselected ==
                                                                  'selected'
                                                          ? const Color(
                                                              0xffFFC107)
                                                          : const Color
                                                              .fromARGB(
                                                              255, 255, 97, 97),
                                                      fw: 1,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Text("-"),
                                        if ((value.unPlegeQty != "0" &&
                                            value.unPlegeQty != ""))
                                          InkWell(
                                            onTap: () {
                                              ledgerprovider
                                                  .unpledgedeletereqfun(
                                                      context,
                                                      value.iSIN.toString(),
                                                      index);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: SvgPicture.asset(
                                                  assets.cancelledIcon),
                                            ),
                                          )
                                        // TextWidget.subText(
                                        //     text:
                                        //         "${(double.parse(value.cOLQTY.toString()).toInt()) > 0 ? (double.parse(value.cOLQTY.toString()).toInt()) : ''} ",
                                        //     color: theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     textOverflow:
                                        //         TextOverflow.ellipsis,
                                        //     theme: theme.isDarkMode,
                                        //     fw: 1),

                                        //         Text(
                                        // " (${value.tRADEDATE})",
                                        // style: textStyle(
                                        //     theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     12,
                                        //     FontWeight.w600)),
                                      ],
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 6.0,
                        bottom: 0.0,
                      ),
                      child: Divider(
                        color: theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffF1F3F8),
                        thickness: 1.0,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
  }

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: bottomSheet));
  }

  int getDisplayQty(dynamic value) {
    final unPledge = int.tryParse(value.unPlegeQty.toString()) ?? 0;
    final nsoh = int.tryParse(value.nSOHQTY.toString()) ?? 0;
    final soh = int.tryParse(value.sOHQTY.toString()) ?? 0;

    if (unPledge > 0) return unPledge;
    if (nsoh > 0) return nsoh;
    if (soh > 0) return soh;

    return 0;
  }

  headingstat(String heading, String value, theme, String side) {
    return Column(
      crossAxisAlignment:
          side == 'right' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
            text: heading,
            color: Color(0xFF696969),
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0),
        // Text(
        //   "Opening Balance",
        //   style: textStyle(Color(0xFF696969), 14,
        //       FontWeight.w500),
        // ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextWidget.titleText(
              text: "₹ $value",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 1),
        ),
      ],
    );
  }
}
