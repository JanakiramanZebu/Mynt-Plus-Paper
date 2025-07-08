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
  final PlaceOrderModel orderData;

  const OrderConfirmationScreen({
    super.key,
    required this.orderData,
  });

  @override
  ConsumerState<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends ConsumerState<OrderConfirmationScreen> {
  List<OrderHistoryModel>? orderHistory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    if (widget.orderData.norenordno != null) {
      try {
        final history = await ref.read(orderProvider).fetchOrderHistory(
              widget.orderData.norenordno!,
              context,
            );
        if (mounted) {
          setState(() {
            orderHistory = history;
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToOrderBook() {
    // Navigate to order book
    ref.read(indexListProvider).bottomMenu(2, context);
    ref.read(portfolioProvider).changeTabIndex(2);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);

    return Scaffold(
      backgroundColor:
          theme.isDarkMode ? colors.colorBlack : colors.kColorLightGrey,
      appBar: AppBar(
        leadingWidth: 41,
        centerTitle: false,
        titleSpacing: 0,
        leading: const CustomBackBtn(),
        elevation: 0.4,
        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        title: TextWidget.subText(
          text: "Order Confirmation",
          fw: 2,
          color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          theme: false,
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color:
                    theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorWhite,
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
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            orderHistory![0].status == "SUCCESS"
                                ? Icons.check_circle
                                : Icons.cancel,
                            color:  orderHistory![0].status == "SUCCESS" ? colors.primary : colors.tertiary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextWidget.subText(
                          text: "Order status ${orderHistory![0].status}",
                          fw: 2,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          theme: false,
                          // fontSize: 18,
                        ),
                        if (widget.orderData.norenordno != null) ...[
                          const SizedBox(height: 8),
                          TextWidget.subText(
                            text:
                                "Order Number: ${widget.orderData.norenordno}",
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            theme: false,
                            // fontSize: 14,
                          ),
                        ],
                        if (widget.orderData.requestTime != null) ...[
                          const SizedBox(height: 4),
                          TextWidget.subText(
                            text: "Time: ${widget.orderData.requestTime}",
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            theme: false,
                            // fontSize: 12,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Order Details
                  if (orderHistory != null &&
                      orderHistory!.isNotEmpty &&
                      orderHistory![0].stat != "Not_Ok") ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget.subText(
                            text: "Order Details",
                            fw: 2,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            theme: false,
                            // fontSize: 16,
                          ),
                          const SizedBox(height: 16),

                          // Build order details from order history
                          _buildOrderDetailRow(
                              "Symbol", orderHistory![0].tsym ?? "-", theme),
                          _buildOrderDetailRow(
                              "Exchange", orderHistory![0].exch ?? "-", theme),
                          _buildOrderDetailRow(
                              "Transaction Type",
                              orderHistory![0].trantype == "B" ? "Buy" : "Sell",
                              theme),
                          _buildOrderDetailRow(
                              "Quantity", orderHistory![0].qty ?? "-", theme),
                          _buildOrderDetailRow("Price",
                              "₹${orderHistory![0].prc ?? "0.00"}", theme),
                          _buildOrderDetailRow(
                              "Product",
                              _getProductName(orderHistory![0].prd ?? ""),
                              theme),
                          _buildOrderDetailRow("Price Type",
                              orderHistory![0].prctyp ?? "-", theme),
                          _buildOrderDetailRow(
                              "Validity", orderHistory![0].ret ?? "-", theme),
                          _buildOrderDetailRow(
                              "Status",
                              _formatStatus(orderHistory![0].status ?? ""),
                              theme),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Fallback if order history is not available
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget.subText(
                            text: "Order Details",
                            fw: 2,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            theme: false,
                            // fontSize: 16,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextWidget.subText(
                              text:
                                  "Order details will be available in the order book shortly.",
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              theme: false,
                              // fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToOrderBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextWidget.subText(
                        text: "View Order Book",
                        color: colors.colorWhite,
                        theme: false,
                        fw: 2,
                        // fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderDetailRow(
      String label, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
            text: label,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            theme: false,
            // fontSize: 14,
          ),
          TextWidget.subText(
            text: value,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            theme: false,
            fw: 1,
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
        return 'Cover Order';
      case 'B':
        return 'Bracket Order';
      default:
        return productCode;
    }
  }

  String _formatStatus(String status) {
    return status
        .toLowerCase()
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
