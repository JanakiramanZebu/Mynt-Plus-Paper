import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/list_divider.dart';
import '../scrip_depth_info.dart'; 

class OptChainPutList extends ConsumerWidget {
  final List<OptionValues>? putData;

  final bool isPutUp;
  const OptChainPutList({super.key, this.putData, required this.isPutUp});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final socketDatas = watch(websocketProvider).socketDatas;
    final scripData = watch(marketWatchProvider);     final theme = watch(themeProvider);
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: isPutUp ? true : false,
      itemCount: putData!.length,
      itemBuilder: (BuildContext context, int index) {
        if (socketDatas.containsKey(putData![index].token)) {
          putData![index].lp =
              "${socketDatas["${putData![index].token}"]['lp']}";
          putData![index].perChange =
              "${socketDatas["${putData![index].token}"]['pc']}";

          putData![index].oiLack = (double.parse(
                      "${socketDatas["${putData![index].token}"]['oi']}") /
                  100000)
              .toStringAsFixed(2);

          putData![index].oiPerChng = ((double.parse(
                          "${socketDatas["${putData![index].token}"]['poi'] ?? 0.00}") /
                      double.parse(
                          "${socketDatas["${putData![index].token}"]['oi'] ?? 0.00}")) *
                  100)
              .toStringAsFixed(2);
        }
        return InkWell(
            onTap: () async {
              await watch(marketWatchProvider).fetchScripQuote(
                  "${putData![index].token}",
                  "${putData![index].exch}",
                  context);
              await scripData.fetchLinkeScrip(
                  "${putData![index].token}", "${putData![index].exch}",context);

     
              await watch(websocketProvider).establishConnection(
                  channelInput:
                      "${putData![index].exch}|${putData![index].token}",
                  task: "d",
                  context: context);

              if (watch(marketWatchProvider).getQuotes!.stat == "Ok") {
                DepthInputArgs depthArgs = DepthInputArgs(
                    exch: '${putData![index].exch}',
                    token: '${putData![index].token}',
                    tsym: '${putData![index].tsym}',
                    instname: "",
                    symbol: '${putData![index].symbol}',
                    expDate: '${putData![index].expDate}',
                    option: '${putData![index].option}');
                Navigator.pop(context);
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
                    builder: (context) => ScripDepthInfo(wlValue: depthArgs));
              }
            },
            child: Container(
          
              height: 58,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${putData![index].lp ?? putData![index].close ?? 0.00}",
                            style: textStyle(
                              theme.isDarkMode?colors.colorWhite:colors.colorBlack, 13, FontWeight.w500)),
                        const SizedBox(height: 3),
                        Text("(${putData![index].perChange ?? 0.00}%)",
                            style: textStyle(
                               putData![index].perChange == null ||
                                        putData![index].perChange == "0.00"
                                    ? colors.ltpgrey
                                    : putData![index].perChange!.startsWith("-")
                                        ? colors.darkred
                                        : colors.ltpgreen,
                                11,
                                FontWeight.w500)),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("${putData![index].oiLack ?? 0.00}",
                          style: textStyle(
                              theme.isDarkMode?colors.colorWhite:colors.colorBlack, 13, FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(
                          "(${putData![index].oiPerChng == "NaN" ? "0.00" : putData![index].oiPerChng ?? 0.00}%)",
                          style: textStyle(
                              putData![index].oiPerChng == null ||
                                      putData![index].oiPerChng == "0.00"
                                  ? colors.ltpgrey
                                  : putData![index].oiPerChng!.startsWith("-")
                                      ? colors.darkred
                                      :colors.ltpgreen,
                              11,
                              FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            )

            // OptChainPutListUpdate(putData: putData![index])

            );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const ListDivider();
      },
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ));
  }
}

// class OptChainPutListUpdate extends StatelessWidget {
//   final OptionValues putData;
//   const OptChainPutListUpdate({super.key, required this.putData});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: context
//             .read(websocketProvider)
//             .touchAcknowledgementStream
//             .stream
//             .where((event) => event.tk == putData.token),
//         builder:
//             (_, AsyncSnapshot<TouchlineAckStream> snapshotAcknowledgement) {
//           if (snapshotAcknowledgement.data != null) {
//             if (snapshotAcknowledgement.data!.tk == putData.token) {
//               putData.lp = snapshotAcknowledgement.data!.lp == null ||
//                       snapshotAcknowledgement.data!.lp! == 'null'
//                   ? putData.lp
//                   : snapshotAcknowledgement.data!.lp!;
//               putData.perChange = snapshotAcknowledgement.data!.pc == null ||
//                       snapshotAcknowledgement.data!.pc! == 'null'
//                   ? putData.perChange
//                   : snapshotAcknowledgement.data!.pc!;

//               putData.oi = snapshotAcknowledgement.data!.oi == null ||
//                       snapshotAcknowledgement.data!.oi! == 'null'
//                   ? putData.oi
//                   : snapshotAcknowledgement.data!.oi!;
//               putData.poi = snapshotAcknowledgement.data!.poi == null ||
//                       snapshotAcknowledgement.data!.poi! == 'null'
//                   ? putData.poi
//                   : snapshotAcknowledgement.data!.poi!;
//               putData.oiLack = (double.parse("${putData.oi ?? 0.00}") / 100000)
//                   .toStringAsFixed(2);

//               putData.oiPerChng = ((double.parse("${putData.poi ?? 0.00}") /
//                           double.parse("${putData.oi ?? 0.00}")) *
//                       100)
//                   .toStringAsFixed(2);
//               putData.close = snapshotAcknowledgement.data!.c == null ||
//                       snapshotAcknowledgement.data!.c! == 'null'
//                   ? putData.close
//                   : snapshotAcknowledgement.data!.c!;
//             }
//           }
//           return StreamBuilder(
//             stream: context
//                 .read(websocketProvider)
//                 .mwStream
//                 .stream
//                 .where((event) => event.tk == putData.token),
//             builder: (_, AsyncSnapshot<UpdateStream> snapshot) {
//               // if (snapshot.connectionState == ConnectionState.active) {
//               if (snapshot.data != null) {
//                 if (snapshot.data!.tk == putData.token) {
//                   putData.lp =
//                       snapshot.data!.lp == null || snapshot.data!.lp! == 'null'
//                           ? putData.lp
//                           : snapshot.data!.lp!;
//                   putData.perChange =
//                       snapshot.data!.pc == null || snapshot.data!.pc! == 'null'
//                           ? putData.perChange
//                           : snapshot.data!.pc!;
//                   putData.oi =
//                       snapshot.data!.oi == null || snapshot.data!.oi! == 'null'
//                           ? putData.oi
//                           : snapshot.data!.oi!;
//                   putData.poi = snapshot.data!.poi == null ||
//                           snapshot.data!.poi! == 'null'
//                       ? putData.poi
//                       : snapshot.data!.poi!;

//                   putData.oiLack =
//                       (double.parse("${putData.oi ?? 0.00}") / 100000)
//                           .toStringAsFixed(2);

//                   putData.oiPerChng = ((double.parse("${putData.poi ?? 0.00}") /
//                               double.parse("${putData.oi ?? 0.00}")) *
//                           100)
//                       .toStringAsFixed(2);
//                   putData.close =
//                       snapshot.data!.c == null || snapshot.data!.c! == 'null'
//                           ? putData.close
//                           : snapshot.data!.c!;
//                 }
//                 // }
//                 return putListUpdate();
//               } else {
//                 return putListUpdate();
//               }
//             },
//           );
//         });
//   }

//   Container putListUpdate() {
//     return Container(
//       color: Colors.white,
//       height: 58,
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text("${putData.lp ?? putData.close ?? 0.00}",
//                     style: textStyle(
//                         const Color(0xff000000), 13, FontWeight.w500)),
//                 const SizedBox(height: 3),
//                 Text("(${putData.perChange ?? 0.00}%)",
//                     style: textStyle(
//                         Color(putData.perChange == null ||
//                                 putData.perChange == "0.00"
//                             ? 0xff666666
//                             : putData.perChange!.startsWith("-")
//                                 ? 0xffFF1717
//                                 : 0xff43A833),
//                         11,
//                         FontWeight.w500)),
//               ],
//             ),
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text("${putData.oiLack ?? 0.00}",
//                   style:
//                       textStyle(const Color(0xff000000), 13, FontWeight.w500)),
//               const SizedBox(height: 3),
//               Text(
//                   "(${putData.oiPerChng == "NaN" ? "0.00" : putData.oiPerChng ?? 0.00}%)",
//                   style: textStyle(
//                       Color(putData.oiPerChng == null ||
//                               putData.oiPerChng == "0.00"
//                           ? 0xff666666
//                           : putData.oiPerChng!.startsWith("-")
//                               ? 0xffFF1717
//                               : 0xff43A833),
//                       11,
//                       FontWeight.w500)),
//             ],
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
