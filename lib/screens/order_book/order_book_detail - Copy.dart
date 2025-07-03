import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/order_book_model/order_book_model.dart';
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
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/scrip_info_btns.dart';
import '../../sharedWidget/time_line.dart';

class OrderBookDetail extends ConsumerStatefulWidget {
  final OrderBookModel orderBookData;
  const OrderBookDetail({super.key, required this.orderBookData});

  @override
  ConsumerState<OrderBookDetail> createState() => _OrderBookDetailState();
}

class _OrderBookDetailState extends ConsumerState<OrderBookDetail> {
  @override
  Widget build(BuildContext context) {
    final marketwatch = ref.watch(marketWatchProvider);
    final depthData = ref.watch(marketWatchProvider).getQuotes!;

    DepthInputArgs depthArgs = DepthInputArgs(
        exch: widget.orderBookData.exch ?? "",
        token: widget.orderBookData.token ?? "",
        tsym: marketwatch.getQuotes!.tsym ?? '',
        instname: marketwatch.getQuotes!.instname ?? "",
        symbol: marketwatch.getQuotes!.symbol ?? '',
        expDate: marketwatch.getQuotes!.expDate ?? '',
        option: marketwatch.getQuotes!.option ?? '');
    // Use read for static data that doesn't need to trigger rebuilds

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
          return Consumer(builder: (context, ref, child) {
            final theme = ref.read(themeProvider);

            final orderHistory = ref.watch(orderProvider).orderHistoryModel;
            final socketData = ref.watch(websocketProvider).socketDataStream;

            return StreamBuilder<Map>(
                stream: socketData,
                builder: (context, snapshot) {
                  // Initialize display data with original
                  var displayData = widget.orderBookData;

                  // Update with WebSocket data if available
                  final socketDatas = snapshot.data ?? {};
                  if (socketDatas.containsKey(widget.orderBookData.token)) {
                    final socketData = socketDatas[widget.orderBookData.token];

                    // Only update with non-zero values
                    final lp = socketData['lp']?.toString();
                    if (lp != null &&
                        lp != "null" &&
                        lp != "0" &&
                        lp != "0.00") {
                      displayData.ltp = lp;
                    }

                    final pc = socketData['pc']?.toString();
                    if (pc != null &&
                        pc != "null" &&
                        pc != "0" &&
                        pc != "0.00") {
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
                          const CustomDragHandler(),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Material(
                                              color: Colors
                                                  .transparent, // Important to allow splash visibility
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                splashColor: theme.isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.15)
                                                    : Colors.black
                                                        .withOpacity(0.15),
                                                highlightColor: theme.isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.08)
                                                    : Colors.black
                                                        .withOpacity(0.08),
                                                onTap: () async {
                                                  await marketwatch
                                                      .chngDephBtn("Overview");

                                                  if (!mounted) return;

                                                  await Navigator.pushNamed(
                                                    context,
                                                    Routes.setAlertScreen,
                                                    arguments: {
                                                      "depthdata": depthData,
                                                      "wlvalue": depthArgs,
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle),
                                                  child: SvgPicture.asset(
                                                    assets.bellIcon,
                                                    width: 18,
                                                    height: 18,
                                                    color: Color(0xFF0037B7),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            TextWidget.titleText(
                                                text: "${displayData.symbol}",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                fw: 0),
                                            TextWidget.subText(
                                                text: "${displayData.option}",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                fw: 3,
                                                textOverflow:
                                                    TextOverflow.ellipsis),
                                            const SizedBox(width: 4),
                                            CustomExchBadge(
                                                exch: displayData.exch!),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        TextWidget.titleText(
                                            text: "${displayData.ltp}",
                                            theme: false,
                                            color: (displayData.change ==
                                                            "null" ||
                                                        displayData.change ==
                                                            null) ||
                                                    displayData.change == "0.00"
                                                ? colors.ltpgrey
                                                : displayData.change!
                                                            .startsWith("-") ||
                                                        displayData.perChange!
                                                            .startsWith("-")
                                                    ? colors.ltpred
                                                    : colors.ltpgreen,
                                            fw: 0),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextWidget.paraText(
                                                text: "${displayData.expDate}",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                fw: 3),
                                            TextWidget.paraText(
                                                text:
                                                    "${double.parse("${displayData.change != "null" ? displayData.change ?? 0.00 : 0.0} ").toStringAsFixed(2)} (${displayData.perChange ?? 0.00}%)",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                fw: 0),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        (widget.orderBookData.status ==
                                                    "PENDING" ||
                                                widget.orderBookData.status ==
                                                    "OPEN" ||
                                                widget.orderBookData.status ==
                                                    "TRIGGER_PENDING")
                                            ? _buildActionButtonsBar(
                                                context,
                                                theme,
                                                ref,
                                                widget.orderBookData)
                                            : _buildRepeatOrderBar(
                                                context,
                                                theme,
                                                ref,
                                                widget.orderBookData),

                                        ScripInfoBtns(
                                            exch:
                                                '${widget.orderBookData.exch}',
                                            token:
                                                '${widget.orderBookData.token}',
                                            insName: '',
                                            tsym:
                                                '${widget.orderBookData.tsym}'),

                                        // Order details section
                                        _OrderDetailsSection(
                                            orderBookData:
                                                widget.orderBookData),

                                        // Order status header
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              TextWidget.titleText(
                                                  text: "Order Status",
                                                  theme: false,
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : const Color(0xff26324A),
                                                  fw: 1),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(widget
                                                              .orderBookData
                                                              .status ==
                                                          "COMPLETE"
                                                      ? assets.completedIcon
                                                      : widget.orderBookData
                                                                      .status ==
                                                                  "CANCELED" ||
                                                              widget.orderBookData
                                                                      .status ==
                                                                  "REJECTED"
                                                          ? assets.cancelledIcon
                                                          : assets.warningIcon),
                                                  TextWidget.subText(
                                                      text:
                                                          "  ${widget.orderBookData.stIntrn![0].toUpperCase()}${widget.orderBookData.stIntrn!.toLowerCase().replaceAll("_", " ").substring(1)}  ",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      fw: 0),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Order history timeline
                                        if (orderHistory != null &&
                                            orderHistory.isNotEmpty &&
                                            orderHistory[0].stat != "Not_Ok")
                                          ListView.builder(
                                            reverse: true,
                                            itemCount: orderHistory.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return TimeLineWidget(
                                                  isfFrist:
                                                      orderHistory.length - 1 ==
                                                              index
                                                          ? true
                                                          : false,
                                                  isLast:
                                                      index == 0 ? true : false,
                                                  orderHistoryData:
                                                      orderHistory[index]);
                                            },
                                          ),
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
                });
          });
        },
      ),
    );
  }
}

// Extracted order details section
class _OrderDetailsSection extends ConsumerWidget {
  final OrderBookModel orderBookData;

  const _OrderDetailsSection({required this.orderBookData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 10),
          TextWidget.titleText(
              text: "Order details",
              theme: false,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              fw: 1),

          const SizedBox(height: 16),
          _buildInfoRow(
              "Transaction Type",
              orderBookData.trantype == "B" ? "Buy" : "Sell",
              "Price Type",
              "${orderBookData.prctyp}",
              theme),
          const SizedBox(height: 4),
          _buildInfoRow("Price", "${orderBookData.prc}", "Avg.Price",
              "${orderBookData.avgprc ?? 0.00}", theme),
          const SizedBox(height: 4),
          _buildInfoRow("Trigger Price", "${orderBookData.trgprc ?? 0.00}", "",
              "", theme),
          const SizedBox(height: 4),
          _buildInfoRow(
              "Filled Qty",
              "${((orderBookData.status != "COMPLETE" && (orderBookData.fillshares?.isNotEmpty ?? false) ? (int.tryParse(orderBookData.fillshares.toString()) ?? 0) : orderBookData.status == "COMPLETE" ? (int.tryParse(orderBookData.rqty.toString()) ?? 0) : (int.tryParse(orderBookData.dscqty.toString()) ?? 0)).toInt() / (orderBookData.exch == 'MCX' ? (int.tryParse(orderBookData.ls.toString()) ?? 1) : 1)).toInt()}/${((int.tryParse(orderBookData.qty.toString()) ?? 0) / (orderBookData.exch == 'MCX' ? (int.tryParse(orderBookData.ls.toString()) ?? 1) : 1)).toInt()}",
              "MKT Protection",
              orderBookData.mktProtection ?? "-",
              theme),
          const SizedBox(height: 4),
          _buildInfoRow("Validity", "${orderBookData.ret}", "Product",
              "${orderBookData.sPrdtAli}", theme),
          const SizedBox(height: 4),
          _buildInfoRow(
              "After Market Order",
              orderBookData.amo ?? "-",
              "Status",
              "${orderBookData.stIntrn![0].toUpperCase()}${orderBookData.stIntrn!.toLowerCase().replaceAll("_", " ").substring(1)}",
              theme),
          const SizedBox(height: 4),
          _buildInfoRow(
              "Order Id",
              "${orderBookData.norenordno}",
              "Date & Time",
              formatDateTime(value: orderBookData.norentm!),
              theme),

          // Show rejection reason if present
          if (orderBookData.rejreason != null) ...[
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        TextWidget.paraText(
                            text: "Rejected Reason",
                            theme: false,
                            color: const Color(0xff666666),
                            fw: 0),
                        const SizedBox(height: 3),
                        TextWidget.subText(
                            text: '${orderBookData.rejreason}',
                            theme: false,
                            color: colors.darkred,
                            fw: 0),
                      ]))
                ]),
            const SizedBox(height: 10),
          ]
        ]));
  }

  Widget _buildInfoRow(String title1, String value1, String title2,
      String value2, ThemesProvider theme) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextWidget.paraText(
            text: title1, theme: false, color: const Color(0xff666666), fw: 0),
        const SizedBox(height: 2),
        TextWidget.subText(
            text: value1,
            theme: false,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            fw: 0),
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
        TextWidget.paraText(
            text: title2, theme: false, color: const Color(0xff666666), fw: 0),
        const SizedBox(height: 2),
        TextWidget.subText(
            text: value2,
            theme: false,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            fw: 0),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ]))
    ]);
  }
}

// Bottom action bar for order actions
Widget _buildActionButtonsBar(
    BuildContext context, ThemesProvider theme, WidgetRef ref, orderBookData) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    if ((orderBookData.sPrdtAli == "BO" || orderBookData.sPrdtAli == "CO") &&
        orderBookData.snonum != null) ...[
      Expanded(
          child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xffF1F3F8),
                borderRadius: BorderRadius.circular(5),
              ),
              child: InkWell(
                onTap: () async {
                  _showExitPositionDialog(context, theme, ref, orderBookData);
                },
                child: Center(
                  child: TextWidget.subText(
                      text: "Exit",
                      theme: false,
                      color: const Color(0XFFFFFFFF),
                      fw: 1),
                ),
              )))
    ] else ...[
      Expanded(
        child: Container(
          height: 40,
          decoration: BoxDecoration(
              color: const Color(0xffFF1717),
              borderRadius: BorderRadius.circular(5)),
          child: InkWell(
            onTap: () async {
              _showCancelOrderDialog(context, theme, ref, orderBookData);
            },
            child: Center(
              child: TextWidget.subText(
                  text: "Cancel Order",
                  theme: false,
                  color: const Color(0XFFFFFFFF),
                  fw: 1),
            ),
          ),
        ),
      ),
    ],
    const SizedBox(width: 16),
    Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            color: const Color(0xff43A833),
            borderRadius: BorderRadius.circular(5)),
        child: InkWell(
          onTap: () async {
            await _navigateToModifyOrder(context, ref, orderBookData);
          },
          child: Center(
            child: TextWidget.subText(
                text: "Modify Order",
                theme: false,
                color: const Color(0XFFFFFFFF),
                fw: 1),
          ),
        ),
      ),
    ),
  ]);
}

Widget _buildRepeatOrderBar(
    BuildContext context, ThemesProvider theme, WidgetRef ref, orderBookData) {
  return Row(
    children: [
      Expanded(
        child: Container(
          height: 40,
          decoration: BoxDecoration(
              color: const Color(0xff43A833),
              borderRadius: BorderRadius.circular(5)),
          child: InkWell(
            onTap: () async {
              await _navigateToPlaceOrder(context, ref, orderBookData);
            },
            child: Center(
                child: TextWidget.subText(
                    text: "Repeat order",
                    theme: false,
                    color: const Color(0XFFFFFFFF),
                    fw: 1)),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
          child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : const Color(0xff0037B7),
                    width: 1),
                color: const Color(0xffF1F3F8),
                borderRadius: BorderRadius.circular(5),
              ),
              child: InkWell(
                onTap: () async {},
                child: Center(
                  child: TextWidget.subText(
                      text: "Cancel",
                      theme: false,
                      color: const Color(0xff0037B7),
                      fw: 1),
                ),
              )))
    ],
  );
}

void _showExitPositionDialog(
    BuildContext context, ThemesProvider theme, WidgetRef ref, orderBookData) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.isDarkMode
              ? const Color.fromARGB(255, 18, 18, 18)
              : colors.colorWhite,
          titleTextStyle: textStyles.appBarTitleTxt.copyWith(
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
          contentTextStyle: textStyles.menuTxt,
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
          scrollable: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: TextWidget.titleText(
              text: "Exit Position", theme: theme.isDarkMode, fw: 1),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.subText(
                    text: "Are you sure you want to exit a position ?",
                    theme: theme.isDarkMode,
                    fw: 0),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: TextWidget.subText(
                    text: "No",
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.colorLightBlue
                        : colors.colorBlue,
                    fw: 0)),
            ElevatedButton(
              onPressed: () async {
                await ref.read(orderProvider).fetchExitSNOOrd(
                    "${orderBookData.snonum}",
                    "${orderBookData.prd}",
                    context,
                    true);
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  )),
              child: TextWidget.subText(
                  text: "Yes", theme: theme.isDarkMode, fw: 0),
            ),
          ],
        );
      });
}

void _showCancelOrderDialog(
    BuildContext context, ThemesProvider theme, WidgetRef ref, orderBookData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: theme.isDarkMode
            ? const Color.fromARGB(255, 18, 18, 18)
            : colors.colorWhite,
        titleTextStyle: TextWidget.textStyle(
            theme: false,
            color: !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            fontSize: 16,
            fw: 1),
        contentTextStyle: TextWidget.textStyle(
            color: const Color(0XFF666666), fontSize: 14, fw: 0, theme: false),
        titlePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))),
        scrollable: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Row(
          children: [
            TextWidget.titleText(
                text: "${orderBookData.tsym}", theme: theme.isDarkMode, fw: 1),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: const Color(0xffF1F3F8),
                  borderRadius: BorderRadius.circular(4)),
              child: TextWidget.captionText(
                  text: "${orderBookData.exch}",
                  theme: false,
                  color: const Color(0XFF666666),
                  fw: 1),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: const Color(0xffFCF3F3),
                  borderRadius: BorderRadius.circular(4)),
              child: TextWidget.captionText(
                  text: "${orderBookData.status}",
                  theme: false,
                  color: colors.darkred,
                  fw: 1),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextWidget.titleText(
                text: "Do you want to Cancel this order?",
                theme: theme.isDarkMode,
                fw: 1)
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: TextWidget.subText(
                  text: "No",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.colorLightBlue
                      : colors.colorBlue,
                  fw: 0)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  )),
              onPressed: () async {
                await ref.read(orderProvider).fetchOrderCancel(
                    "${orderBookData.norenordno}", context, true);
              },
              child: TextWidget.subText(
                  text: "Yes",
                  theme: false,
                  color:
                      !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  fw: 0)),
        ],
      );
    },
  );
}

Future<void> _navigateToModifyOrder(
    BuildContext context, WidgetRef ref, orderBookData) async {
  await ref.read(marketWatchProvider).fetchScripInfo(
      "${orderBookData.token}", '${orderBookData.exch}', context);

  OrderScreenArgs orderArgs = OrderScreenArgs(
      exchange: '${orderBookData.exch}',
      tSym: '${orderBookData.tsym}',
      isExit: false,
      token: "${orderBookData.token}",
      transType: true,
      lotSize: orderBookData.ls,
      ltp: orderBookData.ltp,
      perChange: orderBookData.perChange,
      orderTpye: '',
      holdQty: '',
      isModify: false,
      raw: {});

  Navigator.pop(context);
  Navigator.pushNamed(context, Routes.modifyOrder, arguments: {
    "modifyOrderArgs": orderBookData,
    "orderArg": orderArgs,
    "scripInfo": ref.read(marketWatchProvider).scripInfoModel!
  });
}

Future<void> _navigateToPlaceOrder(
    BuildContext context, WidgetRef ref, orderBookData) async {
  Navigator.pop(context);

  await ref.read(marketWatchProvider).fetchScripInfo(
      "${orderBookData.token}", "${orderBookData.exch}", context, true);

  OrderScreenArgs orderArgs = OrderScreenArgs(
      exchange: orderBookData.exch.toString(),
      tSym: orderBookData.tsym.toString(),
      isExit: false,
      token: orderBookData.token.toString(),
      transType: orderBookData.trantype == 'B' ? true : false,
      lotSize: orderBookData.ls,
      ltp: "${orderBookData.ltp ?? orderBookData.c ?? 0.00}",
      perChange: orderBookData.change ?? "0.00",
      orderTpye: '',
      holdQty: '',
      isModify: false,
      raw: orderBookData.toJson());

  Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
    "orderArg": orderArgs,
    "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
    "isBskt": ''
  });
}
