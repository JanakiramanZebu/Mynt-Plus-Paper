import 'dart:async';
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

class OrderBookDetail extends StatefulWidget {
  final OrderBookModel orderBookData;
  const OrderBookDetail({super.key, required this.orderBookData});

  @override
  State<OrderBookDetail> createState() => _OrderBookDetailState();
}

class _OrderBookDetailState extends State<OrderBookDetail> {
  StreamSubscription? _socketSubscription;
  
  // Local cached copy of order data
  late OrderBookModel displayData;
  
  // Throttling properties
  DateTime _lastSocketUpdateTime = DateTime.now();
  static const Duration _minUpdateInterval = Duration(milliseconds: 200);
  
  @override
  void initState() {
    super.initState();
    // Create a deep copy to avoid modifying the original
    displayData = _createDeepCopy(widget.orderBookData);
    
    // Set initial valid values
    _ensureValidValues();
    
    // Setup socket subscription
    Future.microtask(() {
      final socketProvider = context.read(websocketProvider);
      
      _socketSubscription = socketProvider.socketDataStream.listen((socketDatas) {
        if (socketDatas.isEmpty) return;
        
        // Apply throttling to avoid rapid updates
        final now = DateTime.now();
        if (now.difference(_lastSocketUpdateTime) < _minUpdateInterval) {
          return; // Skip this update if too frequent
        }
        
        _lastSocketUpdateTime = now;
        _updateFromSocketData(socketDatas);
      });
    });
  }
  
  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }
  
  // Creates a deep copy of order data to avoid modifying the original
  OrderBookModel _createDeepCopy(OrderBookModel original) {
    // Create a deep copy by copying all fields explicitly to ensure nothing is lost
    final copy = OrderBookModel.fromJson(original.toJson());
    
    // Ensure critical fields like change and perChange are explicitly copied
    // (in case the model's fromJson doesn't handle them correctly)
    if (original.change != null) copy.change = original.change;
    if (original.perChange != null) copy.perChange = original.perChange;
    if (original.ltp != null) copy.ltp = original.ltp;
    if (original.c != null) copy.c = original.c;
    if (original.close != null) copy.close = original.close;
    
    return copy;
  }
  
  // Ensure all values have valid defaults
  void _ensureValidValues() {
    // Print original data for debugging
    print("Initial LTP: ${displayData.ltp}, Change: ${displayData.change}, PerChange: ${displayData.perChange}, Close: ${displayData.c}");
    
    // Get best available price if LTP is missing
    if (displayData.ltp == null || displayData.ltp == "null" || displayData.ltp == "0" || displayData.ltp == "0.00") {
      final price = _findBestAvailablePrice();
      if (price != "0.00") {
        displayData.ltp = price;
      }
    }
    
    // Make sure close price is set
    if ((displayData.c == null || displayData.c == "null") && displayData.close != null && displayData.close != "null") {
      displayData.c = displayData.close;
    } else if ((displayData.close == null || displayData.close == "null") && displayData.c != null && displayData.c != "null") {
      displayData.close = displayData.c;
    }
    
    // Calculate change and percentage change if they're missing or invalid
    // but we have valid LTP and close price
    final ltp = double.tryParse(displayData.ltp ?? "0.00") ?? 0.0;
    final closePrice = double.tryParse(displayData.c ?? "0.00") ?? 0.0;
    
    if (ltp > 0 && closePrice > 0) {
      // Calculate absolute change if it's missing or invalid
      if (displayData.change == null || displayData.change == "null" || displayData.change == "0") {
        displayData.change = (ltp - closePrice).toStringAsFixed(2);
      }
      
      // Calculate percentage change if it's missing or invalid
      if (displayData.perChange == null || displayData.perChange == "null" || displayData.perChange == "0") {
        displayData.perChange = ((ltp - closePrice) * 100 / closePrice).toStringAsFixed(2);
      }
    } else {
      // Set defaults if we couldn't calculate
      if (displayData.change == null || displayData.change == "null") {
        displayData.change = "0.00";
      }
      
      if (displayData.perChange == null || displayData.perChange == "null") {
        displayData.perChange = "0.00";
      }
    }
    
    // Print final values for debugging
    print("After initialization - LTP: ${displayData.ltp}, Change: ${displayData.change}, PerChange: ${displayData.perChange}, Close: ${displayData.c}");
  }
  
  // Find the best available price from various price fields
  String _findBestAvailablePrice() {
    if (displayData.avgprc != null && displayData.avgprc != "null" && displayData.avgprc != "0" && displayData.avgprc != "0.00") {
      return displayData.avgprc!;
    } else if (displayData.prc != null && displayData.prc != "null" && displayData.prc != "0" && displayData.prc != "0.00") {
      return displayData.prc!;
    } else if (displayData.c != null && displayData.c != "null" && displayData.c != "0" && displayData.c != "0.00") {
      return displayData.c!;
    } else if (displayData.close != null && displayData.close != "null" && displayData.close != "0" && displayData.close != "0.00") {
      return displayData.close!;
    }
    return "0.00";
  }
  
  // Update display data from socket data
  void _updateFromSocketData(Map socketDatas) {
    if (displayData.token == null || !socketDatas.containsKey(displayData.token)) {
      return;
    }
    
    final socketData = socketDatas[displayData.token];
    if (socketData == null || socketData.isEmpty) {
      return;
    }
    
    bool hasUpdates = false;
    
    // Update LTP if valid
          final lp = socketData['lp']?.toString();
    if (lp != null && lp != "null" && lp != "0" && lp != "0.00" && lp != displayData.ltp) {
            displayData.ltp = lp;
      hasUpdates = true;
          }
          
    // Update percent change if valid - don't filter out "0.00" values as they could be valid
          final pc = socketData['pc']?.toString();
    if (pc != null && pc != "null" && pc != displayData.perChange) {
            displayData.perChange = pc;
      hasUpdates = true;
          }
          
    // Update change if valid - don't filter out "0.00" values as they could be valid
    final chng = socketData['chng']?.toString();
    if (chng != null && chng != "null" && chng != displayData.change) {
            displayData.change = chng;
      hasUpdates = true;
    }
    
    // If we have LTP but either change or perChange is missing/invalid, recalculate them
    if (displayData.ltp != null && displayData.ltp != "null" && displayData.ltp != "0" && displayData.ltp != "0.00") {
      if (displayData.c != null && displayData.c != "null" && displayData.c != "0" && displayData.c != "0.00") {
        final ltp = double.tryParse(displayData.ltp!) ?? 0.0;
        final closePrice = double.tryParse(displayData.c!) ?? 0.0;
        
        if (ltp > 0 && closePrice > 0) {
          // Calculate change if it's missing or invalid
          if (displayData.change == null || displayData.change == "null" || displayData.change == "0") {
            final change = (ltp - closePrice).toStringAsFixed(2);
            if (change != displayData.change) {
              displayData.change = change;
              hasUpdates = true;
            }
          }
          
          // Calculate percentage change if it's missing or invalid
          if (displayData.perChange == null || displayData.perChange == "null" || displayData.perChange == "0") {
            final perChange = closePrice > 0 ? ((ltp - closePrice) * 100 / closePrice).toStringAsFixed(2) : "0.00";
            if (perChange != displayData.perChange) {
              displayData.perChange = perChange;
              hasUpdates = true;
            }
          }
        }
      }
    }
    
    // Only rebuild if we have actual updates
    if (hasUpdates && mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final orderHistory = context.read(orderProvider).orderHistoryModel;
    final theme = context.read(themeProvider);
        
        return Scaffold(
            appBar: AppBar(
                elevation: .2,
                leadingWidth: 41,
                centerTitle: false,
                titleSpacing: 6,
                leading: const CustomBackBtn(),
                shadowColor: const Color(0xffECEFF3),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
            _buildHeaderRow(theme),
                  const SizedBox(height: 4),
            _buildSubheaderRow(theme),
          ]
        )
      ),
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
                Text(
                  "Order details",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  16,
                    FontWeight.w600
                  )
                ),
                          const SizedBox(height: 16),
                _buildOrderDetailsSection(theme),
                if (displayData.rejreason != null) ...[
                  _buildRejectionReasonSection(),
                  const SizedBox(height: 10),
                ]
              ]
            )
          ),
          _buildOrderStatusSection(orderHistory, theme),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(theme),
    );
  }
  
  Widget _buildHeaderRow(ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "${displayData.symbol}",
              style: textStyles.appBarTitleTxt.copyWith(
                color: theme.isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack
              )
            ),
            Text(
              " ${displayData.option} ",
              overflow: TextOverflow.ellipsis,
              style: textStyles.scripNameTxtStyle.copyWith(
                color: theme.isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack
              )
            ),
          ],
        ),
        // Wrap in RepaintBoundary since LTP updates frequently
        RepaintBoundary(
          child: Text(
            "₹${displayData.ltp ?? '0.00'}",
            style: textStyle(
              theme.isDarkMode
                ? colors.colorWhite
                : colors.colorBlack,
              16,
              FontWeight.w600
            )
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubheaderRow(ThemesProvider theme) {
    // Format the change and percentage change text
    String changeText = "0.00";
    if (displayData.change != null && displayData.change != "null") {
      try {
        changeText = double.parse(displayData.change!).toStringAsFixed(2);
      } catch (_) {
        // If parsing fails, use the original string but ensure it's not null
        changeText = displayData.change ?? "0.00";
      }
    }
    
    // Ensure percentage change is a valid value
    String percentageText = "0.00";
    if (displayData.perChange != null && displayData.perChange != "null") {
      try {
        percentageText = double.parse(displayData.perChange!).toStringAsFixed(2);
      } catch (_) {
        // If parsing fails, use the original string but ensure it's not null
        percentageText = displayData.perChange ?? "0.00";
      }
    }
      
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            CustomExchBadge(exch: displayData.exch!),
            Text(
              "  ${displayData.expDate}",
              style: textStyle(
                theme.isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack,
                12,
                FontWeight.w600
              )
            )
          ]
        ),
        // Wrap in RepaintBoundary as this updates frequently
        RepaintBoundary(
          child: Text(
            "$changeText ($percentageText%)",
            style: textStyle(
              _getChangeColor(changeText),
              12,
              FontWeight.w500
            )
          ),
        )
      ]
    );
  }
  
  Color _getChangeColor(String changeValue) {
    if (changeValue == "0.00" || changeValue == "null") {
      return colors.ltpgrey;
    }
    return changeValue.startsWith("-") ? colors.darkred : colors.ltpgreen;
  }
  
  Widget _buildOrderDetailsSection(ThemesProvider theme) {
    return Column(
      children: [
                          rowOfInfoData(
                              "Transaction Type",
                              displayData.trantype == "B" ? "Buy" : "Sell",
                              "Price Type",
                              "${displayData.prctyp}",
          theme
        ),
                          const SizedBox(height: 4),
                          rowOfInfoData(
                              "Price",
                              "${displayData.prc}",
                              "Avg.Price",
                              "${displayData.avgprc ?? 0.00}",
          theme
        ),
        const SizedBox(height: 4),
        rowOfInfoData(
          "Trigger Price",
          "${displayData.trgprc ?? 0.00}",
          "",
          "",
          theme
        ),
                          const SizedBox(height: 4),
        _buildQuantityInfoRow(theme),
                          const SizedBox(height: 4),
                          rowOfInfoData(
          "Validity",
          "${displayData.ret}",
          "Product",
          "${displayData.sPrdtAli}",
          theme
        ),
                          const SizedBox(height: 4),
                          rowOfInfoData(
                              "After Market Order",
                              displayData.amo ?? "-",
                              "Status",
                              "${displayData.stIntrn![0].toUpperCase()}${displayData.stIntrn!.toLowerCase().replaceAll("_", " ").substring(1)}",
          theme
        ),
                          const SizedBox(height: 4),
                          rowOfInfoData(
                              "Order Id",
                              "${displayData.norenordno}",
                              "Date & Time",
                              formatDateTime(value: displayData.norentm!),
          theme
        ),
      ],
    );
  }
  
  Widget _buildQuantityInfoRow(ThemesProvider theme) {
    // Calculate quantity display with lot size adjustment
    final filledQty = displayData.status != "COMPLETE" && (displayData.fillshares?.isNotEmpty ?? false) 
      ? (int.tryParse(displayData.fillshares.toString()) ?? 0) 
      : displayData.status == "COMPLETE" 
        ? (int.tryParse(displayData.rqty.toString()) ?? 0) 
        : (int.tryParse(displayData.dscqty.toString()) ?? 0);
    
    final lotSize = displayData.exch == 'MCX' 
      ? (int.tryParse(displayData.ls.toString()) ?? 1) 
      : 1;
    
    final displayFilledQty = (filledQty / lotSize).toInt();
    final displayTotalQty = ((int.tryParse(displayData.qty.toString()) ?? 0) / lotSize).toInt();
    
    return rowOfInfoData(
      "Filled Qty",
      "$displayFilledQty/$displayTotalQty",
      "MKT Protection",
      displayData.mktProtection ?? "-",
      theme
    );
  }
  
  Widget _buildRejectionReasonSection() {
    return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
              Text(
                "Rejected Reason",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                12,
                  FontWeight.w500
                )
              ),
                                        const SizedBox(height: 3),
              Text(
                '${displayData.rejreason}',
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
    );
  }
  
  Widget _buildOrderStatusSection(List<dynamic>? orderHistory, ThemesProvider theme) {
    return Column(
      children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
              Text(
                "Order Status",
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
                  SvgPicture.asset(
                    displayData.status == "COMPLETE"
                              ? assets.completedIcon
                      : displayData.status == "CANCELED" || displayData.status == "REJECTED"
                                  ? assets.cancelledIcon
                        : assets.warningIcon
                  ),
                          Text(
                              "  ${displayData.stIntrn![0].toUpperCase()}${displayData.stIntrn!.toLowerCase().replaceAll("_", " ").substring(1)}  ",
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
        if (orderHistory != null && orderHistory.isNotEmpty && orderHistory[0].stat != "Not_Ok")
          _buildOrderHistoryTimeline(orderHistory),
      ],
    );
  }
  
  Widget _buildOrderHistoryTimeline(List<dynamic> orderHistory) {
    return ListView.builder(
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
    );
  }
  
  Widget? _buildBottomActionBar(ThemesProvider theme) {
    if (displayData.status != "PENDING" && 
        displayData.status != "OPEN" && 
        displayData.status != "TRIGGER_PENDING") {
      return null;
    }
    
    return BottomAppBar(
                    shape: const CircularNotchedRectangle(),
                    child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if ((displayData.sPrdtAli == "BO" || displayData.sPrdtAli == "CO") && 
                displayData.snonum != null) 
              _buildExitButton(theme)
            else 
              _buildCancelButton(theme)
          ]
        )
      ),
    );
  }
  
  Widget _buildExitButton(ThemesProvider theme) {
    return Expanded(
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
            _showExitConfirmationDialog(theme);
          },
          child: Text(
            "Exit",
            style: textStyle(
              const Color(0XFFFFFFFF),
              14,
              FontWeight.w600
            )
          ),
        )
      )
    );
  }
  
  Widget _buildCancelButton(ThemesProvider theme) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          _showCancelConfirmationDialog(theme);
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0XFFD34645),
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            "Cancel",
            style: textStyle(
              const Color(0XFFFFFFFF),
              14,
              FontWeight.w600
            )
          ),
        ),
      )
    );
  }
  
  void _showExitConfirmationDialog(ThemesProvider theme) {
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
                                                            : colors.colorBlack),
          contentTextStyle: textStyles.menuTxt,
          titlePadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
                                                shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
                                                scrollable: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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
              child: Text(
                "No",
                                                          style: textStyles.textBtn.copyWith(
                  color: theme.isDarkMode
                    ? colors.colorLightBlue
                    : colors.colorBlue
                )
              )
            ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                Navigator.of(context).pop();
                await context.read(orderProvider).fetchExitSNOOrd(
                                                              "${displayData.snonum}",
                                                              "${displayData.prd}",
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
              child: Text(
                "Yes",
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
  
  void _showCancelConfirmationDialog(ThemesProvider theme) {
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
                margin: const EdgeInsets.only(left: 8),
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
                margin: const EdgeInsets.only(left: 8),
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
              onPressed: () => Navigator.of(context).pop(),
                                              child: Text(
                                                "No",
                style: textStyles.textBtn.copyWith(
                  color: theme.isDarkMode
                                                        ? colors.colorLightBlue
                      : colors.colorBlue),
              ),
            ),
                                          ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read(orderProvider).fetchOrderCancel(
                  "${displayData.norenordno}", 
                  context,
                  true
                );
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  Routes.homeScreen, 
                  (route) => false, 
                  arguments: 1
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
                                              child: Text(
                                                "Yes",
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
