// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';

class OptChainCallList extends ConsumerWidget {
  final List<OptionValues>? callData;

  final bool isCallUp;
  final SwipeActionController? swipe;
  const OptChainCallList(
      {super.key, this.callData, this.swipe, required this.isCallUp});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final socketDatas = watch(websocketProvider).socketDatas;
    final scripData = watch(marketWatchProvider);
    final theme = watch(themeProvider);
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: isCallUp ? true : false,
      itemCount: callData!.length * 2 - 1,
      itemBuilder: (BuildContext context, int index) {
        final itemIndex = index ~/ 2;
        if (socketDatas.containsKey(callData![itemIndex].token)) {
          callData![itemIndex].lp =
              "${socketDatas["${callData![itemIndex].token}"]['lp']}";
          callData![itemIndex].perChange =
              "${socketDatas["${callData![itemIndex].token}"]['pc']}";

          callData![itemIndex].oiLack = (double.parse(
                      "${socketDatas["${callData![itemIndex].token}"]['oi']}") /
                  100000)
              .toStringAsFixed(2);

          callData![itemIndex].oiPerChng = ((double.parse(
                          "${socketDatas["${callData![itemIndex].token}"]['poi'] ?? 0.00}") /
                      double.parse(
                          "${socketDatas["${callData![itemIndex].token}"]['oi'] ?? 0.00}")) *
                  100)
              .toStringAsFixed(2);
        }
        if (index.isOdd) {
          return const ListDivider();
        }
        return SwipeActionCell(
          isDraggable: true,
          fullSwipeFactor: 0.7,
          controller: swipe,
          index: index,
          key: ValueKey(callData![itemIndex]),
          leadingActions: [
            SwipeAction(
                performsFirstActionWithFullSwipe: true,
                title: "SELL",
                color: Color(theme.isDarkMode ? 0xfffbbbb6 : 0xfffee8e7),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.darkred),
                onTap: (handler) async {
                  await placeOrderInput(
                      scripData,
                      context,
                      callData![itemIndex],
                      false);
                  handler(false);
                }),
          ],
          trailingActions: [
            SwipeAction(
                performsFirstActionWithFullSwipe: true,
                title: "BUY",
                color: Color(theme.isDarkMode ? 0xffcaedc4 : 0xffedf9eb),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.ltpgreen),
                onTap: (handler) async {
                    await placeOrderInput(
                      scripData,
                      context,
                      callData![itemIndex],
                      true);
                  handler(false);
                }),
          ],
          child: GestureDetector(
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
                        "${callData![itemIndex].exch}|${callData![itemIndex].token}",
                    task: "t",
                    context: context);
                await scripData.addDelMarketScrip(
                    scripData.wlName,
                    "${callData![itemIndex].exch}|${callData![itemIndex].token}",
                    context,
                    true,
                    true,
                    false,
                    true);
              }
            },
            onTap: () async {
              await scripData.fetchScripQuoteIndex(
                  "${callData![itemIndex].token}",
                  "${callData![itemIndex].exch}",
                  context);
              final quots = scripData.getQuotes;
              DepthInputArgs depthArgs = DepthInputArgs(
                  exch: quots!.exch.toString(),
                  token: quots.token.toString(),
                  tsym: quots.tsym.toString(),
                  instname: quots.instname.toString(),
                  symbol: quots.symbol.toString(),
                  expDate: quots.expDate.toString(),
                  option: quots.option.toString());
              Navigator.pop(context);
              await scripData.calldepthApis(context, depthArgs, "");
            },
            child: InkWell(
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
                      Text("${callData![itemIndex].oiLack ?? 0.00}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              13,
                              FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(
                          "(${callData![itemIndex].oiPerChng == "NaN" ? "0.00" : callData![itemIndex].oiPerChng ?? 0.00}%)",
                          style: textStyle(
                              callData![itemIndex].oiPerChng == null ||
                                      callData![itemIndex].oiPerChng == "0.00"
                                  ? colors.ltpgrey
                                  : callData![itemIndex]
                                          .oiPerChng!
                                          .startsWith("-")
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
                            "${callData![itemIndex].lp ?? callData![itemIndex].close ?? 0.00}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500)),
                        const SizedBox(height: 3),
                        Text("(${callData![itemIndex].perChange ?? 0.00}%)",
                            style: textStyle(
                                callData![itemIndex].perChange == null ||
                                        callData![itemIndex].perChange == "0.00"
                                    ? colors.ltpgrey
                                    : callData![itemIndex]
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
            )),
          ),
        );
      },
      // separatorBuilder: (BuildContext context, int index) {
      //   return const ListDivider();
      // },
    );
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext context,
      OptionValues depthData, bool transType) async {
    await context.read(marketWatchProvider).fetchScripInfo(
        depthData.token.toString(), depthData.exch.toString(), context, true);
    OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: depthData.exch.toString(),
        tSym: depthData.tsym.toString(),
        isExit: false,
        token: depthData.token.toString(),
        transType: transType,
        lotSize: depthData.ls,
        ltp: "${depthData.lp ?? depthData.close ?? 0.00}",
        perChange: depthData.perChange ?? "0.00",
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {});
    Navigator.pop(context);
    Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
      "orderArg": orderArgs,
      "scripInfo": context.read(marketWatchProvider).scripInfoModel!,
      "isBskt": ""
    });
  }

}
