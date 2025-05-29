import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../sharedWidget/snack_bar.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final holdingProvide = ref.watch(portfolioProvider).holdingsModel;
      final marketWatch = ref.watch(marketWatchProvider);
      final theme = ref.read(themeProvider);
      return ref.watch(portfolioProvider).loading
          ? const Center(child: CircularProgressIndicator())
          : holdingProvide!.isEmpty
              ? const Center(child: NoDataFound())
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: false,
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
                          final socketData = socketDatas[holdingProvide[index].exchTsym![0].token];
                          
                          // Only update with valid data
                          final lp = socketData['lp']?.toString();
                          if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
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
                          if (c != null && c != "null" && c != "0" && c != "0.00") {
                            holdingProvide[index].exchTsym![0].close = c;
                          }
                        }

                        return InkWell(
                            onLongPress: () {
                              if (marketWatch.isPreDefWLs == "Yes") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    warningMessage(context,
                                        "This is a pre-defined watchlist that cannot be edited!"));
                              }
                            },
                            onTap: () async {
                                 DepthInputArgs depthArgs = DepthInputArgs(
                                        exch: holdingProvide[index].exchTsym![0].exch.toString(),
                                        token: holdingProvide[index].exchTsym![0].token.toString(),
                                        tsym: holdingProvide[index].exchTsym![0].tsym.toString(),
                                        instname: holdingProvide[index].exchTsym![0].symbol.toString(),
                                        symbol: holdingProvide[index].exchTsym![0].symbol.toString(),
                                        expDate: "",
                                        option: "");
                              await marketWatch.calldepthApis(
                                  context, depthArgs, "");
                            },
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              dense: true,
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      "${holdingProvide[index].exchTsym![0].symbol} ",
                                      style: textStyles.scripNameTxtStyle.copyWith(
                                          color: theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack)),
                                  if (holdingProvide[index]
                                      .exchTsym![0]
                                      .option!
                                      .isNotEmpty)
                                    Text(
                                        "${holdingProvide[index].exchTsym![0].option}",
                                        style: textStyles.scripNameTxtStyle
                                            .copyWith(
                                                color: const Color(0xff666666))),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      CustomExchBadge(
                                          exch:
                                              "${holdingProvide[index].exchTsym![0].exch}"),
                                      if (holdingProvide[index]
                                          .exchTsym![0]
                                          .expDate!
                                          .isNotEmpty)
                                        Text(
                                            " ${holdingProvide[index].exchTsym![0].expDate}  ",
                                            style: textStyles.scripExchTxtStyle
                                                .copyWith(
                                                    color: colors.colorBlack)),
                                      SvgPicture.asset(assets.suitcase,
                                          height: 12,
                                          width: 16,
                                          color: colors.colorBlue),
                                      Text(" ${holdingProvide[index].currentQty}",
                                          style: textStyles.scripExchTxtStyle
                                              .copyWith(
                                                  color: colors.colorBlue,
                                                  fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("₹${holdingProvide[index].exchTsym![0].lp}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${holdingProvide[index].exchTsym![0].change == "null" ? "0.00 " : holdingProvide[index].exchTsym![0].change} "
                                    "${holdingProvide[index].exchTsym![0].perChange == "null" ? "(0.00%)" : "(${holdingProvide[index].exchTsym![0].perChange ?? 0.00}%)"}",
                                    style: textStyle(
                                        holdingProvide[index]
                                                    .exchTsym![0]
                                                    .change!
                                                    .startsWith("-") ||
                                                holdingProvide[index]
                                                    .exchTsym![0]
                                                    .perChange!
                                                    .startsWith('-')
                                            ? colors.darkred
                                            : (holdingProvide[index]
                                                                .exchTsym![0]
                                                                .change ==
                                                            "null" ||
                                                        holdingProvide[index]
                                                                .exchTsym![0]
                                                                .perChange ==
                                                            "null") ||
                                                    (holdingProvide[index]
                                                                .exchTsym![0]
                                                                .change ==
                                                            "0.00" ||
                                                        holdingProvide[index]
                                                                .exchTsym![0]
                                                                .perChange ==
                                                            "0.00")
                                                ? colors.ltpgrey
                                                : colors.ltpgreen,
                                        12,
                                        FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                        );
                      }
                    );
                  },
                );
    });
  }
  
  TextStyle textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
