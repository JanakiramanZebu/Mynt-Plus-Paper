// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/list_divider.dart';

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

              return Material(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                child: InkWell(
                    // borderRadius: BorderRadius.circular(6),
                    splashColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.15)
                        : Colors.black.withOpacity(0.15),
                    highlightColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
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
                      // Add delay for visual feedback
                      await Future.delayed(const Duration(milliseconds: 150));

                      Navigator.pop(context);
                      await ref
                          .watch(marketWatchProvider)
                          .calldepthApis(context, displayData, "");
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      dense: false,
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${displayData.symbol}",
                              style: TextWidget.textStyle(
                                  fontSize: 14,
                                  fw: 0,
                                  color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                                  theme: theme.isDarkMode,
                                  ),
                            ),
                           
                            if (displayData.option!.isNotEmpty)
                              Text(
                                "${displayData.option}",
                                style: TextWidget.textStyle(
                        fontSize: 14,
                        fw: 0,
                       color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                                            ),
                              )
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                           padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                TextWidget.paraText(
                                    text: "${displayData.exch}",
                                    color:  theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                    ),
                                if (displayData.expDate!.isNotEmpty)
                                  TextWidget.paraText(
                                      text: " ${displayData.expDate}",
                                      color: theme.isDarkMode ? colors.textSecondaryDark :  colors.textSecondaryLight,
                                      theme: theme.isDarkMode,
                                      fw: 0,
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                            child: TextWidget.titleText(
                                text:
                                    "₹${displayData.ltp ?? displayData.close ?? 0.00}",
                                    color: displayData.change!.startsWith("-") ||
                                        displayData.perChange!.startsWith('-')
                                    ?  theme.isDarkMode ? colors.lossDark : colors.lossLight
                                    : (displayData.change == "null" ||
                                                displayData.perChange ==
                                                    "null") ||
                                            (displayData.change == "0.00" ||
                                                displayData.perChange == "0.00")
                                        ? theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight
                                        : theme.isDarkMode ? colors.profitDark : colors.profitLight,
                                theme: theme.isDarkMode,
                                fw: 0,
                                ),
                          ),
                          
                          Padding(
                             padding: const EdgeInsets.only(top: 4),
                            child: TextWidget.paraText(
                                text:
                                    "${displayData.change == "null" ? "0.00 " : double.parse("${displayData.change}").toStringAsFixed(2)} "
                                    "${displayData.perChange == "null" ? "(0.00%)" : "(${displayData.perChange ?? 0.00}%)"}",
                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                theme: theme.isDarkMode,
                                fw: 0,
                                ),
                          ),
                        ],
                      ),
                    )),
              );
            },
          );
        });
  }
}
