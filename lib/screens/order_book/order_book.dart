import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 

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
    final order = watch(orderProvider);        final theme = context.read(themeProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    return orderBook.isNotEmpty
        ? RefreshIndicator(
            onRefresh: () async {
              order.fetchOrderBook(context, true);
              order.fetchTradeBook(context);
            },
            child: Column(children: [
              if (orderBook.length > 1)
                Container(
                    decoration:   BoxDecoration(
                        color: theme.isDarkMode?colors.colorBlack:colors.colorWhite,
                        border: Border(
                            bottom: BorderSide(
                                color:  theme.isDarkMode?colors.darkGrey: const Color(0xffF1F3F8), width: 6))),
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
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(16))),
                                         
                                          context: context,
                                          builder: (context) {
                                            return const OrderbookFilterBottomSheet();
                                          });
                                    },
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: SvgPicture.asset(
                                            assets.filterLines,
                                            color: const Color(0xff333333)))),
                                // InkWell(
                                //     onTap: () {
                                //       order.showOrderSearch(true);
                                //     },
                                //     child: Padding(
                                //         padding: const EdgeInsets.only(
                                //             right: 12, left: 10),
                                //         child: SvgPicture.asset(
                                //             assets.searchIcon,
                                //             width: 19,
                                //             color: const Color(0xff333333))))
                              ])
                            ]))),
              if (order.showSearchHold)
                Container(
                  height: 62,
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  decoration:   BoxDecoration(
                      
                      border: Border(
                          bottom:
                              BorderSide(color:  theme.isDarkMode?colors.darkGrey: const Color(0xffF1F3F8), width: 6))),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: order.orderSearchCtrl,
                          style: textStyle(
                              const Color(0xff000000), 16, FontWeight.w600),
                          decoration: InputDecoration(
                              fillColor: const Color(0xffF1F3F8),
                              filled: true,
                              hintStyle: GoogleFonts.inter(
                                  textStyle: textStyle(const Color(0xff69758F),
                                      15, FontWeight.w500)),
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
                                  order.clearOrderSearch();
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

              // if(order.orderBookSearchItem!.isEmpty)
              Expanded(
                  child: SingleChildScrollView(  physics: const BouncingScrollPhysics(),
                child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (socketDatas.containsKey(orderBook[index].token)) {
                        orderBook[index].ltp =
                            "${socketDatas["${orderBook[index].token}"]['lp']}";
                        orderBook[index].perChange =
                            "${socketDatas["${orderBook[index].token}"]['pc']}";
                      }

                      return InkWell(
                          onTap: () async {
                            await context
                                .read(marketWatchProvider)
                                .fetchLinkeScrip("${orderBook[index].token}",
                                    "${orderBook[index].exch}");

                            await watch(marketWatchProvider).fetchScripQuote(
                                "${orderBook[index].token}",
                                "${orderBook[index].exch}",
                                context);
                            context.read(orderProvider).fetchOrderHistory(
                                "${orderBook[index].norenordno}", context);
                            if ((orderBook[index].exch == "NSE" ||
                                    orderBook[index].exch == "BSE") &&
                                (orderBook[index].instname.toString() !=
                                    "UNDIND")) {
                              context.read(marketWatchProvider).depthBtns.add({
                                "btnName": "Fundamental",
                                "imgPath": assets.dInfo,
                                "key": context
                                    .read(showcaseProvide)
                                    .fundamentalcase,
                                "case": "Click here to view fundamental data."
                              });

                              await context.read(marketWatchProvider).fetchTechData(
                                  context: context,
                                  exch: "${orderBook[index].exch}",
                                  tradeSym: "${orderBook[index].tsym}",
                                  lastPrc:
                                      "${orderBook[index].ltp ?? orderBook[index].c ?? 0.00}");
                            }
                            Navigator.pushNamed(context, Routes.orderDetail,
                                arguments: orderBook[index]);
                          },
                          child: orderBook[index].status != null
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                Text(
                                                    "${orderBook[index].symbol} ",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: textStyles
                                                        .scripNameTxtStyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack)),
                                                Text(
                                                    "${orderBook[index].option} ",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: textStyles
                                                        .scripNameTxtStyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack)),
                                              ]),
                                              Row(
                                                children: [
                                                  Text(" LTP: ",
                                                      style: textStyle(
                                                          const Color(
                                                              0xff5E6B7D),
                                                          13,
                                                          FontWeight.w600)),
                                                  Text(
                                                      "₹${orderBook[index].ltp ?? orderBook[index].close ?? 0.00}",
                                                      style: textStyle(
                                                        theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                                                          14,
                                                          FontWeight.w500)),
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                   CustomExchBadge(exch: "${orderBook[index].exch}"),
                                                
                                                  Text(
                                                      " ${orderBook[index].expDate} ",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: textStyles
                                                          .scripExchTxtStyle
                                                          .copyWith(
                                                              color: theme.isDarkMode?colors.colorWhite:colors.colorBlack))
                                                ],
                                              ),
                                              Text(
                                                  " (${orderBook[index].perChange ?? 0.00}%)",
                                                  style: textStyle(
                                                      Color(orderBook[index]
                                                              .perChange!
                                                              .startsWith("-")
                                                          ? 0XFFFF1717
                                                          : orderBook[index]
                                                                      .perChange ==
                                                                  "0.00"
                                                              ? 0xff666666
                                                              : 0xff43A833),
                                                      12,
                                                      FontWeight.w500)),
                                            ]),
                                        const SizedBox(height: 4),
                                      Divider(color:theme.isDarkMode?colors.darkColorDivider:colors.colorDivider),
                                        const SizedBox(height: 2),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        border: Border.all(
                                                            color: Color(orderBook[index].trantype == "S"
                                                                ? 0xffFFCDCD
                                                                : 0xffC1E7BA)),
                                                        color: Color(orderBook[index].trantype == "S"
                                                            ? 0xffFCF3F3
                                                            : 0xffECF8F1)),
                                                    child: Text(orderBook[index].trantype == "S" ? "SELL" : "BUY",
                                                        style: textStyle(
                                                            Color(orderBook[index].trantype == "S" ? 0xffFF1717 : 0xff43A833),
                                                            12,
                                                            FontWeight.w600))),
                                                Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 7),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 7,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xffF1F3F8))),
                                                    child: Text(
                                                        "${orderBook[index].sPrdtAli}",
                                                        style: textStyle(
                                                            const Color(
                                                                0xff666666),
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
                                                    "${orderBook[index].status == "COMPLETE" ? orderBook[index].rqty ?? 0 : orderBook[index].dscqty ?? 0}/${orderBook[index].qty ?? 0}",
                                                    style: textStyle(
                                                       theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                                                        14,
                                                        FontWeight.w500))
                                              ])
                                            ]),
                                        const SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                SvgPicture.asset(orderBook[
                                                                index]
                                                            .status ==
                                                        "COMPLETE"
                                                    ? assets.completedIcon
                                                    : orderBook[index].status ==
                                                                "CANCELED" ||
                                                            orderBook[index]
                                                                    .status ==
                                                                "REJECTED"
                                                        ? assets.cancelledIcon
                                                        : assets.warningIcon),
                                                Text(
                                                    " ${orderBook[index].status![0].toUpperCase()}${orderBook[index].status!.toLowerCase().replaceAll("_", " ").substring(1)}  ",
                                                    style: textStyle(
                                                      theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                                                        13,
                                                        FontWeight.w500)),
                                                Text(
                                                    formatDateTime(
                                                        value: orderBook[index]
                                                            .norentm!),
                                                    style: textStyle(
                                                        const Color(0xff666666),
                                                        12,
                                                        FontWeight.w500))
                                              ]),
                                              Row(children: [
                                                Text("Price: ",
                                                    style: textStyle(
                                                        const Color(0xff5E6B7D),
                                                        14,
                                                        FontWeight.w500)),
                                                Text(
                                                    "${orderBook[index].avgprc ?? orderBook[index].prc ?? 0.00}",
                                                    style: textStyle(
                                                    theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                                                        14,
                                                        FontWeight.w500))
                                              ])
                                            ])
                                      ]))

                              //  OrderBookList(orderBookList: orderBook[index])
                              : Container());
                    },
                    itemCount: orderBook.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                          color: theme.isDarkMode?colors.darkGrey: const Color(0xffF1F3F8), height: 6);
                    }),
              ))
            ]),
          )
        : const NoDataFound();
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
