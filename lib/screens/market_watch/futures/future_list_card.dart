 
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; 
// import 'package:google_fonts/google_fonts.dart';

// import '../../../models/marketwatch_model/linked_scrips.dart';
// import '../../../models/websockt_model/touchline_ack.dart';
// import '../../../provider/thems.dart';
// import '../../../provider/websocket_provider.dart';
// import '../../../res/res.dart'; 

// class FutureListCard extends StatelessWidget {
//   final Futures scripData;
 
//   const FutureListCard(
//       {super.key,
//       required this.scripData });

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: context
//             .read(websocketProvider)
//             .touchAcknowledgementStream
//             .stream
//             .where((event) => event.tk == scripData.token),
//         builder:
//             (_, AsyncSnapshot<TouchlineAckStream> snapshotAcknowledgement) {
//           if (snapshotAcknowledgement.data != null) {
//             if (snapshotAcknowledgement.data!.tk == scripData.token) {
//               scripData.close =
//                   snapshotAcknowledgement.data!.c == null ||
//                           snapshotAcknowledgement.data!.c! == 'null'
//                       ? scripData.close
//                       : snapshotAcknowledgement.data!.c!;
//               scripData.open = snapshotAcknowledgement.data!.o == null ||
//                       snapshotAcknowledgement.data!.o! == 'null'
//                   ? scripData.open
//                   : snapshotAcknowledgement.data!.o!;
//               scripData.high = snapshotAcknowledgement.data!.h == null ||
//                       snapshotAcknowledgement.data!.h! == 'null'
//                   ? scripData.high
//                   : snapshotAcknowledgement.data!.h!;
//               scripData.low = snapshotAcknowledgement.data!.l == null ||
//                       snapshotAcknowledgement.data!.l! == 'null'
//                   ? scripData.low
//                   : snapshotAcknowledgement.data!.l!;

//               scripData.ltp = snapshotAcknowledgement.data!.lp == null ||
//                       snapshotAcknowledgement.data!.lp! == 'null'
//                   ? scripData.ltp
//                   : snapshotAcknowledgement.data!.lp!;
//               scripData.perChange =
//                   snapshotAcknowledgement.data!.pc == null ||
//                           snapshotAcknowledgement.data!.pc! == 'null'
//                       ? scripData.perChange
//                       : snapshotAcknowledgement.data!.pc!;

//               scripData.change = (double.parse(scripData.ltp ??
//                           scripData.close ??
//                           "0.00") -
//                       double.parse(scripData.close ?? "0.00"))
//                   .toStringAsFixed(2);
//             }
//             // }
//           }

//           return StreamBuilder(
//             stream: context
//                 .read(websocketProvider)
//                 .mwStream
//                 .stream
//                 .where((event) => event.tk == scripData.token),
//             builder: (_, AsyncSnapshot<UpdateStream> snapshot) {
//               // if (snapshot.connectionState == ConnectionState.active) {
//               if (snapshot.data != null) {
//                 if (snapshot.data!.tk == scripData.token) {
//                   scripData.ltp =
//                       snapshot.data!.lp == null || snapshot.data!.lp! == 'null'
//                           ? scripData.ltp
//                           : snapshot.data!.lp!;
//                   scripData.perChange =
//                       snapshot.data!.pc == null || snapshot.data!.pc! == 'null'
//                           ? scripData.perChange
//                           : snapshot.data!.pc!;
//                   scripData.close =
//                       snapshot.data!.c == null || snapshot.data!.c! == 'null'
//                           ? scripData.close
//                           : snapshot.data!.c!;

//                   scripData.change = (double.parse(
//                               scripData.ltp ??
//                                   scripData.close ??
//                                   "0.00") -
//                           double.parse(scripData.close ?? "0.00"))
//                       .toStringAsFixed(2);
//                   // }
//                 }
//                 return watchListScripData(context);
//               } else {
//                 return watchListScripData(context);
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
//           Text("${scripData.symbol} ",
//               style: textStyles.scripNameTxtStyle.copyWith(color: context.read(themeProvider) .isDarkMode?colors.colorWhite:colors.colorBlack)),
//           if (scripData.option!.isNotEmpty)
//             Text("${scripData.option}",
//                 style: textStyles.scripNameTxtStyle
//                     .copyWith(color: const Color(0xff666666))),
//         ],
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               Text("${scripData.exch}  ",
//                   style: textStyles.scripExchTxtStyle),
//               if (scripData.expDate!.isNotEmpty)
//                 Text("${scripData.expDate}  ",
//                     style: textStyles.scripExchTxtStyle
//                         .copyWith(color: colors.colorBlack)),
               
//             ],
//           ),
//         ],
//       ),
//       trailing: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text("₹${scripData.ltp ?? scripData.close ?? 0.00}",
//               style: textStyle(const Color(0xff000000), 14, FontWeight.w600)),
//           const SizedBox(height: 4),
//           Text(
//             "${scripData.change == "null" ? "0.00 " : double.parse("${scripData.change}").toStringAsFixed(2)} "
//             "${scripData.perChange == "null" ? "(0.00%)" : "(${scripData.perChange ?? 0.00}%)"}",
//             style: textStyle(
//                 Color(scripData.change!.startsWith("-") ||
//                         scripData.perChange!.startsWith('-')
//                     ? 0xffFF1717
//                     : (scripData.change == "null" ||
//                                 scripData.perChange == "null") ||
//                             (scripData.change == "0.00" ||
//                                 scripData.perChange == "0.00")
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
