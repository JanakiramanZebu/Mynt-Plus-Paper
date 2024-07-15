import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../models/order_book_model/trade_book_model.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/scrip_info_btns.dart'; 

class TradeBookDetail extends StatelessWidget {
  final TradeBookModel tradeData;
  const TradeBookDetail({super.key, required this.tradeData});

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    return Scaffold(
      appBar: AppBar(
          elevation: .2,
          leadingWidth: 41,
          centerTitle: false,
          titleSpacing: 6,
          leading: const CustomBackBtn(), 
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("${tradeData.symbol}",
                      style: textStyles.appBarTitleTxt.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
             CustomExchBadge(exch: "${tradeData.exch}")
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("₹${tradeData.prc ?? 0.00}",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          15,
                          FontWeight.w500)),
                ],
              )
            ],
          )),
      body: ListView(
        children: [
          ScripInfoBtns(
              exch: '${tradeData.exch}',
              token: '${tradeData.token}',
              insName: ''),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text("Order details",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600)),
                    const SizedBox(height: 16),
                    rowOfInfoData(
                        "Transaction Type",
                        tradeData.trantype == "B" ? "Buy" : "Sell",
                        "Price Type",
                        "${tradeData.prctyp}",
                        theme),
                    const SizedBox(height: 4),
                    rowOfInfoData("Price", "${tradeData.prc}", "Avg.Price",
                        "${tradeData.avgprc ?? 0.00}", theme),
                    const SizedBox(height: 4),
                    rowOfInfoData("Filled Qty", "${tradeData.flqty}", "Fill Id",
                        tradeData.flid ?? "-", theme),
                    const SizedBox(height: 4),
                    rowOfInfoData("Validity", "${tradeData.ret}", "Product",
                        "${tradeData.sPrdtAli}", theme),
                    const SizedBox(height: 4),

                    rowOfInfoData(
                        "Order Id",
                        "${tradeData.norenordno}",
                        "Date & Time",
                        formatDateTime(value: tradeData.norentm!),
                        theme),
                    //
                  ])),
        ],
      ),
    );
  }

  Row rowOfInfoData(
    String title1,
    String value1,
    String title2,
    String value2,
    ThemesProvider theme,
  ) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title1,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value1,
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w500)),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
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
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ]))
    ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
