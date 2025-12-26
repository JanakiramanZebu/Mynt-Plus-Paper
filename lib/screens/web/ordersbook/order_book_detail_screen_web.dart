import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/time_line.dart';
import '../../../utils/responsive_navigation.dart';
import '../order/modify_place_order_web_screen.dart';

class OrderBookDetailScreenWeb extends ConsumerStatefulWidget {
  final OrderBookModel orderBookData;

  const OrderBookDetailScreenWeb({
    super.key,
    required this.orderBookData,
  });

  @override
  ConsumerState<OrderBookDetailScreenWeb> createState() => _OrderBookDetailScreenWebState();
}

class _OrderBookDetailScreenWebState extends ConsumerState<OrderBookDetailScreenWeb>
    with SingleTickerProviderStateMixin {
  late OrderBookModel _orderData;
  late AnimationController _animationController;

  // Track processing states
  bool _isProcessingCancel = false;
  bool _isProcessingModify = false;
  bool _hasFetchedOrderHistory = false; // Track if we've already fetched order history
  bool _showOrderHistory = false; // Track whether to show order history or details

  @override
  void initState() {
    super.initState();
    // Make a copy of the order data to avoid modifying the original
    _orderData = _copyOrderData(widget.orderBookData);

    // Set up animation controller for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Order history will be fetched in build method when ref is available

    // Socket subscription is now handled by StreamBuilder
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Create a copy of the OrderBookModel to avoid modifying the original
  OrderBookModel _copyOrderData(OrderBookModel original) {
    final copy = OrderBookModel();
    copy.token = original.token;
    copy.exch = original.exch;
    copy.tsym = original.tsym;
    copy.symbol = original.symbol;
    copy.expDate = original.expDate;
    copy.option = original.option;
    copy.ltp = original.ltp;
    copy.perChange = original.perChange;
    copy.change = original.change;
    copy.close = original.close;
    copy.status = original.status;
    copy.trantype = original.trantype;
    copy.qty = original.qty;
    copy.prc = original.prc;
    copy.avgprc = original.avgprc;
    copy.trgprc = original.trgprc;
    copy.sPrdtAli = original.sPrdtAli;
    copy.prctyp = original.prctyp;
    copy.norenordno = original.norenordno;
    copy.exchordid = original.exchordid;
    copy.norentm = original.norentm;
    copy.rejreason = original.rejreason;
    copy.fillshares = original.fillshares;
    copy.rqty = original.rqty;
    copy.dscqty = original.dscqty;
    copy.ls = original.ls;
    copy.mktProtection = original.mktProtection;
    copy.amo = original.amo;
    copy.snonum = original.snonum;
    copy.prd = original.prd;
    return copy;
  }


  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(themeProvider);
        final marketwatch = ref.watch(marketWatchProvider);
        final orderHistory = ref.watch(orderProvider).orderHistoryModel;
        // final order = ref.watch(orderProvider); // Not used anymore after commenting out action buttons

        // Automatically fetch order history when dialog opens (only once)
        if (!_hasFetchedOrderHistory) {
          _hasFetchedOrderHistory = true;
          final orderNumber = widget.orderBookData.norenordno?.toString() ?? '';
          if (orderNumber.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ref.read(orderProvider).fetchOrderHistory(orderNumber, context);
                ref.read(orderProvider).showorderHistory(true);
              }
            });
          }
        }

        return StreamBuilder<Map>(
          stream: ref.watch(websocketProvider).socketDataStream,
          builder: (context, snapshot) {
            final socketDatas = snapshot.data ?? {};

            // Create a copy of order data for real-time updates
            OrderBookModel updatedOrderData = _orderData;

            // Update order data with real-time values if available
            if (socketDatas.containsKey(_orderData.token)) {
              final lp = socketDatas["${_orderData.token}"]['lp']?.toString();
              final pc = socketDatas["${_orderData.token}"]['pc']?.toString();
              final chng = socketDatas["${_orderData.token}"]['chng']?.toString();

              if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
                updatedOrderData.ltp = lp;
              }

              if (pc != null && pc != "null" && pc != "0" && pc != "0.00") {
                updatedOrderData.perChange = pc;
              }

              if (chng != null && chng != "null") {
                updatedOrderData.change = chng;
              }
            }

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 700,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSymbolSection(theme, marketwatch, updatedOrderData),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.15)
                              : Colors.black.withOpacity(.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.08)
                              : Colors.black.withOpacity(.08),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 0, bottom: 20, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_showOrderHistory) ...[
                          // Order Details Section
                          _buildOrderDetailsSection(theme, updatedOrderData),
                          
                          // Reason Section - Show if reason exists
                          if (updatedOrderData.rejreason != null && updatedOrderData.rejreason!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildReasonWidget(theme, updatedOrderData.rejreason!),
                          ],
                          
                          // Order History Button - Show if history is available
                          if (orderHistory != null &&
                              orderHistory.isNotEmpty &&
                              orderHistory[0].stat != "Not_Ok") ...[
                            const SizedBox(height: 16),
                            _buildOrderHistoryButton(theme),
                          ],
                        ] else ...[
                          // Order History Timeline - Show when _showOrderHistory is true
                          if (orderHistory != null &&
                              orderHistory.isNotEmpty &&
                              orderHistory[0].stat != "Not_Ok") ...[
                            Row(
                              children: [
                                _buildBackButton(theme),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Order History',
                                    style: WebTextStyles.sub(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                      fontWeight: WebFonts.semiBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 8),
                            _buildOrderHistorySection(theme, orderHistory),
                          ],
                        ],
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
  }

  Widget _buildSymbolSection(ThemesProvider theme, MarketWatchProvider marketwatch, OrderBookModel displayData) {
    DepthInputArgs depthArgs = DepthInputArgs(
      exch: displayData.exch ?? "",
      token: displayData.token ?? "",
      tsym: marketwatch.getQuotes?.tsym ?? '',
      instname: marketwatch.getQuotes?.instname ?? "",
      symbol: marketwatch.getQuotes?.symbol ?? '',
      expDate: marketwatch.getQuotes?.expDate ?? '',
      option: marketwatch.getQuotes?.option ?? '',
    );

    return Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: InkWell(
        customBorder: const RoundedRectangleBorder(),
        borderRadius: BorderRadius.circular(0),
        splashColor: theme.isDarkMode ? colors.primaryDark.withOpacity(0.1) : colors.primaryLight.withOpacity(0.1),
        highlightColor: theme.isDarkMode ? colors.primaryDark.withOpacity(0.2) : colors.primaryLight.withOpacity(0.2),
        onTap: () async {
          Navigator.pop(context);
          await marketwatch.scripdepthsize(false);
          await marketwatch.calldepthApis(context, depthArgs, "");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Symbol and Exchange
            Row(
              children: [
                Text(
                  "${displayData.symbol?.replaceAll("-EQ", "") ?? ''} ${displayData.expDate ?? ''} ${displayData.option ?? ''} ",
                  style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  displayData.exch ?? '',
                  style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Price and Change
            Row(
              children: [
                Text(
                  displayData.ltp ?? displayData.close ?? '0.00',
                  style: WebTextStyles.title(
                    isDarkTheme: theme.isDarkMode,
                    color: (displayData.change == "null" || displayData.change == null) ||
                            displayData.change == "0.00"
                        ? theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight
                        : (displayData.change?.startsWith("-") == true || displayData.perChange?.startsWith("-") == true)
                            ? theme.isDarkMode
                                ? colors.lossDark
                                : colors.lossLight
                            : theme.isDarkMode
                                ? colors.profitDark
                                : colors.profitLight,
                    fontWeight: WebFonts.medium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${(double.tryParse(displayData.change ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${displayData.perChange ?? '0.00'}%)",
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fontWeight: WebFonts.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemesProvider theme, OrderProvider order, OrderBookModel displayData) {
    final isPending = displayData.status == "PENDING" || 
                     displayData.status == "OPEN" || 
                     displayData.status == "TRIGGER_PENDING";

    if (isPending) {
      return _buildPendingActionButtons(theme, order, displayData);
    } else {
      return _buildCompletedActionButtons(theme, order, displayData);
    }
  }

  Widget _buildPendingActionButtons(ThemesProvider theme, OrderProvider order, OrderBookModel displayData) {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: _buildActionButton(
            "Cancel",
            false,
            theme,
            _isProcessingCancel ? null : () => _handleCancelOrder(displayData),
            _isProcessingCancel,
          ),
        ),
        const SizedBox(width: 12),
        // Modify Button
        Expanded(
          child: _buildActionButton(
            "Modify",
            true,
            theme,
            _isProcessingModify ? null : () => _handleModifyOrder(displayData),
            _isProcessingModify,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedActionButtons(ThemesProvider theme, OrderProvider order, OrderBookModel displayData) {
    return Row(
      children: [
        // Repeat Order Button
        Expanded(
          child: _buildActionButton(
            "Repeat Order",
            false,
            theme,
            () => _handleRepeatOrder(displayData),
            false,
          ),
        ),
        if (displayData.status == "OPEN") ...[
          const SizedBox(width: 12),
          // Cancel Button for OPEN orders
          Expanded(
            child: _buildActionButton(
              "Cancel",
              true,
              theme,
              _isProcessingCancel ? null : () => _handleCancelOrder(displayData),
              _isProcessingCancel,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, ThemesProvider theme, VoidCallback? onPressed, bool isLoading) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? colors.primaryLight
              : (theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.6)
                  : colors.btnBg),
          foregroundColor: isPrimary
              ? colors.colorWhite
              : (theme.isDarkMode ? colors.colorWhite : colors.primaryLight),
          side: isPrimary
              ? null
              : BorderSide(
                  color: colors.primaryLight,
                  width: 1,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? colors.colorWhite : (theme.isDarkMode ? colors.colorWhite : colors.primaryLight),
                  ),
                ),
              )
            : Text(
                text,
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: false,
                  color: isPrimary ? colors.colorWhite : (theme.isDarkMode ? colors.colorWhite : colors.primaryLight),
                  fw: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildOrderHistoryButton(ThemesProvider theme) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _showOrderHistory = true;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
            //   ),
            //   borderRadius: BorderRadius.circular(8),
            // ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SvgPicture.asset(
                //   assets.orderhistoryicon,
                //   width: 16,
                //   height: 16,
                //   color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                // ),
                // const SizedBox(width: 8),
                Text(
                  "Order History",
                  style: WebTextStyles.buttonMd(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                    fontWeight: WebFonts.semiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: theme.isDarkMode
            ? Colors.white.withOpacity(.15)
            : Colors.black.withOpacity(.15),
        highlightColor: theme.isDarkMode
            ? Colors.white.withOpacity(.08)
            : Colors.black.withOpacity(.08),
        onTap: () {
          setState(() {
            _showOrderHistory = false;
          });
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.arrow_back_ios_outlined,
            size: 14,
            color: theme.isDarkMode
                ? WebDarkColors.iconSecondary
                : WebColors.iconSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsSection(ThemesProvider theme, OrderBookModel displayData) {
    final color = displayData.status == "COMPLETE"
        ? theme.isDarkMode ? colors.profitDark : colors.profitLight
        : displayData.status == "OPEN"
            ? theme.isDarkMode ? colors.pending : colors.pending
            : (displayData.status == "CANCELED" || displayData.status == "REJECTED")
                ? theme.isDarkMode ? colors.lossDark : colors.lossLight
                : theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Status", _getStatusText(displayData.status), theme, color),
                _buildInfoRow("Type", displayData.trantype == "B" ? "Buy" : "Sell", theme),
                _buildInfoRow("Qty", _getQuantityDisplay(displayData), theme),
                _buildInfoRow("Price", displayData.prc ?? "-", theme),
                _buildInfoRow("Avg Price", displayData.avgprc ?? "0.00", theme),
                _buildInfoRow("Trigger Price", displayData.trgprc ?? "0.00", theme),
                _buildInfoRow("Product / Type", "${displayData.sPrdtAli} / ${displayData.prctyp ?? "-"}", theme),
              ],
            ),
          ),
          // Vertical divider
          Container(
            width: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: theme.isDarkMode
                ? WebDarkColors.divider
                : WebColors.divider,
          ),
          // Right column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Market Protection", displayData.mktProtection ?? "-", theme),
                _buildInfoRow("AMO", displayData.amo ?? "-", theme),
                _buildInfoRow("Order Id", displayData.norenordno ?? "-", theme),
                _buildInfoRow("Exchange", displayData.exchordid ?? "-", theme),
                _buildInfoRow("Date & Time", formatDateTime(value: displayData.norentm ?? "-"), theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonWidget(ThemesProvider theme, String reason) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reason Title
        Text(
          "Reason:",
          style: WebTextStyles.custom(
            fontSize: 14,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            fontWeight: WebFonts.medium,
          ),
        ),
        const SizedBox(height: 8),
        // Divider
        // Container(
        //   height: 1,
        //   color: theme.isDarkMode
        //       ? WebDarkColors.divider
        //       : WebColors.divider,
        // ),
        // const SizedBox(height: 12),
        // Reason Text
        Text(
          reason,
          style: WebTextStyles.dialogContent(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderHistorySection(ThemesProvider theme, List orderHistory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          reverse: true,
          itemCount: orderHistory.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return TimeLineWidget(
              isfFrist: orderHistory.length - 1 == index ? true : false,
              isLast: index == 0 ? true : false,
              orderHistoryData: orderHistory[index],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value, ThemesProvider theme, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.end,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: valueColor ?? (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Unknown';
    return '${status[0].toUpperCase()}${status.replaceAll("_", " ").substring(1)}';
  }

  String _getQuantityDisplay(OrderBookModel order) {
    try {
      // Calculate filled quantity based on status
      int filledQty = 0;
      if (order.status != "COMPLETE" && (order.fillshares?.isNotEmpty ?? false)) {
        filledQty = int.tryParse(order.fillshares.toString()) ?? 0;
      } else if (order.status == "COMPLETE") {
        filledQty = int.tryParse(order.rqty.toString()) ?? 0;
      } else {
        filledQty = int.tryParse(order.dscqty.toString()) ?? 0;
      }

      // Calculate lot size for MCX
      int lotSize = order.exch == 'MCX' ? (int.tryParse(order.ls.toString()) ?? 1) : 1;
      
      // Calculate display quantities
      int displayFilledQty = filledQty ~/ lotSize;
      int displayTotalQty = (int.tryParse(order.qty.toString()) ?? 0) ~/ lotSize;
      
      return "$displayFilledQty / $displayTotalQty";
    } catch (e) {
      return order.qty?.toString() ?? '0';
    }
  }

  // Action handlers
  Future<void> _handleCancelOrder(OrderBookModel orderData) async {
    if (_isProcessingCancel) return;

    try {
      setState(() {
        _isProcessingCancel = true;
      });

      await ref.read(orderProvider).fetchOrderCancel(
        "${orderData.norenordno}",
        context,
        true,
      );
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCancel = false;
        });
      }
    }
  }

  Future<void> _handleModifyOrder(OrderBookModel orderData) async {
    if (_isProcessingModify) return;

    try {
      setState(() {
        _isProcessingModify = true;
      });

      await ref.read(marketWatchProvider).fetchScripInfo(
        "${orderData.token}",
        '${orderData.exch}',
        context,
      );

      if (!mounted) return;

      // Navigate to modify order screen
      Navigator.pop(context);
      ModifyPlaceOrderScreenWeb.showDraggable(
        context: context,
        modifyOrderArgs: orderData,
        orderArg: _createOrderArgs(orderData),
        scripInfo: ref.read(marketWatchProvider).scripInfoModel!,
      );
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingModify = false;
        });
      }
    }
  }

  Future<void> _handleRepeatOrder(OrderBookModel orderData) async {
    try {
      Navigator.pop(context);

      await ref.read(marketWatchProvider).fetchScripInfo(
        "${orderData.token}",
        "${orderData.exch}",
        context,
        true,
      );

      if (!mounted) return;

      ResponsiveNavigation.toPlaceOrderScreen(context: context, arguments: {
        "orderArg": _createOrderArgs(orderData),
        "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
        "isBskt": '',
      });
    } catch (e) {
      // Handle error
    }
  }

  OrderScreenArgs _createOrderArgs(OrderBookModel orderData) {
    // Get LTP, fallback to close price if numeric, otherwise use 0.00
    String ltpValue = "0.00";
    if (orderData.ltp != null && orderData.ltp.toString() != "null") {
      ltpValue = orderData.ltp.toString();
    } else if (orderData.c != null && orderData.c.toString() != "null") {
      // Only use 'c' if it's a valid number, not "C"
      final closePrice = double.tryParse(orderData.c.toString());
      if (closePrice != null) {
        ltpValue = closePrice.toString();
      }
    }

    return OrderScreenArgs(
      exchange: orderData.exch.toString(),
      tSym: orderData.tsym.toString(),
      isExit: false,
      token: orderData.token.toString(),
      transType: orderData.trantype == 'B' ? true : false,
      lotSize: orderData.ls,
      ltp: ltpValue,
      perChange: orderData.change ?? "0.00",
      orderTpye: '',
      holdQty: '',
      isModify: false,
      raw: orderData.toJson(),
    );
  }
}
