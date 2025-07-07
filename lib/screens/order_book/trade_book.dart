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
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';
import 'filter_trade_book.dart';
import 'package:mynt_plus/res/global_state_text.dart';

class TradeBook extends ConsumerWidget {
  List<TradeBookModel> tradeBook;
  TradeBook({super.key, required this.tradeBook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final order = ref.watch(orderProvider);
    return Column(children: [
      // if (order.tradeBook!.length > 1)
      //   Container(
      //       decoration: BoxDecoration(
      //           color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      //           border: Border(
      //               bottom: BorderSide(
      //                   color: theme.isDarkMode
      //                       ? colors.darkGrey
      //                       : const Color(0xffF1F3F8),
      //                   width: 6))),
      //       child: Padding(
      //           padding: const EdgeInsets.only(
      //               left: 16, right: 2, top: 8, bottom: 8),
      //           child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      //             Row(children: [
      //               InkWell(
      //                   onTap: () async {
      //                     FocusScope.of(context).unfocus();
      //                     showModalBottomSheet(
      //                         useSafeArea: true,
      //                         isScrollControlled: true,
      //                         shape: const RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.vertical(
      //                                 top: Radius.circular(16))),
      //                         context: context,
      //                         builder: (context) {
      //                           return const OrderbookTradeBookFilterBottomSheet();
      //                         });
      //                   },
      //                   child: Padding(
      //                       padding: const EdgeInsets.only(right: 12),
      //                       child: SvgPicture.asset(assets.filterLines,
      //                           color: const Color(0xff333333)))),
      //               InkWell(
      //                   onTap: () {
      //                     order.showTradeSearch(true);
      //                   },
      //                   child: Padding(
      //                       padding: const EdgeInsets.only(right: 12, left: 10),
      //                       child: SvgPicture.asset(assets.searchIcon,
      //                           width: 19, color: const Color(0xff333333))))
      //             ])
      //           ]))),
      // // if (order.showtradebookSearch)
      //   Container(
        //   height: 62,
        //   padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        //   decoration: BoxDecoration(
        //       border: Border(
        //           bottom: BorderSide(
        //               color: theme.isDarkMode
        //                   ? colors.darkGrey
        //                   : const Color(0xffF1F3F8),
        //               width: 6))),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: TextFormField(
        //           textCapitalization: TextCapitalization.characters,
        //           inputFormatters: [UpperCaseTextFormatter()],
        //           controller: order.orderTradebookCtrl,
        //           style: TextWidget.textStyle(
        //               fontSize: 16, 
        //               theme: theme.isDarkMode,
        //               color: const Color(0xff000000), 
        //               fw: 1),
        //           decoration: InputDecoration(
        //               fillColor: const Color(0xffF1F3F8),
        //               filled: true,
        //               hintStyle: TextWidget.textStyle(
        //                   fontSize: 15, 
        //                   theme: theme.isDarkMode,
        //                   color: const Color(0xff69758F), 
        //                   fw: 5),
        //               prefixIconColor: const Color(0xff586279),
        //               prefixIcon: Padding(
        //                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
        //                 child: SvgPicture.asset(assets.searchIcon,
        //                     color: const Color(0xff586279),
        //                     fit: BoxFit.contain,
        //                     width: 20),
        //               ),
        //               suffixIcon: InkWell(
        //                 onTap: () async {
        //                   order.clearTradeBookSearch();
        //                 },
        //                 child: Padding(
        //                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
        //                   child: SvgPicture.asset(assets.removeIcon,
        //                       fit: BoxFit.scaleDown, width: 20),
        //                 ),
        //               ),
        //               enabledBorder: OutlineInputBorder(
        //                   borderSide: BorderSide.none,
        //                   borderRadius: BorderRadius.circular(20)),
        //               disabledBorder: InputBorder.none,
        //               focusedBorder: OutlineInputBorder(
        //                   borderSide: BorderSide.none,
        //                   borderRadius: BorderRadius.circular(20)),
        //               hintText: "Search Scrip Name",
        //               contentPadding: const EdgeInsets.only(top: 20),
        //               border: OutlineInputBorder(
        //                   borderSide: BorderSide.none,
        //                   borderRadius: BorderRadius.circular(20))),
        //           onChanged: (value) async {
        //             order.orderTradeBookSearch(value, context);
        //           },
        //         ),
        //       ),
        //       TextButton(
        //           onPressed: () {
        //             order.showTradeSearch(false);
        //             order.clearTradeBookSearch();
        //           },
        //           child: TextWidget.subText(
        //               text: "Close", 
        //               theme: theme.isDarkMode,
        //               color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
        //               fw: 0))
        //     ],
        //   ),
        // ),
      Expanded(
          child: RefreshIndicator(
        onRefresh: () async {
          order.fetchOrderBook(context, true);
          order.fetchTradeBook(context);
        },
        child: order.tradeBooksearch!.isEmpty
            ? tradeBook.isNotEmpty
                ? ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: false,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () async {
                            await ref
                                .read(marketWatchProvider)
                                .fetchLinkeScrip(
                                    "${tradeBook[index].token}",
                                    "${tradeBook[index].exch}",
                                    context);

                            await ref.watch(marketWatchProvider).fetchScripQuote(
                                "${tradeBook[index].token}",
                                "${tradeBook[index].exch}",
                                context);

                            if ((tradeBook[index].exch == "NSE" ||
                                tradeBook[index].exch == "BSE")) {
                              await ref
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xffEEEEEE), width: 1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: Symbol + Expiry | Order Number
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // SYMBOL + EXPIRY + OPTION
                                    Expanded(
                                      child: TextWidget.subText(
                                        text: "${tradeBook[index].symbol?.replaceAll("-EQ", "")} ${tradeBook[index].expDate} ${tradeBook[index].option ?? ''}",
                                        theme: theme.isDarkMode,
                                        fw: 3,
                                        maxLines: 1,
                                        textOverflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    
                                    // Order Number
                                    TextWidget.paraText(
                                      text: "Order: ${tradeBook[index].norenordno ?? ''}",
                                      theme: false,
                                      color: const Color(0xff666666),
                                      fw: 0,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Row 2: Exchange - Time | Fill ID
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextWidget.paraText(
                                        text: "${tradeBook[index].exch} - ${formatDateTime(value: tradeBook[index].norentm!).substring(12, 21)}",
                                        theme: false,
                                        color: const Color(0xff666666),
                                        fw: 00,
                                      ),
                                    ),
                                    TextWidget.paraText(
                                      text: "Fill ID: ${tradeBook[index].flid ?? ''}",
                                      theme: false,
                                      color: const Color(0xff666666),
                                      fw: 0,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Row 3: BUY/SELL + Product + Price Type | Avg Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // BUY/SELL Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: theme.isDarkMode
                                                ? Color(tradeBook[index].trantype == "S" ? 0XFFf44336 : 0xff43A833).withOpacity(.2)
                                                : Color(tradeBook[index].trantype == "S" ? 0xffFCF3F3 : 0xffECF8F1),
                                          ),
                                          child: TextWidget.paraText(
                                            text: tradeBook[index].trantype == "S" ? "SELL" : "BUY",
                                            theme: false,
                                            color: tradeBook[index].trantype == "S" ? colors.darkred : colors.ltpgreen,
                                            fw: 1,
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 8),
                                        
                                        // Product Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: theme.isDarkMode
                                                ? const Color(0xff666666).withOpacity(.2)
                                                : const Color(0xff999999).withOpacity(.2),
                                          ),
                                          child: TextWidget.paraText(
                                            text: "${tradeBook[index].sPrdtAli}",
                                            theme: false,
                                            color: const Color(0xff666666),
                                            fw: 1,
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 8),
                                        
                                        // Price Type Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: theme.isDarkMode
                                                ? const Color(0xff666666).withOpacity(.2)
                                                : const Color(0xff999999).withOpacity(.2),
                                          ),
                                          child: TextWidget.paraText(
                                            text: "${tradeBook[index].prctyp}",
                                            theme: false,
                                            color: const Color(0xff666666),
                                            fw: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Avg Price
                                    TextWidget.subText(
                                      text: "₹${tradeBook[index].avgprc ?? '0.00'}",
                                      color: const Color(0xff666666),
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Row 4: Fill Qty | Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        TextWidget.paraText(
                                          text: "Qty: ",
                                          theme: false,
                                          color: const Color(0xff5E6B7D),
                                          fw: 1,
                                        ),
                                        TextWidget.subText(
                                          text: "${((int.tryParse(tradeBook[index].flqty.toString()) ?? 0) / (tradeBook[index].exch == 'MCX' ? (int.tryParse(tradeBook[index].ls.toString()) ?? 1) : 1)).toInt()}",
                                          color: const Color(0xff666666),
                                          theme: theme.isDarkMode,
                                          fw: 00,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        TextWidget.paraText(
                                          text: "Price: ",
                                          theme: false,
                                          color: const Color(0xff5E6B7D),
                                          fw: 1,
                                        ),
                                        TextWidget.subText(
                                          text: "₹${tradeBook[index].prc ?? '0.00'}",
                                          color: const Color(0xff666666),
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ));
                    },
                    itemCount: tradeBook.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                          color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                          height: 1);
                    },
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(height: MediaQuery.of(context).size.height * 0.7, child: const NoDataFound()))
            : order.tradeBooksearch!.isNotEmpty
                ? ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: false,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () async {
                            await ref
                                .read(marketWatchProvider)
                                .fetchLinkeScrip(
                                    "${order.tradeBooksearch![index].token}",
                                    "${order.tradeBooksearch![index].exch}",
                                    context);

                            await ref.watch(marketWatchProvider).fetchScripQuote(
                                "${order.tradeBooksearch![index].token}",
                                "${order.tradeBooksearch![index].exch}",
                                context);

                            if ((order.tradeBooksearch![index].exch == "NSE" ||
                                order.tradeBooksearch![index].exch == "BSE")) {
                              await ref.read(marketWatchProvider).fetchTechData(
                                  context: context,
                                  exch: "${order.tradeBooksearch![index].exch}",
                                  tradeSym: "${order.tradeBooksearch![index].tsym}",
                                  lastPrc: "${order.tradeBooksearch![index].prc}");
                            }
                            Navigator.pushNamed(context, Routes.tradeDetail,
                                arguments: order.tradeBooksearch![index]);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xffEEEEEE), width: 1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: Symbol + Expiry | Order Number
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // SYMBOL + EXPIRY + OPTION
                                    Expanded(
                                      child: TextWidget.subText(
                                        text: "${order.tradeBooksearch![index].symbol?.replaceAll("-EQ", "")} ${order.tradeBooksearch![index].expDate} ${order.tradeBooksearch![index].option ?? ''}",
                                        theme: theme.isDarkMode,
                                        fw: 3,
                                        maxLines: 1,
                                        textOverflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    
                                    // Order Number
                                    TextWidget.paraText(
                                      text: "Order: ${order.tradeBooksearch![index].norenordno ?? ''}",
                                      theme: false,
                                      color: const Color(0xff666666),
                                      fw: 0,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Row 2: Exchange - Time | Fill ID
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextWidget.paraText(
                                        text: "${order.tradeBooksearch![index].exch} - ${formatDateTime(value: order.tradeBooksearch![index].norentm!).substring(12, 21)}",
                                        theme: false,
                                        color: const Color(0xff666666),
                                        fw: 00,
                                      ),
                                    ),
                                    TextWidget.paraText(
                                      text: "Fill ID: ${order.tradeBooksearch![index].flid ?? ''}",
                                      theme: false,
                                      color: const Color(0xff666666),
                                      fw: 0,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Row 3: BUY/SELL + Product + Price Type | Avg Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // BUY/SELL Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: theme.isDarkMode
                                                ? Color(order.tradeBooksearch![index].trantype == "S" ? 0XFFf44336 : 0xff43A833).withOpacity(.2)
                                                : Color(order.tradeBooksearch![index].trantype == "S" ? 0xffFCF3F3 : 0xffECF8F1),
                                          ),
                                          child: TextWidget.paraText(
                                            text: order.tradeBooksearch![index].trantype == "S" ? "SELL" : "BUY",
                                            theme: false,
                                            color: order.tradeBooksearch![index].trantype == "S" ? colors.darkred : colors.ltpgreen,
                                            fw: 1,
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 8),
                                        
                                        // Product Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: theme.isDarkMode
                                                ? const Color(0xff666666).withOpacity(.2)
                                                : const Color(0xff999999).withOpacity(.2),
                                          ),
                                          child: TextWidget.paraText(
                                            text: "${order.tradeBooksearch![index].sPrdtAli}",
                                            theme: false,
                                            color: const Color(0xff666666),
                                            fw: 1,
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 8),
                                        
                                        // Price Type Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: theme.isDarkMode
                                                ? const Color(0xff666666).withOpacity(.2)
                                                : const Color(0xff999999).withOpacity(.2),
                                          ),
                                          child: TextWidget.paraText(
                                            text: "${order.tradeBooksearch![index].prctyp}",
                                            theme: false,
                                            color: const Color(0xff666666),
                                            fw: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Avg Price
                                    TextWidget.subText(
                                      text: "₹${order.tradeBooksearch![index].avgprc ?? '0.00'}",
                                      color: const Color(0xff666666),
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Row 4: Fill Qty | Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        TextWidget.paraText(
                                          text: "Qty: ",
                                          theme: false,
                                          color: const Color(0xff5E6B7D),
                                          fw: 1,
                                        ),
                                        TextWidget.subText(
                                          text: "${order.tradeBooksearch![index].flqty ?? 0}",
                                          color: const Color(0xff666666),
                                          theme: theme.isDarkMode,
                                          fw: 00,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        TextWidget.paraText(
                                          text: "Price: ",
                                          theme: false,
                                          color: const Color(0xff5E6B7D),
                                          fw: 1,
                                        ),
                                        TextWidget.subText(
                                          text: "₹${order.tradeBooksearch![index].prc ?? '0.00'}",
                                          color: const Color(0xff666666),
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ));
                    },
                    itemCount: order.tradeBooksearch!.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                          color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                          height: 1);
                    },
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(height: MediaQuery.of(context).size.height * 0.7)
                  ),
      ))
    ]);
  }
}
