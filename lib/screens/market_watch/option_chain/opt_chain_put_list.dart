import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
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

class OptChainPutList extends ConsumerWidget {
  final List<OptionValues>? putData;

  final bool isPutUp;
  const OptChainPutList({super.key, this.putData, required this.isPutUp});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final socketDatas = watch(websocketProvider).socketDatas;
    final scripData = watch(marketWatchProvider);
    final theme = watch(themeProvider);
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
                        "${putData![index].exch}|${putData![index].token}",
                    task: "t",
                    context: context);
                await scripData.addDelMarketScrip(
                    scripData.wlName,
                    "${putData![index].exch}|${putData![index].token}",
                    context,
                    true,
                    true,
                    false,true);
              }
            },
            onTap: () async {
              await watch(marketWatchProvider).fetchScripQuote(
                  "${putData![index].token}",
                  "${putData![index].exch}",
                  context);
              await scripData.fetchLinkeScrip("${putData![index].token}",
                  "${putData![index].exch}", context);

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
                    builder: (context) =>
                        ScripDepthInfo(wlValue: depthArgs, isBasket: ''));
              }
            },
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [SvgPicture.asset(assets.suitcase,
                                          height: 12,
                                          width: 16,
                                          color: theme.isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${putData![index].lp ?? putData![index].close ?? 0.00}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500)),
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
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              13,
                              FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(
                          "(${putData![index].oiPerChng == "NaN" ? "0.00" : putData![index].oiPerChng ?? 0.00}%)",
                          style: textStyle(
                              putData![index].oiPerChng == null ||
                                      putData![index].oiPerChng == "0.00"
                                  ? colors.ltpgrey
                                  : putData![index].oiPerChng!.startsWith("-")
                                      ? colors.darkred
                                      : colors.ltpgreen,
                              11,
                              FontWeight.w500)),
                    ],
                  ),
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
