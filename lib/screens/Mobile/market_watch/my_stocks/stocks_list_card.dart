// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';

// import 'package:google_fonts/google_fonts.dart';

// import '../../../model/portfolio/holdings_model.dart';
// import '../../../model/touchline_ack_stream.dart';
// import '../../../provider/thems.dart';
// import '../../../provider/websocket_provider.dart';
// import '../../../res/res.dart'; 

// class StockListCard extends StatelessWidget {
//  final HoldingsModel holdingData;
//   final ExchTsym exchTsym;
 
//   const StockListCard(
//       {super.key,
//     required this.holdingData, required this.exchTsym});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: context
//             .read(websocketProvider)
//             .touchAcknowledgementStream
//             .stream
//             .where((event) => event.tk ==  exchTsym.token),
//         builder:
//             (_, AsyncSnapshot<TouchlineAckStream> snapshotAcknowledgement) {
//           if (snapshotAcknowledgement.data != null) {
//             if (snapshotAcknowledgement.data!.tk ==  exchTsym.token) {
//               exchTsym.close =
//                   snapshotAcknowledgement.data!.c == null ||
//                           snapshotAcknowledgement.data!.c! == 'null'
//                       ? exchTsym.close
//                       : snapshotAcknowledgement.data!.c!;
//               exchTsym.open = snapshotAcknowledgement.data!.o == null ||
//                       snapshotAcknowledgement.data!.o! == 'null'
//                   ? exchTsym.open
//                   : snapshotAcknowledgement.data!.o!;
//               exchTsym.high = snapshotAcknowledgement.data!.h == null ||
//                       snapshotAcknowledgement.data!.h! == 'null'
//                   ? exchTsym.high
//                   : snapshotAcknowledgement.data!.h!;
//               exchTsym.low = snapshotAcknowledgement.data!.l == null ||
//                       snapshotAcknowledgement.data!.l! == 'null'
//                   ? exchTsym.low
//                   : snapshotAcknowledgement.data!.l!;

//               exchTsym.lp = snapshotAcknowledgement.data!.lp == null ||
//                       snapshotAcknowledgement.data!.lp! == 'null'
//                   ? exchTsym.lp
//                   : snapshotAcknowledgement.data!.lp!;
//               exchTsym.perChange =
//                   snapshotAcknowledgement.data!.pc == null ||
//                           snapshotAcknowledgement.data!.pc! == 'null'
//                       ? exchTsym.perChange
//                       : snapshotAcknowledgement.data!.pc!;

//               exchTsym.change = (double.parse( exchTsym.lp ??
//                           exchTsym.close ??
//                           "0.00") -
//                       double.parse( exchTsym.close ?? "0.00"))
//                   .toStringAsFixed(2);
//             }
//             // }
//           }

//           return StreamBuilder(
//             stream: context
//                 .read(websocketProvider)
//                 .mwStream
//                 .stream
//                 .where((event) => event.tk == exchTsym.token),
//             builder: (_, AsyncSnapshot<UpdateStream> snapshot) {
//               // if (snapshot.connectionState == ConnectionState.active) {
//               if (snapshot.data != null) {
//                 if (snapshot.data!.tk == exchTsym.token) {
//                   exchTsym.lp =
//                       snapshot.data!.lp == null || snapshot.data!.lp! == 'null'
//                           ? exchTsym.lp
//                           : snapshot.data!.lp!;
//                   exchTsym.perChange =
//                       snapshot.data!.pc == null || snapshot.data!.pc! == 'null'
//                           ? exchTsym.perChange
//                           : snapshot.data!.pc!;
//                   exchTsym.close =
//                       snapshot.data!.c == null || snapshot.data!.c! == 'null'
//                           ? exchTsym.close
//                           : snapshot.data!.c!;

//                   exchTsym.change = (double.parse(
//                               exchTsym.lp ??
//                                   exchTsym.close ??
//                                   "0.00") -
//                           double.parse( exchTsym.close ?? "0.00"))
//                       .toStringAsFixed(2);
//                   // }
//                 }
//                 return watchListScripData(context );
//               } else {
//                 return watchListScripData(context );
//               }
//             },
//           );
//         });
//   }

//   watchListScripData(BuildContext context) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//       dense: true,
//       title: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text("${ exchTsym.symbol} ",
//               style: textStyles.scripNameTxtStyle.copyWith(color:  ref.read(themeProvider) .isDarkMode?colors.colorWhite:colors.colorBlack)),
//           if ( exchTsym.option!.isNotEmpty)
//             Text("${ exchTsym.option}",
//                 style: textStyles.scripNameTxtStyle
//                     .copyWith(color: const Color(0xff666666))),
//         ],
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(height: 3),
//           Row(
//             children: [

//                Container(
//                 margin: const EdgeInsets.only(right: 4),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(2),
//                           color: const Color(0xffF1F3F8)),
//                       child: Text("${ exchTsym.exch}",
//                           overflow: TextOverflow.ellipsis,
//                           style: textStyle(
//                               const Color(0xff666666), 10, FontWeight.w500)),
//                     ),
             
//               if ( exchTsym.expDate!.isNotEmpty)
//                 Text(" ${ exchTsym.expDate}  ",
//                     style: textStyles.scripExchTxtStyle
//                         .copyWith(color: colors.colorBlack)),
//               if ( holdingData.currentQty != null) ...[
//                 SvgPicture.asset(assets.suitcase,
//                     height: 12, width: 16, color: colors.colorBlue),
//                 Text(" ${  holdingData.currentQty}",
//                     style: textStyles.scripExchTxtStyle.copyWith(
//                         color: colors.colorBlue, fontWeight: FontWeight.w600))
//               ]
//             ],
//           ),
//         ],
//       ),
//       trailing: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text("₹${ exchTsym.lp ?? exchTsym.close ?? 0.00}",
//               style: textStyle(const Color(0xff000000), 14, FontWeight.w600)),
//           const SizedBox(height: 4),
//           Text(
//             "${ exchTsym.change == "null" ? "0.00 " : double.parse("${ exchTsym.change}").toStringAsFixed(2)} "
//             "${ exchTsym.perChange == "null" ? "(0.00%)" : "(${ exchTsym.perChange ?? 0.00}%)"}",
//             style: textStyle(
//                 Color( exchTsym.change!.startsWith("-") ||
//                         exchTsym.perChange!.startsWith('-')
//                     ? 0xffFF1717
//                     : ( exchTsym.change == "null" ||
//                                 exchTsym.perChange == "null") ||
//                             ( exchTsym.change == "0.00" ||
//                                 exchTsym.perChange == "0.00")
//                         ? 0xff999999
//                         : 0xff43A833),
//                 12,
//                 FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle:
//             TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
//   }
// }
