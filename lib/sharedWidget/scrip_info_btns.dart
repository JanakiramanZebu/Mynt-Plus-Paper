import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart'; 
import '../models/marketwatch_model/get_quotes.dart';
import '../provider/market_watch_provider.dart';
import '../screens/market_watch/scrip_depth_info.dart'; 

class ScripInfoBtns extends ConsumerWidget {
  final String token;
  final String exch;
  final String insName;
  const ScripInfoBtns(
      {super.key,
      required this.exch,
      required this.token,
      required this.insName});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final marketwatch = watch(marketWatchProvider);
       final theme = context.read(themeProvider);
    return Container(
        padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
        height: 50,
        decoration:   BoxDecoration( 
            border: Border(top: BorderSide(color:theme.isDarkMode?colors.darkColorDivider: colors.colorDivider,width: 0),bottom: BorderSide(color:theme.isDarkMode?colors.darkColorDivider: colors.colorDivider,width: 0))),
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: marketwatch.depthBtns.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                    color: theme.isDarkMode  ?   const Color(
                                                                  0xffB5C0CF)
                                                              .withOpacity(.15): const Color( 0xffF1F3F8), 
                    borderRadius: BorderRadius.circular(98)),
                child: InkWell(
                    onTap: () async {
                      print(marketwatch.depthBtns[index]['btnName']);

                      if (marketwatch.depthBtns[index]['btnName'] == "Option") {
                        // if ((marketwatch.getQuotes!.exch ==
                        //             "NSE" ||
                        //         marketwatch.getQuotes!.exch ==
                        //             "BSE") &&
                        //     (marketwatch.getQuotes!.instname !=
                        //         "UNDIND")) {
                        //   await marketwatch.fetchTechData(
                        //       exch:
                        //           "${marketwatch.getQuotes!.exch}",
                        //       tradeSym:
                        //           "${marketwatch.getQuotes!.exch}",
                        //       lastPrc:
                        //           "${marketwatch.getQuotes!.lp ?? marketwatch.getQuotes!.c ?? 0.00}",
                        //       context: context);
                        // }
                        if (exch == "NFO" ||
                            (exch == "MCX" && insName == "OPTFUT")) {
                          await marketwatch.fetchStikePrc(
                              "${marketwatch.getQuotes!.undTk}",
                              "${marketwatch.getQuotes!.undExch}",
                              context);
                        }

                        await context.read(websocketProvider).establishConnection(
                            channelInput: (exch == "NFO" ||
                                    (exch == "MCX" && insName == "OPTFUT"))
                                ? '${marketwatch.getQuotes!.undExch ?? marketwatch.getQuotes!.exch}|${marketwatch.getQuotes!.undTk ?? marketwatch.getQuotes!.token}'
                                : '${marketwatch.getQuotes!.exch}|${marketwatch.getQuotes!.token!}',
                            task: "t",
                            context: context);

                        await marketwatch.fetchOPtionChain(
                            context: context,
                            exchange: marketwatch.optionExch!,
                            numofStrike: marketwatch.numStrike,
                            strPrc: marketwatch.optionStrPrc,
                            tradeSym: marketwatch.selectedTradeSym!);
                      } else if (marketwatch.depthBtns[index]['btnName'] ==
                          "Future") {
                        await marketwatch.requestWSFut(
                            context: context, isSubscribe: true);
                      }

                      marketwatch
                          .chngDephBtn(marketwatch.depthBtns[index]['btnName']);

                      if (marketwatch.actDeptBtn == "Overview") {
                        await watch(websocketProvider).establishConnection(
                            channelInput: "$exch|$token",
                            task: "d",
                            context: context);
                      }

                      if (marketwatch.actDeptBtn == "Fundamental") {
                        if ((exch == "NSE" || exch == "BSE") &&
                            (insName != "UNDIND")) {
                          await context
                              .read(marketWatchProvider)
                              .fetchFundamentalData(
                                  tradeSym:
                                      "${context.read(marketWatchProvider).getQuotes!.exch}:${context.read(marketWatchProvider).getQuotes!.tsym}");
                        }
                        marketwatch.chngshareHold("Promoter Holding");
                      }

                      DepthInputArgs depthArgs = DepthInputArgs(
                          exch: exch,
                          token: token,
                          tsym: '${marketwatch.getQuotes!.tsym}',
                          instname: marketwatch.getQuotes!.instname ?? "",
                          symbol: '${marketwatch.getQuotes!.symbol}',
                          expDate: '${marketwatch.getQuotes!.expDate}',
                          option: '${marketwatch.getQuotes!.option}');

                      showModalBottomSheet(
                          barrierColor: Colors.transparent,
                          isScrollControlled: true,
                          useSafeArea: true,
                          isDismissible: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16))),
                          backgroundColor: const Color(0xffffffff),
                          context: context,
                          builder: (context) =>
                              ScripDepthInfo(wlValue: depthArgs, isBasket: ''));
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "${marketwatch.depthBtns[index]['imgPath']}",
                          color:  theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                        ),
                        const SizedBox(width: 8),
                        Text("${marketwatch.depthBtns[index]['btnName']}",
                            style: textStyle(
                                theme.isDarkMode?colors.colorWhite:colors.colorBlack, 12.5, FontWeight.w500))
                      ],
                    )),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 10);
            }));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
