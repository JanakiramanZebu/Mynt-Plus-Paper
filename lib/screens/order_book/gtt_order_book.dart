import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/order_book_model/gtt_order_book.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/shocase_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';
import 'filter_gtt_bottom_sheet.dart';

class GttOrderBook extends ConsumerWidget {
  final List<GttOrderBookModel> gttOrderBook;
  const GttOrderBook({super.key, required this.gttOrderBook});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final order = watch(orderProvider);
    final theme = context.read(themeProvider);
    return Column(children: [
      if (gttOrderBook.length > 1)
        Container(
            decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                border: Border(
                    bottom: BorderSide(
                        color: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        width: 6))),
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 2, top: 8, bottom: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                                return const OrderbooGTTkFilterBottomSheet();
                              });
                        },
                        child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: SvgPicture.asset(assets.filterLines,
                                color: const Color(0xff333333)))),
                    InkWell(
                        onTap: () {
                          order.showGTTOrderSearch(true);
                        },
                        child: Padding(
                            padding: const EdgeInsets.only(right: 12, left: 10),
                            child: SvgPicture.asset(assets.searchIcon,
                                width: 19, color: const Color(0xff333333))))
                  ])
                ]))),
      if (order.showGttOrderSearch)
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
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseTextFormatter()],
                  controller: order.orderGttSearchCtrl,
                  style:
                      textStyle(const Color(0xff000000), 16, FontWeight.w600),
                  decoration: InputDecoration(
                      fillColor: const Color(0xffF1F3F8),
                      filled: true,
                      hintStyle: textStyle(
                          const Color(0xff69758F), 15, FontWeight.w500),
                      prefixIconColor: const Color(0xff586279),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SvgPicture.asset(assets.searchIcon,
                            color: const Color(0xff586279),
                            fit: BoxFit.contain,
                            width: 20),
                      ),
                      suffixIcon: InkWell(
                        onTap: () async {
                          order.clearGttOrderSearch();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                    order.orderGttSearch(value, context);
                  },
                ),
              ),
              TextButton(
                  onPressed: () {
                    order.showGTTOrderSearch(false);
                    order.clearGttOrderSearch();
                  },
                  child: Text("Close", style: textStyles.textBtn))
            ],
          ),
        ),
      Expanded(
        child: StreamBuilder<Map>(
          stream: watch(websocketProvider).socketDataStream,
          builder: (context, snapshot) {
            final socketDatas = snapshot.data ?? {};
            
            // Update order book data with real-time values
            if (snapshot.hasData) {
              for (var order in gttOrderBook) {
                if (socketDatas.containsKey(order.token)) {
                  final lp = socketDatas[order.token]['lp']?.toString();
                  final pc = socketDatas[order.token]['pc']?.toString();
                  
                  if (lp != null && lp != "null") {
                    order.ltp = lp;
                  }
                  
                  if (pc != null && pc != "null") {
                    order.perChange = pc;
                  }
                }
              }
              
              if (order.gttOrderBookSearch!.isNotEmpty) {
                for (var searchOrder in order.gttOrderBookSearch!) {
                  if (socketDatas.containsKey(searchOrder.token)) {
                    final lp = socketDatas[searchOrder.token]['lp']?.toString();
                    final pc = socketDatas[searchOrder.token]['pc']?.toString();
                    
                    if (lp != null && lp != "null") {
                      searchOrder.ltp = lp;
                    }
                    
                    if (pc != null && pc != "null") {
                      searchOrder.perChange = pc;
                    }
                  }
                }
              }
            }
            
            return ListView(
              children: [
                if (order.gttOrderBookSearch!.isEmpty)
                  gttOrderBook.isNotEmpty
                      ? ListView.separated(
                          primary: true,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () async {
                                  await context
                                      .read(marketWatchProvider)
                                      .fetchLinkeScrip(
                                          "${gttOrderBook[index].token}",
                                          "${gttOrderBook[index].exch}",
                                          context);

                                  await watch(marketWatchProvider).fetchScripQuote(
                                      "${gttOrderBook[index].token}",
                                      "${gttOrderBook[index].exch}",
                                      context);

                                  if ((gttOrderBook[index].exch == "NSE" ||
                                      gttOrderBook[index].exch == "BSE")) {
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
                                            exch: "${gttOrderBook[index].exch}",
                                            tradeSym: "${gttOrderBook[index].tsym}",
                                            lastPrc: "${gttOrderBook[index].prc}");
                                  }

                                  Navigator.pushNamed(
                                      context, Routes.gttOrderDetail,
                                      arguments: gttOrderBook[index]);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(children: [
                                                  Text(
                                                      "${gttOrderBook[index].symbol} ",
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style: textStyles
                                                          .scripNameTxtStyle
                                                          .copyWith(
                                                              color: theme
                                                                      .isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack)),
                                                  Text(
                                                      "${gttOrderBook[index].option} ",
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style: textStyles
                                                          .scripNameTxtStyle
                                                          .copyWith(
                                                              color: theme
                                                                      .isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack)),
                                                ]),
                                                Row(
                                                  children: [
                                                    Text(" LTP: ",
                                                        style: textStyle(
                                                            const Color(0xff5E6B7D),
                                                            13,
                                                            FontWeight.w600)),
                                                    Text(
                                                        "₹${gttOrderBook[index].ltp ?? gttOrderBook[index].close ?? 0.00}",
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            14,
                                                            FontWeight.w500)),
                                                  ],
                                                )
                                              ]),
                                          const SizedBox(height: 4),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    CustomExchBadge(
                                                        exch:
                                                            "${gttOrderBook[index].exch}"),
                                                    Text(
                                                        " ${gttOrderBook[index].expDate} ",
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: textStyles
                                                            .scripExchTxtStyle
                                                            .copyWith(
                                                          color: theme.isDarkMode
                                                              ? colors.colorWhite
                                                              : colors.colorBlack,
                                                        ))
                                                  ],
                                                ),
                                                Text(
                                                    " (${gttOrderBook[index].perChange ?? 0.00}%)",
                                                    style: textStyle(
                                                        gttOrderBook[index]
                                                                .perChange!
                                                                .startsWith("-")
                                                            ? colors.darkred
                                                            : gttOrderBook[index]
                                                                        .perChange ==
                                                                    "0.00"
                                                                ? colors.ltpgrey
                                                                : colors.ltpgreen,
                                                        12,
                                                        FontWeight.w500)),
                                              ]),
                                          const SizedBox(height: 4),
                                          Divider(
                                              color: theme.isDarkMode
                                                  ? colors.darkColorDivider
                                                  : colors.colorDivider),
                                          const SizedBox(height: 2),
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
                                                              ? Color(gttOrderBook[index].trantype == "S" ? 0XFFf44336 : 0xff43A833)
                                                                  .withOpacity(.2)
                                                              : Color(
                                                                  gttOrderBook[index].trantype == "S"
                                                                      ? 0xffFCF3F3
                                                                      : 0xffECF8F1)),
                                                      child: Text(gttOrderBook[index].trantype == "S" ? "SELL" : "BUY",
                                                          style: textStyle(
                                                              gttOrderBook[index].trantype == "S"
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
                                                              BorderRadius.circular(
                                                                  4),
                                                          color: theme.isDarkMode
                                                              ? const Color(0xff666666)
                                                                  .withOpacity(.2)
                                                              : const Color(0xff999999)
                                                                  .withOpacity(.2)),
                                                      child: Text(
                                                          "${gttOrderBook[index].placeOrderParams!.sPrdtAli}",
                                                          style: textStyle(
                                                              const Color(0xff666666),
                                                              11,
                                                              FontWeight.w600)))
                                                ]),
                                                Row(children: [
                                                  Text("Qty: ",
                                                      style: textStyle(
                                                          const Color(0xff5E6B7D),
                                                          14,
                                                          FontWeight.w500)),
                                                  Text(
                                                      "${gttOrderBook[index].qty ?? 0}",
                                                      style: textStyle(
                                                          theme.isDarkMode
                                                              ? colors.colorWhite
                                                              : colors.colorBlack,
                                                          14,
                                                          FontWeight.w500))
                                                ])
                                              ]),
                                          const SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        "${gttOrderBook[index].aiT!.replaceAll("_B_O", "").replaceAll("_A_O", "").replaceAll("_", " ")} ",
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors.colorWhite
                                                                : colors.colorBlack,
                                                            14,
                                                            FontWeight.w500)),
                                                    Text(
                                                        formatDateTime(
                                                            value:
                                                                gttOrderBook[index]
                                                                    .norentm!),
                                                        style: textStyle(
                                                            const Color(0xff666666),
                                                            12,
                                                            FontWeight.w500)),
                                                  ],
                                                ),
                                                Row(children: [
                                                  Text("Price: ",
                                                      style: textStyle(
                                                          const Color(0xff5E6B7D),
                                                          14,
                                                          FontWeight.w500)),
                                                  Text(
                                                      "${gttOrderBook[index].prc ?? 0.00}",
                                                      style: textStyle(
                                                          theme.isDarkMode
                                                              ? colors.colorWhite
                                                              : colors.colorBlack,
                                                          14,
                                                          FontWeight.w500))
                                                ])
                                              ])
                                        ]))

                            // GTTOrderBookList( gttOrderBook: gttOrderBook[index])

                            );
                      },
                      itemCount: gttOrderBook.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                            color: theme.isDarkMode
                                ? colors.darkGrey
                                : const Color(0xffF1F3F8),
                            height: 6);
                      },
                    )
                  : const SizedBox(height: 500, child: NoDataFound()),
                if (order.gttOrderBookSearch!.isNotEmpty)
                  ListView.separated(
                    primary: true,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () async {
                            await context.read(marketWatchProvider).fetchLinkeScrip(
                                "${order.gttOrderBookSearch![index].token}",
                                "${order.gttOrderBookSearch![index].exch}",
                                context);

                            await watch(marketWatchProvider).fetchScripQuote(
                                "${order.gttOrderBookSearch![index].token}",
                                "${order.gttOrderBookSearch![index].exch}",
                                context);

                            if ((order.gttOrderBookSearch![index].exch == "NSE" ||
                                order.gttOrderBookSearch![index].exch == "BSE")) {
                              context.read(marketWatchProvider).depthBtns.add({
                                "btnName": "Fundamental",
                                "imgPath": assets.dInfo,
                                "key":
                                    context.read(showcaseProvide).fundamentalcase,
                                "case": "Click here to view fundamental data."
                              });

                              await context.read(marketWatchProvider).fetchTechData(
                                  context: context,
                                  exch: "${order.gttOrderBookSearch![index].exch}",
                                  tradeSym:
                                      "${order.gttOrderBookSearch![index].tsym}",
                                  lastPrc:
                                      "${order.gttOrderBookSearch![index].prc}");
                            }

                            Navigator.pushNamed(context, Routes.gttOrderDetail,
                                arguments: order.gttOrderBookSearch![index]);
                          },
                          child: Container(
                              padding: const EdgeInsets.all(16),
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
                                                "${order.gttOrderBookSearch![index].symbol} ",
                                                overflow: TextOverflow.ellipsis,
                                                style: textStyles.scripNameTxtStyle
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack)),
                                            Text(
                                                "${order.gttOrderBookSearch![index].option} ",
                                                overflow: TextOverflow.ellipsis,
                                                style: textStyles.scripNameTxtStyle
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack)),
                                          ]),
                                          Row(
                                            children: [
                                              Text(" LTP: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      13,
                                                      FontWeight.w600)),
                                              if (socketDatas.containsKey(order
                                                  .gttOrderBookSearch![index]
                                                  .token)) ...[
                                                Text(
                                                    "₹${order.gttOrderBookSearch![index].ltp ?? order.gttOrderBookSearch![index].close ?? 0.00}",
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        14,
                                                        FontWeight.w500)),
                                              ]
                                              // SvgPicture.asset(assets.rightArrowIcon),
                                            ],
                                          )
                                        ]),
                                    const SizedBox(height: 4),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CustomExchBadge(
                                                  exch:
                                                      "${order.gttOrderBookSearch![index].exch}"),
                                              Text(
                                                  " ${order.gttOrderBookSearch![index].expDate} ",
                                                  overflow: TextOverflow.ellipsis,
                                                  style: textStyles
                                                      .scripExchTxtStyle
                                                      .copyWith(
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                  ))
                                            ],
                                          ),
                                          Text(
                                              " (${order.gttOrderBookSearch![index].perChange ?? 0.00}%)",
                                              style: textStyle(
                                                  order.gttOrderBookSearch![index]
                                                          .perChange!
                                                          .startsWith("-")
                                                      ? colors.darkred
                                                      : order
                                                                  .gttOrderBookSearch![
                                                                      index]
                                                                  .perChange ==
                                                              "0.00"
                                                          ? colors.ltpgrey
                                                          : colors.ltpgreen,
                                                  12,
                                                  FontWeight.w500)),
                                        ]),
                                    const SizedBox(height: 4),
                                    Divider(
                                        color: theme.isDarkMode
                                            ? colors.darkColorDivider
                                            : colors.colorDivider),
                                    const SizedBox(height: 2),
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
                                                        ? Color(order.gttOrderBookSearch![index].trantype == "S" ? 0XFFf44336 : 0xff43A833)
                                                            .withOpacity(.2)
                                                        : Color(order.gttOrderBookSearch![index].trantype == "S"
                                                            ? 0xffFCF3F3
                                                            : 0xffECF8F1)),
                                                child: Text(
                                                    gttOrderBook[index].trantype == "S"
                                                        ? "SELL"
                                                        : "BUY",
                                                    style: textStyle(
                                                        order.gttOrderBookSearch![index].trantype == "S"
                                                            ? colors.darkred
                                                            : colors.ltpgreen,
                                                        12,
                                                        FontWeight.w600))),
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
                                                    "${order.gttOrderBookSearch![index].placeOrderParams!.sPrdtAli}",
                                                    style: textStyle(
                                                        const Color(0xff666666),
                                                        11,
                                                        FontWeight.w600)))
                                          ]),
                                          Row(children: [
                                            Text("Qty: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    14,
                                                    FontWeight.w500)),
                                            Text(
                                                "${order.gttOrderBookSearch![index].qty ?? 0}",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500))
                                          ])
                                        ]),
                                    const SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                  "${order.gttOrderBookSearch![index].aiT!.replaceAll("_B_O", "").replaceAll("_A_O", "").replaceAll("_", " ")} ",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                              Text(
                                                  formatDateTime(
                                                      value: gttOrderBook[index]
                                                          .norentm!),
                                                  style: textStyle(
                                                      const Color(0xff666666),
                                                      12,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                          Row(children: [
                                            Text("Price: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    14,
                                                    FontWeight.w500)),
                                            Text(
                                                "${order.gttOrderBookSearch![index].prc ?? 0.00}",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500))
                                          ])
                                        ])
                                  ]))

                          // GTTOrderBookList( gttOrderBook: gttOrderBook[index])

                          );
                    },
                    itemCount: order.gttOrderBookSearch!.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          height: 6);
                    },
                  ),
              ],
            );
          },
        ),
      )
    ]);
  }
}
