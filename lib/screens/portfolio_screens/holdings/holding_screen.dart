import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';

class HoldingScreen extends ConsumerWidget {
  const HoldingScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final holdingProvide = watch(portfolioProvider);
    final socketDatas = watch(websocketProvider);
    final theme = context.read(themeProvider);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? const Color(0xffB5C0CF).withOpacity(.15)
                  : const Color(0xffF1F3F8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Invested",
                          style: textStyle(
                              const Color(0xff5E6B7D), 12, FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text(
                          "₹${getFormatter(value: double.parse(holdingProvide.totInvesHold), v4d: false, noDecimal: false)}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Total P&L",
                          style: textStyle(
                              const Color(0xff5E6B7D), 12, FontWeight.w500)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              "₹${getFormatter(value: holdingProvide.totalPnlHolding, v4d: false, noDecimal: false)} ",
                              style: textStyle(
                                  holdingProvide.totalPnlHolding
                                          .toString()
                                          .startsWith("-")
                                      ? colors.darkred
                                      : colors.ltpgreen,
                                  16,
                                  FontWeight.w500)),
                          Text(
                              "(${holdingProvide.totPnlPercHolding == "NaN" ? 0.00 : holdingProvide.totPnlPercHolding}%)",
                              style: textStyle(
                                  holdingProvide.totPnlPercHolding
                                          .startsWith("-")
                                      ? colors.darkred
                                      : colors.ltpgreen,
                                  14,
                                  FontWeight.w500)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Current Value",
                          style: textStyle(
                              const Color(0xff5E6B7D), 12, FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text(
                          "₹${getFormatter(value: holdingProvide.totalCurrentVal, v4d: false, noDecimal: false)}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                    ],
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text("1D Change",
                        style: textStyle(
                            const Color(0xff5E6B7D), 12, FontWeight.w500)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                            "₹${getFormatter(value: holdingProvide.oneDayChng, v4d: false, noDecimal: false)}",
                            style: textStyle(
                                holdingProvide.oneDayChng
                                        .toStringAsFixed(2)
                                        .startsWith("-")
                                    ? colors.darkred
                                    : colors.ltpgreen,
                                16,
                                FontWeight.w500)),
                        Text(
                            " (${holdingProvide.oneDayChngPer.toStringAsFixed(2)}%)",
                            style: textStyle(
                                holdingProvide.oneDayChngPer
                                        .toStringAsFixed(2)
                                        .startsWith("-")
                                    ? colors.darkred
                                    : colors.ltpgreen,
                                14,
                                FontWeight.w500))
                      ],
                    ),
                  ])
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListView.separated(
                primary: true,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: holdingProvide.holdingsModel!.length,
                itemBuilder: (BuildContext context, int index) {
                  return StreamBuilder(
                    stream: socketDatas.touchAcknowledgementStream.stream.where(
                        (event) =>
                            event.tk ==
                            holdingProvide
                                .holdingsModel![index].exchTsym![0].token),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData || snapshot.data != null) {
                        if (snapshot.data!.lp != null) {
                          holdingProvide.holdingsModel![index].exchTsym![0].lp =
                              snapshot.data!.lp;
                          holdingProvide
                              .holdingsModel![index].currentValue = (int.parse(
                                      "${holdingProvide.holdingsModel![index].currentQty ?? 0}") *
                                  double.parse(
                                      "${holdingProvide.holdingsModel![index].exchTsym![0].lp ?? 0.0}"))
                              .toStringAsFixed(2);
                        }
                        if (snapshot.data!.pc != null) {
                          holdingProvide.holdingsModel![index].exchTsym![0]
                              .perChange = snapshot.data!.pc;
                        }
                        if (snapshot.data!.c != null) {
                          holdingProvide.holdingsModel![index].exchTsym![0]
                              .close = snapshot.data!.c;
                        }
                        holdingProvide.holdingsModel![index].exchTsym![0]
                            .oneDayChg = ((double.parse(holdingProvide
                                            .holdingsModel![index]
                                            .exchTsym![0]
                                            .lp ??
                                        "0.00") -
                                    (double.parse(holdingProvide
                                            .holdingsModel![index]
                                            .exchTsym![0]
                                            .close ??
                                        "0.00"))) *
                                int.parse(
                                    "${holdingProvide.holdingsModel![index].currentQty ?? 0}"))
                            .toStringAsFixed(2);

                        if (holdingProvide.holdingsModel![index].currentQty ==
                            0) {
                          double sellAmt = double.parse(
                              holdingProvide.holdingsModel![index].sellAmt ??
                                  "0.00");

                          int usedQty = int.parse(
                              holdingProvide.holdingsModel![index].usedqty ??
                                  "0");
                          double price = (sellAmt / usedQty);

                          double pnl = price -
                              double.parse(holdingProvide
                                      .holdingsModel![index].upldprc ??
                                  "0.0");

                          holdingProvide.holdingsModel![index].exchTsym![0]
                              .profitNloss = (pnl * usedQty).toStringAsFixed(2);
                        } else {
                          holdingProvide.holdingsModel![index].exchTsym![0]
                              .profitNloss = (double.parse(holdingProvide
                                          .holdingsModel![index].currentValue ??
                                      "0.00") -
                                  double.parse(holdingProvide
                                          .holdingsModel![index].invested ??
                                      "0.00"))
                              .toStringAsFixed(2);
                        }
                        holdingProvide.pnlHoldCal();
                        return StreamBuilder(
                            stream: socketDatas.mwStream.stream.where((event) =>
                                event.tk ==
                                holdingProvide
                                    .holdingsModel![index].exchTsym![0].token),
                            builder: (context, update) {
                              if (update.hasData || update.data != null) {
                                if (update.data!.lp != null) {
                                  holdingProvide.holdingsModel![index]
                                      .exchTsym![0].lp = update.data!.lp;

                                  holdingProvide.holdingsModel![index]
                                      .currentValue = (int.parse(
                                              "${holdingProvide.holdingsModel![index].currentQty ?? 0}") *
                                          double.parse(
                                              "${holdingProvide.holdingsModel![index].exchTsym![0].lp ?? 0.0}"))
                                      .toStringAsFixed(2);
                                }
                                if (update.data!.lp != null) {
                                  holdingProvide.holdingsModel![index]
                                      .exchTsym![0].perChange = update.data!.pc;
                                }
                                if (update.data!.c != null) {
                                  holdingProvide.holdingsModel![index]
                                      .exchTsym![0].close = update.data!.c;
                                }

                                holdingProvide
                                    .holdingsModel![index]
                                    .exchTsym![0]
                                    .oneDayChg = ((double.parse(holdingProvide
                                                    .holdingsModel![index]
                                                    .exchTsym![0]
                                                    .lp ??
                                                "0.00") -
                                            (double.parse(holdingProvide
                                                    .holdingsModel![index]
                                                    .exchTsym![0]
                                                    .close ??
                                                "0.00"))) *
                                        int.parse(
                                            "${holdingProvide.holdingsModel![index].currentQty ?? 0}"))
                                    .toStringAsFixed(2);

                                if (holdingProvide
                                        .holdingsModel![index].currentQty ==
                                    0) {
                                  double sellAmt = double.parse(holdingProvide
                                          .holdingsModel![index].sellAmt ??
                                      "0.00");

                                  int usedQty = int.parse(holdingProvide
                                          .holdingsModel![index].usedqty ??
                                      "0");
                                  double price = (sellAmt / usedQty);

                                  double pnl = price -
                                      double.parse(holdingProvide
                                              .holdingsModel![index].upldprc ??
                                          "0.0");

                                  holdingProvide.holdingsModel![index]
                                          .exchTsym![0].profitNloss =
                                      (pnl * usedQty).toStringAsFixed(2);
                                } else {
                                  holdingProvide.holdingsModel![index]
                                      .exchTsym![0].profitNloss = (double.parse(
                                              holdingProvide
                                                      .holdingsModel![index]
                                                      .currentValue ??
                                                  "0.00") -
                                          double.parse(holdingProvide
                                                  .holdingsModel![index]
                                                  .invested ??
                                              "0.00"))
                                      .toStringAsFixed(2);
                                }
                                holdingProvide.pnlHoldCal();
                              }
                              return InkWell(
                                  onLongPress: () {
                                    Navigator.pushNamed(
                                        context, Routes.holdingExit);
                                  },
                                  onTap: () async {
                                    await watch(marketWatchProvider).fetchLinkeScrip(
                                        "${holdingProvide.holdingsModel![index].exchTsym![0].token}",
                                        "${holdingProvide.holdingsModel![index].exchTsym![0].exch}",
                                        context);
                                    if (watch(marketWatchProvider)
                                            .linkedScrips!
                                            .stat ==
                                        "Ok") {
                                      await watch(marketWatchProvider).fetchScripQuote(
                                          "${holdingProvide.holdingsModel![index].exchTsym![0].token}",
                                          "${holdingProvide.holdingsModel![index].exchTsym![0].exch}",
                                          context);

                                      if ((holdingProvide.holdingsModel![index]
                                                  .exchTsym![0].exch ==
                                              "NSE" ||
                                          holdingProvide.holdingsModel![index]
                                                  .exchTsym![0].exch ==
                                              "BSE")) {
                                        context
                                            .read(marketWatchProvider)
                                            .depthBtns
                                            .add({
                                          "btnName": "Fundamental",
                                          "imgPath": assets.dInfo,
                                          "case":
                                              "Click here to view fundamental data."
                                        });

                                        await context
                                            .read(marketWatchProvider)
                                            .fetchTechData(
                                                context: context,
                                                exch:
                                                    "${holdingProvide.holdingsModel![index].exchTsym![0].exch}",
                                                tradeSym:
                                                    "${holdingProvide.holdingsModel![index].exchTsym![0].tsym}",
                                                lastPrc:
                                                    "${holdingProvide.holdingsModel![index].exchTsym![0].lp}");
                                      }
                                    }
                                    Navigator.pushNamed(
                                        context, Routes.holdingDetail,
                                        arguments: {
                                          "holdingData": holdingProvide
                                              .holdingsModel![index],
                                          "exchTsym": holdingProvide
                                              .holdingsModel![index]
                                              .exchTsym![0]
                                        });
                                    // showModalBottomSheet(
                                    //     showDragHandle: true,
                                    //     isScrollControlled: true,
                                    //     shape: const RoundedRectangleBorder(
                                    //         borderRadius: BorderRadius.vertical(
                                    //             top: Radius.circular(16))),
                                    //     backgroundColor: const Color(0xffffffff),
                                    //     context: context,
                                    //     builder: (context) => HoldingBottomSheet(
                                    //         holdingData:
                                    //             holdingProvide.holdingsModel![index],
                                    //         exchTsym: holdingProvide
                                    //             .holdingsModel![index].exchTsym![0]));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                "${holdingProvide.holdingsModel![index].exchTsym![0].tsym} ",
                                                overflow: TextOverflow.ellipsis,
                                                style: textStyles
                                                    .scripNameTxtStyle
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors
                                                                .colorBlack)),
                                            Row(
                                              children: [
                                                Text(" LTP: ",
                                                    style: textStyle(
                                                        const Color(0xff5E6B7D),
                                                        13,
                                                        FontWeight.w600)),
                                                Text(
                                                    "₹${holdingProvide.holdingsModel![index].exchTsym![0].lp}",
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        14,
                                                        FontWeight.w500)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomExchBadge(
                                                exch:
                                                    "${holdingProvide.holdingsModel![index].exchTsym![0].exch}"),
                                            Text(
                                                " (${holdingProvide.holdingsModel![index].exchTsym![0].perChange}%)",
                                                style: textStyle(
                                                    holdingProvide
                                                            .holdingsModel![
                                                                index]
                                                            .exchTsym![0]
                                                            .perChange!
                                                            .startsWith("-")
                                                        ? colors.darkred
                                                        : holdingProvide
                                                                    .holdingsModel![
                                                                        index]
                                                                    .exchTsym![
                                                                        0]
                                                                    .perChange ==
                                                                "0.00"
                                                            ? colors.ltpgrey
                                                            : colors.ltpgreen,
                                                    12,
                                                    FontWeight.w500)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Divider(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : colors.colorDivider),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text("Qty: ",
                                                    style: textStyle(
                                                        const Color(0xff5E6B7D),
                                                        14,
                                                        FontWeight.w500)),
                                                Text(
                                                    "${holdingProvide.holdingsModel![index].currentQty ?? 0} @ ₹${holdingProvide.holdingsModel![index].upldprc ?? holdingProvide.holdingsModel![index].exchTsym![0].close ?? 0.00}",
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        14,
                                                        FontWeight.w500)),
                                                if (holdingProvide
                                                        .holdingsModel![index]
                                                        .npoadqty
                                                        .toString() !=
                                                    "null") ...[
                                                  Text(" NPQ",
                                                      style: textStyle(
                                                          const Color(
                                                              0xff666666),
                                                          12,
                                                          FontWeight.w500)),
                                                ],
                                                if (holdingProvide
                                                        .holdingsModel![index]
                                                        .btstqty !=
                                                    "0")
                                                  Text(
                                                      " T1: ${holdingProvide.holdingsModel![index].btstqty}",
                                                      style: textStyle(
                                                          const Color(
                                                              0xff666666),
                                                          12,
                                                          FontWeight.w500))
                                              ],
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                    "₹${holdingProvide.holdingsModel![index].exchTsym![0].profitNloss}",
                                                    style: textStyle(
                                                        holdingProvide
                                                                .holdingsModel![
                                                                    index]
                                                                .exchTsym![0]
                                                                .profitNloss!
                                                                .startsWith("-")
                                                            ? colors.darkred
                                                            : colors.ltpgreen,
                                                        14,
                                                        FontWeight.w500)),
                                                Text(
                                                    " (${holdingProvide.holdingsModel![index].exchTsym![0].pNlChng == "NaN" ? 0.0 : holdingProvide.holdingsModel![index].exchTsym![0].pNlChng}%)",
                                                    style: textStyle(
                                                        holdingProvide
                                                                .holdingsModel![
                                                                    index]
                                                                .exchTsym![0]
                                                                .pNlChng!
                                                                .startsWith("-")
                                                            ? colors.darkred
                                                            : holdingProvide
                                                                        .holdingsModel![
                                                                            index]
                                                                        .exchTsym![
                                                                            0]
                                                                        .pNlChng ==
                                                                    "NaN"
                                                                ? colors.darkred
                                                                : colors
                                                                    .ltpgreen,
                                                        12,
                                                        FontWeight.w500)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text("Inv: ",
                                                    style: textStyle(
                                                        const Color(0xff5E6B7D),
                                                        14,
                                                        FontWeight.w500)),
                                                Text(
                                                    "₹${getFormatter(value: double.parse("${holdingProvide.holdingsModel![index].invested == "0.00" ? holdingProvide.holdingsModel![index].exchTsym![0].close ?? 0.00 : holdingProvide.holdingsModel![index].invested ?? 0.00}"), v4d: false, noDecimal: false)}",
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        14,
                                                        FontWeight.w500)),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text("Cur: ",
                                                    style: textStyle(
                                                        const Color(0xff5E6B7D),
                                                        14,
                                                        FontWeight.w500)),
                                                Text(
                                                    "₹${getFormatter(value: double.parse("${holdingProvide.holdingsModel![index].currentValue ?? 0.00}"), v4d: false, noDecimal: false)}",
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        14,
                                                        FontWeight.w500)),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ));
                            });
                      } else {
                        return Container();
                      }
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
