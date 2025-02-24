import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/snack_bar.dart';
import 'edit_scrip.dart';

class WatchlistCard extends ConsumerWidget {
  final dynamic watchListData;
  const WatchlistCard({super.key, required this.watchListData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final marketWatch = watch(marketWatchProvider);
    // final socketDatas = watch(websocketProvider).socketDatas;
    final theme = context.read(themeProvider);

    if (context
        .read(websocketProvider)
        .socketDatas
        .containsKey(watchListData['token'])) {
      watchListData['ltp'] =
          "${context.read(websocketProvider).socketDatas["${watchListData['token']}"]['lp'] ?? 0.00}";
      watchListData['change'] =
          "${context.read(websocketProvider).socketDatas["${watchListData['token']}"]['chng'] ?? 0.00}";
      watchListData['perChange'] =
          "${context.read(websocketProvider).socketDatas["${watchListData['token']}"]['pc'] ?? 0.00}";
      watchListData['close'] =
          "${context.read(websocketProvider).socketDatas["${watchListData['token']}"]['c'] ?? 0.00}";

      //  log("dfgdf ${context.read(websocketProvider).socketDatas["${watchListData['token']}"]['holdQty']}");

      watchListData["holdingQty"] =
          "${context.read(websocketProvider).socketDatas["${watchListData['token']}"]['holdQty']}";
    }
    return ListTile(
        onLongPress: () {
          if (marketWatch.isPreDefWLs == "Yes") {
            ScaffoldMessenger.of(context).showSnackBar(warningMessage(context,
                "This is a pre-defined watchlist that cannot be edited!"));
          } else {
            context
                .read(marketWatchProvider)
                .requestMWScrip(context: context, isSubscribe: false);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditScrip(wlName: marketWatch.wlName)));
          }
        },
        onTap: () async {
          await marketWatch.calldepthApis(context, watchListData, "");
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("${watchListData["symbol"].toString().toUpperCase()} ",
                style: textStyles.scripNameTxtStyle.copyWith(
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack)),
            if (watchListData["option"].toString().isNotEmpty)
              Text("${watchListData["option"]}",
                  style: textStyles.scripNameTxtStyle
                      .copyWith(color: const Color(0xff666666))),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(
              children: [
                CustomExchBadge(exch: '${watchListData["exch"]}'),
                if (watchListData['expDate'].toString().isNotEmpty)
                  Text(" ${watchListData['expDate']}  ",
                      style: textStyles.scripExchTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
                if (watchListData['holdingQty'] != "") ...[
                  SvgPicture.asset(assets.suitcase,
                      height: 12,
                      width: 16,
                      color: theme.isDarkMode
                          ? colors.colorLightBlue
                          : colors.colorBlue),
                  Text(" ${watchListData['holdingQty']}",
                      style: textStyles.scripExchTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue,
                          fontWeight: FontWeight.w600))
                ]
              ],
            ),
          ],
        ),
        trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("₹${watchListData['ltp'] ?? 0.00}",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                "${watchListData["change"] == "null" ? 0.00 : watchListData['change']} (${watchListData['perChange'] == "null" ? 0.00 : watchListData["perChange"]}%)",
                style: textStyle(
                    watchListData['change'].toString().startsWith("-") ||
                            watchListData['perChange']
                                .toString()
                                .startsWith('-')
                        ? colors.darkred
                        : (watchListData['change'].toString() == "null" ||
                                    watchListData['perChange'].toString() ==
                                        "null") ||
                                (watchListData['change'].toString() == "0.00" ||
                                    watchListData['perChange'].toString() ==
                                        "0.00")
                            ? colors.ltpgrey
                            : colors.ltpgreen,
                    12,
                    FontWeight.w600),
              )
            ]));
  }
}
