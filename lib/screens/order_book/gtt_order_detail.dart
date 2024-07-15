import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:google_fonts/google_fonts.dart'; 
  import '../../models/order_book_model/gtt_order_book.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
  import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/scrip_info_btns.dart'; 

class GttOrderDetail extends ConsumerWidget {
  final GttOrderBookModel gttOrderBook;
  const GttOrderDetail({super.key, required this.gttOrderBook});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
   final scripInfo = watch(marketWatchProvider);        final theme = context.read(themeProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    if (socketDatas.containsKey(gttOrderBook.token)) {
      gttOrderBook.ltp = "${socketDatas["${gttOrderBook.token}"]['lp']}";
      gttOrderBook.perChange = "${socketDatas["${gttOrderBook.token}"]['pc']}";

      gttOrderBook.change = "${socketDatas["${gttOrderBook.token}"]['chng']}";
    }
    return Scaffold(
        appBar: AppBar(
            elevation: .2,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: const CustomBackBtn(),
            shadowColor: const Color(0xffECEFF3),
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("${gttOrderBook.symbol}",
                          style: textStyles.appBarTitleTxt.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack)),
                      Text(" ${gttOrderBook.option} ",
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.scripNameTxtStyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack)),
                    ],
                  ),
                  Text("₹${gttOrderBook.ltp}",
                      style: textStyle(
                         theme.isDarkMode?colors.colorWhite:colors.colorBlack, 16, FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                     CustomExchBadge(exch: "${gttOrderBook.exch}"),
                      Text("  ${gttOrderBook.expDate}",
                          style: textStyle(
                              theme.isDarkMode?colors.colorWhite:colors.colorBlack, 12, FontWeight.w600))
                    ]),
                    Text(
                        "${double.parse("${gttOrderBook.change ?? 0.00} ").toStringAsFixed(2)} (${gttOrderBook.perChange ?? 0.00}%)",
                        style: textStyle(
                            Color((gttOrderBook.change == "null" ||
                                        gttOrderBook.change == null) ||
                                    gttOrderBook.change == "0.00"
                                ? 0xff999999
                                : gttOrderBook.change!.startsWith("-") ||
                                        gttOrderBook.perChange!.startsWith("-")
                                    ? 0xffFF1717
                                    : 0xff43A833),
                            12,
                            FontWeight.w500))
                  ])
            ])),
       
        body: ListView(
          children: [
            ScripInfoBtns(
                exch: '${gttOrderBook.exch}',
                token: '${gttOrderBook.token}',
                insName: ''),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order details",
                      style: textStyle(
                          theme.isDarkMode?colors.colorWhite:colors.colorBlack, 16, FontWeight.w600)),
                  const SizedBox(height: 16),
                  rowOfInfoData(
                      "Transaction Type",
                      gttOrderBook.trantype == "B" ? "Buy" : "Sell",
                      "Price Type",
                      "${gttOrderBook.prctyp}",theme),
                  const SizedBox(height: 4),
                  rowOfInfoData("Price", "${gttOrderBook.prc}", "Qty",
                      "${gttOrderBook.qty}",theme),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            // ScripInfoBtns(
            //     exch: '${gttOrderBook.exch}',
            //     token: '${gttOrderBook.token}',
            //     insName: ''),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
   
            shape: const CircularNotchedRectangle(),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await scripInfo.fetchScripInfo("${gttOrderBook.token}",
                            "${gttOrderBook.exch}", context);
                        Navigator.pop(context);

                        Navigator.pushNamed(context, Routes.modifyGtt,
                            arguments: {
                              "gttOrderBook": gttOrderBook,
                              "scripInfo": context
                                  .read(marketWatchProvider)
                                  .scripInfoModel!
                            });
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(color:theme.isDarkMode?colors.colorWhite:colors.colorBlack,),
                            borderRadius: BorderRadius.circular(108)),
                        child: Center(
                          child: Text("Modify Order",
                              style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14,
                                  FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog( backgroundColor:theme.isDarkMode? const Color.fromARGB(255, 18, 18, 18):colors.colorWhite,
                                          
                              titleTextStyle: textStyle(
                                  theme.isDarkMode?colors.colorWhite:colors.colorBlack, 17, FontWeight.w600),
                              contentTextStyle: textStyle(
                                  const Color(0XFF666666), 14, FontWeight.w500),
                              titlePadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14))),
                              scrollable: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              insetPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              title: Row(
                                children: [
                                  Text("${gttOrderBook.tsym}"),
                                   CustomExchBadge(exch: "${gttOrderBook.exch}")
                                ],
                              ),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Do you want to Cancel this order?")
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "No",
                                      style: textStyle(theme.isDarkMode?colors.colorLightBlue:colors.colorBlue,
                                          14, FontWeight.w500),
                                    )),
                                ElevatedButton( style: ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                         theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    )),
                                    onPressed: () async {
                                      await context
                                          .read(orderProvider)
                                          .fetchGttCancelOrder(
                                              "${gttOrderBook.alId}", context);
                                    },
                                    child: Text(
                                      "Yes",
                                      style: textStyle(theme.isDarkMode?colors.colorBlack:colors.colorBlack,
                                          14, FontWeight.w500),
                                    )),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                            borderRadius: BorderRadius.circular(108)),
                        child: Center(
                          child: Text("Cancel Order",
                              style: textStyle(!theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14,
                                  FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ]))));
  }

  Row rowOfInfoData(
      String title1, String value1, String title2, String value2, ThemesProvider theme) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title1,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value1,
            style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
        const SizedBox(height: 2),
        Divider(color:theme.isDarkMode?colors.darkColorDivider: colors.colorDivider)
      ])),
      const SizedBox(width: 24),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title2,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value2,
          style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Divider(color:theme.isDarkMode?colors.darkColorDivider: colors.colorDivider)
      ]))
    ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
