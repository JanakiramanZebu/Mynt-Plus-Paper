import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/models/bonds_model/bonds_order_book_model.dart';
import 'package:intl/intl.dart';

import '../../../../res/res.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/web_colors.dart';
import 'bond_cancel_alert/bonds_cancel_alert.dart';

class BondsDetailsSidebarWeb extends ConsumerWidget {
  final BondsOrderBookModel order;
  final bool isOpenOrder;

  const BondsDetailsSidebarWeb({
    super.key,
    required this.order,
    this.isOpenOrder = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDark = theme.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.colorBlack : colors.colorWhite,
        border: Border(
          left: BorderSide(
            color: isDark ? colors.darkColorDivider : colors.colorDivider,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? colors.darkColorDivider : colors.colorDivider,
                ),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: isDark ? Colors.white : Colors.black, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  "Order Details",
                  style: MyntWebTextStyles.body(context, fontWeight: FontWeight.w600).copyWith(fontSize: 16),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Symbol Name
                  Text(
                    order.symbol ?? "-",
                    style: MyntWebTextStyles.body(context, fontWeight: FontWeight.normal).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  if ((order.orderStatus?.toLowerCase() == 'pending' || order.orderStatus?.toLowerCase() == 'open'))
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => BondCancelAlert(bondcancel: order),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE8EEF9),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: const BorderSide(color: Color(0xFF2E529E)),
                          ),
                        ),
                        child: Text(
                          "Cancel Order",
                          style: MyntWebTextStyles.body(context, 
                              color: const Color(0xFF2E529E), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // Details List
                  _buildRow(context, "Order Id", order.applicationNumber ?? "-", isDark),
                  _buildDivider(isDark),
                  
                  _buildRow(context, "Order Status", order.reponseStatus ?? "-", isDark, isChip: true),
                  _buildDivider(isDark),
                  
                  _buildRow(context, "Payment", order.clearingStatus ?? "Pending", isDark, isChipValue: true),
                  _buildDivider(isDark),
                  
                  _buildRow(context, "App no", order.applicationNumber ?? "-", isDark),
                  _buildDivider(isDark),

                  _buildRow(context, "Qty", _calculateQuantity(order.totalAmountPayable, (order.bidDetail?.price as num?)?.toDouble()), isDark),
                  _buildDivider(isDark),

                  _buildRow(context, "Price", order.bidDetail?.price?.toString() ?? "0", isDark),
                  _buildDivider(isDark),

                  _buildRow(context, "Total amount", order.totalAmountPayable ?? "0", isDark),
                  _buildDivider(isDark),

                  _buildRow(context, "Bid Date & Time", _formatDate(order.responseDatetime), isDark),
                  _buildDivider(isDark),

                  // Reason
                   if (order.failReason != null && order.failReason!.isNotEmpty) ...[
                     _buildRow(context, "Reason", order.failReason!, isDark),
                     _buildDivider(isDark),
                   ],

                  const SizedBox(height: 24),

                  // Single bid order Section
                  Text(
                    "Single bid order",
                    style: MyntWebTextStyles.body(context, fontWeight: FontWeight.w500).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  
                  // Table Header
                  Row(
                    children: [
                      _buildHeaderCell(context, "Bid", width: 40),
                      _buildHeaderCell(context, "Qty", flex: 1),
                      _buildHeaderCell(context, "Price", flex: 1),
                      _buildHeaderCell(context, "Amount", flex: 1),
                      _buildHeaderCell(context, "Cut off", width: 60, alignRight: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Table Row
                  Row(
                    children: [
                      SizedBox(width: 40, child: Text("1", style: MyntWebTextStyles.body(context))),
                      Expanded(child: Text(_calculateQuantity(order.totalAmountPayable, (order.bidDetail?.price as num?)?.toDouble()), style: MyntWebTextStyles.body(context))),
                      Expanded(child: Text(order.bidDetail?.price?.toString() ?? "0", style: MyntWebTextStyles.body(context))),
                      Expanded(child: Text("₹${order.totalAmountPayable ?? "0"}", style: MyntWebTextStyles.body(context))),
                      Container(
                        width: 60,
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, bool isDark, {bool isChip = false, bool isChipValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: MyntWebTextStyles.body(context, color: isDark ? Colors.grey[400] : Colors.grey[800])),
          if (isChip)
            _buildStatusChip(context, value)
          else if (isChipValue)
             _buildPaymentChip(context, value)
          else
            Expanded(
              child: Text(
                value, 
                style: MyntWebTextStyles.body(context, fontWeight: FontWeight.normal),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey[200]);
  }

  Widget _buildHeaderCell(BuildContext context, String text, {double? width, int? flex, bool alignRight = false}) {
    Widget child = Text(
      text,
      style: MyntWebTextStyles.caption(context, color: WebColors.textSecondary),
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
    );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex ?? 1, child: child);
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    bool isFailed = status.toLowerCase() == 'failed';
    // Match colors from image (approx)
    // Failed: light red bg, dark red text
    Color bg = isFailed ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
    Color text = isFailed ? const Color(0xFFEF5350) : const Color(0xFF66BB6A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: MyntWebTextStyles.caption(context, color: text, fontWeight: FontWeight.bold).copyWith(fontSize: 12)),
    );
  }

  Widget _buildPaymentChip(BuildContext context, String status) {
     // Pending: light orange bg, orange text
    bool isPending = status.toLowerCase() == 'pending' || status.toLowerCase() == 'fund pending';
    Color bg = isPending ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    Color text = isPending ? const Color(0xFFFF9800) : const Color(0xFF66BB6A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: MyntWebTextStyles.caption(context, color: text, fontWeight: FontWeight.bold).copyWith(fontSize: 12)),
    );
  }

  String _calculateQuantity(String? amountStr, double? price) {
    if (price == null || price == 0) return '-';
    double amount = double.tryParse(amountStr ?? "0") ?? 0;
    if (amount == 0) return '-';
    return (amount / price).toStringAsFixed(0);
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return dateTimeStr;
    }
  }
}
