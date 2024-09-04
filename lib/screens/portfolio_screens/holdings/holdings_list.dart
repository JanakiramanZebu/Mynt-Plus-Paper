import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/portfolio_model/holdings_model.dart';

import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';

class HoldingsList extends StatelessWidget {
  final HoldingsModel holdingData;
  final ExchTsym exchTsym;
  const HoldingsList(
      {super.key, required this.holdingData, required this.exchTsym});

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    return Container(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("${exchTsym.tsym} ",
                overflow: TextOverflow.ellipsis,
                style: textStyles.scripNameTxtStyle.copyWith(
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack)),
            Row(children: [
              Text(" LTP: ",
                  style:
                      textStyle(const Color(0xff5E6B7D), 13, FontWeight.w600)),
              Text("₹${exchTsym.lp}",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500))
            ])
          ]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CustomExchBadge(exch: "${exchTsym.exch}"),
            Text(" (${exchTsym.perChange}%)",
                style: textStyle(
                    exchTsym.perChange!.startsWith("-")
                        ? colors.darkred
                        : exchTsym.perChange == "0.00"
                            ? colors.ltpgrey
                            : colors.ltpgreen,
                    12,
                    FontWeight.w500))
          ]),
          const SizedBox(height: 4),
          Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider),
          const SizedBox(height: 3),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text("Qty: ",
                  style:
                      textStyle(const Color(0xff5E6B7D), 14, FontWeight.w500)),
              Text(
                  "${holdingData.currentQty ?? 0} @ ₹${holdingData.upldprc ?? exchTsym.close ?? 0.00}",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500)),
              if (holdingData.npoadqty.toString() != "null") ...[
                Text(" NPQ",
                    style:
                        textStyle(const Color(0xff666666), 12, FontWeight.w500))
              ],
              if (holdingData.btstqty != "0")
                Text(" T1: ${holdingData.btstqty}",
                    style:
                        textStyle(const Color(0xff666666), 12, FontWeight.w500))
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text("₹${exchTsym.profitNloss}",
                  style: textStyle(
                      exchTsym.profitNloss!.startsWith("-")
                          ? colors.darkred
                          : colors.ltpgreen,
                      14,
                      FontWeight.w500)),
              Text(" (${exchTsym.pNlChng == "NaN" ? 0.0 : exchTsym.pNlChng}%)",
                  style: textStyle(
                      exchTsym.pNlChng!.startsWith("-")
                          ? colors.darkred
                          : exchTsym.pNlChng == "NaN"
                              ? colors.darkred
                              : colors.ltpgreen,
                      12,
                      FontWeight.w500))
            ])
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Text("Inv: ",
                  style:
                      textStyle(const Color(0xff5E6B7D), 14, FontWeight.w500)),
              Text(
                  "₹${getFormatter(value: double.parse("${holdingData.invested == "0.00" ? exchTsym.close ?? 0.00 : holdingData.invested ?? 0.00}"), v4d: false, noDecimal: false)}",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500))
            ]),
            Row(children: [
              Text("Cur: ",
                  style:
                      textStyle(const Color(0xff5E6B7D), 14, FontWeight.w500)),
              Text(
                  "₹${getFormatter(value: double.parse("${holdingData.currentValue ?? 0.00}"), v4d: false, noDecimal: false)}",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500))
            ])
          ])
        ]));
  }
}
