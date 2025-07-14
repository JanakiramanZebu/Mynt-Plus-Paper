import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/order_book_model/trade_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/scrip_info_btns.dart';
import '../../../res/global_state_text.dart';
import '../market_watch/scrip_depth_info.dart';

class TradeBookDetail extends ConsumerStatefulWidget {
  final TradeBookModel tradeData;
  const TradeBookDetail({super.key, required this.tradeData});

  @override
  ConsumerState<TradeBookDetail> createState() => _TradeBookDetailState();
}

class _TradeBookDetailState extends ConsumerState<TradeBookDetail> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final marketwatch = ref.watch(marketWatchProvider);

    DepthInputArgs depthArgs = DepthInputArgs(
        exch: widget.tradeData.exch ?? "",
        token: widget.tradeData.token ?? "",
        tsym: marketwatch.getQuotes!.tsym ?? '',
        instname: marketwatch.getQuotes!.instname ?? "",
        symbol: marketwatch.getQuotes!.symbol ?? '',
        expDate: marketwatch.getQuotes!.expDate ?? '',
        option: marketwatch.getQuotes!.option ?? '');

    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        // Create a copy of trade data to avoid directly modifying the original
        var displayData = widget.tradeData;

        // Ensure initial values are not null (using safe defaults)
        if (displayData.ltp == null ||
            displayData.ltp == "null" ||
            displayData.ltp == "0" ||
            displayData.ltp == "0.00") {
          // Try to use any available price in a specific priority order
          if (displayData.avgprc != null &&
              displayData.avgprc != "null" &&
              displayData.avgprc != "0" &&
              displayData.avgprc != "0.00") {
            displayData.ltp = displayData.avgprc;
          } else if (displayData.prc != null &&
              displayData.prc != "null" &&
              displayData.prc != "0" &&
              displayData.prc != "0.00") {
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

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.05,
          maxChildSize: 0.99,
          builder: (context, scrollController) {
            return Consumer(builder: (context, ref, _) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Container(
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CustomDragHandler(),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                Material(
                                  color: Colors.transparent,
                                  shape: const BeveledRectangleBorder(),
                                  child: InkWell(
                                    customBorder:
                                        const BeveledRectangleBorder(),
                                    splashColor: theme.isDarkMode
                                        ? colors.splashColorDark
                                        : colors.splashColorLight,
                                    highlightColor: theme.isDarkMode
                                        ? colors.highlightDark
                                        : colors.highlightLight,
                                    onTap: () async {
                                      await marketwatch.chngDephBtn("Overview");
                                      marketwatch.scripdepthsize(true);
                                      // Navigator.pop(context);

                                      showModalBottomSheet(
                                          barrierColor: Colors.transparent,
                                          isScrollControlled: true,
                                          useSafeArea: true,
                                          isDismissible: true,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(16))),
                                          backgroundColor:
                                              const Color(0xffffffff),
                                          context: context,
                                          builder: (context) => ScripDepthInfo(
                                              wlValue: depthArgs,
                                              isBasket: ''));
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                TextWidget.headText(
                                                    text:
                                                        "${displayData.symbol?.replaceAll("-EQ", "") ?? ''}",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,
                                                    fw: 0),
                                                TextWidget.headText(
                                                    text:
                                                        " ${displayData.option ?? ''} ",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,
                                                    fw: 0,
                                                    textOverflow:
                                                        TextOverflow.ellipsis),
                                                CustomExchBadge(
                                                    exch:
                                                        displayData.exch ?? ""),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            TextWidget.titleText(
                                                text: "$formattedLTP",
                                                theme: false,
                                                color: (formattedLTP ==
                                                            "null") ||
                                                        formattedLTP == "0.00"
                                                    ? theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight
                                                    : formattedLTP.startsWith(
                                                                "-") ||
                                                            formattedLTP
                                                                .startsWith("-")
                                                        ? theme.isDarkMode
                                                            ? colors.lossDark
                                                            : colors.lossLight
                                                        : theme.isDarkMode
                                                            ? colors.profitDark
                                                            : colors
                                                                .profitLight,
                                                fw: 3),
                                            // displayData.expDate != null &&
                                            //         displayData.expDate != "null"
                                            //     ? TextWidget.paraText(
                                            //         text:
                                            //             "${displayData.expDate ?? ''}",
                                            //         theme: false,
                                            //         color: theme.isDarkMode
                                            //             ? colors.textSecondaryDark
                                            //             : colors.textSecondaryLight,
                                            //         fw: 3)
                                            //     : const SizedBox.shrink(),
                                            const SizedBox(height: 4),
                                            _buildChangeIndicator(
                                                displayData, theme)
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            Container(
                                              height: 45,
                                              width: 26,
                                              padding: const EdgeInsets.all(7),
                                              child: SvgPicture.asset(
                                                assets.rightarrowcur,
                                                width: 12,
                                                height: 12,
                                                color: colors.iconColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ScripInfoBtns(
                                //     exch: '${displayData.exch ?? ""}',
                                //     token: '${displayData.token ?? ""}',
                                //     insName: '',
                                //     tsym: '${displayData.tsym ?? ""}'),

                                const SizedBox(height: 30),
                                rowOfInfoData(
                                    "Transaction Type",
                                    displayData.trantype == "B"
                                        ? "Buy"
                                        : "Sell",
                                    theme),
                                const SizedBox(height: 8),
                                rowOfInfoData("Filled Qty",
                                    displayData.flqty ?? "-", theme),
                                const SizedBox(height: 8),

                                rowOfInfoData(
                                    "Price",
                                    displayData.avgprc != null &&
                                            displayData.avgprc != "null"
                                        ? displayData.avgprc!
                                        : displayData.prc != null &&
                                                displayData.prc != "null"
                                            ? displayData.prc!
                                            : "0.00",
                                    theme),
                                const SizedBox(height: 8),
                                rowOfInfoData(
                                    "Trade Value",
                                    "${displayData.flqty != null && displayData.flprc != null ? (double.parse(displayData.flqty!) * double.parse(displayData.flprc!)) : 0.00}",
                                    theme),
                                const SizedBox(height: 8),

                                rowOfInfoData2(
                                    "Product",
                                    "Type",
                                    displayData.sPrdtAli ?? '',
                                    displayData.prctyp ?? '',
                                    theme),

                                // rowOfInfoData("Price Type",
                                //     "${displayData.prctyp ?? ''}", theme),
                                // const SizedBox(height: 8),
                                rowOfInfoData("Validity",
                                    "${displayData.ret ?? ''}", theme),
                                const SizedBox(height: 8),

                                rowOfInfoData("Fill Id",
                                    "${displayData.flid ?? ''}", theme),
                                const SizedBox(height: 8),

                                // rowOfInfoData("Product",
                                //     "${displayData.sPrdtAli ?? ''}", theme),
                                // const SizedBox(height: 8),
                                rowOfInfoData("Order Id",
                                    "${displayData.norenordno ?? ''}", theme),
                                const SizedBox(height: 8),
                                rowOfInfoData(
                                    "Date & Time",
                                    displayData.norentm != null
                                        ? formatDateTime(
                                            value: displayData.norentm!)
                                        : "-",
                                    theme),
                                const SizedBox(height: 8),
                                rowOfInfoData("Exch Order ID",
                                    displayData.exchordid ?? "-", theme),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
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

    final isNegative = changeValue < 0 ||
        (data.perChange != null && data.perChange!.startsWith("-"));
    final isZero = changeValue == 0 || formattedChange == "0.00";

    final textColor = isZero
        ? theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight
        : isNegative
            ? theme.isDarkMode
                ? colors.lossDark
                : colors.lossLight
            : theme.isDarkMode
                ? colors.profitDark
                : colors.profitLight;

    return TextWidget.paraText(
        text: "$formattedChange ($formattedPercentage%)",
        theme: false,
        color: theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight,
        fw: 3);
  }

  Widget rowOfInfoData(
    String title1,
    String value1,
    ThemesProvider theme,
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
              text: title1,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 3),
          TextWidget.subText(
              text: value1,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 3),
        ],
      ),
      const SizedBox(height: 8),
      Divider(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          thickness: 0)
    ]);
  }

  Widget rowOfInfoData2(
    String title1,
    String title2,
    String value1,
    String value2,
    ThemesProvider theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: '$title1 / $title2',
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 3,
            ),
            TextWidget.subText(
              text: '$value1 / $value2',
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 3,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          thickness: 0,
        ),
      ],
    );
  }
}
