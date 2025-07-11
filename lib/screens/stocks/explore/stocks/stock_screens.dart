import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/stocks/explore/stocks/news/news_screen.dart';

import '../../../../provider/fund_provider.dart';
import '../../../../provider/index_list_provider.dart';
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
// import 'news/news_screen.dart';
// import 'stock_monitor/stock_monitor_screen.dart';
// import 'trade_action/corporate_action.dart';
// import 'trade_action/trade_action_widget.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch portfolio data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPortfolioData();
    });
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
      ref.read(stocksProvide).chngTradeAction("init");
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
    final order = ref.watch(orderProvider);

    double totalCurrentVal = portfolio.totalPnlHolding;
    double cash = (totalCurrentVal +
        double.parse(funds.fundDetailModel?.cash?.toString() ?? "0"));

    final items = [
      {'label': 'GTT Orders', 'icon': assets.gttdashboard},
      {'label': 'SIP', 'icon': assets.sipdashboard},
      {'label': 'Basket Order', 'icon': assets.basketdashboard},
      {'label': 'Alerts', 'icon': assets.alertdashboard},
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.titleText(
                      text: "Portfolio on Zebu",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard(
                          value1: "Holdings",
                          value2:
                              "${getFormatter(value: totalCurrentVal, v4d: false, noDecimal: false)}",
                          value3:
                              "(${portfolio.totPnlPercHolding == "NaN" ? 0.00 : portfolio.totPnlPercHolding}%)",
                          value1color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          value2color:
                              totalCurrentVal.toString().startsWith("-")
                                  ? theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight
                                  : theme.isDarkMode
                                      ? colors.successDark
                                      : colors.successLight,
                          value3color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoCard(
                          value1: "Positions",
                          value2: portfolio.isDay
                              ? portfolio.totBookedPnL
                              : portfolio.totPnL,
                          value1color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          value2color:
                              totalCurrentVal.toString().startsWith("-")
                                  ? theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight
                                  : theme.isDarkMode
                                      ? colors.successDark
                                      : colors.successLight,
                        ),
                      ],
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
              ),

              // const MyCarousel(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.subText(
                              text: "New",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 3,
                            ),
                            const SizedBox(height: 4),
                            TextWidget.titleText(
                              text: "OptionZ",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 1,
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: TextWidget.subText(
                                  text:
                                      "Explore the world of options trading with our new platform. Trade options with ease and confidence.",
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  fw: 3,
                                  softWrap: true,
                                  maxLines: 4,
                                  letterSpacing: 0.8,
                                  lineHeight: 1.5),
                            ),
                            const SizedBox(height: 10),
                            Material(
                              color: Colors.transparent,
                              shape: const RoundedRectangleBorder(),
                              child: InkWell(
                                splashColor: theme.isDarkMode
                                    ? colors.splashColorDark
                                    : colors.splashColorLight,
                                highlightColor: theme.isDarkMode
                                    ? colors.highlightDark
                                    : colors.highlightLight,
                                customBorder: const RoundedRectangleBorder(),
                                onTap: () {
                                  Future.delayed(
                                      const Duration(milliseconds: 150),
                                      () async {
                                    await funds.fetchHstoken(context);
                                    funds.optionZ(context);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colors.btnBg,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: TextWidget.subText(
                                      text: "Explore",
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      fw: 3),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Image.asset(
                            assets.optionZdash,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // const NewsScreen(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                      text: "Funds & Margin",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 3,
                    ),
                    const SizedBox(height: 8),
                    TextWidget.titleText(
                        text:
                            "Avail ${formatCurrencyStandard(value: double.parse("${funds.fundDetailModel?.totCredit ?? 0.00}").toString())}",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textTertiaryLight,
                        fw: 0),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget.subText(
                          text:
                              "Used ${getFormatter(value: double.parse("${funds.fundDetailModel?.utilizedMrgn ?? 0.00}"), v4d: false, noDecimal: false)}",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                        ),
                        const SizedBox(width: 8),
                        TextWidget.subText(
                          text:
                              "Cash + collateral ${getFormatter(value: (double.tryParse('${funds.listOfCredits.isNotEmpty ? funds.listOfCredits[0]["value"] : 0}') ?? 0.0) + (double.tryParse('${funds.listOfCredits.length > 1 ? funds.listOfCredits[1]["value"] : 0}') ?? 0.0), v4d: false, noDecimal: false)}",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget.titleText(
                          text: "Quick Actions",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 1,
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double itemWidth = (constraints.maxWidth - 24) /
                                2; // padding between items

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: items.map((item) {
                                return SizedBox(
                                  width: itemWidth,
                                  child: actionCard(
                                    icon: item['icon'] as String,
                                    label: item['label'] as String,
                                    theme: theme,
                                    onTap: () {
                                      switch (item['label']) {
                                        case 'GTT Orders':
                                          indexList.bottomMenu(2, context);
                                          portfolio.changeTabIndex(2);
                                          order.changeTabIndex(3, context);
                                          break;
                                        case 'SIP':
                                          indexList.bottomMenu(2, context);
                                          break;
                                        case 'Basket Order':
                                          indexList.bottomMenu(2, context);
                                          portfolio.changeTabIndex(2);
                                          order.changeTabIndex(4, context);
                                          break;
                                        case 'Alerts':
                                          indexList.bottomMenu(2, context);
                                          portfolio.changeTabIndex(2);
                                          order.changeTabIndex(5, context);
                                          break;
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ])),

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

              const SizedBox(
                height: 16,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget.titleText(
                            text: "Live IPOs",
                            theme: false,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 1,
                          ),
                          // TextButton(
                          //     onPressed: () {
                          //       Navigator.pushNamed(context, Routes.ipo);
                          //     },
                          //     child: const Text('See all',
                          //         style: TextStyle(
                          //             color: Color(0xff0037B7),
                          //             fontSize: 14,
                          //             fontWeight: FontWeight.w600)))
                        ]),
                    const LiveIPOList(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const TradeAction(),
              const SizedBox(height: 16),

              // const CaEvents(),
              // const SizedBox(height: 24),
              // const NewsScreen(),
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

  Widget _buildInfoCard({
    required String value1,
    String? value2,
    String? value3,
    required Color value1color,
    Color? value2color,
    Color? value3color,
    // required Color iconColor,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.subText(
                text: value1,
                theme: false,
                color: value1color,
                fw: 3,
              ),
              const SizedBox(height: 4),
              TextWidget.titleText(
                text: value2 ?? "",
                theme: false,
                color: value2color,
                fw: 3,
              ),
              const SizedBox(height: 4),
              TextWidget.subText(
                  text: value3 ?? "", theme: false, color: value3color, fw: 0),
            ],
          ),
          // const SizedBox(width: 4),
          // InkWell(
          //   onTap: () async {
          //     await trancation.fetchValidateToken(context);

          //     await trancation.ip();
          //     await trancation.fetchupiIdView(
          //         trancation.bankdetails!.dATA![trancation.indexss]
          //             [1],
          //         trancation.bankdetails!.dATA![trancation.indexss]
          //             [2]);

          //     await trancation.fetchcwithdraw(context);
          //     trancation.changebool(true);
          //     Navigator.pushNamed(context, Routes.fundscreen,
          //         arguments: trancation);
          //   },
          //   child: Text(
          //     "Add fund",
          //     style: TextStyle(
          //         color: colors.colorBlue,
          //         fontSize: 13,
          //         fontWeight: FontWeight.w500),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget actionCard({
    required String icon,
    required String label,
    required ThemesProvider theme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: colors.kColorLightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.textDisabled),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
              ),
              const SizedBox(width: 12),
              TextWidget.titleText(
                text: label,
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
