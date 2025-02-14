import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../locator/constant.dart';
import '../models/marketwatch_model/market_watch_scrip_model.dart';
import '../provider/fund_provider.dart';
import '../provider/index_list_provider.dart';
import '../provider/market_watch_provider.dart';
import '../provider/network_state_provider.dart';
import '../provider/order_provider.dart';
import '../provider/portfolio_provider.dart';
import '../provider/thems.dart';
import '../provider/user_profile_provider.dart';
import '../provider/version_provider.dart';
import '../provider/websocket_provider.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/internet_widget.dart';
import 'market_watch/index/index_screen.dart';
import 'market_watch/scrip_filter_bottom_sheet.dart';
import 'market_watch/tv_chart/webview_chart.dart';
import 'market_watch/watchlist_screen.dart';
import 'market_watch/watchlists_bottom_sheet.dart';
import 'order_book/basket/create_basket.dart';
import 'order_book/order_book_screen.dart';
import 'portfolio_screens/portfolio_screen.dart';
import 'portfolio_screens/positions/group/position_group_bottomsheet.dart';
import 'profile_screen/logged_user_bottom_sheet.dart';
import 'profile_screen/profile_main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
// This is a websockt heartbeat connection that reconnects every two seconds only.
    ConstantName.timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        context.read(websocketProvider).reconnectWS();
        // context.read(websocketProvider).startPingCheck(context);
      }
    });
    context.read(networkStateProvider).networkStream();
    context.read(marketWatchProvider).fToast.init(context);
    context.read(versionProvider).checkVersion(context);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ConstantName.timer!.cancel();
    super.dispose();
  }

// Determining the app's state, such as inactive, stopped, resumed, and so forth
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        // await context.read(portfolioProvider).fetchPositionBook(context, false);

        // if (context.read(portfolioProvider).postionBookModel![0].stat == "Ok") {
        //   context.read(portfolioProvider).fetchHoldings(context, "");
        //   context.read(orderProvider).fetchOrderBook(context, false);
        //   context.read(orderProvider).fetchTradeBook(context);
        // }

        if (context.read(websocketProvider).wsConnected == false ||
            context.read(websocketProvider).wsConnected == true) {
          if (ConstantName.lastSubscribe.isNotEmpty) {
            context.read(websocketProvider).establishConnection(
                channelInput: ConstantName.lastSubscribe,
                task: "t",
                context: context);
          }
          if (ConstantName.lastSubscribeDepth.isNotEmpty) {
            context.read(websocketProvider).establishConnection(
                channelInput: ConstantName.lastSubscribeDepth,
                task: "d",
                context: context);
          }
          if (context.read(networkStateProvider).connectionStatus !=
              ConnectivityResult.none) {
            context.read(websocketProvider).changeconnectioncount();
            if (context.read(indexListProvider).selectedBtmIndx == 1) {
              context
                  .read(marketWatchProvider)
                  .requestMWScrip(context: context, isSubscribe: true);
            }
            if (context.read(indexListProvider).selectedBtmIndx == 2) {
              context
                  .read(portfolioProvider)
                  .requestWSHoldings(context: context, isSubscribe: true);
              context.read(portfolioProvider).timerfunc();
              context
                  .read(portfolioProvider)
                  .requestWSPosition(context: context, isSubscribe: true);
            }
            if (context.read(indexListProvider).selectedBtmIndx == 3) {
              context
                  .read(orderProvider)
                  .requestWSOrderBook(context: context, isSubscribe: true);
            }
          }
        }
        print("app in resumed");
        final userProfile = context.read(userProfileProvider);

        final scriptInfo = context.read(marketWatchProvider).getQuotes;
        final theme = context.read(themeProvider);

        if (userProfile.showchartof) {
          if (scriptInfo?.exch != null) {
            await ConstantName.webViewController!.evaluateJavascript(
                source:
                    "window.changeScript('${scriptInfo?.exch}:${scriptInfo?.tsym}',${scriptInfo?.token}, '${theme.isDarkMode ? 'Y' : 'N'}')");

            await context.read(websocketProvider).establishConnection(
                channelInput: "${scriptInfo?.exch}|${scriptInfo?.token}",
                task: "d",
                context: context);
          } else {
            userProfile.setChartdialog(false);
          }
        }

        break;
      case AppLifecycleState.inactive:
        if (context.read(indexListProvider).selectedBtmIndx == 2) {
          context.read(portfolioProvider).cancelTimer();
        }
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        if (context.read(indexListProvider).selectedBtmIndx == 2) {
          context.read(portfolioProvider).cancelTimer();
        }
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        if (context.read(indexListProvider).selectedBtmIndx == 2) {
          context.read(portfolioProvider).cancelTimer();
        }
        print("app in detached");
        break;
      case AppLifecycleState.hidden:
        if (context.read(indexListProvider).selectedBtmIndx == 2) {
          context.read(portfolioProvider).cancelTimer();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    // It displays a dialogue to update our Application if the version has changed from the previous version.

    // var upgrader = Upgrader(
    //   messages: MyUpgraderMessages(),
    // );

    return WillPopScope(
        onWillPop: showExitPopup,
        child: Consumer(builder: (context, ScopedReader watch, _) {
          final marketWatchList = watch(marketWatchProvider);
          // final explore = watch(authProvider);
          final indexProvide = watch(indexListProvider);
          final internet = watch(networkStateProvider);
          final portfolio = watch(portfolioProvider);
          final userProfile = watch(userProfileProvider);
          final websocket = watch(websocketProvider);
          final theme = context.read(themeProvider);

          return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child:
                  internet.connectionStatus == ConnectivityResult.none ||
                          websocket.connectioncount >= 5
                      ? Scaffold(
                          appBar: AppBar(
                            elevation: 0,
                            backgroundColor: Color(0xffFFFFFF),
                          ),
                          body: NoInternetScreen(),
                        )
                      : Scaffold(
                          body: Stack(
                            children: [
                              Scaffold(
                                  appBar: indexProvide.selectedBtmIndx == 0
                                      ? null
                                      : AppBar(
                                          shadowColor: theme.isDarkMode
                                              ? colors.darkColorDivider
                                              : colors.colorDivider,
                                          leadingWidth: 205,
                                          elevation: .3,
                                          leading:
                                              indexProvide.selectedBtmIndx == 1
                                                  ? InkWell(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();

                                                        showModalBottomSheet(
                                                            useSafeArea: true,
                                                            isScrollControlled:
                                                                true,
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .vertical(
                                                                            top:
                                                                                Radius.circular(16))),
                                                            context: context,
                                                            builder: (context) {
                                                              return WatchlistsBottomSheet(
                                                                  currentWLName:
                                                                      marketWatchList
                                                                          .wlName);
                                                            });
                                                      },
                                                      child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 10,
                                                              horizontal: 16),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Text(
                                                                marketWatchList
                                                                        .wlName
                                                                        .isEmpty
                                                                    ? marketWatchList
                                                                        .wlName
                                                                    : marketWatchList.isPreDefWLs ==
                                                                            "Yes"
                                                                        ? marketWatchList.wlName ==
                                                                                "My Stocks"
                                                                            ? marketWatchList.wlName
                                                                            : marketWatchList.wlName
                                                                        : "${marketWatchList.wlName[0].toUpperCase()}${marketWatchList.wlName.substring(1)}'s Watchlist",
                                                                style: textStyle(
                                                                    theme.isDarkMode
                                                                        ? colors
                                                                            .colorWhite
                                                                        : colors
                                                                            .colorBlack,
                                                                    14,
                                                                    FontWeight
                                                                        .w600),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            Text(
                                                                marketWatchList
                                                                            .wlName ==
                                                                        "My Stocks"
                                                                    ? "(${portfolio.holdingsModel!.length})"
                                                                    : "(${marketWatchList.scrips.length})",
                                                                style: textStyle(
                                                                    theme.isDarkMode
                                                                        ? colors
                                                                            .colorLightBlue
                                                                        : colors
                                                                            .colorBlue,
                                                                    15,
                                                                    FontWeight
                                                                        .w600)),
                                                            const SizedBox(
                                                                width: 3),
                                                            SvgPicture.asset(
                                                                assets
                                                                    .downArrow,
                                                                color: theme.isDarkMode
                                                                    ? colors
                                                                        .colorLightBlue
                                                                    : colors
                                                                        .colorBlue,
                                                                width: 14)
                                                          ])))
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                              indexProvide.selectedBtmIndx ==
                                                                      3
                                                                  ? "Orderbook"
                                                                  : indexProvide
                                                                              .selectedBtmIndx ==
                                                                          2
                                                                      ? "Portfolio"
                                                                      : "Dashboard",
                                                              // watch(stocksProvide)
                                                              //     .exploreName,
                                                              style: textStyle(
                                                                  theme.isDarkMode
                                                                      ? colors
                                                                          .colorWhite
                                                                      : colors
                                                                          .colorBlack,
                                                                  17,
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                          actions:
                                              indexProvide.selectedBtmIndx == 0
                                                  ? []
                                                  : [
                                                      if (indexProvide
                                                                  .selectedBtmIndx ==
                                                              1 &&
                                                          marketWatchList
                                                                  .isPreDefWLs !=
                                                              "Yes") ...[
                                                        marketWatchList.scrips
                                                                    .length >
                                                                1
                                                            ? InkWell(
                                                                onTap: () {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .unfocus();
                                                                  showModalBottomSheet(
                                                                      useSafeArea:
                                                                          true,
                                                                      isScrollControlled:
                                                                          true,
                                                                      shape: const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.vertical(
                                                                              top: Radius.circular(
                                                                                  16))),
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return const ScripFilterBottomSheet();
                                                                      });
                                                                },
                                                                child: Container(
                                                                    padding: EdgeInsets.only(
                                                                        left: 8,
                                                                        right:
                                                                            10),
                                                                    child: SvgPicture.asset(
                                                                        assets
                                                                            .filterLines,
                                                                        width:
                                                                            19,
                                                                        color: colors
                                                                            .colorGrey)),
                                                              )
                                                            : Container(),
                                                        marketWatchList.scrips
                                                                    .length >=
                                                                50
                                                            ? const SizedBox()
                                                            : InkWell(
                                                                onTap: () {
                                                                  context
                                                                      .read(
                                                                          marketWatchProvider)
                                                                      .requestMWScrip(
                                                                          context:
                                                                              context,
                                                                          isSubscribe:
                                                                              false);
                                                                  Navigator.pushNamed(
                                                                      context,
                                                                      Routes
                                                                          .searchScrip,
                                                                      arguments:
                                                                          marketWatchList
                                                                              .wlName);
                                                                },
                                                                child: Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            16,
                                                                        left:
                                                                            8),
                                                                    child: SvgPicture.asset(
                                                                        assets
                                                                            .searchIcon,
                                                                        width:
                                                                            19,
                                                                        color: colors
                                                                            .colorGrey)),
                                                              ),
                                                      ] else if ((indexProvide
                                                                      .selectedBtmIndx ==
                                                                  2 &&
                                                              portfolio
                                                                  .allPostionList
                                                                  .isNotEmpty) &&
                                                          portfolio
                                                                  .selectedTab ==
                                                              0) ...[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 15.0),
                                                          child: Row(children: [
                                                            Container(
                                                              height: 27,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          10),
                                                              child:
                                                                  OutlinedButton(
                                                                      onPressed:
                                                                          () {
                                                                        showModalBottomSheet(
                                                                            useSafeArea:
                                                                                true,
                                                                            isScrollControlled:
                                                                                true,
                                                                            shape:
                                                                                const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                                                            context: context,
                                                                            builder: (context) {
                                                                              return const PositionGroupBottomSheet();
                                                                            });
                                                                      },
                                                                      style: OutlinedButton.styleFrom(
                                                                          side: BorderSide(
                                                                              color: theme.isDarkMode
                                                                                  ? colors
                                                                                      .colorGrey
                                                                                  : colors
                                                                                      .colorBlack),
                                                                          shape: const RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(
                                                                                  32)))),
                                                                      child: Text(
                                                                          "Group by",
                                                                          style: textStyle(
                                                                              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                                              12,
                                                                              FontWeight.w600))),
                                                            ),
                                                            if (portfolio
                                                                    .exitAll &&
                                                                portfolio
                                                                        .posSelection ==
                                                                    "All position" &&
                                                                portfolio
                                                                        .openPosition!
                                                                        .length >
                                                                    1)
                                                              SizedBox(
                                                                height: 27,
                                                                child:
                                                                    OutlinedButton(
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AlertDialog(
                                                                                backgroundColor: theme.isDarkMode ? const Color.fromARGB(255, 18, 18, 18) : colors.colorWhite,
                                                                                titleTextStyle: textStyles.appBarTitleTxt.copyWith(color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
                                                                                contentTextStyle: textStyles.menuTxt.copyWith(color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
                                                                                titlePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                                                                                scrollable: true,
                                                                                contentPadding: const EdgeInsets.symmetric(
                                                                                  horizontal: 14,
                                                                                ),
                                                                                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                                                                                title: const Text("Exit Position"),
                                                                                content: SizedBox(
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  child: const Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text("Are you sure you want to exit all positions?")
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                actions: [
                                                                                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("No", style: textStyles.textBtn.copyWith(color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue))),
                                                                                  ElevatedButton(
                                                                                    onPressed: () async {
                                                                                      await portfolio.exitPosition(context, true);
                                                                                      Navigator.of(context).pop(true);
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(
                                                                                        elevation: 0,
                                                                                        backgroundColor: theme.isDarkMode ? colors.colorbluegrey : colors.colorBlack,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(50),
                                                                                        )),
                                                                                    child: Text("Yes", style: textStyle(!theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 14, FontWeight.w500)),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                        style: OutlinedButton.styleFrom(
                                                                            side:
                                                                                BorderSide(color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack),
                                                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32)))),
                                                                        child: Text("Exit All", style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 12, FontWeight.w600))),
                                                              ),
                                                          ]),
                                                        )
                                                      ] else if (indexProvide
                                                                  .selectedBtmIndx ==
                                                              3 &&
                                                          watch(orderProvider)
                                                                  .selectedTab ==
                                                              4) ...[
                                                        Row(children: [
                                                          Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 8),
                                                              height: 30,
                                                              child:
                                                                  OutlinedButton(
                                                                      onPressed:
                                                                          () {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return const CreateBasket();
                                                                            });
                                                                      },
                                                                      style: OutlinedButton.styleFrom(
                                                                          side: BorderSide(
                                                                              color: theme.isDarkMode
                                                                                  ? colors
                                                                                      .colorGrey
                                                                                  : colors
                                                                                      .colorBlack),
                                                                          shape: const RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(
                                                                                  32)))),
                                                                      child: Text(
                                                                          "Create Basket",
                                                                          style:
                                                                              textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 12, FontWeight.w600))))
                                                        ])
                                                      ]
                                                    ],
                                          bottom:
                                              indexProvide.selectedBtmIndx == 1
                                                  ? const PreferredSize(
                                                      preferredSize:
                                                          Size(20, 44),
                                                      child: DefaultIndexList())
                                                  : indexProvide.selectedBtmIndx ==
                                                          4
                                                      ? PreferredSize(
                                                          preferredSize: const Size(
                                                              20, 20),
                                                          child:
                                                              userProfile
                                                                      .userloader
                                                                  ? ListTile(
                                                                      dense:
                                                                          true,
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              16),
                                                                      leading:
                                                                          CircleAvatar(
                                                                        backgroundColor: !theme.isDarkMode
                                                                            ? Colors.grey[300]
                                                                            : Color(0xff666666),
                                                                      ),
                                                                      title:
                                                                          Container(
                                                                        height:
                                                                            16,
                                                                        width:
                                                                            150,
                                                                        color: !theme.isDarkMode
                                                                            ? Colors.grey[300]
                                                                            : Color(0xff666666),
                                                                      ),
                                                                      subtitle:
                                                                          Container(
                                                                        height:
                                                                            12,
                                                                        width:
                                                                            100,
                                                                        color: !theme.isDarkMode
                                                                            ? Colors.grey[300]
                                                                            : Color(0xff666666),
                                                                      ),
                                                                      trailing:
                                                                          Container(
                                                                        height:
                                                                            24,
                                                                        width:
                                                                            50,
                                                                        color: !theme.isDarkMode
                                                                            ? Colors.grey[300]
                                                                            : Color(0xff666666),
                                                                      ),
                                                                    )
                                                                  : ListTile(
                                                                      onTap:
                                                                          () {
                                                                        showModalBottomSheet(
                                                                            context:
                                                                                context,
                                                                            isScrollControlled:
                                                                                true,
                                                                            isDismissible:
                                                                                true,
                                                                            shape:
                                                                                const RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(10),
                                                                                topRight: Radius.circular(10),
                                                                              ),
                                                                            ),
                                                                            builder: (_) =>
                                                                                const LoggedUserBottomSheet(initRoute: 'switchAcc'));
                                                                      },
                                                                      dense:
                                                                          true,
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              16),
                                                                      leading:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            const Color(0xffF1F3F8),
                                                                        child: Text(
                                                                            userProfile.userDetailModel!.uname != null
                                                                                ? userProfile.userDetailModel!.uname![0]
                                                                                : "",
                                                                            style: textStyle(const Color(0xff000000), 18, FontWeight.w600)),
                                                                      ),
                                                                      title: Text(
                                                                          "${userProfile.userDetailModel!.uname}",
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style: textStyle(
                                                                              Color(theme.isDarkMode
                                                                                  ? 0xffffffff
                                                                                  : 0xff000000),
                                                                              16,
                                                                              FontWeight
                                                                                  .w600)),
                                                                      subtitle: Text(
                                                                          "Client ID ${userProfile.userDetailModel!.uid}",
                                                                          style: textStyle(
                                                                              const Color(0xff666666),
                                                                              12,
                                                                              FontWeight.w500)),
                                                                      trailing: SizedBox(
                                                                          width: 100,
                                                                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                            IconButton(
                                                                              splashRadius: 26,
                                                                              onPressed: () {
                                                                                Navigator.pushNamed(context, Routes.qrscanner);
                                                                              },
                                                                              icon: SvgPicture.asset("assets/profile/qr_code.svg", width: 20, height: 24, color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
                                                                            ),
                                                                            const SizedBox(width: 4),
                                                                            Icon(Icons.arrow_drop_down_circle_outlined,
                                                                                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack)
                                                                          ]))))
                                                      : null),

                                  // Here is the Bottom menu items
                                  bottomNavigationBar: BottomAppBar(
                                      height: 58,
                                      shadowColor: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                                      padding: EdgeInsets.zero,
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                        // Expanded(
                                        //   child: InkWell(
                                        //     onTap: internet.connectionStatus ==
                                        //             ConnectivityResult.none
                                        //         ? null
                                        //         : () async {
                                        //             watch(stocksProvide)
                                        //                 .chngExpName("Stock", 0);
                                        //             await context
                                        //                 .read(indexListProvider)
                                        //                 .checkSession(context);
                                        //             await portfolio.requestWSHoldings(
                                        //                 context: context,
                                        //                 isSubscribe: false);

                                        //             // await context
                                        //             //     .read(orderProvider)
                                        //             //     .requestWSOrderBook(
                                        //             //         context: context,
                                        //             //         isSubscribe: false);
                                        //             await portfolio.requestWSPosition(
                                        //                 context: context,
                                        //                 isSubscribe: false);

                                        //             await context
                                        //                 .read(marketWatchProvider)
                                        //                 .requestMWScrip(
                                        //                     context: context,
                                        //                     isSubscribe: false);
                                        //             await explore.exploretabSize();
                                        //             indexProvide.bottomMenu(0);
                                        //           },
                                        //     child: Container(
                                        //       margin:
                                        //           const EdgeInsets.symmetric(horizontal: 7),
                                        //       decoration: BoxDecoration(
                                        //           border: indexProvide.selectedBtmIndx == 0
                                        //               ? Border(
                                        //                   top: BorderSide(
                                        //                       color: theme.isDarkMode
                                        //                           ? colors.colorLightBlue
                                        //                           : colors.colorBlue,
                                        //                       width: 2))
                                        //               : null),
                                        //       child: Column(
                                        //         mainAxisAlignment: MainAxisAlignment.center,
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment.center,
                                        //         children: [
                                        //           SvgPicture.asset(assets.bookmarkedIcon,
                                        //               color: theme.isDarkMode &&
                                        //                       indexProvide
                                        //                               .selectedBtmIndx ==
                                        //                           0
                                        //                   ? colors.colorLightBlue
                                        //                   : indexProvide.selectedBtmIndx ==
                                        //                           0
                                        //                       ? colors.colorBlue
                                        //                       : colors.colorGrey),
                                        //           const SizedBox(height: 4),
                                        //           Text("Explore",
                                        //               style: textStyle(
                                        //                   theme.isDarkMode &&
                                        //                           indexProvide
                                        //                                   .selectedBtmIndx ==
                                        //                               0
                                        //                       ? colors.colorLightBlue
                                        //                       : indexProvide
                                        //                                   .selectedBtmIndx ==
                                        //                               0
                                        //                           ? colors.colorBlue
                                        //                           : colors.colorGrey,
                                        //                   12,
                                        //                   indexProvide.selectedBtmIndx == 0
                                        //                       ? FontWeight.w600
                                        //                       : FontWeight.w500)),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),

                                        Expanded(
                                            child: InkWell(
                                                onTap: () async {
                                                  indexProvide.bottomMenu(
                                                      1, context);
                                                  portfolio.cancelTimer();

                                                  // await context
                                                  //     .read(indexListProvider)
                                                  //     .checkSession(context);
                                                  // if (indexProvide
                                                  //         .checkSess!.stat ==
                                                  //     "Ok") {
                                                  await portfolio
                                                      .requestWSHoldings(
                                                          context: context,
                                                          isSubscribe: false);

                                                  await context
                                                      .read(orderProvider)
                                                      .requestWSOrderBook(
                                                          context: context,
                                                          isSubscribe: false);
                                                  await portfolio
                                                      .requestWSPosition(
                                                          context: context,
                                                          isSubscribe: false);
                                                  await context
                                                      .read(marketWatchProvider)
                                                      .requestMWScrip(
                                                          context: context,
                                                          isSubscribe: true);
                                                  // }
                                                },
                                                child: Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7),
                                                    decoration: BoxDecoration(
                                                        border: indexProvide
                                                                    .selectedBtmIndx ==
                                                                1
                                                            ? Border(
                                                                top: BorderSide(
                                                                    color: theme.isDarkMode
                                                                        ? colors
                                                                            .colorLightBlue
                                                                        : colors
                                                                            .colorBlue,
                                                                    width: 2))
                                                            : null),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SvgPicture.asset(
                                                              assets
                                                                  .bookmarkedIcon,
                                                              color: theme.isDarkMode &&
                                                                      indexProvide
                                                                              .selectedBtmIndx ==
                                                                          1
                                                                  ? colors
                                                                      .colorLightBlue
                                                                  : indexProvide
                                                                              .selectedBtmIndx ==
                                                                          1
                                                                      ? colors
                                                                          .colorBlue
                                                                      : colors
                                                                          .colorGrey),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text("Watchlist",
                                                              style: textStyle(
                                                                  theme.isDarkMode &&
                                                                          indexProvide.selectedBtmIndx ==
                                                                              1
                                                                      ? colors
                                                                          .colorLightBlue
                                                                      : indexProvide.selectedBtmIndx ==
                                                                              1
                                                                          ? colors
                                                                              .colorBlue
                                                                          : colors
                                                                              .colorGrey,
                                                                  12,
                                                                  indexProvide.selectedBtmIndx ==
                                                                          1
                                                                      ? FontWeight
                                                                          .w600
                                                                      : FontWeight
                                                                          .w500))
                                                        ])))),
                                        Expanded(
                                            child: InkWell(
                                          onTap: () async {
                                            // await context
                                            //     .read(indexListProvider)
                                            //     .checkSession(context);

                                            // if (indexProvide.checkSess!.stat ==
                                            //     "Ok")
                                            //  {
                                            indexProvide.bottomMenu(2, context);
                                            await portfolio
                                                .fetchMFHoldings(context);
                                            await marketWatchList
                                                .requestMWScrip(
                                                    context: context,
                                                    isSubscribe: false);

                                            await context
                                                .read(orderProvider)
                                                .requestWSOrderBook(
                                                    context: context,
                                                    isSubscribe: false);

                                            await portfolio.requestWSHoldings(
                                                context: context,
                                                isSubscribe: true);

                                            await portfolio.requestWSPosition(
                                                context: context,
                                                isSubscribe: true);
                                            // }
                                          },
                                          child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7),
                                              decoration: BoxDecoration(
                                                  border: indexProvide
                                                              .selectedBtmIndx ==
                                                          2
                                                      ? Border(
                                                          top: BorderSide(
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .colorLightBlue
                                                                  : colors
                                                                      .colorBlue,
                                                              width: 2))
                                                      : null),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                        assets.barChart,
                                                        color: theme.isDarkMode &&
                                                                indexProvide
                                                                        .selectedBtmIndx ==
                                                                    2
                                                            ? colors
                                                                .colorLightBlue
                                                            : indexProvide
                                                                        .selectedBtmIndx ==
                                                                    2
                                                                ? colors
                                                                    .colorBlue
                                                                : colors
                                                                    .colorGrey),
                                                    const SizedBox(height: 4),
                                                    Text("Portfolio",
                                                        style: textStyle(
                                                            theme.isDarkMode &&
                                                                    indexProvide
                                                                            .selectedBtmIndx ==
                                                                        2
                                                                ? colors
                                                                    .colorLightBlue
                                                                : indexProvide
                                                                            .selectedBtmIndx ==
                                                                        2
                                                                    ? colors
                                                                        .colorBlue
                                                                    : colors
                                                                        .colorGrey,
                                                            12,
                                                            indexProvide.selectedBtmIndx ==
                                                                    2
                                                                ? FontWeight
                                                                    .w600
                                                                : FontWeight
                                                                    .w500)),
                                                  ])),
                                        )),
                                        Expanded(
                                            child: InkWell(
                                                onTap: () async {
                                                  indexProvide.bottomMenu(
                                                      3, context);

                                                  portfolio.cancelTimer();
                                                  // await context
                                                  //     .read(indexListProvider)
                                                  //     .checkSession(context);
                                                  // if (indexProvide
                                                  //         .checkSess!.stat ==
                                                  //     "Ok") {
                                                  await context
                                                      .read(orderProvider)
                                                      .fetchSipOrderHistory(
                                                          context);
                                                  await marketWatchList
                                                      .fetchPendingAlert(
                                                          context);
                                                  await marketWatchList
                                                      .requestMWScrip(
                                                          context: context,
                                                          isSubscribe: false);
                                                  await portfolio
                                                      .requestWSHoldings(
                                                          context: context,
                                                          isSubscribe: false);

                                                  await portfolio
                                                      .requestWSPosition(
                                                          context: context,
                                                          isSubscribe: false);

                                                  context
                                                      .read(orderProvider)
                                                      .requestWSOrderBook(
                                                          context: context,
                                                          isSubscribe: true);
                                                  // }
                                                },
                                                child: Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7),
                                                    decoration: BoxDecoration(
                                                        border: indexProvide
                                                                    .selectedBtmIndx ==
                                                                3
                                                            ? Border(
                                                                top: BorderSide(
                                                                    color: theme.isDarkMode
                                                                        ? colors
                                                                            .colorLightBlue
                                                                        : colors
                                                                            .colorBlue,
                                                                    width: 2))
                                                            : null),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SvgPicture.asset(
                                                              assets.bag,
                                                              color: theme.isDarkMode &&
                                                                      indexProvide
                                                                              .selectedBtmIndx ==
                                                                          3
                                                                  ? colors
                                                                      .colorLightBlue
                                                                  : indexProvide
                                                                              .selectedBtmIndx ==
                                                                          3
                                                                      ? colors
                                                                          .colorBlue
                                                                      : colors
                                                                          .colorGrey),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text("Orders",
                                                              style: textStyle(
                                                                  theme.isDarkMode &&
                                                                          indexProvide.selectedBtmIndx ==
                                                                              3
                                                                      ? colors
                                                                          .colorLightBlue
                                                                      : indexProvide.selectedBtmIndx ==
                                                                              3
                                                                          ? colors
                                                                              .colorBlue
                                                                          : colors
                                                                              .colorGrey,
                                                                  12,
                                                                  indexProvide.selectedBtmIndx ==
                                                                          3
                                                                      ? FontWeight
                                                                          .w600
                                                                      : FontWeight
                                                                          .w500))
                                                        ])))),
                                        Expanded(
                                            child: InkWell(
                                                onTap: () async {
                                                  indexProvide.bottomMenu(
                                                      4, context);
                                                  portfolio.cancelTimer();
                                                  await context
                                                      .read(fundProvider)
                                                      .fetchFunds(context);
                                                  // if (context
                                                  //         .read(fundProvider)
                                                  //         .fundDetailModel!
                                                  //         .stat ==
                                                  //     "Ok") {
                                                  //   if (userProfile
                                                  //       .profileMenu.isEmpty) {
                                                  await userProfile
                                                      .fetchprofilemenu();
                                                  // }

                                                  marketWatchList
                                                      .requestMWScrip(
                                                          context: context,
                                                          isSubscribe: false);
                                                  portfolio.requestWSHoldings(
                                                      context: context,
                                                      isSubscribe: false);

                                                  context
                                                      .read(orderProvider)
                                                      .requestWSOrderBook(
                                                          context: context,
                                                          isSubscribe: false);
                                                  portfolio.requestWSPosition(
                                                      context: context,
                                                      isSubscribe: false);
                                                  // }
                                                },
                                                child: Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7),
                                                    decoration: BoxDecoration(
                                                        border: indexProvide
                                                                    .selectedBtmIndx ==
                                                                4
                                                            ? Border(
                                                                top: BorderSide(
                                                                    color: theme.isDarkMode
                                                                        ? colors
                                                                            .colorLightBlue
                                                                        : colors
                                                                            .colorBlue,
                                                                    width: 2))
                                                            : null),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SvgPicture.asset(
                                                              "assets/profile/userlogo.svg",
                                                              height: 18,
                                                              color: theme.isDarkMode &&
                                                                      indexProvide
                                                                              .selectedBtmIndx ==
                                                                          4
                                                                  ? colors
                                                                      .colorLightBlue
                                                                  : indexProvide
                                                                              .selectedBtmIndx ==
                                                                          4
                                                                      ? colors
                                                                          .colorBlue
                                                                      : colors
                                                                          .colorGrey),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text("Profile",
                                                              style: textStyle(
                                                                  theme.isDarkMode &&
                                                                          indexProvide.selectedBtmIndx ==
                                                                              4
                                                                      ? colors
                                                                          .colorLightBlue
                                                                      : indexProvide.selectedBtmIndx ==
                                                                              4
                                                                          ? colors
                                                                              .colorBlue
                                                                          : colors
                                                                              .colorGrey,
                                                                  12,
                                                                  indexProvide.selectedBtmIndx ==
                                                                          4
                                                                      ? FontWeight
                                                                          .w600
                                                                      : FontWeight
                                                                          .w500))
                                                        ])))),
                                        // Expanded(
                                        //     child: InkWell(
                                        //         onTap: internet.connectionStatus ==
                                        //                 ConnectivityResult.none
                                        //             ? null
                                        //             : () async {
                                        //                 showModalBottomSheet(
                                        //                     useSafeArea: true,
                                        //                     isScrollControlled: true,
                                        //                     shape: const RoundedRectangleBorder(
                                        //                         borderRadius:
                                        //                             BorderRadius.vertical(
                                        //                                 top:
                                        //                                     Radius.circular(16))),
                                        //                     context: context,
                                        //                     builder: (context) {
                                        //                       return const MoreMenuBottomSheet();
                                        //                     });
                                        //               },
                                        //         child: Container(
                                        //             margin:
                                        //                 const EdgeInsets.symmetric(horizontal: 7),
                                        //             decoration: BoxDecoration(
                                        //                 border: indexProvide.selectedBtmIndx > 4
                                        //                     ? Border(
                                        //                         top: BorderSide(
                                        //                             color: theme.isDarkMode
                                        //                                 ? colors.colorLightBlue
                                        //                                 : colors.colorBlue,
                                        //                             width: 2))
                                        //                     : null),
                                        //             child: Column(
                                        //                 mainAxisAlignment:
                                        //                     MainAxisAlignment.center,
                                        //                 crossAxisAlignment:
                                        //                     CrossAxisAlignment.center,
                                        //                 children: [
                                        //                   SvgPicture.asset(
                                        //                       "assets/profile/userlogo.svg",
                                        //                       height: 18,
                                        //                       color: theme.isDarkMode &&
                                        //                               indexProvide
                                        //                                       .selectedBtmIndx >
                                        //                                   4
                                        //                           ? colors.colorLightBlue
                                        //                           : indexProvide.selectedBtmIndx >
                                        //                                   4
                                        //                               ? colors.colorBlue
                                        //                               : colors.colorGrey),
                                        //                   const SizedBox(height: 5),
                                        //                   Text("Menu",
                                        //                       style: textStyle(
                                        //                           theme.isDarkMode &&
                                        //                                   indexProvide
                                        //                                           .selectedBtmIndx >
                                        //                                       4
                                        //                               ? colors.colorLightBlue
                                        //                               : indexProvide
                                        //                                           .selectedBtmIndx >
                                        //                                       4
                                        //                                   ? colors.colorBlue
                                        //                                   : colors.colorGrey,
                                        //                           12,
                                        //                           indexProvide.selectedBtmIndx > 4
                                        //                               ? FontWeight.w600
                                        //                               : FontWeight.w500))
                                        //                 ]))))
                                      ])),
                                  body: Stack(children: [
                                    // _onItemTapped(indexProvide.selectedBtmIndx),
                                    if (internet.connectionStatus ==
                                            ConnectivityResult.wifi ||
                                        internet.connectionStatus ==
                                                ConnectivityResult.mobile &&
                                            !userProfile.showchartof) ...[
                                      _onItemTapped(
                                          indexProvide.selectedBtmIndx, theme),
                                    ]
                                  ])),
                              Positioned(
                                // right: userProfile.showchartof
                                //     ? 0
                                //     : -300,
                                bottom: userProfile.showchartof
                                    ? 0
                                    : (MediaQuery.of(context).size.height +
                                        100),
                                // top: 0,
                                // : 0,
                                child: AnimatedContainer(
                                  alignment: Alignment.center,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  decoration: BoxDecoration(
                                    color: theme.isDarkMode
                                        ? colors.colorBlack
                                        : colors.colorWhite,
                                    // borderRadius: const BorderRadius.only(
                                    //   topLeft: Radius.circular(24),
                                    //   topRight: Radius.circular(24),
                                    // ),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //       color: theme.isDarkMode
                                    //           ? const Color.fromARGB(
                                    //               100, 100, 100, 100)
                                    //           : const Color.fromARGB(
                                    //               100, 0, 0, 0),
                                    //       blurRadius: theme.isDarkMode ? 5 : 10,
                                    //       spreadRadius:
                                    //           theme.isDarkMode ? 1 : 100,
                                    //       offset: Offset(
                                    //           0, theme.isDarkMode ? -3 : -6)),
                                    // ],
                                  ),
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: SafeArea(
                                    bottom: false,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ChartScreenWebView(
                                            chartArgs: ChartArgs(
                                                exch: 'ABC',
                                                tsym: 'ABCD',
                                                token: '0123'),
                                            cHeight: 1.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ));
        }));
  }

// The screen will change depending on the condition when you click on the bottom menu items.
  _onItemTapped(index, ThemesProvider theme) {
    switch (index) {
      // case 0:
      //   return ExploreScreens();
      case 1:
        return WatchListScreen();
      case 2:
        return const PortfolioScreen();
      case 3:
        return const OrderBookScreen();
      case 4:
        return const UserAccountScreen();

      // case 5:
      //   return const IPOScreen();
      // case 6:
      //   return const BondScreen();
      // case 7:
      // return const MutualFundScreen();
    }
  }

// If an application asks for user confirmation before you can exit it, do so.
  Future<bool> showExitPopup() async {
    return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  backgroundColor: context.read(themeProvider).isDarkMode
                      ? const Color.fromARGB(255, 18, 18, 18)
                      : colors.colorWhite,
                  titleTextStyle: textStyles.appBarTitleTxt.copyWith(
                      color: context.read(themeProvider).isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack),
                  contentTextStyle: textStyles.menuTxt,
                  titlePadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14))),
                  scrollable: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: const Text("Exit App"),
                  content: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text("Do you want to Exit the App?")])),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("No",
                            style: textStyles.textBtn.copyWith(
                                color: context.read(themeProvider).isDarkMode
                                    ? colors.colorLightBlue
                                    : colors.colorBlue))),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                context.read(themeProvider).isDarkMode
                                    ? colors.colorbluegrey
                                    : colors.colorBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            )),
                        child: Text("Yes",
                            style: textStyle(
                                !context.read(themeProvider).isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)))
                  ]);
            }) ??
        false;
  }
}
