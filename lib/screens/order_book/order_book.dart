import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/custom_text_form_field.dart';

import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/shocase_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';
import 'filter_scrip_bottom_sheet.dart';

class OrderBook extends ConsumerWidget {
  final List<OrderBookModel> orderBook;
  const OrderBook({super.key, required this.orderBook});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final order = watch(orderProvider);
    final searchorder = watch(orderProvider).orderSearchItem;
    final theme = context.read(themeProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(children: [
        if (orderBook.length > 1)
          Container(
              decoration: BoxDecoration(
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  border: Border(
                      bottom: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          width: 6))),
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 2, top: 8, bottom: 8),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                                  return const OrderbookFilterBottomSheet();
                                });
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SvgPicture.asset(assets.filterLines,
                                  color: theme.isDarkMode
                                      ? colors.darkiconcolor
                                      : const Color(0xff333333)))),
                      InkWell(
                          onTap: () {
                            order.showOrderSearch(true);
                          },
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 12, left: 10),
                              child: SvgPicture.asset(assets.searchIcon,
                                  width: 19, color: const Color(0xff333333))))
                    ])
                  ]))),
        if (order.showSearchHold)
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
                    controller: order.orderSearchCtrl,
                    style:
                        textStyle(const Color(0xff000000), 16, FontWeight.w600),
                    decoration: InputDecoration(
                        fillColor: const Color(0xffF1F3F8),
                        filled: true,
                        hintStyle: GoogleFonts.inter(
                            textStyle: textStyle(
                                const Color(0xff69758F), 15, FontWeight.w500)),
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
                            order.clearOrderSearch();
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                      order.orderSearch(value, context);
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      order.showOrderSearch(false);
                      order.clearOrderSearch();
                    },
                    child: Text("Close", style: textStyles.textBtn))
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
              onRefresh: () async {
                order.fetchOrderBook(context, true);
                order.fetchTradeBook(context);
              },
              child: searchorder!.isEmpty
                  ? orderBook.isNotEmpty
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: false,
                          itemBuilder: (context, index) {
                            final itemIndex = index ~/ 2;

                            if (socketDatas
                                .containsKey(orderBook[itemIndex].token)) {
                              orderBook[itemIndex].ltp =
                                  "${socketDatas["${orderBook[itemIndex].token}"]['lp']}";
                              orderBook[itemIndex].perChange =
                                  "${socketDatas["${orderBook[itemIndex].token}"]['pc']}";
                            }
                            if (index.isOdd) {
                              return Container(
                                  color: theme.isDarkMode
                                      ? colors.darkGrey
                                      : const Color(0xffF1F3F8),
                                  height: 6);
                            }

                            return InkWell(
                                onLongPress: () {
                                  if (order.openOrder!.length > 0 &&
                                          order.tabCtrl.index == 1 ||
                                      order.openOrder!.length > 0 &&
                                          !([
                                            "COMPLETE",
                                            "CANCELED",
                                            "REJECTED"
                                          ].contains(
                                              orderBook[itemIndex].status))) {
                                    Navigator.pushNamed(
                                        context, Routes.orderExit,
                                        arguments: order.openOrder);
                                  }
                                },
                                onTap: () async {
                                  await context
                                      .read(marketWatchProvider)
                                      .fetchLinkeScrip(
                                          "${orderBook[itemIndex].token}",
                                          "${orderBook[itemIndex].exch}",
                                          context);

                                  await watch(marketWatchProvider)
                                      .fetchScripQuote(
                                          "${orderBook[itemIndex].token}",
                                          "${orderBook[itemIndex].exch}",
                                          context);
                                  context.read(orderProvider).fetchOrderHistory(
                                      "${orderBook[itemIndex].norenordno}",
                                      context);
                                  if ((orderBook[itemIndex].exch == "NSE" ||
                                          orderBook[itemIndex].exch == "BSE") &&
                                      (orderBook[itemIndex]
                                              .instname
                                              .toString() !=
                                          "UNDIND")) {
                                    context
                                        .read(marketWatchProvider)
                                        .depthBtns
                                        .add({
                                      "btnName": "Fundamental",
                                      "imgPath": assets.dInfo,
                                      "key": context
                                          .read(showcaseProvide)
                                          .fundamentalcase,
                                      "case":
                                          "Click here to view fundamental data."
                                    });

                                    await context
                                        .read(marketWatchProvider)
                                        .fetchTechData(
                                            context: context,
                                            exch:
                                                "${orderBook[itemIndex].exch}",
                                            tradeSym:
                                                "${orderBook[itemIndex].tsym}",
                                            lastPrc:
                                                "${orderBook[itemIndex].ltp ?? orderBook[itemIndex].c ?? 0.00}");
                                  }
                                  Navigator.pushNamed(
                                      context, Routes.orderDetail,
                                      arguments: orderBook[itemIndex]);
                                },
                                child: orderBook[itemIndex].status != null
                                    ? Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      Text(
                                                          "${orderBook[itemIndex].symbol} ",
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
                                                      Text(
                                                          "${orderBook[itemIndex].option} ",
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
                                                    ]),
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
                                                            "₹${orderBook[itemIndex].ltp ?? orderBook[itemIndex].close ?? 0.00}",
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

                                                    // SvgPicture.asset(
                                                    //     assets.rightArrowIcon)
                                                  ]),
                                              const SizedBox(height: 4),
                                              Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CustomExchBadge(
                                                            exch:
                                                                "${orderBook[itemIndex].exch}"),
                                                        Text(
                                                            " ${orderBook[itemIndex].expDate} ",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: textStyles
                                                                .scripExchTxtStyle
                                                                .copyWith(
                                                                    color: theme.isDarkMode
                                                                        ? colors
                                                                            .colorWhite
                                                                        : colors
                                                                            .colorBlack)),
                                                        Container(
                                                            margin:
                                                                const EdgeInsets.only(
                                                                    left: 7),
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 7,
                                                                vertical: 2),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        4),
                                                                color: theme.isDarkMode
                                                                    ? const Color(0xff666666)
                                                                        .withOpacity(
                                                                            .2)
                                                                    : const Color(0xff999999)
                                                                        .withOpacity(
                                                                            .2)),
                                                            child: Text(
                                                                "${orderBook[itemIndex].sPrdtAli}",
                                                                style: textStyle(
                                                                    const Color(0xff666666),
                                                                    11,
                                                                    FontWeight.w600))),
                                                        Container(
                                                            margin:
                                                                const EdgeInsets.only(
                                                                    left: 7),
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 7,
                                                                vertical: 2),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        4),
                                                                color: theme.isDarkMode
                                                                    ? const Color(0xff666666)
                                                                        .withOpacity(
                                                                            .2)
                                                                    : const Color(0xff999999)
                                                                        .withOpacity(
                                                                            .2)),
                                                            child: Text(
                                                                "${orderBook[itemIndex].prctyp}",
                                                                style: textStyle(
                                                                    const Color(0xff666666),
                                                                    11,
                                                                    FontWeight.w600)))
                                                      ],
                                                    ),
                                                    Text(
                                                        " (${orderBook[itemIndex].perChange ?? 0.00}%)",
                                                        style: textStyle(
                                                            orderBook[itemIndex]
                                                                    .perChange!
                                                                    .startsWith(
                                                                        "-")
                                                                ? colors.darkred
                                                                : orderBook[itemIndex]
                                                                            .perChange ==
                                                                        "0.00"
                                                                    ? colors
                                                                        .ltpgrey
                                                                    : colors
                                                                        .ltpgreen,
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2),
                                                          decoration:
                                                              BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          4),
                                                                  color: theme
                                                                          .isDarkMode
                                                                      ? orderBook[itemIndex].trantype ==
                                                                              "S"
                                                                          ? colors.darkred.withOpacity(
                                                                              .2)
                                                                          : colors.ltpgreen.withOpacity(
                                                                              .2)
                                                                      : Color(orderBook[itemIndex].trantype == "S"
                                                                          ? 0xffFCF3F3
                                                                          : 0xffECF8F1)),
                                                          child: Text(orderBook[itemIndex].trantype == "S" ? "SELL" : "BUY",
                                                              style: textStyle(
                                                                  orderBook[itemIndex].trantype == "S"
                                                                      ? colors.darkred
                                                                      : colors.ltpgreen,
                                                                  12,
                                                                  FontWeight.w600))),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                          formatDateTime(
                                                                  value: orderBook[
                                                                          itemIndex]
                                                                      .norentm!)
                                                              .substring(
                                                                  13, 21),
                                                          style: textStyle(
                                                              const Color(
                                                                  0xff666666),
                                                              12,
                                                              FontWeight.w500))
                                                    ]),
                                                    Row(children: [
                                                      Text("Qty: ",
                                                          style: textStyle(
                                                              const Color(
                                                                  0xff5E6B7D),
                                                              14,
                                                              FontWeight.w500)),
                                                      Text(
                                                        "${((orderBook[itemIndex].status != "COMPLETE" && (orderBook[itemIndex].fillshares?.isNotEmpty ?? false) ? (int.tryParse(orderBook[itemIndex].fillshares.toString()) ?? 0) : orderBook[itemIndex].status == "COMPLETE" ? (int.tryParse(orderBook[itemIndex].rqty.toString()) ?? 0) : (int.tryParse(orderBook[itemIndex].dscqty.toString()) ?? 0)).toInt() / (orderBook[itemIndex].exch == 'MCX' ? (int.tryParse(orderBook[itemIndex].ls.toString()) ?? 1) : 1)).toInt()}/${((int.tryParse(orderBook[itemIndex].qty.toString()) ?? 0) / (orderBook[itemIndex].exch == 'MCX' ? (int.tryParse(orderBook[itemIndex].ls.toString()) ?? 1) : 1)).toInt()}",
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            14,
                                                            FontWeight.w500),
                                                      )
                                                    ])
                                                  ]),
                                              const SizedBox(height: 10),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      SvgPicture.asset(orderBook[
                                                                      itemIndex]
                                                                  .status ==
                                                              "COMPLETE"
                                                          ? assets.completedIcon
                                                          : orderBook[itemIndex]
                                                                          .status ==
                                                                      "CANCELED" ||
                                                                  orderBook[itemIndex]
                                                                          .status ==
                                                                      "REJECTED"
                                                              ? assets
                                                                  .cancelledIcon
                                                              : assets
                                                                  .warningIcon),
                                                      Text(
                                                          " ${orderBook[itemIndex].status![0].toUpperCase()}${orderBook[itemIndex].status!.toLowerCase().replaceAll("_", " ").substring(1)}  ",
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              13,
                                                              FontWeight.w500)),
                                                    ]),
                                                    Row(children: [
                                                      Text("Prc: ",
                                                          style: textStyle(
                                                              const Color(
                                                                  0xff5E6B7D),
                                                              14,
                                                              FontWeight.w500)),
                                                      Text(
                                                          "${orderBook[itemIndex].avgprc ?? orderBook[itemIndex].prc ?? 0.00}",
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              14,
                                                              FontWeight.w500)),
                                                      if (orderBook[itemIndex]
                                                                  .prctyp ==
                                                              "SL-LMT" ||
                                                          orderBook[itemIndex]
                                                                  .prctyp ==
                                                              "SL-MKT") ...[
                                                        const SizedBox(
                                                            child: Text(' / ')),
                                                        Text("TP: ",
                                                            style: textStyle(
                                                                const Color(
                                                                    0xff5E6B7D),
                                                                14,
                                                                FontWeight
                                                                    .w500)),
                                                        Text(
                                                            "${orderBook[itemIndex].trgprc ?? 0.00}",
                                                            style: textStyle(
                                                                theme.isDarkMode
                                                                    ? colors
                                                                        .colorWhite
                                                                    : colors
                                                                        .colorBlack,
                                                                14,
                                                                FontWeight
                                                                    .w500))
                                                      ]
                                                    ])
                                                  ])
                                            ]))
                                    : Container());
                          },
                          itemCount: orderBook.length * 2 - 1,
                        )
                      : const SizedBox(height: 500, child: NoDataFound())
                  : searchorder.isNotEmpty
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: false,
                          itemBuilder: (context, index) {
                            final itemIndex = index ~/ 2;

                            if (socketDatas
                                .containsKey(searchorder[itemIndex].token)) {
                              searchorder[itemIndex].ltp =
                                  "${socketDatas["${searchorder[itemIndex].token}"]['lp']}";
                              searchorder[itemIndex].perChange =
                                  "${socketDatas["${searchorder[itemIndex].token}"]['pc']}";
                            }
                            if (index.isOdd) {
                              return Container(
                                  color: theme.isDarkMode
                                      ? colors.darkGrey
                                      : const Color(0xffF1F3F8),
                                  height: 6);
                            }
                            return InkWell(
                                onTap: () async {
                                  await context
                                      .read(marketWatchProvider)
                                      .fetchLinkeScrip(
                                          "${orderBook[index].token}",
                                          "${searchorder[itemIndex].exch}",
                                          context);

                                  await watch(marketWatchProvider)
                                      .fetchScripQuote(
                                          "${searchorder[itemIndex].token}",
                                          "${searchorder[itemIndex].exch}",
                                          context);
                                  context.read(orderProvider).fetchOrderHistory(
                                      "${searchorder[itemIndex].norenordno}",
                                      context);
                                  if ((searchorder[itemIndex].exch == "NSE" ||
                                          searchorder[itemIndex].exch ==
                                              "BSE") &&
                                      (searchorder[itemIndex]
                                              .instname
                                              .toString() !=
                                          "UNDIND")) {
                                    context
                                        .read(marketWatchProvider)
                                        .depthBtns
                                        .add({
                                      "btnName": "Fundamental",
                                      "imgPath": assets.dInfo,
                                      "key": context
                                          .read(showcaseProvide)
                                          .fundamentalcase,
                                      "case":
                                          "Click here to view fundamental data."
                                    });

                                    await context
                                        .read(marketWatchProvider)
                                        .fetchTechData(
                                            context: context,
                                            exch:
                                                "${searchorder[itemIndex].exch}",
                                            tradeSym:
                                                "${searchorder[itemIndex].tsym}",
                                            lastPrc:
                                                "${searchorder[itemIndex].ltp ?? searchorder[itemIndex].c ?? 0.00}");
                                  }
                                  Navigator.pushNamed(
                                      context, Routes.orderDetail,
                                      arguments: searchorder[itemIndex]);
                                },
                                child: searchorder[itemIndex].status != null
                                    ? Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      Text(
                                                          "${searchorder[itemIndex].symbol} ",
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
                                                      Text(
                                                          "${searchorder[itemIndex].option} ",
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
                                                    ]),
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
                                                            "₹${searchorder[itemIndex].ltp ?? searchorder[itemIndex].close ?? 0.00}",
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

                                                    // SvgPicture.asset(
                                                    //     assets.rightArrowIcon)
                                                  ]),
                                              const SizedBox(height: 4),
                                              Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CustomExchBadge(
                                                            exch:
                                                                "${searchorder[itemIndex].exch}"),
                                                        Text(
                                                            " ${searchorder[itemIndex].expDate} ",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: textStyles
                                                                .scripExchTxtStyle
                                                                .copyWith(
                                                                    color: theme.isDarkMode
                                                                        ? colors
                                                                            .colorWhite
                                                                        : colors
                                                                            .colorBlack))
                                                      ],
                                                    ),
                                                    Text(
                                                        " (${searchorder[itemIndex].perChange ?? 0.00}%)",
                                                        style: textStyle(
                                                            searchorder[itemIndex]
                                                                    .perChange!
                                                                    .startsWith(
                                                                        "-")
                                                                ? colors.darkred
                                                                : searchorder[itemIndex]
                                                                            .perChange ==
                                                                        "0.00"
                                                                    ? colors
                                                                        .ltpgrey
                                                                    : colors
                                                                        .ltpgreen,
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2),
                                                          decoration:
                                                              BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          4),
                                                                  color: theme
                                                                          .isDarkMode
                                                                      ? searchorder[itemIndex].trantype ==
                                                                              "S"
                                                                          ? colors.darkred.withOpacity(
                                                                              .2)
                                                                          : colors.ltpgreen.withOpacity(
                                                                              .2)
                                                                      : Color(searchorder[itemIndex].trantype == "S"
                                                                          ? 0xffFCF3F3
                                                                          : 0xffECF8F1)),
                                                          child: Text(searchorder[itemIndex].trantype == "S" ? "SELL" : "BUY",
                                                              style: textStyle(
                                                                  searchorder[itemIndex].trantype == "S"
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
                                                                      .withOpacity(
                                                                          .2)
                                                                  : const Color(0xff999999)
                                                                      .withOpacity(
                                                                          .2)),
                                                          child: Text(
                                                              "${searchorder[itemIndex].sPrdtAli}",
                                                              style: textStyle(
                                                                  const Color(0xff666666),
                                                                  11,
                                                                  FontWeight.w600)))
                                                    ]),
                                                    Row(children: [
                                                      Text("Qty: ",
                                                          style: textStyle(
                                                              const Color(
                                                                  0xff5E6B7D),
                                                              14,
                                                              FontWeight.w500)),
                                                      Text(
                                                          "${searchorder[itemIndex].status == "COMPLETE" ? searchorder[itemIndex].rqty ?? 0 : searchorder[itemIndex].dscqty ?? 0}/${searchorder[itemIndex].qty ?? 0}",
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              14,
                                                              FontWeight.w500))
                                                    ])
                                                  ]),
                                              const SizedBox(height: 10),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      SvgPicture.asset(orderBook[
                                                                      index]
                                                                  .status ==
                                                              "COMPLETE"
                                                          ? assets.completedIcon
                                                          : searchorder[itemIndex]
                                                                          .status ==
                                                                      "CANCELED" ||
                                                                  searchorder[itemIndex]
                                                                          .status ==
                                                                      "REJECTED"
                                                              ? assets
                                                                  .cancelledIcon
                                                              : assets
                                                                  .warningIcon),
                                                      Text(
                                                          " ${searchorder[itemIndex].status![0].toUpperCase()}${searchorder[itemIndex].status!.toLowerCase().replaceAll("_", " ").substring(1)}  ",
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              13,
                                                              FontWeight.w500)),
                                                      Text(
                                                          formatDateTime(
                                                              value: searchorder[
                                                                      itemIndex]
                                                                  .norentm!),
                                                          style: textStyle(
                                                              const Color(
                                                                  0xff666666),
                                                              12,
                                                              FontWeight.w500))
                                                    ]),
                                                    Row(children: [
                                                      Text("Price: ",
                                                          style: textStyle(
                                                              const Color(
                                                                  0xff5E6B7D),
                                                              14,
                                                              FontWeight.w500)),
                                                      Text(
                                                          "${searchorder[itemIndex].avgprc ?? searchorder[itemIndex].prc ?? 0.00}",
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              14,
                                                              FontWeight.w500))
                                                    ])
                                                  ])
                                            ]))
                                    : Container());
                          },
                          itemCount: searchorder.length * 2 - 1,
                        )
                      : Container()),
        )
      ]),
    );
  }
}
