// import 'package:flutter/material.dart';
// import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../model/action_trade_model.dart';
// import '../../../../model/trade_menu_popup.dart';
// import '../../../../provider/stocks_provider.dart';
// import '../../../../res/res.dart';
// import '../../../../routes/route_names.dart';
// import '../../../../screens/stocks/tradeAction/trade_Events/trade_event.dart';
// import '../../../../screens/stocks/tradeAction/trade_action_chart.dart';
// import '../../../../screens/stocks/tradeAction/trade_alert/trade_alert.dart';
// import '../../../../screens/stocks/tradeAction/trade_market_depth.dart';
// import '../../sharedWidget/scrollable_btn.dart';

// class SeeMoreStocks extends StatefulWidget {
//   const SeeMoreStocks({super.key});

//   @override
//   State<SeeMoreStocks> createState() => _SeeMoreStocksState();
// }

// class _SeeMoreStocksState extends State<SeeMoreStocks> {
//   int selectedBtn = 0;

//   List<String> tradeAction = [
//     "Top gainer",
//     "Trending",
//     "Volume breakout",
//     "Most active"
//   ];

//   List<bool> isActiveBtns = [true, false, false, false];
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(builder: (context, ScopedReader watch, _) {
//       final actionTrade = watch(stocksProvide);
//       return Scaffold(
//         backgroundColor: const Color(0xffFFFFFF),
//         appBar: AppBar(
//           backgroundColor: const Color(0xffFFFFFF),
//           leadingWidth: 30,
//           elevation: .3,
//           iconTheme: const IconThemeData(color: Color(0xff000000)),
//           title: Text(
//             'More stocks',
//             style: textStyles.appBarTitleTxt,
//           ),
//           actions: [
//             SvgPicture.asset(assets.editIcon),
//             const SizedBox(
//               width: 14,
//             ),
//             SvgPicture.asset(assets.searchIcon),
//             const SizedBox(
//               width: 16,
//             ),
//           ],
//         ),
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 16.0, top: 16),
//               child: Text(
//                 "Today’s trade action",
//                 style: GoogleFonts.inter(
//                     textStyle: textStyle(
//                         const Color(0xff000000), 16, FontWeight.w600)),
//               ),
//             ),
//             const SizedBox(height: 14),
//             Padding(
//               padding: const EdgeInsets.only(left: 16.0),
//               child: SizedBox(
//                   height: 35,
//                   child: ScrollableBtn(
//                       btnActive: isActiveBtns, btnName: tradeAction)),
//             ),
//             const SizedBox(height: 12),
//             ExpandedTileList.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               itemCount: actionTrade.actionTrademodel!.length,
//               maxOpened: 1,
//               shrinkWrap: true,
//               reverse: selectedBtn == 0 ? true : false,
//               itemBuilder: (context, index, controller) {
//                 return ExpandedTile(
//                   disableAnimation: true,
//                   contentseparator: 0,
//                   trailingRotation: 90,
//                   theme: const ExpandedTileThemeData(
//                       headerColor: Color(0xffFFFFFF),
//                       headerPadding:
//                           EdgeInsets.symmetric(vertical: 8, horizontal: 0),
//                       //   headerSplashColor: Colors.red,
//                       contentBackgroundColor: Color(0xffF1F3F8),
//                       contentPadding: EdgeInsets.all(12.0),
//                       //   contentRadius: 12.0,
//                       trailingPadding: EdgeInsets.all(0)),
//                   controller: controller,
//                   title: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("${actionTrade.actionTrademodel![index].tsym}",
//                               style: GoogleFonts.inter(
//                                   textStyle: textStyle(const Color(0xff000000),
//                                       15, FontWeight.w600))),
//                           const SizedBox(height: 8),
//                           Text(
//                               "Vol. :₹${actionTrade.actionTrademodel![index].volume}k",
//                               style: GoogleFonts.inter(
//                                   textStyle: textStyle(const Color(0xff999999),
//                                       14, FontWeight.w500))),
//                         ],
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text("₹${actionTrade.actionTrademodel![index].ltp}",
//                               style: GoogleFonts.inter(
//                                   textStyle: textStyle(const Color(0xff000000),
//                                       14, FontWeight.w600))),
//                           const SizedBox(height: 8),
//                           Text(
//                               "${actionTrade.actionTrademodel![index].perChange}%",
//                               style: GoogleFonts.inter(
//                                   textStyle: textStyle(
//                                       actionTrade.actionTrademodel![index]
//                                               .perChange!
//                                               .startsWith("-")
//                                           ? const Color(0xffE00000)
//                                           : const Color(0xff43A833),
//                                       14,
//                                       FontWeight.w600))),
//                         ],
//                       ),
//                     ],
//                   ),
//                   content: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               showModalBottomSheet(
//                                   isScrollControlled: true,
//                                   // showDragHandle: true,
//                                   shape: const RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.vertical(
//                                           top: Radius.circular(16))),
//                                   backgroundColor: const Color(0xffffffff),
//                                   context: context,
//                                   builder: (context) {
//                                     return TradeActionChart(
//                                         tradeaction: actionTrade
//                                             .actionTrademodel![index]);
//                                   });
//                             },
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                   color: Color(0xffFFFFFF),
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(4))),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: SvgPicture.asset(assets.charticon),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           InkWell(
//                             onTap: () {
//                               showModalBottomSheet(
//                                   isScrollControlled: true,
//                                   // showDragHandle: true,
//                                   shape: const RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.vertical(
//                                           top: Radius.circular(16))),
//                                   backgroundColor: const Color(0xffffffff),
//                                   context: context,
//                                   builder: (context) {
//                                     return TradeAlert(
//                                         tradeaction: actionTrade
//                                             .actionTrademodel![index]);
//                                   });
//                             },
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                   color: Color(0xffFFFFFF),
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(4))),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: SvgPicture.asset(assets.flagicon),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           InkWell(
//                             onTap: () {
//                               showModalBottomSheet(
//                                   isScrollControlled: true,
//                                   // showDragHandle: true,
//                                   shape: const RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.vertical(
//                                           top: Radius.circular(16))),
//                                   backgroundColor: const Color(0xffffffff),
//                                   context: context,
//                                   builder: (context) {
//                                     return TradeEvent(
//                                         tradeaction: actionTrade
//                                             .actionTrademodel![index]);
//                                   });
//                             },
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                   color: Color(0xffFFFFFF),
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(4))),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: SvgPicture.asset(assets.calendaricon),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             height: 30,
//                             width: 30,
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffFFFFFF),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(4))),
//                             child: PopupMenuButton<TradeMenuItems>(
//                                 elevation: 0,
//                                 surfaceTintColor: const Color(0xff000000),
//                                 onSelected: (item) => onSelected(context, item,
//                                     actionTrade.actionTrademodel![index]),
//                                 color: const Color(0xffFFFFFF),
//                                 splashRadius: BorderSide.strokeAlignOutside,
//                                 // shape: Border.all(color: Color(0xffEBEEF0)),
//                                 shape: const RoundedRectangleBorder(
//                                   side: BorderSide(color: Color(0xffEBEEF0)),
//                                   borderRadius: BorderRadius.all(
//                                     Radius.circular(12),
//                                   ),
//                                 ),
//                                 padding: const EdgeInsets.all(3.2),
//                                 offset: const Offset(10, 35),
//                                 icon: const Icon(
//                                   Icons.more_horiz,
//                                   color: Color(0xff666666),
//                                 ),
//                                 itemBuilder: (context) => [
//                                       ...TradeMenuItem.tradepopup
//                                           .map(buildItem)
//                                           ,
//                                     ]),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           SizedBox(
//                             height: 28,
//                             // padding:
//                             //     EdgeInsets.symmetric(horizontal: 11, vertical: 4),
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 // OrderScreenArgs orderArgs = OrderScreenArgs(
//                                 //     exchange: 'NSE',
//                                 //     tSym:
//                                 //         '${actionTrade.actionTrademodel![index].tsym}',
//                                 //     token: '',
//                                 //     transType: true,
//                                 //     change: '',
//                                 //     close: '',
//                                 //     lotSize: '',
//                                 //     ltp: '',
//                                 //     perChange: '',
//                                 //     isEquity: '');

//                                 // showModalBottomSheet(
//                                 //     showDragHandle: true,
//                                 //     useSafeArea: true,
//                                 //     isScrollControlled: true,
//                                 //     shape: const RoundedRectangleBorder(
//                                 //         borderRadius: BorderRadius.vertical(
//                                 //             top: Radius.circular(16))),
//                                 //     backgroundColor: const Color(0xffffffff),
//                                 //     context: context,
//                                 //     builder: (context) => OrderBottomScreen(
//                                 //         orderScreenArgs: orderArgs));
//                               },
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xff43A833),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6))),
//                               child: Text("BUY",
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xffFFFFFF),
//                                           12,
//                                           FontWeight.w600))),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           SizedBox(
//                             height: 28,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 // Navigator.push(
//                                 //     context,
//                                 //     MaterialPageRoute(
//                                 //         builder: (context) => OrderScreenPage()));
//                                 // OrderScreenArgs orderArgs = OrderScreenArgs(
//                                 //     exchange: 'NSE',
//                                 //     tSym:
//                                 //         '${actionTrade.actionTrademodel![index].tsym}',
//                                 //     token: '',
//                                 //     transType: false,
//                                 //     change: '',
//                                 //     close: '',
//                                 //     lotSize: '',
//                                 //     ltp: '',
//                                 //     perChange: '',
//                                 //     isEquity: '');
//                                 // showModalBottomSheet(
//                                 //     showDragHandle: true,
//                                 //     isScrollControlled: true,
//                                 //     useSafeArea: true,
//                                 //     shape: const RoundedRectangleBorder(
//                                 //         borderRadius: BorderRadius.vertical(
//                                 //             top: Radius.circular(16))),
//                                 //     backgroundColor: const Color(0xffffffff),
//                                 //     context: context,
//                                 //     builder: (context) => OrderBottomScreen(
//                                 //         orderScreenArgs: orderArgs));
//                               },
//                               style: ElevatedButton.styleFrom(
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6)),
//                                   backgroundColor: const Color(0xffFF1717)),
//                               child: Text("SELL",
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xffFFFFFF),
//                                           12,
//                                           FontWeight.w600))),
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                   onTap: () {
//                     debugPrint("tapped!!");
//                   },
//                   onLongTap: () {
//                     debugPrint("looooooooooong tapped!!");
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     );
//   }

//   PopupMenuItem<TradeMenuItems> buildItem(TradeMenuItems item) =>
//       PopupMenuItem<TradeMenuItems>(
//           value: item,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   SvgPicture.asset(
//                     item.img,
//                   ),
//                   const SizedBox(
//                     width: 12,
//                   ),
//                   Text(
//                     item.text,
//                     style: GoogleFonts.inter(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: const Color(0xff666666),
//                         letterSpacing: 0.28),
//                   ),
//                 ],
//               ),
//               SvgPicture.asset(assets.productIcon),
//             ],
//           ));
//   void onSelected(
//     BuildContext context,
//     TradeMenuItems item,
//     ActionTradeModel actionTradeModel,
//   ) {
//     switch (item) {
//       case TradeMenuItem.itesmtradingview:
//         Navigator.pushNamed(context, Routes.tradeingview,
//             arguments: actionTradeModel);
//         break;
//       case TradeMenuItem.itesmarketdepth:
//         showModalBottomSheet(
//             isScrollControlled: true,
//             // showDragHandle: true,
//             shape: const RoundedRectangleBorder(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//             backgroundColor: const Color(0xffffffff),
//             context: context,
//             builder: (BuildContext context) {
//               return TradeMarketDepth(tradedata: actionTradeModel);
//             });
//         break;
//       case TradeMenuItem.itessetgtt:
//         // Navigator.pushNamed(context, Routes.setgttorder,
//         //     arguments: actionTradeModel);
//         break;
//       case TradeMenuItem.itesalertgtt:
//       // Navigator.pushNamed(context, Routes.setalert,
//       //     arguments: actionTradeModel);
//     }
//   }
// }
