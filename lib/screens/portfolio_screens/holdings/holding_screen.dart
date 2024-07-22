import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/no_data_found.dart';
// import '../../holding_list.dart';
// import '../../holding_list.dart';
import 'filter_scrip_bottom_sheet.dart';

class HoldingScreen extends ConsumerWidget {
  const HoldingScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final holdingProvide = watch(portfolioProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    final theme = context.read(themeProvider);
    return holdingProvide.loading
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: RefreshIndicator(
                onRefresh: () async {
                  await holdingProvide.fetchHoldings(context, "Refresh");
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                            const Color(0xff5E6B7D),
                                            12,
                                            FontWeight.w500)),
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
                                            const Color(0xff5E6B7D),
                                            12,
                                            FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            "₹${getFormatter(value: holdingProvide.totalPnlHolding, v4d: false, noDecimal: false)} ",
                                            style: textStyle(
                                              holdingProvide
                                                        .totalPnlHolding
                                                        .toString()
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                16,
                                                FontWeight.w500)),
                                        Text(
                                            "(${holdingProvide.totPnlPercHolding == "NaN" ? 0.00 : holdingProvide.totPnlPercHolding}%)",
                                            style: textStyle(
                                              holdingProvide
                                                        .totPnlPercHolding
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
                                            const Color(0xff5E6B7D),
                                            12,
                                            FontWeight.w500)),
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
                                      Row(
                                        children: [
                                          Text(
                                              "₹${getFormatter(value: holdingProvide.oneDayChng, v4d: false, noDecimal: false)}",
                                              style: textStyle(
                                                holdingProvide
                                                          .oneDayChng
                                                          .toStringAsFixed(2)
                                                          .startsWith("-")
                                                      ? colors.darkred
                                                      : colors.ltpgreen,
                                                  16,
                                                  FontWeight.w500)),
                                          Text(
                                              " (${holdingProvide.oneDayChngPer.toStringAsFixed(2)}%)",
                                              style: textStyle(
                                                  holdingProvide
                                                          .oneDayChngPer
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
                      holdingProvide.holdingsModel!.isNotEmpty &&
                              holdingProvide.holdingsModel![0].stat != "Not_Ok"
                          ? Container(
                              decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  border: Border(
                                      bottom: BorderSide(
                                          color: theme.isDarkMode
                                              ? const Color(0xffB5C0CF)
                                                  .withOpacity(.15)
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
                                                      color: theme.isDarkMode
                                                          ? colors.colorGrey
                                                          : colors.colorWhite,
                                                    ),
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    32)))),
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
                                      if (holdingProvide.holdingsModel!.length >
                                          1)
                                        Row(
                                          children: [
                                            InkWell(
                                                onTap: () async {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  showModalBottomSheet(
                                                      useSafeArea: true,
                                                      isScrollControlled: true,
                                                      shape: const RoundedRectangleBorder(
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
                                                      const EdgeInsets.only(
                                                          right: 12),
                                                  child: SvgPicture.asset(
                                                      assets.filterLines,
                                                      color: theme.isDarkMode
                                      ?Color(0xffBDBDBD)
                                      :colors.colorGrey),
                                                )),
                                            InkWell(
                                              onTap: () {
                                                holdingProvide
                                                    .showHoldSearch(true);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 12, left: 10),
                                                child: SvgPicture.asset(
                                                    assets.searchIcon,
                                                    width: 19,
                                                    color: theme.isDarkMode
                                      ?Color(0xffBDBDBD)
                                      :colors.colorGrey),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  )),
                            )
                          : Container(),
                      if (holdingProvide.showSearchHold)
                        Container(
                          height: 62,
                          padding: const EdgeInsets.only(
                              left: 16, top: 8, bottom: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.darkGrey
                                          : const Color(0xffF1F3F8),
                                      width: 6))),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: holdingProvide.holdingSearchCtrl,
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      16,
                                      FontWeight.w600),
                                  inputFormatters: [UpperCaseTextFormatter()],
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
                                        child: SvgPicture.asset(
                                            assets.searchIcon,
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
                                          child: SvgPicture.asset(
                                              assets.removeIcon,
                                              fit: BoxFit.scaleDown,
                                              width: 20),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      disabledBorder: InputBorder.none,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      hintText: "Search Scrip Name",
                                      contentPadding:
                                          const EdgeInsets.only(top: 20),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                  onChanged: (value) async {
                                    holdingProvide.holdingSearch(
                                        value, context);
                                  },
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    holdingProvide.showHoldSearch(false);
                                  },
                                  child: Text("Close",
                                      style: textStyles.textBtn.copyWith(
                                          color: theme.isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue)))
                            ],
                          ),
                        ),
                      holdingProvide.holdingSearchItem!.isEmpty
                          ? Expanded(
                              child: holdingProvide.holdingsModel!.isNotEmpty
                                  ? holdingProvide.holdingsModel![0].stat !=
                                          "Not_Ok"
                                      ? SingleChildScrollView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (socketDatas.containsKey(
                                                  holdingProvide
                                                      .holdingsModel![index]
                                                      .exchTsym![0]
                                                      .token)) {
                                                holdingProvide
                                                        .holdingsModel![index]
                                                        .exchTsym![0]
                                                        .lp =
                                                    "${socketDatas["${holdingProvide.holdingsModel![index].exchTsym![0].token}"]['lp'] ?? 0.00}";

                                                holdingProvide
                                                        .holdingsModel![index]
                                                        .exchTsym![0]
                                                        .perChange =
                                                    "${socketDatas["${holdingProvide.holdingsModel![index].exchTsym![0].token}"]['pc'] ?? 0.00}";

                                                holdingProvide
                                                        .holdingsModel![index]
                                                        .exchTsym![0]
                                                        .close =
                                                    "${socketDatas["${holdingProvide.holdingsModel![index].exchTsym![0].token}"]['c'] ?? 0.00}";

                                                holdingProvide
                                                    .holdingsModel![index]
                                                    .exchTsym![0]
                                                    .profitNloss = ((double.parse(
                                                                holdingProvide
                                                                        .holdingsModel![
                                                                            index]
                                                                        .exchTsym![
                                                                            0]
                                                                        .lp ??
                                                                    "0.00") -
                                                            double.parse(holdingProvide
                                                                    .holdingsModel![
                                                                        index]
                                                                    .avgPrc ??
                                                                "0.00")) *
                                                        int.parse(
                                                            "${holdingProvide.holdingsModel![index].currentQty ?? 0}"))
                                                    .toStringAsFixed(2)
                                                    .toString();

                                                holdingProvide
                                                    .holdingsModel![index]
                                                    .exchTsym![0]
                                                    .pNlChng = holdingProvide
                                                            .holdingsModel![
                                                                index]
                                                            .invested ==
                                                        "0.00"
                                                    ? "0.00"
                                                    : ((double.parse(
                                                                    "${holdingProvide.holdingsModel![index].exchTsym![0].profitNloss}") /
                                                                double.parse(
                                                                    "${holdingProvide.holdingsModel![index].invested ?? 0.00}")) *
                                                            100)
                                                        .toStringAsFixed(2)
                                                        .toString();

                                                holdingProvide
                                                    .holdingsModel![index]
                                                    .exchTsym![0]
                                                    .oneDayChg = ((double.parse(
                                                                holdingProvide
                                                                        .holdingsModel![
                                                                            index]
                                                                        .exchTsym![
                                                                            0]
                                                                        .lp ??
                                                                    "0.00") -
                                                            (double.parse(holdingProvide
                                                                    .holdingsModel![
                                                                        index]
                                                                    .exchTsym![
                                                                        0]
                                                                    .close ??
                                                                "0.00"))) *
                                                        int.parse(
                                                            "${holdingProvide.holdingsModel![index].currentQty ?? 0}"))
                                                    .toStringAsFixed(2);

                                                holdingProvide
                                                    .holdingsModel![index]
                                                    .currentValue = (int.parse(
                                                            "${holdingProvide.holdingsModel![index].currentQty ?? 0}") *
                                                        double.parse(
                                                            "${holdingProvide.holdingsModel![index].exchTsym![0].lp ?? 0.0}"))
                                                    .toStringAsFixed(2);

                                                // WidgetsBinding.instance
                                                //     .addPostFrameCallback((_) {
                                                holdingProvide.pnlHoldCal();
                                                // });
                                              }
                                              return

                                                  //  HoldingsListCard(data: holdingProvide
                                                  //           .holdingsModel![index],);

                                                  InkWell(
                                                      onLongPress: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            Routes.holdingExit);
                                                      },
                                                      onTap: () async {
                                                        await context
                                                            .read(
                                                                marketWatchProvider)
                                                            .fetchLinkeScrip(
                                                                "${holdingProvide.holdingsModel![index].exchTsym![0].token}",
                                                                "${holdingProvide.holdingsModel![index].exchTsym![0].exch}",context);

                                                        await watch(
                                                                marketWatchProvider)
                                                            .fetchScripQuote(
                                                                "${holdingProvide.holdingsModel![index].exchTsym![0].token}",
                                                                "${holdingProvide.holdingsModel![index].exchTsym![0].exch}",
                                                                context);

                                                        if ((holdingProvide
                                                                    .holdingsModel![
                                                                        index]
                                                                    .exchTsym![
                                                                        0]
                                                                    .exch ==
                                                                "NSE" ||
                                                            holdingProvide
                                                                    .holdingsModel![
                                                                        index]
                                                                    .exchTsym![
                                                                        0]
                                                                    .exch ==
                                                                "BSE")) {
                                                          context
                                                              .read(
                                                                  marketWatchProvider)
                                                              .depthBtns
                                                              .add({
                                                            "btnName":
                                                                "Fundamental",
                                                            "imgPath":
                                                                assets.dInfo,
                                                            "case":
                                                                "Click here to view fundamental data."
                                                          });

                                                          await context
                                                              .read(
                                                                  marketWatchProvider)
                                                              .fetchTechData(
                                                                  context:
                                                                      context,
                                                                  exch:
                                                                      "${holdingProvide.holdingsModel![index].exchTsym![0].exch}",
                                                                  tradeSym:
                                                                      "${holdingProvide.holdingsModel![index].exchTsym![0].tsym}",
                                                                  lastPrc:
                                                                      "${holdingProvide.holdingsModel![index].exchTsym![0].lp}");
                                                        }
                                                        Navigator.pushNamed(
                                                            context,
                                                            Routes
                                                                .holdingDetail,
                                                            arguments: {
                                                              "holdingData":
                                                                  holdingProvide
                                                                          .holdingsModel![
                                                                      index],
                                                              "exchTsym":
                                                                  holdingProvide
                                                                      .holdingsModel![
                                                                          index]
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
                                                      child: 
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "${holdingProvide.holdingsModel![index].exchTsym![0].tsym} ",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: textStyles
                                                                        .scripNameTxtStyle
                                                                        .copyWith(
                                                                            color: theme.isDarkMode
                                                                                ? colors.colorWhite
                                                                                : colors.colorBlack)),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        " LTP: ",
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
                                                            const SizedBox(
                                                                height: 4),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                CustomExchBadge(
                                                                    exch:
                                                                        "${holdingProvide.holdingsModel![index].exchTsym![0].exch}"),
                                                                Text(
                                                                    " (${holdingProvide.holdingsModel![index].exchTsym![0].perChange}%)",
                                                                    style: textStyle(
                                                                      holdingProvide.holdingsModel![index].exchTsym![0].perChange!.startsWith("-")
                                                                            ? colors.darkred
                                                                            : holdingProvide.holdingsModel![index].exchTsym![0].perChange == "0.00"
                                                                                ? colors.ltpgrey
                                                                                : colors.ltpgreen,
                                                                        12,
                                                                        FontWeight.w500)),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Divider(
                                                                color: theme.isDarkMode
                                                                    ? colors
                                                                        .darkColorDivider
                                                                    : colors
                                                                        .colorDivider),
                                                            const SizedBox(
                                                                height: 3),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                        "Qty: ",
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
                                                                      Text(
                                                                          " NPQ",
                                                                          style: textStyle(
                                                                              const Color(0xff666666),
                                                                              12,
                                                                              FontWeight.w500)),
                                                                    ],
                                                                    if (holdingProvide
                                                                            .holdingsModel![
                                                                                index]
                                                                            .btstqty !=
                                                                        "0")
                                                                      Text(
                                                                          " T1: ${holdingProvide.holdingsModel![index].btstqty}",
                                                                          style: textStyle(
                                                                              const Color(0xff666666),
                                                                              12,
                                                                              FontWeight.w500))
                                                                  ],
                                                                ),
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                        "₹${holdingProvide.holdingsModel![index].exchTsym![0].profitNloss}",
                                                                        style: textStyle(
                                                                          holdingProvide.holdingsModel![index].exchTsym![0].profitNloss!.startsWith("-")
                                                                                ? colors.darkred
                                                                                : colors.ltpgreen,
                                                                            14,
                                                                            FontWeight.w500)),
                                                                    Text(
                                                                        " (${holdingProvide.holdingsModel![index].exchTsym![0].pNlChng == "NaN" ? 0.0 : holdingProvide.holdingsModel![index].exchTsym![0].pNlChng}%)",
                                                                        style: textStyle(
                                                                            holdingProvide.holdingsModel![index].exchTsym![0].pNlChng!.startsWith("-")
                                                                                ? colors.darkred
                                                                                : holdingProvide.holdingsModel![index].exchTsym![0].pNlChng == "NaN"
                                                                                    ? colors.darkred
                                                                                    : colors.ltpgreen,
                                                                            12,
                                                                            FontWeight.w500)),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        "Inv: ",
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
                                                                    Text(
                                                                        "Cur: ",
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

                                                  //  HoldingsListCard (
                                                     
                                                  //        data: holdingProvide
                                                  //             .holdingsModel![index] ),

                                                  //     );
                                            },
                                            itemCount: holdingProvide
                                                .holdingsModel!.length,
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return Container(
                                                  color: theme.isDarkMode
                                                      ? const Color(0xffB5C0CF)
                                                          .withOpacity(.15)
                                                      : const Color(0xffF1F3F8),
                                                  height: 6);
                                            },
                                          ),
                                        )
                                      : const Center(child: NoDataFound())
                                  : const Center(child: NoDataFound()))
                          : Expanded(
                              child: ListView.separated(
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // if (socketDatas.containsKey(holdingProvide
                                    //     .holdingSearchItem![index]
                                    //     .exchTsym![0]
                                    //     .token)) {
                                    //   holdingProvide.holdingSearchItem![index]
                                    //           .exchTsym![0].lp =
                                    //       "${socketDatas["${holdingProvide.holdingSearchItem![index].exchTsym![0].token}"]['lp']}";

                                    //   holdingProvide.holdingSearchItem![index]
                                    //           .exchTsym![0].perChange =
                                    //       "${socketDatas["${holdingProvide.holdingSearchItem![index].exchTsym![0].token}"]['pc']}";

                                    //   holdingProvide.holdingSearchItem![index]
                                    //           .exchTsym![0].close =
                                    //       "${socketDatas["${holdingProvide.holdingSearchItem![index].exchTsym![0].token}"]['c']}";

                                    //   // WidgetsBinding.instance
                                    //   //     .addPostFrameCallback((_) {
                                    //   // holdingProvide.holdingCalc();
                                    //   // });
                                    // }
                                    return InkWell(
                                        onTap: () async {
                                          await context
                                              .read(marketWatchProvider)
                                              .fetchLinkeScrip(
                                                  "${holdingProvide.holdingSearchItem![index].exchTsym![0].token}",
                                                  "${holdingProvide.holdingSearchItem![index].exchTsym![0].exch}",context);

                                          await watch(marketWatchProvider)
                                              .fetchScripQuote(
                                                  "${holdingProvide.holdingSearchItem![index].exchTsym![0].token}",
                                                  "${holdingProvide.holdingSearchItem![index].exchTsym![0].exch}",
                                                  context);

                                          if ((holdingProvide
                                                      .holdingSearchItem![index]
                                                      .exchTsym![0]
                                                      .exch ==
                                                  "NSE" ||
                                              holdingProvide
                                                      .holdingSearchItem![index]
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
                                          Navigator.pushNamed(
                                              context, Routes.holdingDetail,
                                              arguments: {
                                                "holdingData": holdingProvide
                                                    .holdingSearchItem![index],
                                                "exchTsym": holdingProvide
                                                    .holdingSearchItem![index]
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
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          "${holdingProvide.holdingSearchItem![index].exchTsym![0].tsym} ",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: textStyles
                                                              .scripNameTxtStyle
                                                              .copyWith(
                                                                  color: theme.isDarkMode
                                                                      ? colors
                                                                          .colorWhite
                                                                      : colors
                                                                          .colorBlack)),
                                                      Row(
                                                        children: [
                                                          Text(" LTP: ",
                                                              style: textStyle(
                                                                  const Color(
                                                                      0xff5E6B7D),
                                                                  13,
                                                                  FontWeight
                                                                      .w600)),
                                                          Text(
                                                              "₹${holdingProvide.holdingSearchItem![index].exchTsym![0].lp}",
                                                              style: textStyle(
                                                                  theme.isDarkMode
                                                                      ? colors
                                                                          .colorWhite
                                                                      : colors
                                                                          .colorBlack,
                                                                  14,
                                                                  FontWeight
                                                                      .w500)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomExchBadge(
                                                          exch:
                                                              "${holdingProvide.holdingsModel![index].exchTsym![0].exch}"),
                                                      Text(
                                                          " (${holdingProvide.holdingSearchItem![index].exchTsym![0].perChange}%)",
                                                          style: textStyle(
                                                             holdingProvide
                                                                      .holdingSearchItem![
                                                                          index]
                                                                      .exchTsym![
                                                                          0]
                                                                      .perChange!
                                                                      .startsWith(
                                                                          "-")
                                                                  ? colors.darkred
                                                                  : holdingProvide
                                                                              .holdingSearchItem![index]
                                                                              .exchTsym![0]
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
                                                          ? colors
                                                              .darkColorDivider
                                                          : colors
                                                              .colorDivider),
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text("Qty: ",
                                                              style: textStyle(
                                                                  const Color(
                                                                      0xff5E6B7D),
                                                                  14,
                                                                  FontWeight
                                                                      .w500)),
                                                          Text(
                                                              "${holdingProvide.holdingSearchItem![index].currentQty ?? 0} @ ₹${holdingProvide.holdingSearchItem![index].upldprc ?? holdingProvide.holdingSearchItem![index].exchTsym![0].close ?? 0.00}",
                                                              style: textStyle(
                                                                  theme.isDarkMode
                                                                      ? colors
                                                                          .colorWhite
                                                                      : colors
                                                                          .colorBlack,
                                                                  14,
                                                                  FontWeight
                                                                      .w500)),
                                                          if (holdingProvide
                                                                  .holdingSearchItem![
                                                                      index]
                                                                  .npoadqty
                                                                  .toString() !=
                                                              "null") ...[
                                                            Text(" NPQ",
                                                                style: textStyle(
                                                                    const Color(
                                                                        0xff666666),
                                                                    12,
                                                                    FontWeight
                                                                        .w500)),
                                                          ],
                                                          if (holdingProvide
                                                                  .holdingSearchItem![
                                                                      index]
                                                                  .btstqty !=
                                                              "0")
                                                            Text(
                                                                " T1: ${holdingProvide.holdingSearchItem![index].btstqty}",
                                                                style: textStyle(
                                                                    const Color(
                                                                        0xff666666),
                                                                    12,
                                                                    FontWeight
                                                                        .w500))
                                                        ],
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                              "₹${holdingProvide.holdingSearchItem![index].exchTsym![0].profitNloss}",
                                                              style: textStyle(
                                                               holdingProvide
                                                                          .holdingSearchItem![
                                                                              index]
                                                                          .exchTsym![
                                                                              0]
                                                                          .profitNloss!
                                                                          .startsWith(
                                                                              "-")
                                                                      ? colors.darkred
                                                                      : colors.ltpgreen,
                                                                  14,
                                                                  FontWeight
                                                                      .w500)),
                                                          Text(
                                                              " (${holdingProvide.holdingSearchItem![index].exchTsym![0].pNlChng == "NaN" ? 0.0 : holdingProvide.holdingSearchItem![index].exchTsym![0].pNlChng}%)",
                                                              style: textStyle(
                                                                holdingProvide
                                                                          .holdingSearchItem![
                                                                              index]
                                                                          .exchTsym![
                                                                              0]
                                                                          .pNlChng!
                                                                          .startsWith(
                                                                              "-")
                                                                      ? colors.darkred
                                                                      : holdingProvide.holdingSearchItem![index].exchTsym![0].pNlChng ==
                                                                              "NaN"
                                                                          ? colors.ltpgrey
                                                                          : colors.ltpgreen,
                                                                  12,
                                                                  FontWeight
                                                                      .w500)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text("Inv: ",
                                                                style: textStyle(
                                                                    const Color(
                                                                        0xff5E6B7D),
                                                                    14,
                                                                    FontWeight
                                                                        .w500)),
                                                            Text(
                                                                "₹${getFormatter(value: double.parse("${holdingProvide.holdingSearchItem![index].invested == "0.00" ? holdingProvide.holdingSearchItem![index].exchTsym![0].close ?? 0.00 : holdingProvide.holdingSearchItem![index].invested ?? 0.00}"), v4d: false, noDecimal: false)}",
                                                                style: textStyle(
                                                                    theme.isDarkMode
                                                                        ? colors
                                                                            .colorWhite
                                                                        : colors
                                                                            .colorBlack,
                                                                    14,
                                                                    FontWeight
                                                                        .w500)),
                                                          ],
                                                        ),
                                                        Row(children: [
                                                          Text("Cur: ",
                                                              style: textStyle(
                                                                  const Color(
                                                                      0xff5E6B7D),
                                                                  14,
                                                                  FontWeight
                                                                      .w500)),
                                                          Text(
                                                              "₹${getFormatter(value: double.parse("${holdingProvide.holdingSearchItem![index].currentValue ?? 0.00}"), v4d: false, noDecimal: false)}",
                                                              style: textStyle(
                                                                  theme.isDarkMode
                                                                      ? colors
                                                                          .colorWhite
                                                                      : colors
                                                                          .colorBlack,
                                                                  14,
                                                                  FontWeight
                                                                      .w500))
                                                        ])
                                                      ])
                                                ])));
                                  },
                                  itemCount:
                                      holdingProvide.holdingSearchItem!.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        color: const Color(0xffF1F3F8),
                                        height: 7);
                                  }))
                    ])));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
