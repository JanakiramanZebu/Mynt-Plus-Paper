// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mynt_plus_testing/models/portfolio_model/holdings_model.dart';

// import '../models/websockt_model/touchline_ack.dart';
// import '../provider/portfolio_provider.dart';
// import '../provider/thems.dart';
// import '../provider/websocket_provider.dart';
// import '../res/res.dart';
// import '../sharedWidget/custom_exch_badge.dart';
// import '../sharedWidget/functions.dart';

// class HoldingsListCard extends ConsumerWidget {
//   final HoldingsModel data;

//   const HoldingsListCard({Key? key, required this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final portfolioProvide = watch(portfolioProvider);

//     final theme = context.read(themeProvider);
//     return StreamBuilder(
//         stream: context
//             .read(websocketProvider)
//             .touchAcknowledgementStream
//             .stream
//             .where((event) {
//           // print("${event.tk} --  ${data.exchTsym![0].token}");
//           return event.tk == data.exchTsym![0].token;
//         }),
//         builder:
//             (_, AsyncSnapshot<TouchlineAckStream> snapshotAcknowledgement) {
//           if (snapshotAcknowledgement.data != null) {
//             // log("${snapshotAcknowledgement.data!.ts}");
//             // log("${snapshotAcknowledgement.data!.pc}");
//             if (snapshotAcknowledgement.data!.tk == data.exchTsym![0].token) {
//               // log("TS :::: ${snapshotAcknowledgement.data!.ts}");
//               // log("PC :::: ${snapshotAcknowledgement.data!.pc}");
//               data.exchTsym![0].close =
//                   snapshotAcknowledgement.data!.c == null ||
//                           snapshotAcknowledgement.data!.c! == 'null'
//                       ? data.exchTsym![0].close
//                       : snapshotAcknowledgement.data!.c!;
//               data.exchTsym![0].open =
//                   snapshotAcknowledgement.data!.o == null ||
//                           snapshotAcknowledgement.data!.o! == 'null'
//                       ? data.exchTsym![0].open
//                       : snapshotAcknowledgement.data!.o!;
//               data.exchTsym![0].high =
//                   snapshotAcknowledgement.data!.h == null ||
//                           snapshotAcknowledgement.data!.h! == 'null'
//                       ? data.exchTsym![0].high
//                       : snapshotAcknowledgement.data!.h!;
//               data.exchTsym![0].low = snapshotAcknowledgement.data!.l == null ||
//                       snapshotAcknowledgement.data!.l! == 'null'
//                   ? data.exchTsym![0].low
//                   : snapshotAcknowledgement.data!.l!;

//               data.exchTsym![0].lp = snapshotAcknowledgement.data!.lp == null ||
//                       snapshotAcknowledgement.data!.lp! == 'null'
//                   ? data.exchTsym![0].lp
//                   : snapshotAcknowledgement.data!.lp!;
//               data.exchTsym![0].perChange =
//                   // ignore: unnecessary_null_comparison
//                   snapshotAcknowledgement.data!.pc == null ||
//                           snapshotAcknowledgement.data!.pc! == 'null'
//                       ? data.exchTsym![0].perChange
//                       : snapshotAcknowledgement.data!.pc!;
//               data.exchTsym![0].change = data.exchTsym![0].change == null ||
//                       data.exchTsym![0].change == "0.00" ||
//                       data.exchTsym![0].change == "00.00"
//                   ? (double.parse(data.exchTsym![0].lp ?? "0.00") -
//                           double.parse(data.exchTsym![0].close ?? "0.00"))
//                       .toStringAsFixed(2)
//                   : data.exchTsym![0].change;

//               data.exchTsym![0].profitNloss =
//                   ((double.parse(data.exchTsym![0].lp ?? "0.00") -
//                               double.parse(data.avgPrc ?? "0.00")) *
//                           int.parse("${data.currentQty ?? 0}"))
//                       .toStringAsFixed(2)
//                       .toString();

//               data.exchTsym![0].pNlChng = data.invested == "0.00"
//                   ? "0.00"
//                   : ((double.parse("${data.exchTsym![0].profitNloss}") /
//                               double.parse("${data.invested ?? 0.00}")) *
//                           100)
//                       .toStringAsFixed(2)
//                       .toString();
//               data.exchTsym![0]
//                   .oneDayChg = ((double.parse(data.exchTsym![0].lp ?? "0.00") -
//                           (double.parse(data.exchTsym![0].close ?? "0.00"))) *
//                       int.parse("${data.currentQty ?? 0}"))
//                   .toStringAsFixed(2);
//               data.currentValue = (int.parse("${data.currentQty ?? 0}") *
//                       double.parse("${data.exchTsym![0].lp ?? 0.0}"))
//                   .toStringAsFixed(2);

//               portfolioProvide.pnlHoldCal();

//               // SchedulerBinding.instance.addPostFrameCallback((_) {
//               // portfolioProvide.holdingCalc(
//               //     "${data.exchTsym![0].token}", "${data.exchTsym![0].lp}");
//               // });
//             }
//           }

//           // ignore: avoid_function_literals_in_foreach_calls

//           return StreamBuilder(
//             stream: context
//                 .read(websocketProvider)
//                 .mwStream
//                 .stream
//                 .where((event) => event.tk == data.exchTsym![0].token),
//             builder: (_, AsyncSnapshot<UpdateStream> snapshot) {
//               if (snapshot.data != null) {
//                 // 51601
//                 // if (snapshot.data!.tk == '51601') {
//                 // log("szdshbgfnsbfhj  ${snapshot.data!.lp}");
//                 // }
//                 if (snapshot.data!.tk == data.exchTsym![0].token) {
//                   // log('WATCHLIST LTP CHECK ::: ${snapshot.data!.lp!}');
//                   data.exchTsym![0].lp =
//                       snapshot.data!.lp == null || snapshot.data!.lp! == 'null'
//                           ? data.exchTsym![0].lp
//                           : snapshot.data!.lp!;
//                   data.exchTsym![0].perChange =
//                       snapshot.data!.pc == null || snapshot.data!.pc! == 'null'
//                           ? data.exchTsym![0].perChange
//                           : snapshot.data!.pc!;
//                   data.exchTsym![0].close =
//                       snapshot.data!.c == null || snapshot.data!.c! == 'null'
//                           ? data.exchTsym![0].close
//                           : snapshot.data!.c!;
//                   data.exchTsym![0].change =
//                       (double.parse(data.exchTsym![0].lp ?? "0.00") -
//                               double.parse(data.exchTsym![0].close ?? "0.00"))
//                           .toString();
//                   data.exchTsym![0].profitNloss =
//                       ((double.parse(data.exchTsym![0].lp ?? "0.00") -
//                                   double.parse(data.avgPrc ?? "0.00")) *
//                               int.parse("${data.currentQty ?? 0}"))
//                           .toStringAsFixed(2)
//                           .toString();
//                   data.exchTsym![0].pNlChng = data.invested == "0.00"
//                       ? "0.00"
//                       : ((double.parse("${data.exchTsym![0].profitNloss}") /
//                                   double.parse("${data.invested ?? 0.00}")) *
//                               100)
//                           .toStringAsFixed(2)
//                           .toString();
//                   data.exchTsym![0].oneDayChg =
//                       ((double.parse(data.exchTsym![0].lp ?? "0.00") -
//                                   (double.parse(
//                                       data.exchTsym![0].close ?? "0.00"))) *
//                               int.parse("${data.currentQty ?? 0}"))
//                           .toStringAsFixed(2);
//                   data.currentValue = (int.parse("${data.currentQty ?? 0}") *
//                           double.parse("${data.exchTsym![0].lp ?? 0.0}"))
//                       .toStringAsFixed(2);
//                   portfolioProvide.pnlHoldCal();
//                   // SchedulerBinding.instance.addPostFrameCallback((_) {
//                   // portfolioProvide.holdingCalc("${data.exchTsym![0].token}",
//                   //     "${data.exchTsym![0].lp}");
//                   // });
//                 }
//                 return Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("${data.exchTsym![0].tsym} ",
//                               overflow: TextOverflow.ellipsis,
//                               style: textStyles.scripNameTxtStyle.copyWith(
//                                   color: theme.isDarkMode
//                                       ? colors.colorWhite
//                                       : colors.colorBlack)),
//                           Row(
//                             children: [
//                               Text(" LTP: ",
//                                   style: textStyle(const Color(0xff5E6B7D), 13,
//                                       FontWeight.w600)),
//                               Text("₹${data.exchTsym![0].lp}",
//                                   style: textStyle(
//                                       theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack,
//                                       14,
//                                       FontWeight.w500)),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           CustomExchBadge(exch: "${data.exchTsym![0].exch}"),
//                           Text(" (${data.exchTsym![0].perChange}%)",
//                               style: textStyle(
//                                   Color(data.exchTsym![0].perChange!
//                                           .startsWith("-")
//                                       ? 0XFFFF1717
//                                       : data.exchTsym![0].perChange == "0.00"
//                                           ? 0xff666666
//                                           : 0xff43A833),
//                                   12,
//                                   FontWeight.w500)),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Divider(
//                           color: theme.isDarkMode
//                               ? colors.darkColorDivider
//                               : colors.colorDivider),
//                       const SizedBox(height: 3),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text("Qty: ",
//                                   style: textStyle(const Color(0xff5E6B7D), 14,
//                                       FontWeight.w500)),
//                               Text(
//                                   "${data.currentQty ?? 0} @ ₹${data.upldprc ?? data.exchTsym![0].close ?? 0.00}",
//                                   style: textStyle(
//                                       theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack,
//                                       14,
//                                       FontWeight.w500)),
//                               if (data.npoadqty.toString() != "null") ...[
//                                 Text(" NPQ",
//                                     style: textStyle(const Color(0xff666666),
//                                         12, FontWeight.w500)),
//                               ],
//                               if (data.btstqty != "0")
//                                 Text(" T1: ${data.btstqty}",
//                                     style: textStyle(const Color(0xff666666),
//                                         12, FontWeight.w500))
//                             ],
//                           ),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text("₹${data.exchTsym![0].profitNloss}",
//                                   style: textStyle(
//                                       Color(data.exchTsym![0].profitNloss!
//                                               .startsWith("-")
//                                           ? 0XFFFF1717
//                                           : 0xff43A833),
//                                       14,
//                                       FontWeight.w500)),
//                               Text(
//                                   " (${data.exchTsym![0].pNlChng == "NaN" ? 0.0 : data.exchTsym![0].pNlChng}%)",
//                                   style: textStyle(
//                                       Color(data.exchTsym![0].pNlChng!
//                                               .startsWith("-")
//                                           ? 0XFFFF1717
//                                           : data.exchTsym![0].pNlChng == "NaN"
//                                               ? 0xff666666
//                                               : 0xff43A833),
//                                       12,
//                                       FontWeight.w500)),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Text("Inv: ",
//                                   style: textStyle(const Color(0xff5E6B7D), 14,
//                                       FontWeight.w500)),
//                               Text(
//                                   "₹${getFormatter(value: double.parse("${data.invested == "0.00" ? data.exchTsym![0].close ?? 0.00 : data.invested ?? 0.00}"), v4d: false, noDecimal: false)}",
//                                   style: textStyle(
//                                       theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack,
//                                       14,
//                                       FontWeight.w500)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Text("Cur: ",
//                                   style: textStyle(const Color(0xff5E6B7D), 14,
//                                       FontWeight.w500)),
//                               Text(
//                                   "₹${getFormatter(value: double.parse("${data.currentValue ?? 0.00}"), v4d: false, noDecimal: false)}",
//                                   style: textStyle(
//                                       theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack,
//                                       14,
//                                       FontWeight.w500)),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 );
//               } else {
//                 return Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("${data.exchTsym![0].tsym} ",
//                               overflow: TextOverflow.ellipsis,
//                               style: textStyles.scripNameTxtStyle.copyWith(
//                                   color: theme.isDarkMode
//                                       ? colors.colorWhite
//                                       : colors.colorBlack)),
//                           Row(
//                             children: [
//                               Text(" LTP: ",
//                                   style: textStyle(const Color(0xff5E6B7D), 13,
//                                       FontWeight.w600)),
//                               Text("₹${data.exchTsym![0].lp}",
//                                   style: textStyle(
//                                       theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack,
//                                       14,
//                                       FontWeight.w500)),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           CustomExchBadge(exch: "${data.exchTsym![0].exch}"),
//                           Text(" (${data.exchTsym![0].perChange}%)",
//                               style: textStyle(
//                                   Color(data.exchTsym![0].perChange!
//                                           .startsWith("-")
//                                       ? 0XFFFF1717
//                                       : data.exchTsym![0].perChange == "0.00"
//                                           ? 0xff666666
//                                           : 0xff43A833),
//                                   12,
//                                   FontWeight.w500)),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Divider(
//                           color: theme.isDarkMode
//                               ? colors.darkColorDivider
//                               : colors.colorDivider),
//                       const SizedBox(height: 3),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text("Qty: ",
//                                   style: textStyle(const Color(0xff5E6B7D), 14,
//                                       FontWeight.w500)),
//                               Text(
//                                   "${data.currentQty ?? 0} @ ₹${data.upldprc ?? data.exchTsym![0].close ?? 0.00}",
//                                   style: textStyle(
//                                       theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack,
//                                       14,
//                                       FontWeight.w500)),
//                               if (data.npoadqty.toString() != "null") ...[
//                                 Text(" NPQ",
//                                     style: textStyle(const Color(0xff666666),
//                                         12, FontWeight.w500)),
//                               ],
//                               if (data.btstqty != "0")
//                                 Text(" T1: ${data.btstqty}",
//                                     style: textStyle(const Color(0xff666666),
//                                         12, FontWeight.w500))
//                             ],
//                           ),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text("₹${data.exchTsym![0].profitNloss}",
//                                   style: textStyle(
//                                       Color(data.exchTsym![0].profitNloss!
//                                               .startsWith("-")
//                                           ? 0XFFFF1717
//                                           : 0xff43A833),
//                                       14,
//                                       FontWeight.w500)),
//                               Text(
//                                   " (${data.exchTsym![0].pNlChng == "NaN" ? 0.0 : data.exchTsym![0].pNlChng}%)",
//                                   style: textStyle(
//                                       Color(data.exchTsym![0].pNlChng!
//                                               .startsWith("-")
//                                           ? 0XFFFF1717
//                                           : data.exchTsym![0].pNlChng == "NaN"
//                                               ? 0xff666666
//                                               : 0xff43A833),
//                                       12,
//                                       FontWeight.w500)),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Text("Inv: ",
//                                   style: textStyle(const Color(0xff5E6B7D), 14,
//                                       FontWeight.w500)),
//                               Text(
//                                   "₹${getFormatter(value: double.parse("${data.invested == "0.00" ? data.exchTsym![0].close ?? 0.00 : data.invested ?? 0.00}"), v4d: false, noDecimal: false)}",
//                                   style: textStyle(
//                                       theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack,
//                                       14,
//                                       FontWeight.w500)),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Text("Cur: ",
//                                   style: textStyle(const Color(0xff5E6B7D), 14,
//                                       FontWeight.w500)),
//                               Text(
//                                   "₹${getFormatter(value: double.parse("${data.currentValue ?? 0.00}"), v4d: false, noDecimal: false)}",
//                                   style: textStyle(
//                                       theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack,
//                                       14,
//                                       FontWeight.w500)),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 );
//               }
//             },
//           );
//         });
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle:
//             TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
//   }
// }
