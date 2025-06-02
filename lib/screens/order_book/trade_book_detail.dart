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
        
        // Ensure initial values are not null (using safe defaults)
        if (displayData.ltp == null || displayData.ltp == "null" || displayData.ltp == "0" || displayData.ltp == "0.00") {
          // Try to use any available price in a specific priority order
          if (displayData.avgprc != null && displayData.avgprc != "null" && displayData.avgprc != "0" && displayData.avgprc != "0.00") {
            displayData.ltp = displayData.avgprc;
          } else if (displayData.prc != null && displayData.prc != "null" && displayData.prc != "0" && displayData.prc != "0.00") {
            displayData.ltp = displayData.prc;
          } else {
            // If no valid price is available, use a default
            displayData.ltp = "0.00";
          }
        }
        
        // Update with WebSocket data if available
        final socketDatas = snapshot.data ?? {};
        if (socketDatas.containsKey(displayData.token)) {
          final socketData = socketDatas[displayData.token];
          
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
        
        // Safety: ensure percent change is not null
        if (displayData.perChange == null || displayData.perChange == "null") {
          displayData.perChange = "0.00";
        }
        
        // Safety: ensure change is not null
        if (displayData.change == null || displayData.change == "null") {
          displayData.change = "0.00";
        }
        
        // Format the LTP for display (handles null safely)
        String formattedLTP = "0.00";
        if (displayData.ltp != null && displayData.ltp != "null") {
          final ltpValue = double.tryParse(displayData.ltp!) ?? 0.0;
          formattedLTP = ltpValue.toStringAsFixed(2);
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
                        Text("${displayData.symbol ?? ''}",
                            style: textStyles.appBarTitleTxt.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack)),
                        Text(" ${displayData.option ?? ''} ",
                            overflow: TextOverflow.ellipsis,
                            style: textStyles.scripNameTxtStyle.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack)),
                      ],
                    ),
                    Text("₹$formattedLTP",
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
                        CustomExchBadge(exch: displayData.exch ?? ""),
                        Text("  ${displayData.expDate ?? ''}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                12,
                                FontWeight.w600))
                      ]),
                      _buildChangeIndicator(displayData, theme)
                    ])
              ])),
          body: ListView(
            children: [
              ScripInfoBtns(
                  exch: '${displayData.exch ?? ""}',
                  token: '${displayData.token ?? ""}',
                  insName: '',
                  tsym: '${displayData.tsym ?? ""}'),
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
                            "${displayData.prctyp ?? ''}",
                            theme),
                        const SizedBox(height: 4),
                        rowOfInfoData(
                            "Price", 
                            displayData.avgprc != null && displayData.avgprc != "null" 
                                ? displayData.avgprc! 
                                : displayData.prc != null && displayData.prc != "null"
                                    ? displayData.prc!
                                    : "0.00", 
                            "", "", theme),
                        const SizedBox(height: 4),
                        rowOfInfoData("Filled Qty", "${displayData.flqty ?? ''}", "Fill Id",
                            displayData.flid ?? "-", theme),
                        const SizedBox(height: 4),
                        rowOfInfoData("Validity", "${displayData.ret ?? ''}", "Product",
                            "${displayData.sPrdtAli ?? ''}", theme),
                        const SizedBox(height: 4),

                        rowOfInfoData(
                            "Order Id",
                            "${displayData.norenordno ?? ''}",
                            "Date & Time",
                            displayData.norentm != null 
                                ? formatDateTime(value: displayData.norentm!)
                                : "-",
                            theme),
                        //
                      ])),
            ],
          ),
        );
      },
    );
  }

  // Extracted method to build the change indicator with proper null handling
  Widget _buildChangeIndicator(TradeBookModel data, ThemesProvider theme) {
    final changeValue = data.change != null && data.change != "null" 
        ? double.tryParse(data.change!) ?? 0.0 
        : 0.0;
    
    final formattedChange = changeValue.toStringAsFixed(2);
    final formattedPercentage = data.perChange ?? "0.00";
    
    final isNegative = changeValue < 0 || (data.perChange != null && data.perChange!.startsWith("-"));
    final isZero = changeValue == 0 || formattedChange == "0.00";
    
    final textColor = isZero 
        ? colors.ltpgrey 
        : isNegative 
            ? colors.darkred 
            : colors.ltpgreen;
    
    return Text(
        "$formattedChange ($formattedPercentage%)",
        style: textStyle(textColor, 12, FontWeight.w500)
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
