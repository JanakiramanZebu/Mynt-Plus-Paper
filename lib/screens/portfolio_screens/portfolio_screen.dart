import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../profile_screen/fund_screen/secure_fund.dart';
import 'allholdings/allholdings_screen.dart';
import 'holdings/holding_screen.dart';
import 'positions/position_screen.dart';

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

      ref.read(portfolioProvider).tabSize();
      if (ref.read(portfolioProvider).selectedTab == 0) {
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
      } else if (ref.read(portfolioProvider).selectedTab == 1) {
        ref
            .read(portfolioProvider)
            .requestWSPosition(context: context, isSubscribe: false);
        ref
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: true);
        ref
            .read(portfolioProvider)
            .requestallHoldings(context: context, isSubscribe: false);

        ref.read(portfolioProvider).timerfunc();
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
      return Column(children: [
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 40,
            child: TabBar(
                // tabAlignment: portfolio.mfHoldingsModel!.isNotEmpty &&
                //             portfolio.mfHoldingsModel![0].stat != "Not_Ok" ||
                //         portfolio.allholds.isNotEmpty
                //     ? TabAlignment.start
                //     : TabAlignment.fill,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                // isScrollable: portfolio.mfHoldingsModel!.isNotEmpty &&
                //         portfolio.mfHoldingsModel![0].stat != "Not_Ok" ||
                //     portfolio.allholds.isNotEmpty,
                isScrollable: true,
                indicatorColor:
                    theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
                unselectedLabelColor: const Color(0XFF777777),
                unselectedLabelStyle: TextWidget.textStyle(
                    fontSize: 12,
                    theme: theme.isDarkMode,
                    fw: 0,
                    letterSpacing: -0.28),
                labelColor:
                    theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
                labelStyle: TextWidget.textStyle(
                    fontSize: 12, theme: theme.isDarkMode, fw: 1),
                controller: portfolio.portTab,
                tabs: portfolio.portTabName)),
        Expanded(
          // child: TransparentLoaderScreen(
          // isLoading: portfolio.loading,
          child: TabBarView(controller: portfolio.portTab, children: [
            PositionScreen(listofPosition: portfolio.allPostionList),
            const HoldingScreen(),
            // if (portfolio.mfHoldingsModel!.isNotEmpty) ...[
            //   if (portfolio.mfHoldingsModel![0].stat != "Not_Ok") ...[
            // const MFHoldingScreen(),
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
