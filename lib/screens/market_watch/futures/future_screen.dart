// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/list_divider.dart';

class FutureScreen extends ConsumerWidget {
  const FutureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);
    
    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};
        
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: future.fut!.length,
          separatorBuilder: (BuildContext context, int index) {
            return const ListDivider();
          },
          itemBuilder: (BuildContext context, int index) {
            // Create a local copy of the data to avoid modifying original
            var displayData = future.fut![index];
            
            // Update with socket data if available
            if (socketDatas.containsKey(displayData.token)) {
              final socketData = socketDatas[displayData.token];
              // Only update with valid values
              final lp = socketData['lp']?.toString();
              if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
                displayData.ltp = lp;
              }
              
              final chng = socketData['chng']?.toString();
              if (chng != null && chng != "null") {
                displayData.change = chng;
              }
              
              final pc = socketData['pc']?.toString();
              if (pc != null && pc != "null") {
                displayData.perChange = pc;
              }
            }
            
            return InkWell(
              onLongPress: () async {
                await future.addDelMarketScrip(
                  future.wlName,
                  "${displayData.exch}|${displayData.token}",
                  context,
                  true,
                  true,
                  false,
                  true);
              },
              onTap: () async {
                Navigator.pop(context);
                await ref.watch(marketWatchProvider)
                    .calldepthApis(context, displayData, "");
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                dense: true,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${displayData.symbol} ",
                        style: textStyles.scripNameTxtStyle.copyWith(
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack)),
                    if (displayData.option!.isNotEmpty)
                      Text("${displayData.option}",
                          style: textStyles.scripNameTxtStyle
                              .copyWith(color: const Color(0xff666666))),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text("${displayData.exch}  ",
                            style: textStyles.scripExchTxtStyle),
                        if (displayData.expDate!.isNotEmpty)
                          Text("${displayData.expDate}  ",
                              style: textStyles.scripExchTxtStyle
                                  .copyWith(color: colors.colorBlack)),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "₹${displayData.ltp ?? displayData.close ?? 0.00}",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      "${displayData.change == "null" ? "0.00 " : double.parse("${displayData.change}").toStringAsFixed(2)} "
                      "${displayData.perChange == "null" ? "(0.00%)" : "(${displayData.perChange ?? 0.00}%)"}",
                      style: textStyle(
                          displayData.change!.startsWith("-") ||
                                  displayData.perChange!.startsWith('-')
                              ? colors.darkred
                              : (displayData.change == "null" ||
                                          displayData.perChange ==
                                              "null") ||
                                      (displayData.change == "0.00" ||
                                          displayData.perChange == "0.00")
                                  ? colors.ltpgrey
                                  : colors.ltpgreen,
                          12,
                          FontWeight.w600),
                    ),
                  ],
                ),
              )
            );
          },
        );
      }
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
