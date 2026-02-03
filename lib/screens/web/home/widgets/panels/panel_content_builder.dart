import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/screens/web/dashboard_screen_web.dart';
import 'package:mynt_plus/screens/web/holdings/holding_screen_web.dart';
import 'package:mynt_plus/screens/web/home/models/screen_type.dart';
import 'package:mynt_plus/screens/web/home/widgets/lazy_loaders/lazy_fund_screen.dart';
import 'package:mynt_plus/screens/web/ipo/ipo_main_screen_web.dart';
import 'package:mynt_plus/screens/web/market_watch/chart_with_depth_web.dart';
import 'package:mynt_plus/screens/web/market_watch/options/option_chain_ss_web.dart';
import 'package:mynt_plus/screens/web/market_watch/watchlist_screen_web.dart';
import 'package:mynt_plus/screens/web/ordersbook/order_book_screen_web.dart';
import 'package:mynt_plus/screens/web/position/position_screen_web.dart';
import 'package:mynt_plus/screens/web/profile/Reports/reports_screen_web.dart';
// import 'package:mynt_plus/screens/web/profile/settings_web.dart';
import 'package:mynt_plus/screens/web/trade_action_screen_web.dart';
import 'package:mynt_plus/screens/web/portfolio_analysis_web.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/screens/Mobile/bonds/bonds_main_screen.dart';
import 'package:mynt_plus/screens/Mobile/desk_reports/ca_action/ca_action_buyback.dart';
import 'package:mynt_plus/screens/Mobile/desk_reports/pledge_unpledge_screen.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_main_screen.dart';

import '../../../../../models/marketwatch_model/get_quotes.dart';

class PanelContentBuilder {
  final DepthInputArgs? optionChainArgs;
  final DepthInputArgs? currentDepthArgs;
  final int? tradeActionTabIndex;
  final Map<ScreenType, bool> screenLoadingStates;

  PanelContentBuilder({
    this.optionChainArgs,
    this.currentDepthArgs,
    this.tradeActionTabIndex,
    required this.screenLoadingStates,
  });

  Widget getScreenForType(ScreenType type) {
    switch (type) {
      case ScreenType.dashboard:
        return const DashboardScreenWeb();
      case ScreenType.watchlist:
        return const WatchListScreenWeb();
      case ScreenType.holdings:
        return Consumer(
          builder: (context, ref, _) {
            final portfolio = ref.watch(portfolioProvider);
            final theme = ref.watch(themeProvider);
            final isLoading = screenLoadingStates[ScreenType.holdings] ?? false;
            // final hasData = portfolio.holdingsModel != null && portfolio.holdingsModel!.isNotEmpty;

            if (isLoading || portfolio.holdloader) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color:
                    theme.isDarkMode ? WebDarkColors.background : Colors.white,
                child: MyntLoader.branded(),
              );
            }
            return HoldingScreenWeb(
                listofHolding: portfolio.holdingsModel ?? []);
          },
        );
      case ScreenType.positions:
        return Consumer(
          builder: (context, ref, _) {
            final portfolio = ref.watch(portfolioProvider);
            final theme = ref.watch(themeProvider);
            final isLoading =
                screenLoadingStates[ScreenType.positions] ?? false;

            if (isLoading || portfolio.posloader) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color:
                    theme.isDarkMode ? WebDarkColors.background : Colors.white,
                child: MyntLoader.branded(),
              );
            }
            return PositionScreenWeb(listofPosition: portfolio.allPostionList);
          },
        );
      case ScreenType.orderBook:
        return const OrderBookScreenWeb();
      case ScreenType.funds:
        return const LazyFundScreen();
      case ScreenType.mutualFund:
        return const MfmainScreen();
      case ScreenType.ipo:
        return const IPOScreen(isIpo: true);
      case ScreenType.bond:
        return const BondsScreen(isBonds: true);
      case ScreenType.scripDepthInfo:
        return Consumer(
          builder: (context, ref, _) {
            final args = currentDepthArgs;
            if (args == null) {
              return ChartWithDepthWeb(
                wlValue: DepthInputArgs(
                  exch: 'NSE',
                  token: '26000',
                  tsym: 'Nifty 50',
                  instname: '',
                  symbol: '',
                  expDate: '',
                  option: '',
                ),
              );
            }
            return ChartWithDepthWeb(wlValue: args);
          },
        );
      case ScreenType.optionChain:
        if (optionChainArgs != null) {
          return OptionChainSSWeb(wlValue: optionChainArgs!);
        }
        return const SizedBox.shrink();
      case ScreenType.pledgeUnpledge:
        return const PledgenUnpledge(ddd: "DDDDD");
      case ScreenType.corporateActions:
        return const CABuyback();
      case ScreenType.reports:
        return const ReportsScreenWeb();
      case ScreenType.settings:
        // return const SettingsScreenWeb();
      case ScreenType.tradeAction:
        final tabIndex = tradeActionTabIndex;
        return TradeActionScreenWeb(
          key: ValueKey('tradeAction_$tabIndex'),
          initialTabIndex: tabIndex,
        );
      case ScreenType.mfNfo:
        return const SizedBox.shrink();
      case ScreenType.mfCollection:
        return const SizedBox.shrink();
      case ScreenType.mfCategory:
        return const SizedBox.shrink();
      case ScreenType.sipCalculator:
        return const SizedBox.shrink();
      case ScreenType.cagrCalculator:
        return const SizedBox.shrink();
      case ScreenType.mfStockDetail:
        return const SizedBox.shrink();
      case ScreenType.notification:
        return const SizedBox.shrink();
      case ScreenType.portfolioAnalysis:
        return const PortfolioDashboardScreen();
    }
  }
}
