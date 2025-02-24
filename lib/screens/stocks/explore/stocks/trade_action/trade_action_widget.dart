import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../../provider/market_watch_provider.dart';
import '../../../../../provider/stocks_provider.dart';
import '../../../../../provider/websocket_provider.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/no_data_found.dart';

class TradeAction extends StatefulWidget {
  const TradeAction({super.key});

  @override
  State<TradeAction> createState() => _TradeActionState();
}

class _TradeActionState extends State<TradeAction> {
  List<String> tradeAction = [
    "Top gainers",
    "Top losers",
    "Vol. breakout",
    "Most Active"
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final actionTrade = watch(stocksProvide);
      final marketWatch = watch(marketWatchProvider);
      final socketDatas = watch(websocketProvider).socketDatas;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's trade action",
                      style: textStyle(
                          const Color(0xff000000), 16, FontWeight.w600)),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      menuItemStyleData: MenuItemStyleData(
                          customHeights: actionTrade.getCustomItemsHeight()),

                      buttonStyleData: const ButtonStyleData(
                          height: 32,
                          width: 100,
                          decoration: BoxDecoration(
                              color: Color(0xffF1F3F8),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32)))),
                      dropdownStyleData: DropdownStyleData(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        offset: const Offset(0, 8),
                      ),
                      // buttonSplashColor: Colors.transparent,
                      isExpanded: true,
                      style: textStyle(
                          const Color(0XFF000000), 13, FontWeight.w500),
                      hint: Text(actionTrade.selctedTradeAct,
                          style: textStyle(
                              const Color(0XFF000000), 13, FontWeight.w500)),
                      items: actionTrade.addDividersAfterExpDates(),
                      // customItemsHeights: actionTrade.getCustomItemsHeight(),
                      value: actionTrade.selctedTradeAct,
                      onChanged: (value) async {
                        if (value != actionTrade.selctedTradeAct) {
                          actionTrade.chngTradeAct("$value");
                        }
                      },
                      // buttonHeight: 36,
                      // buttonWidth: 120,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: tradeAction.length,
                    itemBuilder: (BuildContext context, int index) {
                      return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              tradeAction[index] == actionTrade.tradeData
                                  ? const Color(0xff000000)
                                  : Colors.transparent,
                          side: BorderSide(
                            width: 1,
                            color: tradeAction[index] == actionTrade.tradeData
                                ? const Color(0xff000000)
                                : const Color(0xff666666),
                          ),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                        ),
                        onPressed: () async {
                          actionTrade.requestWSTradeaction(
                              isSubscribe: false, context: context);
                          await actionTrade.chngTradeAction(tradeAction[index]);
                          actionTrade.requestWSTradeaction(
                              isSubscribe: true, context: context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                  "assets/icon/${index == 0 ? 'tg' : index == 1 ? 'tl' : index == 2 ? 'vb' : 'ma'}.svg",
                                  width: 18,
                                  height: 18),
                              const SizedBox(width: 6),
                              Text(
                                tradeAction[index],
                                style: textStyle(
                                    tradeAction[index] == actionTrade.tradeData
                                        ? const Color(0xffffffff)
                                        : const Color(0xff666666),
                                    13,
                                    FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 8);
                    },
                  )),
              const SizedBox(height: 16),
            ]),
          ),
          actionTrade.topStockData.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 7,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (socketDatas.containsKey(
                            actionTrade.topStockData[index].token)) {
                          actionTrade.topStockData[index].lp =
                              "${socketDatas["${actionTrade.topStockData[index].token}"]['lp'] ?? 0.00}";
                          actionTrade.topStockData[index].pc =
                              "${socketDatas["${actionTrade.topStockData[index].token}"]['pc'] ?? 0.00}";
                          actionTrade.topStockData[index].v =
                              "${socketDatas["${actionTrade.topStockData[index].token}"]['v'] ?? 0.00}";
                        }
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                DepthInputArgs depthArgs = DepthInputArgs(
                                    exch: actionTrade.topStockData[index].exch
                                        .toString(),
                                    token: actionTrade.topStockData[index].token
                                        .toString(),
                                    tsym: actionTrade.topStockData[index].tsym
                                        .toString(),
                                    instname: "",
                                    symbol: actionTrade.topStockData[index].tsym
                                        .toString(),
                                    expDate: "",
                                    option: "");
                                await marketWatch.calldepthApis(
                                    context, depthArgs, "");
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${actionTrade.topStockData[index].tsym}",
                                            style: textStyle(
                                                const Color(0xff000000),
                                                14,
                                                FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        Text(
                                            "Vol :${actionTrade.topStockData[index].v}",
                                            style: textStyle(
                                                const Color(0xff999999),
                                                12,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            "₹${actionTrade.topStockData[index].lp}",
                                            style: textStyle(
                                                const Color(0xff000000),
                                                14,
                                                FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        Text(
                                            "${actionTrade.topStockData[index].pc}%",
                                            style: textStyle(
                                                actionTrade
                                                        .topStockData[index].pc!
                                                        .startsWith("-")
                                                    ? const Color(0xffE00000)
                                                    : const Color(0xff43A833),
                                                12,
                                                FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index !=
                                (actionTrade.topStockData.length - 1)) ...[
                              Divider(
                                color: colors.colorDivider,
                                thickness: 0.6,
                                height: 26,
                              ),
                            ]
                          ],
                        );
                      },
                    ),

                    // const SizedBox(height: 8,),
                    // Divider(
                    //   color: colors.colorDivider,
                    //   thickness: 0.6,
                    // ),
                    // InkWell(
                    //     onTap: () async {
                    //       await actionTrade.fetchALLAdindices();
                    //       Navigator.pushNamed(context, Routes.allTrade);
                    //     },
                    //     child: Text('See more stocks',
                    //         style: GoogleFonts.inter(
                    //             color: const Color(0xff0037B7),
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w600)))
                  ],
                )
              : const Center(child: NoDataFound()),
          // const SizedBox(height: 14),
        ],
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
