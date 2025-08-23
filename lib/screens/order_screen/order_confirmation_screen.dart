import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/order_book_model/order_history_model.dart';
import '../../models/order_book_model/place_order_model.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../provider/index_list_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../res/global_state_text.dart';

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  final List<PlaceOrderModel> orderData;

  const OrderConfirmationScreen({
    super.key,
    required this.orderData,
  });

  @override
  ConsumerState<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends ConsumerState<OrderConfirmationScreen> {
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
    ref.read(indexListProvider).bottomMenu(2, context);
    ref.read(portfolioProvider).changeTabIndex(2);
    ref.read(orderProvider).changeTabIndex(0, context);

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);

    try {
      return Scaffold(
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.kColorLightGrey,
        appBar: AppBar(
          leadingWidth: 48,
          centerTitle: false,
          titleSpacing: 0,
          leading: const CustomBackBtn(),
          elevation: 0.2,
          backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          title: TextWidget.titleText(
            text: "Order Confirmation",
            fw: 1,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            theme: false,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _getStatusIcon(),
                      const SizedBox(height: 16),
                      TextWidget.subText(
                        text: _getStatusText(),
                        fw: 3,
                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                        theme: false,
                      ),
                      const SizedBox(height: 8),
                      TextWidget.paraText(
                        text: _getStatusMessage(),
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        theme: false,
                      ),
                    ],
                  ),
                ),
                  
                const SizedBox(height: 20),
                  
                // Orders List
                TextWidget.subText(
                  text: widget.orderData.length == 1 ? "Order Details" : "Order List",
                  fw: 0,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: false,
                ),
                  
                const SizedBox(height: 12),
                  
                // Build expandable list for each order
                ...widget.orderData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final order = entry.value;
                  final orderNumber = order.norenordno ?? '';
                  final isExpanded = expandedOrders.contains(orderNumber);
                  final isLoading = loadingStates[orderNumber] ?? false;
                  final orderHistory = orderHistories[orderNumber];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                              color: colors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: TextWidget.subText(
                                text: "${index + 1}",
                                color: colors.primary,
                                fw: 2,
                                theme: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TextWidget.subText(
                                //   text: "Order ${index + 1}",
                                //   fw: 2,
                                //   color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                //   theme: false,
                                // ),
                                if (orderNumber.isNotEmpty) ...[
                                  // const SizedBox(height: 4),
                                  TextWidget.subText(
                                    text: "#$orderNumber",
                                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                    theme: false,
                                  ),
                                ],
                                if (order.requestTime != null) ...[
                                  const SizedBox(height: 2),
                                  TextWidget.paraText(
                                    text: order.requestTime!,
                                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                    theme: false,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      ),
                      onExpansionChanged: (expanded) {
                        _toggleExpanded(orderNumber);
                      },
                      children: [
                        if (isLoading) ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ] else if (orderHistory != null && orderHistory.isNotEmpty && orderHistory[0].stat != "Not_Ok") ...[
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
                                  child: TextWidget.subText(
                                    text: orderHistory[0].rejreason ?? "",
                                    color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                                    theme: false,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: TextWidget.subText(
                                text: "Order details will be available in the order book shortly.",
                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                theme: false,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                  
                const SizedBox(height: 30),
                  
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToOrderBook,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 45),
                        elevation: 0,
                      backgroundColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: TextWidget.subText(
                      text: "View Order Book",
                      color: colors.colorWhite,
                      theme: false,
                      fw: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return Scaffold(
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.kColorLightGrey,
        appBar: AppBar(
          leadingWidth: 41,
          centerTitle: false,
          titleSpacing: 0,
          leading: const CustomBackBtn(),
          elevation: 0.4,
          backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          title: TextWidget.subText(
            text: "Order Confirmation",
            fw: 2,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            theme: false,
          ),
        ),
        body: Center(
          child: TextWidget.subText(
            text: "Failed to load order confirmation screen.",
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            theme: false,
          ),
        ),
      );
    }
  }

  Widget _buildOrderDetailRow(String label, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
            text: label,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            theme: false,
            // fontSize: 14,
          ),
          TextWidget.subText(
            text: value,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            theme: false,
            fw: 3,
            // fontSize: 14,
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
    if (widget.orderData.length == 1) {
      if (_isLoadingMainOrder) {
        return SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: colors.primary,
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
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: colors.primary,
              size: 40,
            ),
          );

        case 'OPEN':
        case 'PENDING':
          return  Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
            Icons.schedule,
            color: Colors.orange,
            size: 40,
          ),
          );
         ;
        case 'REJECTED':
        case 'CANCELLED':
          return  Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colors.tertiary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cancel,
              color: colors.tertiary,
              size: 40,
            ),
          );
        default:
          return  Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              color: Colors.grey,
              size: 40,
            ),
          );
          
      }
    } else {
      // For slice orders, show success icon
      return Icon(
        Icons.check_circle,
        color: colors.primary,
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
