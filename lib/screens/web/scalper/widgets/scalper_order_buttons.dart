import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../models/order_book_model/place_order_model.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../utils/responsive_snackbar.dart';

/// Quick order buttons for scalper screen
/// Shows: B MKT | B LMT | S LMT | S MKT
class ScalperOrderButtons extends ConsumerStatefulWidget {
  final OptionValues? option;
  final String lotSize;
  final bool isCall;

  const ScalperOrderButtons({
    super.key,
    required this.option,
    required this.lotSize,
    required this.isCall,
  });

  @override
  ConsumerState<ScalperOrderButtons> createState() => _ScalperOrderButtonsState();
}

class _ScalperOrderButtonsState extends ConsumerState<ScalperOrderButtons> {
  bool _isExecuting = false;

  @override
  Widget build(BuildContext context) {
    if (widget.option == null || widget.option?.token == null) {
      return const SizedBox(width: 120);
    }

    return SizedBox(
      width: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // BUY MARKET - Green filled
          _QuickOrderButton(
            label: 'B',
            tooltip: 'Buy Market',
            isMarket: true,
            isBuy: true,
            isExecuting: _isExecuting,
            onPressed: () => _showQuantityPopover(context, true, true),
          ),
          const SizedBox(width: 2),
          // BUY LIMIT - Green outlined
          _QuickOrderButton(
            label: 'B',
            tooltip: 'Buy Limit',
            isMarket: false,
            isBuy: true,
            isExecuting: _isExecuting,
            onPressed: () => _showQuantityPopover(context, true, false),
          ),
          const SizedBox(width: 4),
          // SELL LIMIT - Red outlined
          _QuickOrderButton(
            label: 'S',
            tooltip: 'Sell Limit',
            isMarket: false,
            isBuy: false,
            isExecuting: _isExecuting,
            onPressed: () => _showQuantityPopover(context, false, false),
          ),
          const SizedBox(width: 2),
          // SELL MARKET - Red filled
          _QuickOrderButton(
            label: 'S',
            tooltip: 'Sell Market',
            isMarket: true,
            isBuy: false,
            isExecuting: _isExecuting,
            onPressed: () => _showQuantityPopover(context, false, true),
          ),
        ],
      ),
    );
  }

  Future<void> _showQuantityPopover(
    BuildContext context,
    bool isBuy,
    bool isMarket,
  ) async {
    final option = widget.option;
    if (option == null) return;

    // Get current LTP for limit orders
    final socketData = ref.read(websocketProvider).socketDatas[option.token];
    final currentLTP = double.tryParse(
            socketData?['lp']?.toString() ?? option.lp ?? '0') ??
        0.0;

    // Show quantity input dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) => _QuantityInputDialog(
        symbol: option.tsym ?? '',
        defaultQty: widget.lotSize,
        currentLTP: currentLTP,
        isBuy: isBuy,
        isMarket: isMarket,
        lotSize: int.tryParse(widget.lotSize) ?? 1,
      ),
    );

    if (result != null && mounted) {
      await _executeOrder(
        isBuy: isBuy,
        isMarket: isMarket,
        qty: result['qty'] as String,
        price: result['price'] as double?,
      );
    }
  }

  Future<void> _executeOrder({
    required bool isBuy,
    required bool isMarket,
    required String qty,
    double? price,
  }) async {
    final option = widget.option;
    if (option == null) return;

    setState(() => _isExecuting = true);

    try {
      final orderInput = PlaceOrderInput(
        exch: option.exch ?? 'NFO',
        tsym: option.tsym ?? '',
        qty: qty,
        prc: isMarket ? '0' : (price?.toString() ?? '0'),
        prctype: isMarket ? 'MKT' : 'LMT',
        trantype: isBuy ? 'B' : 'S',
        prd: 'I', // Intraday for scalping
        ret: 'DAY',
        amo: 'No',
        trgprc: '',
        trailprc: '',
        blprc: '',
        bpprc: '',
        dscqty: '',
        mktProt: '',
        channel: 'WEB',
      );

      final result = await ref.read(orderProvider).fetchPlaceOrder(
            context,
            orderInput,
            false, // isExit
            quickOrder: true,
          );

      if (mounted) {
        if (result?.stat == 'Ok') {
          ResponsiveSnackBar.showSuccess(
            context,
            '${isBuy ? "Buy" : "Sell"} order placed: ${option.tsym}',
          );
        }
        // Error handling is done inside placeOrder
      }
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Order failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExecuting = false);
      }
    }
  }
}

/// Quick order button widget
class _QuickOrderButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool isMarket;
  final bool isBuy;
  final bool isExecuting;
  final VoidCallback onPressed;

  const _QuickOrderButton({
    required this.label,
    required this.tooltip,
    required this.isMarket,
    required this.isBuy,
    required this.isExecuting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isBuy ? MyntColors.profit : MyntColors.loss;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 26,
        height: 22,
        child: Material(
          color: isMarket ? baseColor : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          child: InkWell(
            onTap: isExecuting ? null : onPressed,
            borderRadius: BorderRadius.circular(3),
            child: Container(
              decoration: !isMarket
                  ? BoxDecoration(
                      border: Border.all(color: baseColor, width: 1),
                      borderRadius: BorderRadius.circular(3),
                    )
                  : null,
              child: Center(
                child: isExecuting
                    ? SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: isMarket ? Colors.white : baseColor,
                        ),
                      )
                    : Text(
                        label,
                        style: MyntWebTextStyles.caption(
                          context,
                          fontWeight: MyntFonts.bold,
                          color: isMarket ? Colors.white : baseColor,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quantity input dialog with optional price for limit orders
class _QuantityInputDialog extends StatefulWidget {
  final String symbol;
  final String defaultQty;
  final double currentLTP;
  final bool isBuy;
  final bool isMarket;
  final int lotSize;

  const _QuantityInputDialog({
    required this.symbol,
    required this.defaultQty,
    required this.currentLTP,
    required this.isBuy,
    required this.isMarket,
    required this.lotSize,
  });

  @override
  State<_QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<_QuantityInputDialog> {
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  final _qtyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.defaultQty);
    _priceController = TextEditingController(
      text: widget.currentLTP.toStringAsFixed(2),
    );
    // Auto-focus quantity field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _qtyFocusNode.requestFocus();
      _qtyController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _qtyController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _qtyFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final qty = _qtyController.text.trim();
    if (qty.isEmpty || int.tryParse(qty) == null || int.parse(qty) <= 0) {
      return;
    }

    double? price;
    if (!widget.isMarket) {
      price = double.tryParse(_priceController.text.trim());
      if (price == null || price <= 0) {
        return;
      }
    }

    Navigator.of(context).pop({
      'qty': qty,
      'price': price,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.isBuy;
    final isMarket = widget.isMarket;
    final actionColor = isBuy ? MyntColors.profit : MyntColors.loss;
    final actionText = '${isBuy ? "Buy" : "Sell"} ${isMarket ? "MKT" : "LMT"}';

    return Dialog(
      backgroundColor: resolveThemeColor(
        context,
        dark: MyntColors.listItemBgDark,
        light: MyntColors.listItemBg,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: actionColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    actionText,
                    style: MyntWebTextStyles.buttonSm(
                      context,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.symbol,
                    style: MyntWebTextStyles.body(
                      context,
                      fontWeight: MyntFonts.medium,
                      color: resolveThemeColor(
                        context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quantity input
            Text(
              'Quantity (Lot size: ${widget.lotSize})',
              style: MyntWebTextStyles.para(
                context,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _qtyController,
              focusNode: _qtyFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary,
                ),
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                filled: true,
                fillColor: resolveThemeColor(
                  context,
                  dark: MyntColors.searchBgDark,
                  light: MyntColors.searchBg,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: actionColor),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            // Price input for limit orders
            if (!isMarket) ...[
              const SizedBox(height: 12),
              Text(
                'Price',
                style: MyntWebTextStyles.para(
                  context,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: resolveThemeColor(
                    context,
                    dark: MyntColors.searchBgDark,
                    light: MyntColors.searchBg,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: actionColor),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ],
            const SizedBox(height: 16),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Place Order',
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight: MyntFonts.semiBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
