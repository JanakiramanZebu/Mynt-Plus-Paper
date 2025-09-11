import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/stocks/explore/stocks/news/news_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

import '../../../../locator/locator.dart';
import '../../../../locator/preference.dart';
import '../../../../provider/fund_provider.dart';
import '../../../../provider/index_list_provider.dart';
import '../../../../provider/ledger_provider.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/stocks_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../market_watch/index/index_screen.dart';
import '../explore_caevents.dart';
import '../explore_liveIPO.dart';
import 'indices/top_indices.dart';
import 'trade_action/trade_action_widget.dart';
import 'etf_category_detail_screen.dart';
// import 'news/news_screen.dart';
// import 'stock_monitor/stock_monitor_screen.dart';
// import 'trade_action/corporate_action.dart';
// import 'trade_action/trade_action_widget.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    // Fetch portfolio data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPortfolioData();
    });
    _tabController = TabController(length: 1, vsync: this);
  }

  Future<void> _fetchPortfolioData() async {
    try {
      await Future.wait([
        ref.read(portfolioProvider).fetchHoldings(context, ""),
        ref.read(portfolioProvider).fetchPositionBook(context, false),
      ]);

      ref
          .read(portfolioProvider)
          .requestWSHoldings(context: context, isSubscribe: true);
      ref
          .read(portfolioProvider)
          .requestWSPosition(context: context, isSubscribe: true);

      ref.read(portfolioProvider).timerfunc();

      await ref.read(stocksProvide).chngTradeAct("init");
      ref
          .read(stocksProvide)
          .requestWSTradeaction(isSubscribe: true, context: context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final funds = ref.watch(fundProvider);
    final portfolio = ref.watch(portfolioProvider);
    final indexList = ref.watch(indexListProvider);
    final ledgerdate = ref.watch(ledgerProvider);
    final trancation = ref.watch(transcationProvider);

    final Preferences pref = locator<Preferences>();
    final String reflink = "https://oa.mynt.in/?ref=${pref.clientId}";

    double totalCurrentVal = portfolio.totalPnlHolding;
    double cash = totalCurrentVal +
        (double.tryParse(funds.fundDetailModel?.cash?.toString() ?? "0") ??
            0.0);
    // double _invest = double.parse("${portfolio.holdingsModel?.first.invested ?? 0.0}");
    String _totalPnlHolding = "${portfolio.totInvesHold ?? 0.0}";
    String _totalCurrentVal = "${portfolio.totalCurrentVal ?? 0.0}";
    // String _totPnlPercHolding = _invest > 0
    //       ? ((_totalPnlHolding / _invest) * 100).toStringAsFixed(2)
    //       : "0.00";
    final items = [
      {
        'label': 'P&L Summary',
        'icon': assets.plsummary,
        'subtitle': 'Insights for sharper decisions'
      },
      {
        'label': 'Ledger',
        'icon': assets.ledger,
        'subtitle': 'Seamless tracking of every transaction'
      },
      {
        'label': 'F&O Margin Calculator',
        'icon': assets.margincal,
        'subtitle': 'Optimize leverage with precision'
      },
      {
        'label': 'Brokerage Calculator',
        'icon': assets.brokercal,
        'subtitle': 'Transparent costs'
      },
    ];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Consumer(builder: (context, ref, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const TopIndices(),

              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16),
              //   child: Column(
              //     children: [
              //       // Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       TextWidget.titleText(
              //       //         text: "Live IPOs",
              //       //         theme: false,
              //       //         color: theme.isDarkMode
              //       //             ? colors.textPrimaryDark
              //       //             : colors.textPrimaryLight,
              //       //         fw: 1,
              //       //       ),
              //       //       // TextButton(
              //       //       //     onPressed: () {
              //       //       //       Navigator.pushNamed(context, Routes.ipo);
              //       //       //     },
              //       //       //     child: const Text('See all',
              //       //       //         style: TextStyle(
              //       //       //             color: Color(0xff0037B7),
              //       //       //             fontSize: 14,
              //       //       //             fontWeight: FontWeight.w600)))
              //       //     ]),
              //       LiveIPOList(),
              //     ],
              //   ),
              // ),
              // const SizedBox(
              //   height: 16,
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 12, top: 0, bottom: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? colors.darkGrey
                                      : const Color(0xffF1F3F8),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    "assets/icon/briefcase.svg",
                                    width: 14,
                                    height: 14,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.primaryLight,
                                  ),
                                )),
                            const SizedBox(width: 12),
                            TextWidget.subText(
                              text: "Stocks Portfolio",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              fw: 0,
                            ),
                          ],
                        ),
                        // const SizedBox(width: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              canRequestFocus: false,
                              onTap: () async {
                                Future.delayed(
                                    const Duration(milliseconds: 150), () {
                                  trancation.changebool(true);
                                  Navigator.pushNamed(
                                      context, Routes.fundscreen,
                                      arguments: trancation);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: TextWidget.subText(
                                  text: "Add Money",
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight,
                                  fw: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // if (portfolio.holdingsModel != null &&
                  //             portfolio.holdingsModel!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      shape: const RoundedRectangleBorder(),
                      child: InkWell(
                        canRequestFocus: false,
                        customBorder: const RoundedRectangleBorder(),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.highlightDark
                            : colors.highlightLight,
                        onTap: () {
                          indexList.bottomMenu(2, context);
                          portfolio.changeTabIndex(0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? colors.colorBlack
                                : colors.searchBg,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextWidget.subText(
                                    text: "P&L",
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    fw: 0,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextWidget.titleText(
                                        text:
                                            "${getFormatter(value: totalCurrentVal, v4d: false, noDecimal: false)} ",
                                        theme: false,
                                        color: totalCurrentVal
                                                .toString()
                                                .startsWith("-")
                                            ? theme.isDarkMode
                                                ? colors.lossDark
                                                : colors.lossLight
                                            : theme.isDarkMode
                                                ? colors.successDark
                                                : colors.successLight,
                                        fw: 0,
                                      ),
                                      TextWidget.paraText(
                                        text:
                                            "(${portfolio.totPnlPercHolding == "NaN" ? 0.00 : portfolio.totPnlPercHolding}%)",
                                        theme: false,
                                        color: portfolio.totPnlPercHolding
                                                .toString()
                                                .startsWith("-")
                                            ? theme.isDarkMode
                                                ? colors.lossDark
                                                : colors.lossLight
                                            : theme.isDarkMode
                                                ? colors.successDark
                                                : colors.successLight,
                                        fw: 0,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextWidget.subText(
                                        text: "Invested ",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 0,
                                      ),
                                      TextWidget.paraText(
                                        text: formatAmountCompact(
                                            double.parse(_totalPnlHolding)),
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        fw: 0,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextWidget.subText(
                                        text: "Current ",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 0,
                                      ),
                                      TextWidget.paraText(
                                        text: formatAmountCompact(
                                            double.parse(_totalCurrentVal)),
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        fw: 0,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    margin: const EdgeInsets.only(top: 4),
                    child: Material(
                      color: Colors.transparent,
                      shape: const RoundedRectangleBorder(),
                      child: InkWell(
                        // canRequestFocus: false,
                        customBorder: const RoundedRectangleBorder(),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.highlightDark
                            : colors.highlightLight,
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.pushNamed(
                                context, Routes.portfolioDashboard);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextWidget.subText(
                                text: "Portfolio insights",
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.primaryDark
                                    : colors.primaryLight,
                                fw: 2,
                              ),
                              const SizedBox(width: 6),
                              SvgPicture.asset(
                                assets.leftArrow,
                                // width: 12,
                                // height: 12,
                                color: theme.isDarkMode
                                    ? colors.primaryDark
                                    : colors.primaryDark,
                                    fit: BoxFit.scaleDown,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Center(
                  //   child: ElevatedButton(
                  //     onPressed: () async {},
                  //     style: ElevatedButton.styleFrom(
                  //       padding: const EdgeInsets.symmetric(vertical: 8),
                  //       backgroundColor: Colors.white,
                  //       elevation: 0,
                  //       // side: const BorderSide(
                  //       //     color: Color(0xFF87A1DD), width: 1.5),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(24),
                  //       ),
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.max,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         SvgPicture.asset(
                  //           'assets/explore/firefox.svg',
                  //           width: 16,
                  //           height: 16,
                  //         ),
                  //         const SizedBox(width: 8),
                  //         const Text(
                  //           "View my portfolio",
                  //           style: TextStyle(
                  //               color: Color(0xFF4069C9),
                  //               fontWeight: FontWeight.w600,
                  //               fontSize: 14),
                  //         ),
                  //         const Icon(
                  //           Icons.expand_more,
                  //           color: Color(0xFF4069C9),
                  //           size: 28,
                  //           weight: 7,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              optionZTile(context, theme, funds),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 16),

                    // ETF Collections Section
                    Container(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      height: 35,
                      child: TabBar(
                        controller: _tabController,
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: colors.colorWhite,
                        indicator: BoxDecoration(
                          color: theme.isDarkMode
                              ? colors.searchBgDark
                              : const Color(0xffF1F3F8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        unselectedLabelColor: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        labelStyle: TextWidget.textStyle(
                            fontSize: 14,
                            theme: false,
                            fw: 2,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight),
                        unselectedLabelStyle: TextWidget.textStyle(
                            fontSize: 14,
                            theme: false,
                            fw: 3,
                            color: colors.textSecondaryLight),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        // onTap: (index) {
                        //   if (index == 0) {
                        //     Navigator.pushNamed(context, Routes.algoList);
                        //   }
                        // },
                        tabs: const [
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              child: Text("ETF Collections"),
                            ),
                          ),
                          // Tab(
                          //   child: Padding(
                          //     padding: EdgeInsets.only(
                          //         left: 10, right: 10, top: 0, bottom: 0),
                          //     child: Text("Stock Scanner"),
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    // Tab Bar View
                    SizedBox(
                      height: 450,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          buildETFCollectionsTab(theme),
                          // buildStockScannerTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 16),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Expanded(
              //         child: Container(
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(5),
              //             border: Border.all(
              //               color: theme.isDarkMode
              //                   ? colors.dividerDark
              //                   : colors.dividerLight,
              //             ),
              //           ),
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 16, vertical: 12),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Row(
              //                   crossAxisAlignment: CrossAxisAlignment.end,
              //                   children: [
              //                     TextWidget.custmText(
              //                         text: "5x",
              //                         fs: 32,
              //                         theme: theme.isDarkMode,
              //                         fw: 0,
              //                         color: theme.isDarkMode
              //                             ? colors.primaryDark
              //                             : colors.primaryLight),
              //                     Padding(
              //                       padding: const EdgeInsets.only(bottom: 2),
              //                       child: TextWidget.headText(
              //                           text: " - MTF",
              //                           theme: theme.isDarkMode,
              //                           fw: 0,
              //                           color: theme.isDarkMode
              //                               ? colors.primaryDark
              //                               : colors.primaryLight),
              //                     ),
              //                   ],
              //                 ),
              //                 const SizedBox(height: 6),
              //                 TextWidget.subText(
              //                     text: "Extra buying power",
              //                     theme: theme.isDarkMode,
              //                     fw: 3,
              //                     color: theme.isDarkMode
              //                         ? colors.textPrimaryDark
              //                         : colors.textPrimaryLight),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(width: 16),
              //       Expanded(
              //         child: Container(
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(5),
              //             border: Border.all(
              //               color: theme.isDarkMode
              //                   ? colors.dividerDark
              //                   : colors.dividerLight,
              //             ),
              //           ),
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 16, vertical: 12),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Row(
              //                   crossAxisAlignment: CrossAxisAlignment.end,
              //                   children: [
              //                     TextWidget.custmText(
              //                         text: "92",
              //                         fs: 32,
              //                         theme: theme.isDarkMode,
              //                         fw: 0,
              //                         color: theme.isDarkMode
              //                             ? colors.primaryDark
              //                             : colors.primaryLight),
              //                     Padding(
              //                       padding: const EdgeInsets.only(bottom: 2),
              //                       child: TextWidget.custmText(
              //                           text: "%",
              //                           theme: theme.isDarkMode,
              //                           fw: 0,
              //                           fs: 24,
              //                           color: theme.isDarkMode
              //                               ? colors.primaryDark
              //                               : colors.primaryLight),
              //                     ),
              //                   ],
              //                 ),
              //                 const SizedBox(height: 6),
              //                 TextWidget.subText(
              //                     text: "Benefit of Pledge",
              //                     theme: theme.isDarkMode,
              //                     fw: 3,
              //                     color: theme.isDarkMode
              //                         ? colors.textPrimaryDark
              //                         : colors.textPrimaryLight),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // const SizedBox(height: 16),
              const SizedBox(
                height: 380,
                child: TradeAction(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(),
                  child: InkWell(
                    canRequestFocus: false,
                    customBorder: const RoundedRectangleBorder(),
                    splashColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    highlightColor: theme.isDarkMode
                        ? colors.highlightDark
                        : colors.highlightLight,
                    onTap: () async {
                      await Share.share(
                        "I invite you to explore Mynt by Zebu — from Stocks to Mutual funds and more.\nOpen your free demat account today\n👉 ${Uri.parse(reflink)}",
                      );
                    },
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: theme.isDarkMode
                              ? colors.searchBgDark.withOpacity(0.5)
                              : const Color(0xffF1F3F8).withOpacity(0.5),
                          border: Border.all(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TextWidget.custmText(
                                //     text: "₹300",
                                //     theme: false,
                                //     color: theme.isDarkMode
                                //         ? colors.primaryDark
                                //         : colors.primaryLight,
                                //     fw: 0,
                                //     fs: 20),
                                // const SizedBox(height: 4),
                                TextWidget.custmText(
                                    text: "Refer",
                                    theme: false,
                                     color: theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight,
                                        fs: 20,
                                    fw: 0),
                                const SizedBox(height: 4),
                                TextWidget.paraText(
                                    text:
                                        // "Rewarding you for spreading the word",
                                        "Invite your friends to Mynt by Zebu",
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    fw: 0),
                              ],
                            ),
                            // const SizedBox(width: 16),
                            SvgPicture.asset(assets.referandearn,
                                width: 50, height: 50, fit: BoxFit.contain),
                          ],
                        )),
                  ),
                ),
              ),
             
              const SizedBox(height: 16),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          canRequestFocus: false,
                          onTap: () {
                            Navigator.pushNamed(context, Routes.basketScreen);
                            // Navigator.pushNamed(context, Routes.portfolioDashboard);
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, top: 6, bottom: 6),
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? colors.searchBgDark
                                  : const Color(0xffF1F3F8),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextWidget.subText(
                              text: "Quick Access",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap:
                              true, // Important if this is inside another scrollable widget
                          physics:
                              const NeverScrollableScrollPhysics(), // Optional: disable scrolling if needed
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return redesignedActionCard(
                              icon: item['icon'] as String,
                              label: item['label'] as String,
                              subtitle: item['subtitle'] as String,
                              theme: theme,
                              onTap: () async {
                                switch (item['label']) {
                                  case 'P&L Summary':
                                    await ledgerdate.getCurrentDate('pandu');
                                    Navigator.pushNamed(
                                        context, Routes.calenderpnlScreen,
                                        arguments: "DDDDD");
                                    break;
                                  case 'Ledger':
                                    await ledgerdate.getCurrentDate('else');
                                    Navigator.pushNamed(
                                        context, Routes.ledgerscreen,
                                        arguments: "DDDDD");
                                    break;
                                  case 'F&O Margin Calculator':
                                    Navigator.pushNamed(
                                        context, Routes.marginCalculator);
                                    break;
                                  case 'Brokerage Calculator':
                                    Navigator.pushNamed(
                                        context, Routes.brokerCalculator);
                                    break;
                                }
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider(
                              color: theme.isDarkMode
                                  ? colors.dividerDark
                                  : colors.dividerLight,
                            ); // Simple spacing separator
                          },
                        ),
                        Divider(
                          color: theme.isDarkMode
                              ? colors.dividerDark
                              : colors.dividerLight,
                          height: 1,
                        )
                      ])),
              // const SizedBox(height: 16),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               TextWidget.subText(
              //                 text: "New",
              //                 theme: false,
              //                 color: theme.isDarkMode
              //                     ? colors.textSecondaryDark
              //                     : colors.textSecondaryLight,
              //                 fw: 3,
              //               ),
              //               const SizedBox(height: 4),
              //               TextWidget.titleText(
              //                 text: "OptionZ",
              //                 theme: false,
              //                 color: theme.isDarkMode
              //                     ? colors.textPrimaryDark
              //                     : colors.textPrimaryLight,
              //                 fw: 1,
              //               ),
              //               const SizedBox(height: 4),
              //               SizedBox(
              //                 width: MediaQuery.of(context).size.width * 0.6,
              //                 child: TextWidget.subText(
              //                     text:
              //                         "Explore the world of options trading with our new platform. Trade options with ease and confidence.",
              //                     theme: false,
              //                     color: theme.isDarkMode
              //                         ? colors.textSecondaryDark
              //                         : colors.textSecondaryLight,
              //                     fw: 3,
              //                     softWrap: true,
              //                     maxLines: 4,
              //                     letterSpacing: 0.8,
              //                     lineHeight: 1.5),
              //               ),
              //               const SizedBox(height: 10),
              //               Material(
              //                 color: Colors.transparent,
              //                 shape: const RoundedRectangleBorder(),
              //                 child: InkWell(
              //                   splashColor: theme.isDarkMode
              //                       ? colors.splashColorDark
              //                       : colors.splashColorLight,
              //                   highlightColor: theme.isDarkMode
              //                       ? colors.highlightDark
              //                       : colors.highlightLight,
              //                   customBorder: const RoundedRectangleBorder(),
              //                   onTap: () {
              //                     Future.delayed(
              //                         const Duration(milliseconds: 150),
              //                         () async {
              //                       await funds.fetchHstoken(context);
              //                       funds.optionZ(context);
              //                     });
              //                   },
              //                   child: Container(
              //                     padding: const EdgeInsets.symmetric(
              //                         horizontal: 16, vertical: 8),
              //                     decoration: BoxDecoration(
              //                       color: colors.btnBg,
              //                       borderRadius: BorderRadius.circular(16),
              //                     ),
              //                     child: TextWidget.subText(
              //                         text: "Explore",
              //                         theme: false,
              //                         color: theme.isDarkMode
              //                             ? colors.textPrimaryDark
              //                             : colors.textPrimaryLight,
              //                         fw: 3),
              //                   ),
              //                 ),
              //               )
              //             ],
              //           ),
              //           SizedBox(
              //             width: MediaQuery.of(context).size.width * 0.3,
              //             child: Image.asset(
              //               assets.optionZdash,
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // const NewsScreen(),
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       TextWidget.subText(
              //         text: "Funds & Margin",
              //         theme: false,
              //         color: theme.isDarkMode
              //             ? colors.textPrimaryDark
              //             : colors.textPrimaryLight,
              //         fw: 3,
              //       ),
              //       const SizedBox(height: 8),
              //       TextWidget.titleText(
              //           text:
              //               "Avail ${formatCurrencyStandard(value: double.parse("${funds.fundDetailModel?.totCredit ?? 0.00}").toString())}",
              //           theme: false,
              //           color: theme.isDarkMode
              //               ? colors.textPrimaryDark
              //               : colors.textTertiaryLight,
              //           fw: 0),
              //       const SizedBox(height: 8),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           TextWidget.subText(
              //             text:
              //                 "Used ${getFormatter(value: double.parse("${funds.fundDetailModel?.utilizedMrgn ?? 0.00}"), v4d: false, noDecimal: false)}",
              //             theme: false,
              //             color: theme.isDarkMode
              //                 ? colors.textPrimaryDark
              //                 : colors.textPrimaryLight,
              //           ),
              //           const SizedBox(width: 8),
              //           TextWidget.subText(
              //             text:
              //                 "Cash + collateral ${getFormatter(value: (double.tryParse('${funds.listOfCredits.isNotEmpty ? funds.listOfCredits[0]["value"] : 0}') ?? 0.0) + (double.tryParse('${funds.listOfCredits.length > 1 ? funds.listOfCredits[1]["value"] : 0}') ?? 0.0), v4d: false, noDecimal: false)}",
              //             theme: false,
              //             color: theme.isDarkMode
              //                 ? colors.textPrimaryDark
              //                 : colors.textPrimaryLight,
              //           ),
              //         ],
              //       )
              //     ],
              //   ),
              // ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text("Products",
              //           style: textStyle(
              //               const Color(0xff000000), 16, FontWeight.w600)),
              //       const SizedBox(height: 16),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           productList(
              //               'IPO',
              //               "A company's first public stock offering.",
              //               "assets/profileimage/prd-ipo.svg",
              //               theme, () {
              //             Navigator.pushNamed(context, Routes.ipo);
              //             // launch(
              //             //     "https://mynt.zebuetrade.com/ipo?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
              //           }),
              //           productList(
              //               'Mutual Funds',
              //               "Invest in experts managed portfolio.",
              //               "assets/profileimage/prd-mf.svg",
              //               theme, () async {
              //             // await portfolio.fetchMFHoldings(context);
              //             // await mf.fetchMFCategoryType();
              //             // await mf.fetchmfNFO(context);
              //             await mf.fetchMFWatchlist("", "", context, true, "");
              //             Navigator.pushNamed(context, Routes.mfmainscreen);
              //             // launch(
              //             //     "https://mynt.zebuetrade.com/mutualfund?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
              //           }),
              //           productList('OptionZ', "Options Trading Platform.",
              //               "assets/profileimage/prd-optz.svg", theme, () async {
              //             await funds.fetchHstoken(context);
              //             funds.optionZ(context);
              //           }),
              //           productList(
              //               'All Broker',
              //               "A company's first public stock offering.",
              //               "assets/profileimage/prd-ab.svg",
              //               theme, () {
              //             Navigator.pushNamed(context, Routes.reportWebViewApp);
              //             // launch(
              //             //     "https://mynt.zebuetrade.com/ipo?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
              //           }),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),

              // const CaEvents(),
              const SizedBox(height: 16),
              // SizedBox(
              //   height: 350,
              //   child: PageView.builder(
              //     physics: const AlwaysScrollableScrollPhysics(),
              //     itemCount: 1,
              //     itemBuilder: (context, index) {
              //       return RepaintBoundary(child: NewsScreen());
              //     },
              //   ),
              // ),
            ],
          ),
        );
      }),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }

  Widget productList(String title, String subtitle, String image,
      ThemesProvider theme, VoidCallback action) {
    return InkWell(
      canRequestFocus: false,
      onTap: action,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: theme.isDarkMode
                    ? const Color(0xff666666).withOpacity(0.4)
                    : const Color(0xffEBF1FF),
                borderRadius: BorderRadius.circular(60)),
            child: SvgPicture.asset(
              image,
              width: 32,
              color: theme.isDarkMode
                  ? const Color(0xffEBF1FF).withOpacity(0.8)
                  : const Color(0xff000000),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                color: Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Widget _buildInfoCard({
  //   required String value1,
  //   String? value2,
  //   String? value3,
  //   required Color value1color,
  //   Color? value2color,
  //   Color? value3color,
  //   // required Color iconColor,
  // }) {
  //   return Expanded(
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             TextWidget.subText(
  //               text: value1,
  //               theme: false,
  //               color: value1color,
  //               fw: 3,
  //             ),
  //             const SizedBox(height: 4),
  //             TextWidget.titleText(
  //               text: value2 ?? "",
  //               theme: false,
  //               color: value2color,
  //               fw: 3,
  //             ),
  //             const SizedBox(height: 4),
  //             TextWidget.subText(
  //                 text: value3 ?? "", theme: false, color: value3color, fw: 0),
  //           ],
  //         ),
  //         // const SizedBox(width: 4),
  //         // InkWell(
  //         //   onTap: () async {
  //         //     await trancation.fetchValidateToken(context);

  //         //     await trancation.ip();
  //         //     await trancation.fetchupiIdView(
  //         //         trancation.bankdetails!.dATA![trancation.indexss]
  //         //             [1],
  //         //         trancation.bankdetails!.dATA![trancation.indexss]
  //         //             [2]);

  //         //     await trancation.fetchcwithdraw(context);
  //         //     trancation.changebool(true);
  //         //     Navigator.pushNamed(context, Routes.fundscreen,
  //         //         arguments: trancation);
  //         //   },
  //         //   child: Text(
  //         //     "Add fund",
  //         //     style: TextStyle(
  //         //         color: colors.colorBlue,
  //         //         fontSize: 13,
  //         //         fontWeight: FontWeight.w500),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  Widget redesignedActionCard({
    required String icon,
    required String label,
    required String subtitle,
    required ThemesProvider theme,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          canRequestFocus: false,
          onTap: onTap,
          // borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset(
                    icon,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWidget.subText(
                        text: label,
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 0,
                      ),
                      const SizedBox(height: 4),
                      TextWidget.paraText(
                        text: subtitle,
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildETFCategory({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      canRequestFocus: false,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colors.textSecondaryLight.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 32,
              height: 32,
              color: colors.textSecondaryDark,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        TextWidget.textStyle(fontSize: 16, theme: false, fw: 2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style:
                        TextWidget.textStyle(fontSize: 12, theme: false, fw: 3),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildETFCollectionsTab(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Builder(
              builder: (context) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: theme.isDarkMode
                              ? colors.dividerDark
                              : colors.dividerLight),
                      itemCount: 6,
                      itemBuilder: (BuildContext context, int index) {
                        final etfCategories = [
                          {
                            'icon': 'assets/explore/loan.svg',
                            'title': 'Indices',
                            'subtitle': 'Build wealth and save taxes',
                          },
                          {
                            'icon': 'assets/explore/transactions.svg',
                            'title': 'Sector & Theme',
                            'subtitle': 'Maximize returns with high growth',
                          },
                          {
                            'icon': 'assets/explore/goldcoin.svg',
                            'title': 'Strategy Based',
                            'subtitle': 'Stable income and growth',
                          },
                          {
                            'icon': 'assets/icon/dashboard/global.svg',
                            'title': 'Global',
                            'subtitle': 'Focused investments in key sectors',
                          },
                          {
                            'icon': 'assets/icon/dashboard/Debt.svg',
                            'title': 'Debt',
                            'subtitle': 'Diversify your portfolio globally',
                          },
                          {
                            'icon': 'assets/icon/dashboard/gold_silver.svg',
                            'title': 'Gold & Silver',
                            'subtitle': 'Stability and growth combined',
                          },
                        ];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    ETFCategoryDetailScreen(
                                  categoryTitle:
                                      etfCategories[index]['title'] ?? '',
                                  categoryIcon:
                                      etfCategories[index]['icon'] ?? '',
                                  categoryDescription:
                                      etfCategories[index]['subtitle'] ?? '',
                                ),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(-1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: ListTile(
                            minLeadingWidth: 30,
                            // contentPadding:
                            //     const EdgeInsets.symmetric(horizontal: 16),
                            dense: false,
                            leading: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: SvgPicture.asset(
                                etfCategories[index]['icon'] ?? '',
                                height: 30,
                                width: 30,
                              ),
                            ),
                            title: TextWidget.subText(
                              text: etfCategories[index]['title'] ?? '',
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              textOverflow: TextOverflow.ellipsis,
                              theme: theme.isDarkMode,
                              fw: 0,
                            ),
                            subtitle: TextWidget.paraText(
                              text: "${etfCategories[index]['subtitle'] ?? ''}",
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                              theme: theme.isDarkMode,
                              fw: 0,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            Divider(
                height: 1,
                color: theme.isDarkMode
                    ? colors.dividerDark
                    : colors.dividerLight),
          ],
        )
      ],
    );
  }

  Widget buildStockScannerTab(ThemesProvider theme) {
    return const Center(
      child: Text("Stock Scanner Content"),
    );
  }
  Widget optionZTile(BuildContext context, ThemesProvider theme, funds) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: InkWell(
       canRequestFocus: false,
       borderRadius: BorderRadius.circular(5),
                    customBorder: const RoundedRectangleBorder(),
                    splashColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    highlightColor: theme.isDarkMode
                        ? colors.highlightDark
                        : colors.highlightLight,
        onTap: () async {
          Future.delayed(const Duration(milliseconds: 150), () async {
            await funds.fetchHstoken(context);
            funds.optionZ(context);
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: theme.isDarkMode
                              ? colors.searchBgDark.withOpacity(0.5)
                              : const Color(0xffF1F3F8).withOpacity(0.5),
                          border: Border.all(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                          ),
                        ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Texts
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.custmText(
                                    text: "OptionZ",
                                    theme: false,
                                     color: theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight,
                                        fs: 20,
                                    fw: 0),
                                const SizedBox(height: 4),
                                TextWidget.paraText(
                                    text:
                                        // "Rewarding you for spreading the word",
                                        "Trade smart in options",
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    fw: 0),
                ],
              ),
               Icon(
                 Icons.bar_chart_rounded,
                 size: 35,
                 color: theme.isDarkMode
                     ? colors.secondaryDark
                     : colors.secondaryLight,
               ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
