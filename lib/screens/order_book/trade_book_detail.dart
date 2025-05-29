import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_book_model/trade_book_model.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/scrip_info_btns.dart';

class TradeBookDetail extends ConsumerWidget {
  final TradeBookModel tradeData;
  const TradeBookDetail({super.key, required this.tradeData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    
    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        // Create a copy of trade data to avoid directly modifying the original
        var displayData = tradeData;
        
        // Update with WebSocket data if available
        final socketDatas = snapshot.data ?? {};
        if (socketDatas.containsKey(tradeData.token)) {
          final socketData = socketDatas[tradeData.token];
          
          // Only update with non-zero values
          final lp = socketData['lp']?.toString();
          if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
            displayData.ltp = lp;
          }
          
          final pc = socketData['pc']?.toString();
          if (pc != null && pc != "null" && pc != "0" && pc != "0.00") {
            displayData.perChange = pc;
          }
          
          final chng = socketData['chng']?.toString();
          if (chng != null && chng != "null") {
            displayData.change = chng;
          }
        }
        
        return Scaffold(
          appBar: AppBar(
              elevation: .2,
              leadingWidth: 41,
              centerTitle: false,
              titleSpacing: 6,
              leading: const CustomBackBtn(),
              title:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("${displayData.symbol}",
                            style: textStyles.appBarTitleTxt.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack)),
                        Text(" ${displayData.option} ",
                            overflow: TextOverflow.ellipsis,
                            style: textStyles.scripNameTxtStyle.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack)),
                      ],
                    ),
                    Text("₹${displayData.ltp}",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(children: [
                        CustomExchBadge(exch: displayData.exch!),
                        Text("  ${displayData.expDate}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                12,
                                FontWeight.w600))
                      ]),
                      Text(
                          "${double.parse("${displayData.change != "null" ? displayData.change ?? 0.00 : 0.0} ").toStringAsFixed(2)} (${displayData.perChange ?? 0.00}%)",
                          style: textStyle(
                              (displayData.change == "null" ||
                                          displayData.change == null) ||
                                      displayData.change == "0.00"
                                  ? colors.ltpgrey
                                  : displayData.change!.startsWith("-") ||
                                          displayData.perChange!.startsWith("-")
                                      ? colors.darkred
                                      : colors.ltpgreen,
                              12,
                              FontWeight.w500))
                    ])
              ])),
          body: ListView(
            children: [
              ScripInfoBtns(
                  exch: '${displayData.exch}',
                  token: '${displayData.token}',
                  insName: '',
                  tsym: '${displayData.tsym}'),
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
                            displayData.trantype == "B" ? "Buy" : "Sell",
                            "Price Type",
                            "${displayData.prctyp}",
                            theme),
                        const SizedBox(height: 4),
                        rowOfInfoData(
                            "Price", "${displayData.avgprc}", "", "", theme),
                        const SizedBox(height: 4),
                        rowOfInfoData("Filled Qty", "${displayData.flqty}", "Fill Id",
                            displayData.flid ?? "-", theme),
                        const SizedBox(height: 4),
                        rowOfInfoData("Validity", "${displayData.ret}", "Product",
                            "${displayData.sPrdtAli}", theme),
                        const SizedBox(height: 4),

                        rowOfInfoData(
                            "Order Id",
                            "${displayData.norenordno}",
                            "Date & Time",
                            formatDateTime(value: displayData.norentm!),
                            theme),
                        //
                      ])),
            ],
          ),
        );
      },
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
