// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:upgrader/upgrader.dart';
// import '../locator/constant.dart';
// import '../locator/locator.dart';
// import '../locator/preference.dart';
// import '../models/upgrader_model.dart';
// import '../provider/auth_provider.dart';
// import '../provider/fund_provider.dart';
// import '../provider/index_list_provider.dart';
// import '../provider/market_watch_provider.dart';
// import '../provider/network_state_provider.dart';
// import '../provider/order_provider.dart';
// import '../provider/portfolio_provider.dart';
// import '../provider/stocks_provider.dart';
// import '../provider/thems.dart';
// import '../provider/user_profile_provider.dart';
// import '../provider/websocket_provider.dart';
// import '../res/res.dart';
// import '../routes/route_names.dart';
// import '../sharedWidget/custom_switch_btn.dart';
// import '../sharedWidget/no_internet_widget.dart';
// import 'market_watch/index/index_screen.dart';
// import 'market_watch/scrip_filter_bottom_sheet.dart';
// import 'market_watch/watchlist_screen.dart';
// import 'market_watch/watchlists_bottom_sheet.dart';
// import 'order_book/order_book_screen.dart';
// import 'portfolio_screens/portfolio_screen.dart';
// import 'profile_screen/logged_user_bottom_sheet.dart';
// import 'profile_screen/profile_main_screen.dart';
// import 'stocks/explore/explore_screens.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final Preferences pref = locator<Preferences>();
//   @override
//   void initState() {
//     context.read(networkStateProvider).networkStream();
//     if (  context.read(indexListProvider).selectedBtmIndx!=0 ) {
//       ConstantName.timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//        if (mounted) {
//         context.read(websocketProvider).reconnectWS();}
      
//     });
//     }
    
//     context.read(marketWatchProvider).fToast.init(context);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     ConstantName.timer!.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var upgrader = Upgrader(
//       messages: MyUpgraderMessages(),
//     );
//     if (context.read(websocketProvider).wsConnected == false ||
//         context.read(websocketProvider).wsConnected == true) {
//       if (ConstantName.pageName != "edit") {
//         if (context.read(networkStateProvider).connectionStatus !=
//             ConnectivityResult.none) {
//           if (context.read(indexListProvider).selectedBtmIndx == 1) {
//             context
//                 .read(marketWatchProvider)
//                 .requestMWScrip(context: context, isSubscribe: true);
//           }
//           if (context.read(indexListProvider).selectedBtmIndx == 2) {
//             context
//                 .read(portfolioProvider)
//                 .requestWSHoldings(context: context, isSubscribe: true);
//             context
//                 .read(portfolioProvider)
//                 .requestWSPosition(context: context, isSubscribe: true);
//           }
//         }
//       }
//     }
//     return WillPopScope(
//         onWillPop: showExitPopup,
//         child: Consumer(builder: (context, ScopedReader watch, _) {
//           final marketWatchList = watch(marketWatchProvider);
//           final indexProvide = watch(indexListProvider);
//           final internet = watch(networkStateProvider);
//           final portfolio = watch(portfolioProvider);
//           final userProfile = watch(userProfileProvider);
//           final stockProvide = watch(stocksProvide);
//           final theme = context.read(themeProvider);
//           return GestureDetector(
//               onTap: () => FocusScope.of(context).unfocus(),
//               child: UpgradeAlert(
//                   upgrader: upgrader,
//                   showIgnore: false,
//                   showLater: false,
//                   child: Scaffold(
//                       appBar: AppBar(
//                           shadowColor: theme.isDarkMode
//                               ? colors.darkColorDivider
//                               : colors.colorDivider,
//                           leadingWidth: 205,
//                           elevation: .3,
//                           leading: indexProvide.selectedBtmIndx == 1
//                               ? InkWell(
//                                   onTap: () {
//                                     FocusScope.of(context).unfocus();
//                                     showModalBottomSheet(
//                                         useSafeArea: true,
//                                         isScrollControlled: true,
//                                         shape: const RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.vertical(
//                                                 top: Radius.circular(16))),
//                                         context: context,
//                                         builder: (context) {
//                                           return WatchlistsBottomSheet(
//                                               currentWLName:
//                                                   marketWatchList.wlName);
//                                         });
//                                   },
//                                   child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 10, horizontal: 16),
//                                       child: Row(children: [
//                                         Expanded(
//                                             child: Text(
//                                                 marketWatchList.wlName.isEmpty
//                                                     ? marketWatchList.wlName
//                                                     : marketWatchList
//                                                                 .isPreDefWLs ==
//                                                             "Yes"
//                                                         ? marketWatchList
//                                                                     .wlName ==
//                                                                 "My Stocks"
//                                                             ? marketWatchList
//                                                                 .wlName
//                                                             : marketWatchList
//                                                                 .wlName
//                                                         : "${marketWatchList.wlName[0].toUpperCase()}${marketWatchList.wlName.substring(1)}'s Watchlist",
//                                                 style: textStyle(
//                                                     theme.isDarkMode
//                                                         ? colors.colorWhite
//                                                         : colors.colorBlack,
//                                                     14,
//                                                     FontWeight.w600),
//                                                 overflow:
//                                                     TextOverflow.ellipsis)),
//                                         Text(
//                                             marketWatchList.wlName ==
//                                                     "My Stocks"
//                                                 ? "(${portfolio.holdingsModel!.length})"
//                                                 : "(${marketWatchList.scrips.length >= 50 ? 50 : marketWatchList.scrips.length})",
//                                             style: textStyle(
//                                                 theme.isDarkMode
//                                                     ? colors.colorLightBlue
//                                                     : colors.colorBlue,
//                                                 15,
//                                                 FontWeight.w600)),
//                                         const SizedBox(width: 3),
//                                         SvgPicture.asset(assets.downArrow,
//                                             color: theme.isDarkMode
//                                                 ? colors.colorLightBlue
//                                                 : colors.colorBlue,
//                                             width: 14)
//                                       ])))
//                               : Padding(
//                                   padding: const EdgeInsets.all(18),
//                                   child: Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                             indexProvide.selectedBtmIndx == 2
//                                                 ? "Orderbook"
//                                                 : indexProvide
//                                                             .selectedBtmIndx ==
//                                                         1
//                                                     ? "Portfolio"
//                                                     : indexProvide
//                                                                 .selectedBtmIndx ==
//                                                             0
//                                                         ? stockProvide
//                                                             .exploreName
//                                                         : "Profile",
//                                             style: textStyles.appBarTitleTxt
//                                                 .copyWith(
//                                                     color: theme.isDarkMode
//                                                         ? colors.colorWhite
//                                                         : colors.colorBlack))
//                                       ])),
//                           actions: indexProvide.selectedBtmIndx == 0
//                               ? null
//                               : [
//                                   if (indexProvide.selectedBtmIndx == 1 &&
//                                       marketWatchList.isPreDefWLs != "Yes") ...[
//                                     marketWatchList.scrips.length > 1
//                                         ? InkWell(
//                                             onTap: () {
//                                               //                     context
//                                               //                       .read(showcaseProvide).showToast("Reconnecting",
//                                               //  context);
//                                               FocusScope.of(context).unfocus();
//                                               showModalBottomSheet(
//                                                   useSafeArea: true,
//                                                   isScrollControlled: true,
//                                                   shape: const RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.vertical(
//                                                               top: Radius
//                                                                   .circular(
//                                                                       16))),
//                                                   context: context,
//                                                   builder: (context) {
//                                                     return const ScripFilterBottomSheet();
//                                                   });
//                                             },
//                                             child: Container(
//                                                 padding: EdgeInsets.only(
//                                                     left: 8,
//                                                     right: marketWatchList
//                                                                 .watchListValues
//                                                                 .length >=
//                                                             50
//                                                         ? 0
//                                                         : 8),
//                                                 child: SvgPicture.asset(
//                                                     assets.filterLines,
//                                                     width: 19,
//                                                     color: colors.colorGrey)),
//                                           )
//                                         : Container(),
//                                     marketWatchList.watchListValues.length >= 50
//                                         ? const SizedBox()
//                                         : InkWell(
//                                             onTap: () {
//                                               context
//                                                   .read(marketWatchProvider)
//                                                   .requestMWScrip(
//                                                       context: context,
//                                                       isSubscribe: false);
//                                               Navigator.pushNamed(
//                                                   context, Routes.searchScrip,
//                                                   arguments:
//                                                       marketWatchList.wlName);
//                                             },
//                                             child: Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     right: 16, left: 8),
//                                                 child: SvgPicture.asset(
//                                                     assets.searchIcon,
//                                                     width: 19,
//                                                     color: colors.colorGrey)),
//                                           ),
//                                   ] else if (indexProvide.selectedBtmIndx ==
//                                           2 &&
//                                       portfolio.postionBookModel!.isNotEmpty &&
//                                       portfolio.selectedTab == 0) ...[
//                                     if (portfolio.postionBookModel![0].stat ==
//                                         "Ok")
//                                       Padding(
//                                         padding:
//                                             const EdgeInsets.only(right: 15.0),
//                                         child: Row(children: [
//                                           Text("DAY",
//                                               style: textStyle(
//                                                   theme.isDarkMode
//                                                       ? colors.colorWhite
//                                                       : colors.colorBlack,
//                                                   13,
//                                                   FontWeight.w500)),
//                                           const SizedBox(width: 6),
//                                           CustomSwitch(
//                                               onChanged: (bool value) {
//                                                 portfolio.chngPositionPnl(true);
//                                                 portfolio.positionToggle(
//                                                     value, context);
//                                               },
//                                               value: portfolio.isDay),
//                                           const SizedBox(width: 6),
//                                           Text("NET",
//                                               style: textStyle(
//                                                   theme.isDarkMode
//                                                       ? colors.colorWhite
//                                                       : colors.colorBlack,
//                                                   13,
//                                                   FontWeight.w500)),
//                                         ]),
//                                       )
//                                   ]
//                                 ],
//                           bottom: indexProvide.selectedBtmIndx == 1
//                               ? const PreferredSize(
//                                   preferredSize: Size(20, 44),
//                                   child: DefaultIndexList())
//                               : indexProvide.selectedBtmIndx == 4
//                                   ? PreferredSize(
//                                       preferredSize: const Size(20, 20),
//                                       child: ListTile(
//                                           onTap: () {
//                                             showModalBottomSheet(
//                                                 context: context,
//                                                 isScrollControlled: true,
//                                                 isDismissible: true,
//                                                 shape:
//                                                     const RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                     topLeft:
//                                                         Radius.circular(10),
//                                                     topRight:
//                                                         Radius.circular(10),
//                                                   ),
//                                                 ),
//                                                 builder: (_) =>
//                                                     const LoggedUserBottomSheet(
//                                                         initRoute:
//                                                             'switchAcc'));
//                                           },
//                                           dense: true,
//                                           contentPadding:
//                                               const EdgeInsets.symmetric(
//                                                   horizontal: 16),
//                                           leading: CircleAvatar(
//                                             backgroundColor:
//                                                 const Color(0xffF1F3F8),
//                                             child: Text(
//                                                 userProfile.userDetailModel!
//                                                             .uname !=
//                                                         null
//                                                     ? userProfile
//                                                         .userDetailModel!
//                                                         .uname![0]
//                                                     : "",
//                                                 style: textStyle(
//                                                     const Color(0xff000000),
//                                                     18,
//                                                     FontWeight.w600)),
//                                           ),
//                                           title: Text(
//                                               "${userProfile.userDetailModel!.uname}",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: textStyle(
//                                                   Color(theme.isDarkMode
//                                                       ? 0xffffffff
//                                                       : 0xff000000),
//                                                   16,
//                                                   FontWeight.w600)),
//                                           subtitle: Text(
//                                               "User ID ${userProfile.userDetailModel!.uid}",
//                                               style: textStyle(
//                                                   const Color(0xff666666),
//                                                   12,
//                                                   FontWeight.w500)),
//                                           trailing: Container(
//                                               width: 100,
//                                               child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.end,
//                                                   children: [
//                                                     IconButton(
//                                                       splashRadius: 26,
//                                                       onPressed: () {
//                                                         Navigator.pushNamed(
//                                                             context,
//                                                             Routes.qrscanner);
//                                                       },
//                                                       icon: SvgPicture.asset(
//                                                           "assets/profile/qr_code.svg",
//                                                           width: 20,
//                                                           height: 24,
//                                                           color: theme.isDarkMode
//                                                               ? colors
//                                                                   .colorWhite
//                                                               : colors
//                                                                   .colorBlack),
//                                                     ),
//                                                     SizedBox(width: 4),
//                                                     Icon(
//                                                         Icons
//                                                             .arrow_drop_down_circle_outlined,
//                                                         color: theme.isDarkMode
//                                                             ? colors.colorWhite
//                                                             : colors.colorBlack)
//                                                   ]))))
//                                   : null),
//                       bottomNavigationBar: BottomAppBar(
//                           height: 58,
//                           shadowColor: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
//                           padding: EdgeInsets.zero,
//                           child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
//                             Expanded(
//                                 child: InkWell(
//                                     onTap: internet.connectionStatus ==
//                                             ConnectivityResult.none
//                                         ? null
//                                         : () async {
//                                             await portfolio.requestWSHoldings(
//                                                 context: context,
//                                                 isSubscribe: false);

//                                             await portfolio.requestWSPosition(
//                                                 context: context,
//                                                 isSubscribe: false);

//                                             await marketWatchList
//                                                 .requestMWScrip(
//                                                     context: context,
//                                                     isSubscribe: false);
//                                             await marketWatchList
//                                                 .requestWSOptChain(
//                                                     context: context,
//                                                     isSubscribe: false);
//                                             context
//                                                 .read(orderProvider)
//                                                 .requestWSOrderBook(
//                                                     context: context,
//                                                     isSubscribe: false);

//                                             indexProvide.bottomMenu(0);
//                                           },
//                                     child: Container(
//                                         margin:
//                                             const EdgeInsets
//                                                 .symmetric(horizontal: 7),
//                                         decoration: BoxDecoration(
//                                             border: indexProvide
//                                                         .selectedBtmIndx ==
//                                                     0
//                                                 ? Border(
//                                                     top: BorderSide(
//                                                         color: theme.isDarkMode
//                                                             ? colors
//                                                                 .colorLightBlue
//                                                             : colors.colorBlue,
//                                                         width: 2))
//                                                 : null),
//                                         child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               SvgPicture.asset(
//                                                   assets.bookmarkedIcon,
//                                                   color: theme.isDarkMode &&
//                                                           indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               0
//                                                       ? colors.colorLightBlue
//                                                       : indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               0
//                                                           ? colors.colorBlue
//                                                           : colors.colorGrey),
//                                               const SizedBox(height: 4),
//                                               Text("Explore",
//                                                   style: textStyle(
//                                                       theme.isDarkMode &&
//                                                               indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   0
//                                                           ? colors
//                                                               .colorLightBlue
//                                                           : indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   0
//                                                               ? colors.colorBlue
//                                                               : colors
//                                                                   .colorGrey,
//                                                       12,
//                                                       indexProvide.selectedBtmIndx ==
//                                                               0
//                                                           ? FontWeight.w600
//                                                           : FontWeight.w500))
//                                             ])))),
//                             Expanded(
//                                 child: InkWell(
//                                     onTap: internet.connectionStatus ==
//                                             ConnectivityResult.none
//                                         ? null
//                                         : () async {
//                                             if (!pref.islogIn!) {
//                                               showLoginDialog();
//                                             } else {
//                                               await indexProvide
//                                                   .checkSession(context);
//                                               await portfolio.requestWSHoldings(
//                                                   context: context,
//                                                   isSubscribe: false);

//                                               await context
//                                                   .read(orderProvider)
//                                                   .requestWSOrderBook(
//                                                       context: context,
//                                                       isSubscribe: false);
//                                               await portfolio.requestWSPosition(
//                                                   context: context,
//                                                   isSubscribe: false);

//                                               await marketWatchList
//                                                   .requestMWScrip(
//                                                       context: context,
//                                                       isSubscribe: true);

//                                               indexProvide.bottomMenu(1);
//                                             }
//                                           },
//                                     child: Container(
//                                         margin:
//                                             const EdgeInsets
//                                                 .symmetric(horizontal: 7),
//                                         decoration: BoxDecoration(
//                                             border: indexProvide
//                                                         .selectedBtmIndx ==
//                                                     1
//                                                 ? Border(
//                                                     top: BorderSide(
//                                                         color: theme.isDarkMode
//                                                             ? colors
//                                                                 .colorLightBlue
//                                                             : colors.colorBlue,
//                                                         width: 2))
//                                                 : null),
//                                         child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               SvgPicture.asset(
//                                                   assets.bookmarkedIcon,
//                                                   color: theme.isDarkMode &&
//                                                           indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               1
//                                                       ? colors.colorLightBlue
//                                                       : indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               1
//                                                           ? colors.colorBlue
//                                                           : colors.colorGrey),
//                                               const SizedBox(height: 4),
//                                               Text("Watchlist",
//                                                   style: textStyle(
//                                                       theme.isDarkMode &&
//                                                               indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   1
//                                                           ? colors
//                                                               .colorLightBlue
//                                                           : indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   1
//                                                               ? colors.colorBlue
//                                                               : colors
//                                                                   .colorGrey,
//                                                       12,
//                                                       indexProvide.selectedBtmIndx ==
//                                                               1
//                                                           ? FontWeight.w600
//                                                           : FontWeight.w500))
//                                             ])))),
//                             Expanded(
//                                 child: InkWell(
//                                     onTap: internet.connectionStatus ==
//                                             ConnectivityResult.none
//                                         ? null
//                                         : () async {
//                                             if (!pref.islogIn!) {
//                                               showLoginDialog();
//                                             } else {
//                                               await context
//                                                   .read(indexListProvider)
//                                                   .checkSession(context);
//                                               await portfolio
//                                                   .fetchMFHoldings(context);
//                                               // await context
//                                               //     .read(indexListProvider)
//                                               //     .checkSession(context);
//                                               await marketWatchList
//                                                   .requestMWScrip(
//                                                       context: context,
//                                                       isSubscribe: false);

//                                               await context
//                                                   .read(orderProvider)
//                                                   .requestWSOrderBook(
//                                                       context: context,
//                                                       isSubscribe: false);
//                                               if (portfolio.selectedTab == 1) {
//                                                 await portfolio
//                                                     .requestWSHoldings(
//                                                         context: context,
//                                                         isSubscribe: true);
//                                               }
//                                               if (portfolio.selectedTab == 0) {
//                                                 await portfolio
//                                                     .requestWSPosition(
//                                                         context: context,
//                                                         isSubscribe: true);
//                                               }
//                                               indexProvide.bottomMenu(2);
//                                             }
//                                           },
//                                     child: Container(
//                                         margin:
//                                             const EdgeInsets
//                                                 .symmetric(horizontal: 7),
//                                         decoration: BoxDecoration(
//                                             border: indexProvide
//                                                         .selectedBtmIndx ==
//                                                     2
//                                                 ? Border(
//                                                     top: BorderSide(
//                                                         color: theme.isDarkMode
//                                                             ? colors
//                                                                 .colorLightBlue
//                                                             : colors.colorBlue,
//                                                         width: 2))
//                                                 : null),
//                                         child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               SvgPicture.asset(assets.barChart,
//                                                   color: theme.isDarkMode &&
//                                                           indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               2
//                                                       ? colors.colorLightBlue
//                                                       : indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               2
//                                                           ? colors.colorBlue
//                                                           : colors.colorGrey),
//                                               const SizedBox(height: 4),
//                                               Text("Portfolio",
//                                                   style: textStyle(
//                                                       theme.isDarkMode &&
//                                                               indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   2
//                                                           ? colors
//                                                               .colorLightBlue
//                                                           : indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   2
//                                                               ? colors.colorBlue
//                                                               : colors
//                                                                   .colorGrey,
//                                                       12,
//                                                       indexProvide.selectedBtmIndx ==
//                                                               2
//                                                           ? FontWeight.w600
//                                                           : FontWeight.w500))
//                                             ])))),
//                             Expanded(
//                                 child: InkWell(
//                                     onTap: internet.connectionStatus ==
//                                             ConnectivityResult.none
//                                         ? null
//                                         : () async {
//                                             if (!pref.islogIn!) {
//                                               showLoginDialog();
//                                             } else {
//                                               await context
//                                                   .read(indexListProvider)
//                                                   .checkSession(context);
//                                               await marketWatchList
//                                                   .fetchPendingAlert(context);
//                                               await marketWatchList
//                                                   .requestMWScrip(
//                                                       context: context,
//                                                       isSubscribe: false);
//                                               await portfolio.requestWSHoldings(
//                                                   context: context,
//                                                   isSubscribe: false);

//                                               await portfolio.requestWSPosition(
//                                                   context: context,
//                                                   isSubscribe: false);

//                                               context
//                                                   .read(orderProvider)
//                                                   .requestWSOrderBook(
//                                                       context: context,
//                                                       isSubscribe: true);

//                                               indexProvide.bottomMenu(3);
//                                             }
//                                           },
//                                     child: Container(
//                                         margin:
//                                             const EdgeInsets
//                                                 .symmetric(horizontal: 7),
//                                         decoration: BoxDecoration(
//                                             border: indexProvide
//                                                         .selectedBtmIndx ==
//                                                     3
//                                                 ? Border(
//                                                     top: BorderSide(
//                                                         color: theme.isDarkMode
//                                                             ? colors
//                                                                 .colorLightBlue
//                                                             : colors.colorBlue,
//                                                         width: 2))
//                                                 : null),
//                                         child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               SvgPicture.asset(assets.bag,
//                                                   color: theme.isDarkMode &&
//                                                           indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               3
//                                                       ? colors.colorLightBlue
//                                                       : indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               3
//                                                           ? colors.colorBlue
//                                                           : colors.colorGrey),
//                                               const SizedBox(height: 4),
//                                               Text("Orders",
//                                                   style: textStyle(
//                                                       theme.isDarkMode &&
//                                                               indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   3
//                                                           ? colors
//                                                               .colorLightBlue
//                                                           : indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   3
//                                                               ? colors.colorBlue
//                                                               : colors
//                                                                   .colorGrey,
//                                                       12,
//                                                       indexProvide.selectedBtmIndx ==
//                                                               3
//                                                           ? FontWeight.w600
//                                                           : FontWeight.w500))
//                                             ])))),
//                             Expanded(
//                                 child: InkWell(
//                                     onTap: internet.connectionStatus ==
//                                             ConnectivityResult.none
//                                         ? null
//                                         : () async {
//                                             if (!pref.islogIn!) {
//                                               showLoginDialog();
//                                             } else {
//                                               await context
//                                                   .read(indexListProvider)
//                                                   .checkSession(context);
//                                               await context
//                                                   .read(fundProvider)
//                                                   .fetchFunds(context);

//                                               await context
//                                                   .read(userProfileProvider)
//                                                   .fetchprofilemenu();
//                                               indexProvide.bottomMenu(4);
//                                               marketWatchList.requestMWScrip(
//                                                   context: context,
//                                                   isSubscribe: false);
//                                               portfolio.requestWSHoldings(
//                                                   context: context,
//                                                   isSubscribe: false);

//                                               context
//                                                   .read(orderProvider)
//                                                   .requestWSOrderBook(
//                                                       context: context,
//                                                       isSubscribe: false);
//                                               portfolio.requestWSPosition(
//                                                   context: context,
//                                                   isSubscribe: false);
//                                             }
//                                           },
//                                     child: Container(
//                                         margin:
//                                             const EdgeInsets
//                                                 .symmetric(horizontal: 7),
//                                         decoration: BoxDecoration(
//                                             border: indexProvide
//                                                         .selectedBtmIndx ==
//                                                     4
//                                                 ? Border(
//                                                     top: BorderSide(
//                                                         color: theme.isDarkMode
//                                                             ? colors
//                                                                 .colorLightBlue
//                                                             : colors.colorBlue,
//                                                         width: 2))
//                                                 : null),
//                                         child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               SvgPicture.asset(
//                                                   "assets/profile/userlogo.svg",
//                                                   height: 18,
//                                                   color: theme.isDarkMode &&
//                                                           indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               4
//                                                       ? colors.colorLightBlue
//                                                       : indexProvide
//                                                                   .selectedBtmIndx ==
//                                                               4
//                                                           ? colors.colorBlue
//                                                           : colors.colorGrey),
//                                               const SizedBox(height: 5),
//                                               Text("Profile",
//                                                   style: textStyle(
//                                                       theme.isDarkMode &&
//                                                               indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   4
//                                                           ? colors
//                                                               .colorLightBlue
//                                                           : indexProvide
//                                                                       .selectedBtmIndx ==
//                                                                   4
//                                                               ? colors.colorBlue
//                                                               : colors
//                                                                   .colorGrey,
//                                                       12,
//                                                       indexProvide.selectedBtmIndx ==
//                                                               4
//                                                           ? FontWeight.w600
//                                                           : FontWeight.w500))
//                                             ]))))
//                           ])),
//                       body: Stack(children: [
//                         _onItemTapped(indexProvide.selectedBtmIndx),
//                         if (internet.connectionStatus ==
//                             ConnectivityResult.none) ...[
//                           const NoInternetWidget()
//                         ]
//                       ]))));
//         }));
//   }

//   _onItemTapped(index) {
//     switch (index) {
//       case 0:
//         return ExploreScreens();
//       case 1:
//         return WatchListScreen();
//       case 2:
//         return const PortfolioScreen();
//       case 3:
//         return const OrderBookScreen();
//       case 4:
//         return const UserAccountScreen();
//     }
//   }

//   Future<bool> showExitPopup() async {
//     return await showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                   backgroundColor: context.read(themeProvider).isDarkMode
//                       ? const Color.fromARGB(255, 18, 18, 18)
//                       : colors.colorWhite,
//                   titleTextStyle: textStyles.appBarTitleTxt.copyWith(
//                       color: context.read(themeProvider).isDarkMode
//                           ? colors.colorWhite
//                           : colors.colorBlack),
//                   contentTextStyle: textStyles.menuTxt,
//                   titlePadding:
//                       const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                   shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(14))),
//                   scrollable: true,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                   ),
//                   insetPadding: const EdgeInsets.symmetric(horizontal: 20),
//                   title: const Text("Exit App"),
//                   content: SizedBox(
//                       width: MediaQuery.of(context).size.width,
//                       child: const Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [Text("Do you want to Exit the App?")])),
//                   actions: [
//                     TextButton(
//                         onPressed: () => Navigator.of(context).pop(false),
//                         child: Text("No",
//                             style: textStyles.textBtn.copyWith(
//                                 color: context.read(themeProvider).isDarkMode
//                                     ? colors.colorLightBlue
//                                     : colors.colorBlue))),
//                     ElevatedButton(
//                         onPressed: () => Navigator.of(context).pop(true),
//                         style: ElevatedButton.styleFrom(
//                             elevation: 0,
//                             backgroundColor:
//                                 context.read(themeProvider).isDarkMode
//                                     ? colors.colorbluegrey
//                                     : colors.colorBlack,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(50))),
//                         child: Text("Yes",
//                             style: textStyle(
//                                 !context.read(themeProvider).isDarkMode
//                                     ? colors.colorWhite
//                                     : colors.colorBlack,
//                                 14,
//                                 FontWeight.w500)))
//                   ]);
//             }) ??
//         false;
//   }

//   showLoginDialog() {
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//               backgroundColor: context.read(themeProvider).isDarkMode
//                   ? const Color.fromARGB(255, 18, 18, 18)
//                   : colors.colorWhite,
//               titleTextStyle: textStyles.appBarTitleTxt.copyWith(
//                   color: context.read(themeProvider).isDarkMode
//                       ? colors.colorWhite
//                       : colors.colorBlack),
//               contentTextStyle: textStyles.menuTxt,
//               titlePadding:
//                   const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//               shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(14))),
//               scrollable: true,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 14,
//               ),
//               insetPadding: const EdgeInsets.symmetric(horizontal: 20),
//               title: const Text("Login to continue"),
//               content: SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   child: const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [Text("To access our app, please log in!")])),
//               actions: [
//                 ElevatedButton(
//                     onPressed: () async {
//                       Navigator.pop(context);
//                       context.read(authProvider).loginMethCtrl.text =
//                           pref.isMobileLogin!
//                               ? pref.clientMob!
//                               : pref.clientId!;
//                       context.read(authProvider).switchMobToClinent(
//                           pref.clientId!.isEmpty ? false : true);
//                       if (pref.clientSession!.isEmpty &&
//                           pref.clientId!.isNotEmpty) {
//                         pref.setHideLoginOptBtn(false);
//                       } else {
//                         pref.setHideLoginOptBtn(true);
//                       }
//                       if (pref.deviceName!.isEmpty) {
//                         await context.read(authProvider).getDeviceDetails();
//                       }

//                       Navigator.pushNamed(context, Routes.loginScreen);
//                     },
//                     style: ElevatedButton.styleFrom(
//                         elevation: 0,
//                         backgroundColor: context.read(themeProvider).isDarkMode
//                             ? colors.colorbluegrey
//                             : colors.colorBlack,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(50))),
//                     child: Text("Continue",
//                         style: textStyle(
//                             !context.read(themeProvider).isDarkMode
//                                 ? colors.colorWhite
//                                 : colors.colorBlack,
//                             14,
//                             FontWeight.w500)))
//               ]);
//         });
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle:
//             TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
//   }
// }
