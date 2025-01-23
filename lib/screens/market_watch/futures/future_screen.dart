// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/list_divider.dart';
import '../scrip_depth_info.dart';

class FutureScreen extends ConsumerWidget {
  const FutureScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final future = watch(marketWatchProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    final theme = context.read(themeProvider);
    // final internet = watch(networkStateProvider);
    return

        // WillPopScope(
        //     onWillPop: () async {
        //       future.requestWSFut(context: context, isSubscribe: false);
        //       await future.requestWSMarketWatchScrip(
        //           context: context, isSubscribe: true);

        //       return true;
        //     },
        //     child: Scaffold(
        //         backgroundColor: const Color(0xffFFFFFF),
        //         appBar: AppBar(
        //           backgroundColor: const Color(0xffFFFFFF),
        //           elevation: 0.3,
        //           centerTitle: false,
        //           iconTheme: const IconThemeData(color: Color(0xff000000)),
        //           title: Row(
        //             children: [
        //               Text("Futures",
        //                   style: textStyle(
        //                       const Color(0xff000000), 18, FontWeight.w600)),
        //               Text(" (${future.fut!.length})",
        //                   style: textStyle(colors.colorBlue, 17, FontWeight.w600)),
        //             ],
        //           ),
        //         ),
        //         body: Stack(
        //           children: [

        ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: future.fut!.length,
      separatorBuilder: (BuildContext context, int index) {
        return const ListDivider();
      },
      itemBuilder: (BuildContext context, int index) {
        if (socketDatas.containsKey(future.fut![index].token)) {
          future.fut![index].ltp =
              "${socketDatas["${future.fut![index].token}"]['lp']}";
          future.fut![index].change =
              "${socketDatas["${future.fut![index].token}"]['chng']}";
          future.fut![index].perChange =
              "${socketDatas["${future.fut![index].token}"]['pc']}";
        }
        return InkWell(
            onTap: () async {
              watch(marketWatchProvider).singlePageloader(true);
              Navigator.pop(context);

              DepthInputArgs depthArgs = DepthInputArgs(
                  exch: '${future.fut![index].exch}',
                  token: '${future.fut![index].token}',
                  tsym: '${future.fut![index].tsym}',
                  instname: "",
                  symbol: '${future.fut![index].symbol}',
                  expDate: '${future.fut![index].expDate}',
                  option: '${future.fut![index].option}');
              showModalBottomSheet(
                  isScrollControlled: true,
                  useSafeArea: true,
                  isDismissible: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16))),
                  backgroundColor: const Color(0xffffffff),
                  context: context,
                  builder: (context) => ScripDepthInfo(
                        wlValue: depthArgs,
                        isBasket: '',
                      ));
              watch(marketWatchProvider).singlePageloader(false);

              await watch(websocketProvider).establishConnection(
                  channelInput:
                      "${future.fut![index].exch}|${future.fut![index].token}",
                  task: "d",
                  context: context);
              await watch(marketWatchProvider).fetchScripQuote(
                  "${future.fut![index].token}",
                  "${future.fut![index].exch}",
                  context);

              if (watch(marketWatchProvider).getQuotes!.stat == "Ok") {
                await context.read(marketWatchProvider).fetchLinkeScrip(
                    "${future.fut![index].token}",
                    "${future.fut![index].exch}",
                    context);
              }

            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              dense: true,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${future.fut![index].symbol} ",
                      style: textStyles.scripNameTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
                  if (future.fut![index].option!.isNotEmpty)
                    Text("${future.fut![index].option}",
                        style: textStyles.scripNameTxtStyle
                            .copyWith(color: const Color(0xff666666))),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text("${future.fut![index].exch}  ",
                          style: textStyles.scripExchTxtStyle),
                      if (future.fut![index].expDate!.isNotEmpty)
                        Text("${future.fut![index].expDate}  ",
                            style: textStyles.scripExchTxtStyle
                                .copyWith(color: colors.colorBlack)),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "₹${future.fut![index].ltp ?? future.fut![index].close ?? 0.00}",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    "${future.fut![index].change == "null" ? "0.00 " : double.parse("${future.fut![index].change}").toStringAsFixed(2)} "
                    "${future.fut![index].perChange == "null" ? "(0.00%)" : "(${future.fut![index].perChange ?? 0.00}%)"}",
                    style: textStyle(
                        future.fut![index].change!.startsWith("-") ||
                                future.fut![index].perChange!.startsWith('-')
                            ? colors.darkred
                            : (future.fut![index].change == "null" ||
                                        future.fut![index].perChange ==
                                            "null") ||
                                    (future.fut![index].change == "0.00" ||
                                        future.fut![index].perChange == "0.00")
                                ? colors.ltpgrey
                                : colors.ltpgreen,
                        12,
                        FontWeight.w600),
                  ),
                ],
              ),
            )

            // FutureListCard(
            //     key: Key(index.toString()),
            //     scripData: future.fut![index])

            );
      },
      //               ),
      //               if (internet.connectionStatus == ConnectivityResult.none) ...[
      //                 const NoInternetWidget()
      //               ]
      //             ],
      //           ))
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
