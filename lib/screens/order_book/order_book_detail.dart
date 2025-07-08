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
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/scrip_info_btns.dart';
import '../../sharedWidget/time_line.dart';
import '../market_watch/scrip_depth_info.dart';

class OrderBookDetail extends ConsumerStatefulWidget {
  final OrderBookModel orderBookData;
  const OrderBookDetail({super.key, required this.orderBookData});

  @override
  ConsumerState<OrderBookDetail> createState() => _OrderBookDetailState();
}

class _OrderBookDetailState extends ConsumerState<OrderBookDetail> {
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final GlobalKey orderStatusKey = GlobalKey();

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
            final order = ref.watch(orderProvider);

            final color = widget.orderBookData.status == "COMPLETE"
                ? const Color(0xff43A833)
                : widget.orderBookData.status == "OPEN"
                    ? const Color(0xffFFB038)
                    : (widget.orderBookData.status == "CANCELED" ||
                            widget.orderBookData.status == "REJECTED")
                        ? const Color(0xffFF1717)
                        : const Color(0xff666666);

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
                                        const SizedBox(height: 16),

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
                                                  .chngDephBtn("Overview");
                                              marketwatch.scripdepthsize(true);
                                              // Navigator.pop(context);

                                              showModalBottomSheet(
                                                  barrierColor:
                                                      Colors.transparent,
                                                  isScrollControlled: true,
                                                  useSafeArea: true,
                                                  isDismissible: true,
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      16))),
                                                  backgroundColor:
                                                      const Color(0xffffffff),
                                                  context: context,
                                                  builder: (context) =>
                                                      ScripDepthInfo(
                                                          wlValue: depthArgs,
                                                          isBasket: ''));
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        TextWidget.titleText(
                                                            text:
                                                                "${displayData.symbol?.replaceAll("-EQ", "")}",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .textPrimaryDark
                                                                : colors
                                                                    .textPrimaryLight,
                                                            fw: 0),
                                                        TextWidget.subText(
                                                            text:
                                                                "${displayData.option}",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .textPrimaryDark
                                                                : colors
                                                                    .textPrimaryLight,
                                                            fw: 3,
                                                            textOverflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        const SizedBox(
                                                            width: 4),
                                                        CustomExchBadge(
                                                            exch: displayData
                                                                .exch!),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    TextWidget.titleText(
                                                        text:
                                                            "${displayData.ltp}",
                                                        theme: false,
                                                        color: (displayData.change ==
                                                                        "null" ||
                                                                    displayData
                                                                            .change ==
                                                                        null) ||
                                                                displayData
                                                                        .change ==
                                                                    "0.00"
                                                            ? theme.isDarkMode
                                                                ? colors
                                                                    .textSecondaryDark
                                                                : colors
                                                                    .textSecondaryLight
                                                            : displayData.change!
                                                                        .startsWith(
                                                                            "-") ||
                                                                    displayData
                                                                        .perChange!
                                                                        .startsWith(
                                                                            "-")
                                                                ? theme
                                                                        .isDarkMode
                                                                    ? colors
                                                                        .lossDark
                                                                    : colors
                                                                        .lossLight
                                                                : theme
                                                                        .isDarkMode
                                                                    ? colors
                                                                        .profitDark
                                                                    : colors
                                                                        .profitLight,
                                                        fw: 3),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        // TextWidget.paraText(
                                                        //     text:
                                                        //         "${displayData.expDate}",
                                                        //     theme: false,
                                                        //     color: theme.isDarkMode
                                                        //         ? colors
                                                        //             .colorWhite
                                                        //         : colors
                                                        //             .colorBlack,
                                                        //     fw: 3),
                                                        TextWidget.paraText(
                                                            text:
                                                                "${double.parse("${displayData.change != "null" ? displayData.change ?? 0.00 : 0.0} ").toStringAsFixed(2)} (${displayData.perChange ?? 0.00}%)",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .textSecondaryDark
                                                                : colors
                                                                    .textSecondaryLight,
                                                            fw: 0),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: 45,
                                                      width: 26,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              7),
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

                                        // ScripInfoBtns(
                                        //     exch:
                                        //         '${widget.orderBookData.exch}',
                                        //     token:
                                        //         '${widget.orderBookData.token}',
                                        //     insName: '',
                                        //     tsym:
                                        //         '${widget.orderBookData.tsym}'),

                                        const SizedBox(height: 25),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // if ((widget.positionList.netqty !=
                                            //         "0") &&
                                            //     (widget.positionList
                                            //                 .sPrdtAli ==
                                            //             "MIS" ||
                                            //         widget.positionList
                                            //                 .sPrdtAli ==
                                            //             "CNC" ||
                                            //         widget.positionList
                                            //                 .sPrdtAli ==
                                            //             "NRML"))
                                            Material(
                                              color: Colors.transparent,
                                              shape:
                                                  const BeveledRectangleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const BeveledRectangleBorder(),
                                                splashColor: Colors.black
                                                    .withOpacity(0.15),
                                                highlightColor: Colors.black
                                                    .withOpacity(0.08),
                                                onTap: () async {
                                                  await order
                                                      .showorderHistory(true);
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 100));
                                                  Scrollable.ensureVisible(
                                                    orderStatusKey
                                                        .currentContext!,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                  );
                                                },
                                                child: Center(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SvgPicture.asset(
                                                        assets.orderhistoryicon,
                                                        width: 14,
                                                        height: 14,
                                                        color: theme.isDarkMode
                                                            ? colors.primaryDark
                                                            : colors
                                                                .primaryLight,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      TextWidget.subText(
                                                        text: "Order History",
                                                        fw: 2,
                                                        color: theme.isDarkMode
                                                            ? colors.primaryDark
                                                            : colors
                                                                .primaryLight,
                                                        theme: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        _OrderDetailsSection(
                                            orderBookData:
                                                widget.orderBookData),

                                        // Order status header
                                        order.showOrderHistory
                                            ? Row(
                                                key: orderStatusKey,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  TextWidget.subText(
                                                      text: "Order Status",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: color
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                        color: color,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: TextWidget.subText(
                                                        text:
                                                            "${widget.orderBookData.status![0].toUpperCase()}${widget.orderBookData.status!.toLowerCase().replaceAll("_", " ").substring(1)}",
                                                        theme: false,
                                                        color: color,
                                                        fw: 0),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox.shrink(),

                                        // Order history timeline
                                        if (orderHistory != null &&
                                            orderHistory.isNotEmpty &&
                                            orderHistory[0].stat != "Not_Ok" &&
                                            order.showOrderHistory) ...[
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
                                        ] else ...[
                                          const SizedBox.shrink(),
                                        ],
                                        const SizedBox(height: 20),
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
    final color = orderBookData.status == "COMPLETE"
        ? theme.isDarkMode
            ? colors.profitDark
            : colors.profitLight
        : orderBookData.status == "OPEN"
            ? theme.isDarkMode
                ? colors.pending
                : colors.pending
            : (orderBookData.status == "CANCELED" ||
                    orderBookData.status == "REJECTED")
                ? theme.isDarkMode
                    ? colors.lossDark
                    : colors.lossLight
                : theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // const SizedBox(height: 20),
      // TextWidget.titleText(
      //   text: "Details",
      //   color: theme.isDarkMode ? colors.colorWhite : const Color(0xff666666),
      //   fw: 1,
      //   theme: false,
      // ),
      const SizedBox(height: 24),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
                text: "Status",
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: color,
                  width: 1,
                ),
              ),
              child: TextWidget.subText(
                  text:
                      "${orderBookData.status![0].toUpperCase()}${orderBookData.status!.toLowerCase().replaceAll("_", " ").substring(1)}",
                  theme: false,
                  color: color,
                  fw: 0),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : const Color(0xffEBEEF3),
            thickness: 1)
      ]),
      const SizedBox(height: 8),
      _buildInfoRow("Type", orderBookData.trantype == "B" ? "Buy" : "Sell",
          theme, context),
      const SizedBox(height: 8),
      _buildInfoRow(
          "Qty",
          "${((orderBookData.status != "COMPLETE" && (orderBookData.fillshares?.isNotEmpty ?? false) ? (int.tryParse(orderBookData.fillshares.toString()) ?? 0) : orderBookData.status == "COMPLETE" ? (int.tryParse(orderBookData.rqty.toString()) ?? 0) : (int.tryParse(orderBookData.dscqty.toString()) ?? 0)).toInt() / (orderBookData.exch == 'MCX' ? (int.tryParse(orderBookData.ls.toString()) ?? 1) : 1)).toInt()}/${((int.tryParse(orderBookData.qty.toString()) ?? 0) / (orderBookData.exch == 'MCX' ? (int.tryParse(orderBookData.ls.toString()) ?? 1) : 1)).toInt()}",
          theme,
          context),
      const SizedBox(height: 8),
      _buildInfoRow("Price", "${orderBookData.prc ?? "-"}", theme, context),
      const SizedBox(height: 8),
      _buildInfoRow(
          "Avg Price", "${orderBookData.avgprc ?? "-"}", theme, context),
      const SizedBox(height: 8),
      _buildInfoRow(
          "Trigger Price", "${orderBookData.trgprc ?? "-"}", theme, context),
      const SizedBox(height: 8),
      _buildInfoRow(
          "Product / Type",
          "${orderBookData.sPrdtAli} / ${orderBookData.prctyp ?? "-"}",
          theme,
          context),
      const SizedBox(height: 8),
      _buildInfoRow("Market Protection",
          "${orderBookData.mktProtection ?? "-"}", theme, context),
      const SizedBox(height: 8),
      _buildInfoRow("AMO", "${orderBookData.amo ?? "-"}", theme, context),
      const SizedBox(height: 8),
      _buildInfoRow(
          "Order Id", "${orderBookData.norenordno ?? "-"}", theme, context),
      const SizedBox(height: 8),
      _buildInfoRow(
          "Exchange", "${orderBookData.exchordid ?? "-"}", theme, context),
      const SizedBox(height: 8),
      _buildInfoRow(
          "Date & Time",
          "${formatDateTime(value: orderBookData.norentm ?? "-")}",
          theme,
          context),
      const SizedBox(height: 8),
      orderBookData.rejreason != null
          ? _buildInfoRow(
              "Reason", "${orderBookData.rejreason ?? "-"}", theme, context)
          : const SizedBox.shrink(),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildInfoRow(String title1, String value1, ThemesProvider theme,
      BuildContext context) {
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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: TextWidget.subText(
                align: TextAlign.end,
                text: value1,
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                maxLines: null,
                textOverflow: TextOverflow.visible,
                softWrap: true,
                fw: 3),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Divider(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          thickness: 1)
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
                border: Border.all(
                  color: theme.isDarkMode
                      ? colors.colorGrey
                      : const Color(0xff0037B7),
                  width: 1,
                ),
              ),
              child: InkWell(
                onTap: () async {
                  _showExitPositionDialog(context, theme, ref, orderBookData);
                },
                child: Center(
                  child: TextWidget.subText(
                      text: "Exit",
                      theme: false,
                      color: const Color(0xff0037B7),
                      fw: 1),
                ),
              )))
    ] else ...[
      Expanded(
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffF1F3F8),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color:
                  theme.isDarkMode ? colors.colorGrey : const Color(0xff0037B7),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () async {
              _showCancelOrderDialog(context, theme, ref, orderBookData);
            },
            child: Center(
              child: TextWidget.subText(
                  text: "Cancel Order",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.primaryDark
                      : colors.primaryLight,
                  fw: 2),
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
          color: const Color(0xffF1F3F8),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                theme.isDarkMode ? colors.colorGrey : const Color(0xff0037B7),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () async {
            await _navigateToModifyOrder(context, ref, orderBookData);
          },
          child: Center(
            child: TextWidget.subText(
                text: "Modify Order",
                theme: false,
                color:
                    theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                fw: 2),
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
            color: const Color(0xffF1F3F8),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: colors.btnOutlinedBorder,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(),
            child: InkWell(
              splashColor: colors.splashColorLight,
              highlightColor: colors.splashColorDark,
              customBorder: const RoundedRectangleBorder(),
              onTap: () async {
                Future.delayed(const Duration(milliseconds: 100), () {
                  _navigateToPlaceOrder(context, ref, orderBookData);
                });
              },
              child: Center(
                  child: TextWidget.subText(
                      text: "Repeat order",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight,
                      fw: 2)),
            ),
          ),
        ),
      ),
      if ((orderBookData.sPrdtAli != "BO" || orderBookData.sPrdtAli != "CO") &&
          orderBookData.snonum == null &&
          orderBookData.status == "OPEN")
        Expanded(
            child: Container(
                margin: const EdgeInsets.only(left: 12),
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: colors.btnOutlinedBorder, width: 1),
                  color: const Color(0xffF1F3F8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(),
                  child: InkWell(
                    splashColor: colors.splashColorLight,
                    highlightColor: colors.splashColorDark,
                    customBorder: const RoundedRectangleBorder(),
                    onTap: () async {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _showCancelOrderDialog(
                            context, theme, ref, orderBookData);
                      });
                    },
                    child: Center(
                      child: TextWidget.subText(
                          text: "Cancel",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                          fw: 0),
                    ),
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
  final color = orderBookData.status == "COMPLETE"
      ? theme.isDarkMode
          ? colors.profitDark
          : colors.profitLight
      : orderBookData.status == "OPEN"
          ? theme.isDarkMode
              ? colors.pending
              : colors.pending
          : (orderBookData.status == "CANCELED" ||
                  orderBookData.status == "REJECTED")
              ? theme.isDarkMode
                  ? colors.lossDark
                  : colors.lossLight
              : theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: colors.colorWhite,
        titleTextStyle: TextWidget.textStyle(
            theme: false,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fontSize: 14,
            fw: 0),
        contentTextStyle: TextWidget.textStyle(
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fontSize: 12,
            fw: 0,
            theme: false),
        titlePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))),
        scrollable: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    TextWidget.subText(
                        text:
                            "${orderBookData.symbol?.replaceAll("-EQ", "")} ${orderBookData.option} ",
                        theme: theme.isDarkMode,
                        fw: 3,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight),
                    TextWidget.paraText(
                        text: "${orderBookData.exch} ",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 3),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        // borderRadius: BorderRadius.circular(5),
                        // border: Border.all(
                        //   color: color,
                        //   width: 1,
                        // ),
                      ),
                      child: TextWidget.paraText(
                          text: "${orderBookData.status}",
                          theme: false,
                          color: color,
                          fw: 3),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 150));
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.iconColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const ListDivider(),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextWidget.subText(
                text: "Do you want to Cancel this order?",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3)
          ]),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(orderProvider).fetchOrderCancel(
                      "${orderBookData.norenordno}",
                      context,
                      true,
                    );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40), // width, height
                side: BorderSide(color: colors.error), // Outline border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: Colors.transparent, // Transparent background
              ),
              child: TextWidget.subText(
                text: "Cancel",
                color: colors.error,
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
          ),
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
