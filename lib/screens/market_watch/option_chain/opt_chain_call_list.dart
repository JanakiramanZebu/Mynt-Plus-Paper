// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
 
// import '../../../model/touchline_ack_stream.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/list_divider.dart';
import '../scrip_depth_info.dart'; 

class OptChainCallList extends ConsumerWidget {
  final List<OptionValues>? callData;

  final bool isCallUp;
  const OptChainCallList({super.key, this.callData, required this.isCallUp});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final socketDatas = watch(websocketProvider).socketDatas;
    final scripData = watch(marketWatchProvider);
     final theme = watch(themeProvider);
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: isCallUp ? true : false,
      itemCount: callData!.length,
      itemBuilder: (BuildContext context, int index) {
        if (socketDatas.containsKey(callData![index].token)) {
          callData![index].lp =
              "${socketDatas["${callData![index].token}"]['lp']}";
          callData![index].perChange =
              "${socketDatas["${callData![index].token}"]['pc']}";

          callData![index].oiLack = (double.parse(
                      "${socketDatas["${callData![index].token}"]['oi']}") /
                  100000)
              .toStringAsFixed(2);

          callData![index].oiPerChng = ((double.parse(
                          "${socketDatas["${callData![index].token}"]['poi'] ?? 0.00}") /
                      double.parse(
                          "${socketDatas["${callData![index].token}"]['oi'] ?? 0.00}")) *
                  100)
              .toStringAsFixed(2);
        }

        return InkWell(
            onTap: () async {
              await scripData.fetchScripQuote("${callData![index].token}",
                  "${callData![index].exch}", context);

              await context.read(marketWatchProvider).fetchLinkeScrip(
                  "${callData![index].token}", "${callData![index].exch}",context);

              await watch(websocketProvider).establishConnection(
                  channelInput:
                      "${callData![index].exch}|${callData![index].token}",
                  task: "d",
                  context: context);

              if (watch(marketWatchProvider).getQuotes!.stat == "Ok") {
                Navigator.pop(context);
                DepthInputArgs depthArgs = DepthInputArgs(
                    exch: '${callData![index].exch}',
                    token: '${callData![index].token}',
                    tsym: '${callData![index].tsym}',
                    instname: "",
                    symbol: '${callData![index].symbol}',
                    expDate: '${callData![index].expDate}',
                    option: '${callData![index].option}');

                showModalBottomSheet(
                    barrierColor: Colors.transparent,
                    isScrollControlled: true,
                    useSafeArea: true,
                    isDismissible: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16))),
                    backgroundColor: const Color(0xffffffff),
                    context: context,
                    builder: (context) => ScripDepthInfo(wlValue: depthArgs, isBasket: ''));
              }
            },
            child: Container(
             
              height: 58,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${callData![index].oiLack ?? 0.00}",
                          style: textStyle(
                            theme.isDarkMode?colors.colorWhite:colors.colorBlack, 13, FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(
                          "(${callData![index].oiPerChng == "NaN" ? "0.00" : callData![index].oiPerChng ?? 0.00}%)",
                          style: textStyle(
                             callData![index].oiPerChng == null ||
                                      callData![index].oiPerChng == "0.00"
                                  ? colors.ltpgrey
                                  : callData![index].oiPerChng!.startsWith("-")
                                      ? colors.darkred
                                      : colors.ltpgreen,
                              11,
                              FontWeight.w500)),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "${callData![index].lp ?? callData![index].close ?? 0.00}",
                            style: textStyle(
                                 theme.isDarkMode?colors.colorWhite:colors.colorBlack, 13, FontWeight.w500)),
                        const SizedBox(height: 3),
                        Text("(${callData![index].perChange ?? 0.00}%)",
                            style: textStyle(
                                callData![index].perChange == null ||
                                        callData![index].perChange == "0.00"
                                    ? colors.ltpgrey
                                    : callData![index]
                                            .perChange!
                                            .startsWith("-")
                                        ? colors.darkred
                                        : colors.ltpgreen,
                                11,
                                FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            )

            // OptChainCallListUpdate(callData: callData![index])

            );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const ListDivider();
      },
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

// class OptChainCallListUpdate extends StatelessWidget {
//   final OptionValues callData;

//   const OptChainCallListUpdate({super.key, required this.callData});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: context
//             .read(websocketProvider)
//             .touchAcknowledgementStream
//             .stream
//             .where((event) => event.tk == callData.token),
//         builder:
//             (_, AsyncSnapshot<TouchlineAckStream> snapshotAcknowledgement) {
//           if (snapshotAcknowledgement.connectionState ==
//               ConnectionState.active) {
//             if (snapshotAcknowledgement.data != null) {
//               if (snapshotAcknowledgement.data!.tk == callData.token) {
//                 callData.lp = snapshotAcknowledgement.data!.lp == null ||
//                         snapshotAcknowledgement.data!.lp! == 'null'
//                     ? callData.lp
//                     : snapshotAcknowledgement.data!.lp!;
//                 callData.perChange = snapshotAcknowledgement.data!.pc == null ||
//                         snapshotAcknowledgement.data!.pc! == 'null'
//                     ? callData.perChange
//                     : snapshotAcknowledgement.data!.pc!;

//                 callData.oi = snapshotAcknowledgement.data!.oi == null ||
//                         snapshotAcknowledgement.data!.oi! == 'null'
//                     ? callData.oi
//                     : snapshotAcknowledgement.data!.oi!;

//                 callData.close = snapshotAcknowledgement.data!.c == null ||
//                         snapshotAcknowledgement.data!.c! == 'null'
//                     ? callData.close
//                     : snapshotAcknowledgement.data!.c!;
//                 callData.poi = snapshotAcknowledgement.data!.poi == null ||
//                         snapshotAcknowledgement.data!.poi! == 'null'
//                     ? callData.poi
//                     : snapshotAcknowledgement.data!.poi!;

//                 callData.oiLack =
//                     (double.parse("${callData.oi ?? 0.00}") / 100000)
//                         .toStringAsFixed(2);

//                 callData.oiPerChng = ((double.parse("${callData.poi ?? 0.00}") /
//                             double.parse("${callData.oi ?? 0.00}")) *
//                         100)
//                     .toStringAsFixed(2);

//                 debugPrint(
//                     "- - - -   +++++   -  ${callData.lp ?? callData.close ?? 0.00}    --  ${callData.strprc}");
//               }
//             }
//           }
//           return StreamBuilder(
//             stream: context
//                 .read(websocketProvider)
//                 .mwStream
//                 .stream
//                 .where((event) => event.tk == callData.token),
//             builder: (_, AsyncSnapshot<UpdateStream> snapshot) {
//               // if (snapshot.connectionState == ConnectionState.active) {
//               if (snapshot.data != null) {
//                 if (snapshot.data!.tk == callData.token) {
//                   callData.lp =
//                       snapshot.data!.lp == null || snapshot.data!.lp! == 'null'
//                           ? callData.lp
//                           : snapshot.data!.lp!;
//                   callData.perChange =
//                       snapshot.data!.pc == null || snapshot.data!.pc! == 'null'
//                           ? callData.perChange
//                           : snapshot.data!.pc!;

//                   callData.oi =
//                       snapshot.data!.oi == null || snapshot.data!.oi! == 'null'
//                           ? callData.oi
//                           : snapshot.data!.oi!;
//                   callData.close =
//                       snapshot.data!.c == null || snapshot.data!.c! == 'null'
//                           ? callData.close
//                           : snapshot.data!.c!;
//                   callData.poi = snapshot.data!.poi == null ||
//                           snapshot.data!.poi! == 'null'
//                       ? callData.poi
//                       : snapshot.data!.poi!;

//                   callData.oiLack =
//                       (double.parse("${callData.oi ?? 0.00}") / 100000)
//                           .toStringAsFixed(2);

//                   callData.oiPerChng =
//                       ((double.parse("${callData.poi ?? 0.00}") /
//                                   double.parse("${callData.oi ?? 0.00}")) *
//                               100)
//                           .toStringAsFixed(2);
//                   log(" --- - - - -  ${callData.lp ?? callData.close ?? 0.00}    --  ${callData.strprc}");
//                   // }
//                 }
//                 return callListUpdate();
//               } else {
//                 return callListUpdate();
//               }
//             },
//           );
//         });
//   }

//   Container callListUpdate() {
//     return Container(
//       color: Colors.white,
//       height: 58,
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("${callData.oiLack ?? 0.00}",
//                   style:
//                       textStyle(const Color(0xff000000), 13, FontWeight.w500)),
//               const SizedBox(height: 3),
//               Text(
//                   "(${callData.oiPerChng == "NaN" ? "0.00" : callData.oiPerChng ?? 0.00}%)",
//                   style: textStyle(
//                       Color(callData.oiPerChng == null ||
//                               callData.oiPerChng == "0.00"
//                           ? 0xff666666
//                           : callData.oiPerChng!.startsWith("-")
//                               ? 0xffFF1717
//                               : 0xff43A833),
//                       11,
//                       FontWeight.w500)),
//             ],
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text("${callData.lp ?? callData.close ?? 0.00}",
//                     style: textStyle(
//                         const Color(0xff000000), 13, FontWeight.w500)),
//                 const SizedBox(height: 3),
//                 Text("(${callData.perChange ?? 0.00}%)",
//                     style: textStyle(
//                         Color(callData.perChange == null ||
//                                 callData.perChange == "0.00"
//                             ? 0xff666666
//                             : callData.perChange!.startsWith("-")
//                                 ? 0xffFF1717
//                                 : 0xff43A833),
//                         11,
//                         FontWeight.w500)),
//               ],
//             ),
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
