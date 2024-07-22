import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../models/order_book_model/trade_book_model.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';  
class TradeBookList extends ConsumerWidget {
  final TradeBookModel orderBookList;
  const TradeBookList({super.key, required this.orderBookList});

  @override
  Widget build(BuildContext context, ScopedReader watch) {        final theme = context.read(themeProvider);
    return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Text("${orderBookList.symbol} ",
                      overflow: TextOverflow.ellipsis,
                            style: textStyles.scripNameTxtStyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack)),
                  Text("${orderBookList.option} ",
                      overflow: TextOverflow.ellipsis,
                          style: textStyles.scripNameTxtStyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack))
                ]),
                SvgPicture.asset(assets.rightArrowIcon)
              ]),
              const SizedBox(height: 4),
              Row(children: [
CustomExchBadge(exch: "${orderBookList.exch}"),

                
                Text(" ${orderBookList.expDate} ",
                    overflow: TextOverflow.ellipsis,
                      style: textStyles.scripExchTxtStyle
                        .copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack))
              ]),
              const SizedBox(height: 3),
                Divider(color: theme.isDarkMode?colors.darkColorDivider:colors.colorDivider),
              const SizedBox(height: 3),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                            4),
                                                        color: theme.isDarkMode
                                                            ? Color(orderBookList.trantype == "S" ? 0XFFf44336 : 0xff43A833)
                                                                .withOpacity(.2)
                                                            : Color(orderBookList.trantype == "S"
                                                                ? 0xffFCF3F3
                                                                : 0xffECF8F1)),
                      child: Text(
                          orderBookList.trantype == "S" ? "SELL" : "BUY",
                          style: textStyle(
                              orderBookList.trantype == "S"
                                  ? colors.darkred
                                  : colors.ltpgreen,
                              12,
                              FontWeight.w600))),
                  Container(
                    margin: const EdgeInsets.only(left: 7),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                    child: Text("${orderBookList.sPrdtAli}",
                        style: textStyle(
                            const Color(0xff666666), 12, FontWeight.w600)),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 7),
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
                      child: Text("${orderBookList.prctyp}",
                          style: textStyle(
                              const Color(0xff666666), 12, FontWeight.w600)))
                ]),
                Row(children: [
                  Text("Prc: ",
                      style: textStyle(
                          const Color(0xff5E6B7D), 14, FontWeight.w500)),
                  Text("₹${orderBookList.prc ?? 0.00}",
                      style: textStyle(
                      theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500))
                ])
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Text("Fill Qty: ",
                      style: textStyle(
                          const Color(0xff5E6B7D), 14, FontWeight.w500)),
                  Text("${orderBookList.flqty ?? 0}",
                      style: textStyle(
                      theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500))
                ]),
                Row(children: [
                  Text("Avg.Price: ",
                      style: textStyle(
                          const Color(0xff5E6B7D), 14, FontWeight.w500)),
                  Text("${orderBookList.avgprc ?? 0.00}",
                      style: textStyle(
                       theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500))
                ])
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Text("Fill Id: ",
                      style: textStyle(
                          const Color(0xff5E6B7D), 14, FontWeight.w500)),
                  Text("${orderBookList.flid ?? 0}",
                      style: textStyle(
                       theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500))
                ]),
                Text(formatDateTime(value: orderBookList.norentm!),
                    style:
                        textStyle(const Color(0xff666666), 12, FontWeight.w500))
              ])
            ]));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
