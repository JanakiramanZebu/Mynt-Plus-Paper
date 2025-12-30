import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/utils/custom_navigator.dart';
import 'dart:html' as html;
import '../../../models/order_book_model/order_history_model.dart';
import '../../../models/order_book_model/place_order_model.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../market_watch/tv_chart/chart_iframe_guard.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class OrderConfirmationScreenWeb extends ConsumerStatefulWidget {
  final List<PlaceOrderModel> orderData;

  const OrderConfirmationScreenWeb({
    super.key,
    required this.orderData,
  });

  @override
  ConsumerState<OrderConfirmationScreenWeb> createState() => _OrderConfirmationScreenWebState();
}

class _OrderConfirmationScreenWebState extends ConsumerState<OrderConfirmationScreenWeb> {
  Map<String, List<OrderHistoryModel>?> orderHistories = {};
  Map<String, bool> loadingStates = {};
  Set<String> expandedOrders = {};
  bool _isLoadingMainOrder = false;
  String _mainOrderStatus = '';

  @override
  void initState() {
    super.initState();
    _initializeOrderStates();
  }

  // Directly disable all chart iframes and reset cursor (like chart's onExit)
  void _disableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'none';
          // Reset cursor style to prevent cursor bleeding
          iframe.style.cursor = 'default';
        }
      }
      // Also reset cursor on document body to ensure it's reset globally
      html.document.body?.style.cursor = 'default';
    } catch (e) {
      debugPrint('Error disabling iframes: $e');
    }
  }

  void _enableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'auto';
          iframe.style.cursor = '';
        }
      }
      html.document.body?.style.cursor = '';
    } catch (e) {
      debugPrint('Error enabling iframes: $e');
    }
  }

  @override
  void dispose() {
    ChartIframeGuard.release();
    _enableAllChartIframes();
    super.dispose();
  }

  void _initializeOrderStates() {
    for (final order in widget.orderData) {
      final orderNumber = order.norenordno ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      loadingStates[orderNumber] = false;
      orderHistories[orderNumber] = null;
    }

    // For single orders, expand by default and fetch order details immediately
    if (widget.orderData.isNotEmpty && widget.orderData.length == 1) {
      final orderNumber = widget.orderData[0].norenordno ?? '';
      expandedOrders.add(orderNumber);
      _isLoadingMainOrder = true;
      _fetchOrderDetails(orderNumber, isMainOrder: true);
    }
  }

  Future<void> _fetchOrderDetails(String orderNumber, {bool isMainOrder = false}) async {
    if (orderNumber.isEmpty) return;

    setState(() {
      loadingStates[orderNumber] = true;
      if (isMainOrder) {
        _isLoadingMainOrder = true;
      }
    });

    try {
      final history = await ref.read(orderProvider).fetchOrderHistory(
            orderNumber,
            context,
          );
      if (mounted) {
        setState(() {
          orderHistories[orderNumber] = history;
          loadingStates[orderNumber] = false;

          // Update main order status for single orders
          if (isMainOrder && history != null && history.isNotEmpty) {
            _mainOrderStatus = history[0].status ?? '';
            _isLoadingMainOrder = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loadingStates[orderNumber] = false;
          if (isMainOrder) {
            _isLoadingMainOrder = false;
            _mainOrderStatus = 'Unknown';
          }
        });
      }
    }
  }

  void _toggleExpanded(String orderNumber) {
    setState(() {
      if (expandedOrders.contains(orderNumber)) {
        expandedOrders.remove(orderNumber);
      } else {
        expandedOrders.add(orderNumber);
        // Fetch order details when expanding
        if (orderHistories[orderNumber] == null && !loadingStates[orderNumber]!) {
          _fetchOrderDetails(orderNumber);
        }
      }
    });
  }

  void _navigateToOrderBook() {
    // Navigate to order book
    if (kIsWeb) {
      WebNavigationHelper.navigateTo("orderBook");
    } else {
    ref.read(indexListProvider).bottomMenu(2, context);
    ref.read(portfolioProvider).changeTabIndex(2);
    ref.read(orderProvider).changeTabIndex(0, context);
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);

    return Dialog(
      backgroundColor: theme.isDarkMode 
          ? WebDarkColors.surface 
          : WebColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: PointerInterceptor(
        child: MouseRegion(
          cursor: SystemMouseCursors.basic,
          onEnter: (_) {
            ChartIframeGuard.acquire();
            _disableAllChartIframes();
          },
          onHover: (_) {
            _disableAllChartIframes();
          },
          onExit: (_) {
            ChartIframeGuard.release();
            _enableAllChartIframes();
          },
          child: Listener(
            onPointerMove: (_) {
              _disableAllChartIframes();
            },
            child: GestureDetector(
              onTap: () {}, // Prevent tap from propagating to background
              child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
                  Text(
                    "Order Confirmation",
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? WebDarkColors.backgroundTertiary
                            : WebColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          _getStatusIcon(),
                          const SizedBox(height: 10),
                          Text(
                            _getStatusText(),
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStatusMessage(),
                            style: WebTextStyles.custom(
                              fontSize: 10,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textSecondary
                                  : WebColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Orders List Title
                    Text(
                      widget.orderData.length == 1 ? "Order Details" : "Order List",
                      style: WebTextStyles.custom(
                        fontSize: 13,
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Build expandable list for each order - scrollable to avoid overflow
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.orderData.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, listIndex) {
                          final order = widget.orderData[listIndex];
                          final orderNumber = order.norenordno ?? '';
                          final isExpanded = expandedOrders.contains(orderNumber);
                          final isLoading = loadingStates[orderNumber] ?? false;
                          final orderHistory = orderHistories[orderNumber];

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? WebDarkColors.backgroundTertiary
                                  : WebColors.backgroundTertiary,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: theme.isDarkMode
                                    ? WebDarkColors.divider
                                    : WebColors.divider,
                              ),
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: widget.orderData.length == 1 && isExpanded,
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              childrenPadding: const EdgeInsets.all(16),
                              title: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: (theme.isDarkMode
                                              ? WebDarkColors.primary
                                              : WebColors.primary)
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${listIndex + 1}",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.primary
                                              : WebColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (orderNumber.isNotEmpty)
                                          Text(
                                            "#$orderNumber",
                                            overflow: TextOverflow.ellipsis,
                                            style: WebTextStyles.custom(
                                              fontSize: 13,
                                              isDarkTheme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? WebDarkColors.textPrimary
                                                  : WebColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        if (order.requestTime != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            order.requestTime!,
                                            style: WebTextStyles.custom(
                                              fontSize: 12,
                                              isDarkTheme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? WebDarkColors.textSecondary
                                                  : WebColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: theme.isDarkMode
                                    ? WebDarkColors.iconSecondary
                                    : WebColors.iconSecondary,
                                size: 20,
                              ),
                              onExpansionChanged: (_) {
                                _toggleExpanded(orderNumber);
                              },
                              children: [
                                if (isLoading)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                        color: theme.isDarkMode
                                            ? WebDarkColors.primary
                                            : WebColors.primary,
                                      ),
                                    ),
                                  )
                                else if (orderHistory != null && orderHistory.isNotEmpty && orderHistory[0].stat != "Not_Ok")
                                  Column(
                                    children: [
                                      _buildOrderDetailRow("Symbol", orderHistory[0].tsym ?? "-", theme),
                                      _buildOrderDetailRow("Exchange", orderHistory[0].exch ?? "-", theme),
                                      _buildOrderDetailRow("Transaction Type", orderHistory[0].trantype == "B" ? "Buy" : "Sell", theme),
                                      _buildOrderDetailRow("Quantity", orderHistory[0].qty ?? "-", theme),
                                      _buildOrderDetailRow("Price", "₹${orderHistory[0].prc ?? "0.00"}", theme),
                                      _buildOrderDetailRow("Product", _getProductName(orderHistory[0].prd ?? ""), theme),
                                      _buildOrderDetailRow("Price Type", orderHistory[0].prctyp ?? "-", theme),
                                      _buildOrderDetailRow("Validity", orderHistory[0].ret ?? "-", theme),
                                      _buildOrderDetailRow("Status", _formatStatus(orderHistory[0].status ?? ""), theme),
                                      if (orderHistory[0].status == "REJECTED") ...[
                                        _buildOrderDetailRow("Reason", "", theme),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            orderHistory[0].rejreason ?? "",
                                            style: WebTextStyles.custom(
                                              fontSize: 13,
                                              isDarkTheme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? WebDarkColors.error
                                                  : WebColors.error,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Center(
                                      child: Text(
                                        "Order details will be available in the order book shortly.",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textSecondary
                                              : WebColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _navigateToOrderBook,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          "View Order Book",
                          style: WebTextStyles.custom(
                            fontSize: 14,
                            isDarkTheme: theme.isDarkMode,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textSecondary
                  : WebColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getProductName(String productCode) {
    switch (productCode.toUpperCase()) {
      case 'C':
        return 'Delivery';
      case 'I':
        return 'Intraday';
      case 'M':
        return 'NRML';
      case 'F':
        return 'MTF';
      case 'H':
        return 'CO - BO Order';
      case 'B':
        return 'CO - BO Order';
      default:
        return productCode;
    }
  }

  String _formatStatus(String status) {
    return status.toLowerCase().split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _getStatusText() {
    if (widget.orderData.length == 1) {
      if (_isLoadingMainOrder) {
        return "Loading Order Status...";
      }
      return _mainOrderStatus.isEmpty ? "Order Status" : "Order status ${_formatStatus(_mainOrderStatus)}";
    } else {
      return "${widget.orderData.length} Orders Status";
    }
  }

  Widget _getStatusIcon() {
    final theme = ref.read(themeProvider);
    
    if (widget.orderData.length == 1) {
      if (_isLoadingMainOrder) {
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
            strokeWidth: 3,
          ),
        );
      }

      // Return icon based on order status
      switch (_mainOrderStatus.toUpperCase()) {
        case 'COMPLETE':
        case 'TRADED':
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
              size: 40,
            ),
          );

        case 'OPEN':
        case 'PENDING':
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule,
              color: Colors.orange,
              size: 40,
            ),
          );
        case 'REJECTED':
        case 'CANCELLED':
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (theme.isDarkMode ? WebDarkColors.error : WebColors.error).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cancel,
              color: theme.isDarkMode ? WebDarkColors.error : WebColors.error,
              size: 40,
            ),
          );
        default:
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
              size: 40,
            ),
          );
      }
    } else {
      // For slice orders, show success icon
      return Icon(
        Icons.check_circle,
        color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
        size: 40,
      );
    }
  }

  String _getStatusMessage() {
    if (widget.orderData.length == 1) {
      if (_isLoadingMainOrder) {
        return "Please wait while we fetch your order details...";
      }

      switch (_mainOrderStatus.toUpperCase()) {
        case 'COMPLETE':
        case 'TRADED':
          return "Your order has been executed successfully";
        case 'OPEN':
        case 'PENDING':
          return "Your order is pending execution";
        case 'REJECTED':
          return "Your order has been rejected";
        case 'CANCELLED':
          return "Your order has been cancelled";
        default:
          return "Your order has been placed";
      }
    } else {
      return "Your slice orders have been placed";
    }
  }
}
