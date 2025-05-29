// import 'package:bubble/bubble.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:showcaseview/showcaseview.dart';
// import 'package:trading_app_zebu/provider/index_list_provider.dart';
// import 'package:trading_app_zebu/provider/market_watch_provider.dart';
// import 'package:trading_app_zebu/provider/shocase_provider.dart';
// import 'package:trading_app_zebu/res/res.dart';
// import 'package:trading_app_zebu/screens/market_watch/scrip_filter_bottom_sheet.dart';
// import '../../model/get_quotes.dart';
// import '../../provider/fund_provider.dart';
// import '../../provider/order_provider.dart';
// import '../../provider/portfolio_provider.dart';
// import '../../provider/user_profile_provider.dart';
// import '../../provider/websocket_provider.dart';
// import '../../routes/route_names.dart';
// import '../market_watch/index/index_bottom_sheet.dart';
// import '../market_watch/scrip_depth_info.dart';
// import '../market_watch/watchlists_bottom_sheet.dart';

// class ShowCaseView extends StatefulWidget {
//   const ShowCaseView({
//     Key? key,
//     required this.margin,
//     required this.globalKey,
//     required this.text,
//     required this.postion,
//     required this.childs,
//     required this.index,
//     required this.nip,
//     required this.showtour,
//   }) : super(key: key);

//   final GlobalKey globalKey;
//   final Widget childs;
//   final String text;
//   final TooltipPosition postion;
//   final int index;
//   final EdgeInsetsGeometry margin;
//   final BubbleNip nip;
//   final bool showtour;

//   @override
//   State<ShowCaseView> createState() => _ShowCaseViewState();
// }

// class _ShowCaseViewState extends State<ShowCaseView> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         final marketWatchScrip = ref.watch(marketWatchProvider).watchListValues;
//         final marketWatchList = ref.watch(marketWatchProvider);
//         final indexProvide = ref.watch(indexListProvider);

//         final orderbook = ref.watch(orderProvider);
//         final portfolio = ref.watch(portfolioProvider);
//         final holdingProvide = ref.watch(portfolioProvider);
//         return Showcase.withWidget(
//             // disableMovingAnimation: true,
//             tooltipPosition: widget.postion,
//             key: widget.globalKey,
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height / 2,
//             container: Container(
//               margin: widget.margin,
//               width: MediaQuery.of(context).size.width / 1.5,
//               child: Bubble(
//                 //radius: Radius.zero,
//                 // nipWidth: 8,
//                 // nipHeight: 24,
//                 margin: const BubbleEdges.only(top: 10),
//                 nip: widget.nip,
//                 color: colors.colorWhite,
//                 child: Container(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 10),
//                         child: headerTitleText(widget.text),
//                       ),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                               onPressed: () async {
//                                 await context
//                                     .read(showcaseProvide)
//                                     .setTutorialStatus(false);
//                                 // setState(() {
//                                 //   dd.showtour = false;
//                                 //   dd.showtour1 = false;
//                                 // });
//                                 WidgetsBinding.instance.addPostFrameCallback(
//                                     (_) =>
//                                         ShowCaseWidget.of(context).dismiss());
//                               },
//                               child: Text("Skip", style: textStyles.textBtn)),
//                           ElevatedButton(
//                             onPressed: () async {
//                               // await context
//                               //     .read(showcaseProvide)
//                               //     .setTutorialStatus(dd.showtour);
//                               // setState(() {
//                               //   dd.showtour = false;
//                               //   dd.showtour1 = false;
//                               // });
//                               if (widget.text ==
//                                   "Click here to see watchlist screen") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   showModalBottomSheet(
//                                       showDragHandle: true,
//                                       useSafeArea: true,
//                                       isScrollControlled: true,
//                                       shape: const RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.vertical(
//                                               top: Radius.circular(16))),
//                                       backgroundColor: const Color(0xffffffff),
//                                       context: context,
//                                       builder: (context) {
//                                         return WatchlistsBottomSheet(
//                                           currentWLName: marketWatchList.wlName,
//                                         );
//                                       });
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .createnewwl,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .watchlisttabcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .changewlcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .changewldeletecase,
//                                           ]));
//                                 });
//                               }
//                               if (widget.text ==
//                                   "Click here to remove your watchlist.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   Navigator.pop(context);
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .filtercase,
//                                           ]));
//                                 });
//                               }
//                               if (widget.text ==
//                                   "Click here to filter the data.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   showModalBottomSheet(
//                                       showDragHandle: true,
//                                       useSafeArea: true,
//                                       isScrollControlled: true,
//                                       shape: const RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.vertical(
//                                               top: Radius.circular(16))),
//                                       backgroundColor: const Color(0xffffffff),
//                                       context: context,
//                                       builder: (context) {
//                                         return const ScripFilterBottomSheet();
//                                       });
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .sortbycase,
//                                           ]));
//                                 });
//                               }
//                               if (widget.text ==
//                                   "Click here to sort your desired preferences.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   Navigator.pop(context);
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .searchiconcase,
//                                           ]));
//                                 });
//                               }
//                               if (widget.text ==
//                                   "click here to view search and add the script.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   marketWatchList.requestMWScrip(
//                                       context: context, isSubscribe: false);
//                                   Navigator.pushNamed(
//                                       context, Routes.searchScrip,
//                                       arguments: marketWatchList.wlName);
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .searchtextfiledcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .searchtabcase
//                                           ]));
//                                 });
//                               }

//                               if (widget.text ==
//                                   "Click here to see the different types on segment search.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   Navigator.pop(context);
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .indexcardcase,
//                                           ]));
//                                 });
//                               }
//                               if (widget.text ==
//                                   "Click here to view all index list.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500),
//                                     () async {
//                                   await context
//                                       .read(indexListProvider)
//                                       .fetchIndexList("NSE", context);
//                                   // _showSimpleDialog(context, widget.indexProvide, index);
//                                   showModalBottomSheet(
//                                       context: context,
//                                       // backgroundColor: ref.read(themeProvider).isDarkMode
//                                       //     ? colors.kColorDarkThemeBackground
//                                       //     : colors.kColorlightThemeBackground,
//                                       isScrollControlled: true,
//                                       showDragHandle: true,
//                                       isDismissible: true,
//                                       shape: const RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(10),
//                                           topRight: Radius.circular(10),
//                                         ),
//                                       ),
//                                       builder: (_) => IndexBottomSheet(
//                                           defaultIndex: widget.index));
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .indexsegmentchangecase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .favindexchangecase,
//                                           ]));
//                                 });
//                               }
//                               if (widget.text ==
//                                   "Click here to update your favourite index list.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   Navigator.pop(context);

//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .scripdatainfocase,
//                                           ]));
//                                 });
//                               }

//                               if (widget.text ==
//                                   "Click here to view the scrip price movement.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500),
//                                     () async {
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .overviewcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .chartcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .optioncase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .futurecase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .fundamentalcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .creategtt,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .placesellbutton,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .placebuybutton,
//                                           ]));

//                                   await ref.watch(marketWatchProvider).fetchScripQuote(
//                                       "${marketWatchScrip[widget.index].token}",
//                                       "${marketWatchScrip[widget.index].exch}",
//                                       context);

//                                   await ref.watch(websocketProvider)
//                                       .establishConnection(
//                                           channelInput:
//                                               "${marketWatchScrip[widget.index].exch}|${marketWatchScrip[widget.index].token}",
//                                           task: "d",
//                                           context: context);

//                                   if (watch(marketWatchProvider)
//                                           .getQuotes!
//                                           .stat ==
//                                       "Ok") {
//                                     await context
//                                         .read(marketWatchProvider)
//                                         .fetchLinkeScrip(
//                                             "${marketWatchScrip[widget.index].token}",
//                                             "${marketWatchScrip[widget.index].exch}");
//                                     print(
//                                         '${marketWatchScrip[widget.index].exch}');
//                                     DepthInputArgs depthArgs = DepthInputArgs(
//                                         exch:
//                                             '${marketWatchScrip[widget.index].exch}',
//                                         token:
//                                             '${marketWatchScrip[widget.index].token}',
//                                         tsym:
//                                             '${marketWatchScrip[widget.index].tsym}',
//                                         instname: marketWatchScrip[widget.index]
//                                                 .instname ??
//                                             "",
//                                         symbol:
//                                             '${marketWatchScrip[widget.index].symbol}',
//                                         expDate:
//                                             '${marketWatchScrip[widget.index].expDate}',
//                                         option:
//                                             '${marketWatchScrip[widget.index].option}');

//                                     showModalBottomSheet(
//                                         barrierColor: Colors.transparent,
//                                         isScrollControlled: true,
//                                         useSafeArea: true,
//                                         isDismissible: true,
//                                         shape: const RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.vertical(
//                                                 top: Radius.circular(16))),
//                                         backgroundColor:
//                                             const Color(0xffffffff),
//                                         context: context,
//                                         builder: (context) =>
//                                             ScripDepthInfo(wlValue: depthArgs));
//                                   }
//                                 });
//                               }
//                               if (widget.text ==
//                                   "click here to place buy order.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500),
//                                     () async {
//                                   Navigator.pop(context);
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .portfolioiconcase,
//                                           ]));
//                                 });
//                               }
//                               if (widget.text ==
//                                   "Click here to view the portfolio page.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500),
//                                     () async {
//                                   await context
//                                       .read(indexListProvider)
//                                       .checkSession(context);
//                                   await marketWatchList
//                                       .requestMWScrip(
//                                           context: context, isSubscribe: false);

//                                   await context
//                                       .read(orderProvider)
//                                       .requestWSOrderBook(
//                                           context: context, isSubscribe: false);

//                                   portfolio.requestWSHoldings(
//                                       context: context, isSubscribe: false);
//                                   await portfolio.requestWSPosition(
//                                       context: context, isSubscribe: true);
//                                   portfolio.tabSize();
//                                   indexProvide.bottomMenu(1);
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase(
//                                             [
//                                               if (portfolio.postionBookModel![0]
//                                                       .stat ==
//                                                   "Ok") ...[
//                                                 context
//                                                     .read(showcaseProvide)
//                                                     .daynetswitchcase,
//                                               ],
//                                               context
//                                                   .read(showcaseProvide)
//                                                   .positiontabcase,
//                                               context
//                                                   .read(showcaseProvide)
//                                                   .netmtmcase,
//                                               context
//                                                   .read(showcaseProvide)
//                                                   .netplcase,
//                                               // context
//                                               //     .read(showcaseProvide)
//                                               //     .postiondetailscase,
//                                               // context
//                                               //     .read(showcaseProvide)
//                                               //     .exiteallpositioncase,
//                                               // if (portfolio
//                                               //         .allPostionList.length >
//                                               //     1) ...[
//                                               //   context
//                                               //       .read(showcaseProvide)
//                                               //       .filterlinecase,
//                                               // ],
//                                               // if (portfolio
//                                               //         .allPostionList.length >
//                                               //     1) ...[
//                                               //   context
//                                               //       .read(showcaseProvide)
//                                               //       .searchcase,
//                                               // ],
//                                             ],
//                                           ));
//                                 });
//                               }
//                               // if (widget.text ==
//                               //     "Click here to view the position conversation, add, and reduce the position.") {
//                               //   Future.delayed(
//                               //       const Duration(milliseconds: 500),
//                               //       () async {
//                               //     // Navigator.push(
//                               //     //     context,
//                               //     //     MaterialPageRoute(
//                               //     //         builder: (context) =>
//                               //     //             PositionDummyDetailScreen()));
//                               //     WidgetsBinding.instance.addPostFrameCallback(
//                               //         (_) => ShowCaseWidget.of(context)
//                               //                 .startShowCase([
//                               //               context
//                               //                   .read(showcaseProvide)
//                               //                   .postionconvertioncase,
//                               //               context
//                               //                   .read(showcaseProvide)
//                               //                   .postionaddmorebtncase,
//                               //               context
//                               //                   .read(showcaseProvide)
//                               //                   .postionexitbtncase,
//                               //             ]));
//                               //   });
//                               // }

//                               if (widget.text ==
//                                   "Click here to view net profit and loss.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   portfolio.portTab.animateTo(widget.index + 1);
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .holdingstabcase,
//                                           ]));
//                                 });
//                               }

//                               if (widget.text ==
//                                   "Click here to view holdings detials.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .holdingsediscase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .holdingsfilterlinecase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .holdingsearchcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .holdinglistcard
//                                           ]));
//                                 });
//                               }
//                               if (widget.text ==
//                                   "Click here to view. Add or reduce your holdings.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   Navigator.pushNamed(
//                                       context, Routes.holdingDetail,
//                                       arguments: {
//                                         "holdingData": holdingProvide
//                                             .holdingsModel![widget.index],
//                                         "exchTsym": holdingProvide
//                                             .holdingsModel![widget.index]
//                                             .exchTsym![0]
//                                       });
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .holdingdetailsaddmorecase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .holdingexitcase
//                                           ]));
//                                 });
//                               }

//                               if (widget.text ==
//                                   "Click here to withdraw your holding shares.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   Navigator.pop(context);
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .ordericoncase
//                                           ]));
//                                 });
//                               }
//                               if (widget.text ==
//                                   "Click here to view the order page.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500),
//                                     () async {
//                                   indexProvide.bottomMenu(2);
//                                   orderbook.tabSize();
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .alltabcase,
//                                             if (orderbook
//                                                     .orderBookModel!.length >
//                                                 1) ...[
//                                               context
//                                                   .read(showcaseProvide)
//                                                   .alllistcardcase,
//                                             ],
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .opentabcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .executedtabcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .gttttabcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .tradebooktabcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .profileiconcase
//                                           ]));

//                                   await context
//                                       .read(orderProvider)
//                                       .fetchTradeBook(context);

//                                   await context
//                                       .read(orderProvider)
//                                       .fetchGTTOrderBook(context,"initLoad");
//                                   await marketWatchList
//                                       .requestMWScrip(
//                                           context: context, isSubscribe: false);
//                                   await portfolio.requestWSHoldings(
//                                       context: context, isSubscribe: false);

//                                   await portfolio.requestWSPosition(
//                                       context: context, isSubscribe: false);
//                                   await indexProvide.requestdefaultIndex(
//                                       context: context, isSubscribe: false);

//                                   await context
//                                       .read(orderProvider)
//                                       .requestWSOrderBook(
//                                           context: context, isSubscribe: true);

//                                   // await context
//                                   //     .read(orderProvider)
//                                   //     .reqWSGTTBook(
//                                   //         context: context, isSubscribe: true);
//                                 });
//                               }
//                               // if (text ==
//                               //     "Click here to view your excuted order.") {
//                               //   Future.delayed(
//                               //       const Duration(milliseconds: 500), () {
//                               //     WidgetsBinding.instance.addPostFrameCallback(
//                               //         (_) => ShowCaseWidget.of(context)
//                               //                 .startShowCase([
//                               //               context
//                               //                   .read(showcaseProvide)
//                               //                   .profileiconcase
//                               //             ]));
//                               //   });
//                               // }
//                               if (widget.text ==
//                                   "Click here to view the profile page.") {
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   indexProvide.bottomMenu(3);
//                                   context
//                                       .read(fundProvider)
//                                       .fetchFunds(context);
//                                   context
//                                       .read(userProfileProvider)
//                                       .fetchprofilemenu();

//                                   indexProvide.requestdefaultIndex(
//                                       context: context, isSubscribe: false);

//                                   marketWatchList.requestMWScrip(
//                                       context: context, isSubscribe: false);
//                                   portfolio.requestWSHoldings(
//                                       context: context, isSubscribe: false);

//                                   context
//                                       .read(orderProvider)
//                                       .requestWSOrderBook(
//                                           context: context, isSubscribe: false);
//                                   portfolio.requestWSPosition(
//                                       context: context, isSubscribe: false);
//                                   WidgetsBinding.instance.addPostFrameCallback(
//                                       (_) => ShowCaseWidget.of(context)
//                                               .startShowCase([
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .viewswitchaccountcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .fundcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .accountcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .reportcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .corporateactioncase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .pledgeunpcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .changepasswordcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .theamcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .logcase,
//                                             context
//                                                 .read(showcaseProvide)
//                                                 .stokscase,
//                                           ]));
//                                 });
//                               }

//                               WidgetsBinding.instance.addPostFrameCallback(
//                                   (_) => ShowCaseWidget.of(context).next());
//                               // widget.index == 2 ||
//                               //         widget.index == 3 ||
//                               //         widget.index == 4 ||
//                               //         widget.index == 5 ||
//                               //         widget.index == 6
//                               //     ? scrollToIndex(widget.index, dd, context)
//                               //     : null;

//                               // if (widget.index <
//                               //     orderbook.orderTabName.length - 1) {
//                               //   orderbook.tabCtrl.animateTo(widget.index + 1);
//                               // }
//                             },
//                             style: ElevatedButton.styleFrom(
//                                 elevation: 0,
//                                 backgroundColor: const Color(0xff000000),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(50),
//                                 )),
//                             child: Text("Next",
//                                 style: textStyle(const Color(0xffFFFFFF), 14,
//                                     FontWeight.w500)),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             child: widget.childs);
//       },
//     );
//   }

//   scrollToIndex(int index, ShowCaseProvider dd, BuildContext context) {
//     double offset = index == 2 || index == 3 || index == 4 ? index * 60 : 0;

//     dd.controller.jumpTo(
//       offset,
//       // duration: const Duration(milliseconds: 500),
//       // curve: Curves.easeInOut,
//     );
//   }

//   scrolltabbarindex(int index, OrderProvider orderbook, BuildContext context) {
//     if (index < orderbook.orderTabName.length - 1) {
//       orderbook.tabCtrl.animateTo(index + 1);
//     }
//   }

//   portfoliotabbarindex(
//       int index, OrderProvider orderbook, BuildContext context) {
//     if (index < orderbook.orderTabName.length - 1) {
//       orderbook.tabCtrl.animateTo(index + 1);
//     }
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle:
//             TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
//   }

//   Text headerTitleText(String text) {
//     return Text(text,
//         style: textStyle(const Color(0xff000000), 14, FontWeight.w500));
//   }
// }
