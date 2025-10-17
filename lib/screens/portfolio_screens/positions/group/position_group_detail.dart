import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/custom_exch_badge.dart';
import '../../../../res/global_state_text.dart';
import '../../../../sharedWidget/scrip_info_btns.dart';

class PositionGroupDetail extends ConsumerWidget {
  final Map<String, dynamic> positionData;
  const PositionGroupDetail({super.key, required this.positionData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(portfolioProvider);
    final theme = ref.read(themeProvider);
    
    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};
        
        // Update position data with real-time values
        if (socketDatas.containsKey(positionData['token'])) {
          final lp = socketDatas["${positionData['token']}"]['lp']?.toString();
          final pc = socketDatas["${positionData['token']}"]['pc']?.toString();
          final chng = socketDatas["${positionData['token']}"]['chng']?.toString();
          
          if (lp != null && lp != "null") {
            positionData['lp'] = lp;
          }
          
          if (pc != null && pc != "null") {
            positionData['perChange'] = pc;
          }
          
          if (chng != null && chng != "null") {
            positionData['chng'] = chng;
          }
          
          // Calculate P&L or MTM based on latest price
          if (positionData['avgPrc'] != null && positionData['netqty'] != null) {
            final avgPrice = double.tryParse(positionData['avgPrc']?.toString() ?? "0.0") ?? 0.0;
            final qty = int.tryParse(positionData['netqty']?.toString() ?? "0") ?? 0;
            final ltp = double.tryParse(positionData['lp']?.toString() ?? "0.0") ?? 0.0;
            
            if (avgPrice > 0 && qty != 0 && ltp > 0) {
              final pnl = (ltp - avgPrice) * qty;
              positionData['profitNloss'] = pnl.toStringAsFixed(2);
              positionData['mTm'] = pnl.toStringAsFixed(2);
            }
          }
        }
        
        return Scaffold(
            appBar: AppBar(
                elevation: .2,
                centerTitle: false,
                leadingWidth: 41,
                titleSpacing: 6,
                leading: const CustomBackBtn(),
                title: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("${positionData['symbol']}",
                                    style: textStyles.appBarTitleTxt.copyWith(
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack)),
                                Text(" ${positionData['option']} ",
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyles.scripNameTxtStyle.copyWith(
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack)),
                              ],
                            ),
                            TextWidget.titleText(
                                text: "₹${positionData['lp']}",
                                theme: theme.isDarkMode,
                                fw: 1),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(children: [
                                CustomExchBadge(exch: "${positionData['exch']}"),
                                TextWidget.captionText(
                                    text: "  ${positionData['expDate']}",
                                    theme: theme.isDarkMode,
                                    fw: 1)
                              ]),
                              TextWidget.captionText(
                                  text: "${double.parse("${positionData['chng'] ?? 0.00} ").toStringAsFixed(2)} (${positionData['perChange'] ?? 0.00}%)",
                                  theme: theme.isDarkMode,
                                  fw: 0,
                                  color: (positionData['chng'].toString() == "null") ||
                                              positionData['chng'] == "0.00"
                                          ? colors.ltpgrey
                                          : positionData['chng']!.startsWith("-") ||
                                                  positionData['perChange']!
                                                      .startsWith("-")
                                              ? colors.darkred
                                              : colors.ltpgreen)
                            ])
                      ]),
                )),
            body: ListView(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: theme.isDarkMode
                                ? const Color(0xff666666).withOpacity(.2)
                                : const Color(0xff999999).withOpacity(.2)),
                        child: TextWidget.captionText(
                            text: "${positionData['s_prdt_ali']}",
                            theme: theme.isDarkMode,
                            fw: 1,
                            color: const Color(0xff666666))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidget.captionText(
                            text: positions.isNetPnl ? "P&L" : "MTM",
                            theme: theme.isDarkMode,
                            fw: 0,
                            color: const Color(0xff5E6B7D)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (positions.isNetPnl) ...[
                              TextWidget.subText(
                                  text: "₹${positionData['profitNloss'] ?? positionData['rpnl']}",
                                  theme: theme.isDarkMode,
                                  fw: 1,
                                  color: positionData['profitNloss'] != null
                                          ? positionData['profitNloss']!
                                                  .startsWith("-")
                                              ? colors.darkred
                                              : positionData['profitNloss'] ==
                                                      "0.00"
                                                  ? colors.ltpgrey
                                                  : colors.ltpgreen
                                          : positionData['rpnl']!.startsWith("-")
                                              ? colors.darkred
                                              : positionData['rpnl'] == "0.00"
                                                  ? colors.ltpgrey
                                                  : colors.ltpgreen)
                            ] else ...[
                              TextWidget.subText(
                                  text: "₹${positionData['mTm']}",
                                  theme: theme.isDarkMode,
                                  fw: 1,
                                  color: positionData['mTm']!.startsWith("-")
                                          ? colors.darkred
                                          : positionData['mTm'] == "0.00"
                                              ? colors.ltpgrey
                                              : colors.ltpgreen)
                            ]
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ScripInfoBtns(
                  exch: '${positionData['exch']}',
                  token: '${positionData['token']}',
                  insName: '',
                  tsym: '${positionData['tysm']}'),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        TextWidget.titleText(
                            text: "Position details",
                            theme: theme.isDarkMode,
                            fw: 1),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.subText(
                                      text: "Price",
                                      theme: theme.isDarkMode,
                                      fw: 1),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                      text: "${positionData['dayavgprc'] ?? 0.00}",
                                      theme: theme.isDarkMode,
                                      fw: 1),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                  TextWidget.captionText(
                                      text: "Day Buy Avg",
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                      color: const Color(0xff666666)),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                    text: "${positionData['daybuyavgprc'] ?? 0.00}",
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                            const SizedBox(width: 27),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.subText(
                                      text: "Net Qty",
                                      theme: theme.isDarkMode,
                                      fw: 1),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                      text: "${positionData['netqty'] ?? 0}",
                                      theme: theme.isDarkMode,
                                      fw: 1),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                  TextWidget.captionText(
                                      text: "Day Buy Qty",
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                      color: const Color(0xff666666)),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                    text: "${positionData['daybuyqty'] ?? 0}",
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
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
                                  TextWidget.captionText(
                                      text: "Day Sell Avg",
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                      color: const Color(0xff666666)),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                    text: "${positionData['daysellavgprc'] ?? 0.00}",
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                            const SizedBox(width: 27),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.captionText(
                                      text: "Day Sell Qty",
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                      color: const Color(0xff666666)),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                    text: "${positionData['daysellqty'] ?? 0}",
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
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
                                  TextWidget.captionText(
                                      text: "CF Buy Avg",
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                      color: const Color(0xff666666)),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                    text: "${positionData['cfbuyavgprc'] ?? 0.00}",
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                            const SizedBox(width: 27),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.captionText(
                                      text: "CF Buy Qty",
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                      color: const Color(0xff666666)),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                    text: "${positionData['cfbuyqty'] ?? 0}",
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
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
                                  TextWidget.captionText(
                                      text: "CF Sell Avg",
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                      color: const Color(0xff666666)),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                    text: "${positionData['cfsellavgprc'] ?? 0.00}",
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                            const SizedBox(width: 27),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.captionText(
                                      text: "CF Sell Qty",
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                      color: const Color(0xff666666)),
                                  const SizedBox(height: 2),
                                  TextWidget.subText(
                                    text: "${positionData['cfsellqty'] ?? 0}",
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextWidget.subText(
                            text: "Net Buy Value",
                            theme: theme.isDarkMode,
                            fw: 0),
                        const SizedBox(height: 2),
                        TextWidget.subText(
                          text: "${positionData['totbuyamt'] ?? 0.00}",
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                        const SizedBox(height: 2),
                        Divider(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider),
                        const SizedBox(height: 4),
                        TextWidget.subText(
                            text: "Net Sell Value",
                            theme: theme.isDarkMode,
                            fw: 0),
                        const SizedBox(height: 2),
                        TextWidget.subText(
                          text: "${positionData['totsellamt'] ?? 0.00}",
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                        const SizedBox(height: 2),
                        Divider(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider),
                        const SizedBox(height: 4),
                        TextWidget.subText(
                            text: "Net Value",
                            theme: theme.isDarkMode,
                            fw: 0),
                        const SizedBox(height: 2),
                        TextWidget.subText(
                          text: (double.parse("${positionData['totbuyamt'] ?? 0.00}") +
                                  double.parse(
                                      "${positionData['totsellamt'] ?? 0.00}"))
                              .toStringAsFixed(2),
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                      ])),
              // ScripInfoBtns(exch: '${positionData['exch']}', token: '${positionData['token']}', insName: '')
            ]),
            bottomNavigationBar: positionData['s_prdt_ali'] == "BO" ||
                    positionData['s_prdt_ali'] == "CO"
                ? null
                : BottomAppBar(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const CircularNotchedRectangle(),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(children: [
                        Expanded(
                          child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                  color: const Color(0xff43A833),
                                  borderRadius: BorderRadius.circular(32)),
                              width: MediaQuery.of(context).size.width,
                              child: InkWell(
                                onTap: () async {
                                  await ref.read(marketWatchProvider)
                                      .fetchScripInfo("${positionData['token']}",
                                          '${positionData['exch']}', context, true);
                                  Navigator.pop(context);
                                  OrderScreenArgs orderArgs = OrderScreenArgs(
                                      exchange: '${positionData['exch']}',
                                      tSym: '${positionData['tsym']}',
                                      isExit: false,
                                      token: "${positionData['token']}",
                                      transType: true,
                                      prd: "${positionData['prd']}",
                                      // change: depthData['chng'],
                                      // close: depthData.c,
                                      lotSize: positionData['netqty'],
                                      ltp: positionData['lp'],
                                      perChange:
                                          positionData['perChange'] ?? "0.00",
                                      orderTpye: '',
                                      holdQty: '${positionData['netqty']}',
                                      isModify: false,
                                      raw: {});

                                  Navigator.pushNamed(
                                      context, Routes.placeOrderScreen,
                                      arguments: {
                                        "orderArg": orderArgs,
                                        "scripInfo": ref.read(marketWatchProvider)
                                            .scripInfoModel!,
                                        "isBskt": ""
                                      });
                                },
                                child: Center(
                                    child: TextWidget.subText(
                                        text: "Add More",
                                        theme: false,
                                        fw: 1,
                                        color: const Color(0xffFFFFFF))),
                              )),
                        ),
                        if (positionData['qty'] != "0" && !positions.isDay) ...[
                          const SizedBox(width: 12),
                          Expanded(
                              child: Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                      color: colors.darkred,
                                      borderRadius: BorderRadius.circular(32)),
                                  width: MediaQuery.of(context).size.width,
                                  child: InkWell(
                                    onTap: () async {
                                      await ref.read(marketWatchProvider)
                                          .fetchScripInfo(
                                              "${positionData['token']}",
                                              '${positionData['exch']}',
                                              context, true);
                                      Navigator.pop(context);
                                      OrderScreenArgs orderArgs = OrderScreenArgs(
                                          exchange: '${positionData['exch']}',
                                          tSym: '${positionData['tsym']}',
                                          isExit: false,
                                          token: "${positionData['token']}",
                                          transType:
                                              int.parse(positionData['netqty']!) < 0
                                                  ? true
                                                  : false,
                                          // change: depthData['chng'],
                                          // close: depthData.c,
                                          lotSize: positionData['netqty'],
                                          ltp: positionData['lp'],
                                          perChange:
                                              positionData['perChange'] ?? "0.00",
                                          orderTpye: '',
                                          holdQty: '${positionData['netqty']}',
                                          isModify: false,
                                          raw: {});

                                      Navigator.pushNamed(
                                          context, Routes.placeOrderScreen,
                                          arguments: {
                                            "orderArg": orderArgs,
                                            "scripInfo": ref.read(marketWatchProvider)
                                                .scripInfoModel!,
                                            "isBskt": ""
                                          });
                                    },
                                    child: Center(
                                        child: TextWidget.subText(
                                            text: "Exit",
                                            theme: false,
                                            fw: 1,
                                            color: const Color(0xffFFFFFF))),
                                  )))
                        ]
                      ]),
                    )));
      },
    );
  }
}
