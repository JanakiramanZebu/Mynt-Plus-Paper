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

class OrderBookDetail extends StatelessWidget {
  final OrderBookModel orderBookData;
  const OrderBookDetail({super.key, required this.orderBookData});

  @override
  Widget build(BuildContext context) {
    // Use read for static data that doesn't need to trigger rebuilds
    final theme = context.read(themeProvider);
    
    return Scaffold(
      appBar: AppBar(
        elevation: .2,
        leadingWidth: 41,
        centerTitle: false,
        titleSpacing: 6,
        leading: const CustomBackBtn(),
        shadowColor: const Color(0xffECEFF3),
        title: _OrderAppBarTitle(orderBookData: orderBookData),
      ),
      body: _OrderDetailBody(orderBookData: orderBookData),
      bottomNavigationBar: _BottomActionBar(orderBookData: orderBookData),
    );
  }
}

// Extracted AppBar title component
class _OrderAppBarTitle extends ConsumerWidget {
  final OrderBookModel orderBookData;
  
  const _OrderAppBarTitle({required this.orderBookData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    
    // Only watch the WebSocket data for this specific symbol
    return Consumer(
      builder: (context, watch, _) {
        final socketData = watch(websocketProvider).socketDataStream;
        
        return StreamBuilder<Map>(
          stream: socketData,
          builder: (context, snapshot) {
            // Initialize display data with original
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
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
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
                        FontWeight.w500)
                    )
                  ]
                )
              ]
            );
          }
        );
      }
    );
  }
}

// Main body of the order detail
class _OrderDetailBody extends ConsumerWidget {
  final OrderBookModel orderBookData;
  
  const _OrderDetailBody({required this.orderBookData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    // Only watch the specific data needed
    final orderHistory = watch(orderProvider).orderHistoryModel;
    
    return ListView(
      children: [
        ScripInfoBtns(
          exch: '${orderBookData.exch}',
          token: '${orderBookData.token}',
          insName: '',
          tsym: '${orderBookData.tsym}'
        ),
        
        // Order details section
        _OrderDetailsSection(orderBookData: orderBookData),
        
        // Order status header
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
                  FontWeight.w600
                )
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(orderBookData.status == "COMPLETE"
                    ? assets.completedIcon
                    : orderBookData.status == "CANCELED" ||
                            orderBookData.status == "REJECTED"
                        ? assets.cancelledIcon
                        : assets.warningIcon),
                  Text(
                    "  ${orderBookData.stIntrn![0].toUpperCase()}${orderBookData.stIntrn!.toLowerCase().replaceAll("_", " ").substring(1)}  ",
                    style: textStyle(
                      theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                      13,
                      FontWeight.w500
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Order history timeline
        if (orderHistory != null && orderHistory.isNotEmpty && orderHistory[0].stat != "Not_Ok")
          ListView.builder(
            reverse: true,
            itemCount: orderHistory.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return TimeLineWidget(
                isfFrist: orderHistory.length - 1 == index ? true : false,
                isLast: index == 0 ? true : false,
                orderHistoryData: orderHistory[index]
              );
            },
          ),
      ],
    );
  }
}

// Extracted order details section
class _OrderDetailsSection extends StatelessWidget {
  final OrderBookModel orderBookData;
  
  const _OrderDetailsSection({required this.orderBookData});

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    
    return Container(
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
              FontWeight.w600
            )
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            "Transaction Type",
            orderBookData.trantype == "B" ? "Buy" : "Sell",
            "Price Type",
            "${orderBookData.prctyp}",
            theme
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            "Price",
            "${orderBookData.prc}",
            "Avg.Price",
            "${orderBookData.avgprc ?? 0.00}",
            theme
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            "Trigger Price",
            "${orderBookData.trgprc ?? 0.00}", 
            "", 
            "", 
            theme
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            "Filled Qty",
            "${((orderBookData.status != "COMPLETE" && (orderBookData.fillshares?.isNotEmpty ?? false) ? (int.tryParse(orderBookData.fillshares.toString()) ?? 0) : orderBookData.status == "COMPLETE" ? (int.tryParse(orderBookData.rqty.toString()) ?? 0) : (int.tryParse(orderBookData.dscqty.toString()) ?? 0)).toInt() / (orderBookData.exch == 'MCX' ? (int.tryParse(orderBookData.ls.toString()) ?? 1) : 1)).toInt()}/${((int.tryParse(orderBookData.qty.toString()) ?? 0) / (orderBookData.exch == 'MCX' ? (int.tryParse(orderBookData.ls.toString()) ?? 1) : 1)).toInt()}",
            "MKT Protection",
            orderBookData.mktProtection ?? "-",
            theme
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            "Validity", 
            "${orderBookData.ret}",
            "Product", 
            "${orderBookData.sPrdtAli}", 
            theme
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            "After Market Order",
            orderBookData.amo ?? "-",
            "Status",
            "${orderBookData.stIntrn![0].toUpperCase()}${orderBookData.stIntrn!.toLowerCase().replaceAll("_", " ").substring(1)}",
            theme
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            "Order Id",
            "${orderBookData.norenordno}",
            "Date & Time",
            formatDateTime(value: orderBookData.norentm!),
            theme
          ),
          
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
                      Text("Rejected Reason",
                        style: textStyle(
                          const Color(0xff666666),
                          12,
                          FontWeight.w500
                        )
                      ),
                      const SizedBox(height: 3),
                      Text('${orderBookData.rejreason}',
                        style: textStyle(
                          colors.darkred, 
                          14,
                          FontWeight.w500
                        )
                      ),
                    ]
                  )
                )
              ]
            ),
            const SizedBox(height: 10),
          ]
        ]
      )
    );
  }
  
  Widget _buildInfoRow(String title1, String value1, String title2, String value2, ThemesProvider theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(title1,
                style: textStyle(const Color(0xff666666), 12, FontWeight.w500)
              ),
              const SizedBox(height: 2),
              Text(value1,
                style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500
                )
              ),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider
              )
            ]
          )
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(title2,
                style: textStyle(const Color(0xff666666), 12, FontWeight.w500)
              ),
              const SizedBox(height: 2),
              Text(
                value2,
                style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500
                ),
              ),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider
              )
            ]
          )
        )
      ]
    );
  }
}

// Bottom action bar for order actions
class _BottomActionBar extends ConsumerWidget {
  final OrderBookModel orderBookData;
  
  const _BottomActionBar({required this.orderBookData});
  
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    
    // Show different bottom bar based on order status
    if (orderBookData.status == "PENDING" ||
        orderBookData.status == "OPEN" ||
        orderBookData.status == "TRIGGER_PENDING") {
      return _buildActionButtonsBar(context, theme);
    } else {
      return _buildRepeatOrderBar(context, theme);
    }
  }
  
  Widget _buildActionButtonsBar(BuildContext context, ThemesProvider theme) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if ((orderBookData.sPrdtAli == "BO" ||
                orderBookData.sPrdtAli == "CO") &&
                orderBookData.snonum != null) ...[
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
                      )
                    ),
                    onPressed: () async {
                      _showExitPositionDialog(context, theme);
                    },
                    child: Text("Exit",
                      style: textStyle(const Color(0XFFFFFFFF),
                        14, FontWeight.w600)
                    ),
                  )
                )
              )
            ] else ...[
              Expanded(
                child: InkWell(
                  onTap: () async {
                    _showCancelOrderDialog(context, theme);
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                      borderRadius: BorderRadius.circular(108)
                    ),
                    child: Center(
                      child: Text("Cancel Order",
                        style: textStyle(
                          !theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                          14,
                          FontWeight.w600
                        )
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () async {
                  await _navigateToModifyOrder(context);
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack
                    ),
                    borderRadius: BorderRadius.circular(108)
                  ),
                  child: Center(
                    child: Text("Modify Order",
                      style: textStyle(
                        theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                        14,
                        FontWeight.w600
                      )
                    ),
                  ),
                ),
              ),
            ),
          ]
        )
      )
    );
  }
  
  Widget _buildRepeatOrderBar(BuildContext context, ThemesProvider theme) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: theme.isDarkMode
            ? colors.colorbluegrey
            : colors.colorBlack,
          borderRadius: BorderRadius.circular(32)
        ),
        width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: () async {
            await _navigateToPlaceOrder(context);
          },
          child: Center(
            child: Text("Repeat order",
              style: textStyle(
                !theme.isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack,
                14,
                FontWeight.w600
              )
            )
          ),
        )
      ),
    );
  }
  
  void _showExitPositionDialog(BuildContext context, ThemesProvider theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.isDarkMode
            ? const Color.fromARGB(255, 18, 18, 18)
            : colors.colorWhite,
          titleTextStyle: textStyles.appBarTitleTxt.copyWith(
            color: theme.isDarkMode
              ? colors.colorWhite
              : colors.colorBlack
          ),
          contentTextStyle: textStyles.menuTxt,
          titlePadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))
          ),
          scrollable: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Text("Exit Position"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Are you sure you want to exit a position ?")
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No",
                style: textStyles.textBtn.copyWith(
                  color: theme.isDarkMode
                    ? colors.colorLightBlue
                    : colors.colorBlue
                )
              )
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read(orderProvider).fetchExitSNOOrd(
                  "${orderBookData.snonum}",
                  "${orderBookData.prd}",
                  context,
                  true
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: theme.isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                )
              ),
              child: Text("Yes",
                style: textStyle(
                  theme.isDarkMode
                    ? colors.colorBlack
                    : colors.colorWhite,
                  14,
                  FontWeight.w500
                )
              ),
            ),
          ],
        );
      }
    );
  }
  
  void _showCancelOrderDialog(BuildContext context, ThemesProvider theme) {
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
            FontWeight.w600
          ),
          contentTextStyle: textStyle(
            const Color(0XFF666666),
            14,
            FontWeight.w500
          ),
          titlePadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))
          ),
          scrollable: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Row(
            children: [
              Text("${orderBookData.tsym}"),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F3F8),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text("${orderBookData.exch}",
                  style: textStyle(
                    const Color(0XFF666666),
                    10,
                    FontWeight.w600
                  )
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffFCF3F3),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text("${orderBookData.status}",
                  style: textStyle(
                    colors.darkred,
                    10, 
                    FontWeight.w600
                  )
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Do you want to Cancel this order?")
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
                  FontWeight.w500
                ),
              )
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: theme.isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                )
              ),
              onPressed: () async {
                await context.read(orderProvider).fetchOrderCancel(
                  "${orderBookData.norenordno}",
                  context,
                  true
                );
              },
              child: Text(
                "Yes",
                style: textStyle(
                  !theme.isDarkMode
                    ? colors.colorWhite
                    : colors.colorBlack,
                  14,
                  FontWeight.w500
                ),
              )
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _navigateToModifyOrder(BuildContext context) async {
    await context.read(marketWatchProvider).fetchScripInfo(
      "${orderBookData.token}",
      '${orderBookData.exch}', 
      context
    );

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
      raw: {}
    );
    
    Navigator.pop(context);
    Navigator.pushNamed(context, Routes.modifyOrder,
      arguments: {
        "modifyOrderArgs": orderBookData,
        "orderArg": orderArgs,
        "scripInfo": context.read(marketWatchProvider).scripInfoModel!
      }
    );
  }
  
  Future<void> _navigateToPlaceOrder(BuildContext context) async {
    Navigator.pop(context);

    await context.read(marketWatchProvider).fetchScripInfo(
      "${orderBookData.token}",
      "${orderBookData.exch}",
      context, 
      true
    );

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
      raw: orderBookData.toJson()
    );

    Navigator.pushNamed(context, Routes.placeOrderScreen,
      arguments: {
        "orderArg": orderArgs,
        "scripInfo": context.read(marketWatchProvider).scripInfoModel!,
        "isBskt": ''
      }
    );
  }
}
