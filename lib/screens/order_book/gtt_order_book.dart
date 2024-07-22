import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../models/order_book_model/gtt_order_book.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/shocase_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart'; 

class GttOrderBook extends ConsumerWidget {
  final List<GttOrderBookModel> gttOrderBook;
  const GttOrderBook({super.key, required this.gttOrderBook});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final socketDatas = watch(websocketProvider).socketDatas;
    final theme = context.read(themeProvider);
    return gttOrderBook.isNotEmpty
        ? Column(children: [
            // if (gttOrderBook.length > 1)
            //   Container(
            //     decoration:   BoxDecoration(
            //             color: theme.isDarkMode?colors.colorBlack:colors.colorWhite,
            //             border: Border(
            //                 bottom: BorderSide(
            //                     color:  theme.isDarkMode?colors.darkGrey: Color(0xffF1F3F8), width: 6))),
            //          child: Padding(
            //           padding: const EdgeInsets.only(
            //               left: 16, right: 2, top: 8, bottom: 8),
            //           child: Row(
            //               mainAxisAlignment: MainAxisAlignment.end,
            //               children: [
            //                 Row(children: [
            //                   InkWell(
            //                       onTap: () async {
            //                         FocusScope.of(context).unfocus();
            //                         // showModalBottomSheet(
            //                         //     showDragHandle: true,
            //                         //     useSafeArea: true,
            //                         //     isScrollControlled: true,
            //                         //     shape: const RoundedRectangleBorder(
            //                         //         borderRadius:
            //                         //             BorderRadius.vertical(
            //                         //                 top:
            //                         //                     Radius.circular(16))),
            //                         //     backgroundColor:
            //                         //         const Color(0xffffffff),
            //                         //     context: context,
            //                         //     builder: (context) {
            //                         //       return OrderbookFilterBottomSheet();
            //                         //     });
            //                       },
            //                       child: Padding(
            //                           padding: const EdgeInsets.only(right: 12),
            //                           child: SvgPicture.asset(
            //                               assets.filterLines,
            //                               color: const Color(0xff333333)))),
            //                   // InkWell(
            //                   //     onTap: () {
            //                   //       order.showOrderSearch(true);
            //                   //     },
            //                   //     child: Padding(
            //                   //         padding: const EdgeInsets.only(
            //                   //             right: 12, left: 10),
            //                   //         child: SvgPicture.asset(
            //                   //             assets.searchIcon,
            //                   //             width: 19,
            //                   //             color: const Color(0xff333333))))
            //                 ])
            //               ]))),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  if (socketDatas.containsKey(gttOrderBook[index].token)) {
                    gttOrderBook[index].ltp =
                        "${socketDatas["${gttOrderBook[index].token}"]['lp']}";
                    gttOrderBook[index].perChange =
                        "${socketDatas["${gttOrderBook[index].token}"]['pc']}";
                  }
                  return InkWell(
                      onTap: () async {
                        await context.read(marketWatchProvider).fetchLinkeScrip(
                            "${gttOrderBook[index].token}",
                            "${gttOrderBook[index].exch}",context);

                        await watch(marketWatchProvider).fetchScripQuote(
                            "${gttOrderBook[index].token}",
                            "${gttOrderBook[index].exch}",
                            context);

                        if ((gttOrderBook[index].exch == "NSE" ||
                            gttOrderBook[index].exch == "BSE")) {
                          context.read(marketWatchProvider).depthBtns.add({
                            "btnName": "Fundamental",
                            "imgPath": assets.dInfo,
                            "key":
                                context.read(showcaseProvide).fundamentalcase,
                            "case": "Click here to view fundamental data."
                          });

                          await context.read(marketWatchProvider).fetchTechData(
                              context: context,
                              exch: "${gttOrderBook[index].exch}",
                              tradeSym: "${gttOrderBook[index].tsym}",
                              lastPrc: "${gttOrderBook[index].prc}");
                        }

                        Navigator.pushNamed(context, Routes.gttOrderDetail,
                            arguments: gttOrderBook[index]);
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
                                        Text("${gttOrderBook[index].symbol} ",
                                            overflow: TextOverflow.ellipsis,
                                            style: textStyles.scripNameTxtStyle
                                                .copyWith(
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack)),
                                        Text("${gttOrderBook[index].option} ",
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
                                          if (socketDatas.containsKey(
                                              gttOrderBook[index].token)) ...[
                                            Text(
                                                "₹${gttOrderBook[index].ltp ?? gttOrderBook[index].close ?? 0.00}",
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
                                                  "${gttOrderBook[index].exch}"),
                                          Text(
                                              " ${gttOrderBook[index].expDate} ",
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                             decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                            4),
                                                        color: theme.isDarkMode
                                                            ? Color(gttOrderBook[index].trantype == "S" ? 0XFFf44336 : 0xff43A833)
                                                                .withOpacity(.2)
                                                            : Color(gttOrderBook[index].trantype == "S"
                                                                ? 0xffFCF3F3
                                                                : 0xffECF8F1)),
                                            child: Text(
                                                gttOrderBook[index].trantype == "S"
                                                    ? "SELL"
                                                    : "BUY",
                                                style: textStyle(
                                                   gttOrderBook[index].trantype == "S" ? colors.darkred : colors.ltpgreen,
                                                    12,
                                                    FontWeight.w600))),
                                        Container(
                                            margin:
                                                const EdgeInsets.only(left: 7),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                             decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        color: theme.isDarkMode
                                                            ? Color(0xff666666)
                                                                .withOpacity(.2)
                                                            : Color(0xff999999)
                                                                .withOpacity(
                                                                    .2)),
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
                                        Text("${gttOrderBook[index].qty ?? 0}",
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
              ),
            )
          ])
        : const NoDataFound();
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
