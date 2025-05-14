import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/portfolio_model/holdings_model.dart';

import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
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
    
    return StreamBuilder<Map>(
      stream: context.read(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};
        
        // Update exchTsym with real-time values if available
        if (socketDatas.containsKey(exchTsym.token)) {
          final lp = socketDatas[exchTsym.token]['lp']?.toString();
          final pc = socketDatas[exchTsym.token]['pc']?.toString();
          final chng = socketDatas[exchTsym.token]['chng']?.toString();
          final c = socketDatas[exchTsym.token]['c']?.toString();
          
          if (lp != null && lp != "null") {
            exchTsym.lp = lp;
          }
          
          if (pc != null && pc != "null") {
            exchTsym.perChange = pc;
          }
          
          if (chng != null && chng != "null") {
            exchTsym.change = chng;
          }
          
          if (c != null && c != "null") {
            exchTsym.close = c;
          }
          
          // Calculate other values based on updated data
          if (exchTsym.lp != null && exchTsym.close != null) {
            final ltp = double.tryParse(exchTsym.lp ?? "0.0") ?? 0.0;
            final close = double.tryParse(exchTsym.close ?? "0.0") ?? 0.0;
            
            if (ltp > 0 && close > 0) {
              // Update currentValue in holdingData
              final qty = int.tryParse(holdingData.currentQty.toString()) ?? 0;
              holdingData.currentValue = (qty * ltp).toStringAsFixed(2);
            }
          }
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${exchTsym.tsym} ",
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.scripNameTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
                  Row(
                    children: [
                      Text(" LTP: ",
                          style: textStyle(const Color(0xff5E6B7D), 13, FontWeight.w600)),
                      Text("₹${exchTsym.lp}",
                          style: textStyle(
                              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                              14,
                              FontWeight.w500))
                    ]
                  )
                ]
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                ]
              ),
              const SizedBox(height: 4),
              Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Qty: ",
                          style: textStyle(const Color(0xff5E6B7D), 14, FontWeight.w500)),
                      Text(
                          "${holdingData.currentQty ?? 0} @ ₹${holdingData.upldprc ?? exchTsym.close ?? 0.00}",
                          style: textStyle(
                              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                      if (holdingData.npoadqty.toString() != "null") ...[
                        Text(" NPQ",
                            style: textStyle(const Color(0xff666666), 12, FontWeight.w500))
                      ],
                      if (holdingData.btstqty != "0")
                        Text(" T1: ${holdingData.btstqty}",
                            style: textStyle(const Color(0xff666666), 12, FontWeight.w500))
                    ]
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                    ]
                  )
                ]
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("Inv: ",
                          style: textStyle(const Color(0xff5E6B7D), 14, FontWeight.w500)),
                      Text(
                          "₹${getFormatter(value: double.parse("${holdingData.invested == "0.00" ? exchTsym.close ?? 0.00 : holdingData.invested ?? 0.00}"), v4d: false, noDecimal: false)}",
                          style: textStyle(
                              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                              14,
                              FontWeight.w500))
                    ]
                  ),
                  Row(
                    children: [
                      Text("Cur: ",
                          style: textStyle(const Color(0xff5E6B7D), 14, FontWeight.w500)),
                      Text(
                          "₹${getFormatter(value: double.parse("${holdingData.currentValue ?? 0.00}"), v4d: false, noDecimal: false)}",
                          style: textStyle(
                              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                              14,
                              FontWeight.w500))
                    ]
                  )
                ]
              )
            ]
          )
        );
      }
    );
  }
  
  TextStyle textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
