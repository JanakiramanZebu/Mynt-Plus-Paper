import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/scrip_info_btns.dart';
import '../../sharedWidget/time_line.dart';

class OrderBookDetail extends ConsumerWidget {
  final OrderBookModel orderBookData;
  const OrderBookDetail({super.key, required this.orderBookData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final orderHistory = watch(orderProvider).orderHistoryModel;
    final theme = context.read(themeProvider);
    
    return StreamBuilder<Map>(
      stream: watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        // Copy the order book data to avoid directly modifying the original
        var displayData = orderBookData;
        
        // Update with WebSocket data if available
        final socketDatas = snapshot.data ?? {};
        if (socketDatas.containsKey(orderBookData.token)) {
          final socketData = socketDatas[orderBookData.token];
          
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
        
        return Scaffold(
            appBar: AppBar(
                elevation: .2,
                leadingWidth: 41,
                centerTitle: false,
                titleSpacing: 6,
                leading: const CustomBackBtn(),
                shadowColor: const Color(0xffECEFF3),
                title:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("${displayData.symbol}",
                              style: textStyles.appBarTitleTxt.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack)),
                          Text(" ${displayData.option} ",
                              overflow: TextOverflow.ellipsis,
                              style: textStyles.scripNameTxtStyle.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack)),
                        ],
                      ),
                      Text("₹${displayData.ltp}",
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
                          CustomExchBadge(exch: displayData.exch!),
                          Text("  ${displayData.expDate}",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  12,
                                  FontWeight.w600))
                        ]),
                        Text(
                            "${double.parse("${displayData.change != "null" ? displayData.change ?? 0.00 : 0.0} ").toStringAsFixed(2)} (${displayData.perChange ?? 0.00}%)",
                            style: textStyle(
                                (displayData.change == "null" ||
                                            displayData.change == null) ||
                                        displayData.change == "0.00"
                                    ? colors.ltpgrey
                                    : displayData.change!.startsWith("-") ||
                                            displayData.perChange!.startsWith("-")
                                        ? colors.darkred
                                        : colors.ltpgreen,
                                12,
                                FontWeight.w500))
                      ])
                ])),
            body: ListView(
              children: [
                ScripInfoBtns(
                    exch: '${displayData.exch}',
                    token: '${displayData.token}',
                    insName: '',
                    tsym: '${displayData.tsym}'),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
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
                              "${displayData.prctyp}",
                              theme),
                          const SizedBox(height: 4),
                          rowOfInfoData(
                              "Price",
                              "${displayData.prc}",
                              "Avg.Price",
                              "${displayData.avgprc ?? 0.00}",
                              theme),
                          const SizedBox(height: 4),
                          rowOfInfoData("Trigger Price",
                              "${displayData.trgprc ?? 0.00}", "", "", theme),
                          const SizedBox(height: 4),
                          rowOfInfoData(
                              "Filled Qty",
                              "${((displayData.status != "COMPLETE" && (displayData.fillshares?.isNotEmpty ?? false) ? (int.tryParse(displayData.fillshares.toString()) ?? 0) : displayData.status == "COMPLETE" ? (int.tryParse(displayData.rqty.toString()) ?? 0) : (int.tryParse(displayData.dscqty.toString()) ?? 0)).toInt() / (displayData.exch == 'MCX' ? (int.tryParse(displayData.ls.toString()) ?? 1) : 1)).toInt()}/${((int.tryParse(displayData.qty.toString()) ?? 0) / (displayData.exch == 'MCX' ? (int.tryParse(displayData.ls.toString()) ?? 1) : 1)).toInt()}",
                              "MKT Protection",
                              displayData.mktProtection ?? "-",
                              theme),
                          const SizedBox(height: 4),
                          rowOfInfoData("Validity", "${displayData.ret}",
                              "Product", "${displayData.sPrdtAli}", theme),
                          const SizedBox(height: 4),
                          rowOfInfoData(
                              "After Market Order",
                              displayData.amo ?? "-",
                              "Status",
                              "${displayData.stIntrn![0].toUpperCase()}${displayData.stIntrn!.toLowerCase().replaceAll("_", " ").substring(1)}",
                              theme),
                          const SizedBox(height: 4),
                          rowOfInfoData(
                              "Order Id",
                              "${displayData.norenordno}",
                              "Date & Time",
                              formatDateTime(value: displayData.norentm!),
                              theme),
                          //
                          if (displayData.rejreason != null) ...[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text("Rejected Reason",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                12,
                                                FontWeight.w500)),
                                        const SizedBox(height: 3),
                                        Text('${displayData.rejreason}',
                                            style: textStyle(colors.darkred, 14,
                                                FontWeight.w500)),
                                      ]))
                                ]),
                            const SizedBox(height: 10),
                          ]
                        ])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Order Status",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : const Color(0xff26324A),
                              16,
                              FontWeight.w600)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(displayData.status == "COMPLETE"
                              ? assets.completedIcon
                              : displayData.status == "CANCELED" ||
                                      displayData.status == "REJECTED"
                                  ? assets.cancelledIcon
                                  : assets.warningIcon),
                          Text(
                              "  ${displayData.stIntrn![0].toUpperCase()}${displayData.stIntrn!.toLowerCase().replaceAll("_", " ").substring(1)}  ",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  13,
                                  FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (orderHistory!.isNotEmpty && orderHistory[0].stat != "Not_Ok")
                  ListView.builder(
                    reverse: true,
                    itemCount: orderHistory.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return TimeLineWidget(
                          isfFrist: orderHistory.length - 1 == index ? true : false,
                          isLast: index == 0 ? true : false,
                          orderHistoryData: orderHistory[index]);
                    },
                  ),
              ],
            ),
            bottomNavigationBar: displayData.status == "PENDING" ||
                    displayData.status == "OPEN" ||
                    displayData.status == "TRIGGER_PENDING"
                ? BottomAppBar(
                    shape: const CircularNotchedRectangle(),
                    child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(children: [
                          if ((displayData.sPrdtAli == "BO" ||
                                  displayData.sPrdtAli == "CO") &&
                              displayData.snonum != null) ...[
                            Expanded(
                                child: SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                          backgroundColor: const Color(0XFFD34645),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50),
                                          )),
                                      onPressed: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: theme.isDarkMode
                                                    ? const Color.fromARGB(
                                                        255, 18, 18, 18)
                                                    : colors.colorWhite,
                                                titleTextStyle: textStyles
                                                    .appBarTitleTxt
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack),
                                                contentTextStyle:
                                                    textStyles.menuTxt,
                                                titlePadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 12),
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(14))),
                                                scrollable: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                ),
                                                insetPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                title: const Text("Exit Position"),
                                                content: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          "Are you sure you want to exit a position ?")
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: Text("No",
                                                          style: textStyles.textBtn.copyWith(
                                                              color: theme
                                                                      .isDarkMode
                                                                  ? colors
                                                                      .colorLightBlue
                                                                  : colors
                                                                      .colorBlue))),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      await watch(orderProvider)
                                                          .fetchExitSNOOrd(
                                                              "${displayData.snonum}",
                                                              "${displayData.prd}",
                                                              context,
                                                              true);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        elevation: 0,
                                                        backgroundColor:
                                                            theme.isDarkMode
                                                                ? colors.colorWhite
                                                                : colors.colorBlack,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  50),
                                                        )),
                                                    child: Text("Yes",
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors.colorBlack
                                                                : colors.colorWhite,
                                                            14,
                                                            FontWeight.w500)),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      child: Text("Exit",
                                          style: textStyle(const Color(0XFFFFFFFF),
                                              14, FontWeight.w600)),
                                    )))
                          ] else ...[
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: theme.isDarkMode
                                            ? const Color.fromARGB(255, 18, 18, 18)
                                            : colors.colorWhite,
                                        titleTextStyle: textStyle(
                                            !theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorWhite,
                                            17,
                                            FontWeight.w600),
                                        contentTextStyle: textStyle(
                                            const Color(0XFF666666),
                                            14,
                                            FontWeight.w500),
                                        titlePadding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(14))),
                                        scrollable: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        insetPadding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        title: Row(
                                          children: [
                                            Text("${displayData.tsym}"),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: const Color(0xffF1F3F8),
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Text("${displayData.exch}",
                                                  style: textStyle(
                                                      const Color(0XFF666666),
                                                      10,
                                                      FontWeight.w600)),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: const Color(0xffFCF3F3),
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Text("${displayData.status}",
                                                  style: textStyle(colors.darkred,
                                                      10, FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                        content: SizedBox(
                                          width: MediaQuery.of(context).size.width,
                                          child: const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Do you want to Cancel this order?")
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "No",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorLightBlue
                                                        : colors.colorBlue,
                                                    14,
                                                    FontWeight.w500),
                                              )),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(50),
                                                  )),
                                              onPressed: () async {
                                                await context
                                                    .read(orderProvider)
                                                    .fetchOrderCancel(
                                                        "${displayData.norenordno}",
                                                        context,
                                                        true);
                                              },
                                              child: Text(
                                                "Yes",
                                                style: textStyle(
                                                    !theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500),
                                              )),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      borderRadius: BorderRadius.circular(108)),
                                  child: Center(
                                    child: Text("Cancel Order",
                                        style: textStyle(
                                            !theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await context
                                    .read(marketWatchProvider)
                                    .fetchScripInfo("${displayData.token}",
                                        '${displayData.exch}', context);

                                OrderScreenArgs orderArgs = OrderScreenArgs(
                                    exchange: '${displayData.exch}',
                                    tSym: '${displayData.tsym}',
                                    isExit: false,
                                    token: "${displayData.token}",
                                    transType: true,
                                    lotSize: displayData.ls,
                                    ltp: displayData.ltp,
                                    perChange: displayData.perChange,
                                    orderTpye: '',
                                    holdQty: '',
                                    isModify: false,
                                    raw: {});
                                Navigator.pop(context);
                                Navigator.pushNamed(context, Routes.modifyOrder,
                                    arguments: {
                                      "modifyOrderArgs": displayData,
                                      "orderArg": orderArgs,
                                      "scripInfo": context
                                          .read(marketWatchProvider)
                                          .scripInfoModel!
                                    });
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack),
                                    borderRadius: BorderRadius.circular(108)),
                                child: Center(
                                  child: Text("Modify Order",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                        ])))
                : BottomAppBar(
                    shape: const CircularNotchedRectangle(),
                    child: Container(
                        height: 38,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? colors.colorbluegrey
                                : colors.colorBlack,
                            borderRadius: BorderRadius.circular(32)),
                        width: MediaQuery.of(context).size.width,
                        child: InkWell(
                          onTap: () async {
                            Navigator.pop(context);

                            await watch(marketWatchProvider).fetchScripInfo(
                                "${displayData.token}",
                                "${displayData.exch}",
                                context, true);

                            OrderScreenArgs orderArgs = OrderScreenArgs(
                                exchange: displayData.exch.toString(),
                                tSym: displayData.tsym.toString(),
                                isExit: false,
                                token: displayData.token.toString(),
                                transType:
                                    displayData.trantype == 'B' ? true : false,
                                lotSize: displayData.ls,
                                ltp:
                                    "${displayData.ltp ?? displayData.c ?? 0.00}",
                                perChange: displayData.change ?? "0.00",
                                orderTpye: '',
                                holdQty: '',
                                isModify: false,
                                raw: displayData.toJson());

                            // Navigator.pop(context);
                            Navigator.pushNamed(context, Routes.placeOrderScreen,
                                arguments: {
                                  "orderArg": orderArgs,
                                  "scripInfo": context
                                      .read(marketWatchProvider)
                                      .scripInfoModel!,
                                  "isBskt": ''
                                });
                          },
                          child: Center(
                              child: Text("Repeat order",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600))),
                        )),
              ));
      }
    );
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      ThemesProvider theme) {
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
}
