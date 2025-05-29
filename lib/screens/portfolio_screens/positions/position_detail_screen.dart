import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/scrip_info_btns.dart';
import 'convert_position_dialogue.dart';

class PositionDetailScreen extends ConsumerWidget {
  final PositionBookModel positionList;
  const PositionDetailScreen({super.key, required this.positionList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(portfolioProvider);
    final theme = ref.read(themeProvider);
    
    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};
        
        // Update position data with real-time values if available
        if (socketDatas.containsKey(positionList.token)) {
          final lp = socketDatas["${positionList.token}"]['lp']?.toString();
          final pc = socketDatas["${positionList.token}"]['pc']?.toString();
          final chng = socketDatas["${positionList.token}"]['chng']?.toString();
          final close = socketDatas["${positionList.token}"]['c']?.toString(); // Get close price from socket data
          
          // Store previous values to detect changes
          final prevLtp = positionList.lp;
          
          if (lp != null && lp != "null") {
            positionList.lp = lp;
          }
          
          if (pc != null && pc != "null") {
            positionList.perChange = pc;
          }
          
          if (chng != null && chng != "null") {
            positionList.chng = chng;
          }
          
          // Calculate MTM/PNL values based on updated data
          if (positionList.lp != null && positionList.netqty != null) {
            final ltp = double.tryParse(positionList.lp ?? "0.0") ?? 0.0;
            final qty = int.tryParse(positionList.netqty ?? "0") ?? 0;
            final avgPrice = double.tryParse(positionList.avgPrc ?? "0.0") ?? 0.0;
            
            if (ltp > 0 && qty != 0 && avgPrice > 0) {
              final pnl = (ltp - avgPrice) * qty;
              positionList.profitNloss = pnl.toStringAsFixed(2);
              
              // Calculate MTM
              positionList.mTm = pnl.toStringAsFixed(2);
            }
            
            // Calculate change value if it's missing or invalid but we have close price from socket
            if ((positionList.chng == null || positionList.chng == "null" || positionList.chng == "0" || positionList.chng == "0.00") 
                && ltp > 0 && close != null && close != "null") {
              final closePrice = double.tryParse(close) ?? 0.0;
              if (closePrice > 0) {
                positionList.chng = (ltp - closePrice).toStringAsFixed(2);
              }
            }
            
            // If we still don't have valid change value but have perChange, try to calculate change
            if ((positionList.chng == null || positionList.chng == "null" || positionList.chng == "0" || positionList.chng == "0.00") 
                && ltp > 0 && positionList.perChange != null && positionList.perChange != "null") {
              final perChange = double.tryParse(positionList.perChange!) ?? 0.0;
              if (perChange != 0) {
                // Calculate implied close price and then change value
                final impliedClosePrice = ltp / (1 + (perChange / 100));
                positionList.chng = (ltp - impliedClosePrice).toStringAsFixed(2);
              }
            }
          }
        }
        
        // Make a final check to ensure change value is valid - calculate it from perChange and LTP if needed
        if ((positionList.chng == null || positionList.chng == "null" || positionList.chng == "0" || positionList.chng == "0.00") 
            && positionList.lp != null && positionList.perChange != null) {
          final ltp = double.tryParse(positionList.lp!) ?? 0.0;
          final perChange = double.tryParse(positionList.perChange!) ?? 0.0;
          
          if (ltp > 0 && perChange != 0) {
            // Calculate implied close price from percentage change
            final impliedClosePrice = ltp / (1 + (perChange / 100));
            positionList.chng = (ltp - impliedClosePrice).toStringAsFixed(2);
          }
        }
        
        // Make sure the formatting of the change display matches the text format
        final changeTextDisplay = positionList.chng ?? "0.00";
        try {
          // Ensure change value is properly formatted even if it's a string already
          positionList.chng = double.parse(changeTextDisplay).toStringAsFixed(2);
        } catch (e) {
          // If parsing fails, leave it as is but ensure it's not null
          positionList.chng = changeTextDisplay;
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
                                Text("${positionList.symbol}",
                                    style: textStyles.appBarTitleTxt.copyWith(
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack)),
                                Text(" ${positionList.option} ",
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyles.scripNameTxtStyle.copyWith(
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack)),
                              ],
                            ),
                            Text("₹${positionList.lp}",
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
                              Row(children: [
                                CustomExchBadge(exch: "${positionList.exch}"),
                                Text("  ${positionList.expDate}",
                                    style: textStyle(const Color(0xff000000), 12,
                                        FontWeight.w600))
                              ]),
                              Text(
                                  "${double.parse("${positionList.chng ?? 0.00} ").toStringAsFixed(2)} (${positionList.perChange ?? 0.00}%)",
                                  style: textStyle(
                                      (positionList.chng == "null" ||
                                                  positionList.chng == null) ||
                                              positionList.chng == "0.00"
                                          ? colors.ltpgrey
                                          : positionList.chng!.startsWith("-") ||
                                                  positionList.perChange!
                                                      .startsWith("-")
                                              ? colors.darkred
                                              : colors.ltpgreen,
                                      12,
                                      FontWeight.w500))
                            ])
                      ]),
                )),
            body: ListView(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: positionList.sPrdtAli == "BO" ||
                          positionList.sPrdtAli == "CO" ||
                          positionList.sPrdtAli == "MTF"
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: theme.isDarkMode
                                    ? const Color(0xff666666).withOpacity(.2)
                                    : const Color(0xff999999).withOpacity(.2)),
                            child: Text("${positionList.sPrdtAli}",
                                style: textStyle(
                                    const Color(0xff666666), 12, FontWeight.w600))),
                        if ((positionList.netqty != "0") &&
                            (positionList.sPrdtAli == "MIS" ||
                                positionList.sPrdtAli == "CNC" ||
                                positionList.sPrdtAli == "NRML")) ...[
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ConvertPositionDialogue(
                                            convertPosition: positionList);
                                      });
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: theme.isDarkMode
                                                ? colors.colorGrey
                                                : colors.colorBlack),
                                        borderRadius: BorderRadius.circular(32)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: Text("Convert",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            13,
                                            FontWeight.w600))),
                              ),
                            ],
                          )
                        ],
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(positions.isNetPnl ? "P&L" : "MTM",
                            style: textStyle(
                                const Color(0xff5E6B7D), 12, FontWeight.w500)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (positions.isNetPnl) ...[
                              Text(
                                  "₹${positionList.profitNloss ?? positionList.rpnl}",
                                  style: textStyle(
                                      positionList.profitNloss != null
                                          ? positionList.profitNloss!
                                                  .startsWith("-")
                                              ? colors.darkred
                                              : positionList.profitNloss == "0.00"
                                                  ? colors.ltpgrey
                                                  : colors.ltpgreen
                                          : positionList.rpnl!.startsWith("-")
                                              ? colors.darkred
                                              : positionList.rpnl == "0.00"
                                                  ? colors.ltpgrey
                                                  : colors.ltpgreen,
                                      15,
                                      FontWeight.w600))
                            ] else ...[
                              Text("₹${positionList.mTm}",
                                  style: textStyle(
                                      positionList.mTm!.startsWith("-")
                                          ? colors.darkred
                                          : positionList.mTm == "0.00"
                                              ? colors.ltpgrey
                                              : colors.ltpgreen,
                                      15,
                                      FontWeight.w600))
                            ]
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ScripInfoBtns(
                  exch: '${positionList.exch}',
                  token: '${positionList.token}',
                  insName: '',
                  tsym: '${positionList.tsym}'),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text("Position details",
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
                                  Text("Price",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text("${positionList.dayavgprc ?? 0.00}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                  Text("Day Buy Avg",
                                      style: textStyle(const Color(0xff666666), 12,
                                          FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${positionList.daybuyavgprc ?? 0.00}",
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
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                            const SizedBox(width: 27),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Net Qty",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                      "${((int.tryParse(positionList.netqty.toString()) ?? 0) / (positionList.exch == 'MCX' ? (int.tryParse(positionList.ls.toString()) ?? 1) : 1)).toInt()}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                  Text("Day Buy Qty",
                                      style: textStyle(const Color(0xff666666), 12,
                                          FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${((int.tryParse(positionList.daybuyqty.toString()) ?? 0) / (positionList.exch == 'MCX' ? (int.tryParse(positionList.ls.toString()) ?? 1) : 1)).toInt()}",
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
                                  Text("Day Sell Avg",
                                      style: textStyle(const Color(0xff666666), 12,
                                          FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${positionList.daysellavgprc ?? 0.00}",
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
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                            const SizedBox(width: 27),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Day Sell Qty",
                                      style: textStyle(const Color(0xff666666), 12,
                                          FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${((int.tryParse(positionList.daysellqty.toString()) ?? 0) / (positionList.exch == 'MCX' ? (int.tryParse(positionList.ls.toString()) ?? 1) : 1)).toInt()}",
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
                                  Text("CF Buy Avg",
                                      style: textStyle(const Color(0xff666666), 12,
                                          FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${positionList.cfbuyavgprc ?? 0.00}",
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
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                            const SizedBox(width: 27),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("CF Buy Qty",
                                      style: textStyle(const Color(0xff666666), 12,
                                          FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${((int.tryParse(positionList.cfbuyqty.toString()) ?? 0) / (positionList.exch == 'MCX' ? (int.tryParse(positionList.ls.toString()) ?? 1) : 1)).toInt()}",
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
                                  Text("CF Sell Avg",
                                      style: textStyle(const Color(0xff666666), 12,
                                          FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${positionList.cfsellavgprc ?? 0.00}",
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
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                            const SizedBox(width: 27),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("CF Sell Qty",
                                      style: textStyle(const Color(0xff666666), 12,
                                          FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${((int.tryParse(positionList.cfsellqty.toString()) ?? 0) / (positionList.exch == 'MCX' ? (int.tryParse(positionList.ls.toString()) ?? 1) : 1)).toInt()}",
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
                                          : colors.colorDivider),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Net Buy Value",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(
                          "${positionList.totbuyamt ?? 0.00}",
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
                                : colors.colorDivider),
                        const SizedBox(height: 4),
                        Text("Net Sell Value",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(
                          "${positionList.totsellamt ?? 0.00}",
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
                                : colors.colorDivider),
                        const SizedBox(height: 4),
                        Text("Net Value",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(
                          (double.parse("${positionList.totbuyamt ?? 0.00}") +
                                  double.parse(
                                      "${positionList.totsellamt ?? 0.00}"))
                              .toStringAsFixed(2),
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
                                : colors.colorDivider),
                        const SizedBox(height: 4),
                        Text("Act Avg Price",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(
                          (double.parse("${positionList.upldprc ?? 0.00}"))
                              .toStringAsFixed(2),
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500),
                        ),
                      ])),
              // ScripInfoBtns(exch: '${positionList.exch}', token: '${positionList.token}', insName: '')
            ]),
            bottomNavigationBar: positionList.sPrdtAli == "BO" ||
                    positionList.sPrdtAli == "CO"
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
                                      .fetchScripInfo("${positionList.token}",
                                          '${positionList.exch}', context, true);
                                  int lotsize = int.parse(ref.read(marketWatchProvider)
                                      .scripInfoModel!
                                      .ls
                                      .toString());
                                  Navigator.pop(context);
                                  OrderScreenArgs orderArgs = OrderScreenArgs(
                                      exchange: '${positionList.exch}',
                                      tSym: '${positionList.tsym}',
                                      isExit: false,
                                      token: "${positionList.token}",
                                      transType: int.parse(positionList.netqty!) < 0
                                          ? false
                                          : true,
                                      prd: '${positionList.prd}',
                                      // change: depthData.chng,
                                      // close: depthData.c,
                                      lotSize: lotsize.toString(),
                                      ltp: positionList.lp,
                                      perChange: positionList.perChange ?? "0.00",
                                      orderTpye: '',
                                      holdQty: '${positionList.netqty}',
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
                                    child: Text("Add More",
                                        style: textStyle(const Color(0xffFFFFFF),
                                            14, FontWeight.w600))),
                              )),
                        ),
                        if (positionList.qty != "0" && !positions.isDay) ...[
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
                                          .fetchScripInfo("${positionList.token}",
                                              '${positionList.exch}', context, true);
                                      Navigator.pop(context);
                                      OrderScreenArgs orderArgs = OrderScreenArgs(
                                          exchange: '${positionList.exch}',
                                          tSym: '${positionList.tsym}',
                                          isExit: true,
                                          token: "${positionList.token}",
                                          transType:
                                              int.parse(positionList.netqty!) < 0
                                                  ? true
                                                  : false,
                                          prd: '${positionList.prd}',
                                          // change: depthData.chng,
                                          // close: depthData.c,
                                          lotSize: positionList.netqty,
                                          ltp: positionList.lp,
                                          perChange:
                                              positionList.perChange ?? "0.00",
                                          orderTpye: '',
                                          holdQty: '${positionList.netqty}',
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
                                        child: Text("Exit",
                                            style: textStyle(
                                                const Color(0xffFFFFFF),
                                                14,
                                                FontWeight.w600))),
                                  )))
                        ]
                      ]),
                    )));
      },
    );
  }
}
