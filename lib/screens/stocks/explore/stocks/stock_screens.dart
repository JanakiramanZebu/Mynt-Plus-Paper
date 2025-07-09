import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/stocks/explore/stocks/news/news_screen.dart';

import '../../../../provider/fund_provider.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/stocks_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
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
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final funds = ref.watch(fundProvider);
    final mf = ref.watch(mfProvider);
    final trancation = ref.watch(transcationProvider);

    return Consumer(builder: (context, ref, child) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const TopIndices(),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.titleText(
                      text: "Portfolio",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                    ),
                    Icon(Icons.arrow_forward,
                        size: 20,
                        color: theme.isDarkMode
                            ? colors.colorLightBlue
                            : colors.colorBlue)
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹476,656.36",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(
                              theme.isDarkMode ? 0xffffffff : 0xff000000)),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () async {
                        await trancation.fetchValidateToken(context);

                        await trancation.ip();
                        await trancation.fetchupiIdView(
                            trancation.bankdetails!.dATA![trancation.indexss]
                                [1],
                            trancation.bankdetails!.dATA![trancation.indexss]
                                [2]);

                        await trancation.fetchcwithdraw(context);
                        trancation.changebool(true);
                        Navigator.pushNamed(context, Routes.fundscreen,
                            arguments: trancation);
                      },
                      child: Text(
                        "Add fund",
                        style: TextStyle(
                            color: colors.colorBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                      icon: 'assets/icon/dashboard/briefcase.svg',
                      label: "Holdings",
                      value: "347945.90",
                      iconColor: Colors.teal,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoCard(
                      icon: 'assets/icon/dashboard/currency.svg',
                      label: "Cash",
                      value: "128629.91",
                      iconColor: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      // side: const BorderSide(
                      //     color: Color(0xFF87A1DD), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/explore/firefox.svg',
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "View my portfolio",
                          style: TextStyle(
                              color: Color(0xFF4069C9),
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        const Icon(
                          Icons.expand_more,
                          color: Color(0xFF4069C9),
                          size: 28,
                          weight: 7,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // const MyCarousel(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Products",
                      style: textStyle(
                          const Color(0xff000000), 16, FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      productList(
                          'IPO',
                          "A company's first public stock offering.",
                          "assets/profileimage/prd-ipo.svg",
                          theme, () {
                        Navigator.pushNamed(context, Routes.ipo);
                        // launch(
                        //     "https://mynt.zebuetrade.com/ipo?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
                      }),
                      productList(
                          'Mutual Funds',
                          "Invest in experts managed portfolio.",
                          "assets/profileimage/prd-mf.svg",
                          theme, () async {
                        // await portfolio.fetchMFHoldings(context);
                        // await mf.fetchMFCategoryType();
                        // await mf.fetchmfNFO(context);
                        await mf.fetchMFWatchlist("", "", context, true, "");
                        Navigator.pushNamed(context, Routes.mfmainscreen);
                        // launch(
                        //     "https://mynt.zebuetrade.com/mutualfund?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
                      }),
                      productList('OptionZ', "Options Trading Platform.",
                          "assets/profileimage/prd-optz.svg", theme, () async {
                        await funds.fetchHstoken(context);
                        funds.optionZ(context);
                      }),
                      productList(
                          'All Broker',
                          "A company's first public stock offering.",
                          "assets/profileimage/prd-ab.svg",
                          theme, () {
                        Navigator.pushNamed(context, Routes.reportWebViewApp);
                        // launch(
                        //     "https://mynt.zebuetrade.com/ipo?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            const TradeAction(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Live IPO",
                            style: textStyle(
                                const Color(0xff000000), 16, FontWeight.w600)),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.ipo);
                            },
                            child: const Text('See all',
                                style: TextStyle(
                                    color: Color(0xff0037B7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)))
                      ]),
                  const LiveIPOList(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const CaEvents(),
            const SizedBox(height: 24),
            const NewsScreen(),
          ],
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }

  Widget ServiceCard(
      {required String icon,
      required String title,
      required String description}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // White at 10%
            Color(0xFFF1F3F8), // Light Gray at 60%
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.1, 0.6], // 10% and 60%
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 50,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
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
    required String icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 16,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
