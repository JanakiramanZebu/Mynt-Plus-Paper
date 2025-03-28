// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
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
            onLongPress: () async {
              if (scripData.isPreDefWLs == "Yes") {
                Fluttertoast.showToast(
                    msg:
                        "This is a pre-defined watchlist that cannot be Added!",
                    timeInSecForIosWeb: 2,
                    backgroundColor: colors.colorBlack,
                    textColor: colors.colorWhite,
                    fontSize: 14.0);
              } else {
                await watch(websocketProvider).establishConnection(
                    channelInput:
                        "${callData![index].exch}|${callData![index].token}",
                    task: "t",
                    context: context);
                await scripData.addDelMarketScrip(
                    scripData.wlName,
                    "${callData![index].exch}|${callData![index].token}",
                    context,
                    true,
                    true,
                    false,
                    true);
              }
            },
            onTap: () async {
              await scripData.fetchScripQuote("${callData![index].token}",
                  "${callData![index].exch}", context);

           

              if (watch(marketWatchProvider).getQuotes!.stat == "Ok") {
                Navigator.pop(context);
                   await context.read(marketWatchProvider).fetchLinkeScrip(
                  "${callData![index].token}",
                  "${callData![index].exch}",
                  context);

              await watch(websocketProvider).establishConnection(
                  channelInput:
                      "${callData![index].exch}|${callData![index].token}",
                  task: "d",
                  context: context);
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
                    builder: (context) =>
                        ScripDepthInfo(wlValue: depthArgs, isBasket: ''));
              scripData.chngDephBtn("Overview");

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
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              13,
                              FontWeight.w500)),
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
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500)),
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
                  )
                  // ,SvgPicture.asset(assets.suitcase,
                  //                         height: 12,
                  //                         width: 16,
                  //                         color: theme.isDarkMode
                  //                             ? colors.colorLightBlue
                  //                             : colors.colorBlue),
                ],
              ),
            ));
      },
      separatorBuilder: (BuildContext context, int index) {
        return const ListDivider();
      },
    );
  }
}
