// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/tradeAction/trade_fandamental.dart';
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_analyst_reco.dart';
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_event_news.dart';
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_events.dart';
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_finacial_year.dart';
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_financial_health.dart';
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_mfi.dart';
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_price_compersoin.dart';
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/tarde_stock_analsyt.dart';
// import '../../../../screens/stocks/tradeAction/trading_view_price_chart.dart'; 

// class TradingViewMenu extends StatefulWidget {
//   final ActionTradeModel tradedata;
//   const TradingViewMenu({super.key, required this.tradedata});

//   @override
//   State<TradingViewMenu> createState() => _TradingViewMenuState();
// }

// class _TradingViewMenuState extends State<TradingViewMenu>
//     with SingleTickerProviderStateMixin {
//   List<String> tabList = [
//     "Overview",
//     "Fundamental",
//     "Analyst Forecasts",
//     "Finalcials",
//     "Peers",
//     "Holdings",
//     "Events",
//     "News"
//   ];
//   double low = 0.00;
//   double high = 0.00;
//   double price = 0.00;
//   double scrollHeight = 0.00;
//   int indicesLength = 0;
//   bool hideMore = false;
//   List<String> chartDuration = ["1M", "3M", "6M", "1YR", "3YR", "MAX"];
//   List<bool> isActiveBtn = [true, false, false, false, false, false];

//   late TabController tabController;
//   static const kExpandedHeight = 170.0;
//   late AutoScrollController autoScrollController;
//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: tabList.length, vsync: this);
//     autoScrollController = AutoScrollController();
//     _scrollController = ScrollController()
//       ..addListener(() {
//         setState(() {
//           _isSliverAppBarExpanded;
//         });
//       });
//   }

//   @override
//   void dispose() {
//     autoScrollController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   bool get _isSliverAppBarExpanded {
//     return _scrollController.hasClients &&
//         _scrollController.offset > kExpandedHeight - kToolbarHeight;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       body: VerticalScrollableTabView(
//           autoScrollController: autoScrollController,
//           tabController: tabController,
//           listItemData: tabList,
//           eachItemChild: (aaa, int index) {
//             return Column(
//               children: [
//                 if (aaa == "Overview") ...[
//                   const TradingViewPriceChart(),
//                 ],
//                 if (aaa == "Fundamental") ...[
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//                     child: EftFundamental(),
//                   ),
//                   const Divider(
//                     color: Color(0xffDDDDDD),
//                   ),
//                 ],
//                 if (aaa == "Analyst Forecasts") ...[
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: EftAnalystRecommendation(),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   const Divider(
//                     color: Color(0xffDDDDDD),
//                   ),
//                 ],
//                 if (aaa == "Finalcials") ...[
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: SectorFinancialHealth(),
//                   ),
//                   const SizedBox(
//                     height: 16,
//                   ),
//                   const SectorFinacinalYear(),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const Divider(
//                     color: Color(0xffECEDEE),
//                     // color: Colors.black,
//                   ),
//                 ],
//                 if (aaa == "Peers") ...[
//                   const PriceCompersion(),
//                   const SizedBox(
//                     height: 28,
//                   ),
//                 ],
//                 if (aaa == "Holdings") ...[
//                   const EftAnalystRecommentation(),
//                   const SizedBox(
//                     height: 28,
//                   ),
//                   const EftMutualFundsHoldingTrend(),
//                   const SizedBox(
//                     height: 22,
//                   ),
//                 ],
//                 if (aaa == "Events") ...[
//                   const EftEvent(),
//                   const SizedBox(
//                     height: 28,
//                   ),
//                 ],
//                 if (aaa == "News") ...[
//                   const EftEventNews(),
//                 ],
//               ],
//             );
//           },
//           slivers: [
//             SliverAppBar(
//               toolbarHeight: 50,
//               pinned: true,
//               iconTheme: const IconThemeData(color: Colors.black),
//               leadingWidth: 32,
//               elevation: .4,
//               centerTitle: false,
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Trading View',
//                     style: GoogleFonts.inter(
//                       color: const Color(0xff000000),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SvgPicture.asset(
//                     assets.threedots,
//                     color: const Color(0xff6666666),
//                   ),
//                 ],
//               ),
//               // style:
//               //     TextStyle(  Color(0xff000000), 14, FontWeight.w600)),
//               backgroundColor: const Color(0xffFFFFFF),
//               expandedHeight: scrollHeight > 30 ? 60 : 200,
//               // expandedHeight: 250.0,

//               flexibleSpace: FlexibleSpaceBar(
//                 background: Container(
//                   color: const Color(0xffFAFBFF),
//                 ),
//                 title: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${widget.tradedata.tsym}',
//                       style: GoogleFonts.inter(
//                         color: const Color(0xff000000),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.36,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Text(
//                       '₹ ${widget.tradedata.ltp}',
//                       style: GoogleFonts.inter(
//                         color: const Color(0xff000000),
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 3,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '${widget.tradedata.perChange} (${widget.tradedata.change}%)',
//                           style: GoogleFonts.inter(
//                             color: widget.tradedata.perChange!.startsWith("-")
//                                 ? const Color(0xffFF1717)
//                                 : const Color(0xff43A833),
//                             fontSize: 8,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               'APR 20, 2023 11:57 IST',
//                               style: GoogleFonts.inter(
//                                 color: const Color(0xff666666),
//                                 fontSize: 7,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             Text(
//                               '  OPEN',
//                               style: GoogleFonts.inter(
//                                 color: const Color(0xff43A833),
//                                 fontSize: 7,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//                 centerTitle: false,
//                 titlePadding: EdgeInsets.only(
//                     left: scrollHeight > 20 ? 70 : 12,
//                     bottom: 40,
//                     top: scrollHeight == 5
//                         ? 130
//                         : scrollHeight <= 15
//                             ? 120
//                             : scrollHeight <= 20
//                                 ? 110
//                                 : scrollHeight <= 30
//                                     ? 100
//                                     : scrollHeight <= 40
//                                         ? 90
//                                         : scrollHeight <= 50
//                                             ? 80
//                                             : scrollHeight <= 60
//                                                 ? 70
//                                                 : scrollHeight <= 70
//                                                     ? 60
//                                                     : 34,
//                     right: 12),
//               ),
//               // flexibleSpace: FlexibleSpaceBar(
//               //   background: Container(
//               //     color: const Color(0xffFFFFFF),
//               //   ),
//               //   title: Column(
//               //     crossAxisAlignment: CrossAxisAlignment.start,
//               //     children: [
//               //       Text(
//               //         '${widget.tradedata.tsym}',
//               //         style: GoogleFonts.inter(
//               //           color: Color(0xff000000),
//               //           fontSize: 12,
//               //           fontWeight: FontWeight.w600,
//               //           letterSpacing: 0.36,
//               //         ),
//               //       ),
//               //       const SizedBox(
//               //         height: 5,
//               //       ),
//               //       Text(
//               //         '₹ ${widget.tradedata.ltp}',
//               //         style: GoogleFonts.inter(
//               //           color: Color(0xff000000),
//               //           fontSize: 10,
//               //           fontWeight: FontWeight.w600,
//               //         ),
//               //       ),
//               //       const SizedBox(
//               //         height: 3,
//               //       ),
//               //       Row(
//               //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //         children: [
//               //           Text(
//               //             '${widget.tradedata.perChange} (${widget.tradedata.change}%)',
//               //             style: GoogleFonts.inter(
//               //               color: widget.tradedata.perChange!.startsWith("-")
//               //                   ? Color(0xffFF1717)
//               //                   : Color(0xff43A833),
//               //               fontSize: 8,
//               //               fontWeight: FontWeight.w600,
//               //             ),
//               //           ),
//               //           Row(
//               //             children: [
//               //               Text(
//               //                 'APR 20, 2023 11:57 IST',
//               //                 style: GoogleFonts.inter(
//               //                   color: Color(0xff666666),
//               //                   fontSize: 7,
//               //                   fontWeight: FontWeight.w500,
//               //                 ),
//               //               ),
//               //               Text(
//               //                 '  OPEN',
//               //                 style: GoogleFonts.inter(
//               //                   color: Color(0xff43A833),
//               //                   fontSize: 7,
//               //                   fontWeight: FontWeight.w500,
//               //                 ),
//               //               ),
//               //             ],
//               //           )
//               //         ],
//               //       ),
//               //     ],
//               //   ),
//               //   centerTitle: false,
//               //   titlePadding: EdgeInsets.only(
//               //       left: scrollHeight > 20 ? 70 : 12,
//               //       bottom: 40,
//               //       top: scrollHeight == 5
//               //           ? 130
//               //           : scrollHeight <= 15
//               //               ? 120
//               //               : scrollHeight <= 20
//               //                   ? 110
//               //                   : scrollHeight <= 30
//               //                       ? 100
//               //                       : scrollHeight <= 40
//               //                           ? 90
//               //                           : scrollHeight <= 50
//               //                               ? 80
//               //                               : scrollHeight <= 60
//               //                                   ? 70
//               //                                   : scrollHeight <= 70
//               //                                       ? 60
//               //                                       : 34,
//               //       right: 12),
//               // ),

//               bottom: TabBar(
//                 isScrollable: true,
//                 controller: tabController,
//                 indicatorPadding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 indicatorColor: Colors.black,
//                 labelColor: Colors.black,
//                 unselectedLabelColor: Colors.grey,
//                 indicatorWeight: 3.0,
//                 tabs: tabList.map((e) {
//                   return Tab(text: e);
//                 }).toList(),
//                 onTap: (index) {
//                   VerticalScrollableTabBarStatus.setIndex(index);
//                 },
//               ),
//             ),
//           ]),
//     );
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle: TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     ));
//   }
// }
