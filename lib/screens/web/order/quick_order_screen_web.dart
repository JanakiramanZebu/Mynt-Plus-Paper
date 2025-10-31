import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:mynt_plus/models/marketwatch_model/scrip_info.dart';
import 'package:mynt_plus/models/order_book_model/place_order_model.dart';
import 'package:mynt_plus/models/order_book_model/order_margin_model.dart';
import 'package:mynt_plus/models/order_book_model/order_book_model.dart';
import 'package:mynt_plus/provider/order_input_provider.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/network_state_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/sharedWidget/cust_text_formfield.dart';
import 'package:mynt_plus/sharedWidget/custom_widget_button.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:mynt_plus/sharedWidget/enums.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/screens/Mobile/order_screen/margin_charges_bottom_sheet.dart';
import 'package:mynt_plus/screens/Mobile/market_watch/slice_order_pop.dart';
import 'package:mynt_plus/utils/responsive_navigation.dart';

class QuickOrderScreenWeb extends ConsumerStatefulWidget {
  final OrderScreenArgs orderArg;
  final ScripInfoModel scripInfo;
  final bool embedded; // if true, render without Scaffold/AppBar for inline use
  const QuickOrderScreenWeb({super.key, required this.orderArg, required this.scripInfo, this.embedded = false});

  @override
  ConsumerState<QuickOrderScreenWeb> createState() => _QuickOrderScreenWebState();
}

class _QuickOrderScreenWebState extends ConsumerState<QuickOrderScreenWeb> {
  bool? isBuy;
  String orderType = "Delivery"; // Delivery, Intraday
  String priceType = "Limit"; // Limit, Market, SL Limit, SL MKT
  String validityType = "DAY"; // DAY | IOC | EOS

  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController trgCtrl = TextEditingController();
  final TextEditingController discQtyCtrl = TextEditingController(text: "0");
  final TextEditingController mktProtCtrl = TextEditingController(text: "5");

  bool _isMarketOrder = false;
  bool _isStoplossOrder = false;
  bool _isQtyToAmount = false;
  bool _afterMarketOrder = false;
  bool _addValidityAndDisclosedQty = false;

  String ordPrice = "0.00";
  int lotSize = 0;
  int frezQty = 0;
  double tik = 0.0;
  bool _surveillanceConfirmed = false;

  void _initializeFromProps() {
    isBuy = widget.orderArg.transType;
    tik = double.tryParse(widget.scripInfo.ti?.toString() ?? "0") ?? 0.0;
    lotSize = int.tryParse(widget.scripInfo.ls?.toString() ?? '1') ?? 1;
    final sfq = int.tryParse(widget.scripInfo.frzqty?.toString() ?? '1') ?? 1;
    frezQty = sfq > 1 ? (sfq / lotSize).floor() * lotSize : lotSize;

    if ((widget.orderArg.prd ?? '').isNotEmpty) {
      orderType = {
            'C': 'Delivery',
            'I': 'Intraday',
          }[widget.orderArg.prd] ??
          'Delivery';
    } else {
      orderType = 'Delivery';
    }

    qtyCtrl.text = widget.orderArg.isExit
        ? (widget.orderArg.holdQty ?? '1').replaceAll('-', '')
        : (widget.orderArg.lotSize ?? '1').replaceAll('-', '');

    if (ref.read(websocketProvider).socketDatas.containsKey(widget.scripInfo.token)) {
      ordPrice = "${ref.read(websocketProvider).socketDatas["${widget.scripInfo.token}"]['lp']}";
    } else {
      ordPrice = widget.orderArg.ltp ?? "0.00";
    }
    priceCtrl.text = ordPrice;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordInputProvider).chngInvesType(
          widget.scripInfo.seg == "EQT" ? InvestType.delivery : InvestType.carryForward,
          "PlcOrder");
      ref.read(ordInputProvider).chngPriceType(priceType, widget.orderArg.exchange);
      _marginUpdate();
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeFromProps();
  }

  @override
  void didUpdateWidget(covariant QuickOrderScreenWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool tokenChanged = oldWidget.scripInfo.token != widget.scripInfo.token;
    final bool exchChanged = oldWidget.orderArg.exchange != widget.orderArg.exchange;
    final bool prdChanged = (oldWidget.orderArg.prd ?? '') != (widget.orderArg.prd ?? '');
    final bool transChanged = oldWidget.orderArg.transType != widget.orderArg.transType;
    if (tokenChanged || exchChanged || prdChanged || transChanged) {
      setState(() {
        _initializeFromProps();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final internet = ref.watch(networkStateProvider);
    final orderProvide = ref.watch(orderProvider);

    final content = Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 20, bottom:12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.embedded) _instrumentHeader(theme),
          if (!widget.embedded) const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _orderTypeTabs(theme)),           
          ]),
          const SizedBox(height: 12),
          _qtyAndPrice(theme),
          const SizedBox(height: 12),

           Padding(
             padding: const EdgeInsets.symmetric(vertical: 4),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 TextButton(
                    onPressed: _openAdvance,
                    child: Text(
                      "Advance",
                      style: WebTextStyles.para(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
                        fontWeight: WebFonts.semiBold,
                      ),
                    ),
                  ),
               ],
             ),
           ),
          // Quick mode intentionally omits Stoploss/AMO/Validity sections
          if (internet.connectionStatus != ConnectivityResult.none)
            _marginAndBalance(theme),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: internet.connectionStatus == ConnectivityResult.none
                      ? null
                      : () async {
                          isBuy = true;
                          await _placeOrder(theme);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    minimumSize: const Size(0, 45),
                  ),
                  child: orderProvide.orderloader
                      ? const SizedBox(width: 18, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xffffffff)))
                      : Text(
                          'Buy',
                          style: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: colors.colorWhite,
                            fontWeight: WebFonts.bold,
                            
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: internet.connectionStatus == ConnectivityResult.none
                      ? null
                      : () async {
                          isBuy = false;
                          await _placeOrder(theme);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.tertiary,
                    minimumSize: const Size(0, 45),
                  ),
                  child: orderProvide.orderloader
                      ? const SizedBox(width: 18, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xffffffff)))
                      : Text(
                          'Sell',
                          style: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: colors.colorWhite,
                            fontWeight: WebFonts.bold,
                            
                          ),
                        ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: AppBar(
        elevation: .4,
        title: Text(
          "Quick Order",
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            fontWeight: WebFonts.semiBold,
            
          ),
        ),
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _instrumentHeader(ThemesProvider theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.scripInfo.symbol?.replaceAll("-EQ", "") ?? widget.orderArg.tSym}",
                style: WebTextStyles.sub(
                  isDarkTheme: theme.isDarkMode,
                  fontWeight: WebFonts.bold,
                  
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  CustomExchBadge(exch: " ${widget.scripInfo.exch}"),
                  const SizedBox(width: 8),
                  Text(
                    "LTP: ${widget.orderArg.ltp ?? ordPrice}",
                    style: WebTextStyles.para(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      fontWeight: WebFonts.regular,
                      
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        IconButton(
          onPressed: () => setState(() => isBuy = !(isBuy ?? true)),
          icon: Icon(isBuy! ? Icons.north_east : Icons.south_west,
              color: isBuy! ? colors.successLight : colors.lossLight),
        )
      ],
    );
  }

  Widget _orderTypeTabs(ThemesProvider theme) {
    final tabs = const ["Delivery", "Intraday"]; // keep scope same as quick order
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final t = tabs[index];
          final isSelected = orderType == t;
          return TextButton(
            onPressed: () {
              setState(() {
                orderType = t;
                ref.read(ordInputProvider).chngInvesType(
                    t == "Intraday" ? InvestType.intraday : InvestType.delivery, "PlcOrder");
                _onOrderTypeChanged();
                _marginUpdate();
              });
              FocusScope.of(context).unfocus();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              backgroundColor:
                  isSelected ? (theme.isDarkMode ? colors.primaryDark : colors.primaryLight) : colors.colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: isSelected
                    ? BorderSide(color: colors.colorWhite, width: 1)
                    : BorderSide(color: colors.primaryLight, width: 1),
              ),
              minimumSize: const Size(0, 30),
            ),
            child: Text(
              t == "Delivery" ? "Delivery" : t,
              style: WebTextStyles.custom(
                fontSize: 13,
                isDarkTheme: theme.isDarkMode,
                color: isSelected
                    ? colors.colorWhite
                    : (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
                fontWeight: WebFonts.bold,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: tabs.length,
      ),
    );
  }

  Widget _qtyAndPrice(ThemesProvider theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              _isQtyToAmount ? "Amount" : "Qty",
              style: WebTextStyles.para(
                isDarkTheme: theme.isDarkMode,
                fontWeight: WebFonts.semiBold,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: CustomTextFormField(
                fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                hintText: "0",
                inputFormate: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                textCtrl: qtyCtrl,
                textAlign: TextAlign.start,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fontWeight: WebFonts.semiBold,
                  
                ),
                suffixIcon: widget.scripInfo.instname == "EQ"
                    ? IconButton(
                        onPressed: () => setState(() {
                          _isQtyToAmount = !_isQtyToAmount;
                          _marginUpdate();
                        }),
                        icon: SvgPicture.asset(assets.switchIcon, fit: BoxFit.scaleDown),
                      )
                    : null,
                onChanged: (_) => _marginUpdate(),
              ),
            )
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                "Price",
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  fontWeight: WebFonts.semiBold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                priceType,
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fontWeight: WebFonts.semiBold,
                ),
              ),
            ]),
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: CustomTextFormField(
                fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                hintText: widget.orderArg.ltp ?? ordPrice,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textCtrl: priceCtrl,
                textAlign: TextAlign.start,
                isReadable: priceType == "Limit" || priceType == "SL Limit" ? false : true,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fontWeight: WebFonts.semiBold,
                  
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isMarketOrder = !_isMarketOrder;
                      _updatePriceType();
                      ref.read(ordInputProvider).chngPriceType(priceType, widget.orderArg.exchange);
                      _marginUpdate();
                    });
                  },
                  icon: SvgPicture.asset(assets.switchIcon, fit: BoxFit.scaleDown),
                ),
                onChanged: (v) {
                  final val = double.tryParse(v) ?? 0;
                  if (v.isEmpty || val <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(warningMessage(context, "Price can not be ${val <= 0 ? 'zero' : 'empty'}"));
                  } else {
                    setState(() => ordPrice = v);
                    _marginUpdate();
                  }
                },
              ),
            )
          ]),
        ),
      ],
    );
  }

  Widget _trigger(ThemesProvider theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Trigger",
        style: WebTextStyles.sub(
          isDarkTheme: theme.isDarkMode,
          fontWeight: WebFonts.regular,
          
        ),
      ),
      const SizedBox(height: 6),
      SizedBox(
        height: 44,
        child: CustomTextFormField(
          fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
          hintText: "0.00",
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textCtrl: trgCtrl,
          textAlign: TextAlign.start,
          onChanged: (value) {
            if (value.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(warningMessage(context, "Trigger can not be empty"));
            } else {
              _marginUpdate();
            }
          },
          style: WebTextStyles.custom(
            fontSize: 16,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fontWeight: WebFonts.regular,
            
          ),
        ),
      )
    ]);
  }

  Widget _advanced(ThemesProvider theme) {
    return Column(children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'Stoploss order',
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            fontWeight: WebFonts.bold,
            
          ),
        ),
        trailing: Switch(
          value: _isStoplossOrder,
          onChanged: (v) {
            setState(() {
              _isStoplossOrder = v;
              _updatePriceType();
              ref.read(ordInputProvider).chngPriceType(priceType, widget.orderArg.exchange);
              _marginUpdate();
            });
          },
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'After market order (AMO)',
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            fontWeight: WebFonts.bold,
            
          ),
        ),
        trailing: Switch(
          value: _afterMarketOrder,
          onChanged: (v) => setState(() => _afterMarketOrder = v),
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'Add validity & Disclosed quantity',
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            fontWeight: WebFonts.bold,
            
          ),
        ),
        trailing: Switch(
          value: _addValidityAndDisclosedQty,
          onChanged: (v) => setState(() => _addValidityAndDisclosedQty = v),
        ),
      ),
      if (_addValidityAndDisclosedQty)
        Row(children: [
          DropdownButton<String>(
            value: validityType,
            items: (widget.orderArg.exchange == "BSE" || widget.orderArg.exchange == "BFO"
                    ? const ["DAY", "IOC", "EOS"]
                    : const ["DAY", "IOC"]) // web quick scope
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => validityType = v ?? "DAY"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44,
              child: CustomTextFormField(
                fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                hintText: "Disclosed Qty",
                inputFormate: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                textCtrl: discQtyCtrl,
                textAlign: TextAlign.start,
              ),
            ),
          )
        ])
    ]);
  }

  Widget _marginAndBalance(ThemesProvider theme) {
    final orderProvide = ref.watch(orderProvider);
    final clientFundDetail = ref.watch(fundProvider).fundDetailModel;
    return Row(children: [
      CustomWidgetButton(
        onPress: () {
          _marginUpdate();
          BrokerageInput bInput = BrokerageInput(
              exch: "${widget.scripInfo.exch}",
              prc: priceCtrl.text,
              prd: ref.read(ordInputProvider).orderType,
              qty: "${widget.scripInfo.ls}",
              trantype: isBuy! ? "B" : "S",
              tsym: "${widget.scripInfo.tsym}");
          ref.read(orderProvider).fetchGetBrokerage(bInput, context);
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              builder: (ctx) => const MarginDetailsBottomsheet());
        },
        widget: Row(children: [
          Text(
            "Required ",
            style: WebTextStyles.caption(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fontWeight: WebFonts.medium,
              
            ),
          ),
          Text(
            "${orderProvide.orderMarginModel == null ? 0.00 : orderProvide.orderMarginModel!.ordermargin} + ${orderProvide.getBrokerageModel == null ? 0.00 : orderProvide.getBrokerageModel!.brkageAmt ?? 0.00}",
            style: WebTextStyles.caption(
              isDarkTheme: theme.isDarkMode,
              fontWeight: WebFonts.semiBold,
              color: !theme.isDarkMode ? colors.colorBlue : colors.colorLightBlue,
              
            ),
          ),
          Icon(Icons.arrow_drop_down, color: !theme.isDarkMode ? colors.colorBlue : colors.colorLightBlue)
        ]),
      ),
      const SizedBox(width: 12),
      Text(
        "Balance ${clientFundDetail?.avlMrg ?? ''}",
        style: WebTextStyles.caption(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          fontWeight: WebFonts.medium,
          
        ),
      ),
      const Spacer(),
      IconButton(onPressed: _marginUpdate, icon: SvgPicture.asset(assets.reloadIcon))
    ]);
  }

  void _onOrderTypeChanged() {
    _isStoplossOrder = false; // SL options are disabled in quick order
    _afterMarketOrder = false;
    _addValidityAndDisclosedQty = false;
    _updatePriceType();
  }

  void _updatePriceType() {
    // Quick order supports only Limit/Market
    if (_isMarketOrder) {
      priceType = "Market";
    } else {
      priceType = "Limit";
    }

    if (priceType == "Market" || priceType == "SL MKT") {
      priceCtrl.text = "Market";
      final ltp = double.tryParse(widget.orderArg.ltp ?? "0") ?? 0.0;
      final prot = double.tryParse(mktProtCtrl.text.isEmpty ? "0" : mktProtCtrl.text) ?? 0.0;
      double px = isBuy! ? ltp + (ltp * prot / 100) : ltp - (ltp * prot / 100);
      double result = px + (double.tryParse(widget.scripInfo.ti?.toString() ?? '0') ?? 0) / 2;
      final step = double.tryParse(widget.scripInfo.ti?.toString() ?? '0') ?? 0.0;
      if (step > 0) {
        result -= result % step;
      }
      final uc = double.tryParse(widget.scripInfo.uc?.toString() ?? '0') ?? double.infinity;
      final lc = double.tryParse(widget.scripInfo.lc?.toString() ?? '0') ?? 0.0;
      if (result >= uc) {
        ordPrice = "${widget.scripInfo.uc ?? 0.00}";
      } else if (result <= lc) {
        ordPrice = "${widget.scripInfo.lc ?? 0.00}";
      } else {
        ordPrice = result.toStringAsFixed(2);
      }
    } else if (priceCtrl.text == "Market") {
      priceCtrl.text = widget.orderArg.ltp ?? ordPrice;
      ordPrice = priceCtrl.text;
    }
  }

  String _convertQtyOrAmtValue(String value) {
    final ltp = double.tryParse(widget.orderArg.ltp ?? '0.0') ?? 0.0;
    if (!_isQtyToAmount) return value;
    if (ltp <= 0) return '0';
    return ((double.tryParse(value) ?? 0.0) ~/ ltp).toString();
  }

  void _marginUpdate() {
    final input = OrderMarginInput(
        exch: "${widget.scripInfo.exch}",
        prc: (priceType == "Market" || priceType == "SL MKT") ? "0" : ordPrice,
        prctyp: ref.read(ordInputProvider).prcType,
        prd: ref.read(ordInputProvider).orderType,
        qty: widget.scripInfo.exch == 'MCX'
            ? ((double.tryParse(_convertQtyOrAmtValue(qtyCtrl.text))?.toInt() ?? 0) * lotSize).toString()
            : _convertQtyOrAmtValue(qtyCtrl.text),
        rorgprc: '0',
        rorgqty: '0',
        trantype: isBuy! ? "B" : "S",
        tsym: "${widget.scripInfo.tsym}",
        blprc: '',
        bpprc: '',
        trgprc: (priceType == "SL Limit" || priceType == "SL MKT") ? trgCtrl.text : "");
    ref.read(orderProvider).fetchOrderMargin(input, context);

    BrokerageInput bInput = BrokerageInput(
        exch: "${widget.scripInfo.exch}",
        prc: (priceType == "Market" || priceType == "SL MKT") ? "0" : ordPrice,
        prd: ref.read(ordInputProvider).orderType,
        qty: widget.scripInfo.exch == 'MCX'
            ? ((double.tryParse(_convertQtyOrAmtValue(qtyCtrl.text))?.toInt() ?? 0) * lotSize).toString()
            : _convertQtyOrAmtValue(qtyCtrl.text),
        trantype: isBuy! ? "B" : "S",
        tsym: "${widget.scripInfo.tsym}");
    ref.read(orderProvider).fetchGetBrokerage(bInput, context);
  }

  Future<void> _placeOrder(ThemesProvider theme) async {
    final orderProv = ref.read(orderProvider);
    // Required fields
    if (_convertQtyOrAmtValue(qtyCtrl.text).trim().isEmpty ||
        priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(warningMessage(context,
          _convertQtyOrAmtValue(qtyCtrl.text).isEmpty ? "Quantity can not be empty" : "Price can not be empty"));
      return;
    }
    if (_convertQtyOrAmtValue(qtyCtrl.text) == '0' || priceCtrl.text == '0') {
      ScaffoldMessenger.of(context).showSnackBar(warningMessage(context,
          _convertQtyOrAmtValue(qtyCtrl.text) == '0' ? "Quantity can not be 0" : "Price can not be 0"));
      return;
    }

    // Qty multiple of lot size (except MCX qty handling which we map at send time)
    final enteredQty = int.tryParse(_convertQtyOrAmtValue(qtyCtrl.text)) ?? 0;
    final qRounded = ((enteredQty / lotSize).round() * lotSize);
    if (enteredQty != qRounded && widget.scripInfo.exch != 'MCX') {
      ScaffoldMessenger.of(context).showSnackBar(
          warningMessage(context, "Quantity should be multiple of lot size $lotSize => $qRounded"));
      return;
    }

    // Slice order flow if qty exceeds freeze quantity
    final frezQtyOrderSliceMaxLimit = orderProv.frezQtyOrderSliceMaxLimit;
    int slices = 0;
    int remainder = 0;
    if (frezQty > lotSize && enteredQty > frezQty) {
      slices = enteredQty ~/ frezQty;
      remainder = enteredQty % frezQty;
      final totalOrders = slices + (remainder > 0 ? 1 : 0);
      if (totalOrders > frezQtyOrderSliceMaxLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context,
                "Quantity can only be split into a maximum of $frezQtyOrderSliceMaxLimit slice. (Ex: $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQty * frezQtyOrderSliceMaxLimit})"));
        return;
      }
      // Confirm surveillance before showing slice sheet
      if (!_surveillanceConfirmed) {
        await _showSurveillanceBottomSheet(theme, () async {
          _surveillanceConfirmed = true;
          await _openSliceSheet(theme, enteredQty, slices, remainder);
        });
        return;
      }
      await _openSliceSheet(theme, enteredQty, slices, remainder);
      return;
    }

    // Surveillance confirmation (one-time)
    if (!_surveillanceConfirmed) {
      await _showSurveillanceBottomSheet(theme, () async {
        _surveillanceConfirmed = true;
        await _placeOrder(theme); // re-enter after confirmation
      });
      return;
    }

    // Tick validations (only for Limit)
    if (priceType == "Limit") {
      final r = _roundOffWithInterval(double.tryParse(priceCtrl.text) ?? 0, tik).toStringAsFixed(2);
      if ((double.tryParse(priceCtrl.text) ?? 0) != double.parse(r)) {
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, "Price should be multiple of tick size $tik => $r"));
        return;
      }
    }

    // Market protection for market orders
    if ((priceType == "Market" || priceType == "SL MKT")) {
      final prot = int.tryParse(mktProtCtrl.text.isEmpty ? '0' : mktProtCtrl.text) ?? 0;
      if (prot > 20 || prot < 1) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, "Market Protection between 1% to 20%"));
        return;
      }
    }

    // Circuit validations for non-market
    if (priceType == "Limit") {
      final lc = double.tryParse("${widget.scripInfo.lc ?? 0.00}") ?? 0.0;
      final uc = double.tryParse("${widget.scripInfo.uc ?? 0.00}") ?? double.infinity;
      final px = double.tryParse(ordPrice) ?? 0.0;
      if (px < lc || px > uc) {
        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
            context,
            px < lc
                ? "Price can not be lesser than Lower Circuit Limit ${widget.scripInfo.lc ?? 0.00}"
                : "Price can not be greater than Upper Circuit Limit ${widget.scripInfo.uc ?? 0.00}"));
        return;
      }
    }

    // Ready to place
    ref.read(orderProvider).setOrderloader(true);
    final input = PlaceOrderInput(
      amo: _afterMarketOrder ? "Yes" : "",
      blprc: '',
      bpprc: '',
      dscqty: discQtyCtrl.text,
      exch: widget.scripInfo.exch!,
      prc: ordPrice,
      prctype: ref.read(ordInputProvider).prcType,
      prd: ref.read(ordInputProvider).orderType,
      qty: widget.scripInfo.exch == 'MCX'
          ? ((int.tryParse(_convertQtyOrAmtValue(qtyCtrl.text)) ?? 0) * lotSize).toString()
          : _convertQtyOrAmtValue(qtyCtrl.text),
      ret: validityType,
      trailprc: '',
      trantype: isBuy! ? 'B' : 'S',
      trgprc: "",
      tsym: widget.scripInfo.tsym!,
      mktProt: (priceType == "Market" || priceType == "SL MKT") ? mktProtCtrl.text : '',
      channel: '',
    );
    await ref.read(orderProvider).fetchPlaceOrder(context, input, widget.orderArg.isExit);
    ref.read(orderProvider).setOrderloader(false);
    if (mounted) Navigator.of(context).maybePop();
  }

  double _roundOffWithInterval(double input, double interval) {
    if (interval <= 0) return input;
    return ((input / interval).round() * interval);
  }

  Future<void> _openAdvance() async {
    await ResponsiveNavigation.toPlaceOrderScreen(context: context, arguments: {
      "orderArg": widget.orderArg,
      "scripInfo": widget.scripInfo,
      "isBskt": "",
    });
  }

  Future<void> _openSliceSheet(ThemesProvider theme, int enteredQty, int slices, int remainder) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      context: context,
      builder: (context) => SliceOrderSheet(
        scripInfo: widget.scripInfo,
        isBuy: isBuy ?? true,
        quantity: slices,
        frezQty: frezQty,
        reminder: remainder,
        isAmo: _afterMarketOrder,
        orderType: orderType,
        priceType: priceType,
        ordPrice: ordPrice,
        validityType: validityType,
        stopLossCtrl: TextEditingController(text: ''),
        targetCtrl: TextEditingController(text: ''),
        discQtyCtrl: discQtyCtrl,
        triggerPriceCtrl: trgCtrl,
        mktProtCtrl: mktProtCtrl,
        isBracketOrderEnabled: false,
        lotSize: lotSize,
      ),
    );
  }

  Future<void> _showSurveillanceBottomSheet(ThemesProvider theme, Future<void> Function() onContinue) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(children: [
                    const Icon(Icons.warning_outlined,
                        color: Color.fromARGB(190, 255, 170, 0), size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        " Exchange surveillance active",
                        style: WebTextStyles.title(
                          isDarkTheme: theme.isDarkMode,
                          fontWeight: WebFonts.medium,
                          
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text(
                    "Please confirm to proceed with your order.",
                    style: WebTextStyles.sub(
                      isDarkTheme: theme.isDarkMode,
                      fontWeight: WebFonts.regular,
                      
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await onContinue();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        "Continue",
                        style: WebTextStyles.sub(
                          isDarkTheme: theme.isDarkMode,
                          color: colors.colorWhite,
                          fontWeight: WebFonts.semiBold,
                          
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
          ),
        );
  }
}


