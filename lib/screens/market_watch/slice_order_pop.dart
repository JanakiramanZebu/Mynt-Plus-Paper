import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/marketwatch_model/scrip_info.dart';
import '../../models/order_book_model/place_order_model.dart';
import '../../provider/index_list_provider.dart';
import '../../provider/order_input_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/snack_bar.dart';

class SliceOrderSheet extends StatefulWidget {
  final ScripInfoModel scripInfo;
  final bool isBuy;
  final int quantity;
  final int frezQty;
  final int reminder;
  final bool isAmo;
  final String orderType;
  final String priceType;
  final String ordPrice;
  final String validityType;
  final TextEditingController stopLossCtrl;
  final TextEditingController targetCtrl;
  final TextEditingController discQtyCtrl;
  final TextEditingController triggerPriceCtrl;
  final TextEditingController mktProtCtrl;

  const SliceOrderSheet({
    super.key,
    required this.scripInfo,
    required this.isBuy,
    required this.quantity,
    required this.frezQty,
    required this.reminder,
    required this.isAmo,
    required this.orderType,
    required this.priceType,
    required this.ordPrice,
    required this.validityType,
    required this.stopLossCtrl,
    required this.targetCtrl,
    required this.discQtyCtrl,
    required this.triggerPriceCtrl,
    required this.mktProtCtrl,
  });

  @override
  State<SliceOrderSheet> createState() => _SliceOrderSheetState();
}

class _SliceOrderSheetState extends State<SliceOrderSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final orders = ref.watch(orderProvider);
      final indexpro = ref.watch(indexListProvider);
      final orderInput = ref.watch(ordInputProvider);
      return PopScope(
          canPop: !orders.orderloader,
          onPopInvoked: (didPop) {
            if (!didPop && orders.orderloader) {
              // Block pop if loader is true
              return;
            }
          },
          child: GestureDetector(
              onVerticalDragDown:
                  orders.orderloader ? (_) {} : null, // Blocks swipe down
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xff999999),
                      blurRadius: 4.0,
                      offset: Offset(2.0, 0.0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomDragHandler(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Slice Order",
                        style: textStyles.appBarTitleTxt.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                        ),
                      ),
                    ),
                    Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildScripInfo(theme),
                          Row(
                            children: [
                              Text(
                                "Qty: ${widget.frezQty} ",
                                style: textStyles.scripNameTxtStyle.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                ),
                              ),
                              Text(
                                " X ${widget.quantity >= 20 ? 20 : widget.quantity}",
                                style: textStyles.scripExchTxtStyle.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    if (widget.reminder != 0) _buildReminderSection(theme),
                    _buildActionButton(theme, orders, orderInput, indexpro),
                    const SizedBox(height: 10),
                  ],
                ),
              )));
    });
  }

  Widget _buildScripInfo(theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "${widget.scripInfo.symbol} ",
              style: textStyles.scripNameTxtStyle.copyWith(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
            Text(
              "${widget.scripInfo.option}",
              style: textStyles.scripNameTxtStyle.copyWith(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            CustomExchBadge(exch: "${widget.scripInfo.exch}"),
            Text(
              "${widget.scripInfo.expDate}",
              style: textStyles.scripExchTxtStyle.copyWith(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderSection(theme) {
    return Column(
      children: [
        Divider(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScripInfo(theme),
              Row(
                children: [
                  Text(
                    "Qty: ${widget.reminder} ",
                    style: textStyles.scripNameTxtStyle.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                    ),
                  ),
                  Text(
                    " X 1",
                    style: textStyles.scripExchTxtStyle.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildActionButton(
    theme,
    orders,
    orderInput,
    indexpro,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () async {
          if (!orders.orderloader) {
            orders.setOrderloader(true);
            final iterations = widget.quantity >= 20 ? 20 : widget.quantity;
            for (var i = 0; i < iterations; i++) {
              final placeOrderInput = _buildOrderInput(orderInput);
              orders.slicePlaceOrder(context, placeOrderInput);
              // if (orders.placeOrderModel!.emsg ==
              //     "Session Expired :  Invalid Session Key") break;
            }

            if (widget.reminder != 0) {
              final reminderOrder = _buildOrderInput(orderInput,
                  qtyOverride: widget.reminder.toString());
              orders.slicePlaceOrder(context, reminderOrder);
            }

            // await orders.fetchOrderBook(context, true);
            await indexpro.bottomMenu(3, context);
            ScaffoldMessenger.of(context).showSnackBar(
                successMessage(context, "Order placed successfully."));
            Navigator.pop(context);
            Navigator.pop(context);
            orders.setOrderloader(false);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          backgroundColor: widget.isBuy ? colors.ltpgreen : colors.darkred,
          shape: const StadiumBorder(),
        ),
        child: orders.orderloader
            ? const SizedBox(
                width: 18,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xffffffff)),
              )
            : Text(
                widget.isBuy ? 'Buy Now' : "Sell Now",
                style: textStyle(const Color(0xffffffff), 14, FontWeight.w600),
              ),
      ),
    );
  }

  PlaceOrderInput _buildOrderInput(orderInput, {String? qtyOverride}) {
    return PlaceOrderInput(
      amo: widget.isAmo ? "Yes" : "",
      blprc: widget.orderType == "Cover" || widget.orderType == "Bracket"
          ? widget.stopLossCtrl.text
          : '',
      bpprc: widget.orderType == "Bracket" ? widget.targetCtrl.text : '',
      dscqty: widget.discQtyCtrl.text,
      exch: widget.scripInfo.exch!,
      prc: widget.ordPrice,
      prctype: orderInput.prcType,
      prd: orderInput.orderType,
      qty: qtyOverride ?? "${widget.frezQty}",
      ret: widget.validityType,
      trailprc: '',
      trantype: widget.isBuy ? 'B' : 'S',
      trgprc: widget.priceType == "SL Limit" || widget.priceType == "SL MKT"
          ? widget.triggerPriceCtrl.text
          : "",
      tsym: widget.scripInfo.tsym!,
      mktProt: widget.priceType == "Market" || widget.priceType == "SL MKT"
          ? widget.mktProtCtrl.text
          : '',
      channel: '',
    );
  }
}
