//  

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../model/portfolio/holdings_model.dart';
// import '../../../model/order_book_model/order_book_model.dart';
// import '../../../model/touchline_ack_stream.dart';
// import '../../../provider/market_watch_provider.dart';
// import '../../../provider/websocket_provider.dart';

// class HoldingBottomSheet extends StatelessWidget {
//   final ExchTsym exchTsym;
//   final HoldingsModel holdingData;
//   const HoldingBottomSheet(
//       {super.key, required this.exchTsym, required this.holdingData});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: context
//             .read(websocketProvider)
//             .touchAcknowledgementStream
//             .stream
//             .where((event) {
//           log("1event $event");
//           return event.tk == exchTsym.token;
//         }),
//         builder:
//             (_, AsyncSnapshot<TouchlineAckStream> snapshotAcknowledgement) {
//           if (snapshotAcknowledgement.data != null) {
//             log("${snapshotAcknowledgement.data!.pc}");
//             if (snapshotAcknowledgement.data!.tk == exchTsym.token) {
//               exchTsym.lp = snapshotAcknowledgement.data!.lp == null ||
//                       snapshotAcknowledgement.data!.lp! == 'null'
//                   ? exchTsym.lp == null || exchTsym.lp == "null"
//                       ? "0.00"
//                       : exchTsym.lp
//                   : snapshotAcknowledgement.data!.lp!;

//               double qty = double.parse("${holdingData.npoadqty}");
//               double avgCost = double.parse("${holdingData.upldprc}");
//               double lastPrice = double.parse("${exchTsym.lp}");

//               exchTsym.profitNloss =
//                   ((lastPrice - avgCost) * qty).toStringAsFixed(2).toString();
//               exchTsym.currentAmt = (qty * lastPrice).toString();

//               exchTsym.perChange = ((double.parse("${exchTsym.profitNloss}") /
//                           double.parse("${holdingData.invested}")) *
//                       100)
//                   .toStringAsFixed(2)
//                   .toString();
//             }
//           }

//           return StreamBuilder(
//             stream: context
//                 .read(websocketProvider)
//                 .mwStream
//                 .stream
//                 .where((event) => event.tk == exchTsym.token),
//             builder: (_, AsyncSnapshot<UpdateStream> snapshot) {
//               if (snapshot.connectionState == ConnectionState.active) {
//                 log("--${snapshot.data!.lp}");
//                 if (snapshot.data != null) {
//                   if (snapshot.data!.tk == exchTsym.token) {
//                     exchTsym.lp = snapshot.data!.lp == null ||
//                             snapshot.data!.lp! == 'null'
//                         ? exchTsym.lp == null || exchTsym.lp == "null"
//                             ? "0.00"
//                             : exchTsym.lp
//                         : snapshot.data!.lp!;

//                     double qty = double.parse("${holdingData.npoadqty}");
//                     double avgCost = double.parse("${holdingData.upldprc}");
//                     double lastPrice = double.parse("${exchTsym.lp}");
//                     exchTsym.profitNloss = ((lastPrice - avgCost) * qty)
//                         .toStringAsFixed(2)
//                         .toString();
//                     exchTsym.currentAmt = (qty * lastPrice).toString();

//                     exchTsym.perChange =
//                         ((double.parse("${exchTsym.profitNloss}") /
//                                     double.parse("${holdingData.invested}")) *
//                                 100)
//                             .toStringAsFixed(2)
//                             .toString();
//                   }
//                 }

//                 return scripDetailData(context);
//               } else {
//                 return scripDetailData(context);
//               }
//             },
//           );
//         });
//   }

//   Column scripDetailData(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             children: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Text("${exchTsym.tsym}",
//                           style: textStyle(
//                               const Color(0XFF000000), 15, FontWeight.w500)),
//                       Container(
//                         margin: const EdgeInsets.only(left: 8),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                             color: const Color(0xffF1F3F8),
//                             borderRadius: BorderRadius.circular(4)),
//                         child: Text("${exchTsym.exch}",
//                             style: textStyle(
//                                 const Color(0XFF666666), 10, FontWeight.w600)),
//                       ),
//                     ],
//                   ),
//                   InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: SvgPicture.asset("assets/icon/clear.svg"))
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Text("Qty ",
//                           style: textStyle(
//                               const Color(0XFF666666), 15, FontWeight.w500)),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(4),
//                             color: Color(holdingData.npoadqty!.startsWith("-")
//                                 ? 0XFFFF1717
//                                 : 0xffECF8F1),
//                             border: Border.all(color: const Color(0xffC1E7BA))),
//                         child: Text("${holdingData.npoadqty}",
//                             style: textStyle(
//                                 Color(holdingData.npoadqty!.startsWith("-")
//                                     ? 0XFFFF1717
//                                     : 0XFF43A833),
//                                 13,
//                                 FontWeight.w600)),
//                       )
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text("P&L: ",
//                           style: textStyle(
//                               const Color(0XFF666666), 15, FontWeight.w500)),
//                       Text("₹${exchTsym.profitNloss}",
//                           style: textStyle(
//                               Color(exchTsym.profitNloss!.startsWith("-")
//                                   ? 0XFFFF1717
//                                   : 0XFF43A833),
//                               15,
//                               FontWeight.w500)),
//                       Text("(${exchTsym.perChange}%)",
//                           style: textStyle(
//                               Color(exchTsym.perChange!.startsWith("-")
//                                   ? 0XFFFF1717
//                                   : 0XFF43A833),
//                               12,
//                               FontWeight.w400)),
//                     ],
//                   )
//                 ],
//               ),
//               const SizedBox(height: 8),
//               const Divider(color: Color(0xffECEDEE)),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("LTP",
//                                 style: textStyle(const Color(0XFF666666), 14,
//                                     FontWeight.w500)),
//                             Text("₹${exchTsym.lp}",
//                                 style: textStyle(const Color(0XFF000000), 14,
//                                     FontWeight.w500)),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Current Val",
//                                 style: textStyle(const Color(0XFF666666), 14,
//                                     FontWeight.w500)),
//                             Text(
//                                 "₹${double.parse("${exchTsym.currentAmt}").toStringAsFixed(2)}",
//                                 style: textStyle(const Color(0XFF000000), 14,
//                                     FontWeight.w500)),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Saleable Qty",
//                                 style: textStyle(const Color(0XFF666666), 14,
//                                     FontWeight.w500)),
//                             Text("${holdingData.benqty}",
//                                 style: textStyle(const Color(0XFF000000), 14,
//                                     FontWeight.w500)),
//                           ],
//                         ),
//                         const SizedBox(height: 7),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 28),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Invested",
//                                 style: textStyle(const Color(0XFF666666), 14,
//                                     FontWeight.w500)),
//                             Text("₹${holdingData.invested}",
//                                 style: textStyle(const Color(0XFF000000), 14,
//                                     FontWeight.w500)),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Avg Price",
//                                 style: textStyle(const Color(0XFF666666), 14,
//                                     FontWeight.w500)),
//                             Text("₹${holdingData.upldprc}",
//                                 style: textStyle(const Color(0XFF000000), 14,
//                                     FontWeight.w500)),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Pledged Qty",
//                                 style: textStyle(const Color(0XFF666666), 14,
//                                     FontWeight.w500)),
//                             Text("--",
//                                 style: textStyle(const Color(0XFF000000), 14,
//                                     FontWeight.w500)),
//                           ],
//                         ),
//                         const SizedBox(height: 7),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 18),
//         Container(
//           decoration: const BoxDecoration(
//               border: Border(top: BorderSide(color: Color(0xffECEDEE)))),
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               InkWell(
//                 onTap: () async {
//                   await context.read(marketWatchProvider).fetchScripInfo(
//                       "${exchTsym.token}", '${exchTsym.exch}', context);
//                   OrderScreenArgs orderArgs = OrderScreenArgs(
//                       exchange: '${exchTsym.exch}',
//                       tSym: '${exchTsym.tsym}',
//                       token: '',
//                       transType: true,
//                       // change: '',
//                       // close: '',
//                       lotSize: '${exchTsym.ls}',
//                       isExit: false,
//                       ltp: '${exchTsym.lp}',
//                       perChange: '${exchTsym.perChange}',
//                       orderNum: '');
//                   // showModalBottomSheet(
//                   //     showDragHandle: true,
//                   //     isScrollControlled: true,
//                   //     useSafeArea: true,
//                   //     shape: const RoundedRectangleBorder(
//                   //         borderRadius:
//                   //             BorderRadius.vertical(top: Radius.circular(16))),
//                   //     backgroundColor: const Color(0xffffffff),
//                   //     context: context,
//                   //     builder: (context) => OrderBottomScreen(
//                   //         orderScreenArgs: orderArgs,
//                   //         scriptInfoData: context
//                   //             .read(marketWatchProvider)
//                   //             .scripInfoModel!));
//                 },
//                 child: Container(
//                   width: 145,
//                   height: 40,
//                   decoration: BoxDecoration(
//                       color: const Color(0xff43A833),
//                       borderRadius: BorderRadius.circular(108)),
//                   child: Center(
//                     child: Text("Add More",
//                         style: textStyle(
//                             const Color(0XFFFFFFFF), 16, FontWeight.w600)),
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () async {
//                   await context.read(marketWatchProvider).fetchScripInfo(
//                       "${exchTsym.token}", '${exchTsym.exch}', context);
//                   OrderScreenArgs orderArgs = OrderScreenArgs(
//                       exchange: '${exchTsym.exch}',
//                       tSym: '${exchTsym.tsym}',
//                       token: '${exchTsym.token}',
//                       transType: false,
//                       isExit: false,
//                       // change: '${exchTsym.change}',
//                       // close: '${exchTsym.close}',
//                       lotSize: '${holdingData.npoadqty}',
//                       ltp: '${exchTsym.lp}',
//                       perChange: '${exchTsym.perChange}',
//                       orderNum: '');
//                   // showModalBottomSheet(
//                   //     showDragHandle: true,
//                   //     isScrollControlled: true,
//                   //     useSafeArea: true,
//                   //     shape: const RoundedRectangleBorder(
//                   //         borderRadius:
//                   //             BorderRadius.vertical(top: Radius.circular(16))),
//                   //     backgroundColor: const Color(0xffffffff),
//                   //     context: context,
//                   //     builder: (context) => OrderBottomScreen(
//                   //         orderScreenArgs: orderArgs,
//                   //         scriptInfoData: context
//                   //             .read(marketWatchProvider)
//                   //             .scripInfoModel!));
//                 },
//                 child: Container(
//                   width: 145,
//                   height: 40,
//                   decoration: BoxDecoration(
//                       color: const Color(0XFFD34645),
//                       borderRadius: BorderRadius.circular(108)),
//                   child: Center(
//                     child: Text("Exit",
//                         style: textStyle(
//                             const Color(0XFFFFFFFF), 16, FontWeight.w600)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
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
