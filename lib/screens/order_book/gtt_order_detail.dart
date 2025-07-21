import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/order_book_model/gtt_order_book.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/scrip_info_btns.dart';
import '../market_watch/scrip_depth_info.dart';

class GttOrderDetail extends ConsumerStatefulWidget {
  final GttOrderBookModel gttOrderBook;
  const GttOrderDetail({super.key, required this.gttOrderBook});

  @override
  ConsumerState<GttOrderDetail> createState() => _GttOrderDetailState();
}

class _GttOrderDetailState extends ConsumerState<GttOrderDetail> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 400) {
          Navigator.of(context).pop();
        }
      },
      child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.05,
          maxChildSize: 0.99,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                final scripInfo = ref.watch(marketWatchProvider);
                final theme = ref.read(themeProvider);
                final marketwatch = ref.watch(marketWatchProvider);

                DepthInputArgs depthArgs = DepthInputArgs(
                    exch: widget.gttOrderBook.exch ?? "",
                    token: widget.gttOrderBook.token ?? "",
                    tsym: marketwatch.getQuotes!.tsym ?? '',
                    instname: marketwatch.getQuotes!.instname ?? "",
                    symbol: marketwatch.getQuotes!.symbol ?? '',
                    expDate: marketwatch.getQuotes!.expDate ?? '',
                    option: marketwatch.getQuotes!.option ?? '');

                return StreamBuilder<Map>(
                  stream: ref.watch(websocketProvider).socketDataStream,
                  builder: (context, snapshot) {
                    final socketDatas = snapshot.data ?? {};

                    // Update model with real-time data if available
                    GttOrderBookModel displayData = widget.gttOrderBook;
                    if (socketDatas.containsKey(displayData.token)) {
                      final socketData = socketDatas[displayData.token];

                      // Only update with valid values
                      final lp = socketData['lp']?.toString();
                      if (lp != null && lp != "null" && lp != "0") {
                        displayData.ltp = lp;
                      }

                      final pc = socketData['pc']?.toString();
                      if (pc != null && pc != "null") {
                        displayData.perChange = pc;
                      }

                      final chng = socketData['chng']?.toString();
                      if (chng != null && chng != "null") {
                        displayData.change = chng;
                      }
                    }

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
                          children: <Widget>[
                            SingleChildScrollView(
                              controller: scrollController,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CustomDragHandler(),
                                    Material(
                                      color: Colors.transparent,
                                      shape: const BeveledRectangleBorder(),
                                      child: InkWell(
                                        customBorder:
                                            const BeveledRectangleBorder(),
                                        splashColor:
                                            Colors.black.withOpacity(0.15),
                                        highlightColor:
                                            Colors.black.withOpacity(0.08),
                                        onTap: () async {
                                          await marketwatch
                                              .scripdepthsize(true);
                                          await marketwatch.calldepthApis(
                                              context, depthArgs, "");
                                        },
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          TextWidget.titleText(
                                                              text:
                                                                  "${displayData.symbol?.replaceAll("-EQ", "")}",
                                                              theme: theme
                                                                  .isDarkMode,
                                                              fw: 0),
                                                          TextWidget.subText(
                                                              text:
                                                                  " ${displayData.option} ",
                                                              theme: false,
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              fw: 3,
                                                              textOverflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          CustomExchBadge(
                                                              exch:
                                                                  "${displayData.exch}"),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TextWidget.titleText(
                                                              text:
                                                                  "${displayData.ltp ?? '0.00'}",
                                                              theme: theme
                                                                  .isDarkMode,
                                                              color: (displayData.ltp ==
                                                                              "null" ||
                                                                          displayData.ltp ==
                                                                              null) ||
                                                                      displayData
                                                                              .ltp ==
                                                                          "0.00"
                                                                  ? colors
                                                                      .ltpgrey
                                                                  : displayData
                                                                              .ltp!
                                                                              .startsWith(
                                                                                  "-") ||
                                                                          displayData
                                                                              .ltp!
                                                                              .startsWith(
                                                                                  "-")
                                                                      ? colors
                                                                          .darkred
                                                                      : colors
                                                                          .ltpgreen,
                                                              fw: 3),
                                                          // TextWidget.paraText(
                                                          //     text:
                                                          //         "  ${displayData.expDate}",
                                                          //     theme: theme.isDarkMode,
                                                          //     fw: 1),
                                                          const SizedBox(
                                                              height: 4),
                                                          TextWidget.paraText(
                                                              text:
                                                                  "${double.parse("${displayData.change ?? 0.00} ").toStringAsFixed(2)} (${displayData.perChange ?? 0.00}%)",
                                                              theme: false,
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              fw: 3),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        height: 45,
                                                        width: 26,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(7),
                                                        child: SvgPicture.asset(
                                                          assets.rightarrowcur,
                                                          width: 12,
                                                          height: 12,
                                                          color: const Color(
                                                              0xff777777),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ]),
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Row(children: [
                                          Expanded(
                                            child: Material(
                                              color: Colors.transparent,
                                              shape:
                                                  const BeveledRectangleBorder(),
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: colors.btnBg,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color: colors
                                                        .btnOutlinedBorder,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  customBorder:
                                                      const BeveledRectangleBorder(),
                                                  splashColor: theme.isDarkMode
                                                      ? colors.splashColorDark
                                                      : colors.splashColorLight,
                                                  highlightColor: theme
                                                          .isDarkMode
                                                      ? colors.highlightDark
                                                      : colors.highlightLight,
                                                  onTap: () async {
                                                    await scripInfo.fetchScripInfo(
                                                        "${displayData.token}",
                                                        "${displayData.exch}",
                                                        context);
                                                    Navigator.pop(context);

                                                    Navigator.pushNamed(context,
                                                        Routes.modifyGtt,
                                                        arguments: {
                                                          "gttOrderBook":
                                                              displayData,
                                                          "scripInfo": ref
                                                              .read(
                                                                  marketWatchProvider)
                                                              .scripInfoModel!
                                                        });
                                                  },
                                                  child: Center(
                                                    child: TextWidget.subText(
                                                        text: "Modify Order",
                                                        theme: theme.isDarkMode,
                                                        color: theme.isDarkMode
                                                            ? colors.primaryDark
                                                            : colors
                                                                .primaryLight,
                                                        fw: 0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      colors.btnOutlinedBorder,
                                                  width: 1,
                                                ),
                                                color: colors.btnBg,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                shape:
                                                    const BeveledRectangleBorder(),
                                                child: InkWell(
                                                  customBorder:
                                                      const BeveledRectangleBorder(),
                                                  splashColor: theme.isDarkMode
                                                      ? colors.splashColorDark
                                                      : colors.splashColorLight,
                                                  highlightColor: theme
                                                          .isDarkMode
                                                      ? colors.highlightDark
                                                      : colors.highlightLight,
                                                  onTap: () async {
                                                    ref
                                                            .read(orderProvider)
                                                            .loading
                                                        ? null
                                                        : showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                dialogContext) {
                                                              return AlertDialog(
                                                                backgroundColor:
                                                                    colors
                                                                        .colorWhite,
                                                                titlePadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            8),
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8))),
                                                                scrollable:
                                                                    true,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 12,
                                                                ),
                                                                actionsPadding:
                                                                    const EdgeInsets.only(
                                                                        bottom:
                                                                            16,
                                                                        right:
                                                                            16,
                                                                        left:
                                                                            16,
                                                                        top: 8),
                                                                insetPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            30,
                                                                        vertical:
                                                                            12),
                                                                title: Column(
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Material(
                                                                          color:
                                                                              Colors.transparent,
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              await Future.delayed(const Duration(milliseconds: 150));
                                                                              Navigator.pop(context);
                                                                            },
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                            splashColor: theme.isDarkMode
                                                                                ? colors.splashColorDark
                                                                                : colors.splashColorLight,
                                                                            highlightColor: theme.isDarkMode
                                                                                ? colors.splashColorDark
                                                                                : colors.splashColorLight,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(6.0),
                                                                              child: Icon(
                                                                                Icons.close_rounded,
                                                                                size: 22,
                                                                                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            12),
                                                                    Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        TextWidget.subText(
                                                                            text:
                                                                                "${displayData.tsym?.replaceAll("-EQ", "")} ${displayData.expDate} ${displayData.option}",
                                                                            theme: theme
                                                                                .isDarkMode,
                                                                            color: theme.isDarkMode
                                                                                ? colors.textPrimaryDark
                                                                                : colors.textPrimaryLight,
                                                                            fw: 3),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            5),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      child:
                                                                          Center(
                                                                        child: TextWidget.subText(
                                                                            text:
                                                                                "Do you want to Cancel this order?",
                                                                            theme: theme
                                                                                .isDarkMode,
                                                                            color: theme.isDarkMode
                                                                                ? colors.textPrimaryDark
                                                                                : colors.textPrimaryLight,
                                                                            fw: 3),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                actions: [
                                                                  SizedBox(
                                                                    width: double
                                                                        .infinity,
                                                                    child:
                                                                        OutlinedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        Navigator.pop(
                                                                            dialogContext);
                                                                        await ref.read(orderProvider).cancelGttOrder(
                                                                            "${displayData.alId}",
                                                                            context);
                                                                      },
                                                                      style: OutlinedButton
                                                                          .styleFrom(
                                                                        minimumSize: const Size(
                                                                            0,
                                                                            40), // width, height
                                                                        side: BorderSide(
                                                                            color:
                                                                                colors.btnOutlinedBorder), // Outline border color
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                        ),
                                                                        backgroundColor:
                                                                            colors.primaryDark, // Transparent background
                                                                      ),
                                                                      child: TextWidget
                                                                          .titleText(
                                                                        text:
                                                                            "Cancel",
                                                                        color: !theme.isDarkMode
                                                                            ? colors.colorWhite
                                                                            : colors.colorBlack,
                                                                        theme: theme
                                                                            .isDarkMode,
                                                                        fw: 0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                  },
                                                  child: Center(
                                                    child: ref
                                                            .read(orderProvider)
                                                            .loading
                                                        ? SizedBox(
                                                            width: 18,
                                                            height: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: colors
                                                                  .primaryDark,
                                                            ),
                                                          )
                                                        : TextWidget.subText(
                                                            text:
                                                                "Cancel Order",
                                                            theme: theme
                                                                .isDarkMode,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .primaryDark
                                                                : colors
                                                                    .primaryLight,
                                                            fw: 0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                    // ScripInfoBtns(
                                    //     exch: '${displayData.exch}',
                                    //     token: '${displayData.token}',
                                    //     insName: '',
                                    //     tsym: '${displayData.tsym}'),
                                    const SizedBox(height: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (displayData.placeOrderParams !=
                                            null)
                                          rowOfInfoData(
                                              "${displayData.placeOrderParams?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger",
                                              "${displayData.oivariable?.first.d}",
                                              theme),
                                        rowOfInfoData(
                                            "Product",
                                            displayData.placeOrderParams?.prd ==
                                                    "C"
                                                ? "CNC"
                                                : displayData.placeOrderParams
                                                            ?.prd ==
                                                        "I"
                                                    ? "MIS"
                                                    : displayData
                                                                .placeOrderParams
                                                                ?.prd ==
                                                            "M"
                                                        ? "NRML"
                                                        : "-",
                                            theme),
                                        rowOfInfoData(
                                            "Order Type",
                                            "${displayData.placeOrderParams?.prctyp}",
                                            theme),
                                        rowOfInfoData(
                                            "Qty",
                                            "${displayData.placeOrderParams?.qty}",
                                            theme),
                                        rowOfInfoData(
                                            "Price",
                                            "${displayData.placeOrderParams?.prctyp == "MKT" ? "MKT" : displayData.placeOrderParams?.prc}",
                                            theme)
                                      ],
                                    ),
                                    if (displayData.placeOrderParamsLeg2 !=
                                        null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextWidget.titleText(
                                              text:
                                                  "${displayData.placeOrderParamsLeg2?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger @ ${displayData.oivariable?.last.d}",
                                              theme: theme.isDarkMode,
                                              fw: 1),
                                          const SizedBox(height: 16),
                                          rowOfInfoData(
                                              "Product",
                                              displayData.placeOrderParamsLeg2
                                                          ?.prd ==
                                                      "C"
                                                  ? "CNC"
                                                  : displayData
                                                              .placeOrderParamsLeg2
                                                              ?.prd ==
                                                          "I"
                                                      ? "MIS"
                                                      : displayData
                                                                  .placeOrderParamsLeg2
                                                                  ?.prd ==
                                                              "M"
                                                          ? "NRML"
                                                          : "-",
                                              theme),
                                          rowOfInfoData(
                                              "Order Type",
                                              "${displayData.placeOrderParamsLeg2?.prctyp}",
                                              theme),
                                          rowOfInfoData(
                                              "Qty",
                                              "${displayData.placeOrderParamsLeg2?.qty}",
                                              theme),
                                          rowOfInfoData(
                                              "Price",
                                              "${displayData.placeOrderParamsLeg2?.prctyp == "MKT" ? "MKT" : displayData.placeOrderParamsLeg2?.prc}",
                                              theme)
                                        ],
                                      ),
                                    if (displayData.remarks != null &&
                                        displayData.remarks != "")
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextWidget.titleText(
                                                text: "Remarks",
                                                theme: theme.isDarkMode,
                                                fw: 1),
                                            const SizedBox(height: 16),
                                            TextWidget.subText(
                                                text: "${displayData.remarks}",
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }),
    );
  }

  rowOfInfoData(String title, String value, ThemesProvider theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
              text: title,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 3),
          TextWidget.subText(text: value, theme: theme.isDarkMode, fw: 3),
        ],
      ),
      const SizedBox(height: 8),
      Divider(
          color: theme.isDarkMode
              ? colors.darkColorDivider
              : const Color(0xffEBEEF3),
          thickness: 1)
    ]);
  }
}
