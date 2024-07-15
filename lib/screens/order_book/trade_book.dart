// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../models/order_book_model/trade_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/shocase_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart'; 
import '../../sharedWidget/no_data_found.dart';
import 'trade_book_list_card.dart';

class TradeBook extends ConsumerWidget {
  List<TradeBookModel> tradeBook;
  TradeBook({super.key, required this.tradeBook});

  @override
  Widget build(BuildContext context, ScopedReader watch) {    final theme = context.read(themeProvider);
    final order = watch(orderProvider);
    return tradeBook.isNotEmpty
        ? RefreshIndicator(
            onRefresh: () async {
              order.fetchOrderBook(context, true);
              order.fetchTradeBook(context);
            },
            child: Column(children: [
              // Container(
              //   decoration: const BoxDecoration(
              //       color: Color(0xffFFFFFF),
              //       border: Border(
              //           bottom:
              //               BorderSide(color: Color(0xffF1F3F8), width: 6))),
              //   child: ListTile(
              //     contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              //     dense: true,
              //     title: Text("${tradeBook.length} Order · List by you",
              //         style: textStyle(
              //             const Color(0xff666666), 12, FontWeight.w600)),
              //   ),
              // ),
              Expanded(
                  child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () async {
                        await context.read(marketWatchProvider).fetchLinkeScrip(
                            "${tradeBook[index].token}",
                            "${tradeBook[index].exch}");

                        await watch(marketWatchProvider).fetchScripQuote(
                            "${tradeBook[index].token}",
                            "${tradeBook[index].exch}",
                            context);

                        if ((tradeBook[index].exch == "NSE" ||
                            tradeBook[index].exch == "BSE")) {
                          context.read(marketWatchProvider).depthBtns.add({
                            "btnName": "Fundamental",
                            "imgPath": assets.dInfo,
                            "key":
                                context.read(showcaseProvide).fundamentalcase,
                            "case": "Click here to view fundamental data."
                          });

                          await context.read(marketWatchProvider).fetchTechData(
                              context: context,
                              exch: "${tradeBook[index].exch}",
                              tradeSym: "${tradeBook[index].tsym}",
                              lastPrc: "${tradeBook[index].prc}");
                        }
                        Navigator.pushNamed(context, Routes.tradeDetail,
                            arguments: tradeBook[index]);
                      },
                      child: TradeBookList(orderBookList: tradeBook[index]));
                },
                itemCount: tradeBook.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                          color: theme.isDarkMode?colors.darkGrey: const Color(0xffF1F3F8), height: 6);
                },
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
