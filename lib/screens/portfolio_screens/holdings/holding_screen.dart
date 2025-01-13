import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/functions.dart';
import 'filter_scrip_bottom_sheet.dart';

import 'holdings_list.dart';

class HoldingScreen extends ConsumerWidget {
  const HoldingScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final holdingProvide = watch(portfolioProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    final theme = context.read(themeProvider);
    return holdingProvide.holdloader
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                    style: textStyle(const Color(0xff5E6B7D),
                                        12, FontWeight.w500)),
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
                                    style: textStyle(const Color(0xff5E6B7D),
                                        12, FontWeight.w500)),
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
                                      style: textStyle(const Color(0xff5E6B7D),
                                          12, FontWeight.w500)),
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
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("1D Change",
                                        style: textStyle(
                                            const Color(0xff5E6B7D),
                                            12,
                                            FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Row(children: [
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
                                          " (${holdingProvide.oneDayChngPer.isNaN ? "0.00" : holdingProvide.oneDayChngPer.toStringAsFixed(2)}%)",
                                          style: textStyle(
                                              holdingProvide.oneDayChngPer
                                                      .toStringAsFixed(2)
                                                      .startsWith("-")
                                                  ? colors.darkred
                                                  : colors.ltpgreen,
                                              14,
                                              FontWeight.w500))
                                    ])
                                  ])
                            ])
                      ])),
              if (holdingProvide.holdingsModel!.isNotEmpty)
                Container(
                    decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        border: Border(
                            bottom: BorderSide(
                                color: theme.isDarkMode
                                    ? const Color(0xffB5C0CF).withOpacity(.15)
                                    : const Color(0xffF1F3F8),
                                width: 6))),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 2, top: 8, bottom: 8),
                        child: Row(
                            mainAxisAlignment: holdingProvide.showEdis
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.end,
                            children: [
                              if (holdingProvide.showEdis)
                                SizedBox(
                                    height: 27,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: colors.colorGrey),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(32)))),
                                        onPressed: () async {
                                          await context
                                              .read(fundProvider)
                                              .fetchHstoken(context);
                                          await context
                                              .read(fundProvider)
                                              .eDis(context);
                                        },
                                        child: Text("E-DIS",
                                            style: textStyle(
                                                !theme.isDarkMode
                                                    ? colors.colorBlack
                                                    : colors.colorWhite,
                                                12,
                                                FontWeight.w600)))),
                              if (holdingProvide.holdingsModel!.length > 1)
                                Row(children: [
                                  if (!holdingProvide.showSearchHold)
                                    InkWell(
                                        onTap: () async {
                                          FocusScope.of(context).unfocus();
                                          showModalBottomSheet(
                                              useSafeArea: true,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      16))),
                                              context: context,
                                              builder: (context) {
                                                return const HoldingsScripFilterBottomSheet();
                                              });
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 12),
                                          child: SvgPicture.asset(
                                              assets.filterLines,
                                              color: theme.isDarkMode
                                                  ? const Color(0xffBDBDBD)
                                                  : colors.colorGrey),
                                        )),
                                  InkWell(
                                      onTap: () {
                                        holdingProvide.showHoldSearch(true);
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12, left: 10),
                                          child: SvgPicture.asset(
                                              assets.searchIcon,
                                              width: 19,
                                              color: theme.isDarkMode
                                                  ? const Color(0xffBDBDBD)
                                                  : colors.colorGrey)))
                                ])
                            ]))),
              if (holdingProvide.showSearchHold)
                Container(
                    height: 62,
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                width: 6))),
                    child: Row(children: [
                      Expanded(
                          child: TextFormField(
                              controller: holdingProvide.holdingSearchCtrl,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  16,
                                  FontWeight.w600),
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                RemoveEmojiInputFormatter(),
                                FilteringTextInputFormatter.deny(
                                    RegExp('[π£•₹€℅™∆√¶/.,]'))
                              ],
                              decoration: InputDecoration(
                                  fillColor: theme.isDarkMode
                                      ? colors.darkGrey
                                      : const Color(0xffF1F3F8),
                                  filled: true,
                                  hintStyle: GoogleFonts.inter(
                                      textStyle: textStyle(
                                          const Color(0xff69758F),
                                          15,
                                          FontWeight.w500)),
                                  prefixIconColor: const Color(0xff586279),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: SvgPicture.asset(assets.searchIcon,
                                        color: const Color(0xff586279),
                                        fit: BoxFit.contain,
                                        width: 20),
                                  ),
                                  suffixIcon: InkWell(
                                    onTap: () async {
                                      holdingProvide.clearHoldSearch();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: SvgPicture.asset(assets.removeIcon,
                                          fit: BoxFit.scaleDown, width: 20),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20)),
                                  disabledBorder: InputBorder.none,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20)),
                                  hintText: "Search Scrip Name",
                                  contentPadding:
                                      const EdgeInsets.only(top: 20),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20))),
                              onChanged: (value) async {
                                holdingProvide.holdingSearch(value, context);
                              })),
                      TextButton(
                          onPressed: () {
                            holdingProvide.clearHoldSearch();
                            holdingProvide.showHoldSearch(false);
                          },
                          child: Text("Close",
                              style: textStyles.textBtn.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue)))
                    ])),
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: () async {
                        await holdingProvide.fetchHoldings(context, "Refresh");
                      },
                      child: holdingProvide.holdingSearchItem!.isEmpty
                          ? holdingProvide.holdingsModel!.isNotEmpty
                              ? ListView.separated(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                        onLongPress: () {
                                          Navigator.pushNamed(
                                              context, Routes.holdingExit);
                                        },
                                        onTap: () async {
                                          await watch(marketWatchProvider)
                                              .fetchLinkeScrip(
                                                  "${holdingProvide.holdingsModel![index].exchTsym![0].token}",
                                                  "${holdingProvide.holdingsModel![index].exchTsym![0].exch}",
                                                  context);
                                          if (watch(marketWatchProvider)
                                                  .linkedScrips!
                                                  .stat ==
                                              "Ok") {
                                            await watch(marketWatchProvider)
                                                .fetchScripQuote(
                                                    "${holdingProvide.holdingsModel![index].exchTsym![0].token}",
                                                    "${holdingProvide.holdingsModel![index].exchTsym![0].exch}",
                                                    context);

                                            if ((holdingProvide
                                                        .holdingsModel![index]
                                                        .exchTsym![0]
                                                        .exch ==
                                                    "NSE" ||
                                                holdingProvide
                                                        .holdingsModel![index]
                                                        .exchTsym![0]
                                                        .exch ==
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
                                        },
                                        child: HoldingsList(
                                            holdingData: holdingProvide
                                                .holdingsModel![index],
                                            exchTsym: holdingProvide
                                                .holdingsModel![index]
                                                .exchTsym![0]));
                                  },
                                  itemCount:
                                      holdingProvide.holdingsModel!.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        height: 6);
                                  })
                              : const Center(
                                  child: SizedBox(
                                    height: 400,
                                    child: NoDataFound(),
                                  ),
                                )
                          : holdingProvide.holdingSearchItem!.isNotEmpty
                              ? ListView.separated(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (socketDatas.containsKey(holdingProvide
                                        .holdingSearchItem![index]
                                        .exchTsym![0]
                                        .token)) {
                                          print('hold if');
                                      var exchTsym = holdingProvide
                                          .holdingSearchItem![index]
                                          .exchTsym![0];
                                      var currentItem = holdingProvide
                                          .holdingSearchItem![index];

                                      exchTsym.lp =
                                          "${socketDatas[exchTsym.token]['lp'] ?? 0.00}";
                                      exchTsym.perChange =
                                          "${socketDatas[exchTsym.token]['pc'] ?? 0.00}";
                                      exchTsym.close =
                                          "${socketDatas[exchTsym.token]['c'] ?? 0.00}";

                                      currentItem.currentValue = (int.parse(
                                                  "${currentItem.currentQty ?? 0}") *
                                              double.parse(
                                                  "${exchTsym.lp ?? 0.0}"))
                                          .toStringAsFixed(2);

                                      double avgCost = double.parse(
                                          "${currentItem.upldprc == "0.00" ? exchTsym.close ?? 0.0 : currentItem.upldprc ?? 0.00}");
                                      currentItem.invested =
                                          (currentItem.currentQty! * avgCost)
                                              .toStringAsFixed(2);

                                      exchTsym.pNlChng = currentItem.invested ==
                                              "0.00"
                                          ? "0.00"
                                          : ((double.parse(
                                                          "${exchTsym.profitNloss ?? 0.0}") /
                                                      double.parse(
                                                          "${currentItem.invested ?? 0.0}")) *
                                                  100)
                                              .toStringAsFixed(2);

                                      exchTsym.oneDayChg = ((double.parse(
                                                      exchTsym.lp ?? "0.00") -
                                                  double.parse(exchTsym.close ??
                                                      "0.00")) *
                                              int.parse(
                                                  "${currentItem.currentQty ?? 0}"))
                                          .toStringAsFixed(2);

                                      if (currentItem.currentQty == 0) {
                                        double sellAmt = double.parse(
                                            currentItem.sellAmt ?? "0.00");
                                        int usedQty = int.parse(
                                            currentItem.usedqty ?? "0");
                                        double price = (sellAmt / usedQty);
                                        double pnl = price -
                                            double.parse(
                                                currentItem.upldprc ?? "0.0");

                                        exchTsym.profitNloss =
                                            (pnl * usedQty).toStringAsFixed(2);
                                      } else {
                                        exchTsym.profitNloss = (double.parse(
                                                    currentItem.currentValue ??
                                                        "0.00") -
                                                double.parse(
                                                    currentItem.invested ??
                                                        "0.00"))
                                            .toStringAsFixed(2);
                                      }
                                    }

                                    return InkWell(
                                        onLongPress: () {
                                          Navigator.pushNamed(
                                              context, Routes.holdingExit);
                                        },
                                        onTap: () async {
                                          await watch(marketWatchProvider)
                                              .fetchLinkeScrip(
                                                  "${holdingProvide.holdingSearchItem![index].exchTsym![0].token}",
                                                  "${holdingProvide.holdingSearchItem![index].exchTsym![0].exch}",
                                                  context);
                                          if (watch(marketWatchProvider)
                                                  .linkedScrips!
                                                  .stat ==
                                              "Ok") {
                                            await watch(marketWatchProvider)
                                                .fetchScripQuote(
                                                    "${holdingProvide.holdingSearchItem![index].exchTsym![0].token}",
                                                    "${holdingProvide.holdingSearchItem![index].exchTsym![0].exch}",
                                                    context);

                                            if ((holdingProvide
                                                        .holdingSearchItem![
                                                            index]
                                                        .exchTsym![0]
                                                        .exch ==
                                                    "NSE" ||
                                                holdingProvide
                                                        .holdingSearchItem![
                                                            index]
                                                        .exchTsym![0]
                                                        .exch ==
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
                                                          "${holdingProvide.holdingSearchItem![index].exchTsym![0].exch}",
                                                      tradeSym:
                                                          "${holdingProvide.holdingSearchItem![index].exchTsym![0].tsym}",
                                                      lastPrc:
                                                          "${holdingProvide.holdingSearchItem![index].exchTsym![0].lp}");
                                            }
                                          }
                                          Navigator.pushNamed(
                                              context, Routes.holdingDetail,
                                              arguments: {
                                                "holdingData": holdingProvide
                                                    .holdingSearchItem![index],
                                                "exchTsym": holdingProvide
                                                    .holdingSearchItem![index]
                                                    .exchTsym![0]
                                              });
                                        },
                                        child: HoldingsList(
                                            holdingData: holdingProvide
                                                .holdingSearchItem![index],
                                            exchTsym: holdingProvide
                                                .holdingSearchItem![index]
                                                .exchTsym![0]));
                                  },
                                  itemCount:
                                      holdingProvide.holdingSearchItem!.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        height: 6);
                                  })
                              : Container()))
            ]));
  }
}
