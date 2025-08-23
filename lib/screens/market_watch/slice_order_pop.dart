import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/marketwatch_model/scrip_info.dart';
import '../../models/order_book_model/place_order_model.dart';
import '../../provider/index_list_provider.dart';
import '../../provider/order_input_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../res/global_state_text.dart';

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
  final bool isBracketOrderEnabled;

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
    required this.isBracketOrderEnabled,
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
      final portfoliopro = ref.read(portfolioProvider);
      return PopScope(
          canPop: !orders.orderloader,
          onPopInvoked: (didPop) {
            if (!didPop && orders.orderloader) {
              // Block pop if loader is true
              return;
            }
          },
          child: GestureDetector(
              onVerticalDragDown: orders.orderloader ? (_) {} : null, // Blocks swipe down
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                      child: TextWidget.subText(
                        text: "Slice Order",
                        theme: theme.isDarkMode,
                        fw: 1,
                      ),
                    ),
                    Divider(
                      color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildScripInfo(theme),
                          Row(
                            children: [
                              TextWidget.subText(
                                text: "Qty: ${widget.frezQty} ",
                                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                theme: theme.isDarkMode,
                                fw: 1,
                              ),
                              TextWidget.captionText(
                                text: " X ${widget.quantity >= orders.frezQtyOrderSliceMaxLimit ? orders.frezQtyOrderSliceMaxLimit : widget.quantity}",
                                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                theme: theme.isDarkMode,
                                fw: 0,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    if (widget.reminder != 0) _buildReminderSection(theme),
                    _buildActionButton(theme, orders, orderInput, widget.isBracketOrderEnabled, indexpro, portfoliopro),
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
            TextWidget.subText(
              text: "${widget.scripInfo.symbol} ",
              theme: theme.isDarkMode,
              fw: 1,
            ),
            TextWidget.subText(
              text: "${widget.scripInfo.option}",
              theme: theme.isDarkMode,
              fw: 1,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            CustomExchBadge(exch: "${widget.scripInfo.exch}"),
            TextWidget.captionText(
              text: "${widget.scripInfo.expDate}",
              theme: theme.isDarkMode,
              fw: 0,
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
          color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScripInfo(theme),
              Row(
                children: [
                  TextWidget.subText(
                    text: "Qty: ${widget.reminder} ",
                    theme: theme.isDarkMode,
                    fw: 1,
                  ),
                  TextWidget.captionText(
                    text: " X 1",
                    color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    theme: theme.isDarkMode,
                    fw: 0,
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
    ThemesProvider theme,
    OrderProvider orders,
    OrderInputProvider orderInput,
    bool isBracketOrderEnabled,
    IndexListProvider indexpro,
    PortfolioProvider portfoliopro,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () async {
          if (!orders.orderloader) {
            orders.setOrderloader(true);

            try {
              // Prepare order inputs for slice orders
              List<PlaceOrderInput> placeOrderInputs = [];
              placeOrderInputs.add(_buildOrderInput(orderInput, isBracketOrderEnabled));

              if (widget.reminder != 0) {
                placeOrderInputs.add(_buildOrderInput(orderInput, isBracketOrderEnabled, qtyOverride: widget.reminder.toString()));
              }

              // Use the new slice order with confirmation function
              orders.slicePlaceOrderWithConfirmation(context, placeOrderInputs, widget.quantity, widget.reminder);

            } catch (e) {
              // Handle any unexpected errors
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
            } finally {
              orders.setOrderloader(false);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          backgroundColor: widget.isBuy ? colors.primary : colors.tertiary,
          // shape: const StadiumBorder(),
        ),
        child: orders.orderloader
            ? const SizedBox(
                width: 18,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xffffffff)),
              )
            : TextWidget.subText(
                text: widget.isBuy ? 'Buy' : "Sell",
                color: const Color(0xffffffff),
                theme: theme.isDarkMode,
                fw: 1,
              ),
      ),
    );
  }

  PlaceOrderInput _buildOrderInput(orderInput, bool isBracketOrderEnabled, {String? qtyOverride}) {
    return PlaceOrderInput(
      amo: widget.isAmo ? "Yes" : "",
      blprc: widget.orderType == "CO - BO" ? widget.stopLossCtrl.text : '',
      bpprc: widget.orderType == "CO - BO" && isBracketOrderEnabled ? widget.targetCtrl.text : '',
      dscqty: widget.discQtyCtrl.text,
      exch: widget.scripInfo.exch!,
      prc: widget.ordPrice,
      prctype: orderInput.prcType,
      prd: orderInput.orderType,
      qty: qtyOverride ?? "${widget.frezQty}",
      ret: widget.validityType,
      trailprc: '',
      trantype: widget.isBuy ? 'B' : 'S',
      trgprc: widget.priceType == "SL Limit" || widget.priceType == "SL MKT" ? widget.triggerPriceCtrl.text : "",
      tsym: widget.scripInfo.tsym!,
      mktProt: widget.priceType == "Market" || widget.priceType == "SL MKT" ? widget.mktProtCtrl.text : '',
      channel: '',
    );
    // widget.scripInfo.exch == 'MCX'
    //               ? (int.parse(qtyOverride??"${widget.frezQty}") * int.parse("${widget.scripInfo.ls ?? 0}")).toString()
    //               :
  }
}
