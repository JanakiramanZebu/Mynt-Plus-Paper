import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../models/order_book_model/place_order_model.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../scalper_provider.dart';

/// Bottom order bar with Buy/Sell buttons, lot controls, product type, order type
class ScalperOrderBar extends ConsumerStatefulWidget {
  const ScalperOrderBar({super.key});

  @override
  ConsumerState<ScalperOrderBar> createState() => _ScalperOrderBarState();
}

class _ScalperOrderBarState extends ConsumerState<ScalperOrderBar> {
  bool _isPlacingOrder = false;
  final TextEditingController _leftBuyPriceController = TextEditingController();
  final TextEditingController _leftSellPriceController = TextEditingController();
  final TextEditingController _rightBuyPriceController = TextEditingController();
  final TextEditingController _rightSellPriceController = TextEditingController();
  bool _leftBuyPriceInitialized = false;
  bool _leftSellPriceInitialized = false;
  bool _rightBuyPriceInitialized = false;
  bool _rightSellPriceInitialized = false;
  String? _lastCallToken;
  String? _lastPutToken;
  final TextEditingController _lotController = TextEditingController(text: '1');
  int _lastLotQuantity = 1;

  // FocusNodes with arrow key handlers for increment/decrement
  late final FocusNode _lotFocusNode = FocusNode(
    onKeyEvent: (node, event) => _handleLotKeyEvent(event),
  );
  late final FocusNode _leftBuyPriceFocus = FocusNode(
    onKeyEvent: (node, event) => _handlePriceKeyEvent(event, _leftBuyPriceController, 'left_buy', true),
  );
  late final FocusNode _leftSellPriceFocus = FocusNode(
    onKeyEvent: (node, event) => _handlePriceKeyEvent(event, _leftSellPriceController, 'left_sell', true),
  );
  late final FocusNode _rightBuyPriceFocus = FocusNode(
    onKeyEvent: (node, event) => _handlePriceKeyEvent(event, _rightBuyPriceController, 'right_buy', false),
  );
  late final FocusNode _rightSellPriceFocus = FocusNode(
    onKeyEvent: (node, event) => _handlePriceKeyEvent(event, _rightSellPriceController, 'right_sell', false),
  );

  @override
  void dispose() {
    _leftBuyPriceController.dispose();
    _leftSellPriceController.dispose();
    _rightBuyPriceController.dispose();
    _rightSellPriceController.dispose();
    _lotController.dispose();
    _lotFocusNode.dispose();
    _leftBuyPriceFocus.dispose();
    _leftSellPriceFocus.dispose();
    _rightBuyPriceFocus.dispose();
    _rightSellPriceFocus.dispose();
    super.dispose();
  }

  /// Handle arrow keys in lot quantity field
  KeyEventResult _handleLotKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    // Let Shift/Ctrl+arrow pass through for order shortcuts
    if (HardwareKeyboard.instance.isShiftPressed || HardwareKeyboard.instance.isControlPressed) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      ref.read(scalperProvider).incrementLotQuantity();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      ref.read(scalperProvider).decrementLotQuantity();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Handle arrow keys in price fields — increment/decrement by tick size
  KeyEventResult _handlePriceKeyEvent(
    KeyEvent event, TextEditingController controller, String priceKey, bool isCall,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    // Let Shift/Ctrl+arrow pass through for order shortcuts
    if (HardwareKeyboard.instance.isShiftPressed || HardwareKeyboard.instance.isControlPressed) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _adjustPrice(controller, priceKey, isCall, true);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _adjustPrice(controller, priceKey, isCall, false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Adjust price by tick size
  void _adjustPrice(TextEditingController controller, String priceKey, bool isCall, bool increment) {
    final scalper = ref.read(scalperProvider);
    final option = isCall ? scalper.selectedCall : scalper.selectedPut;
    final tickSize = double.tryParse(option?.ti ?? '0.05') ?? 0.05;
    final current = double.tryParse(controller.text) ?? 0.0;
    final newPrice = increment ? current + tickSize : current - tickSize;
    if (newPrice <= 0) return;
    // Round to tick size to avoid floating point errors
    final rounded = (newPrice / tickSize).round() * tickSize;
    controller.text = rounded.toStringAsFixed(2);
    scalper.setLimitPrice(priceKey, controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final scalper = ref.watch(scalperProvider);
    final callOption = scalper.selectedCall;
    final putOption = scalper.selectedPut;

    // Get call option data from websocket
    // Use direct watch (not select) to ensure initial data triggers rebuild
    final wsProvider = ref.watch(websocketProvider);
    final callData = callOption?.token != null
        ? wsProvider.socketDatas[callOption!.token]
        : null;

    // Get put option data from websocket
    final putData = putOption?.token != null
        ? wsProvider.socketDatas[putOption!.token]
        : null;

    // Parse ASK/BID prices from websocket depth data
    // sp1 = best sell price (ask), bp1 = best buy price (bid)
    final callAsk = callData?['sp1']?.toString() ?? callOption?.lp ?? '0.00';
    final callBid = callData?['bp1']?.toString() ?? callOption?.lp ?? '0.00';
    final putAsk = putData?['sp1']?.toString() ?? putOption?.lp ?? '0.00';
    final putBid = putData?['bp1']?.toString() ?? putOption?.lp ?? '0.00';

    // Dynamic labels based on option type (CE or PE)
    final leftType = callOption?.optt ?? 'CE';
    final rightType = putOption?.optt ?? 'PE';
    final isMarket = scalper.isMarketOrder;

    // Reset price initialization when selected options change (symbol/expiry switch)
    if (callOption?.token != _lastCallToken) {
      _lastCallToken = callOption?.token;
      _leftBuyPriceInitialized = false;
      _leftSellPriceInitialized = false;
    }
    if (putOption?.token != _lastPutToken) {
      _lastPutToken = putOption?.token;
      _rightBuyPriceInitialized = false;
      _rightSellPriceInitialized = false;
    }

    // Auto-fill limit prices when switching to Limit mode
    // Also sync to provider so keyboard shortcuts can read them
    final sp = ref.read(scalperProvider);
    if (!isMarket) {
      if (!_leftBuyPriceInitialized) {
        _leftBuyPriceController.text = callAsk;
        _leftBuyPriceInitialized = true;
        sp.setLimitPrice('left_buy', callAsk);
      }
      if (!_leftSellPriceInitialized) {
        _leftSellPriceController.text = callBid;
        _leftSellPriceInitialized = true;
        sp.setLimitPrice('left_sell', callBid);
      }
      if (!_rightBuyPriceInitialized) {
        _rightBuyPriceController.text = putAsk;
        _rightBuyPriceInitialized = true;
        sp.setLimitPrice('right_buy', putAsk);
      }
      if (!_rightSellPriceInitialized) {
        _rightSellPriceController.text = putBid;
        _rightSellPriceInitialized = true;
        sp.setLimitPrice('right_sell', putBid);
      }
    } else {
      // Reset when switching back to Market
      _leftBuyPriceInitialized = false;
      _leftSellPriceInitialized = false;
      _rightBuyPriceInitialized = false;
      _rightSellPriceInitialized = false;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: resolveThemeColor(
          context,
          dark: MyntColors.primaryDark.withValues(alpha: 0.04),
          light: MyntColors.primary.withValues(alpha: 0.04),
        ),
        border: Border(
          top: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          // Left chart option buttons (with separate buy/sell price inputs)
          _buildOptionSection(
            context, callOption, callAsk, callBid, leftType, true, isMarket,
            _leftBuyPriceController, _leftSellPriceController,
            _leftBuyPriceFocus, _leftSellPriceFocus,
          ),
          // Center controls
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLotControls(context, scalper),
                const SizedBox(width: 24),
                _buildProductTypeToggle(context, scalper),
                const SizedBox(width: 16),
                _buildOrderTypeButton(context, scalper),
              ],
            ),
          ),
          // Right chart option buttons (with separate buy/sell price inputs)
          _buildOptionSection(
            context, putOption, putAsk, putBid, rightType, false, isMarket,
            _rightBuyPriceController, _rightSellPriceController,
            _rightBuyPriceFocus, _rightSellPriceFocus,
          ),
        ],
      ),
    );
  }

  /// Builds the option section: separate limit price inputs for buy/sell + buttons
  Widget _buildOptionSection(
    BuildContext context,
    OptionValues? option,
    String askPrice,
    String bidPrice,
    String optType,
    bool isLeft,
    bool isMarket,
    TextEditingController buyPriceController,
    TextEditingController sellPriceController,
    FocusNode buyPriceFocus,
    FocusNode sellPriceFocus,
  ) {
    final buyColor = resolveThemeColor(
      context,
      dark: MyntColors.primaryDark,
      light: MyntColors.primary,
    );
    final sellColor = resolveThemeColor(
      context,
      dark: MyntColors.lossDark,
      light: MyntColors.tertiary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Buy column: price input + button
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMarket)
              _buildPriceInput(context, buyPriceController, isLeft ? 'left_buy' : 'right_buy', buyPriceFocus),
            _buildOrderButton(
              context: context,
              label: 'Buy $optType',
              subLabel: 'ASK: $askPrice',
              shortcut: isLeft ? 'Shift + ↑' : 'Ctrl + ↑',
              color: buyColor,
              isFilled: true,
              onPressed: option != null && !_isPlacingOrder
                  ? () => _placeOrder(option, true, option.optt == 'CE',
                      limitPrice: !isMarket ? buyPriceController.text : null)
                  : null,
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Sell column: price input + button
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMarket)
              _buildPriceInput(context, sellPriceController, isLeft ? 'left_sell' : 'right_sell', sellPriceFocus),
            _buildOrderButton(
              context: context,
              label: 'Sell $optType',
              subLabel: 'BID: $bidPrice',
              shortcut: isLeft ? 'Shift + ↓' : 'Ctrl + ↓',
              color: sellColor,
              isFilled: true,
              onPressed: option != null && !_isPlacingOrder
                  ? () => _placeOrder(option, false, option.optt == 'CE',
                      limitPrice: !isMarket ? sellPriceController.text : null)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInput(BuildContext context, TextEditingController controller, String priceKey, FocusNode focusNode) {
    final secondaryColor = resolveThemeColor(
      context,
      dark: MyntColors.textSecondaryDark,
      light: MyntColors.textSecondary,
    );

    return Container(
      width: 120,
      height: 30,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: resolveThemeColor(
          context,
          dark: MyntColors.transparent,
          light: const Color(0xffF1F3F8),
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: resolveThemeColor(
            context,
            dark: MyntColors.textSecondaryDark,
            light: MyntColors.primary,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (v) => ref.read(scalperProvider).setLimitPrice(priceKey, v),
              textAlign: TextAlign.center, 
              style: MyntWebTextStyles.bodySmall(
                context,
                darkColor: MyntColors.textWhite,
                lightColor: MyntColors.textBlack,
                fontWeight: MyntFonts.medium,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                border: InputBorder.none,
                hintText: 'Price',
                hintStyle: MyntWebTextStyles.bodySmall(
                  context,
                  color: secondaryColor,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),
          ),
        ],
      ),
    );
  } 

  Widget _buildOrderButton({
    required BuildContext context,
    required String label,
    required String subLabel,
    required String shortcut,
    required Color color,
    required bool isFilled,
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: shortcut,
      child: Material(
        color: isFilled
            ? (isEnabled ? color : color.withValues(alpha: 0.5))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: isFilled
                  ? null
                  : Border.all(
                      color: isEnabled ? color : color.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: MyntWebTextStyles.buttonSm(
                    context,
                    color: isFilled
                        ? Colors.white
                        : (isEnabled ? color : color.withValues(alpha: 0.5)),
                  ),
                ),
                Text(
                  subLabel,
                  style: MyntWebTextStyles.caption(
                    context,
                    color: isFilled
                        ? Colors.white.withValues(alpha: 0.8)
                        : (isEnabled
                            ? color.withValues(alpha: 0.8)
                            : color.withValues(alpha: 0.4)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLotControls(BuildContext context, ScalperProvider scalper) {
    final lotSize = int.tryParse(scalper.lotSize) ?? 1;
    final totalQty = scalper.lotQuantity * lotSize;
    final dividerColor = resolveThemeColor(context, dark: MyntColors.dividerDark, light: MyntColors.divider);

    // Sync controller text only when value changed externally (not while user is editing)
    if (scalper.lotQuantity != _lastLotQuantity && !_lotFocusNode.hasFocus) {
      _lastLotQuantity = scalper.lotQuantity;
      _lotController.text = scalper.lotQuantity.toString();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Lot (Qty: $totalQty)',
          style: MyntWebTextStyles.para(
            context,
            color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: dividerColor),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement button
              InkWell(
                onTap: () => ref.read(scalperProvider).decrementLotQuantity(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
                child: Container(
                  width: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: dividerColor)),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                  ),
                ),
              ),
              // Quantity input
              SizedBox(
                width: 44,
                child: TextField(
                  controller: _lotController,
                  focusNode: _lotFocusNode,
                  textAlign: TextAlign.center,
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight: MyntFonts.semiBold,
                    color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onSubmitted: (value) {
                    final qty = int.tryParse(value) ?? 1;
                    ref.read(scalperProvider).setLotQuantity(qty);
                  },
                ),
              ),
              // Increment button
              InkWell(
                onTap: () => ref.read(scalperProvider).incrementLotQuantity(),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                child: Container(
                  width: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: dividerColor)),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductTypeToggle(
      BuildContext context, ScalperProvider scalper) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Product',
          style: MyntWebTextStyles.para(
            context,
            color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        _buildSegmentedControl(
          context: context,
          options: ['Intraday', 'Delivery'],
          selectedIndex: scalper.isIntraday ? 0 : 1,
          onTap: (index) => ref.read(scalperProvider).setProductType(index == 0),
        ),
      ],
    );
  }

  Widget _buildOrderTypeButton(BuildContext context, ScalperProvider scalper) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Order Type',
          style: MyntWebTextStyles.para(
            context,
            color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        _buildSegmentedControl(
          context: context,
          options: ['Market', 'Limit'],
          selectedIndex: scalper.isMarketOrder ? 0 : 1,
          onTap: (index) => ref.read(scalperProvider).setOrderType(index == 0),
        ),
      ],
    );
  }

  /// Segmented control matching the app's toggle pattern
  Widget _buildSegmentedControl({
    required BuildContext context,
    required List<String> options,
    required int selectedIndex,
    required void Function(int) onTap,
  }) {
    final primary = resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary);
    final dividerColor = resolveThemeColor(context, dark: MyntColors.dividerDark, light: MyntColors.divider);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == selectedIndex;
          final isFirst = index == 0;
          final isLast = index == options.length - 1;

          return InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.only(
              topLeft: isFirst ? const Radius.circular(5) : Radius.zero,
              bottomLeft: isFirst ? const Radius.circular(5) : Radius.zero,
              topRight: isLast ? const Radius.circular(5) : Radius.zero,
              bottomRight: isLast ? const Radius.circular(5) : Radius.zero,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: isFirst ? const Radius.circular(5) : Radius.zero,
                  bottomLeft: isFirst ? const Radius.circular(5) : Radius.zero,
                  topRight: isLast ? const Radius.circular(5) : Radius.zero,
                  bottomRight: isLast ? const Radius.circular(5) : Radius.zero,
                ),
              ),
              child: Text(
                label,
                style: MyntWebTextStyles.para(
                  context,
                  fontWeight: isSelected ? MyntFonts.bold : MyntFonts.medium,
                  color: isSelected
                      ? Colors.white
                      : resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _placeOrder(
      OptionValues option, bool isBuy, bool isCall,
      {String? limitPrice}) async {
    if (_isPlacingOrder) return;

    final scalper = ref.read(scalperProvider);
    final isMarket = scalper.isMarketOrder;

    // For limit orders, use the user-entered price from the textbox
    String price = '0';
    if (!isMarket) {
      price = limitPrice ?? '0';
      if (price.isEmpty || price == '0' || price == '0.00') {
        // Fallback to LTP if textbox is empty
        final socketData = ref.read(websocketProvider).socketDatas[option.token];
        price = socketData?['lp']?.toString() ?? option.lp ?? '0';
      }
    }

    setState(() => _isPlacingOrder = true);

    try {
      final qty = scalper.totalOrderQuantity.toString();
      // Options (NFO/BFO) use NRML for delivery, not CNC
      final prd = scalper.isIntraday ? 'I' : 'NRML';
      final prcType = isMarket ? 'MKT' : 'LMT';

      final orderInput = PlaceOrderInput(
        exch: option.exch ?? 'NFO',
        tsym: option.tsym ?? '',
        qty: qty,
        prc: price,
        prctype: prcType,
        trantype: isBuy ? 'B' : 'S',
        prd: prd,
        ret: 'DAY',
        amo: 'No',
        trgprc: '',
        trailprc: '',
        blprc: '',
        bpprc: '',
        dscqty: '',
        mktProt: (isMarket && scalper.isMktProtectionEnabled)
            ? scalper.mktProtectionPoints.toString()
            : '',
        channel: 'WEB',
      );

      final result = await ref.read(orderProvider).fetchPlaceOrder(
            context,
            orderInput,
            false,
            quickOrder: true,
          );

      if (mounted) {
        if (result?.stat == 'Ok') {
          _showSnackbar(
            context,
            '${isBuy ? 'Buy' : 'Sell'} ${isCall ? 'Call' : 'Put'} order placed successfully',
            isSuccess: true,
          );
        } else {
          _showSnackbar(
            context,
            result?.emsg ?? 'Order failed',
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar(context, 'Order failed: $e', isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  void _showSnackbar(BuildContext context, String message,
      {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? MyntColors.profit : MyntColors.loss,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
