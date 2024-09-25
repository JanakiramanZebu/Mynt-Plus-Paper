// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_book_model/trade_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/shocase_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';
import 'filter_trade_book.dart';

class TradeBook extends ConsumerWidget {
  List<TradeBookModel> tradeBook;
  TradeBook({super.key, required this.tradeBook});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final order = watch(orderProvider);
    return Column(children: [
      Expanded(
          child: RefreshIndicator(
        onRefresh: () async {
          order.fetchOrderBook(context, true);
          order.fetchTradeBook(context);
        },
        child: ListView(
          children: [
            if (order.tradeBook!.length > 1)
              Container(
                  decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorWhite,
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkGrey
                                  : Color(0xffF1F3F8),
                              width: 6))),
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 2, top: 8, bottom: 8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(children: [
                              InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    showModalBottomSheet(
                                        useSafeArea: true,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(16))),
                                        context: context,
                                        builder: (context) {
                                          return const OrderbookTradeBookFilterBottomSheet();
                                        });
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: SvgPicture.asset(
                                          assets.filterLines,
                                          color: const Color(0xff333333)))),
                              InkWell(
                                  onTap: () {
                                    order.showTradeSearch(true);
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 12, left: 10),
                                      child: SvgPicture.asset(assets.searchIcon,
                                          width: 19,
                                          color: const Color(0xff333333))))
                            ])
                          ]))),
            if (order.showSiptradebookSearch)
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: order.orderTradebookCtrl,
                        style: textStyle(
                            const Color(0xff000000), 16, FontWeight.w600),
                        decoration: InputDecoration(
                            fillColor: const Color(0xffF1F3F8),
                            filled: true,
                            hintStyle: textStyle(
                                const Color(0xff69758F), 15, FontWeight.w500),
                            prefixIconColor: const Color(0xff586279),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SvgPicture.asset(assets.searchIcon,
                                  color: const Color(0xff586279),
                                  fit: BoxFit.contain,
                                  width: 20),
                            ),
                            suffixIcon: InkWell(
                              onTap: () async {
                                order.clearTradeBookSearch();
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
                            contentPadding: const EdgeInsets.only(top: 20),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20))),
                        onChanged: (value) async {
                          order.orderTradeBookSearch(value, context);
                        },
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          order.showTradeSearch(false);
                          order.clearTradeBookSearch();
                        },
                        child: Text("Close", style: textStyles.textBtn))
                  ],
                ),
              ),
            if (order.tradeBooksearch!.isEmpty)
              tradeBook.isNotEmpty
                  ? ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () async {
                              await context
                                  .read(marketWatchProvider)
                                  .fetchLinkeScrip("${tradeBook[index].token}",
                                      "${tradeBook[index].exch}", context);

                              await watch(marketWatchProvider).fetchScripQuote(
                                  "${tradeBook[index].token}",
                                  "${tradeBook[index].exch}",
                                  context);

                              if ((tradeBook[index].exch == "NSE" ||
                                  tradeBook[index].exch == "BSE")) {
                                context
                                    .read(marketWatchProvider)
                                    .depthBtns
                                    .add({
                                  "btnName": "Fundamental",
                                  "imgPath": assets.dInfo,
                                  "key": context
                                      .read(showcaseProvide)
                                      .fundamentalcase,
                                  "case": "Click here to view fundamental data."
                                });

                                await context
                                    .read(marketWatchProvider)
                                    .fetchTechData(
                                        context: context,
                                        exch: "${tradeBook[index].exch}",
                                        tradeSym: "${tradeBook[index].tsym}",
                                        lastPrc: "${tradeBook[index].prc}");
                              }
                              Navigator.pushNamed(context, Routes.tradeDetail,
                                  arguments: tradeBook[index]);
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Text("${tradeBook[index].symbol} ",
                                                overflow: TextOverflow.ellipsis,
                                                style: textStyles
                                                    .scripNameTxtStyle
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors
                                                                .colorBlack)),
                                            Text("${tradeBook[index].option} ",
                                                overflow: TextOverflow.ellipsis,
                                                style: textStyles
                                                    .scripNameTxtStyle
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors
                                                                .colorBlack))
                                          ]),
                                          SvgPicture.asset(
                                              assets.rightArrowIcon)
                                        ]),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      CustomExchBadge(
                                          exch: "${tradeBook[index].exch}"),
                                      Text(" ${tradeBook[index].expDate} ",
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyles.scripExchTxtStyle
                                              .copyWith(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack))
                                    ]),
                                    const SizedBox(height: 3),
                                    Divider(
                                        color: theme.isDarkMode
                                            ? colors.darkColorDivider
                                            : colors.colorDivider),
                                    const SizedBox(height: 3),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color: theme.isDarkMode
                                                        ? Color(tradeBook[index].trantype == "S" ? 0XFFf44336 : 0xff43A833)
                                                            .withOpacity(.2)
                                                        : Color(
                                                            tradeBook[index].trantype == "S"
                                                                ? 0xffFCF3F3
                                                                : 0xffECF8F1)),
                                                child: Text(tradeBook[index].trantype == "S" ? "SELL" : "BUY",
                                                    style: textStyle(
                                                        tradeBook[index].trantype == "S"
                                                            ? colors.darkred
                                                            : colors.ltpgreen,
                                                        12,
                                                        FontWeight.w600))),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 7),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  color: theme.isDarkMode
                                                      ? const Color(0xff666666)
                                                          .withOpacity(.2)
                                                      : const Color(0xff999999)
                                                          .withOpacity(.2)),
                                              child: Text(
                                                  "${tradeBook[index].sPrdtAli}",
                                                  style: textStyle(
                                                      const Color(0xff666666),
                                                      12,
                                                      FontWeight.w600)),
                                            ),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    left: 7),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color: theme.isDarkMode
                                                        ? const Color(0xff666666)
                                                            .withOpacity(.2)
                                                        : const Color(
                                                                0xff999999)
                                                            .withOpacity(.2)),
                                                child: Text(
                                                    "${tradeBook[index].prctyp}",
                                                    style: textStyle(
                                                        const Color(0xff666666),
                                                        12,
                                                        FontWeight.w600)))
                                          ]),
                                          Row(children: [
                                            Text("Prc: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    14,
                                                    FontWeight.w500)),
                                            Text(
                                                "₹${tradeBook[index].prc ?? 0.00}",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500))
                                          ])
                                        ]),
                                    const SizedBox(height: 8),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Text("Fill Qty: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    14,
                                                    FontWeight.w500)),
                                            Text(
                                                "${tradeBook[index].flqty ?? 0}",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500))
                                          ]),
                                          Row(children: [
                                            Text("Avg.Price: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    14,
                                                    FontWeight.w500)),
                                            Text(
                                                "${tradeBook[index].avgprc ?? 0.00}",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500))
                                          ])
                                        ]),
                                    const SizedBox(height: 8),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Text("Fill Id: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    14,
                                                    FontWeight.w500)),
                                            Text(
                                                "${tradeBook[index].flid ?? 0}",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500))
                                          ]),
                                          Text(
                                              formatDateTime(
                                                  value: tradeBook[index]
                                                      .norentm!),
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  12,
                                                  FontWeight.w500))
                                        ])
                                  ]),
                            ));
                      },
                      itemCount: tradeBook.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                            color: theme.isDarkMode
                                ? colors.darkGrey
                                : const Color(0xffF1F3F8),
                            height: 6);
                      },
                    )
                  : const SizedBox(height: 500, child: NoDataFound()),
            if (order.tradeBooksearch!.isNotEmpty)
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () async {
                        await context.read(marketWatchProvider).fetchLinkeScrip(
                            "${order.tradeBooksearch![index].token}",
                            "${order.tradeBooksearch![index].exch}",
                            context);

                        await watch(marketWatchProvider).fetchScripQuote(
                            "${order.tradeBooksearch![index].token}",
                            "${order.tradeBooksearch![index].exch}",
                            context);

                        if ((order.tradeBooksearch![index].exch == "NSE" ||
                            order.tradeBooksearch![index].exch == "BSE")) {
                          context.read(marketWatchProvider).depthBtns.add({
                            "btnName": "Fundamental",
                            "imgPath": assets.dInfo,
                            "key":
                                context.read(showcaseProvide).fundamentalcase,
                            "case": "Click here to view fundamental data."
                          });

                          await context.read(marketWatchProvider).fetchTechData(
                              context: context,
                              exch: "${order.tradeBooksearch![index].exch}",
                              tradeSym: "${order.tradeBooksearch![index].tsym}",
                              lastPrc: "${order.tradeBooksearch![index].prc}");
                        }
                        Navigator.pushNamed(context, Routes.tradeDetail,
                            arguments: order.tradeBooksearch![index]);
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Text(
                                          "${order.tradeBooksearch![index].symbol} ",
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyles.scripNameTxtStyle
                                              .copyWith(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack)),
                                      Text(
                                          "${order.tradeBooksearch![index].option} ",
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyles.scripNameTxtStyle
                                              .copyWith(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack))
                                    ]),
                                    SvgPicture.asset(assets.rightArrowIcon)
                                  ]),
                              const SizedBox(height: 4),
                              Row(children: [
                                CustomExchBadge(
                                    exch:
                                        "${order.tradeBooksearch![index].exch}"),
                                Text(
                                    " ${order.tradeBooksearch![index].expDate} ",
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyles.scripExchTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack))
                              ]),
                              const SizedBox(height: 3),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider),
                              const SizedBox(height: 3),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: theme.isDarkMode
                                                  ? Color(order.tradeBooksearch![index].trantype == "S" ? 0XFFf44336 : 0xff43A833)
                                                      .withOpacity(.2)
                                                  : Color(order.tradeBooksearch![index].trantype == "S"
                                                      ? 0xffFCF3F3
                                                      : 0xffECF8F1)),
                                          child: Text(order.tradeBooksearch![index].trantype == "S" ? "SELL" : "BUY",
                                              style: textStyle(
                                                  order.tradeBooksearch![index]
                                                              .trantype ==
                                                          "S"
                                                      ? colors.darkred
                                                      : colors.ltpgreen,
                                                  12,
                                                  FontWeight.w600))),
                                      Container(
                                        margin: const EdgeInsets.only(left: 7),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: theme.isDarkMode
                                                ? const Color(0xff666666)
                                                    .withOpacity(.2)
                                                : const Color(0xff999999)
                                                    .withOpacity(.2)),
                                        child: Text(
                                            "${order.tradeBooksearch![index].sPrdtAli}",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                12,
                                                FontWeight.w600)),
                                      ),
                                      Container(
                                          margin:
                                              const EdgeInsets.only(left: 7),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: theme.isDarkMode
                                                  ? const Color(0xff666666)
                                                      .withOpacity(.2)
                                                  : const Color(0xff999999)
                                                      .withOpacity(.2)),
                                          child: Text(
                                              "${order.tradeBooksearch![index].prctyp}",
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  12,
                                                  FontWeight.w600)))
                                    ]),
                                    Row(children: [
                                      Text("Prc: ",
                                          style: textStyle(
                                              const Color(0xff5E6B7D),
                                              14,
                                              FontWeight.w500)),
                                      Text(
                                          "₹${order.tradeBooksearch![index].prc ?? 0.00}",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w500))
                                    ])
                                  ]),
                              const SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Text("Fill Qty: ",
                                          style: textStyle(
                                              const Color(0xff5E6B7D),
                                              14,
                                              FontWeight.w500)),
                                      Text(
                                          "${order.tradeBooksearch![index].flqty ?? 0}",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w500))
                                    ]),
                                    Row(children: [
                                      Text("Avg.Price: ",
                                          style: textStyle(
                                              const Color(0xff5E6B7D),
                                              14,
                                              FontWeight.w500)),
                                      Text(
                                          "${order.tradeBooksearch![index].avgprc ?? 0.00}",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w500))
                                    ])
                                  ]),
                              const SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Text("Fill Id: ",
                                          style: textStyle(
                                              const Color(0xff5E6B7D),
                                              14,
                                              FontWeight.w500)),
                                      Text(
                                          "${order.tradeBooksearch![index].flid ?? 0}",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w500))
                                    ]),
                                    Text(
                                        formatDateTime(
                                            value: order.tradeBooksearch![index]
                                                .norentm!),
                                        style: textStyle(
                                            const Color(0xff666666),
                                            12,
                                            FontWeight.w500))
                                  ])
                            ]),
                      ));
                },
                itemCount: order.tradeBooksearch!.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                      color: theme.isDarkMode
                          ? colors.darkGrey
                          : const Color(0xffF1F3F8),
                      height: 6);
                },
              )
          ],
        ),
      ))
    ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
