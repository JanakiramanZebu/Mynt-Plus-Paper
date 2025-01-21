import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/portfolio_model/holdings_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/alert_dialogue.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/scrip_info_btns.dart'; 

class HoldingDetailScreen extends ConsumerWidget {
  final ExchTsym exchTsym;
  final HoldingsModel holdingData;
  const HoldingDetailScreen(
      {super.key, required this.exchTsym, required this.holdingData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final socketDatas = watch(websocketProvider).socketDatas;
    if (socketDatas.containsKey(exchTsym.token)) {
      exchTsym.lp = "${socketDatas["${exchTsym.token}"]['lp']}";
      exchTsym.perChange = "${socketDatas["${exchTsym.token}"]['pc']}";

      exchTsym.change = "${socketDatas["${exchTsym.token}"]['chng']}";
    }
    final theme = context.read(themeProvider);
    return Scaffold(
        appBar: AppBar(
            elevation: .2,
            leadingWidth: 41,
            titleSpacing: 6,
            leading: const CustomBackBtn(),
            shadowColor: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            title:
                   Padding(
                  padding: const EdgeInsets.only(right:  8.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${exchTsym.tsym}",
                        style: textStyles.appBarTitleTxt.copyWith(
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack)),
                    Text("₹${exchTsym.lp}",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600)),
                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomExchBadge(exch: exchTsym.exch!),
                      Text(
                          "${double.parse("${exchTsym.change.toString()=="null"?"0.00":exchTsym.change} ").toStringAsFixed(2)} (${exchTsym.perChange.toString()=="null"?"0.00":exchTsym.perChange}%)",
                          style: textStyle(
                             (exchTsym.change == "null" ||
                                          exchTsym.change == null) ||
                                      exchTsym.change == "0.00"
                                  ? colors.ltpgrey
                                  : exchTsym.change!.startsWith("-") ||
                                          exchTsym.perChange!.startsWith("-")
                                      ? colors.darkred
                                      : colors.ltpgreen,
                              12,
                              FontWeight.w500))
                    ])
                              ]),
                )),
        body: ListView(children: [
          Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                  mainAxisAlignment: holdingData.sPrdtAli != "null"
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  children: [
                    if (holdingData.sPrdtAli != "null")
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: theme.isDarkMode
                                  ? const Color(0xffB5C0CF).withOpacity(.15)
                                  : const Color(0xffF1F3F8)),
                          child: Text("${holdingData.sPrdtAli}",
                              overflow: TextOverflow.ellipsis,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  13,
                                  FontWeight.w500))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("P&L",
                            style: textStyle(
                                const Color(0xff5E6B7D), 12, FontWeight.w500)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${exchTsym.profitNloss}",
                                style: textStyle(
                                    exchTsym.profitNloss!.startsWith("-")
                                        ? colors.darkred
                                        : colors.ltpgreen,
                                    16,
                                    FontWeight.w600)),
                            Text(" (${exchTsym.pNlChng})%",
                                style: textStyle(
                                    exchTsym.pNlChng!.startsWith("-")
                                        ? colors.darkred
                                        : colors.ltpgreen,
                                    14,
                                    FontWeight.w500)),
                          ],
                        )
                      ],
                    ),
                  ])),
          ScripInfoBtns(
              exch: '${exchTsym.exch}',
              token: '${exchTsym.token}',
              insName: '', tsym: '${exchTsym.tsym}'),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text("Holding details",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sellable Qty",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(
                                "${holdingData.saleableQty ?? 0}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider)
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Avg.Price",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(
                                "${holdingData.upldprc ?? 0}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider)
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Non POA Qty",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(
                                "${holdingData.npoadqty ?? 0}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider)
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Invested",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(
                                "${holdingData.invested == "0.00" ? exchTsym.close ?? 0.00 : holdingData.invested ?? 0.00}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider)
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Pledge Qty",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(
                                "${holdingData.brkcolqty ?? 0}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Current Value",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(
                                (int.parse("${holdingData.currentQty ?? 0}") *
                                        double.parse("${exchTsym.lp ?? 00}"))
                                    .toStringAsFixed(2),
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (holdingData.btstqty != "0") ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("T1 Qty",
                                    style: textStyle(const Color(0xff666666),
                                        12, FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text(
                                  "${holdingData.btstqty ?? 0}",
                                  style: textStyle(const Color(0xff000000), 14,
                                      FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Divider(color: colors.colorDivider),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Container(
                    //   height: 40,
                    //      margin: EdgeInsets.symmetric(horizontal: 20),
                    //       decoration: BoxDecoration(
                    //           color: const Color(0xffFFFFFF),
                    //           border: Border.all(color: const Color(0xffECEDEE)),
                    //           borderRadius: BorderRadius.circular(98)),
                    //       child: InkWell(
                    //         onTap: () async {

                    //         },
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             SvgPicture.asset(
                    //              assets.charticon,
                    //               color: const Color(0xff666666),
                    //             ),
                    //             const SizedBox(width: 8),
                    //             Text("Market Depth",
                    //                 style: textStyle(const Color(0XFF000000), 12.5,
                    //                     FontWeight.w500)),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                  ])),
          // ScripInfoBtns(exch: '${exchTsym.exch}', token: '${exchTsym.token}', insName: '')
        ]),
        bottomNavigationBar: BottomAppBar(
          
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const CircularNotchedRectangle(),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                Expanded(
                  child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                          color: const Color(0xff43A833),
                          borderRadius: BorderRadius.circular(32)),
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        onTap: () async {
                          context.read(websocketProvider).establishConnection(
                              channelInput: "${exchTsym.exch}|${exchTsym.token}#",
                              task: "t",
                              context: context);
                          // context
                          //     .read(marketWatchProvider)
                          //     .lastScbTok("${exchTsym.exch}|${exchTsym.token}#");
                          await context.read(marketWatchProvider).fetchScripInfo(
                              "${exchTsym.token}", '${exchTsym.exch}', context);
                          OrderScreenArgs orderArgs = OrderScreenArgs(
                              exchange: '${exchTsym.exch}',
                              tSym: '${exchTsym.tsym}',
                              token: '',
                              transType: true,
                              lotSize: '${exchTsym.ls}',
                              orderTpye: "${holdingData.sPrdtAli}",
                              isExit: false,
                              ltp: '${exchTsym.lp}',
                              perChange: '${exchTsym.perChange}',
                              holdQty: '',
                              isModify: false);
                          // ignore: use_build_context_synchronously
                          Navigator.pushNamed(context, Routes.placeOrderScreen,
                              arguments: {
                                "orderArg": orderArgs,
                                "scripInfo": context
                                    .read(marketWatchProvider)
                                    .scripInfoModel!, "isBskt":""
                              });
                        },
                        child: Center(
                            child: Text("Add More",
                                style: textStyle(const Color(0xffFFFFFF), 14,
                                    FontWeight.w600))),
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                            color: holdingData.saleableQty == 0
                                ?  colors.darkred.withOpacity(.8)
                                : colors.darkred,
                            borderRadius: BorderRadius.circular(32)),
                        width: MediaQuery.of(context).size.width,
                        child: InkWell(
                          onTap: () async {
                            if (holdingData.saleableQty == 0) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialogue(
                                      scripName: "${exchTsym.tsym}",
                                      exch: "${exchTsym.exch}",
                                      content:
                                          'You are unable to exit because there are no sealable quantity.',
                                    );
                                  });
                            } else {
                              context.read(websocketProvider).establishConnection(
                                  channelInput:
                                      "${exchTsym.exch}|${exchTsym.token}#",
                                  task: "t",
                                  context: context);
                              // context
                              //     .read(marketWatchProvider)
                              //     .lastScbTok("${exchTsym.exch}|${exchTsym.token}#");
                              await context
                                  .read(marketWatchProvider)
                                  .fetchScripInfo("${exchTsym.token}",
                                      '${exchTsym.exch}', context);
                              OrderScreenArgs orderArgs = OrderScreenArgs(
                                  exchange: '${exchTsym.exch}',
                                  tSym: '${exchTsym.tsym}',
                                  token: '',
                                  transType: false,
                                  lotSize: '${exchTsym.ls}',
                                  isExit: true,
                                  ltp: '${exchTsym.lp}',
                                  perChange: '${exchTsym.perChange}',
                                  orderTpye: "${holdingData.sPrdtAli}",
                                  holdQty: "${holdingData.saleableQty ?? 0}",
                                  isModify: false);
                              Navigator.pushNamed(
                                  context, Routes.placeOrderScreen,
                                  arguments: {
                                    "orderArg": orderArgs,
                                    "scripInfo": context
                                        .read(marketWatchProvider)
                                        .scripInfoModel!, "isBskt":""
                                  });
                            }
                          },
                          child: Center(
                              child: Text("Exit",
                                  style: textStyle(const Color(0xffFFFFFF), 14,
                                      FontWeight.w600))),
                        )))
              ]),
            )));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
