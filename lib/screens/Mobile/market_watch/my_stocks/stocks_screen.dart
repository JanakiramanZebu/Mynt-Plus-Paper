import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_exch_badge.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../sharedWidget/snack_bar.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  int? hoveredIndex; // <-- Track hover index

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final holdingProvide = ref.watch(portfolioProvider).holdingsModel;
      final marketWatch = ref.watch(marketWatchProvider);
      final theme = ref.read(themeProvider);

      return ref.watch(portfolioProvider).loading
          ? const Center(child: CircularProgressIndicator())
          : holdingProvide!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextWidget.subText(
                          text: "No Holdings ",
                          color: colors.colorBlack,
                          theme: theme.isDarkMode,
                          align: TextAlign.center,
                          fw: 00),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 250,
                        child: TextWidget.paraText(
                            text:
                                "You haven't made any investments yet. Build your portfolio today!",
                            color: const Color(0xff666666),
                            theme: theme.isDarkMode,
                            align: TextAlign.center,
                            fw: 00),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: holdingProvide.length * 2 - 1,
                  itemBuilder: (BuildContext context, int idx) {
                    int index = idx ~/ 2;

                    if (idx.isOdd) {
                      return const ListDivider();
                    }

                    return StreamBuilder<Map>(
                        stream: ref.watch(websocketProvider).socketDataStream,
                        builder: (context, snapshot) {
                          final socketDatas = snapshot.data ?? {};

                          if (socketDatas.containsKey(
                              holdingProvide[index].exchTsym![0].token)) {
                            final socketData = socketDatas[
                                holdingProvide[index].exchTsym![0].token];

                            final lp = socketData['lp']?.toString();
                            if (lp != null &&
                                lp != "null" &&
                                lp != "0" &&
                                lp != "0.00") {
                              holdingProvide[index].exchTsym![0].lp = lp;
                            }

                            final chng = socketData['chng']?.toString();
                            if (chng != null && chng != "null") {
                              holdingProvide[index].exchTsym![0].change = chng;
                            }

                            final pc = socketData['pc']?.toString();
                            if (pc != null && pc != "null") {
                              holdingProvide[index].exchTsym![0].perChange = pc;
                            }

                            final c = socketData['c']?.toString();
                            if (c != null &&
                                c != "null" &&
                                c != "0" &&
                                c != "0.00") {
                              holdingProvide[index].exchTsym![0].close = c;
                            }
                          }

                          return MouseRegion(
                            onEnter: (_) =>
                                setState(() => hoveredIndex = index),
                            onExit: (_) => setState(() => hoveredIndex = null),
                            child: InkWell(
                              onLongPress: () {
                                if (marketWatch.isPreDefWLs == "Yes") {
                                  showResponsiveWarningMessage(context,
                                      "This is a pre-defined watchlist that cannot be edited!");
                                }
                              },
                              onTap: () async {
                                DepthInputArgs depthArgs = DepthInputArgs(
                                    exch: holdingProvide[index]
                                        .exchTsym![0]
                                        .exch
                                        .toString(),
                                    token: holdingProvide[index]
                                        .exchTsym![0]
                                        .token
                                        .toString(),
                                    tsym: holdingProvide[index]
                                        .exchTsym![0]
                                        .tsym
                                        .toString(),
                                    instname: holdingProvide[index]
                                        .exchTsym![0]
                                        .symbol
                                        .toString(),
                                    symbol: holdingProvide[index]
                                        .exchTsym![0]
                                        .symbol
                                        .toString(),
                                    expDate: "",
                                    option: "");
                                await marketWatch.calldepthApis(
                                    context, depthArgs, "");
                              },
                              child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  dense: false,
                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${holdingProvide[index].exchTsym![0].symbol} ",
                                          style: TextWidget.textStyle(
                                            fontSize: 14,
                                            color: theme.isDarkMode
                                                ? colors.textPrimaryDark
                                                : colors.textPrimaryLight,
                                            theme: theme.isDarkMode,
                                            fw: 0,
                                          ),
                                        ),
                                        if (holdingProvide[index]
                                            .exchTsym![0]
                                            .option!
                                            .isNotEmpty)
                                          Text(
                                            "${holdingProvide[index].exchTsym![0].option}",
                                            style: TextWidget.textStyle(
                                              fontSize: 14,
                                              color: theme.isDarkMode
                                                  ? colors.textPrimaryDark
                                                  : colors.textPrimaryLight,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            CustomExchBadge(
                                                exch:
                                                    "${holdingProvide[index].exchTsym![0].exch}"),
                                            if (holdingProvide[index]
                                                .exchTsym![0]
                                                .expDate!
                                                .isNotEmpty)
                                              TextWidget.paraText(
                                                text:
                                                    " ${holdingProvide[index].exchTsym![0].expDate}  ",
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                theme: theme.isDarkMode,
                                                fw: 0,
                                              ),
                                            const SizedBox(width: 6),
                                            SvgPicture.asset(assets.suitcase,
                                                height: 12,
                                                width: 16,
                                                color: theme.isDarkMode
                                                    ? colors.secondaryDark
                                                    : colors.secondaryLight),
                                            const SizedBox(width: 4),
                                            TextWidget.paraText(
                                              text:
                                                  "${holdingProvide[index].currentQty}",
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      hoveredIndex == index
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _buildHoverButton(
                                                  label: 'Buy',
                                                  color: theme.isDarkMode
                                                      ? colors.successDark
                                                      : colors.successLight,
                                                  onPressed: () async {
                                                    // Navigate to place order screen with Buy action
                                                  },
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                _buildHoverButton(
                                                  label: 'Sell',
                                                  color: theme.isDarkMode
                                                      ? colors.lossDark
                                                      : colors.lossLight,
                                                  onPressed: () async {
                                                    // Navigate to place order screen with Sell action
                                                  },
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                _buildHoverButton(
                                                  label: 'Chart',
                                                  color: theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors
                                                          .textSecondaryLight,
                                                  onPressed: () {},
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4),
                                            child: TextWidget.titleText(
                                              text:
                                                  "${holdingProvide[index].exchTsym![0].lp}",
                                              color: holdingProvide[index]
                                                          .exchTsym![0]
                                                          .change!
                                                          .startsWith("-") ||
                                                      holdingProvide[index]
                                                          .exchTsym![0]
                                                          .perChange!
                                                          .startsWith('-')
                                                  ? theme.isDarkMode
                                                      ? colors.lossDark
                                                      : colors.lossLight
                                                  : (holdingProvide[index]
                                                                      .exchTsym![
                                                                          0]
                                                                      .change ==
                                                                  "null" ||
                                                              holdingProvide[index]
                                                                      .exchTsym![
                                                                          0]
                                                                      .perChange ==
                                                                  "null") ||
                                                          (holdingProvide[index]
                                                                      .exchTsym![
                                                                          0]
                                                                      .change ==
                                                                  "0.00" ||
                                                              holdingProvide[
                                                                          index]
                                                                      .exchTsym![0]
                                                                      .perChange ==
                                                                  "0.00")
                                                      ? theme.isDarkMode
                                                          ? colors.textSecondaryDark
                                                          : colors.textSecondaryLight
                                                      : theme.isDarkMode
                                                          ? colors.profitDark
                                                          : colors.profitLight,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: TextWidget.paraText(
                                              text:
                                                  "${holdingProvide[index].exchTsym![0].change == "null" ? "0.00 " : holdingProvide[index].exchTsym![0].change} "
                                                  "(${holdingProvide[index].exchTsym![0].perChange == "null" ? "(0.00%)" : "${holdingProvide[index].exchTsym![0].perChange ?? 0.00}%"})",
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          );
                        });
                  },
                );
    });
  }

  Widget _buildHoverButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    // final theme = ref.read(themeProvider);

    return SizedBox(
      width: 45,
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                label,
                style: TextWidget.textStyle(
                  fontSize: 11,
                  color: color,
                  theme: true,
                  fw: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
