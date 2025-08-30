import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import '../../provider/ledger_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../profile_screen/fund_screen/secure_fund.dart';
import 'allholdings/allholdings_screen.dart';
import 'holdings/holding_screen.dart';
import 'positions/position_screen.dart';
import '../order_book/order_book_screen.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    //  await
    ref.read(portfolioProvider).fetchBrokerDetails(context, false, false);

    ref.read(portfolioProvider).portTab = TabController(
        length: ref.read(portfolioProvider).portTabName.length,
        vsync: this,
        initialIndex: ref.read(portfolioProvider).selectedTab);

    ref.read(portfolioProvider).portTab.addListener(() {
      ref
          .read(portfolioProvider)
          .changeTabIndex(ref.read(portfolioProvider).portTab.index);

      // ref.read(portfolioProvider).tabSize(ref.read(themeProvider));
      if (ref.read(portfolioProvider).selectedTab == 0) {
        ref
            .read(portfolioProvider)
            .requestWSPosition(context: context, isSubscribe: false);
        ref
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: true);
        ref
            .read(portfolioProvider)
            .requestallHoldings(context: context, isSubscribe: false);
      } else if (ref.read(portfolioProvider).selectedTab == 1) {
        ref.read(portfolioProvider).cancelTimer();
        ref
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: false);
        ref
            .read(portfolioProvider)
            .requestWSPosition(context: context, isSubscribe: true);
        ref
            .read(portfolioProvider)
            .requestallHoldings(context: context, isSubscribe: false);

        if (ref.read(ledgerProvider).pledgeandunpledge == null) {
          ref.read(ledgerProvider).getCurrentDate("pandu");
          ref.read(ledgerProvider).fetchpledgeandunpledge(context);
        }

        ref.read(portfolioProvider).timerfunc();
      } else if (ref.read(portfolioProvider).selectedTab == 2) {
        // Orders tab - handle order-related logic
        ref.read(portfolioProvider).cancelTimer();
        ref
            .read(portfolioProvider)
            .requestWSPosition(context: context, isSubscribe: false);
        ref
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: false);
        ref
            .read(portfolioProvider)
            .requestallHoldings(context: context, isSubscribe: false);

        // Load order-related data
        ref.read(orderProvider).fetchOrderBook(context, false);
        ref.read(orderProvider).fetchTradeBook(context);
        ref.read(orderProvider).fetchSipOrderHistory(context);
        ref.read(marketWatchProvider).fetchPendingAlert(context);
        ref
            .read(orderProvider)
            .requestWSOrderBook(context: context, isSubscribe: true);
      } else if (ref.read(portfolioProvider).selectedTab == 3) {
        ref.read(portfolioProvider).cancelTimer();

        ref
            .read(portfolioProvider)
            .requestWSPosition(context: context, isSubscribe: false);
        ref
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: false);
        ref.read(fundProvider).fetchFunds(context);
        // context
        //     .read(portfolioProvider)
        //     .requestallHoldings(context: context, isSubscribe: true);
      } else {
        ref.read(portfolioProvider).cancelTimer();
        ref
            .read(portfolioProvider)
            .requestWSPosition(context: context, isSubscribe: false);
        ref
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: false);
        ref
            .read(portfolioProvider)
            .requestallHoldings(context: context, isSubscribe: false);
      }
    });

    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Portfolio Screen',
      screenClass: 'Portfolio_screen',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final portfolio = ref.watch(portfolioProvider);
      final theme = ref.read(themeProvider);
      String countText;
      if (portfolio.portTab.index == 0) {
        countText = portfolio.allPostionList.isNotEmpty
            ? "${portfolio.allPostionList.length}"
            : "";
      } else if (portfolio.portTab.index == 1) {
        final holdings = portfolio.holdingsModel;
        countText = (holdings != null && holdings.isNotEmpty)
            ? "${holdings.length}"
            : "";
      } else {
        countText = "";
      }

      return Column(children: [
        Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: TabBar(
                onTap: (index) {
                  setState(() {});
                },
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
                isScrollable: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                indicatorColor: theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight,
                unselectedLabelColor: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                unselectedLabelStyle: TextWidget.textStyle(
                  fontSize: 14,
                  theme: false,
                  fw: 3,
                ),
                labelColor: theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight,
                labelStyle:
                    TextWidget.textStyle(fontSize: 14, theme: false, fw: 3),
                controller: portfolio.portTab,
                tabs: List.generate(portfolio.portTabName.length, (index) {
                  return AnimatedBuilder(
                    animation: portfolio.portTab.animation!,
                    builder: (context, child) {
                      final isSelected = portfolio.portTab.index == index;
                      final animationValue = portfolio.portTab.animation!.value;
                      final isTransitioning =
                          (animationValue - index).abs() < 1;

                      final color = isTransitioning
                          ? Color.lerp(
                              theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight,
                              1 - (animationValue - index).abs())
                          : isSelected
                              ? theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight
                              : theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight;

                      return Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextWidget.subText(
                              text: index == 0
                                  ? "Holding${portfolio.holdingsModel!.isNotEmpty ? "s" : ""}"
                                  : index == 1
                                      ? "Position${portfolio.allPostionList.isNotEmpty ? "s" : ""}"
                                      : index == 2
                                          ? "Orders"
                                          : "Funds",
                              theme: false,
                              color: color,
                              fw: isSelected ? 2 : 2,
                            ),
                            const SizedBox(width: 5),
                            if ((index == 0 &&
                                    (portfolio.holdingsModel?.isNotEmpty ??
                                        false)) ||
                                (index == 1 &&
                                    portfolio.allPostionList.isNotEmpty))
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: TextWidget.paraText(
                                  text: index == 0
                                      ? (portfolio.holdingsModel?.isNotEmpty ??
                                              false
                                          ? "${portfolio.holdingsModel!.length}"
                                          : "")
                                      : index == 1
                                          ? (portfolio.allPostionList.isNotEmpty
                                              ? "${portfolio.allPostionList.length}"
                                              : "")
                                          : "",
                                  theme: false,
                                  color: color,
                                  fw: isSelected ? 2 : 0,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color:
                  theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            ),
          ],
        ),
        Expanded(
          // child: TransparentLoaderScreen(
          // isLoading: portfolio.loading,
          child: TabBarView(controller: portfolio.portTab, children: [
            const HoldingScreen(),
            PositionScreen(listofPosition: portfolio.allPostionList),
            const OrdersTabView(),
            const SecureFund(),
            //   ]
            // ],
            // const Allholdings()
          ]),
          // )
        ),
      ]);
    });
  }
}

// Orders tab view that embeds the OrderBook functionality
class OrdersTabView extends ConsumerWidget {
  const OrdersTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const OrderBookScreen();
  }
}
