import 'package:flutter/material.dart';
import 'package:mynt_plus/screens/profile_screen/app_webview/ipo_webview.dart';
import '../screens/authentication/login/login_banner_screen.dart';
import '../screens/authentication/login/login_screen.dart';
import '../screens/authentication/login/otp_screen.dart';
import '../screens/authentication/password/change_pass.dart';
import '../screens/authentication/password/forgot_pass_unblock_user.dart';
import '../screens/bonds/bond_screen.dart';
import '../screens/home_screen.dart';
import '../screens/ipo/ipo_main_screen.dart';
import '../screens/ipo/ipo_orderbook_screen/ipo_modify_order/modify_order_screen.dart';
import '../screens/ipo/ipo_orderbook_screen/ipo_order_book_main_screen.dart';
import '../screens/ipo/ipo_orderbook_screen/ipo_orderbook_details/close_order_details.dart';
import '../screens/ipo/ipo_orderbook_screen/ipo_orderbook_details/open_order_details.dart';
import '../screens/ipo/mainstream_ipo/mainstream_order_screen/order_screen.dart';
import '../screens/ipo/sme_ipo/sme_order_screen/sme_order.dart';
import '../screens/market_watch/edit_scrip.dart';
import '../screens/market_watch/futures/future_screen.dart';
import '../screens/market_watch/option_chain/strategy/option_strategey.dart';
import '../screens/market_watch/search_screen.dart';
import '../screens/mutual_fund/mf_order_screen.dart';
import '../screens/mutual_fund/mf_stock_detail_screen.dart';
import '../screens/mutual_fund/mf_watchlist.dart';
import '../screens/mutual_fund/mutual_fund_screen.dart';
import '../screens/order_book/basket/basket_list.dart';
import '../screens/order_book/gtt_order_detail.dart';
import '../screens/order_book/order_book_detail.dart';
import '../screens/order_book/pending_alert_detail_screen.dart';
import '../screens/order_book/sip_order_details.dart';
import '../screens/order_book/trade_book_detail.dart';
import '../screens/order_screen/Rework/modify_gtt.dart';
import '../screens/order_screen/Rework/repeat_order.dart';
import '../screens/order_screen/modify_place_order_screen.dart';
import '../screens/order_screen/place_order_screen.dart';
import '../screens/portfolio_screens/holdings/edies_webview.dart';
import '../screens/portfolio_screens/holdings/exit_holdings_screen.dart';
import '../screens/portfolio_screens/holdings/holding_detail_screen.dart';
import '../screens/portfolio_screens/positions/exit_position_screen.dart';
import '../screens/portfolio_screens/positions/group/position_group_detail.dart';
import '../screens/portfolio_screens/positions/position_detail_screen.dart';
import '../screens/profile_screen/app_webview/cams_web_view.dart';
import '../screens/profile_screen/app_webview/fund_transaction.dart';
import '../screens/profile_screen/app_webview/option_z.dart';
import '../screens/profile_screen/app_webview/profile_web_view.dart';
import '../screens/profile_screen/app_webview/report_web_view.dart';
import '../screens/profile_screen/fund_screen/fund_screen.dart';
import '../screens/profile_screen/fund_screen/secure_fund.dart';
import '../screens/profile_screen/log_message.dart';
import '../screens/profile_screen/manage_fund/report_screen.dart';
import '../screens/profile_screen/my_ac_screens/bank_detail.dart';
import '../screens/profile_screen/my_ac_screens/my_acc.dart';
import '../screens/profile_screen/my_ac_screens/profile_details.dart';
import '../screens/profile_screen/my_ac_screens/set_auto_pay.dart';
import '../screens/profile_screen/my_ac_screens/setautopayscreen.dart';
import '../screens/profile_screen/notification_screens/notification_screen.dart';
import '../screens/profile_screen/qr_scan_widget.dart';
import '../screens/profile_screen/setting_screen/notification_setting.dart';
import '../screens/profile_screen/setting_screen/settingmaincscreen.dart';
import '../screens/profile_screen/setting_screen/window_settings.dart';
import '../screens/profile_screen/settingui.dart';
import '../screens/splash_screen.dart';
import '../screens/stocks/explore/stocks/indices/all_index_screen.dart';
import '../screens/stocks/explore/stocks/news/news_listdata.dart';
import '../screens/stocks/explore/stocks/stock_screens.dart';
import '../screens/stocks/explore/stocks/trade_action/all_trade.dart';
import '../screens/stocks/explore/stocks/trade_action/sector_themeatic_details.dart';
import '../sharedWidget/internet_widget.dart';
import 'route_names.dart';
import 'package:google_fonts/google_fonts.dart';

class AppRoutes {
  static Route router(RouteSettings settings) {
    final dynamic args = settings.arguments;
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      // case Routes.homeScreen:
      //   return MaterialPageRoute(builder: (_) => const HomeScreenDashBoard());
      case Routes.loginScreen:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start from the right
            const end = Offset.zero; // End at the original position
            const curve = Curves.easeInOut; // Smooth transition curve

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );

      case Routes.loginScreenBanner:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginBannerScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.loginOtpVerify:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case Routes.forgotPass:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ForgotPassUnblockUser(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start from the right
            const end = Offset.zero; // End at the original position
            const curve = Curves.easeInOut; // Smooth transition curve

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );

      case Routes.changePass:
        return MaterialPageRoute(
            builder: (_) => ChangePass(isChangePass: args));
      case Routes.nointernet:
        return MaterialPageRoute(builder: (_) => const NoInternetScreen());
      case Routes.logError:
        return MaterialPageRoute(builder: (_) => const LogMessage());
      case Routes.stock:
        return MaterialPageRoute(builder: (_) => const StockScreen());
      case Routes.searchScrip:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SearchScreen(wlName: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.editScrip:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              EditScrip(wlName: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.upiautopay:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const UpiPayement(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
                begin: const Offset(0, 1), end: const Offset(.0, .0));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.notificationscreen:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const NotificationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
                begin: const Offset(0, 1), end: const Offset(.0, .0));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.windowsetting:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const WindowSettings(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
                begin: const Offset(0, 1), end: const Offset(.0, .0));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.placeOrderScreen:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              PlaceOrderScreen(
            orderArg: args['orderArg'],
            scripInfo: args['scripInfo'],
            isBasket: args["isBskt"],
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      // case Routes.gttOrderScreen:
      //   return PageRouteBuilder(
      //     pageBuilder: (context, animation, secondaryAnimation) =>
      //         GTTOrderScreen(
      //             orderArg: args['orderArg'], scripInfo: args['scripInfo']),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       const begin = Offset(0.0, 1.0);
      //       const end = Offset.zero;
      //       const curve = Curves.ease;

      //       final tween =
      //           Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      //       return SlideTransition(
      //         position: animation.drive(tween),
      //         child: child,
      //       );
      //     },
      //   );

      case Routes.modifyGtt:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ModifyGTT(
              gttOrderBook: args['gttOrderBook'], scripInfo: args['scripInfo']),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.modifyOrder:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ModifyPlaceOrderScreen(
                  orderArg: args['orderArg'],
                  modifyOrderArgs: args['modifyOrderArgs'],
                  scripInfo: args['scripInfo']),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      // case Routes.chartWebView:
      //   return PageRouteBuilder(
      //     pageBuilder: (context, animation, secondaryAnimation) =>
      //         ChartScreenWebView(chartArgs: args),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       const begin = Offset(-1.0, 0.0);
      //       const end = Offset.zero;
      //       const curve = Curves.ease;

      //       final tween =
      //           Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      //       return SlideTransition(
      //         position: animation.drive(tween),
      //         child: child,
      //       );
      //     },
      //   );

      case Routes.futures:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const FutureScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });
      case Routes.holdingDetail:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HoldingDetailScreen(
                  exchTsym: args['exchTsym'],
                  holdingData: args['holdingData'],
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });
      case Routes.holdingExit:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ExitHoldingsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });
      case Routes.edis:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                EdisWebview(
                  params: args,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.optionZWebView:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              OptionZWebView(argument: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.camsWebView:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              CamsWebView(argument: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.orderDetail:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              OrderBookDetail(orderBookData: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.bsktScripList:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BasketScripList(bsktName: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.tradeDetail:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TradeBookDetail(tradeData: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.gttOrderDetail:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              GttOrderDetail(gttOrderBook: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.positionDetail:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              PositionDetailScreen(positionList: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.positionGroupDetail:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              PositionGroupDetail(positionData: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.positionExit:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ExitPositionScreen(exitPositionList: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.reports:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ReportsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.settingscreen:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SettingMainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
                begin: const Offset(0, 1), end: const Offset(.0, .0));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.myAcc:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MyAccount(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.profileDetail:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ProfileDetails(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.bankDetail:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const BankDetail(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.setautopay:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SetAutoPay(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.allIndex:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AllIndicesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case Routes.allTrade:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AllTrade(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.reportWebViewApp:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ReportWebViewApp(argument: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.ipowebview:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                IpoWebview(argument: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.fund:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SecureFund(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.fundTransaction:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FundTransaction(argument: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });
      case Routes.profileWebViewApp:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProfileWebViewApp(argument: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });
      case Routes.allnews:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const NewsListData(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.profilesettingscreen:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SettingsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                  begin: const Offset(0, 1), end: const Offset(.0, .0));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.repeatOrd:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                RepeatOrder(orderBookList: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                  begin: const Offset(0, 1), end: const Offset(.0, .0));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.notificationpage:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Notificationpage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                  begin: const Offset(0, 1), end: const Offset(.0, .0));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.ipo:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const IPOScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                  begin: const Offset(0, 1), end: const Offset(.0, .0));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.applyIPO:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ApplyIpoScreen(mainstream: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.smeapplyIPO:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SMEApplyIpoScreen(smeipo: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.ipoorderbook:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const IpoOrderbookMainScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                  begin: const Offset(0, 1), end: const Offset(.0, .0));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.modifyipoorder:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ModifyIpoOrderScreen(modifyipoorder: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.ipoopendetailsscreen:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                IpoOpenOrderDetails(ipodetails: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0, 1);
              const end = Offset(0, 0);
              const curve = Curves.bounceIn;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.ipoclosedetailsscreen:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                IpoCloseOrderDetails(ipoclose: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0, 1);
              const end = Offset(0, 0);
              const curve = Curves.bounceIn;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.sectorThematicDetail:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SectorThematicDetail(data: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.pendingalertdetails:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PendingAlertDetails(alert: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.qrscanner:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const BarcodeScannerWithScanWindow(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      case Routes.bonds:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const BondScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });
      case Routes.mf:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MutualFundScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case Routes.mfWatchlist:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MFWatchlistScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
                position: animation.drive(tween), child: child);
          },
        );
      case Routes.mfStockDetail:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MFStockDetailScreen(mfStockData: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            });

      case Routes.mforderScreen:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MFOrderScreen(mfData: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });
      case Routes.sipDetails:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SipOrderDetails(sipdetails: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      /////
      case Routes.fundscreen:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FundScreen(dd: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
                position: animation.drive(tween), child: child);
          },
          // settings: RouteSettings(),
          // maintainState: true,
          // fullscreenDialog: false,
          // opaque: true,
        );

      case Routes.optionStrategy:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OptionStrategey(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            });

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          body: Center(
              child: Text('404 Page Not Found',
                  style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600)))));
    });
  }
}
