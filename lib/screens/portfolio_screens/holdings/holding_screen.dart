import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
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
    final mf = watch(mfProvider);
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
                  child: StreamBuilder<Map>(
                    stream: watch(websocketProvider).socketDataStream,
                    builder: (context, snapshot) {
                      double totalPnlHolding = 0.0;
                      double oneDayChng = 0.0;
                      double invest = 0.0;
                      double totalCurrentVal = 0.0;
                      double oneDayChngPer = 0.0;
                      String totPnlPercHolding = "0.00";
                      
                      final socketDatas = snapshot.data ?? {};

                      if (holdingProvide.holdingsModel!.isNotEmpty) {
                        for (var holdingJson in holdingProvide.holdingsModel!) {
                          if (socketDatas.containsKey(holdingJson.exchTsym![0].token)) {
                            final socketData = socketDatas[holdingJson.exchTsym![0].token];
                            final lp = socketData['lp']?.toString();
                            if (lp != null && lp != "null" && lp != "0" && lp != "0.0" && lp != "0.00") {
                              holdingJson.exchTsym![0].lp = lp;
                            }
                            
                            final pc = socketData['pc']?.toString();
                            if (pc != null && pc != "null" && pc != "0" && pc != "0.0" && pc != "0.00") {
                              holdingJson.exchTsym![0].perChange = pc;
                            }
                            
                            final c = socketData['c']?.toString();
                            if (c != null && c != "null" && c != "0" && c != "0.0" && c != "0.00") {
                              holdingJson.exchTsym![0].close = c;
                            }
                            
                            final lpValue = double.tryParse(holdingJson.exchTsym![0].lp ?? "0.00") ?? 0.0;
                            if (lpValue > 0) {
                              holdingJson.currentValue = (int.parse("${holdingJson.currentQty ?? 0}") * lpValue).toStringAsFixed(2);
                            }
                          }
                          
                          totalPnlHolding += double.parse("${holdingJson.exchTsym![0].profitNloss ?? 0.0}");
                          oneDayChng += double.parse("${holdingJson.exchTsym![0].oneDayChg ?? 0.0}");
                          invest += double.parse("${holdingJson.invested ?? 0.0}");
                          totalCurrentVal += double.parse("${holdingJson.currentValue ?? 0.0}");
                        }

                        oneDayChngPer = totalCurrentVal > 0 ? (oneDayChng / totalCurrentVal) * 100 : 0.0;
                        totPnlPercHolding = invest > 0
                            ? ((totalPnlHolding / invest) * 100).toStringAsFixed(2)
                            : "0.00";
                      }
                      
                      return Column(
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
                                          "₹${getFormatter(value: totalPnlHolding, v4d: false, noDecimal: false)} ",
                                          style: textStyle(
                                              totalPnlHolding
                                                      .toString()
                                                      .startsWith("-")
                                                  ? colors.darkred
                                                  : colors.ltpgreen,
                                              16,
                                              FontWeight.w500)),
                                      Text(
                                          "(${totPnlPercHolding == "NaN" ? 0.00 : totPnlPercHolding}%)",
                                          style: textStyle(
                                              totPnlPercHolding.startsWith("-")
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
                                        "₹${getFormatter(value: totalCurrentVal, v4d: false, noDecimal: false)}",
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
                                            "₹${getFormatter(value: oneDayChng, v4d: false, noDecimal: false)}",
                                            style: textStyle(
                                                oneDayChng
                                                        .toStringAsFixed(2)
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                16,
                                                FontWeight.w500)),
                                        Text(
                                            " (${oneDayChngPer.isNaN ? "0.00" : oneDayChngPer.toStringAsFixed(2)}%)",
                                            style: textStyle(
                                                oneDayChngPer
                                                        .toStringAsFixed(2)
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                14,
                                                FontWeight.w500))
                                      ])
                                    ])
                              ])
                        ],
                      );
                    }
                  )),
              
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (holdingProvide.holdingsModel!.isNotEmpty && holdingProvide.showEdis) ...[
                                  SizedBox(
                                      height: 27,
                                      child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                  color: colors.colorGrey),
                                              shape:
                                                  const RoundedRectangleBorder(
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
                                  const SizedBox(
                                    width: 8,
                                  )
                                ],
                                SizedBox(
                                    height: 27,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: colors.colorGrey),
                                            shape:
                                                const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                32)))),
                                        onPressed: () async {
                                          await mf.mfApicallinit(context, 2);
                                        },
                                        child: Text("My MF",
                                            style: textStyle(
                                                !theme.isDarkMode
                                                    ? colors.colorBlack
                                                    : colors.colorWhite,
                                                12,
                                                FontWeight.w600)))),
                              ],
                            ),
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
                      child: StreamBuilder<Map>(
                        stream: watch(websocketProvider).socketDataStream,
                        builder: (context, snapshot) {
                          final socketDatas = snapshot.data ?? {};

                          if (holdingProvide.holdingSearchItem!.isEmpty) {
                            if (holdingProvide.holdingsModel!.isNotEmpty) {
                              for (var holding in holdingProvide.holdingsModel!) {
                                var exchTsym = holding.exchTsym![0];
                                
                                if (socketDatas.containsKey(exchTsym.token)) {
                                  final socketData = socketDatas[exchTsym.token];
                                  
                                  // Only update with non-zero values, otherwise keep existing values
                                  final lp = socketData['lp']?.toString();
                                  if (lp != null && lp != "null" && lp != "0" && lp != "0.0" && lp != "0.00") {
                                    exchTsym.lp = lp;
                                  }
                                  
                                  final pc = socketData['pc']?.toString();
                                  if (pc != null && pc != "null" && pc != "0" && pc != "0.0" && pc != "0.00") {
                                    exchTsym.perChange = pc;
                                  }
                                  
                                  final c = socketData['c']?.toString();
                                  if (c != null && c != "null" && c != "0" && c != "0.0" && c != "0.00") {
                                    exchTsym.close = c;
                                  }
                                  
                                  // Only calculate currentValue if we have valid lp
                                  final lpValue = double.tryParse(exchTsym.lp ?? "0.00") ?? 0.0;
                                  if (lpValue > 0) {
                                    holding.currentValue = (int.parse("${holding.currentQty ?? 0}") * lpValue).toStringAsFixed(2);
                                  
                                    // Use the close value for avgCost only if it's valid
                                    final closeValue = double.tryParse(exchTsym.close ?? "0.00") ?? 0.0;
                                    double avgCost = double.parse("${holding.upldprc == "0.00" ? 
                                        (closeValue > 0 ? closeValue.toString() : "0.00") : holding.upldprc ?? 0.00}");
                                    
                                    if (avgCost > 0) {
                                      holding.invested = (holding.currentQty! * avgCost).toStringAsFixed(2);
                                    }
                                  }
                                  
                                  if (double.parse(exchTsym.profitNloss.toString()) != 0 && 
                                      double.parse(exchTsym.pNlChng.toString()) == 0.00) {
                                      
                                    exchTsym.pNlChng = holding.invested == "0.00" 
                                        ? "0.00" 
                                        : ((double.parse("${exchTsym.profitNloss ?? 0.0}") / 
                                            double.parse("${holding.invested ?? 0.0}")) * 100).toStringAsFixed(2);
                                    
                                    exchTsym.oneDayChg = ((double.parse(exchTsym.lp ?? "0.00") - 
                                            double.parse(exchTsym.close ?? "0.00")) * 
                                            int.parse("${holding.currentQty ?? 0}")).toStringAsFixed(2);
                                    
                                    if (holding.currentQty == 0) {
                                      double sellAmt = double.parse(holding.sellAmt ?? "0.00");
                                      int usedQty = int.parse(holding.usedqty ?? "0");
                                      double price = (sellAmt / usedQty);
                                      double pnl = price - double.parse(holding.upldprc ?? "0.0");
                                      
                                      exchTsym.profitNloss = (pnl * usedQty).toStringAsFixed(2);
                                    } else {
                                      exchTsym.profitNloss = (double.parse(holding.currentValue ?? "0.00") - 
                                          double.parse(holding.invested ?? "0.00")).toStringAsFixed(2);
                                    }
                                  }
                                }
                              }
                              
                              return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: false,
                                itemBuilder: (BuildContext context, int idx) {
                                  final index = idx ~/ 2;
                                  
                                  if (idx.isOdd) {
                                    return Container(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF).withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        height: 6);
                                  }

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
                                            .exchTsym![0]),
                                  );
                                },
                                itemCount:
                                    holdingProvide.holdingsModel!.length * 2 - 1,
                              );
                            } else {
                              return const Center(
                                child: SizedBox(
                                  height: 400,
                                  child: NoDataFound(),
                                ),
                              );
                            }
                          } else {
                            for (var holding in holdingProvide.holdingSearchItem!) {
                              var exchTsym = holding.exchTsym![0];
                              
                              if (socketDatas.containsKey(exchTsym.token)) {
                                final socketData = socketDatas[exchTsym.token];
                                
                                // Only update with non-zero values, otherwise keep existing values
                                final lp = socketData['lp']?.toString();
                                if (lp != null && lp != "null" && lp != "0" && lp != "0.0" && lp != "0.00") {
                                  exchTsym.lp = lp;
                                }
                                
                                final pc = socketData['pc']?.toString();
                                if (pc != null && pc != "null" && pc != "0" && pc != "0.0" && pc != "0.00") {
                                  exchTsym.perChange = pc;
                                }
                                
                                final c = socketData['c']?.toString();
                                if (c != null && c != "null" && c != "0" && c != "0.0" && c != "0.00") {
                                  exchTsym.close = c;
                                }
                                
                                // Only calculate currentValue if we have valid lp
                                final lpValue = double.tryParse(exchTsym.lp ?? "0.00") ?? 0.0;
                                if (lpValue > 0) {
                                  holding.currentValue = (int.parse("${holding.currentQty ?? 0}") * lpValue).toStringAsFixed(2);
                                
                                  // Use the close value for avgCost only if it's valid
                                  final closeValue = double.tryParse(exchTsym.close ?? "0.00") ?? 0.0;
                                  double avgCost = double.parse("${holding.upldprc == "0.00" ? 
                                      (closeValue > 0 ? closeValue.toString() : "0.00") : holding.upldprc ?? 0.00}");
                                  
                                  if (avgCost > 0) {
                                    holding.invested = (holding.currentQty! * avgCost).toStringAsFixed(2);
                                  }
                                }
                                
                                exchTsym.pNlChng = holding.invested == "0.00" 
                                    ? "0.00" 
                                    : ((double.parse("${exchTsym.profitNloss ?? 0.0}") / 
                                        double.parse("${holding.invested ?? 0.0}")) * 100).toStringAsFixed(2);
                                
                                exchTsym.oneDayChg = ((double.parse(exchTsym.lp ?? "0.00") - 
                                        double.parse(exchTsym.close ?? "0.00")) * 
                                        int.parse("${holding.currentQty ?? 0}")).toStringAsFixed(2);
                                
                                if (holding.currentQty == 0) {
                                  double sellAmt = double.parse(holding.sellAmt ?? "0.00");
                                  int usedQty = int.parse(holding.usedqty ?? "0");
                                  double price = (sellAmt / usedQty);
                                  double pnl = price - double.parse(holding.upldprc ?? "0.0");
                                  
                                  exchTsym.profitNloss = (pnl * usedQty).toStringAsFixed(2);
                                } else {
                                  exchTsym.profitNloss = (double.parse(holding.currentValue ?? "0.00") - 
                                      double.parse(holding.invested ?? "0.00")).toStringAsFixed(2);
                                }
                              }
                            }
                            
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: false,
                              itemBuilder: (BuildContext context, int idx) {
                                final index = idx ~/ 2;
                                
                                if (idx.isOdd) {
                                  return Container(
                                      color: theme.isDarkMode
                                          ? const Color(0xffB5C0CF).withOpacity(.15)
                                          : const Color(0xffF1F3F8),
                                      height: 6);
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
                                          .exchTsym![0]),
                                );
                              },
                              itemCount:
                                  holdingProvide.holdingSearchItem!.length * 2 - 1,
                            );
                          }
                        },
                      )))
            ]));
  }
}
