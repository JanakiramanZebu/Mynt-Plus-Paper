// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_expanded_tile/flutter_expanded_tile.dart'; 
// import '../../../../res/res.dart';
// import '../../../../routes/route_names.dart';
// import '../../../../screens/stocks/tradeAction/trade_market_depth.dart';

// import '../../../../provider/stocks_provider.dart';

// class TradeAction extends StatefulWidget {
//   const TradeAction({super.key});

//   @override
//   State<TradeAction> createState() => _TradeActionState();
// }

// class _TradeActionState extends State<TradeAction> {
//   List<String> tradeAction = [
//     "Top gainers",
//     "Top losers",
//     "Volume",
//     "Value"
//   ];  

//   @override
//   Widget build(BuildContext context) {
//     // double screenWidth = MediaQuery.of(context).size.width;
//     return Consumer(builder: (context, ScopedReader watch, _) {
//       final actionTrade = watch(stocksProvide);
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Today's trade action",
//                     style: GoogleFonts.inter(
//                         textStyle: textStyle(
//                             const Color(0xff000000), 16, FontWeight.w600))),
//                 DropdownButtonHideUnderline(
//                   child: DropdownButton2(
//                     // buttonDecoration: const BoxDecoration(
//                     //     color: Color(0xffF1F3F8),
//                     //     // border: Border.all(color: Colors.grey),
//                     //     borderRadius: BorderRadius.all(Radius.circular(32))),

//                     dropdownStyleData: DropdownStyleData(
//               width: 160,
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(4),
//                 color: Colors.redAccent,
//               ),
//               offset: const Offset(0, 8),
//             ),
//                     // buttonSplashColor: Colors.transparent,
//                     isExpanded: true,
//                     style:
//                         textStyle(const Color(0XFF000000), 13, FontWeight.w500),
//                     hint: Text(actionTrade.selctedTradeAct,
//                         style: textStyle(
//                             const Color(0XFF000000), 13, FontWeight.w500)),
//                     items: actionTrade.addDividersAfterExpDates(),
//                     // customItemsHeights: actionTrade.getCustomItemsHeight(),
//                     value: actionTrade.selctedTradeAct,
//                     onChanged: (value) async {
//                       actionTrade.chngTradeAct("$value");
//                     },
//                     // buttonHeight: 36,
//                     // buttonWidth: 120,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//               height: 35,
//               child: ListView.separated(
//                 padding: const EdgeInsets.only(left: 16.0),
//                 scrollDirection: Axis.horizontal,
//                 itemCount: tradeAction.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(
//                         width: 1,
//                         color: tradeAction[index] == actionTrade.tradeData
//                             ? const Color(0xff000000)
//                             : const Color(0xff666666),
//                       ),
//                       shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(40))),
//                     ),
//                     onPressed: () async {
//                       actionTrade.chngTradeAction(tradeAction[index]);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 5.0),
//                       child: Text(
//                         tradeAction[index],
//                         style: textStyle(
//                             tradeAction[index] == actionTrade.tradeData
//                                 ? const Color(0xff000000)
//                                 : const Color(0xff666666),
//                             14,
//                             FontWeight.w600),
//                       ),
//                     ),
//                   );
//                 },
//                 separatorBuilder: (BuildContext context, int index) {
//                   return const SizedBox(width: 8);
//                 },
//               )),
//           const SizedBox(height: 12),
//           ExpandedTileList.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             itemCount: actionTrade.topStockData.length,
//             maxOpened: 1,
//             shrinkWrap: true,
//             itemBuilder: (context, index, controller) {
//               return ExpandedTile(
//                 disableAnimation: true,
//                 contentseparator: 0,
//                 trailingRotation: 90,
//                 theme: const ExpandedTileThemeData(
//                     headerColor: Color(0xffFFFFFF),
//                     headerPadding:
//                         EdgeInsets.symmetric(vertical: 8, horizontal: 0),
//                     //   headerSplashColor: Colors.red,
//                     contentBackgroundColor: Color(0xffF1F3F8),
//                     contentPadding: EdgeInsets.all(12.0),
//                     //   contentRadius: 12.0,
//                     trailingPadding: EdgeInsets.all(0)),
//                 controller: controller,
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("${actionTrade.topStockData[index].tsym}",
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff000000),
//                                     15, FontWeight.w600))),
//                         const SizedBox(height: 8),
//                         Text("Vol :₹${actionTrade.topStockData[index].v}",
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff999999),
//                                     14, FontWeight.w500))),
//                       ],
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text("₹${actionTrade.topStockData[index].lp}",
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff000000),
//                                     14, FontWeight.w600))),
//                         const SizedBox(height: 8),
//                         Text("${actionTrade.topStockData[index].pc}%",
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(
//                                     actionTrade.topStockData[index].pc!
//                                             .startsWith("-")
//                                         ? const Color(0xffE00000)
//                                         : const Color(0xff43A833),
//                                     14,
//                                     FontWeight.w600))),
//                       ],
//                     ),
//                   ],
//                 ),
//                 content: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             // showModalBottomSheet(
//                             //     isScrollControlled: true,
//                             //     // showDragHandle: true,
//                             //     shape: const RoundedRectangleBorder(
//                             //         borderRadius: BorderRadius.vertical(
//                             //             top: Radius.circular(16))),
//                             //     backgroundColor: const Color(0xffffffff),
//                             //     context: context,
//                             //     builder: (context) {
//                             //       return TradeActionChart(
//                             //           tradeaction:
//                             //               tradeAction ![index]);
//                             //     });
//                           },
//                           child: Container(
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffFFFFFF),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(4))),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(assets.charticon),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         InkWell(
//                           onTap: () {
//                             // showModalBottomSheet(
//                             //     isScrollControlled: true,
//                             //     // showDragHandle: true,
//                             //     shape: const RoundedRectangleBorder(
//                             //         borderRadius: BorderRadius.vertical(
//                             //             top: Radius.circular(16))),
//                             //     backgroundColor: const Color(0xffffffff),
//                             //     context: context,
//                             //     builder: (context) {
//                             //       return TradeAlert(
//                             //           tradeaction:
//                             //               tradeAction ![index]);
//                             //     });
//                           },
//                           child: Container(
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffFFFFFF),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(4))),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(assets.flagicon),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         InkWell(
//                           onTap: () {
//                             // showModalBottomSheet(
//                             //     isScrollControlled: true,
//                             //     // showDragHandle: true,
//                             //     shape: const RoundedRectangleBorder(
//                             //         borderRadius: BorderRadius.vertical(
//                             //             top: Radius.circular(16))),
//                             //     backgroundColor: const Color(0xffffffff),
//                             //     context: context,
//                             //     builder: (context) {
//                             //       return TradeEvent(
//                             //           tradeaction:
//                             //               tradeAction ![index]);
//                             //     });
//                           },
//                           child: Container(
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffFFFFFF),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(4))),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(assets.calendaricon),
//                             ),
//                           ),
//                         ),
//                         // const SizedBox(width: 8),
//                         // Container(
//                         //   height: 30,
//                         //   width: 30,
//                         //   decoration: const BoxDecoration(
//                         //       color: Color(0xffFFFFFF),
//                         //       borderRadius:
//                         //           BorderRadius.all(Radius.circular(4))),
//                         //   child: PopupMenuButton<TradeMenuItems>(
//                         //       elevation: 0,
//                         //       surfaceTintColor: Color(0xff000000),
//                         //       onSelected: (item) => onSelected(context, item,
//                         //           tradeAction ![index]),
//                         //       color: Color(0xffFFFFFF),
//                         //       splashRadius: BorderSide.strokeAlignOutside,
//                         //       // shape: Border.all(color: Color(0xffEBEEF0)),
//                         //       shape: const RoundedRectangleBorder(
//                         //         side: BorderSide(color: Color(0xffEBEEF0)),
//                         //         borderRadius: BorderRadius.all(
//                         //           Radius.circular(12),
//                         //         ),
//                         //       ),
//                         //       padding: const EdgeInsets.all(3.2),
//                         //       offset: const Offset(10, 35),
//                         //       icon: const Icon(
//                         //         Icons.more_horiz,
//                         //         color: Color(0xff666666),
//                         //       ),
//                         //       itemBuilder: (context) => [
//                         //             ...TradeMenuItem.tradepopup
//                         //                 .map(buildItem)
//                         //                 .toList(),
//                         //           ]),
//                         // ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         SizedBox(
//                           height: 28,
//                           // padding:
//                           //     EdgeInsets.symmetric(horizontal: 11, vertical: 4),
//                           child: ElevatedButton(
//                             onPressed: () {
//                               // OrderScreenArgs orderArgs = OrderScreenArgs(
//                               //     exchange: 'NSE',
//                               //     tSym:
//                               //         '${tradeAction ![index].tsym}',
//                               //     token: '',
//                               //     transType: true,
//                               //     change: '',
//                               //     close: '',
//                               //     lotSize: '',
//                               //     ltp: '',
//                               //     perChange: '',
//                               //     isEquity: '');

//                               // showModalBottomSheet(
//                               //     showDragHandle: true,
//                               //     useSafeArea: true,
//                               //     isScrollControlled: true,
//                               //     shape: const RoundedRectangleBorder(
//                               //         borderRadius: BorderRadius.vertical(
//                               //             top: Radius.circular(16))),
//                               //     backgroundColor: const Color(0xffffffff),
//                               //     context: context,
//                               //     builder: (context) => OrderBottomScreen(
//                               //         orderScreenArgs: orderArgs));
//                             },
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xff43A833),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(6))),
//                             child: Text("BUY",
//                                 style: GoogleFonts.inter(
//                                     textStyle: textStyle(
//                                         const Color(0xffFFFFFF),
//                                         12,
//                                         FontWeight.w600))),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         SizedBox(
//                           height: 28,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               // Navigator.push(
//                               //     context,
//                               //     MaterialPageRoute(
//                               //         builder: (context) => OrderScreenPage()));
//                               // OrderScreenArgs orderArgs = OrderScreenArgs(
//                               //     exchange: 'NSE',
//                               //     tSym:
//                               //         '${tradeAction ![index].tsym}',
//                               //     token: '',
//                               //     transType: false,
//                               //     change: '',
//                               //     close: '',
//                               //     lotSize: '',
//                               //     ltp: '',
//                               //     perChange: '',
//                               //     isEquity: '');
//                               // showModalBottomSheet(
//                               //     showDragHandle: true,
//                               //     isScrollControlled: true,
//                               //     useSafeArea: true,
//                               //     shape: const RoundedRectangleBorder(
//                               //         borderRadius: BorderRadius.vertical(
//                               //             top: Radius.circular(16))),
//                               //     backgroundColor: const Color(0xffffffff),
//                               //     context: context,
//                               //     builder: (context) => OrderBottomScreen(
//                               //         orderScreenArgs: orderArgs));
//                             },
//                             style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(6)),
//                                 backgroundColor: const Color(0xffFF1717)),
//                             child: Text("SELL",
//                                 style: GoogleFonts.inter(
//                                     textStyle: textStyle(
//                                         const Color(0xffFFFFFF),
//                                         12,
//                                         FontWeight.w600))),
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//                 onTap: () {
//                   debugPrint("tapped!!");
//                 },
//                 onLongTap: () {
//                   debugPrint("looooooooooong tapped!!");
//                 },
//               );
//             },
//           ),
//         ],
//       );
//     });
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle:
//             TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
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
