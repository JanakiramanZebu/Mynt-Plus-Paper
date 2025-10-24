import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import '../../utils/url_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/profile_all_details_provider.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import '../../../res/res.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../models/marketwatch_model/scrip_info.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../models/order_book_model/order_margin_model.dart';
import '../../models/order_book_model/place_gtt_order.dart';
import '../../models/order_book_model/place_order_model.dart';
import '../../models/order_book_model/sip_place_order.dart';
import '../../provider/auth_provider.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/network_state_provider.dart';
import '../../provider/order_input_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/shocase_provider.dart';
import '../../provider/sip_order_provider.dart';
import '../../provider/thems.dart';
import '../../provider/transcation_provider.dart';
import '../../provider/user_profile_provider.dart';
import '../../provider/websocket_provider.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_widget_button.dart';
import '../../sharedWidget/enums.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_internet_widget.dart';
import '../../sharedWidget/snack_bar.dart';
import '../market_watch/slice_order_pop.dart';
import '../profile_screen/profile_main_screen.dart';
import 'gtt_condition.dart';
import 'invest_type_widget.dart';
import 'margin_charges_bottom_sheet.dart';
import 'order_screen_header.dart';
import 'package:intl/intl.dart';
import '../../provider/chart_provider.dart';

class PlaceOrderScreen extends ConsumerStatefulWidget {
  final OrderScreenArgs orderArg;
  final ScripInfoModel scripInfo;
  final String isBasket;
  final bool fromChart;
  const PlaceOrderScreen({super.key, required this.scripInfo, required this.orderArg, required this.isBasket, this.fromChart = false});

  @override
  ConsumerState<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends ConsumerState<PlaceOrderScreen> with TickerProviderStateMixin {
  bool? isBuy;
//   bool addStoploss = false;
  bool isAgree = false;
  String quotemsg = "";
//   bool addValidity = false;
//   bool isAmo = false;
  bool isAvbSecu = false;
  bool isSecu = false;

  late AnimationController anibuildctrl;
  // late Animation<double> _shakeAnimation;
  TextEditingController priceCtrl = TextEditingController();
  TextEditingController mktProtCtrl = TextEditingController();
  TextEditingController qtyCtrl = TextEditingController();
  TextEditingController discQtyCtrl = TextEditingController();
  TextEditingController triggerPriceCtrl = TextEditingController();
  TextEditingController stopLossCtrl = TextEditingController();
  TextEditingController targetCtrl = TextEditingController();
  TextEditingController trailingTicksCtrl = TextEditingController();

  TextEditingController sipLtpctrl = TextEditingController();
  TextEditingController sipname = TextEditingController();
  TextEditingController sipqtyctrl = TextEditingController();

  final Preferences pref = locator<Preferences>();

  DateTime now = DateTime.now();
  String formattedDate = "";
  String selectedValue = 'Daily';
  double resultsip = 0.0;

  String mktProtErrorText = "";
  TextEditingController mktProtDialogCtrl = TextEditingController();

  int frezQty = 0;
  int reminder = 0;
  int maxQty = 0;
  int quantity = 0;
  List orderTypes = ["Delivery", "Intraday", "CO - BO"];

  List priceTypes = ["Limit", "Market", "SL Limit", "SL MKT"];
  List<String> validityTypes = ["DAY", "IOC", "EOS"];
  List<String> sipDropdown = ['Daily', 'Weekly', 'Fortnightly', 'Monthly'];
  bool isOco = false;
  bool isGtt = true;

  // List<String> validityTypesGTT = ["DAY", "GTT"];
  bool _isStock =true;
  int lotSize = 0;
  int multiplayer = 0;
  String ordPrice = "0.00";
  String validityType = "GTT";
  String orderType = "Delivery";
  String priceType = "Limit";
  // String validityTypeGTT = "DAY";
  double tik = 0.00;
  double roundOffWithInterval(double input, double interval) {
    return ((input / interval).round() * interval);
  }

  Map userOrderPreference = {};
  bool isUserOrderPreferenceAvailable = false;
  final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();

  bool isAdvancedOptionClicked = false;
  bool _isMarketOrder = false;
  bool _isQtyToAmount = false;
  bool _isLotToQty = true;
  bool _isStoplossOrder = false;
  bool _afterMarketOrder = false;
  bool _addValidityAndDisclosedQty = false;
  bool _isCoverOrderEnabled = true;
  bool _isBracketOrderEnabled = false;
  bool _isMTFEnabled = false;
  // bool _GTTPriceTypeIsMarket = false;
  // bool _GTTOCOPriceTypeIsMarket = false;

  bool _hasValidCircuitBreakerValues = false;

  @override
  void initState() {
    ref.read(fundProvider).fetchFunds(context);

    userOrderPreference = ref.read(authProvider).savedOrderPreference;
    if (userOrderPreference.isNotEmpty && !widget.orderArg.isModify) {
      isUserOrderPreferenceAvailable = true;
    }

    tik = double.parse(widget.scripInfo.ti.toString());
    bool checkRawValue = widget.orderArg.raw.isNotEmpty;
    Map orderRawValue = widget.orderArg.raw;
    bool prdcheck = widget.orderArg.prd?.isNotEmpty ?? false;
    
    _isStock = widget.scripInfo.exch == "NSE" || widget.scripInfo.exch == "BSE";

    orderType = prdcheck // ① honour prd
        ? {"C": "Delivery", "I": "Intraday", "F": "MTF"}[widget.orderArg.prd] ?? "Delivery"
        : checkRawValue // ② old logic
            ? {"B": "CO - BO", "H": "CO - BO", "I": "Intraday", "F": "MTF"}[orderRawValue['prd']] ?? "Delivery"
            : isUserOrderPreferenceAvailable
                ? (["Delivery", "Intraday", "MTF"].contains(userOrderPreference['prd']) ? userOrderPreference['prd'] : "Delivery")
                : "Delivery";

    orderTypes = [
      {"type": "Delivery"},
      {"type": "Intraday"}
    ];

    if (widget.isBasket != "Basket" && widget.isBasket != "BasketEdit" && widget.isBasket != "BasketMode") {
      if (widget.scripInfo.exch == "NSE" || widget.scripInfo.exch == "BSE") {
        // if (widget.scripInfo.instname == "EQ") {
        orderTypes.add({"type": "MTF"});
        // }
        if (ref.read(userProfileProvider).userDetailModel != null && ref.read(userProfileProvider).userDetailModel!.stat == "Ok") {
          for (var element in ref.read(userProfileProvider).userDetailModel!.prarr!) {
            if (element.sPrdtAli == "MTF") {
              // orderTypes.add({"type": "MTF"});
              _isMTFEnabled = true;
            }
          }
        }
      }

      // if (widget.scripInfo.instname == "EQ") {
      //   orderTypes.add({
      //     "type": "SIP",
      //     "key": ref.read(showcaseProvide).sip,
      //     "case": "Click here to view SIP order details."
      //   });
      // }
    }
    orderTypes.add({"type": "CO - BO"});

    if (widget.isBasket != "Basket" && widget.isBasket != "BasketEdit" && widget.isBasket != "BasketMode") {
      if (widget.scripInfo.instname != "UNDIND" && widget.scripInfo.instname != "COM") {
        orderTypes.add({"type": "GTT", "key": ref.read(showcaseProvide).orderscreenBracketcase, "case": "Click here to view GTT order details."});
      }
    }
    // print("object ${res['prctyp']} ${res['prctyp'] == "SL-LMT"} ${priceType}");

    priceType = widget.orderArg.isExit && ["Limit", "Market"].contains(userOrderPreference['expos'])
        ? userOrderPreference['expos']
        : checkRawValue
            ? {"MKT": "Market", "SL-LMT": "SL Limit", "SL-MKT": "SL MKT"}[orderRawValue['prctyp']] ?? "Limit"
            : isUserOrderPreferenceAvailable
                ? (["Limit", "Market"].contains(userOrderPreference['prc'])
                    ? userOrderPreference['prc']
                    : (userOrderPreference['prc'] == "SL MKT" && (orderType != "Delivery" && orderType != "Intraday"))
                        ? 'Limit'
                        : userOrderPreference['prc'])
                : 'Limit';

    _isMarketOrder = ["Market", "SL MKT"].contains(priceType);
    _isStoplossOrder = isAdvancedOptionClicked = ["SL Limit", "SL MKT"].contains(priceType);

    priceTypes = [
      {"type": "Limit", "key": ref.read(showcaseProvide).limitprctype, "case": "Click here to set your order type to Limit."},
      {"type": "Market", "key": ref.read(showcaseProvide).marketprctype, "case": "Click here to set your order type to Market."},
      {"type": "SL Limit", "key": ref.read(showcaseProvide).sllimitprctype, "case": "Click here to set your order type to SL Limit."},
      {"type": "SL MKT", "key": ref.read(showcaseProvide).sllimktprctype, "case": "Click here to set your order type to SL MKT."},
    ];

    // bool prdcheck = widget.orderArg.prd?.isNotEmpty ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final invesType = prdcheck
          ? {"C": InvestType.delivery, "I": InvestType.intraday, "M": InvestType.carryForward, "F": InvestType.mtf}[widget.orderArg.prd] ??
              InvestType.carryForward
          : checkRawValue && widget.isBasket == "BasketEdit"
              ? {"C": InvestType.delivery, "I": InvestType.intraday, "M": InvestType.carryForward, "F": InvestType.mtf}[orderRawValue['prd']] ??
                  InvestType.delivery
              : checkRawValue
                  ? {"C": InvestType.delivery, "I": InvestType.intraday, "F": InvestType.mtf}[orderRawValue['prd']] ?? InvestType.carryForward
                  : !widget.orderArg.isExit && isUserOrderPreferenceAvailable
                      ? userOrderPreference['prd'] == "Intraday"
                          ? InvestType.intraday
                          : (userOrderPreference['prd'] == "Delivery" && widget.scripInfo.seg == "EQT")
                              ? InvestType.delivery
                              : InvestType.carryForward
                      : widget.scripInfo.seg == "EQT"
                          ? InvestType.delivery
                          : InvestType.carryForward;

      ref.read(ordInputProvider).chngInvesType(invesType, "PlcOrder");

      ref.read(ordInputProvider).chngPriceType(priceType, widget.orderArg.exchange);
      marginUpdate();
      if (orderType != "Delivery" && orderType != "Intraday" && orderType != "MTF") {
        ref.read(ordInputProvider).chngOrderType(orderType, _isCoverOrderEnabled, _isBracketOrderEnabled);
      }
    });

    setState(() {
      formattedDate = DateFormat('dd-MM-yyyy').format(now);
      // if (widget.scripInfo.exch != "NSE" && widget.scripInfo.exch != "BSE") {
      //   orderTypes.remove("SIP");
      // }
      int sfq = int.tryParse(widget.scripInfo.frzqty?.toString() ?? '1') ?? 1;

      validityType = isUserOrderPreferenceAvailable && userOrderPreference['validity'] == 'IOC'
          ? 'IOC'
          : widget.orderArg.exchange == "BSE" || widget.orderArg.exchange == "BFO"
              ? "EOS"
              : "DAY";

      _addValidityAndDisclosedQty = isUserOrderPreferenceAvailable && userOrderPreference['validity'] == 'IOC' ? true : false;
      isAdvancedOptionClicked = !isAdvancedOptionClicked ? _addValidityAndDisclosedQty : isAdvancedOptionClicked;

      
      lotSize = int.parse("${widget.scripInfo.ls ?? 0}");

      frezQty = sfq > 1
          ? widget.orderArg.exchange == "MCX"
              ? (sfq / lotSize).floor()
              : (sfq / lotSize).floor() * lotSize
          : lotSize;
      // 999999 1353220
      isBuy = widget.orderArg.transType;
      sipqtyctrl = TextEditingController(text: "1");

      qtyCtrl = TextEditingController(
          text: widget.orderArg.exchange == "MCX"
              ? widget.orderArg.isExit
                  ? widget.orderArg.lotSize!.replaceAll("-", "")
                  : "1"
              : widget.orderArg.isExit
                  ? widget.orderArg.holdQty!.replaceAll("-", "")
                  : widget.orderArg.lotSize!.replaceAll("-", ""));

      if (widget.orderArg.isExit && widget.orderArg.exchange == "MCX") {
        qtyCtrl.text = (int.parse(qtyCtrl.text) / lotSize).toInt().toString();
      } else if (!widget.orderArg.isExit && isUserOrderPreferenceAvailable) {
        qtyCtrl.text = (int.parse(qtyCtrl.text) * int.parse(userOrderPreference['qty'])).toString();
      }

      multiplayer = int.parse((widget.orderArg.exchange == "MCX"
              ? "1"
              : widget.orderArg.isExit
                  ? widget.scripInfo.ls
                  : widget.orderArg.lotSize)
          .toString());

      mktProtCtrl = TextEditingController(text: isUserOrderPreferenceAvailable ? userOrderPreference['mrkprot'] : "5");
      discQtyCtrl = TextEditingController(text: "0");

      if (ref.read(websocketProvider).socketDatas.containsKey(widget.scripInfo.token)) {
        ordPrice = "${ref.read(websocketProvider).socketDatas["${widget.scripInfo.token}"]['lp']}";

        priceCtrl.text = priceType == "Market" || priceType == "SL MKT" ? "Market" : ordPrice;
      }
    });

    final quote = ref.read(marketWatchProvider).getQuotes?.ordMsg;

    if (widget.isBasket == "Basket" || widget.isBasket == "BasketEdit" || widget.isBasket == "BasketMode" || quote == null) {
      isAvbSecu = false;
      isSecu = true;
    } else {
      quotemsg = quote;
      isAvbSecu = true;
      isSecu = false;
    }
    // addStoploss = orderType != "Delivery" && orderType != "Intraday" ? true : false;

    if (checkRawValue) {
      isBuy = orderRawValue['trantype'] == 'S' ? false : true;
      //   addStoploss = (res['prd'] == "B" || res['prd'] == "H") ? true : false;
      _addValidityAndDisclosedQty =
          orderRawValue['ret']?.toUpperCase() == 'IOC' || (orderRawValue['dscqty'] != null && int.parse(orderRawValue['dscqty']) > 0) ? true : false;
      _afterMarketOrder = orderRawValue['amo'] == "Yes" ? true : false;
      priceCtrl.text = priceType == "Market" || priceType == "SL MKT" ? "Market" : orderRawValue['prc'] ?? "0";
      ordPrice = priceType == "Market" || priceType == "SL MKT" ? ordPrice : orderRawValue['prc'] ?? "0";
      qtyCtrl.text =
          widget.scripInfo.exch == 'MCX' ? (int.parse(orderRawValue['qty'] ?? lotSize) / lotSize).toStringAsFixed(0) : orderRawValue['qty'] ?? "1";

      stopLossCtrl.text = orderRawValue['blprc'] ?? "0";
      targetCtrl.text = orderRawValue['bpprc'] ?? "0";
      trailingTicksCtrl.text = orderRawValue['trailprc'] ?? "";
      validityType = orderRawValue['ret'] ?? '';
      triggerPriceCtrl.text = orderRawValue['trgprc'] ?? "0";
      mktProtCtrl.text = (double.tryParse(orderRawValue['mkt_protection']?.toString() ?? '5')?.toInt() ?? 5).toString();

      // **FIX FOR BASKET EDIT**: Auto-expand advanced section and set states based on order data
      if (widget.isBasket == "BasketEdit") {
        // Auto-expand advanced section for stop-loss orders
        if (["SL-LMT", "SL-MKT"].contains(orderRawValue['prctyp'])) {
          _isStoplossOrder = true;
          isAdvancedOptionClicked = true;
        }

        // Set market order state
        _isMarketOrder = ["MKT", "SL-MKT"].contains(orderRawValue['prctyp']);

        // Auto-expand for IOC validity or disclosed quantity
        if (orderRawValue['ret']?.toUpperCase() == 'IOC' || (orderRawValue['dscqty'] != null && int.parse(orderRawValue['dscqty']) > 0)) {
          isAdvancedOptionClicked = true;
          _addValidityAndDisclosedQty = true;
        }

        // Auto-expand for AMO orders
        if (orderRawValue['amo'] == "Yes") {
          isAdvancedOptionClicked = true;
          _afterMarketOrder = true;
        }

        // Set bracket order states for CO-BO orders based on product code
        if (orderType == "CO - BO") {
          // Differentiate between Cover Order (H) and Bracket Order (B)
          if (orderRawValue['prd'] == 'H') {
            // Cover Order - only Cover checkbox should be ticked
            _isCoverOrderEnabled = true;
            _isBracketOrderEnabled = false;
          } else if (orderRawValue['prd'] == 'B') {
            // Bracket Order - both Cover and Bracket checkboxes should be ticked
            _isCoverOrderEnabled = true;
            _isBracketOrderEnabled = true;
          } else {
            // Default fallback (for any other product codes)
            _isCoverOrderEnabled = true;
            _isBracketOrderEnabled = true;
          }

          // Auto-expand if bracket order has stop-loss or target values
          if ((orderRawValue['blprc'] != null && orderRawValue['blprc'] != "0") ||
              (orderRawValue['bpprc'] != null && orderRawValue['bpprc'] != "0")) {
            isAdvancedOptionClicked = true;
          }
        }
      }
    }

    // Initialize circuit breaker validation flag
    _hasValidCircuitBreakerValues = widget.scripInfo.lc != null &&
        widget.scripInfo.uc != null &&
        widget.scripInfo.lc != "0.00" &&
        widget.scripInfo.uc != "0.00" &&
        widget.scripInfo.lc!.isNotEmpty &&
        widget.scripInfo.uc!.isNotEmpty;

    ref.read(orderProvider).setDOrderloader(false);
    super.initState();
    anibuildctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          anibuildctrl.reset(); // Reset animation after shake
        }
      });

    // _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
    //   CurvedAnimation(parent: anibuildctrl, curve: Curves.elasticIn),
    // );
  }

  @override
  void dispose() {
    anibuildctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Allows back navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If system handled back, do nothing

        ref.read(ordInputProvider).clearTextField();
        await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: true);

        // If coming from chart, restore the chart overlay
        if (widget.fromChart) {
          final chartState = ref.read(chartProvider);
          if (chartState.chartArgs != null) {
            ref.read(chartProvider.notifier).showChart(chartState.chartArgs!, previousRoute: null);
          }
        }
        Navigator.pop(context);
      },
      child: Consumer(
        builder: (context, WidgetRef ref, _) {
          final orderProvide = ref.watch(orderProvider);
          final orderInput = ref.watch(ordInputProvider);
          final internet = ref.watch(networkStateProvider);
          final theme = ref.read(themeProvider);
          final trancation = ref.watch(transcationProvider);
          final clientFundDetail = ref.watch(fundProvider).fundDetailModel;

          final sip = ref.watch(siprovider);
          int frezQtyOrderSliceMaxLimit = ref.read(orderProvider).frezQtyOrderSliceMaxLimit;

          return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                      leadingWidth: 41,
                      centerTitle: false,
                      titleSpacing: 0,
                      leading: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: Semantics(
                          identifier: "Back button",
                          child: IconButton(
                            // customBorder: const CircleBorder(),
                            splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                            highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                            onPressed: () {
                              ref.read(ordInputProvider).clearTextField();
                          
                              // If coming from chart, restore the chart overlay
                              if (widget.fromChart) {
                                final chartState = ref.read(chartProvider);
                                if (chartState.chartArgs != null) {
                                  ref.read(chartProvider.notifier).showChart(chartState.chartArgs!, previousRoute: null);
                                }
                              }
                          
                              Navigator.pop(context);
                            },
                            icon: Container(
                              width: 44, // Increased touch area
                              height: 44,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.arrow_back_ios_outlined,
                                size: 18,
                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ),
                      ),
                      elevation: .4,
                      title: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Column(children: [
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            TextWidget.titleText(
                              text: "${widget.scripInfo.symbol!.replaceAll("-EQ", "")} ",
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                              maxLines: 1,
                              textOverflow: TextOverflow.ellipsis,
                              fw: 0,
                            ),

                            // Text(
                            //     "${widget.scripInfo.symbol!.replaceAll("-EQ", "")} ",
                            //     style: textStyle(
                            //         theme.isDarkMode
                            //             ? colors.colorWhite
                            //             : colors.colorBlack,
                            //         14,
                            //         FontWeight.w400),
                            //     overflow: TextOverflow.ellipsis,
                            //     maxLines: 1),
                            if (widget.scripInfo.expDate!.isNotEmpty)
                              TextWidget.titleText(
                                text: " ${widget.scripInfo.expDate} ",
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis,
                                fw: 0,
                              ),

                            // Text(" ${widget.scripInfo.expDate} ",
                            //     style: textStyle(
                            //         theme.isDarkMode
                            //             ? colors.colorWhite
                            //             : colors.colorBlack,
                            //         14,
                            //         FontWeight.w400)),
                            if (widget.scripInfo.option!.isNotEmpty)
                              TextWidget.titleText(
                                text: widget.scripInfo.option!,
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis,
                                fw: 0,
                              ),

                            // Text(widget.scripInfo.option!,
                            //     style: textStyle(
                            //         theme.isDarkMode
                            //             ? colors.colorWhite
                            //             : colors.colorBlack,
                            //         14,
                            //         FontWeight.w400),
                            //     overflow: TextOverflow.ellipsis,
                            //     maxLines: 1),
                            // CustomExchBadge(
                            //     exch: " ${widget.scripInfo.exch}"),

                            TextWidget.titleText(
                              fw: 0,
                              text: " ${widget.scripInfo.exch}",
                              textOverflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                              theme: false,
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            OrderScreenHeader(headerData: widget.orderArg),
                            // if (orderType == "Regular" ||
                            //     orderType == "Cover" ||
                            //     orderType == "Bracket" ||
                            //     orderType == "GTT") ...[
                            //   Row(children: [
                            //     InkWell(
                            //         onTap: () {
                            //           setState(() {
                            //             isBuy = true;
                            //           });
                            //         },
                            //         child:
                            //             SvgPicture.asset(assets.buyIcon)),
                            //     const SizedBox(width: 6),
                            //     CustomSwitch(
                            //         onChanged: (bool value) {
                            //           setState(() {
                            //             isBuy = value;
                            //           });
                            //           marginUpdate();
                            //         },
                            //         value: isBuy!),
                            //     const SizedBox(width: 6),
                            //     InkWell(
                            //         onTap: () {
                            //           setState(() {
                            //             isBuy = false;
                            //           });
                            //         },
                            //         child:
                            //             SvgPicture.asset(assets.sellIcon))
                            //   ])
                            // ]
                          ])
                        ]),
                      ),
                      // Tab section starts here
                      bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(50), // widget.orderArg.exchange == "NCOM" ? 10 :
                          child: Column(children: [
                            // if (widget.orderArg.exchange != "NCOM") ...[
                            Container(
                                height: 46,
                                // decoration: BoxDecoration(
                                //     border: (Border(
                                //         top: BorderSide(
                                //             color: theme.isDarkMode
                                //                 ? colors.darkColorDivider
                                //                 : colors.colorDivider)))),
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            orderType = orderTypes[index]['type'];
                                            updatePriceType();
                                            onOrderTypeChangeClearValues();
                                            // if (priceType == "SL MKT") {
                                            //   priceType = "Limit";
                                            // }

                                            // if (index == 2) {
                                            //   // index == 1
                                            //   addStoploss = true;
                                            // } else {
                                            //   addStoploss = false;
                                            // }
                                            if (orderType == "SIP") {
                                              sip.startdatemethod("0");
                                              sip.numberofSips.clear();
                                            }
                                          });

                                          if (orderTypes[index]['type'] == "CO - BO") {
                                            orderInput.chngOrderType(orderTypes[index]['type'], _isCoverOrderEnabled, _isBracketOrderEnabled);
                                          } else if (orderTypes[index]['type'] == "Intraday") {
                                            orderInput.chngInvesType(InvestType.intraday, "PlcOrder");
                                          } else if (orderTypes[index]['type'] == "MTF") {
                                            orderInput.chngInvesType(InvestType.mtf, "PlcOrder");
                                          } else {
                                            // this condition works both for PlcOrder and GTT
                                            orderInput.chngInvesType(
                                                widget.scripInfo.seg == "EQT" ? InvestType.delivery : InvestType.carryForward, "PlcOrder");
                                            orderInput.chngInvesType(
                                                widget.scripInfo.seg == "EQT" ? InvestType.delivery : InvestType.carryForward, "OCO");
                                          }
                                          if (orderType != "GTT") {
                                            isOco = false;
                                            marginUpdate();
                                          } else {
                                            // ref.read(ordInputProvider)
                                            //     .chngInvesType(
                                            //         widget.scripInfo.seg == "EQT"
                                            //             ? InvestType.delivery
                                            //             : InvestType.carryForward,
                                            //         "GTT");
                                            if (orderInput.prcType != "MKT") {
                                            ref
                                                .read(ordInputProvider)
                                                .updatePrcCtrl("${widget.orderArg.ltp}", widget.orderArg.lotSize!.replaceAll("-", ""));
                                            ref.read(ordInputProvider).chngGTTPriceType("Limit");
}
                                            ref.read(ordInputProvider).disableCondGTT(false);
                                          }
                                          if (priceType == "Market" || priceType == "SL MKT") {
                                            priceCtrl.text = "Market";
                                          } else {
                                            priceCtrl.text = "${widget.orderArg.ltp}";
                                            ordPrice = priceCtrl.text;
                                          }
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            decoration: BoxDecoration(
                                                border: orderType == orderTypes[index]['type']
                                                    ? Border(
                                                        bottom: BorderSide(
                                                            color: theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight, width: 2))
                                                    : null),
                                            child: TextWidget.subText(
                                                text: orderTypes[index]['type'],
                                                color: orderType == orderTypes[index]['type']
                                                    ? theme.isDarkMode
                                                        ? colors.secondaryDark
                                                        : colors.secondaryLight
                                                    : theme.isDarkMode
                                                        ? colors.textSecondaryDark
                                                        : colors.textSecondaryLight,
                                                textOverflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                theme: theme.isDarkMode,
                                                fw: orderType == orderTypes[index]['type'] ? 2 : 0)

                                            // Text(
                                            //     orderTypes[index]['type'],
                                            //     style: textStyle(
                                            //         orderType == orderTypes[index]['type'] &&
                                            //                 theme.isDarkMode
                                            //             ? colors.colorWhite
                                            //             : orderType ==
                                            //                     orderTypes[index]
                                            //                         ['type']
                                            //                 ? colors
                                            //                     .colorBlue
                                            //                 : const Color(
                                            //                     0xff666666),
                                            //         14,
                                            //         orderType ==
                                            //                 orderTypes[index]['type']
                                            //             ? FontWeight.w600
                                            //             : FontWeight.w500),
                                            //             ),
                                            ),
                                      );
                                    },
                                    itemCount: orderTypes.length))
                            // ]
                          ]))),
                  body: SafeArea(
                    child: Stack(children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: ((priceType == "Market" || priceType == "SL MKT") && isAvbSecu) ? 120 : 90),
                        // reverse: true,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(height: 24),
                          if (orderType == "SIP") ...[
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  child: Row(children: [
                                    Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      headerTitleText("Frequency", theme),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                          height: 44,
                                          child: DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                  dropdownStyleData: DropdownStyleData(
                                                      maxHeight: 240,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: !theme.isDarkMode ? colors.colorWhite : const Color.fromARGB(255, 18, 18, 18))),
                                                  buttonStyleData: ButtonStyleData(
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                                          borderRadius: const BorderRadius.all(Radius.circular(32)))),
                                                  isExpanded: true,
                                                  style: theme.isDarkMode
                                                      ? textStyles.textFieldLabelStyle.copyWith(color: colors.colorWhite)
                                                      : textStyles.textFieldLabelStyle,
                                                  items: sipDropdown.map((item) {
                                                    return DropdownMenuItem(
                                                      value: item,
                                                      child: Text(item.toString()),
                                                    );
                                                  }).toList(),
                                                  value: selectedValue,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      selectedValue = newValue!.toString();

                                                      FocusScope.of(context).unfocus();
                                                    });
                                                  })))
                                    ])),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      headerTitleText("Qty", theme),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        height: 44,
                                        child: TextFormField(
                                          textAlign: TextAlign.center,
                                          controller: sipqtyctrl,
                                          style: theme.isDarkMode
                                              ? textStyles.textFieldLabelStyle.copyWith(color: colors.colorWhite)
                                              : textStyles.textFieldLabelStyle,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              prefixIcon: Theme(
                                                  data: ThemeData(splashColor: Colors.transparent, splashFactory: NoSplash.splashFactory),
                                                  child: InkWell(
                                                      // onLongPress: () {
                                                      //   setState(
                                                      //       () {
                                                      //     if (sipqtyctrl
                                                      //         .text
                                                      //         .isNotEmpty) {
                                                      //       if (int.parse(sipqtyctrl.text) >
                                                      //           multiplayer) {
                                                      //         sipqtyctrl.text = (int.parse(sipqtyctrl.text) - multiplayer).toString();
                                                      //         double inputValue = double.tryParse(sipqtyctrl.text) ?? 0.00;
                                                      //         double ltpsip = double.parse("${widget.orderArg.ltp}");
                                                      //         resultsip = inputValue * ltpsip;
                                                      //       }
                                                      //     } else {
                                                      //       sipqtyctrl.text =
                                                      //           "$multiplayer";
                                                      //     }
                                                      //   });
                                                      // },
                                                      onTap: () {
                                                        setState(() {
                                                          // if () {
                                                          int sipQty = int.tryParse(sipqtyctrl.text) ?? multiplayer;
                                                          //  if (sipQty ==
                                                          //   multiplayer) {
                                                          // sipqtyctrl.text = (sipQty).toString();
                                                          //   }
                                                          if (sipqtyctrl.text.isNotEmpty && sipQty > multiplayer) {
                                                            sipqtyctrl.text = (sipQty - multiplayer).toString();
                                                            double ltpsip = double.parse("${widget.orderArg.ltp}");
                                                            int inputValue = int.tryParse(sipqtyctrl.text) ?? 0;
                                                            resultsip = inputValue * ltpsip;
                                                            // }
                                                          } else {
                                                            sipqtyctrl.text = "$multiplayer";
                                                          }
                                                        });
                                                      },
                                                      child: SvgPicture.asset(theme.isDarkMode ? assets.darkCMinus : assets.minusIcon,
                                                          fit: BoxFit.scaleDown))),
                                              suffixIcon: Theme(
                                                  data: ThemeData(splashColor: Colors.transparent, splashFactory: NoSplash.splashFactory),
                                                  child: InkWell(
                                                      // onLongPress: () {
                                                      //   setState(
                                                      //       () {
                                                      //     if (sipqtyctrl
                                                      //         .text
                                                      //         .isNotEmpty) {
                                                      //       sipqtyctrl.text =
                                                      //           (int.parse(sipqtyctrl.text) + multiplayer).toString();
                                                      //       double
                                                      //           inputValue =
                                                      //           double.tryParse(sipqtyctrl.text) ?? 0.00;
                                                      //       double
                                                      //           ltpsip =
                                                      //           double.parse("${widget.orderArg.ltp}");
                                                      //       resultsip =
                                                      //           inputValue * ltpsip;
                                                      //     } else {
                                                      //       sipqtyctrl.text =
                                                      //           "$multiplayer";
                                                      //     }
                                                      //   });
                                                      // },
                                                      onTap: () {
                                                        setState(() {
                                                          int sipQty = int.tryParse(sipqtyctrl.text) ?? multiplayer;
                                                          bool hasNoFreezeLimit = frezQty <= lotSize;
                                                          bool withinLimit = hasNoFreezeLimit || sipQty < frezQtyOrderSliceMaxLimit * frezQty;

                                                          if (sipqtyctrl.text.isNotEmpty && withinLimit) {
                                                            sipqtyctrl.text = (sipQty + multiplayer).toString();
                                                            double ltpsip = double.parse("${widget.orderArg.ltp}");
                                                            int inputValue = int.tryParse(sipqtyctrl.text) ?? 0;
                                                            resultsip = inputValue * ltpsip;
                                                          } else if (!hasNoFreezeLimit) {
                                                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                            warningMessage(context,
                                                                "Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit * frezQty}");
                                                            // sipqtyctrl.text =
                                                            //     "$multiplayer";
                                                          }
                                                        });
                                                      },
                                                      child: SvgPicture.asset(theme.isDarkMode ? assets.darkAdd : assets.addIcon,
                                                          fit: BoxFit.scaleDown))),
                                              fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30)),
                                              disabledBorder: InputBorder.none,
                                              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30)),
                                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30))),
                                          onTap: () {},
                                          onChanged: (value) {
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            if (value.isEmpty || value == "0") {
                                              warningMessage(context, "The minimum quantity of this stock is one.");
                                            } else {
                                              setState(() {
                                                int inputValue = int.tryParse(value) ?? 0;

                                                double ltpsip = double.parse("${widget.orderArg.ltp}");
                                                resultsip = inputValue * ltpsip;
                                                sipLtpctrl.text = resultsip.toStringAsFixed(2);
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ]))
                                  ])),
                              const SizedBox(height: 10),
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  child: Row(children: [
                                    Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      headerTitleText("Start Date", theme),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                          height: 44,
                                          child: TextFormField(
                                              controller: sip.datefield,
                                              style: theme.isDarkMode
                                                  ? textStyles.textFieldLabelStyle.copyWith(color: colors.colorWhite)
                                                  : textStyles.textFieldLabelStyle,
                                              decoration: InputDecoration(
                                                  fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                                  filled: true,
                                                  enabledBorder:
                                                      OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30)),
                                                  disabledBorder: InputBorder.none,
                                                  focusedBorder:
                                                      OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30)),
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30))),
                                              readOnly: true,
                                              onTap: () {
                                                sip.providedate(context, theme, "2");
                                              },
                                              onChanged: (value) {
                                                sip.providedate(context, theme, "2");
                                              }))
                                    ])),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      headerTitleText("Number of SIPs", theme),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                          height: 44,
                                          child: TextFormField(
                                              keyboardType: TextInputType.number,
                                              controller: sip.numberofSips,
                                              style: theme.isDarkMode
                                                  ? textStyles.textFieldLabelStyle.copyWith(color: colors.colorWhite)
                                                  : textStyles.textFieldLabelStyle,
                                              decoration: InputDecoration(
                                                  fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                                  filled: true,
                                                  enabledBorder:
                                                      OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30)),
                                                  disabledBorder: InputBorder.none,
                                                  focusedBorder:
                                                      OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30)),
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30))),
                                              onChanged: (value) {
                                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                int inputValue = int.tryParse(value) ?? 0;
                                                if (value.isEmpty || inputValue < 1) {
                                                  warningMessage(context, "The minimum number of this SIP is one.");
                                                }
                                                //  if (value.isEmpty) {
                                                //   ScaffoldMessenger
                                                //           .of(
                                                //               context)
                                                //       .showSnackBar(
                                                //           warningMessage(
                                                //               context,
                                                //               "The minimum number of this SIP is one."));
                                                // }
                                              }))
                                    ]))
                                  ])),
                              const SizedBox(height: 40),
                              Center(
                                  child: Column(children: [
                                Text(
                                  "₹${resultsip == 0.0 ? widget.orderArg.ltp : resultsip.toStringAsFixed(2)}",
                                  style: textStyle(const Color(0xff43A833), 20, FontWeight.w600),
                                ),
                                Text("Installment Amount",
                                    style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 15, FontWeight.w600))
                              ]))
                            ])
                          ],
                          if (orderType == "GTT") ...[
                            // GttCondition(
                            //     isOco: false,
                            //     isGtt: isGtt,
                            //     isModify: widget.orderArg.isModify),

                            // const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  headerTitleText(isOco ? "Target Trigger Price" : "Trigger Price", theme),
                                ]),
                                const SizedBox(height: 8),
                                SizedBox(
                                    height: 45,
                                    child: Semantics(
                                      identifier: 'trigger_price_input',
                                      child: CustomTextFormField(
                                          inputFormate: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                                          fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                          onChanged: (value) {
                                            double inputPrice = double.tryParse(value) ?? 0;

                                            if (value.isNotEmpty && inputPrice > 0) {
                                              final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                                              if (!regex.hasMatch(value)) {
                                                orderInput.val1Ctrl.text = value.substring(0, value.length - 1);
                                                orderInput.val1Ctrl.selection = TextSelection.collapsed(offset: orderInput.val1Ctrl.text.length);
                                              }
                                            }
                                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                            if (value.isEmpty) {
                                              warningMessage(context, "Target trigger price cannot be empty");
                                            } else if (inputPrice <= 0) {
                                              warningMessage(context, "Target trigger price cannot be 0");
                                            }
                                          },
                                          hintText: "${widget.orderArg.ltp}",
                                          hintStyle: TextWidget.textStyle(
                                            fontSize: 14,
                                            theme: theme.isDarkMode,
                                            color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                            fw: 0,
                                          ),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          style: TextWidget.textStyle(
                                            fontSize: 16,
                                            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                            theme: theme.isDarkMode,
                                            fw: 0,
                                          ),
                                          textCtrl: orderInput.val1Ctrl,
                                          textAlign: TextAlign.start),
                                    )),
                              ]),
                            ),

                            // const SizedBox(height: 8),
                            // // InvesTypeWidget(
                            // //     scripInfo: widget.scripInfo, ordType: "GTT"),
                            // const SizedBox(height: 8),
                            // Padding(
                            //     padding: const EdgeInsets.only(left: 16),
                            //     child: headerTitleText("Price type", theme)),
                            // const SizedBox(height: 10),
                            // PriceTypeBtn(
                            //     isOco: false,
                            //     isGtt: isGtt,
                            //     ltp: "${widget.orderArg.ltp}"),
                            // const SizedBox(height: 3),
                            // Divider(
                            //     color: theme.isDarkMode
                            //         ? colors.darkColorDivider
                            //         : colors.colorDivider),

                            const SizedBox(height: 16),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    headerTitleText("Qty", theme),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                        height: 45,
                                        child: Semantics(
                                          identifier: "GTT Qty Input",
                                          child: CustomTextFormField(
                                              fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                              hintText: "0", //orderInput.qtyCtrl.text,
                                              hintStyle: TextWidget.textStyle(
                                                fontSize: 14,
                                                theme: theme.isDarkMode,
                                                color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                                fw: 0,
                                              ),
                                              inputFormate: [FilteringTextInputFormatter.digitsOnly],
                                              keyboardType: TextInputType.number,
                                              style: TextWidget.textStyle(
                                                fontSize: 16,
                                                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                theme: theme.isDarkMode,
                                                fw: 0,
                                              ),
                                              // prefixIcon: InkWell(
                                              //   onTap: () {
                                              //     setState(() {
                                              //       String input =
                                              //           orderInput
                                              //               .qtyCtrl.text;
                                          
                                              //       int currentQty =
                                              //           int.tryParse(
                                              //                   input) ??
                                              //               0;
                                          
                                              //       int adjustedQty =
                                              //           ((currentQty /
                                              //                       multiplayer)
                                              //                   .floor()) *
                                              //               multiplayer;
                                          
                                              //       if (currentQty !=
                                              //           adjustedQty) {
                                              //         orderInput.qtyCtrl
                                              //                 .text =
                                              //             adjustedQty
                                              //                 .toString();
                                              //       } else if (input
                                              //               .isNotEmpty &&
                                              //           currentQty >
                                              //               multiplayer) {
                                              //         orderInput.qtyCtrl
                                              //             .text = (int.parse(orderInput
                                              //                     .qtyCtrl
                                              //                     .text) -
                                              //                 multiplayer)
                                              //             .toString();
                                              //       } else {
                                              //         orderInput.qtyCtrl
                                              //                 .text =
                                              //             "$multiplayer";
                                              //       }
                                              //     });
                                              //   },
                                              //   child: SvgPicture.asset(
                                              //       theme.isDarkMode
                                              //           ? assets
                                              //               .darkCMinus
                                              //           : assets
                                              //               .minusIcon,
                                              //       fit:
                                              //           BoxFit.scaleDown),
                                              // ),
                                              // suffixIcon: InkWell(
                                              //           onTap: () {},
                                              //           child: SvgPicture.asset(
                                              //               assets.switchIcon,
                                              //               fit: BoxFit.scaleDown),
                                              //         ),
                                          
                                              // suffixIcon: InkWell(
                                              //   onTap: () {
                                              //     setState(() {
                                              //       String input =
                                              //           orderInput
                                              //               .qtyCtrl.text;
                                          
                                              //       int currentQty =
                                              //           int.tryParse(
                                              //                   input) ??
                                              //               0;
                                          
                                              //       int adjustedQty =
                                              //           ((currentQty /
                                              //                       multiplayer)
                                              //                   .round()) *
                                              //               multiplayer;
                                          
                                              //       if (currentQty !=
                                              //           adjustedQty) {
                                              //         orderInput.qtyCtrl
                                              //                 .text =
                                              //             adjustedQty
                                              //                 .toString();
                                              //       } else if (input
                                              //               .isNotEmpty &&
                                              //           currentQty <
                                              //               ((frezQtyOrderSliceMaxLimit *
                                              //                           frezQty) ==
                                              //                       frezQtyOrderSliceMaxLimit
                                              //                   ? 999999
                                              //                   : frezQtyOrderSliceMaxLimit *
                                              //                       frezQty)) {
                                              //         orderInput.qtyCtrl
                                              //                 .text =
                                              //             (currentQty +
                                              //                     multiplayer)
                                              //                 .toString();
                                              //       } else {
                                              //         ScaffoldMessenger
                                              //                 .of(context)
                                              //             .removeCurrentSnackBar();
                                              //         ScaffoldMessenger
                                              //                 .of(context)
                                              //             .showSnackBar(
                                              //                 warningMessage(
                                              //                     context,
                                              //                     "Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit * frezQty}"));
                                              //         // orderInput.
                                              //         //         qtyCtrl
                                              //         //         .text =
                                              //         //      multiplayer
                                              //         //       .toString();
                                              //       }
                                              //     });
                                              //   },
                                              //   child: SvgPicture.asset(
                                              //       theme.isDarkMode
                                              //           ? assets.darkAdd
                                              //           : assets.addIcon,
                                              //       fit:
                                              //           BoxFit.scaleDown),
                                              // ),
                                              textCtrl: orderInput.qtyCtrl,
                                              textAlign: TextAlign.start,
                                              onChanged: (value) {
                                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                if (value.isEmpty || value == "0") {
                                                  warningMessage(context, "Quantity cannot be ${value == "0" ? '0' : 'empty'}");
                                                } else {
                                                  String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                          
                                                  int number = int.tryParse(newValue) ?? 0;
                                                  if (number > (frezQty == lotSize ? 999999 : frezQtyOrderSliceMaxLimit * frezQty)) {
                                                    orderInput.qtyCtrl.text = orderInput.qtyCtrl.text;
                                                    warningMessage(context,
                                                        "Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit * frezQty}");
                                                  }
                                          
                                                  if (newValue != value) {
                                                    orderInput.qtyCtrl.text = newValue;
                                          
                                                    orderInput.qtyCtrl.selection = TextSelection.fromPosition(
                                                      TextPosition(offset: newValue.length),
                                                    );
                                                  }
                                                }
                                              }),
                                        ))
                                  ])),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment
                                        //         .spaceBetween,
                                        children: [
                                          headerTitleText("Price", theme),
                                          const SizedBox(width: 4),
                                          TextWidget.subText(
                                            text: "${orderInput.actPrcType}",
                                            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                            theme: theme.isDarkMode,
                                            fw: 1,
                                          ),
                                        ]),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                        height: 45,
                                        child: Semantics(
                                          identifier: "GTT Price Input",
                                          child: CustomTextFormField(
                                              inputFormate: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                                              fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                              onChanged: (value) {
                                                double inputPrice = double.tryParse(value) ?? 0;
                                                if (value.isNotEmpty && inputPrice > 0) {
                                                  final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                                                  if (!regex.hasMatch(value)) {
                                                    orderInput.priceCtrl.text = value.substring(0, value.length - 1);
                                                    orderInput.priceCtrl.selection = TextSelection.collapsed(
                                                      offset: orderInput.priceCtrl.text.length,
                                                    );
                                                  }
                                                }
                                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                if (value.isEmpty) {
                                                  warningMessage(context, "Price cannot be empty");
                                                } else if (inputPrice <= 0) {
                                                  warningMessage(context, "Price cannot be 0");
                                                } else {
                                                  setState(() {
                                                    ordPrice = value;
                                                  });
                                                }
                                              },
                                              hintText: "${widget.orderArg.ltp}",
                                              hintStyle: TextWidget.textStyle(
                                                fontSize: 14,
                                                theme: theme.isDarkMode,
                                                color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                                fw: 0,
                                              ),
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              style: TextWidget.textStyle(
                                                fontSize: 16,
                                                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                theme: theme.isDarkMode,
                                                fw: 0,
                                              ),
                                              isReadable: orderInput.actPrcType == "Limit" || orderInput.actPrcType == "SL Limit" ? false : true,
                                              // prefixIcon: Container(
                                              //     margin:
                                              //         const EdgeInsets.all(
                                              //             12),
                                              //     decoration: BoxDecoration(
                                              //         borderRadius:
                                              //             BorderRadius.circular(20),
                                              //         color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                                              //     child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, orderInput.actPrcType == "Limit" || orderInput.actPrcType == "SL Limit" ? assets.ruppeIcon : assets.lock, fit: BoxFit.scaleDown)),
                                              suffixIcon: Material(
                                                color: Colors.transparent,
                                                shape: const CircleBorder(),
                                                child: Semantics(
                                                  identifier: "GTT Price Type button",
                                                  child: InkWell(
                                                    customBorder: const CircleBorder(),
                                                    splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                                                    highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                                                    onTap: () {
                                                      setState(() {
                                                        orderInput.setGTTPriceTypeOrderIsMarket(
                                                            !orderInput.GTTPriceTypeOrderIsMarket);
                                                            final newType = orderInput.GTTPriceTypeOrderIsMarket ? "Market" : "Limit";
                                                        orderInput
                                                            .chngGTTPriceType(newType);
                                                        if (orderInput.actPrcType == "Market" ||
                                                            orderInput.actPrcType == "SL MKT") {
                                                          orderInput.priceCtrl.text = "Market";
                                                        } else {
                                                          orderInput.priceCtrl.text = "${widget.orderArg.ltp}";
                                                        }
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(12.0),
                                                      child: SvgPicture.asset(assets.switchIcon, fit: BoxFit.contain),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              textCtrl: orderInput.priceCtrl,
                                              textAlign: TextAlign.start),
                                        )),
                                  ]))
                                ])),
                            const SizedBox(height: 16),
                            // if(orderInput.actPrcType == "Market" || orderInput.actPrcType == "SL MKT") ...[
                            //     marketProtectionDisclaimer(theme, context, widget.scripInfo, mktProtCtrl.text),
                            //   const SizedBox(height: 16),
                            // ],
                            // Divider(
                            //     color: theme.isDarkMode
                            //         ? colors.darkColorDivider
                            //         : colors.colorDivider),
                            // if (orderInput.actPrcType == "SL Limit" || orderInput.actPrcType == "SL MKT") ...[
                            //   triggerOption(theme, context, widget.scripInfo),
                            //   Divider(
                            //       color: theme.isDarkMode
                            //           ? colors.darkColorDivider
                            //           : colors.colorDivider)
                            // ],
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //   Expanded(
                                  //       child: Column(
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.start,
                                  //           children: [
                                  //         headerTitleText(
                                  //             "Validity", theme),
                                  //         const SizedBox(height: 7),
                                  //         SizedBox(
                                  //             height: 38,
                                  //             child: ListView.separated(
                                  //                 scrollDirection:
                                  //                     Axis.horizontal,
                                  //                 itemBuilder:
                                  //                     (context, index) {
                                  //                   return ElevatedButton(
                                  //                       onPressed: () {
                                  //                         setState(() {
                                  //                           validityTypeGTT =
                                  //                               validityTypesGTT[
                                  //                                   index];
                                  //                         });
                                  //                       },
                                  //                       style: ElevatedButton
                                  //                           .styleFrom(
                                  //                               elevation:
                                  //                                   0,
                                  //                               padding: const EdgeInsets
                                  //                                   .symmetric(
                                  //                                   horizontal:
                                  //                                       12,
                                  //                                   vertical:
                                  //                                       0),
                                  //                               backgroundColor: !theme
                                  //                                       .isDarkMode
                                  //                                   ? validityTypeGTT != validityTypesGTT[index]
                                  //                                       ? const Color(0xffF1F3F8)
                                  //                                       : colors.colorBlack
                                  //                                   : validityTypeGTT != validityTypesGTT[index]
                                  //                                       ? colors.darkGrey
                                  //                                       : colors.colorbluegrey,
                                  //                               shape: const StadiumBorder()),
                                  //                       child: Text(validityTypesGTT[index],
                                  //                           style: textStyle(
                                  //                               !theme.isDarkMode
                                  //                                   ? validityTypeGTT != validityTypesGTT[index]
                                  //                                       ? const Color(0xff666666)
                                  //                                       : colors.colorWhite
                                  //                                   : validityTypeGTT != validityTypesGTT[index]
                                  //                                       ? const Color(0xff666666)
                                  //                                       : colors.colorBlack,
                                  //                               14,
                                  //                               validityTypeGTT == validityTypesGTT[index] ? FontWeight.w600 : FontWeight.w500)));
                                  //                 },
                                  //                 separatorBuilder:
                                  //                     (context, index) {
                                  //                   return const SizedBox(
                                  //                       width: 8);
                                  //                 },
                                  //                 itemCount:
                                  //                     validityTypesGTT
                                  //                         .length))
                                  //       ],
                                  //       ),
                                  //       ),
                                  //   const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      TextWidget.subText(
                                        text: "OCO",
                                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                        theme: theme.isDarkMode,
                                        fw: 0,
                                      ),
                                       Semantics(
                                        identifier: 'GTT OCO button',
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                            if (isBuy! && widget.scripInfo.seg == "EQT") {
                                              warningMessage(context, "OCO Order cannot be placed for Buy order");
                                              return;
                                            }
                                        
                                            setState(() {
                                              isOco = !isOco;
                                              orderInput.disableCondGTT(isOco);
                                              //  orderInput.setGTTPriceTypeOrderIsMarket(isOco);
                                            });
                                            if(orderInput.ocoPrcType != "MKT"){
                                            orderInput.chngOCOPriceType("Limit");
                                        
                                            ref.read(ordInputProvider).updateOcoPrcQtyCtrl(
                                                  "${widget.orderArg.ltp}",
                                                  widget.orderArg.lotSize!.replaceAll("-", ""),
                                                );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 250),
                                              curve: Curves.easeOut,
                                              width: 40,
                                              height: 22,
                                              padding: const EdgeInsets.symmetric(horizontal: 3),
                                              decoration: BoxDecoration(
                                                color: (isBuy! && widget.scripInfo.seg == "EQT")
                                                    ? (theme.isDarkMode ? Colors.grey[800] : Colors.grey[300]) // Disabled state
                                                    : isOco
                                                        ? colors.colorBlue.withOpacity(0.25)
                                                        : (theme.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: AnimatedAlign(
                                                duration: const Duration(milliseconds: 250),
                                                curve: Curves.easeOut,
                                                alignment: isOco ? Alignment.centerRight : Alignment.centerLeft,
                                                child: Container(
                                                  width: 16,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    color: (isBuy! && widget.scripInfo.seg == "EQT")
                                                        ? (theme.isDarkMode ? Colors.grey[600] : Colors.grey[400]) // Disabled knob
                                                        : isOco
                                                            ? colors.colorBlue
                                                            : Colors.grey[500],
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.25),
                                                        blurRadius: 3,
                                                        offset: const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isOco) ...[
                              // Divider(
                              //     color: theme.isDarkMode
                              //         ? colors.darkColorDivider
                              //         : colors.colorDivider,
                              //     thickness: .4),
                              // const SizedBox(height: 16),
                              // GttCondition(
                              //     isOco: isOco,
                              //     isGtt: isGtt,
                              //     isModify: widget.orderArg.isModify),
                              // const SizedBox(height: 8),
                              // InvesTypeWidget(
                              //     scripInfo: widget.scripInfo, ordType: "OCO"),
                              // const SizedBox(height: 8),
                              // Padding(
                              //     padding: const EdgeInsets.only(left: 16),
                              //     child: headerTitleText("Price type", theme)),
                              // const SizedBox(height: 10),
                              // PriceTypeBtn(
                              //     isOco: isOco,
                              //     isGtt: isGtt,
                              //     ltp: "${widget.orderArg.ltp}"),
                              // Divider(
                              //     color: theme.isDarkMode
                              //         ? colors.darkColorDivider
                              //         : colors.colorDivider),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    headerTitleText(isOco ? "Stoploss Trigger Price" : "Trigger Price", theme),
                                  ]),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                      height: 45,
                                      child: Semantics(
                                        identifier: 'stoploss_trigger_price',
                                        child: CustomTextFormField(
                                            inputFormate: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                                            fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                            onChanged: (value) {
                                              double inputPrice = double.tryParse(value) ?? 0;

                                              if (value.isNotEmpty && inputPrice > 0) {
                                                final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                                                if (!regex.hasMatch(value)) {
                                                  orderInput.val2Ctrl.text = value.substring(0, value.length - 1);
                                                  orderInput.val2Ctrl.selection = TextSelection.collapsed(offset: orderInput.val2Ctrl.text.length);
                                                }
                                              }
                                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                              if (value.isEmpty) {
                                                warningMessage(context, "Stoploss trigger price cannot be empty");
                                              } else if (inputPrice <= 0) {
                                                warningMessage(context, "Stoploss trigger price cannot be 0");
                                              }
                                            },
                                            hintText: "${widget.orderArg.ltp}",
                                            hintStyle: TextWidget.textStyle(
                                              fontSize: 14,
                                              theme: theme.isDarkMode,
                                              color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                              fw: 0,
                                            ),
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            style: TextWidget.textStyle(
                                              fontSize: 16,
                                              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                            ),
                                            textCtrl: orderInput.val2Ctrl,
                                            textAlign: TextAlign.start),
                                      )),
                                ]),
                              ),

                              const SizedBox(height: 16),
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      headerTitleText("Qty", theme),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                          height: 45,
                                          child: Semantics(
                                            identifier: 'oco_qty_input',
                                            child: CustomTextFormField(
                                                fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                                hintText: "0", //orderInput.ocoQtyCtrl.text,
                                                hintStyle: TextWidget.textStyle(
                                                  fontSize: 14,
                                                  theme: theme.isDarkMode,
                                                  color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                                  fw: 0,
                                                ),
                                                inputFormate: [FilteringTextInputFormatter.digitsOnly],
                                                keyboardType: TextInputType.number,
                                                style: TextWidget.textStyle(
                                                  fontSize: 16,
                                                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                  theme: theme.isDarkMode,
                                                  fw: 0,
                                                ),
                                                // prefixIcon: InkWell(
                                                //   onTap: () {
                                                //     setState(() {
                                                //       String input =
                                                //           orderInput
                                                //               .ocoQtyCtrl
                                                //               .text;
                                                //       int currentQty =
                                                //           int.tryParse(
                                                //                   input) ??
                                                //               0;
                                                //       int adjustedQty =
                                                //           ((currentQty /
                                                //                       multiplayer)
                                                //                   .floor()) *
                                                //               multiplayer;

                                                //       if (currentQty !=
                                                //           adjustedQty) {
                                                //         orderInput
                                                //                 .ocoQtyCtrl
                                                //                 .text =
                                                //             adjustedQty
                                                //                 .toString();
                                                //       } else if (input
                                                //               .isNotEmpty &&
                                                //           currentQty >
                                                //               multiplayer) {
                                                //         orderInput
                                                //             .ocoQtyCtrl
                                                //             .text = (currentQty -
                                                //                 multiplayer)
                                                //             .toString();
                                                //       } else {
                                                //         orderInput
                                                //                 .ocoQtyCtrl
                                                //                 .text =
                                                //             multiplayer
                                                //                 .toString();
                                                //       }
                                                //     });
                                                //   },
                                                //   child: SvgPicture.asset(
                                                //       theme.isDarkMode
                                                //           ? assets
                                                //               .darkCMinus
                                                //           : assets
                                                //               .minusIcon,
                                                //       fit: BoxFit
                                                //           .scaleDown),
                                                // ),

                                                // suffixIcon: InkWell(
                                                //       onTap: () {},
                                                //       child: SvgPicture.asset(
                                                //           assets.switchIcon,
                                                //           fit: BoxFit.scaleDown),
                                                //     ),

                                                // suffixIcon: InkWell(
                                                //   onTap: () {
                                                //     setState(() {
                                                //       String input =
                                                //           orderInput
                                                //               .ocoQtyCtrl
                                                //               .text;
                                                //       int currentQty =
                                                //           int.tryParse(
                                                //                   input) ??
                                                //               0;
                                                //       int adjustedQty =
                                                //           ((currentQty /
                                                //                       multiplayer)
                                                //                   .round()) *
                                                //               multiplayer;

                                                //       if (currentQty !=
                                                //           adjustedQty) {
                                                //         orderInput
                                                //                 .ocoQtyCtrl
                                                //                 .text =
                                                //             adjustedQty
                                                //                 .toString();
                                                //       } else if (input
                                                //               .isNotEmpty &&
                                                //           currentQty <
                                                //               ((frezQtyOrderSliceMaxLimit *
                                                //                           frezQty) ==
                                                //                       frezQtyOrderSliceMaxLimit
                                                //                   ? 999999
                                                //                   : frezQtyOrderSliceMaxLimit *
                                                //                       frezQty)) {
                                                //         orderInput
                                                //             .ocoQtyCtrl
                                                //             .text = (int.parse(orderInput
                                                //                     .ocoQtyCtrl
                                                //                     .text) +
                                                //                 multiplayer)
                                                //             .toString();
                                                //       } else {
                                                //         ScaffoldMessenger
                                                //                 .of(context)
                                                //             .removeCurrentSnackBar();
                                                //         ScaffoldMessenger
                                                //                 .of(
                                                //                     context)
                                                //             .showSnackBar(
                                                //                 warningMessage(
                                                //                     context,
                                                //                     "Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit * frezQty}"));
                                                //         // orderInput
                                                //         //     .ocoQtyCtrl
                                                //         //     .text = "$multiplayer";
                                                //       }
                                                //     });
                                                //   },
                                                //   child: SvgPicture.asset(
                                                //       theme.isDarkMode
                                                //           ? assets.darkAdd
                                                //           : assets
                                                //               .addIcon,
                                                //       fit: BoxFit
                                                //           .scaleDown),
                                                // ),
                                                textCtrl: orderInput.ocoQtyCtrl,
                                                textAlign: TextAlign.start,
                                                onChanged: (value) {
                                                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                  if (value.isEmpty || value == "0") {
                                                    warningMessage(context, "OCO quantity cannot be ${value == "0" ? '0' : 'empty'}");
                                                  } else {
                                                    String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');

                                                    int number = int.tryParse(newValue) ?? 0;
                                                    bool hasNoFreezeLimit = frezQty <= lotSize;
                                                    if (!hasNoFreezeLimit && number > frezQtyOrderSliceMaxLimit * frezQty) {
                                                      orderInput.qtyCtrl.text = orderInput.qtyCtrl.text;
                                                      warningMessage(context,
                                                          "Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit * frezQty}");
                                                    }

                                                    if (newValue != value) {
                                                      orderInput.ocoQtyCtrl.text = newValue;
                                                      orderInput.ocoQtyCtrl.selection = TextSelection.fromPosition(
                                                        TextPosition(offset: newValue.length),
                                                      );
                                                    }
                                                  }
                                                }),
                                          ))
                                    ])),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment
                                          //         .spaceBetween,
                                          children: [
                                            headerTitleText("Price", theme),
                                            const SizedBox(width: 4),
                                            TextWidget.subText(
                                              text: "${orderInput.actOcoPrcType}",
                                              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                              theme: theme.isDarkMode,
                                              fw: 1,
                                            ),
                                          ]),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                          height: 44,
                                          child: Semantics(
                                            identifier: 'oco_price_input',
                                            child: CustomTextFormField(
                                                inputFormate: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                                                fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                                onChanged: (value) {
                                                  double inputPrice = double.tryParse(value) ?? 0;
                                                  if (value.isNotEmpty && inputPrice > 0) {
                                                    final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                                                    if (!regex.hasMatch(value)) {
                                                      orderInput.ocoPriceCtrl.text = value.substring(0, value.length - 1);
                                                      orderInput.ocoPriceCtrl.selection = TextSelection.collapsed(
                                                        offset: orderInput.ocoPriceCtrl.text.length,
                                                      );
                                                    }
                                                  }
                                                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                    if (value.isEmpty) {
                                                warningMessage(context, "OCO price cannot be empty");
                                              } else if (inputPrice <= 0) {
                                                warningMessage(context, "OCO price cannot be 0");
                                              } else {
                                                setState(() {
                                                  ordPrice = value;
                                                });
                                              }},
                                                hintText: "${widget.orderArg.ltp}",
                                                hintStyle: TextWidget.textStyle(
                                                  fontSize: 14,
                                                  theme: theme.isDarkMode,
                                                  color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                                  fw: 0,
                                                ),
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                style: TextWidget.textStyle(
                                                  fontSize: 16,
                                                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                  theme: theme.isDarkMode,
                                                  fw: 0,
                                                ),
                                                isReadable:
                                                    orderInput.actOcoPrcType == "Limit" || orderInput.actOcoPrcType == "SL Limit" ? false : true,
                                                // prefixIcon: Container(
                                                //     margin: const EdgeInsets.all(
                                                //         12),
                                                //     decoration: BoxDecoration(
                                                //         borderRadius:
                                                //             BorderRadius.circular(20),
                                                //         color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                                                //     child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, orderInput.actOcoPrcType == "Limit" || orderInput.actOcoPrcType == "SL Limit" ? assets.ruppeIcon : assets.lock, fit: BoxFit.scaleDown)),

                                                suffixIcon: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      orderInput.setGTTOCOPriceTypeOrderIsMarket(
                                                          !orderInput.GTTOCOPriceTypeOrderIsMarket);
                                                      final newType1 = orderInput.GTTOCOPriceTypeOrderIsMarket ? "Market" : "Limit";
                                                      orderInput.chngOCOPriceType(
                                                          newType1);
                                                      if (orderInput.actOcoPrcType == "Market" ||
                                                          orderInput.actOcoPrcType == "SL MKT") {
                                                        orderInput.ocoPriceCtrl.text = "Market";
                                                      } else {
                                                        orderInput.ocoPriceCtrl.text = "${widget.orderArg.ltp}";
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(12.0),
                                                    child: SvgPicture.asset(assets.switchIcon, fit: BoxFit.contain),
                                                  ),
                                                ),
                                                textCtrl: orderInput.ocoPriceCtrl,
                                                textAlign: TextAlign.start),
                                          ))
                                    ]))
                                  ])),

                              // const SizedBox(height: 3),
                              // Divider(
                              //     color: theme.isDarkMode
                              //         ? colors.darkColorDivider
                              //         : colors.colorDivider),
                              // if (orderInput.actOcoPrcType == "SL Limit" ||
                              //     orderInput.actOcoPrcType == "SL MKT") ...[
                              //   Padding(
                              //       padding: const EdgeInsets.symmetric(
                              //           horizontal: 16),
                              //       child: Column(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.start,
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             const SizedBox(height: 2),
                              //             headerTitleText("Trigger", theme),
                              //             const SizedBox(height: 7),
                              //             SizedBox(
                              //                 height: 44,
                              //                 child: CustomTextFormField(
                              //                     fillColor: theme.isDarkMode
                              //                         ? colors.darkGrey
                              //                         : const Color(0xffF1F3F8),
                              //                     hintText: "0.00",
                              //                     hintStyle: textStyle(
                              //                         const Color(0xff666666),
                              //                         15,
                              //                         FontWeight.w400),
                              //                     onChanged: (value) {
                              //                       if (value.isNotEmpty &&
                              //                           double.parse(value) >
                              //                               0) {
                              //                         final regex = RegExp(
                              //                             r'^(\d+)?(\.\d{0,2})?$'); // Allows numbers with up to 2 decimal places
                              //                         if (!regex
                              //                             .hasMatch(value)) {
                              //                           orderInput.ocoTrgPrcCtrl
                              //                                   .text =
                              //                               value.substring(
                              //                                   0,
                              //                                   value.length -
                              //                                       1); // Revert to previous valid input
                              //                           orderInput.ocoTrgPrcCtrl
                              //                                   .selection =
                              //                               TextSelection.collapsed(
                              //                                   offset: orderInput
                              //                                       .ocoTrgPrcCtrl
                              //                                       .text
                              //                                       .length); // Keep cursor at the end
                              //                         }
                              //                       }
                              //                       ScaffoldMessenger.of(
                              //                               context)
                              //                           .hideCurrentSnackBar();
                              //                       if (value.isNotEmpty) {
                              //                       } else {
                              //                         ScaffoldMessenger.of(
                              //                                 context)
                              //                             .showSnackBar(
                              //                                 warningMessage(
                              //                                     context,
                              //                                     "Trigger cannot be empty"));
                              //                       }
                              //                     },
                              //                     keyboardType:
                              //                         const TextInputType.numberWithOptions(
                              //                             decimal: true),
                              //                     style: textStyle(
                              //                         theme.isDarkMode
                              //                             ? colors.colorWhite
                              //                             : colors.colorBlack,
                              //                         16,
                              //                         FontWeight.w600),
                              //                     prefixIcon: Container(
                              //                         margin:
                              //                             const EdgeInsets.all(
                              //                                 12),
                              //                         decoration: BoxDecoration(
                              //                             borderRadius:
                              //                                 BorderRadius.circular(
                              //                                     20),
                              //                             color: theme.isDarkMode
                              //                                 ? const Color(
                              //                                     0xff555555)
                              //                                 : colors
                              //                                     .colorWhite),
                              //                         child: SvgPicture.asset(
                              //                             color: theme.isDarkMode
                              //                                 ? colors.colorWhite
                              //                                 : colors.colorGrey,
                              //                             assets.ruppeIcon,
                              //                             fit: BoxFit.scaleDown)),
                              //                     textCtrl: orderInput.ocoTrgPrcCtrl,
                              //                     textAlign: TextAlign.start)),
                              //           ])),
                              //   Divider(
                              //       color: theme.isDarkMode
                              //           ? colors.darkColorDivider
                              //           : colors.colorDivider)
                              // ]
                            ],

                            // if (!isOco) ...[
                            //   const SizedBox(height: 3),
                            //   Divider(
                            //       color: theme.isDarkMode
                            //           ? colors.darkColorDivider
                            //           : colors.colorDivider,
                            //       thickness: .4)

                            // Padding(
                            //   padding:
                            //       const EdgeInsets.only(bottom: 8, left: 16),
                            //   child: headerTitleText("Remarks", theme),
                            // ),
                            // Container(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 16),
                            //   height: 40,
                            //   child: CustomTextFormField(
                            //       keyboardType: TextInputType.text,
                            //       fillColor: theme.isDarkMode
                            //           ? colors.darkGrey
                            //           : const Color(0xffF1F3F8),
                            //       hintStyle: textStyle(const Color(0xff666666),
                            //           15, FontWeight.w400),
                            //       style: textStyle(
                            //           theme.isDarkMode
                            //               ? colors.colorWhite
                            //               : colors.colorBlack,
                            //           16,
                            //           FontWeight.w600),
                            //       textAlign: TextAlign.start,
                            //       onChanged: (value) {},
                            //       textCtrl: orderInput.reMarksCtrl),
                            // ),

                            //  ],
                            // if ((orderInput.actOcoPrcType == "Market" ||
                            //         orderInput.actOcoPrcType == "SL MKT") ||
                            //     (orderInput.actPrcType == "Market" ||
                            //         orderInput.actPrcType == "SL MKT")) ...[
                            //   const SizedBox(height: 16),
                            //   marketProtectionDisclaimer(theme, context,
                            //       widget.scripInfo, mktProtCtrl.text),
                            //   const SizedBox(height: 16),
                            // ],
                            const SizedBox(height: 100)
                          ] else ...[
                            // If Order Tab is Regular then show investment type and investment type radio button
                            // if (orderType == "Delivery" || orderType == "Intraday") ...[
                            //   Column(
                            //       crossAxisAlignment:
                            //           CrossAxisAlignment.start,
                            //       children: [
                            //         Padding(
                            //             padding: const EdgeInsets.symmetric(
                            //                 horizontal: 16),
                            //             child: Row(
                            //               mainAxisAlignment:
                            //                   MainAxisAlignment
                            //                       .spaceBetween,
                            //               children: [
                            //                 Text("Investment type",
                            //                     style: textStyle(
                            //                         theme.isDarkMode
                            //                             ? colors.colorWhite
                            //                             : colors.colorBlack,
                            //                         14,
                            //                         FontWeight.w500)),
                            //                 InkWell(
                            //                   onTap: () {
                            //                     setState(() {
                            //                       Navigator.pop(context);
                            //                       Navigator.pushNamed(
                            //                           context,
                            //                           Routes.orderPrefer,
                            //                           arguments: {
                            //                             "orderArg":
                            //                                 widget.orderArg,
                            //                             "scripInfo": widget
                            //                                 .scripInfo,
                            //                             "isRollback": 'yes'
                            //                           });
                            //                     });
                            //                   },
                            //                   child: SvgPicture.asset(
                            //                       'assets/profile/privacy_settings.svg'),
                            //                 )
                            //               ],
                            //             )),
                            //         Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.start,
                            //             children: [
                            //               if (widget.orderArg.exchange !=
                            //                   "NCOM") ...[
                            //                 Radio<InvestType>(
                            //                     fillColor:
                            //                         WidgetStateProperty
                            //                             .resolveWith<
                            //                                 Color>((Set<
                            //                                     WidgetState>
                            //                                 states) {
                            //                       if (states.contains(
                            //                           WidgetState
                            //                               .disabled)) {
                            //                         return const Color(
                            //                             0xff666666);
                            //                       }
                            //                       return theme.isDarkMode
                            //                           ? colors.colorWhite
                            //                           : const Color(
                            //                               0xff666666);
                            //                     }),
                            //                     activeColor:
                            //                         theme.isDarkMode
                            //                             ? colors.colorWhite
                            //                             : const Color(
                            //                                 0xff666666),
                            //                     value: InvestType.intraday,
                            //                     groupValue:
                            //                         orderInput.investType,
                            //                     onChanged:
                            //                         (InvestType? value) {
                            //                       orderInput.chngInvesType(
                            //                           value!, "PlcOrder");
                            //                       if (orderType != "GTT") {
                            //                         marginUpdate();
                            //                       }
                            //                     }),
                            //                 Text('Intraday',
                            //                     style: textStyle(
                            //                         theme.isDarkMode
                            //                             ? Color(orderInput
                            //                                         .investType ==
                            //                                     InvestType
                            //                                         .intraday
                            //                                 ? 0xffffffff
                            //                                 : 0xff666666)
                            //                             : Color(orderInput
                            //                                         .investType ==
                            //                                     InvestType
                            //                                         .intraday
                            //                                 ? 0xff3E4763
                            //                                 : 0xff666666),
                            //                         14,
                            //                         FontWeight.w500))
                            //               ],
                            //               Radio<InvestType>(
                            //                   fillColor: WidgetStateProperty
                            //                       .resolveWith<Color>(
                            //                           (Set<WidgetState>
                            //                               states) {
                            //                     if (states.contains(
                            //                         WidgetState.disabled)) {
                            //                       return const Color(
                            //                           0xff666666);
                            //                     }
                            //                     return theme.isDarkMode
                            //                         ? colors.colorWhite
                            //                         : const Color(
                            //                             0xff666666);
                            //                   }),
                            //                   activeColor: theme.isDarkMode
                            //                       ? colors.colorWhite
                            //                       : const Color(0xff666666),
                            //                   value: widget.scripInfo.seg ==
                            //                           "EQT"
                            //                       ? InvestType.delivery
                            //                       : InvestType.carryForward,
                            //                   groupValue:
                            //                       orderInput.investType,
                            //                   onChanged:
                            //                       (InvestType? value) {
                            //                     orderInput.chngInvesType(
                            //                         value!, "PlcOrder");
                            //                     if (orderType != "GTT") {
                            //                       marginUpdate();
                            //                     }
                            //                   }),
                            //               Text(
                            //                   widget.scripInfo.seg == "EQT"
                            //                       ? 'Delivery'
                            //                       : "Carry Forward",
                            //                   style: textStyle(
                            //                       theme.isDarkMode
                            //                           ? Color(orderInput
                            //                                           .investType ==
                            //                                       InvestType
                            //                                           .delivery ||
                            //                                   orderInput
                            //                                           .investType ==
                            //                                       InvestType
                            //                                           .carryForward
                            //                               ? 0xffffffff
                            //                               : 0xff666666)
                            //                           : Color(orderInput
                            //                                           .investType ==
                            //                                       InvestType
                            //                                           .delivery ||
                            //                                   orderInput
                            //                                           .investType ==
                            //                                       InvestType
                            //                                           .carryForward
                            //                               ? 0xff3E4763
                            //                               : 0xff666666),
                            //                       14,
                            //                       FontWeight.w500))
                            //             ])
                            //       ]),
                            //   const SizedBox(height: 8)
                            // ],
                            // If Order Tab is Regular, Cover, Bracket, or GTT then show Price type Section , Quantity and Price fields
                            // if (orderType == "Regular" || orderType == "Cover" || orderType == "Bracket" || orderType == "GTT") ...[
                            if (orderType == "Delivery" ||
                                orderType == "Intraday" ||
                                orderType == "CO - BO" ||
                                orderType == "GTT" ||
                                orderType == "MTF") ...[
                              //   Padding(
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 16),
                              //         child: Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.spaceBetween,
                              //           children: [
                              //             Text("Price type",
                              //                 style: textStyle(
                              //                     theme.isDarkMode
                              //                         ? colors.colorWhite
                              //                         : colors.colorBlack,
                              //                     14,
                              //                     FontWeight.w500)),
                              //             if (orderType != "Regular") ...[
                              //                 InkWell(
                              //                   onTap: () {
                              //                       setState(() {
                              //                         Navigator.pop(context);
                              //                         Navigator.pushNamed(context,
                              //                             Routes.orderPrefer,
                              //                             arguments: {
                              //                               "orderArg":
                              //                                   widget.orderArg,
                              //                               "scripInfo":
                              //                                   widget.scripInfo,
                              //                               "isRollback": 'yes'
                              //                             });
                              //                       },
                              //                     );
                              //                   },
                              //                   child: SvgPicture.asset(
                              //                       'assets/profile/privacy_settings.svg'),
                              //                 )
                              //             ]
                              //           ],
                              //         ),
                              //     ),
                              //       const SizedBox(height: 10),

                              //   // Price Type section, List of buttons such as Market, Limit, SL, SL Mkt
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 16),
                              //   child: SizedBox(
                              //       height: 38,
                              //       child: ListView.separated(
                              //           scrollDirection: Axis.horizontal,
                              //           itemBuilder: (context, index) {
                              //                 return ElevatedButton(
                              //                     onPressed: () {
                              //                     setState(() {
                              //                         priceType =
                              //                             priceTypes[index]
                              //                                 ['type'];
                              //                         if (priceType ==
                              //                                 "Market" ||
                              //                             priceType ==
                              //                                 "SL MKT") {
                              //                         priceCtrl.text =
                              //                             "Market";

                              //                         double ltp = (double.parse("${widget.orderArg.ltp}") *
                              //                                 double.parse(mktProtCtrl.text.isEmpty? "0": mktProtCtrl.text)) /100;

                              //                         if (isBuy!) {
                              //                             ordPrice = (double.parse("${widget.orderArg.ltp ?? 0.00}") + ltp).toStringAsFixed(2);
                              //                         } else {
                              //                             ordPrice = (double.parse("${widget.orderArg.ltp ?? 0.00}") - ltp).toStringAsFixed(2);
                              //                         }
                              //                         double result = double.parse(ordPrice) + (double.parse( "${widget.scripInfo.ti}") / 2);
                              //                         result -= result % double.parse("${widget.scripInfo.ti}");

                              //                           if (result >=
                              //                               double.parse(
                              //                                   "${widget.scripInfo.uc ?? 0.00}")) {
                              //                               ordPrice =
                              //                                   "${widget.scripInfo.uc ?? 0.00}";
                              //                           } else if (result <=
                              //                               double.parse(
                              //                                   "${widget.scripInfo.lc ?? 0.00}")) {
                              //                               ordPrice =
                              //                                   "${widget.scripInfo.lc ?? 0.00}";
                              //                           } else {
                              //                               ordPrice = result
                              //                                   .toStringAsFixed(
                              //                                       2);
                              //                           }
                              //                           } else {
                              //                               priceCtrl.text =
                              //                                   "${widget.orderArg.ltp}";
                              //                               ordPrice =
                              //                                   priceCtrl.text;
                              //                           }
                              //                           orderInput
                              //                               .chngPriceType(
                              //                                   priceTypes[
                              //                                           index]
                              //                                       ['type'],
                              //                                   widget.orderArg
                              //                                       .exchange);
                              //                       });
                              //                       marginUpdate();
                              //                       FocusScope.of(context)
                              //                           .unfocus();
                              //                       },
                              //                       style: ElevatedButton
                              //                           .styleFrom(
                              //                               elevation: 0,
                              //                               padding: const EdgeInsets
                              //                                   .symmetric(
                              //                                   horizontal: 12,
                              //                                   vertical: 0),
                              //                               backgroundColor: !theme
                              //                                       .isDarkMode
                              //                                   ? priceType !=
                              //                                           priceTypes[index]
                              //                                               [
                              //                                               'type']
                              //                                       ? const Color(
                              //                                           0xffF1F3F8)
                              //                                       : colors
                              //                                           .colorBlack
                              //                                   : priceType !=
                              //                                           priceTypes[index]
                              //                                               [
                              //                                               'type']
                              //                                       ? colors
                              //                                           .darkGrey
                              //                                       : colors
                              //                                           .colorbluegrey,
                              //                               shape:
                              //                                   const StadiumBorder()),
                              //                       child: Text(
                              //                           priceTypes[index]
                              //                               ['type'],
                              //                           style: textStyle(
                              //                               !theme.isDarkMode
                              //                                   ? priceType !=
                              //                                           priceTypes[index]
                              //                                               [
                              //                                               'type']
                              //                                       ? const Color(
                              //                                           0xff666666)
                              //                                       : colors
                              //                                           .colorWhite
                              //                                   : priceType !=
                              //                                           priceTypes[index]
                              //                                               ['type']
                              //                                       ? const Color(0xff666666)
                              //                                       : colors.colorBlack,
                              //                               14,
                              //                               priceType == priceTypes[index]['type'] ? FontWeight.w600 : FontWeight.w500),
                              //                           ),
                              //                       );
                              //             },
                              //             separatorBuilder:
                              //                 (context, index) {
                              //               return const SizedBox(width: 8);
                              //             },
                              //             itemCount: orderType == "Cover" || orderType == "Bracket" ? 3 : priceTypes.length
                              //           ),
                              //         ),
                              //     ),
                              //   const SizedBox(height: 3),
                              // Divider(
                              //     color: theme.isDarkMode
                              //         ? colors.darkColorDivider
                              //         : colors.colorDivider),

                              // Quantity and Price fields
                              if (orderType == "MTF" && !_isMTFEnabled) ...[
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Card(
                                    color: theme.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF1F3F8),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.lock_outline,
                                              size: 40, color: theme.isDarkMode ? colors.lossDark : colors.lossLight), // your blue
                                          const SizedBox(height: 16),
                                          TextWidget.subText(
                                            text: "MTF is not Enabled",
                                            align: TextAlign.center,
                                            color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                                            theme: theme.isDarkMode,
                                            fw: 0,
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: colors.colorBlue,
                                                minimumSize: const Size(0, 45),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                              ),
                                              onPressed: () {
                                                final profileDetails = ref.watch(profileAllDetailsProvider);
                                                final clientData = profileDetails.clientAllDetails.clientData;

                                                bool DDPIActive = clientData?.dDPI == 'Y';
                                                bool POAActive = clientData?.pOA == 'Y';
                                                // Navigate to the screen where the user enables MTF
                                                // Navigator.pushNamed(context, Routes.mtfEnableScreen);
                                                
                                                if (!DDPIActive && !POAActive){
                                                    final pendingStatuses =
                                                      ref.watch(profileAllDetailsProvider).pendingStatusList;
                                                  if (pendingStatuses.isNotEmpty &&
                                                      pendingStatuses[0].data != null) {
                                                    final hasPendingChanges = pendingStatuses[0]
                                                        .data!
                                                        .any((status) => status == 'mtf_pending');
                                                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                  if (hasPendingChanges) {
                                                      warningMessage(context, 'You have pending request.click on the E-Sign to proceed.');
                                                      return;
                                                    }
                                                  }
                                                  // profileDetails.openInWebURL(context, "segment");
                                                  ref.watch(profileAllDetailsProvider).openInWebURLk(context, "segment", "mtf");
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => const MyAccountScreen(initialIndex: 2),
                                                    ),
                                                  );
                                                  warningMessage(context, 'You need to enable DDPI before you can proceed with enabling MTF.');
                                                }
                                              },
                                              child: TextWidget.subText(
                                                text: "Enable MTF",
                                                color: colors.colorWhite,
                                                theme: theme.isDarkMode,
                                                fw: 2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ] else ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      headerTitleText(
                                                        (_isStock)
                                                          ? (_isQtyToAmount ? "Amount" : "Qty")
                                                          : (_isLotToQty ? "Qty" : "Lot"),
                                                        theme
                                                      ),
                                                      const SizedBox(width: 16),
                                                      if(widget.scripInfo.exch == "NFO" || widget.scripInfo.exch == "BFO" || _isStock)
                                                      Material(
                                                        color: Colors.transparent,
                                                        shape: const CircleBorder(),
                                                        child: InkWell(
                                                          customBorder: const CircleBorder(),
                                                          splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                                                          highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                                                          onTap: () {
                                                            setState(() {
                                                              if (_isStock) {
                                                                // NSE/BSE: Toggle between Qty and Amount
                                                                _isQtyToAmount = !_isQtyToAmount;
                                                                if (_isQtyToAmount) {
                                                                  qtyCtrl.text = ((double.tryParse(widget.orderArg.ltp ?? "0.00") ?? 0).ceil()).toString();
                                                                } else {
                                                                  qtyCtrl.text = "1";
                                                                }
                                                              } else {
                                                                // NFO/BFO: Toggle between Lot and Qty
                                                                _isLotToQty = !_isLotToQty;
                                                                if (_isLotToQty) {
                                                                  // Converting from Lot to Qty: multiply by lot size
                                                                  int currentLot = int.tryParse(qtyCtrl.text) ??  1;
                                                                  qtyCtrl.text = (currentLot * lotSize).toString();
                                                                } else {
                                                                  // Converting from Qty to Lot: divide by lot size
                                                                  int currentQty = int.tryParse(qtyCtrl.text) ?? lotSize;
                                                                  qtyCtrl.text = ((currentQty / lotSize).round()).toString();
                                                                  // if (qtyCtrl.text == "0") qtyCtrl.text = "1";
                                                                }
                                                              }
                                                              marginUpdate();
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(0.0),
                                                            child: SvgPicture.asset(
                                                              assets.switchIcon,
                                                              width: 16,
                                                              height: 16,
                                                              fit: BoxFit.contain,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  // Text(
                                                  // "Lot: ${widget.scripInfo.ls} ${widget.scripInfo.prcunt ?? ''}  ",
                                                  // style: textStyle(
                                                  //     const Color(
                                                  //         0xff777777),
                                                  //     11,
                                                  //     FontWeight.w600),
                                                  // )
                                                ]),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 45,
                                              child: Semantics(
                                                identifier: 'qty_input',
                                                child: CustomTextFormField(
                                                  fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                                  hintText: "0", //qtyCtrl.text,
                                                  hintStyle: TextWidget.textStyle(
                                                    fontSize: 14,
                                                    theme: theme.isDarkMode,
                                                    color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                                    fw: 0,
                                                  ),
                                                  inputFormate: [FilteringTextInputFormatter.digitsOnly],
                                                  keyboardType: TextInputType.number,
                                                  style: TextWidget.textStyle(
                                                    fontSize: 16,
                                                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                    theme: theme.isDarkMode,
                                                    fw: 0,
                                                  ),
                                                  prefixIcon: _isStock
                                                      ? null
                                                      : Material(
                                                          color: Colors.transparent,
                                                          shape: const CircleBorder(),
                                                          child: InkWell(
                                                            customBorder: const CircleBorder(),
                                                            splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                                                            highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                                                            onTap: () {
                                                              setState(() {
                                                                String input = qtyCtrl.text;
                                                                int currentValue = int.tryParse(input) ?? 0;
                                                                int adjustedQty = currentValue >= multiplayer ? ((currentValue / multiplayer).floor()) * multiplayer : multiplayer;

                                                                if (_isLotToQty) {
                                                                  // Qty mode: decrement by Lot size
                                                                  if (currentValue != adjustedQty) {
                                                                    qtyCtrl.text = (adjustedQty).toString();
                                                                  }else if(input.isNotEmpty && currentValue > multiplayer){
                                                                          qtyCtrl.text = (currentValue - multiplayer).toString();
                                                                  }else {
                                                                    qtyCtrl.text = "$multiplayer";
                                                                  }
                                                                } else {
                                                                  // Lot mode: decrement by 1
                                                                  if (currentValue > 1) {
                                                                    qtyCtrl.text = (currentValue - 1).toString();
                                                                  } else {
                                                                    qtyCtrl.text = "1";
                                                                  }
                                                                }
                                                                marginUpdate();
                                                              });
                                                            },
                                                            child: SvgPicture.asset(
                                                              theme.isDarkMode ? assets.darkCMinus : assets.minusIcon,
                                                              fit: BoxFit.scaleDown,
                                                            ),
                                                          )),

                                                  suffixIcon: _isStock
                                                      ? null
                                                      : Material(
                                                          color: Colors.transparent,
                                                          shape: const CircleBorder(),
                                                          child: InkWell(
                                                            customBorder: const CircleBorder(),
                                                            splashColor: theme.isDarkMode
                                                                ? colors.splashColorDark
                                                                : colors.splashColorLight,
                                                            highlightColor: theme.isDarkMode
                                                                ? colors.highlightDark
                                                                : colors.highlightLight,
                                                            onTap: () {
                                                              setState(() {
                                                                String input = qtyCtrl.text;
                                                                int currentValue = int.tryParse(input) ?? 0;
                                                                int adjustedQty = currentValue >= multiplayer ? ((currentValue / multiplayer).floor()) * multiplayer : multiplayer;

                                                                
                                                                bool hasNoFreezeLimit = frezQty <= lotSize;
                                                                bool withinLimit = hasNoFreezeLimit || currentValue < frezQtyOrderSliceMaxLimit * frezQty;
                                                                
                                                                if (_isLotToQty) {
                                                                  // Qty mode: increment by Lot Size, check against freeze limit
                                                                  if (currentValue != adjustedQty) {
                                                                      qtyCtrl.text = adjustedQty.toString();

                                                                  } else if (input.isNotEmpty && withinLimit) {
                                                                        qtyCtrl.text = (currentValue + multiplayer).toString();
                                                                  } else if(input.isEmpty){
                                                                    qtyCtrl.text = "$multiplayer";
                                                                  }
                                                                  else if (!hasNoFreezeLimit) {
                                                                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                                      warningMessage(context,"Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit*frezQty}");
                                                                    // qtyCtrl.text =
                                                                    //     "$multiplayer";
                                                                  }
                                                                } else {
                                                                  // Lot mode: increment by 1 lot, check against freeze limit
                                                                  bool hasNoFreezeLimit = frezQty <= lotSize;
                                                                  int maxAllowedLots = hasNoFreezeLimit ? 999999 : (frezQtyOrderSliceMaxLimit * frezQty) ~/ lotSize;

                                                                  if (input.isEmpty) {
                                                                    qtyCtrl.text = "1";
                                                                  } else if (currentValue < maxAllowedLots) {
                                                                    qtyCtrl.text = (currentValue + 1).toString();
                                                                  } else {
                                                                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                                    warningMessage(context,"Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit*frezQty}");
                                                                  }
                                                                }
                                                                marginUpdate();
                                                              });
                                                            },
                                                            child: SvgPicture.asset(
                                                              theme.isDarkMode
                                                                  ? assets.darkAdd
                                                                  : assets.addIcon,
                                                              fit: BoxFit.scaleDown
                                                            ),
                                                          ),
                                                        ),

                                                  textCtrl: qtyCtrl,
                                                  textAlign: _isStock
                                                      ? TextAlign.start
                                                      : TextAlign.center,
                                                  onChanged: (value) {
                                                     ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                    if (value.isEmpty || value == "0") {
                                                      String fieldName = (_isStock)
                                                          ? (_isQtyToAmount ? 'Amount' : 'Quantity')
                                                          : (_isLotToQty ? 'Quantity' : 'Lot');
                                                      warningMessage(context,
                                                          "$fieldName cannot be ${value == "0" ? '0' : 'empty'}");
                                                    } else {
                                                      String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                                      double ltp = double.tryParse(widget.orderArg.ltp ?? "0.0") ?? 0.0;
                                                      var number = (_isStock)
                                                          ? (!_isQtyToAmount ? int.tryParse(newValue) ?? 0 : ((double.tryParse(newValue) ?? 0.0) ~/ ltp))
                                                          : (!_isLotToQty ? int.tryParse(newValue) ?? 0 : ((int.tryParse(newValue) ?? 0) ~/ lotSize));

                                                      if (_isQtyToAmount && number < 1 && (_isStock)) {
                                                        warningMessage(context,
                                                            "Minimum Allowed Amount should be greater than $ltp");
                                                      } else {
                                                        bool hasNoFreezeLimit = frezQty <= lotSize;
                                                        if (!hasNoFreezeLimit && number > frezQtyOrderSliceMaxLimit * frezQty) {
                                                          qtyCtrl.text = qtyCtrl.text;
                                                          warningMessage(context,
                                                              "Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit * frezQty}");
                                                        }
                                                      }

                                                      if (newValue != value) {
                                                        qtyCtrl.text = newValue;
                                                        qtyCtrl.selection = TextSelection.fromPosition(
                                                          TextPosition(offset: newValue.length),
                                                        );
                                                      }
                                                      marginUpdate();
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            // if (widget.scripInfo.frzqty != null) ...[
                                            //         const SizedBox(height: 8),
                                            //         Text("Frz Qty : $frezQty",
                                            //             style: textStyle(
                                            //                 const Color(
                                            //                     0xff666666),
                                            //                 12,
                                            //                 FontWeight.w500))
                                            // ]
                                            if (_isQtyToAmount && (_isStock))
                                              TextWidget.subText(
                                                text: "Qty : ${getFinalQuantity(qtyCtrl.text)}",
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                fw: 0,
                                              ),
                                            if (_isLotToQty && (widget.scripInfo.exch == "NFO" || widget.scripInfo.exch == "BFO"))
                                              TextWidget.subText(
                                                text: "Lot : ${((int.tryParse(qtyCtrl.text) ?? 0) / lotSize).ceil()}",
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                fw: 0,
                                              ),
                                            // Text(
                                            //     "Qty : ${getFinalQuantity(qtyCtrl.text)}",
                                            //     style: textStyle(
                                            //         const Color(
                                            //             0xff666666),
                                            //         14,
                                            //         FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                // mainAxisAlignment:
                                                //     MainAxisAlignment
                                                //         .spaceBetween,
                                                // crossAxisAlignment:
                                                //     CrossAxisAlignment
                                                //         .end,
                                                children: [
                                                  headerTitleText("Price", theme),
                                                  const SizedBox(width: 4),
                                                  TextWidget.subText(
                                                      text: "$priceType",
                                                      theme: theme.isDarkMode,
                                                      fw: 1,
                                                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight)
                                                ]),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                                height: 45,
                                                child: Semantics(
                                                  identifier: 'price_input',
                                                  child: CustomTextFormField(
                                                      inputFormate: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                                                      fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                                      onChanged: (value) {
                                                        double inputPrice = double.tryParse(value) ?? 0;
                                                        if (value.isNotEmpty && inputPrice > 0) {
                                                          final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                                                          if (!regex.hasMatch(value)) {
                                                            priceCtrl.text = value.substring(0, value.length - 1);
                                                            priceCtrl.selection = TextSelection.collapsed(
                                                              offset: priceCtrl.text.length,
                                                            );
                                                          }
                                                        }
                                                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                        if (value.isEmpty) {
                                                          warningMessage(context, "Price cannot be empty");
                                                        } else if (inputPrice <= 0) {
                                                          warningMessage(context, "Price cannot be 0");
                                                        } else {
                                                          setState(() {
                                                            ordPrice = value;
                                                            marginUpdate();
                                                          });
                                                        }
                                                      },
                                                      hintText: "${widget.orderArg.ltp}",
                                                      hintStyle: TextWidget.textStyle(
                                                        fontSize: 14,
                                                        theme: theme.isDarkMode,
                                                        color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight)
                                                            .withOpacity(0.4),
                                                        fw: 0,
                                                      ),
                                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                      style: TextWidget.textStyle(
                                                        fontSize: 16,
                                                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                        theme: theme.isDarkMode,
                                                        fw: 0,
                                                      ),
                                                      isReadable: priceType == "Limit" || priceType == "SL Limit" ? false : true,
                                                      // prefixIcon: Container(
                                                      //     margin:
                                                      //         const EdgeInsets.all(
                                                      //             12),
                                                      //     decoration: BoxDecoration(
                                                      //         borderRadius: BorderRadius.circular(20),
                                                      //         color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                                                      //     child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, priceType == "Limit" || priceType == "SL Limit" ? assets.ruppeIcon : assets.lock, fit: BoxFit.scaleDown)),
                                                      suffixIcon: Material(
                                                        color: Colors.transparent,
                                                        shape: const CircleBorder(),
                                                        child: InkWell(
                                                          customBorder: const CircleBorder(),
                                                          splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                                                          highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                                                          onTap: () {
                                                            setState(() {
                                                              _isMarketOrder = !_isMarketOrder;
                                                              updatePriceType();
                                                              orderInput.chngPriceType(priceType, widget.orderArg.exchange);
                                                              marginUpdate();
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(12.0),
                                                            child: SvgPicture.asset(
                                                              assets.switchIcon,
                                                              fit: BoxFit.contain,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      textCtrl: priceCtrl,
                                                      textAlign: TextAlign.start),
                                                )),
                                            // const SizedBox(height: 8),
                                            // Text(
                                            //     "Cir Lv : ${widget.scripInfo.lc ?? 0.00} - ${widget.scripInfo.uc ?? 0.00}",
                                            //     style: textStyle(
                                            //         const Color(
                                            //             0xff666666),
                                            //         12,
                                            //         FontWeight.w500))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if ((priceType == "Market" || priceType == "SL MKT")) ...[
                                  const SizedBox(height: 16),
                                  marketProtectionDisclaimer(theme, context, widget.scripInfo, mktProtCtrl.text),
                                  // const SizedBox(height: 16),
                                ],

                                // if (orderType == "Delivery" || orderType == "Intraday" || orderType == "MTF" || orderType == "CO - BO") ...[
                                  // Advance Option section
                                  const SizedBox(height: 16),
                                  Column(
                                    children: [
                                      Center(
                                        child: SizedBox(
                                          width: 150,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                             shape: const RoundedRectangleBorder(),
                                                                          padding: const EdgeInsets.all(0),
                                                                          backgroundColor: Colors.white,
                                                                          foregroundColor: Colors.white,
                                                                          elevation: 0.0,
                                                                          minimumSize: const Size(0, 40),
                                                                          side: BorderSide.none,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (!_isStoplossOrder && !_afterMarketOrder && !_addValidityAndDisclosedQty) {
                                                  isAdvancedOptionClicked = !isAdvancedOptionClicked;
                                                }
                                                updatePriceType();
                                              });
                                            },
                                            child: Container(
                                              color: Colors.transparent, // To make the full width tappable
                                              height: 48,
                                              child: Center(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextWidget.subText(
                                                        text: 'Advance',
                                                        color: theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight,
                                                        theme: theme.isDarkMode,
                                                        fw: 2),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 4),
                                                      child: Icon(
                                                        isAdvancedOptionClicked ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                        color: theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: isAdvancedOptionClicked,
                                        child: Column(
                                          children: [
                                            Divider(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,),

                                            Theme(
                                              data: ThemeData(
                                                unselectedWidgetColor: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                              ),
                                              child: GestureDetector(
                                                behavior: HitTestBehavior.translucent, // Improves touch detection
                                                onTap: () {
                                                  setState(() {
                                                    _isStoplossOrder = !_isStoplossOrder;
                                                    updatePriceType();
                                                    orderInput.chngPriceType(priceType, widget.orderArg.exchange);
                                                    marginUpdate();
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      TextWidget.subText(
                                                        text: 'Stoploss order',
                                                        theme: theme.isDarkMode,
                                                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                        fw: 0,
                                                      ),
                                                      // Text(
                                                      //   'Stoploss order',
                                                      //   style: textStyle(
                                                      //     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                      //     14,
                                                      //     FontWeight.w400,
                                                      //   ),
                                                      // ),
                                                      AnimatedContainer(
                                                        duration: const Duration(milliseconds: 250),
                                                        curve: Curves.easeOut,
                                                        width: 40,
                                                        height: 22,
                                                        padding: const EdgeInsets.symmetric(horizontal: 3),
                                                        decoration: BoxDecoration(
                                                          color: _isStoplossOrder
                                                              ? colors.colorBlue.withOpacity(0.25)
                                                              : (theme.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: AnimatedAlign(
                                                          duration: const Duration(milliseconds: 250),
                                                          curve: Curves.easeOut,
                                                          alignment: _isStoplossOrder ? Alignment.centerRight : Alignment.centerLeft,
                                                          child: Container(
                                                            width: 16,
                                                            height: 16,
                                                            decoration: BoxDecoration(
                                                              color: _isStoplossOrder ? colors.colorBlue : Colors.grey[500],
                                                              shape: BoxShape.circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black.withOpacity(0.25),
                                                                  blurRadius: 3,
                                                                  offset: const Offset(0, 1),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (priceType == "SL Limit" || priceType == "SL MKT") ...[
                                              triggerOption(theme, context, widget.scripInfo), 
                                            ],


                                            if(!(orderType == "CO - BO")) ...[
                                            // AMO switch section
                                            Divider(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider),
                                            Theme(
                                              data: ThemeData(
                                                unselectedWidgetColor: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                              ),
                                              child: GestureDetector(
                                                behavior: HitTestBehavior.translucent, // Improves touch detection
                                                onTap: () {
                                                  setState(() {
                                                    _afterMarketOrder = !_afterMarketOrder;
                                                    // isAmo = !isAmo; // if needed
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      TextWidget.subText(
                                                        text: 'After market order (AMO)',
                                                        theme: theme.isDarkMode,
                                                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                        fw: 0,
                                                      ),
                                                      // Text(
                                                      //   'After market order (AMO)',
                                                      //   style: textStyle(
                                                      //     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                      //     14,
                                                      //     FontWeight.w400,
                                                      //   ),
                                                      // ),
                                                      AnimatedContainer(
                                                        duration: const Duration(milliseconds: 250),
                                                        curve: Curves.easeOut,
                                                        width: 40,
                                                        height: 22,
                                                        padding: const EdgeInsets.symmetric(horizontal: 3),
                                                        decoration: BoxDecoration(
                                                          color: _afterMarketOrder
                                                              ? colors.colorBlue.withOpacity(0.25)
                                                              : (theme.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: AnimatedAlign(
                                                          duration: const Duration(milliseconds: 250),
                                                          curve: Curves.easeOut,
                                                          alignment: _afterMarketOrder ? Alignment.centerRight : Alignment.centerLeft,
                                                          child: Container(
                                                            width: 16,
                                                            height: 16,
                                                            decoration: BoxDecoration(
                                                              color: _afterMarketOrder ? colors.colorBlue : Colors.grey[500],
                                                              shape: BoxShape.circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black.withOpacity(0.25),
                                                                  blurRadius: 3,
                                                                  offset: const Offset(0, 1),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ],

                                            if(!(orderType == "CO - BO")) ...[
                                              // validity & Disclosed Qty  section
                                            Divider(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider),
                                            Theme(
                                              data: ThemeData(
                                                unselectedWidgetColor: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                              ),
                                              child: GestureDetector(
                                                behavior: HitTestBehavior.translucent, // Improves touch detection
                                                    onTap: () {
                                                      setState(() {
                                                        _addValidityAndDisclosedQty = !_addValidityAndDisclosedQty;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          TextWidget.subText(
                                                            text: 'Add validity & Disclosed quantity',
                                                            theme: theme.isDarkMode,
                                                            color: theme.isDarkMode
                                                                ? colors.textPrimaryDark
                                                                : colors.textPrimaryLight,
                                                            fw: 0,
                                                          ),
                                                          // Text(
                                                          //   'Add validity & Disclosed quantity',
                                                          //   style: textStyle(
                                                          //     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                          //     14,
                                                          //     FontWeight.w400,
                                                          //   ),
                                                          // ),
                                                          AnimatedContainer(
                                                            duration: const Duration(milliseconds: 250),
                                                            curve: Curves.easeOut,
                                                            width: 40,
                                                            height: 22,
                                                            padding: const EdgeInsets.symmetric(horizontal: 3),
                                                            decoration: BoxDecoration(
                                                              color: _addValidityAndDisclosedQty
                                                                  ? colors.colorBlue.withOpacity(0.25)
                                                                  : (theme.isDarkMode
                                                                      ? Colors.grey[700]
                                                                      : Colors.grey[300]),
                                                              borderRadius: BorderRadius.circular(20),
                                                            ),
                                                            child: AnimatedAlign(
                                                              duration: const Duration(milliseconds: 250),
                                                              curve: Curves.easeOut,
                                                              alignment: _addValidityAndDisclosedQty
                                                                  ? Alignment.centerRight
                                                                  : Alignment.centerLeft,
                                                              child: Container(
                                                                width: 16,
                                                                height: 16,
                                                                decoration: BoxDecoration(
                                                                  color: _addValidityAndDisclosedQty
                                                                      ? colors.colorBlue
                                                                      : Colors.grey[500],
                                                                  shape: BoxShape.circle,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withOpacity(0.25),
                                                                      blurRadius: 3,
                                                                      offset: const Offset(0, 1),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ),

                                              if (_addValidityAndDisclosedQty) ...[
                                                addValidityAndDisclosedQtyOption(theme, context, widget.scripInfo),
                                                const SizedBox(height: 10)
                                              ],
                                            ],

                                            Divider(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider),
                                            // SizedBox(
                                            //     height: priceType == "Market"
                                            //         ? 180
                                            //         : 100)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                // ],
                                if (orderType == "CO - BO") ...[
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.translucent, // Improves touch detection
                                              onTap: () {
                                                setState(() {
                                                  _isCoverOrderEnabled = !_isCoverOrderEnabled;
                                                  _isBracketOrderEnabled = !_isCoverOrderEnabled;

                                                  // updatePriceType();
                                                  // orderInput.chngPriceType(priceType, widget.orderArg.exchange);
                                                  orderInput.chngOrderType(
                                                    orderType,
                                                    _isCoverOrderEnabled,
                                                    _isBracketOrderEnabled,
                                                  );
                                                  marginUpdate();
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    TextWidget.subText(
                                                      text: 'Cover - Only SL',
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                      fw: 0,
                                                    ),
                                                    // Text(
                                                    //   'Cover - Only SL',
                                                    //   style: textStyle(
                                                    //     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                    //     14,
                                                    //     FontWeight.w400,
                                                    //   ),
                                                    // ),
                                                    AnimatedContainer(
                                                      duration: const Duration(milliseconds: 250),
                                                      curve: Curves.easeOut,
                                                      width: 40,
                                                      height: 22,
                                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                                      decoration: BoxDecoration(
                                                        color: _isCoverOrderEnabled
                                                            ? colors.colorBlue.withOpacity(0.25)
                                                            : (theme.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: AnimatedAlign(
                                                        duration: const Duration(milliseconds: 250),
                                                        curve: Curves.easeOut,
                                                        alignment: _isCoverOrderEnabled ? Alignment.centerRight : Alignment.centerLeft,
                                                        child: Container(
                                                          width: 16,
                                                          height: 16,
                                                          decoration: BoxDecoration(
                                                            color: _isCoverOrderEnabled ? colors.colorBlue : Colors.grey[500],
                                                            shape: BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withOpacity(0.25),
                                                                blurRadius: 3,
                                                                offset: const Offset(0, 1),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.translucent, // Improves touch detection
                                              onTap: () {
                                                setState(() {
                                                  _isBracketOrderEnabled = !_isBracketOrderEnabled;
                                                  _isCoverOrderEnabled = !_isBracketOrderEnabled;

                                                  orderInput.chngOrderType(
                                                    orderType,
                                                    _isCoverOrderEnabled,
                                                    _isBracketOrderEnabled,
                                                  );
                                                  marginUpdate();
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    TextWidget.subText(
                                                      text: 'Bracket - TGT / SL',
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                      fw: 0,
                                                    ),
                                                    // Text(
                                                    AnimatedContainer(
                                                      duration: const Duration(milliseconds: 250),
                                                      curve: Curves.easeOut,
                                                      width: 40,
                                                      height: 22,
                                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                                      decoration: BoxDecoration(
                                                        color: _isBracketOrderEnabled
                                                            ? colors.colorBlue.withOpacity(0.25)
                                                            : (theme.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: AnimatedAlign(
                                                        duration: const Duration(milliseconds: 250),
                                                        curve: Curves.easeOut,
                                                        alignment: _isBracketOrderEnabled ? Alignment.centerRight : Alignment.centerLeft,
                                                        child: Container(
                                                          width: 16,
                                                          height: 16,
                                                          decoration: BoxDecoration(
                                                            color: _isBracketOrderEnabled ? colors.colorBlue : Colors.grey[500],
                                                            shape: BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withOpacity(0.25),
                                                                blurRadius: 3,
                                                                offset: const Offset(0, 1),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider),
                                        ],
                                      ),
                                      if (_isBracketOrderEnabled) ...[
                                        const SizedBox(height: 10),
                                        targetOption(theme, context, widget.scripInfo),
                                        const SizedBox(height: 10)
                                      ],

                                      //    if (_isCoverOrderEnabled) ...[
                                      stopLossOption(theme, context, widget.scripInfo),
                                      const SizedBox(height: 10),

                                      if (_isBracketOrderEnabled) ...[
                                        trailingTicksOption(theme, context, widget.scripInfo),
                                      ],
                                      // const SizedBox(height: 30),
                                      // ],
                                      // Text( "Cover: ${_isCoverOrderEnabled} Bracket: ${_isBracketOrderEnabled}"),
                                      // Text("Order Type: ${orderType}"),
                                    ],
                                  ),
                                ],

                                // if (priceType == "Market" || priceType == "SL MKT") ...[
                                //   const SizedBox(height: 8),
                                //   Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 16),
                                //     child: Text(
                                //         "A market order carries the risk of execution at a less advantageous price",
                                //         style: textStyle(
                                //             const Color(0xff666666),
                                //             12,
                                //             FontWeight.w500)),
                                //   ),
                                // ],
                                // Divider(
                                //     color: theme.isDarkMode
                                //         ? colors.darkColorDivider
                                //         : colors.colorDivider)
                              ],
                            ]
                          ],
                        ]),
                      ),
                      if (internet.connectionStatus == ConnectivityResult.none) ...[const NoInternetWidget()]
                    ]),
                  ),
                  bottomNavigationBar: internet.connectionStatus == ConnectivityResult.none
                      ? const NoInternetWidget()
                      : SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                  if (orderType != "GTT" && orderType != "SIP") ...[
                                    if (orderType == "MTF" && !_isMTFEnabled) ...[
                                      const SizedBox.shrink()
                                    ] else ...[
                                      Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              color: theme.isDarkMode ? colors.darkGrey : const Color(0xfffafbff),
                                              border: Border(
                                                  top: BorderSide(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider),
                                                  bottom: BorderSide(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider))),
                                          padding: const EdgeInsets.only(left: 16.0, right: 3, top: 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // if (isAvbSecu) ...[
                                              //   AnimatedBuilder(
                                              //     animation: anibuildctrl,
                                              //     builder: (context, child) {
                                              //       return Transform.translate(
                                              //         offset: Offset(
                                              //             _shakeAnimation.value *
                                              //                 sin(DateTime.now().millisecondsSinceEpoch * 0.01),
                                              //             0),
                                              //         child: GestureDetector(
                                              //           onTap: () {
                                              //             final dynamic tooltip = tooltipKey.currentState;
                                              //             tooltip?.ensureTooltipVisible(); // Manually show tooltip on tap
                                              //           },
                                              //           child: AnimatedContainer(
                                              //               duration: const Duration(milliseconds: 300),
                                              //               curve: Curves.easeInCubic,
                                              //               margin: const EdgeInsets.only(right: 16, top: 16, bottom: 0),
                                              //               padding: const EdgeInsets.all(0),
                                              //               decoration: BoxDecoration(
                                              //                 color: const Color(0xffFFF6E6),
                                              //                 borderRadius: BorderRadius.circular(6),
                                              //                 border: Border.all(
                                              //                   color: anibuildctrl.isAnimating
                                              //                       ? colors.darkred
                                              //                       : const Color(0xffFFF6E6), // Border color
                                              //                   width: anibuildctrl.isAnimating
                                              //                       ? 1.0
                                              //                       : 0.0, // Border width (1px)
                                              //                 ),
                                              //                 boxShadow: anibuildctrl.isAnimating
                                              //                     ? [
                                              //                         BoxShadow(
                                              //                           color: colors.darkred.withOpacity(0.6),
                                              //                           blurRadius: 10,
                                              //                           spreadRadius: 3,
                                              //                           offset: const Offset(0, 0),
                                              //                         ),
                                              //                       ]
                                              //                     : [],
                                              //               ),
                                              //               child: Row(
                                              //                 mainAxisAlignment: MainAxisAlignment.start,
                                              //                 children: [
                                              //                   IconButton(
                                              //                       onPressed: () {
                                              //                         setState(() {
                                              //                           isSecu = !isSecu;
                                              //                         });
                                              //                       },
                                              //                       icon: SvgPicture.asset(
                                              //                           isSecu ? assets.checkedbox : assets.checkbox)),
                                              //                   Expanded(
                                              //                       // Ensures text takes available space and wraps
                                              //                       child: Column(
                                              //                     crossAxisAlignment: CrossAxisAlignment.start,
                                              //                     children: [
                                              //                       RichText(
                                              //                         text: TextSpan(
                                              //                           style: textStyle(
                                              //                             const Color(0xffB37702),
                                              //                             13,
                                              //                             FontWeight.w500,
                                              //                           ),
                                              //                           children: [
                                              //                             const WidgetSpan(
                                              //                               child: Icon(Icons.warning_outlined,
                                              //                                   color: Color.fromARGB(190, 255, 170, 0),
                                              //                                   size: 16),
                                              //                             ),
                                              //                             const TextSpan(
                                              //                                 text:
                                              //                                     " Exchange surveillance active — confirm to proceed with your order."),
                                              //                             WidgetSpan(
                                              //                               child: Tooltip(
                                              //                                 key: tooltipKey,
                                              //                                 // enableTapToDismiss: false,
                                              //                                 preferBelow: false,
                                              //                                 message: quotemsg,
                                              //                                 textStyle: const TextStyle(
                                              //                                   color: Colors.white,
                                              //                                   fontSize: 13,
                                              //                                 ),
                                              //                                 padding: const EdgeInsets.symmetric(
                                              //                                     vertical: 8, horizontal: 16),
                                              //                                 margin: const EdgeInsets.symmetric(
                                              //                                     horizontal: 16),
                                              //                                 decoration: BoxDecoration(
                                              //                                   color: Colors.black,
                                              //                                   borderRadius: BorderRadius.circular(8),
                                              //                                 ),
                                              //                                 child: Text(
                                              //                                   " Know more",
                                              //                                   style: textStyle(
                                              //                                     !theme.isDarkMode
                                              //                                         ? colors.colorBlue
                                              //                                         : colors.colorLightBlue,
                                              //                                     13,
                                              //                                     FontWeight.w500,
                                              //                                   ),
                                              //                                 ),
                                              //                               ),
                                              //                             ),
                                              //                           ],
                                              //                         ),
                                              //                         softWrap: true,
                                              //                       ),
                                              //                     ],
                                              //                   ))
                                              //                 ],
                                              //               )),
                                              //         ),
                                              //       );
                                              //     },
                                              //   ),
                                              // ],
                                              SingleChildScrollView(
                                                padding: const EdgeInsets.all(0),
                                                scrollDirection: Axis.horizontal,
                                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                  Row(children: [
                                                    CustomWidgetButton(
                                                        onPress: internet.connectionStatus == ConnectivityResult.none
                                                            ? () {}
                                                            : () {
                                                                marginUpdate();
                                                                BrokerageInput brokerageInput = BrokerageInput(
                                                                    exch: "${widget.scripInfo.exch}",
                                                                    prc: priceCtrl.text,
                                                                    prd: orderInput.orderType,
                                                                    qty: "${widget.scripInfo.ls}",
                                                                    trantype: isBuy! ? "B" : "S",
                                                                    tsym: "${widget.scripInfo.tsym}");
                                                                ref.read(orderProvider).fetchGetBrokerage(brokerageInput, context);

                                                                showModalBottomSheet(
                                                                    useSafeArea: true,
                                                                    isScrollControlled: true,
                                                                    shape: const RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return const MarginDetailsBottomsheet();
                                                                    });
                                                              },
                                                        widget: Row(children: [
                                                          TextWidget.paraText(
                                                            text: "Required ",
                                                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                            theme: theme.isDarkMode,
                                                            fw: 0,
                                                          ),

                                                          TextWidget.paraText(
                                                            text:
                                                                "${orderProvide.orderMarginModel == null ? 0.00 : orderProvide.orderMarginModel!.ordermargin}  + ${orderProvide.getBrokerageModel == null ? 0.00 : orderProvide.getBrokerageModel!.brkageAmt ?? 0.00}",
                                                            theme: theme.isDarkMode,
                                                            color: !theme.isDarkMode ? colors.colorBlue : colors.colorLightBlue,
                                                            fw: 2,
                                                          ),

                                                          // Text(
                                                          //     "${orderProvide.orderMarginModel == null ? 0.00 : orderProvide.orderMarginModel!.ordermargin}  + ${orderProvide.getBrokerageModel == null ? 0.00 : orderProvide.getBrokerageModel!.brkageAmt ?? 0.00}",
                                                          //     style: textStyle(
                                                          //         !theme.isDarkMode ? colors.colorBlue : colors.colorLightBlue,
                                                          //         12,
                                                          //         FontWeight.bold)),
                                                          Icon(Icons.arrow_drop_down,
                                                              color: !theme.isDarkMode ? colors.colorBlue : colors.colorLightBlue)
                                                        ])),

                                                    const SizedBox(width: 16),
                                                    Row(
                                                      children: [
                                                        TextWidget.paraText(
                                                          text: "Balance ",
                                                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                          theme: theme.isDarkMode,
                                                          fw: 0,
                                                        ),
                                                        // const SizedBox(width: 4),
                                                        TextWidget.paraText(
                                                          text: " ${clientFundDetail?.avlMrg ?? ''}",
                                                          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                          theme: theme.isDarkMode,
                                                          fw: 0,
                                                        ),
                                                        const SizedBox(width: 4),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 8),
                                                    orderProvide.orderMarginModel != null
                                                        ? orderProvide.orderMarginModel!.remarks == "Insufficient Balance"
                                                            ? InkWell(
                                                                onTap: () {
                                                                  ref.read(transcationProvider).fetchValidateToken(context);
                                                                  Future.delayed(const Duration(milliseconds: 100), () async {
                                                                    await trancation.ip();
                                                                    await trancation.fetchupiIdView(
                                                                        trancation.bankdetails!.dATA![trancation.indexss][1],
                                                                        trancation.bankdetails!.dATA![trancation.indexss][2]);
                                                                    await trancation.fetchcwithdraw(context);
                                                                  });

                                                                  trancation.changebool(true);
                                                                  Navigator.pushNamed(context, Routes.fundscreen, arguments: trancation);
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    // Red circular icon with white exclamation mark
                                                                    // Container(
                                                                    //   width: 20,
                                                                    //   height: 20,
                                                                    //   decoration: const BoxDecoration(
                                                                    //     color: Colors.white,
                                                                    //     shape: BoxShape.circle,
                                                                    //   ),
                                                                    //   child: const Center(
                                                                    //     child: Icon(
                                                                    //       Icons.error, // Exclamation icon
                                                                    //       color: Colors.red,
                                                                    //       size: 20,
                                                                    //     ),
                                                                    //   ),
                                                                    // ),

                                                                    // "+ Add fund" text in blue
                                                                    TextWidget.paraText(
                                                                        text: '+ Add fund',
                                                                        color: theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight,
                                                                        theme: theme.isDarkMode,
                                                                        fw: 2),
                                                                    const SizedBox(width: 8),
                                                                  ],
                                                                ),
                                                              )
                                                            : const SizedBox()
                                                        : const SizedBox(),

                                                            // CustomWidgetButton(
                                                            //     onPress: internet
                                                            //                 .connectionStatus ==
                                                            //             ConnectivityResult
                                                            //                 .none
                                                            //         ? () {}
                                                            //         : () {
                                                            //             BrokerageInput brokerageInput = BrokerageInput(
                                                            //                 exch:"${widget.scripInfo.exch}",
                                                            //                 prc: priceCtrl.text,
                                                            //                 prd: orderInput.orderType,
                                                            //                 qty:"${widget.scripInfo.ls}",
                                                            //                 trantype: isBuy!? "B": "S",
                                                            //                 tsym:"${widget.scripInfo.tsym}");
                                                            //                 ref.read(orderProvider)
                                                            //                 .fetchGetBrokerage(brokerageInput,context);
                                                            //             showModalBottomSheet(useSafeArea:true,
                                                            //                 isScrollControlled:true,
                                                            //                 shape: const RoundedRectangleBorder(
                                                            //                 borderRadius: BorderRadius.vertical(
                                                            //                 top: Radius.circular(16))),
                                                            //                 context:context,
                                                            //                 builder:(context) {
                                                            //                   return const ChargesDetailsBottomsheet();
                                                            //                 });
                                                            //           },
                                                            //     widget: Row(
                                                            //         children: [
                                                            //           Text(
                                                            //               "Charges: ",
                                                            //               style: textStyle(
                                                            //                   const Color(
                                                            //                       0xff666666),
                                                            //                   12,
                                                            //                   FontWeight
                                                            //                       .w500)),
                                                            //           Text(
                                                            //               "₹${orderProvide.getBrokerageModel == null ? 0.00 : orderProvide.getBrokerageModel!.brkageAmt ?? 0.00}",
                                                            //               style: textStyle(
                                                            //                   !theme.isDarkMode
                                                            //                       ? colors.colorBlue
                                                            //                       : colors.colorLightBlue,
                                                            //                   12,
                                                            //                   FontWeight.w600)),
                                                            //           Icon(
                                                            //               Icons
                                                            //                   .arrow_drop_down,
                                                            //               color: !theme.isDarkMode
                                                            //                   ? colors
                                                            //                       .colorBlue
                                                            //                   : colors
                                                            //                       .colorLightBlue)
                                                            //         ]))
                                                          ]),
                                                          IconButton(
                                                              onPressed:
                                                                  internet.connectionStatus == ConnectivityResult.none
                                                                      ? null
                                                                      : () {
                                                                          marginUpdate();
                                                                        },
                                                              icon: SvgPicture.asset(assets.reloadIcon)),
                                                        ]),
                                                  ),
                                                ],
                                              ))
                                        ],
                                      ],
                                      if (orderType == "MTF" && !_isMTFEnabled) ...[
                                        const SizedBox.shrink()
                                      ] else ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          width: MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                            onPressed: internet.connectionStatus == ConnectivityResult.none
                                                ? null
                                                : () async { ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                if (!orderProvide.orderloader) {
                                                  if (orderType == "SIP") {
                                                        if (sipqtyctrl.text.isEmpty || sipqtyctrl.text == "0") {
                                                          warningMessage(
                                                              context,
                                                              sipqtyctrl.text.isEmpty
                                                                  ? "Quantity cannot be empty"
                                                                  : "Quantity cannot be 0");
                                                        } else if (sip.numberofSips.text.isEmpty ||
                                                            sip.numberofSips.text == "0") {
                                                          warningMessage(
                                                              context,
                                                              sip.numberofSips.text.isEmpty
                                                                  ? "Number of SIP cannot be empty"
                                                                  : "Number of SIP cannot be 0");
                                                        } else {
                                                          bool sipQty =
                                                              int.tryParse(sipqtyctrl.text) != null ? true : false;
                                                          bool numberOfSips =
                                                              int.tryParse(sip.numberofSips.text) != null
                                                                  ? true
                                                                  : false;

                                                      if (!sipQty || !numberOfSips) {
                                                        warningMessage(context, "Provide a valid value for SIP");
                                                      } else {
                                                        sipOrder(ref);
                                                      }
                                                    }
                                                  } else if (orderType == "GTT") {
                                                    if (orderInput.disableGTTCond) {
                                                      if ((orderInput.val1Ctrl.text.isNotEmpty &&
                                                              orderInput.val2Ctrl.text.isNotEmpty &&
                                                              orderInput.priceCtrl.text.isNotEmpty &&
                                                              orderInput.ocoPriceCtrl.text.isNotEmpty &&
                                                              orderInput.ocoQtyCtrl.text.isNotEmpty) &&
                                                          orderInput.qtyCtrl.text.isNotEmpty &&
                                                          double.tryParse(orderInput.val1Ctrl.text) != null &&
                                                          double.tryParse(orderInput.val1Ctrl.text)! > 0 &&
                                                          double.tryParse(orderInput.val2Ctrl.text) != null &&
                                                          double.tryParse(orderInput.val2Ctrl.text)! > 0 &&
                                                          double.tryParse(orderInput.qtyCtrl.text) != null &&
                                                          double.tryParse(orderInput.qtyCtrl.text)! > 0 &&
                                                          double.tryParse(orderInput.ocoQtyCtrl.text) != null &&
                                                          double.tryParse(orderInput.ocoQtyCtrl.text)! > 0 &&
                                                          (orderInput.priceCtrl.text == "Market" ||
                                                              (double.tryParse(orderInput.priceCtrl.text) != null &&
                                                                  double.tryParse(orderInput.priceCtrl.text)! > 0)) &&
                                                          (orderInput.ocoPriceCtrl.text == "Market" ||
                                                              (double.tryParse(orderInput.ocoPriceCtrl.text) != null &&
                                                                  double.tryParse(orderInput.ocoPriceCtrl.text)! > 0))) {
                                                        // if (orderInput
                                                        //             .actOcoPrcType == "SL Limit" ||
                                                        //     orderInput
                                                        //             .actOcoPrcType == "SL MKT") {
                                                        //   if (orderInput
                                                        //       .ocoTrgPrcCtrl
                                                        //       .text
                                                        //       .isEmpty) {
                                                        //     ScaffoldMessenger.of(
                                                        //             context)
                                                        //         .showSnackBar(warningMessage(
                                                        //             context,
                                                        //             "Trigger cannot be empty"));
                                                        //   } else {
                                                        //     prepareToPlaceOCOOrder(orderInput);
                                                        //   }
                                                        // }
                                                        // else {
                                                        double ltp = double.parse(widget.orderArg.ltp ?? "0.00");
                                                        double val1 = double.parse(orderInput.val1Ctrl.text);
                                                        double val2 = double.parse(orderInput.val2Ctrl.text);

                                                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                            if (val1 > ltp && val2 < ltp) {
                                                              prepareToPlaceOCOOrder(orderInput);
                                                            } else {
                                                              warningMessage(
                                                                  context,
                                                                  val1 <= ltp
                                                                      ? "Target trigger price cannot be less than LTP"
                                                                      : val2 >= ltp
                                                                          ? "Stoploss trigger price cannot be greater than LTP"
                                                                          : "Target trigger price cannot be equal to LTP");
                                                            }
                                                            // }
                                                          } else {
                                                          if(orderInput.val1Ctrl.text.isEmpty){
                                                           warningMessage(context, "Target trigger price cannot be empty");
                                                         }
                                                         else if(double.parse(orderInput.val1Ctrl.text) <= 0){
                                                           warningMessage(context, "Target trigger price cannot be 0");
                                                         }
                                                         else if(orderInput.qtyCtrl.text.isEmpty){
                                                           warningMessage(context, "Quantity cannot be empty");
                                                         }
                                                         else if(double.parse(orderInput.qtyCtrl.text) <= 0){
                                                           warningMessage(context, "Quantity cannot be 0");
                                                         }
                                                         else if(orderInput.priceCtrl.text.isEmpty){
                                                           warningMessage(context, "Price cannot be empty");
                                                         }
                                                          else if (orderInput.priceCtrl.text != "Market" &&
                                                          double.tryParse(orderInput.priceCtrl.text) != null &&
                                                          double.parse(orderInput.priceCtrl.text) <= 0) {
                                                            warningMessage(context, "Price cannot be 0");
                                                          }
                                                         else if(orderInput.val2Ctrl.text.isEmpty){
                                                           warningMessage(context, "Stoploss trigger price cannot be empty");
                                                         }
                                                         else if(double.parse(orderInput.val2Ctrl.text) <= 0){
                                                           warningMessage(context, "Stoploss trigger price cannot be 0");
                                                         }
                                                         else if(orderInput.ocoQtyCtrl.text.isEmpty){
                                                            warningMessage(context, "OCO quantity cannot be empty");
                                                         }
                                                         else if(double.parse(orderInput.ocoQtyCtrl.text) <= 0){
                                                           warningMessage(context, "OCO quantity cannot be 0");
                                                         }
                                                         else if(orderInput.ocoPriceCtrl.text.isEmpty){
                                                           warningMessage(context, "OCO price cannot be empty");
                                                         }
                                                        else if (orderInput.ocoPriceCtrl.text != "Market") {
                                                            final ocoPrice = double.tryParse(orderInput.ocoPriceCtrl.text);
                                                            if (ocoPrice == null) {
                                                              warningMessage(context, "Invalid OCO price");
                                                            } else if (ocoPrice <= 0) {
                                                              warningMessage(context, "OCO price cannot be 0");
                                                            }
                                                          }
                                                         else {
                                                           warningMessage(context, "Enter all Input fields");
                                                         }
                                                          }
                                                        } else {
                                                          if ((orderInput.val1Ctrl.text.isNotEmpty &&
                                                                  orderInput.priceCtrl.text.isNotEmpty) &&
                                                              orderInput.qtyCtrl.text.isNotEmpty 
                                                              && double.parse(orderInput.val1Ctrl.text) > 0 && 
                                                              double.parse(orderInput.qtyCtrl.text) > 0 && (orderInput.priceCtrl.text == "Market" || 
                                                              double.parse(orderInput.priceCtrl.text) > 0)) {
                                                            // if (orderInput
                                                            //             .actPrcType == "SL Limit" ||
                                                            //     orderInput
                                                            //             .actPrcType == "SL MKT") {
                                                            //   if (orderInput
                                                            //       .trgPrcCtrl
                                                            //       .text
                                                            //       .isEmpty) {
                                                            //     ScaffoldMessenger.of(
                                                            //             context)
                                                            //         .showSnackBar(warningMessage(
                                                            //             context,
                                                            //             "Trigger cannot be empty"));
                                                            //   } else {
                                                            //     prepareToPlaceGttOrder(orderInput);
                                                            //   }
                                                            // } else {

                                                        double ltp = double.parse(widget.orderArg.ltp ?? "0.00");
                                                        double val1 = double.parse(orderInput.val1Ctrl.text);
                                                        // double val2 = double.parse(orderInput.val2Ctrl.text);

                                                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                            if (val1 > ltp) {
                                                              orderInput.chngCond("Greater than");
                                                              orderInput.chngAlert("LTP");
                                                              prepareToPlaceGttOrder(orderInput);
                                                            } else if (val1 < ltp) {
                                                              orderInput.chngCond("Less than");
                                                              orderInput.chngAlert("LTP");
                                                              prepareToPlaceGttOrder(orderInput);
                                                            } else {
                                                              warningMessage(
                                                                  context, "Target trigger price cannot be equal to LTP");
                                                            }
                                                            // }
                                                          } else {
                                                          if(orderInput.val1Ctrl.text.isEmpty){
                                                           warningMessage(context, "Target trigger price cannot be empty");
                                                         }
                                                         else if(double.parse(orderInput.val1Ctrl.text) <= 0){
                                                           warningMessage(context, "Target trigger price cannot be 0");
                                                         }
                                                         else if(orderInput.qtyCtrl.text.isEmpty){
                                                           warningMessage(context, "Quantity cannot be empty");
                                                         }
                                                         else if(double.parse(orderInput.qtyCtrl.text) <= 0){
                                                           warningMessage(context, "Quantity cannot be 0");
                                                         }
                                                         else if(orderInput.priceCtrl.text.isEmpty){
                                                           warningMessage(context, "Price cannot be empty");
                                                         }
                                                          else if(double.parse(orderInput.priceCtrl.text) <= 0){
                                                           warningMessage(context, "Price cannot be 0");
                                                         }
                                                         else if(orderInput.val2Ctrl.text.isEmpty){
                                                           warningMessage(context, "Stoploss trigger price cannot be empty");
                                                         }
                                                         else if(double.parse(orderInput.val2Ctrl.text) <= 0){
                                                           warningMessage(context, "Stoploss trigger price cannot be 0");
                                                         }
                                                         else if(orderInput.ocoQtyCtrl.text.isEmpty){
                                                            warningMessage(context, "OCO quantity cannot be empty");
                                                         }
                                                         else if(double.parse(orderInput.ocoQtyCtrl.text) <= 0){
                                                           warningMessage(context, "OCO quantity cannot be 0");
                                                         }
                                                         else if(orderInput.ocoPriceCtrl.text.isEmpty){
                                                           warningMessage(context, "OCO price cannot be empty");
                                                         }
                                                         else if(double.parse(orderInput.ocoPriceCtrl.text) <= 0){
                                                           warningMessage(context, "OCO price cannot be 0");
                                                         }
                                                         else {
                                                           warningMessage(context, "Enter all Input fields");
                                                         }
                                                          }
                                                        }
                                                  } else {
                                                        setState(() {
                                                          if (frezQty == 0) {
                                                            quantity = int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                ? "0"
                                                                : getFinalQuantity(qtyCtrl.text));
                                                            // frezQty;
                                                          } else {
                                                            quantity = int.parse(
                                                                    getFinalQuantity(qtyCtrl.text).isEmpty
                                                                        ? "0"
                                                                        : getFinalQuantity(qtyCtrl.text)) ~/ frezQty;
                                                          }
                                                          reminder = int.parse(
                                                                  getFinalQuantity(qtyCtrl.text).isEmpty
                                                                      ? "0"
                                                                      : getFinalQuantity(qtyCtrl.text)) - (frezQty * quantity);
                                                          maxQty = frezQty * frezQtyOrderSliceMaxLimit;
                                                        });
                                                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                        if (getFinalQuantity(qtyCtrl.text).trim().isEmpty ||priceCtrl.text.trim().isEmpty) {
                                                          String fieldName = (_isStock)
                                                              ? (_isQtyToAmount ? "Amount" : "Quantity")
                                                              : (_isLotToQty ? "Quantity" : "Lot");
                                                          warningMessage(context, getFinalQuantity(qtyCtrl.text).isEmpty
                                                                  ? "$fieldName cannot be empty"
                                                                  : "Price cannot be empty");
                                                        } else if ((getFinalQuantity(qtyCtrl.text).trim()) =="0" ||priceCtrl.text.trim() == "0") {
                                                          String fieldName = (_isStock)
                                                              ? (_isQtyToAmount ? "Amount" : "Quantity")
                                                              : (_isLotToQty ? "Quantity" : "Lot");
                                                          warningMessage(context,
                                                              getFinalQuantity(qtyCtrl.text) == "0"
                                                                  ? (_isStock)
                                                                      ? (_isQtyToAmount
                                                                          ? (qtyCtrl.text != "0" ? "Minimum Allowed Amount should be greater than ${widget.orderArg.ltp}" : "Amount cannot be 0")
                                                                          : "Quantity cannot be 0")
                                                                      : "$fieldName cannot be 0"
                                                                  : "Price cannot be 0");
                                                        } else if (frezQty > lotSize && int.parse(getFinalQuantity(qtyCtrl.text).trim()) > frezQtyOrderSliceMaxLimit * frezQty) {
                                                          warningMessage(context,
                                                              "Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit * frezQty}");
                                                        } else if ((priceType == "Limit" || priceType == "SL Limit") &&
                                                            _hasValidCircuitBreakerValues &&
                                                            ((double.parse(ordPrice) < double.parse(widget.scripInfo.lc!)) ||
                                                                (double.parse(ordPrice) > double.parse(widget.scripInfo.uc!)))) {
                                                          warningMessage(
                                                              context,
                                                              double.parse(ordPrice) < double.parse(widget.scripInfo.lc!)
                                                                  ? "Price cannot be lesser than Lower Circuit Limit ${widget.scripInfo.lc}"
                                                                  : "Price cannot be greater than Upper Circuit Limit ${widget.scripInfo.uc}");
                                                        } else if ((orderType == "Delivery" || orderType == "Intraday") && (priceType == "SL Limit" || priceType == "SL MKT")) {
                                                              if (triggerPriceCtrl.text.isEmpty || triggerPriceCtrl.text == "0") {
                                                                warningMessage(context,
                                                                    triggerPriceCtrl.text.isEmpty ? "Trigger cannot be empty" : "Trigger cannot be 0");
                                                              } else {
                                                                if (isBuy!) {
                                                                  if (priceType == "SL MKT") {
                                                                    if (double.parse(triggerPriceCtrl.text) < double.parse(widget.orderArg.ltp ?? "0.00")) {
                                                                      warningMessage(context, "Trigger should be greater than LTP");
                                                                    } else if (_hasValidCircuitBreakerValues &&
                                                                        double.parse(triggerPriceCtrl.text) > double.parse(widget.scripInfo.uc!)) {
                                                                      warningMessage(context,
                                                                          "Trigger cannot be greater than upper circuit limit of ${widget.scripInfo.uc}");
                                                                    } else {
                                                                      if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                                  ? "0"
                                                                                  : getFinalQuantity(qtyCtrl.text)) >
                                                                              frezQty &&
                                                                          widget.scripInfo.frzqty != null)) {
                                                                        placeOrder(orderInput, true, theme);
                                                                      } else {
                                                                        placeOrder(orderInput, false, theme);
                                                                      }
                                                                    }
                                                                  } else {
                                                                    if (_hasValidCircuitBreakerValues &&
                                                                        double.parse(triggerPriceCtrl.text) < double.parse(widget.scripInfo.lc!)) {
                                                                      warningMessage(context,
                                                                          "Trigger cannot be lesser than lower circuit limit of ${widget.scripInfo.lc}");
                                                                    } else if (double.parse(ordPrice) < double.parse(triggerPriceCtrl.text)) {
                                                                      warningMessage(context, "Trigger should be less than price");
                                                                    } else if (_hasValidCircuitBreakerValues &&
                                                                        double.parse(triggerPriceCtrl.text) > double.parse(widget.scripInfo.uc!)) {
                                                                      warningMessage(context,
                                                                          "Trigger cannot be greater than upper circuit limit of ${widget.scripInfo.uc}");
                                                                    } else {
                                                                      if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                                  ? "0"
                                                                                  : getFinalQuantity(qtyCtrl.text)) >
                                                                              frezQty &&
                                                                          widget.scripInfo.frzqty != null)) {
                                                                        placeOrder(orderInput, true, theme);
                                                                      } else {
                                                                        placeOrder(orderInput, false, theme);
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  if (priceType == "SL MKT") {
                                                                    if (double.parse(triggerPriceCtrl.text) > double.parse(widget.orderArg.ltp ?? "0.00")) {
                                                                      warningMessage(context, "Trigger should be lesser than LTP");
                                                                    } else if (_hasValidCircuitBreakerValues &&
                                                                        double.parse(triggerPriceCtrl.text) < double.parse(widget.scripInfo.lc!)) {
                                                                      warningMessage(context,
                                                                          "Trigger cannot be lesser than lower circuit limit of ${widget.scripInfo.lc ?? 0.00}");
                                                                    } else {
                                                                      if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                                  ? "0"
                                                                                  : getFinalQuantity(qtyCtrl.text)) >
                                                                              frezQty &&
                                                                          widget.scripInfo.frzqty != null)) {
                                                                        placeOrder(orderInput, true, theme);
                                                                      } else {
                                                                        placeOrder(orderInput, false, theme);
                                                                      }
                                                                    }
                                                                  } else {
                                                                    if (_hasValidCircuitBreakerValues &&
                                                                        double.parse(triggerPriceCtrl.text) > double.parse(widget.scripInfo.uc!)) {
                                                                      warningMessage(context,
                                                                          "Trigger cannot be greater than upper circuit limit of ${widget.scripInfo.uc ?? 0.00}");
                                                                    } else if (double.parse(ordPrice) > double.parse(triggerPriceCtrl.text)) {
                                                                      warningMessage(context, "Trigger should be greater than price");
                                                                    } else if (_hasValidCircuitBreakerValues &&
                                                                        double.parse(triggerPriceCtrl.text) < double.parse(widget.scripInfo.lc!)) {
                                                                      warningMessage(context,
                                                                          "Trigger cannot be lesser than lower circuit limit of ${widget.scripInfo.lc ?? 0.00}");
                                                                    } else {
                                                                      if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                                  ? "0"
                                                                                  : getFinalQuantity(qtyCtrl.text)) >
                                                                              frezQty &&
                                                                          widget.scripInfo.frzqty != null)) {
                                                                        placeOrder(orderInput, true, theme);
                                                                      } else {
                                                                        placeOrder(orderInput, false, theme);
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                        } else if (_isCoverOrderEnabled && orderType == "CO - BO" && (priceType == "Limit" || priceType == "Market")) {
                                                              if (stopLossCtrl.text.isEmpty || stopLossCtrl.text == "0") {
                                                                warningMessage(
                                                                    context, stopLossCtrl.text.isEmpty ? "Stoploss cannot be empty" : "Stoploss cannot be 0");
                                                              } else {
                                                                if (isBuy!) {
                                                                  if (_hasValidCircuitBreakerValues &&
                                                                      (double.parse(ordPrice) - double.parse(stopLossCtrl.text)) <
                                                                          double.parse(widget.scripInfo.lc!)) {
                                                                    warningMessage(context,
                                                                        "Price(Order price - Stoploss = ${(double.parse(ordPrice) - double.parse(stopLossCtrl.text)).toStringAsFixed(2)}) Stoploss cannot be lower than ${widget.scripInfo.lc}");
                                                                  } else {
                                                                    if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                                ? "0"
                                                                                : getFinalQuantity(qtyCtrl.text)) >
                                                                            frezQty &&
                                                                        widget.scripInfo.frzqty != null)) {
                                                                      placeOrder(orderInput, true, theme);
                                                                    } else {
                                                                      placeOrder(orderInput, false, theme);
                                                                    }
                                                                  }
                                                                } else {
                                                                  if (_hasValidCircuitBreakerValues &&
                                                                      (double.parse(ordPrice) + double.parse(stopLossCtrl.text)) >
                                                                          double.parse(widget.scripInfo.uc!)) {
                                                                    warningMessage(context,
                                                                        "Price(Order price + Stoploss = ${(double.parse(ordPrice) + double.parse(stopLossCtrl.text))}) Stoploss cannot be greater than ${widget.scripInfo.uc}");
                                                                  } else {
                                                                    if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                                ? "0"
                                                                                : getFinalQuantity(qtyCtrl.text)) >
                                                                            frezQty &&
                                                                        widget.scripInfo.frzqty != null)) {
                                                                      placeOrder(orderInput, true, theme);
                                                                    } else {
                                                                      placeOrder(orderInput, false, theme);
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                        }
                                                        else if (_isCoverOrderEnabled && orderType == "CO - BO" && (priceType == "SL Limit")) {
                                                                double userOrderPrice = double.tryParse(ordPrice)??0;
                                                                double userStopLoss = double.tryParse(stopLossCtrl.text)??0;
                                                                double userTriggerPrice = double.tryParse(triggerPriceCtrl.text)??0;
                                                                double lc = double.tryParse(widget.scripInfo.lc??"0")??0;
                                                                double uc = double.tryParse(widget.scripInfo.uc??"0")??0;

                                                            if (stopLossCtrl.text.isEmpty ||stopLossCtrl.text =="0") {
                                                                    warningMessage(
                                                                          context,
                                                                          stopLossCtrl.text.isEmpty
                                                                              ? "Stoploss cannot be empty"
                                                                              : "Stoploss cannot be 0");

                                                            } else if (isBuy! && (userOrderPrice - userStopLoss) < lc) {
                                                                    warningMessage(
                                                                          context,
                                                                          "Price(Order price - Stoploss = ${(double.parse(ordPrice) - double.parse(stopLossCtrl.text)).toStringAsFixed(2)}) Stoploss cannot be lower than ${widget.scripInfo.lc ?? 0.00}");

                                                            } else if (!isBuy! && (userOrderPrice + userStopLoss) > uc) {
                                                                    warningMessage(
                                                                          context,
                                                                          "Price(Order price + Stoploss = ${(double.parse(ordPrice) + double.parse(stopLossCtrl.text))}) Stoploss cannot be greater than ${widget.scripInfo.uc ?? 0.00}");

                                                            } else if ((triggerPriceCtrl.text.isEmpty ||triggerPriceCtrl.text =="0") && priceType =="SL Limit") {
                                                                  warningMessage(
                                                                      context,
                                                                      triggerPriceCtrl.text.isEmpty
                                                                          ? "Trigger cannot be empty"
                                                                          : "Trigger cannot be 0");
                                                            } else {
                                                              if (isBuy!) {
                                                                if (userTriggerPrice < lc) {
                                                                  warningMessage(context, "Trigger cannot be lesser than lower circuit limit of $lc");

                                                                } else if (userOrderPrice < userTriggerPrice) {
                                                                  warningMessage(context, "Trigger should be less than price");

                                                                } else if (userTriggerPrice > uc) {
                                                                  warningMessage(context, "Trigger cannot be greater than upper circuit limit of $uc");

                                                                } else {
                                                                  if (int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                            ? "0" : getFinalQuantity(qtyCtrl.text)) >
                                                                            frezQty && widget.scripInfo.frzqty != null) {
                                                                        placeOrder(
                                                                            orderInput,
                                                                            true,
                                                                            theme);
                                                                  } else {
                                                                        placeOrder(
                                                                            orderInput,
                                                                            false,
                                                                            theme);
                                                                  }
                                                                }
                                                              } else {
                                                                if (userTriggerPrice > uc) {
                                                                  warningMessage(context,"Trigger cannot be greater than upper circuit limit of $uc");

                                                                } else if (userOrderPrice > userTriggerPrice) {
                                                                        warningMessage(context,"Trigger should be greater than price");
                                                                        
                                                                } else if (userTriggerPrice < lc) {
                                                                        warningMessage(context,"Trigger cannot be lesser than lower circuit limit of ${widget.scripInfo.lc ?? 0.00}");
                                                                } else {
                                                                  if (int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                        ? "0" : getFinalQuantity(qtyCtrl.text)) >
                                                                        frezQty &&  widget.scripInfo.frzqty != null) {

                                                                        placeOrder(
                                                                            orderInput,
                                                                            true,
                                                                            theme);
                                                                  } else {
                                                                        placeOrder(
                                                                            orderInput,
                                                                            false,
                                                                            theme);
                                                                  }
                                                                }
                                                              }
                                                            }
                                                        }
                                                        else if (_isBracketOrderEnabled && orderType == "CO - BO" && (priceType == "Limit" || priceType == "Market")) {
                                                              double tickSize = double.parse(widget.scripInfo.ti.toString());
                                                              double enteredValue = double.tryParse(trailingTicksCtrl.text) ?? 0;
                                                              double trailTicksQuotient = enteredValue / tickSize;
                                                              double trailTicksRemainder = (trailTicksQuotient - trailTicksQuotient.round()).abs();

                                                              if (stopLossCtrl.text.isEmpty || targetCtrl.text.isEmpty) {
                                                                warningMessage(context, "${targetCtrl.text.isEmpty ? "Target" : "Stoploss"} cannot be empty");
                                                              } else if (double.parse(stopLossCtrl.text) <= 0 || double.parse(targetCtrl.text) <= 0) {
                                                                warningMessage(
                                                                    context, "${double.parse(targetCtrl.text) <= 0 ? "Target" : "Stoploss"} cannot be 0");
                                                              } else if (isBuy! &&
                                                                  _hasValidCircuitBreakerValues &&
                                                                  (double.parse(ordPrice) - double.parse(stopLossCtrl.text)) <
                                                                      double.parse(widget.scripInfo.lc!)) {
                                                                warningMessage(context,
                                                                    "Price(Order price - Stoploss = ${(double.parse(ordPrice) - double.parse(stopLossCtrl.text)).toStringAsFixed(2)}) Stoploss cannot be lower than ${widget.scripInfo.lc}");
                                                              } else if (!isBuy! &&
                                                                  _hasValidCircuitBreakerValues &&
                                                                  (double.parse(ordPrice) + double.parse(stopLossCtrl.text)) >
                                                                      double.parse(widget.scripInfo.uc!)) {
                                                                warningMessage(context,
                                                                    "Price(Order price + Stoploss = ${(double.parse(ordPrice) + double.parse(stopLossCtrl.text))}) Stoploss cannot be greater than ${widget.scripInfo.uc}");
                                                              } else if (trailingTicksCtrl.text.isNotEmpty && (trailTicksRemainder > 0.0001)) {
                                                                warningMessage(context, "Trailing SL should be in multiples of tick size: $tickSize");
                                                              } else if (trailingTicksCtrl.text.isNotEmpty && (enteredValue <= 0)) {
                                                                warningMessage(context, "Trailing SL should be positive value");
                                                              } else {
                                                                if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                            ? "0"
                                                                            : getFinalQuantity(qtyCtrl.text)) >
                                                                        frezQty &&
                                                                    widget.scripInfo.frzqty != null)) {
                                                                  placeOrder(orderInput, true, theme);
                                                                } else {
                                                                  placeOrder(orderInput, false, theme);
                                                                }
                                                              }
                                                        }
                                                        else if (_isBracketOrderEnabled && orderType == "CO - BO" && (priceType == "SL Limit")) {

                                                                double userOrderPrice = double.tryParse(ordPrice)??0;
                                                                double userStopLoss = double.tryParse(stopLossCtrl.text)??0;
                                                                double userTriggerPrice = double.tryParse(triggerPriceCtrl.text)??0;
                                                                double lc = double.tryParse(widget.scripInfo.lc??"0")??0;
                                                                double uc = double.tryParse(widget.scripInfo.uc??"0")??0;


                                                          if (stopLossCtrl.text.isEmpty || targetCtrl.text.isEmpty) {
                                                                    warningMessage(context,"${stopLossCtrl.text.isEmpty ? "Stoploss" : "Target"} cannot be empty");

                                                          } else if (isBuy! &&
                                                              (userOrderPrice - userStopLoss) < lc) {
                                                                    warningMessage(context,"Price(Order price - Stoploss = ${(double.parse(ordPrice) - double.parse(stopLossCtrl.text)).toStringAsFixed(2)}) Stoploss cannot be lower than ${widget.scripInfo.lc ?? 0.00}");

                                                          } else if (!isBuy! &&
                                                              (userOrderPrice + userStopLoss) > uc) {
                                                                    warningMessage(context, "Price(Order price + Stoploss = ${(double.parse(ordPrice) + double.parse(stopLossCtrl.text))}) Stoploss cannot be greater than ${widget.scripInfo.uc ?? 0.00}");

                                                          } else if (triggerPriceCtrl
                                                                  .text
                                                                  .isEmpty &&
                                                              priceType == "SL Limit") {
                                                           
                                                                    warningMessage(
                                                                        context,
                                                                        "Trigger cannot be empty");
                                                          } else {
                                                            if (isBuy!) {
                                                              if (userTriggerPrice < lc) {
                                                               warningMessage(
                                                                        context,
                                                                        "Trigger cannot be lesser than lower circuit limit of ${widget.scripInfo.lc ?? 0.00}");
                                                              } else if (userOrderPrice < userTriggerPrice) {
                                                               warningMessage(
                                                                        context,
                                                                        "Trigger should be less than price");
                                                              } else if (userTriggerPrice > uc) {
                                                                warningMessage(
                                                                        context,
                                                                        "Trigger cannot be greater than upper circuit limit of ${widget.scripInfo.uc ?? 0.00}");
                                                              } else {
                                                                if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                            ? "0"
                                                                            : getFinalQuantity(qtyCtrl.text)) > frezQty && widget.scripInfo.frzqty != null))  {
                                                                    placeOrder(
                                                                      orderInput,
                                                                      true,
                                                                      theme);
                                                                } else {
                                                                  placeOrder(
                                                                      orderInput,
                                                                      false,
                                                                      theme);
                                                                }
                                                              }
                                                            } else {
                                                              if (userTriggerPrice > uc) {
                                                               warningMessage(context, "Trigger cannot be greater than upper circuit limit of ${widget.scripInfo.uc ?? 0.00}");

                                                              } else if (userOrderPrice > userTriggerPrice) {
                                                                warningMessage(context,"Trigger should be greater than price");

                                                              } else if (userTriggerPrice < lc) {
                                                                warningMessage(context,"Trigger cannot be lesser than lower circuit limit of ${widget.scripInfo.lc ?? 0.00}");

                                                              } else {
                                                                if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                        ? "0" : getFinalQuantity(qtyCtrl.text)) 
                                                                        > frezQty && widget.scripInfo.frzqty != null)) {

                                                                  placeOrder(
                                                                      orderInput,
                                                                      true,
                                                                      theme);
                                                                } else {
                                                                  placeOrder(
                                                                      orderInput,
                                                                      false,
                                                                      theme);
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                        else {
                                                          if ((int.parse(getFinalQuantity(qtyCtrl.text).isEmpty
                                                                      ? "0"
                                                                      : getFinalQuantity(qtyCtrl.text)) >
                                                                  frezQty &&
                                                              widget.scripInfo.frzqty != null)) {
                                                            placeOrder(orderInput, true, theme);
                                                          } else {
                                                            placeOrder(orderInput, false, theme);
                                                          }
                                                        }
                                                  }
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          backgroundColor:
                                              (widget.isBasket == "Basket" || widget.isBasket == "BasketEdit" || widget.isBasket == "BasketMode")
                                                  ? colors.primary // Use primary color for basket mode
                                                  : isBuy!
                                                      ? colors.primary
                                                      : colors.tertiary,
                                          // shape: const StadiumBorder()
                                        ),
                                        child: orderProvide.orderloader
                                            ? const SizedBox(
                                                width: 18,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xffffffff)),
                                              )
                                            : TextWidget.subText(
                                                text: (widget.isBasket == "Basket" ||
                                                        widget.isBasket == "BasketEdit" ||
                                                        widget.isBasket == "BasketMode")
                                                    ? widget.isBasket == "BasketEdit"
                                                        ? "Edit to Basket"
                                                        : "Add to Basket"
                                                    : orderType == "SIP"
                                                        ? "Create SIP"
                                                        : isBuy!
                                                            ? 'Buy'
                                                            : "Sell",
                                                color: theme.isDarkMode
                                                    ? orderType == "SIP"
                                                        ? colors.colorBlack
                                                        : colors.colorWhite
                                                    : const Color(0xffffffff),
                                                theme: theme.isDarkMode,
                                                fw: 2),
                                      ),
                                    ),
                                    // if (defaultTargetPlatform ==
                                    //     TargetPlatform.iOS)
                                    const SizedBox(height: 10)
                                  ]
                                ])),
                          ),
                        )));
        },
      ),
    );
  }

  Padding addValidityAndDisclosedQtyOption(ThemesProvider theme, BuildContext context, ScripInfoModel scripInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            headerTitleText("Validity", theme),
            const SizedBox(height: 8),
            SizedBox(
                height: 38,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            validityType = validityTypes[index];
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            minimumSize: const Size(0, 0),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            backgroundColor: !theme.isDarkMode
                                ? validityType != validityTypes[index]
                                    ? const Color(0xffF1F3F8)
                                    : theme.isDarkMode
                                        ? colors.secondaryDark
                                        : colors.secondaryLight
                                : validityType != validityTypes[index]
                                    ? colors.darkGrey
                                    : theme.isDarkMode
                                        ? colors.secondaryDark
                                        : colors.secondaryLight,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            )
                            //   const StadiumBorder()
                            ),
                        child: TextWidget.subText(
                            text: validityTypes[index],
                            color: !theme.isDarkMode
                                ? validityType != validityTypes[index]
                                    ? theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight
                                    : colors.colorWhite
                                : validityType != validityTypes[index]
                                    ? theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight
                                    : colors.colorWhite,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: validityType == validityTypes[index] ? 1 : 0),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(width: 8);
                    },
                    itemCount: widget.orderArg.exchange == "BSE" || widget.orderArg.exchange == "BFO" ? validityTypes.length : 2))
          ])),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerTitleText("Disclosed Qty", theme),
                const SizedBox(height: 8),
                SizedBox(
                  height: 45,
                  child: Semantics(
                    identifier: "Disclosed Qty",
                    child: CustomTextFormField(
                        fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                        hintText: "0",
                        hintStyle: TextWidget.textStyle(
                          fontSize: 14,
                          theme: theme.isDarkMode,
                          color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                          fw: 0,
                        ),
                        inputFormate: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        style: TextWidget.textStyle(
                          fontSize: 16,
                          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                        // prefixIcon: InkWell(
                        //   onTap: () {
                        //     setState(() {
                        //       if (discQtyCtrl
                        //           .text
                        //           .isNotEmpty) {
                        //         if (int.parse(
                        //                 discQtyCtrl
                        //                     .text) >
                        //             0) {
                        //           discQtyCtrl
                        //                   .text =
                        //               (int.parse(discQtyCtrl.text) -
                        //                       1)
                        //                   .toString();
                        //         } else {
                        //           discQtyCtrl
                        //                   .text =
                        //               "0";
                        //         }
                        //       } else {
                        //         discQtyCtrl
                        //             .text = "0";
                        //       }
                        //     });
                        //   },
                        //   child: SvgPicture.asset(
                        //       theme.isDarkMode
                        //           ? assets
                        //               .darkCMinus
                        //           : assets
                        //               .minusIcon,
                        //       fit: BoxFit
                        //           .scaleDown),
                        // ),
                        // suffixIcon: InkWell(
                        //   onTap: () {
                        //     setState(() {
                        //       int number =
                        //           int.parse(
                        //               discQtyCtrl
                        //                   .text);
                        //       if (discQtyCtrl
                        //           .text
                        //           .isNotEmpty) {
                        //         if (number <
                        //             9999999999) {
                        //           discQtyCtrl
                        //                   .text =
                        //               (int.parse(discQtyCtrl.text) +
                        //                       1)
                        //                   .toString();
                        //         }
                        //       } else {
                        //         discQtyCtrl
                        //             .text = "0";
                        //       }
                        //     });
                        //   },
                        //   child: SvgPicture.asset(
                        //       theme.isDarkMode
                        //           ? assets
                        //               .darkAdd
                        //           : assets
                        //               .addIcon,
                        //       fit: BoxFit
                        //           .scaleDown),
                        // ),
                        textCtrl: discQtyCtrl,
                        textAlign: TextAlign.start),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding triggerOption(ThemesProvider theme, BuildContext context, ScripInfoModel scripInfo) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 2),
          headerTitleText("Trigger", theme),
          const SizedBox(height: 8),
          SizedBox(
              height: 45,
              child: Semantics(
                identifier: "Stoploss Trigger",
                child: CustomTextFormField(
                    inputFormate: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                    fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                    hintText: "0.00",
                    hintStyle: TextWidget.textStyle(
                      fontSize: 14,
                      theme: theme.isDarkMode,
                      color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                      fw: 0,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && double.parse(value) > 0) {
                        final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$'); // Allows numbers with up to 2 decimal places
                        if (!regex.hasMatch(value)) {
                          triggerPriceCtrl.text = value.substring(0, value.length - 1); // Revert to previous valid input
                          triggerPriceCtrl.selection = TextSelection.collapsed(offset: triggerPriceCtrl.text.length); // Keep cursor at the end
                        }
                      }
                
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      if (value.isNotEmpty && value != "0") {
                        marginUpdate();
                      } else if (value == "0") {
                        warningMessage(context, "Trigger cannot be 0");
                      } else {
                        warningMessage(context, "Trigger cannot be empty");
                      }
                    },
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextWidget.textStyle(
                      fontSize: 16,
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),
                    // prefixIcon: Container(
                    //     margin: const EdgeInsets.all(12),
                    //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                    //     child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, assets.ruppeIcon, fit: BoxFit.scaleDown)),
                    textCtrl: triggerPriceCtrl,
                    textAlign: TextAlign.start),
              )),
          // const SizedBox(height: 8),
          // Text(
          //     "Your order will be executed after a stock crosses this trigger price set for you",
          //     style:
          //         textStyle(const Color(0xff666666), 12, FontWeight.w500))
        ]));
  }

  Padding targetOption(ThemesProvider theme, BuildContext context, ScripInfoModel scripInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitleText("Target", theme),
          const SizedBox(height: 8),
          SizedBox(
              height: 45,
              child: Semantics(
                identifier: "Bracket Target Input",
                child: CustomTextFormField(
                    inputFormate: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                    fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                    hintText: "0.00",
                    onChanged: (value) {
                      if (value.isNotEmpty && double.parse(value) > 0) {
                        final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$'); // Allows numbers with up to 2 decimal places
                        if (!regex.hasMatch(value)) {
                          targetCtrl.text = value.substring(0, value.length - 1); // Revert to previous valid input
                          targetCtrl.selection = TextSelection.collapsed(offset: targetCtrl.text.length); // Keep cursor at the end
                        }
                      }
                
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      if (value.isEmpty) {
                        warningMessage(context, "Target cannot be empty");
                      } else if (value.isNotEmpty && double.parse(value) <= 0) {
                        warningMessage(context, "Target cannot be 0");
                      }
                    },
                    hintStyle: TextWidget.textStyle(
                      fontSize: 14,
                      theme: theme.isDarkMode,
                      color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                      fw: 0,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextWidget.textStyle(
                      fontSize: 16,
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),
                    // prefixIcon: Container(
                    //   margin: const EdgeInsets.all(12),
                    //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                    //   child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, assets.ruppeIcon, fit: BoxFit.scaleDown),
                    // ),
                    textCtrl: targetCtrl,
                    textAlign: TextAlign.start),
              )),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

  Padding stopLossOption(ThemesProvider theme, BuildContext context, ScripInfoModel scripInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitleText("Stoploss", theme),
          const SizedBox(height: 8),
          SizedBox(
              height: 45,
              child: Semantics(
                identifier: "Stoploss cover sl",
                child: CustomTextFormField(
                    inputFormate: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                    fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                    onChanged: (value) {
                      if (value.isNotEmpty && double.parse(value) > 0) {
                        final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$'); // Allows numbers with up to 2 decimal places
                        if (!regex.hasMatch(value)) {
                          stopLossCtrl.text = value.substring(0, value.length - 1); // Revert to previous valid input
                          stopLossCtrl.selection = TextSelection.collapsed(offset: stopLossCtrl.text.length); // Keep cursor at the end
                        }
                      }
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      if (value.isEmpty) {
                        warningMessage(context, "Stoploss cannot be empty");
                      } else if (value.isNotEmpty && double.parse(value) <= 0) {
                        warningMessage(context, "Stoploss cannot be 0");
                      }
                    },
                    hintText: "0.00",
                    hintStyle: TextWidget.textStyle(
                      fontSize: 14,
                      theme: theme.isDarkMode,
                      color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                      fw: 0,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextWidget.textStyle(
                      fontSize: 16,
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),
                    // prefixIcon: Container(
                    //   margin: const EdgeInsets.all(12),
                    //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                    //   child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, assets.ruppeIcon, fit: BoxFit.scaleDown),
                    // ),
                    textCtrl: stopLossCtrl,
                    textAlign: TextAlign.start),
              )),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

  Padding trailingTicksOption(ThemesProvider theme, BuildContext context, ScripInfoModel scripInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitleText("Trailing SL", theme),
          const SizedBox(height: 8),
          SizedBox(
              height: 45,
              child: Semantics(
                identifier: "Trailing SL Input",
                child: CustomTextFormField(
                    inputFormate: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                    fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                    hintText: "0.00",
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        double tickSize = double.parse(scripInfo.ti.toString());
                        double enteredValue = (double.tryParse(value) ?? 0).abs();
                
                        if (enteredValue <= 0) {
                          trailingTicksCtrl.text = value.substring(0, value.length - 1);
                          trailingTicksCtrl.selection = TextSelection.collapsed(offset: trailingTicksCtrl.text.length);
                          return;
                        }
                
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        double quotient = enteredValue / tickSize;
                        double remainder = (quotient - quotient.round()).abs();
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        if (remainder > 0.0001) {
                          warningMessage(context, "Trailing SL should be in multiples of tick size: $tickSize");
                        }
                      }
                      if (value.isEmpty) {
                        warningMessage(context, "Trailing SL cannot be empty");
                      }
                    },
                    hintStyle: TextWidget.textStyle(
                      fontSize: 14,
                      theme: theme.isDarkMode,
                      color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                      fw: 0,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextWidget.textStyle(
                      fontSize: 16,
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),
                    textCtrl: trailingTicksCtrl,
                    textAlign: TextAlign.start),
              ))
        ],
      ),
    );
  }

  Padding marketProtectionDisclaimer(ThemesProvider theme, BuildContext context, ScripInfoModel scripInfo, String marketProtection) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextWidget.subText(
                  text: "Market Protected by", color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue, theme: theme.isDarkMode, fw: 0),
              Semantics(
                identifier: "Market Protection %",
                child: InkWell(
                  // borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() {
                      mktProtDialogCtrl.text = mktProtCtrl.text;
                      mktProtErrorText = "";
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter dialogSetState) {
                            return AlertDialog(
                              backgroundColor: theme.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF1F3F8),
                              titlePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                              scrollable: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
                              insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(4),
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.transparent,
                                          elevation: 0.0,
                                          minimumSize: const Size(0, 30),
                                          side: BorderSide.none,
                                          ),
                                    onPressed: () async {
                                      await Future.delayed(const Duration(milliseconds: 150));
                                      Navigator.pop(context);
                                    },
                                    // borderRadius: BorderRadius.circular(20),
                                    // splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                                    // highlightColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 22,
                                      color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.subText(
                                      text: 'Enter Market Protection',
                                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                  const SizedBox(height: 8),
                                  Semantics(
                                    identifier: "Market Protection % Input",
                                    child: CustomTextFormField(
                                      fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                      inputFormate: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^(0|[1-9][0-9]{0,19})$'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          if (value.isEmpty) {
                                            mktProtErrorText = "Market Protection cannot be empty";
                                          } else {
                                            int intValue = int.tryParse(value) ?? 0;
                                                    
                                            if (intValue > 20) {
                                              // force value back to 20
                                              mktProtDialogCtrl.text = "20";
                                              mktProtDialogCtrl.selection = TextSelection.fromPosition(
                                                TextPosition(offset: mktProtDialogCtrl.text.length),
                                              );
                                              mktProtErrorText = "Cannot enter greater than 20%";
                                            } else if (intValue < 1) {
                                              mktProtErrorText = "Cannot enter less than 1%";
                                            } else {
                                              mktProtErrorText = "";
                                            }
                                          }
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      style: TextWidget.textStyle(
                                        fontSize: 16,
                                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                        theme: theme.isDarkMode,
                                        fw: 0,
                                      ),
                                      textCtrl: mktProtDialogCtrl,
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                                        child: SvgPicture.asset(
                                            color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, assets.precentIcon, fit: BoxFit.scaleDown),
                                      ),
                                      textAlign: TextAlign.start,
                                      hintText: "Add Market Protection %",
                                      hintStyle: TextWidget.textStyle(
                                        fontSize: 14,
                                        theme: theme.isDarkMode,
                                        color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                        fw: 0,
                                      ),
                                    ),
                                  ),
                                  if (mktProtErrorText.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Semantics(
                                        identifier: "Market Protection % Error Text",
                                        child: TextWidget.paraText(
                                          text: mktProtErrorText,
                                          color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                      ),
                                      //  Text(
                                      //   mktProtErrorText,
                                      //   style: TextStyle(
                                      //     color: Colors.red,
                                      //     fontSize: 12,
                                      //   ),
                                      // ),
                                    ),
                                ],
                              ),
                              actions: [
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      if (mktProtDialogCtrl.text.isEmpty) {
                                        dialogSetState(() {
                                          mktProtErrorText = "Market Protection cannot be empty";
                                        });
                                        return;
                                      }
                
                                      double intValue = double.tryParse(mktProtDialogCtrl.text) ?? 0;
                                      if (intValue > 20 || intValue < 1) {
                                        return;
                                      }
                
                                      updatePriceType();
                                      setState(() {
                                        mktProtCtrl.text = mktProtDialogCtrl.text;
                                        mktProtErrorText = "";
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 45), // width, height
                                      side: BorderSide(color: colors.btnOutlinedBorder), // Outline border color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      backgroundColor: colors.primaryDark, // Transparent background
                                    ),
                                    child: TextWidget.titleText(text: "OK", color: colors.colorWhite, theme: theme.isDarkMode, fw: 2),
                                  ),
                                ),
                
                                // TextButton(
                                //   onPressed: () => Navigator.of(context).pop(),
                                //   child: const Text('Cancel'),
                                // ),
                                // TextButton(
                                //   onPressed: () {
                                //     Navigator.of(context).pop();
                                //   },
                                //   child: const Text('OK'),
                                // ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextWidget.paraText(
                      text: " $marketProtection %",
                      color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
                      theme: theme.isDarkMode,
                      decoration: TextDecoration.underline,
                      fw: 2,
                    ),
                
                    //  Text(
                    //   " $marketProtection %",
                    //   style: textStyle(
                    //     theme.isDarkMode
                    //         ? colors.colorLightBlue
                    //         : colors.colorBlue,
                    //     14,
                    //     FontWeight.w600,
                    //   ).copyWith(
                    //     decoration: TextDecoration.underline,
                    //   ),
                    // ),
                  ),
                ),
              )
            ],
          ),
          // const SizedBox(height: 4),
          // Text(
          //     "I agreed the trigger executions are not guaranteed. ",
          //   style: textStyle(
          //     theme.isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
          //     13,
          //     FontWeight.w400
          //   ),
          // ),
        ],
      ),
    );
  }

  sipOrder(WidgetRef ref) async {
    final sip = ref.watch(siprovider);
    SipInputField sipOrderInput = SipInputField(
        regdate: sipdateformat(formattedDate),
        startdate: sipdateformat(sip.datefield.text),
        frequency: selectedValue == "Daily"
            ? "0"
            : selectedValue == "Weekly"
                ? "1"
                : selectedValue == "Fortnightly"
                    ? "2"
                    : "3",
        endperiod: sip.numberofSips.text.toString(),
        sipname: widget.scripInfo.tsym,
        exch: widget.scripInfo.exch,
        tysm: widget.scripInfo.tsym,
        prd: "C",
        token: widget.scripInfo.token,
        qty: sipqtyctrl.text);
    await ref.read(orderProvider).fetchSipPlaceOrder(context, sipOrderInput);
  }

  placeOrder(OrderInputProvider orderInput, bool isSliceOrd, ThemesProvider theme) async {
    String bsktName = ref.read(orderProvider).selectedBsktName;
    int frezQtyOrderSliceMaxLimit = ref.read(orderProvider).frezQtyOrderSliceMaxLimit;
    if (widget.isBasket == "Basket" || widget.isBasket == "BasketEdit" || widget.isBasket == "BasketMode") {
      if (widget.isBasket == "BasketEdit") {
        await ref.read(orderProvider).removeBsktScrip(widget.orderArg.raw['index'], bsktName);
      }
      addBasketScrip(orderInput, bsktName, widget.isBasket == "Basket");
    } else {
      if (!isSliceOrd) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
        bool placeorder = true;
        if (priceType == "Limit" || priceType == "SL Limit") {
          String r = roundOffWithInterval(double.parse(priceCtrl.text), tik).toStringAsFixed(2);
          if (double.parse(priceCtrl.text) != double.parse(r)) {
            placeorder = false;
            warningMessage(context, "Price should be multiple of tick size $tik => $r");
          }
        }
        if (placeorder && (priceType == "SL Limit" || priceType == "SL MKT")) {
          String r = roundOffWithInterval(double.parse(triggerPriceCtrl.text), tik).toStringAsFixed(2);
          if (double.parse(triggerPriceCtrl.text) != double.parse(r)) {
            placeorder = false;
            warningMessage(context, "Trigger should be multiple of tick size $tik => $r");
          }
        }
        int q = ((int.parse(getFinalQuantity(qtyCtrl.text)) / lotSize).round() * lotSize);
        if (int.parse(getFinalQuantity(qtyCtrl.text)) != q && widget.scripInfo.exch != 'MCX') {
          placeorder = false;
          warningMessage(context, "Quantity should be multiple of lot size $lotSize => $q");
        }

        if ((priceType == "Market" || priceType == "SL MKT") &&
            (mktProtCtrl.text.isEmpty || double.parse(mktProtCtrl.text.toString()) > 20 || double.parse(mktProtCtrl.text.toString()) < 1)) {
          placeorder = false;
          warningMessage(context, "Market Protection between 1% to 20%");
        }
        if (!isSecu) {
          placeorder = false;
          // anibuildctrl.forward();
          _showSurveillanceBottomSheet(orderInput, isSliceOrd, theme);
        }

        if (placeorder) {
          ref.read(orderProvider).setOrderloader(true);
          PlaceOrderInput placeOrderInput = PlaceOrderInput(
              amo: _afterMarketOrder ? "Yes" : "",
              blprc: orderType == "CO - BO" ? stopLossCtrl.text : '',
              bpprc: orderType == "CO - BO" && _isBracketOrderEnabled ? targetCtrl.text : '',
              dscqty: discQtyCtrl.text,
              exch: widget.scripInfo.exch!,
              prc: ordPrice,
              prctype: orderInput.prcType,
              prd: orderInput.orderType,
              qty: widget.scripInfo.exch == 'MCX'
                  ? (int.parse(getFinalQuantity(qtyCtrl.text)) * lotSize).toString()
                  : getFinalQuantity(qtyCtrl.text),
              ret: validityType,
              trailprc: orderType == "CO - BO" && trailingTicksCtrl.text.isNotEmpty && (double.tryParse(trailingTicksCtrl.text) ?? 0) > 0
                  ? trailingTicksCtrl.text
                  : '',
              trantype: isBuy! ? 'B' : 'S',
              trgprc: priceType == "SL Limit" || priceType == "SL MKT" ? triggerPriceCtrl.text : "",
              tsym: widget.scripInfo.tsym!,
              mktProt: priceType == "Market" || priceType == "SL MKT" ? mktProtCtrl.text : '',
              channel: '');
          await ref.read(orderProvider).fetchPlaceOrder(context, placeOrderInput, widget.orderArg.isExit);
          ref.read(orderProvider).setOrderloader(false);
        }
      } else {
        int q = ((int.parse(getFinalQuantity(qtyCtrl.text)) / lotSize).round() * lotSize);
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        if (int.parse(getFinalQuantity(qtyCtrl.text)) != q && widget.scripInfo.exch != 'MCX') {
          warningMessage(context, "Quantity should be multiple of lot size $lotSize => $q");
        } else if (frezQtyOrderSliceMaxLimit < quantity) {
          warningMessage(context,
              "Quantity can only be split into a maximum of $frezQtyOrderSliceMaxLimit slice. (Ex: $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQty * frezQtyOrderSliceMaxLimit})");
        } else if (!isSecu) {
          _showSurveillanceBottomSheet(orderInput, isSliceOrd, theme);
        } else {
          showModalBottomSheet(
            isScrollControlled: true,
            useSafeArea: true,
            isDismissible: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            context: context,
            builder: (context) => SliceOrderSheet(
              scripInfo: widget.scripInfo,
              isBuy: isBuy!,
              quantity: quantity,
              frezQty: frezQty,
              reminder: reminder,
              lotSize: lotSize,
              isAmo: _afterMarketOrder,
              orderType: orderType,
              priceType: priceType,
              ordPrice: ordPrice,
              validityType: validityType,
              stopLossCtrl: stopLossCtrl,
              targetCtrl: targetCtrl,
              discQtyCtrl: discQtyCtrl,
              triggerPriceCtrl: triggerPriceCtrl,
              mktProtCtrl: mktProtCtrl,
              isBracketOrderEnabled: _isBracketOrderEnabled,
            ),
          );
        }
      }
    }
  }

  headerTitleText(String text, ThemesProvider theme) {
    return TextWidget.subText(text: text, theme: theme.isDarkMode, fw: 1, color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight);
  }

  void marginUpdate() {
    OrderMarginInput input = OrderMarginInput(
        exch: "${widget.scripInfo.exch}",
        prc: (priceType == "Market" || priceType == "SL MKT") ? "0" : ordPrice,
        prctyp: ref.read(ordInputProvider).prcType,
        prd: ref.read(ordInputProvider).orderType,
        qty: widget.scripInfo.exch == 'MCX'
            ? (double.parse(getFinalQuantity(qtyCtrl.text)).toInt() * lotSize).toString()
            : getFinalQuantity(qtyCtrl.text),
        rorgprc: '0',
        rorgqty: '0',
        trantype: isBuy! ? "B" : "S",
        tsym: "${widget.scripInfo.tsym}",
        blprc: orderType == "CO - BO" ? stopLossCtrl.text : '',
        bpprc: orderType == "CO - BO" ? targetCtrl.text : '',
        trgprc: priceType == "SL Limit" || priceType == "SL MKT" ? triggerPriceCtrl.text : "");
    ref.read(orderProvider).fetchOrderMargin(input, context);
    BrokerageInput brokerageInput = BrokerageInput(
        exch: "${widget.scripInfo.exch}",
        prc: (priceType == "Market" || priceType == "SL MKT") ? "0" : ordPrice,
        prd: ref.read(ordInputProvider).orderType,
        qty: widget.scripInfo.exch == 'MCX'
            ? (double.parse(getFinalQuantity(qtyCtrl.text)).toInt() * lotSize).toString()
            : getFinalQuantity(qtyCtrl.text),
        trantype: isBuy! ? "B" : "S",
        tsym: "${widget.scripInfo.tsym}");
    ref.read(orderProvider).fetchGetBrokerage(brokerageInput, context);
  }

  void _showSurveillanceBottomSheet(OrderInputProvider orderInput, bool isSliceOrd, ThemesProvider theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  border: Border(
                    top: BorderSide(
                      color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.5) : colors.colorWhite,
                    ),
                    left: BorderSide(
                      color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.5) : colors.colorWhite,
                    ),
                    right: BorderSide(
                      color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.5) : colors.colorWhite,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning_outlined, color: Color.fromARGB(190, 255, 170, 0), size: 24),
                                    Expanded(
                                        child: Text(
                                      " Exchange surveillance active",
                                      style: textStyle(
                                        theme.isDarkMode ? colors.textPrimary : colors.textPrimaryLight,
                                        16,
                                        FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextWidget.subText(text: quotemsg, theme: theme.isDarkMode, lineHeight: 1.6),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isSecu = true;
                            });
                            Navigator.pop(context);
                            placeOrder(orderInput, isSliceOrd, theme);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: TextWidget.subText(
                            text: "Continue",
                            color: colors.colorWhite,
                            theme: theme.isDarkMode,
                            fw: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  prepareToPlaceGttOrder(OrderInputProvider orderInput) async {
    PlaceGTTOrderInput input = PlaceGTTOrderInput(
        exch: '${widget.scripInfo.exch}',
        qty: orderInput.qtyCtrl.text,
        tsym: '${widget.scripInfo.tsym}',
        validity: "GTT",
        prc: orderInput.actPrcType == "Market" || orderInput.actPrcType == "SL MKT" ? "0.00" : orderInput.priceCtrl.text,
        prd: orderInput.orderType,
        trantype: isBuy! ? 'B' : "S",
        ret: 'DAY',
        ait: orderInput.ait,
        d: orderInput.val1Ctrl.text,
        prctyp: orderInput.prcType,
        remarks: orderInput.reMarksCtrl.text,
        trgprc: orderInput.actPrcType == "SL Limit" || orderInput.actPrcType == "SL MKT" ? orderInput.trgPrcCtrl.text : "",
        alid: '');
    await ref.read(orderProvider).placeGTTOrder(input, context);
  }

  prepareToPlaceOCOOrder(OrderInputProvider orderInput) async {
    PlaceOcoOrderInput input = PlaceOcoOrderInput(
        exch: '${widget.scripInfo.exch}',
        tsym: '${widget.scripInfo.tsym}',
        validity: "GTT",
        trantype: isBuy! ? 'B' : "S",
        ret: 'DAY',
        remarks: orderInput.reMarksCtrl.text,
        qty1: orderInput.qtyCtrl.text,
        trgprc1: orderInput.actOcoPrcType == "SL Limit" || orderInput.actOcoPrcType == "SL MKT" ? orderInput.trgPrcCtrl.text : "",
        prc1: orderInput.actPrcType == "Market" || orderInput.actPrcType == "SL MKT" ? "0.00" : orderInput.priceCtrl.text,
        prd1: orderInput.orderType,
        d1: orderInput.val1Ctrl.text,
        prctyp1: orderInput.prcType,
        d2: orderInput.val2Ctrl.text,
        prctyp2: orderInput.ocoPrcType,
        prc2: orderInput.actOcoPrcType == "Market" || orderInput.actOcoPrcType == "SL MKT" ? "0.00" : orderInput.ocoPriceCtrl.text,
        prd2: orderInput.ocoOrderType,
        qty2: orderInput.ocoQtyCtrl.text,
        trgprc2: orderInput.actOcoPrcType == "SL Limit" || orderInput.actOcoPrcType == "SL MKT" ? orderInput.ocoTrgPrcCtrl.text : "",
        alid: '');
    await ref.read(orderProvider).placeOCOOrder(input, context);
  }

  addBasketScrip(OrderInputProvider orderInput, String bsktName, bool stay) async {
    Map<String, dynamic> data = {};
    String curDate = convDateWithTime();

    // Validate quantity is multiple of lot size for basket orders
    final quantity = int.parse(qtyCtrl.text);
    final lotSizeVal = lotSize;

    if (quantity % lotSizeVal != 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Quantity must be multiple of lot size ($lotSizeVal). Current: $quantity"),
        backgroundColor: colors.darkred,
        duration: const Duration(seconds: 3),
      ));
      return; // Exit the function without adding to basket
    }

    // Use user-specific storage if available, otherwise general storage
    final userId = pref.clientId;
    if (userId != null && userId.isNotEmpty) {
      final userBasketScrips = pref.getBasketScripsForUser(userId) ?? "";
      data = userBasketScrips.isEmpty ? {} : jsonDecode(userBasketScrips);
    } else {
      data = pref.bsktScrips!.isEmpty ? {} : jsonDecode(pref.bsktScrips!);
    }

    List scripList = data[bsktName] ?? [];

    // Calculate splits needed for current order
    List<int> splitQuantities = [];
    final freezeQty = frezQty;
    final orderProv = ref.read(orderProvider);
    final frezQtyOrderSliceMaxLimit = orderProv.frezQtyOrderSliceMaxLimit;

    if (widget.scripInfo.frzqty != null && quantity > freezeQty) {
      // Calculate number of full splits and remainder
      final fullSplits = quantity ~/ freezeQty; // Integer division
      final remainder = quantity % freezeQty;

      // Add full splits
      for (int i = 0; i < fullSplits; i++) {
        splitQuantities.add(freezeQty);
      }

      // Add remainder if exists
      if (remainder > 0) {
        splitQuantities.add(remainder);
      }
    } else {
      // No split needed
      splitQuantities.add(quantity);
    }

    // Check if total orders in basket would exceed limit
    int currentBasketOrders = scripList.length; // Each item in basket counts as 1 order
    int newOrders = splitQuantities.length;

    if (currentBasketOrders + newOrders > frezQtyOrderSliceMaxLimit) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Cannot add to basket. Total orders would be ${currentBasketOrders + newOrders}, which exceeds the maximum limit of $frezQtyOrderSliceMaxLimit orders."),
        backgroundColor: colors.darkred,
        duration: const Duration(seconds: 3),
      ));
      return; // Exit the function without adding to basket
    }

    // Add each split as separate entry to basket
    for (int splitQty in splitQuantities) {
      scripList.add({
        "dname": "${widget.scripInfo.dname}",
        "token": widget.scripInfo.token,
        "frzqty": widget.scripInfo.frzqty?.toString() ?? "0",
        "date": curDate,
        "amo": _afterMarketOrder ? "Yes" : "",
        "blprc": orderType == "CO - BO" ? stopLossCtrl.text : '',
        "bpprc": orderType == "CO - BO" && _isBracketOrderEnabled ? targetCtrl.text : '',
        "dscqty": discQtyCtrl.text,
        "exch": widget.scripInfo.exch!,
        "prc": ordPrice,
        "prctype": orderInput.prcType,
        "prd": orderInput.orderType,
        "ordType": orderInput.orderType == "I"
            ? "MIS"
            : orderInput.orderType == "C"
                ? "CNC"
                : orderInput.orderType == "M"
                    ? "NRML"
                    : orderInput.orderType == "H"
                        ? "CO"
                        : "BO",
        "qty": splitQty.toString(), // Use the split quantity instead of original quantity
        "ret": validityType,
        "trailprc": orderType == "CO - BO" && trailingTicksCtrl.text.isNotEmpty && (double.tryParse(trailingTicksCtrl.text) ?? 0) > 0
            ? trailingTicksCtrl.text
            : '',
        "trantype": isBuy! ? 'B' : 'S',
        "trgprc": priceType == "SL Limit" || priceType == "SL MKT" ? triggerPriceCtrl.text : "",
        "tsym": widget.scripInfo.tsym != null ? UrlUtils.encodeParameter(widget.scripInfo.tsym!) : '',
        "mktProt": priceType == "Market" || priceType == "SL MKT" ? mktProtCtrl.text : ''
      });
    }

    data.addAll({bsktName: scripList});

    String jsonData = jsonEncode(data);

    print("=== ADDING TO BASKET DEBUG ===");
    print("Basket name: $bsktName");
    print("Script count after add: ${scripList.length}");
    print("Full data being saved: $jsonData");

    // Save to the same storage type we read from
    if (userId != null && userId.isNotEmpty) {
      await pref.setBasketScripForUser(userId, jsonData);
      print("Saved to user storage for user: $userId");

      // Clear general storage to prevent conflicts
      if (pref.bsktScrips != null && pref.bsktScrips!.isNotEmpty) {
        await pref.setBasketScrip("{}");
        print("Cleared general storage");
      }
    } else {
      await pref.setBasketScrip(jsonData);
      print("Saved to general storage");
    }
    print("==============================");

    // **FIX: Add small delay to ensure storage write completes before reading**
    await Future.delayed(const Duration(milliseconds: 100));

    await ref.read(orderProvider).getBasketName();

    // Ensure WebSocket subscription for the updated basket
    // final orderProv = ref.read(orderProvider);
    if (orderProv.selectedBsktName == bsktName) {
      // Re-subscribe to ensure new items get real-time updates
      await orderProv.chngBsktName(bsktName, context, true);
    }

    await ref.read(orderProvider).fetchBasketMargin();
    Navigator.pop(context);
    if (stay) {
      Navigator.pop(context);
    }
  }

  void updatePriceType() {
    if ((orderType == "Delivery" || orderType == "Intraday" || orderType == "MTF") &&
        _isStoplossOrder &&
        _isMarketOrder) {
      priceType = "SL MKT";
    } else if (((orderType == "Delivery" || orderType == "Intraday" || orderType == "MTF" || orderType == "CO - BO") &&  _isStoplossOrder && !_isMarketOrder) 
            || (orderType == "CO - BO" &&  _isStoplossOrder && _isMarketOrder)) {
                    priceType = "SL Limit";
    } else if (_isMarketOrder) {
      priceType = "Market";
    } else {
      priceType = "Limit";
    }

    // Update price controller based on type
    if (priceType == "Market" || priceType == "SL MKT") {
      priceCtrl.text = "Market";
      double ltp = (double.parse("${widget.orderArg.ltp}") * double.parse(mktProtCtrl.text.isEmpty ? "0" : mktProtCtrl.text)) / 100;

      if (isBuy!) {
        ordPrice = (double.parse("${widget.orderArg.ltp ?? 0.00}") + ltp).toStringAsFixed(2);
      } else {
        ordPrice = (double.parse("${widget.orderArg.ltp ?? 0.00}") - ltp).toStringAsFixed(2);
      }
      double result = double.parse(ordPrice) + (double.parse("${widget.scripInfo.ti}") / 2);
      result -= result % double.parse("${widget.scripInfo.ti}");

      if (_hasValidCircuitBreakerValues) {
        if (result >= double.parse(widget.scripInfo.uc!)) {
          ordPrice = widget.scripInfo.uc!;
        } else if (result <= double.parse(widget.scripInfo.lc!)) {
          ordPrice = widget.scripInfo.lc!;
        } else {
          ordPrice = result.toStringAsFixed(2);
        }
      } else {
        ordPrice = result.toStringAsFixed(2);
      }
    } else if (priceCtrl.text == "Market") {
      priceCtrl.text = "${widget.orderArg.ltp}";
      ordPrice = priceCtrl.text;
    }
  }

  void onOrderTypeChangeClearValues() {
    if (orderType == "Delivery" || orderType == "Intraday" || orderType == "MTF") {
      _isCoverOrderEnabled = true;
      _isBracketOrderEnabled = false;

    }else if (orderType == "CO - BO") {
      _addValidityAndDisclosedQty = false;
      _afterMarketOrder = false;
    }
  }

  String convertQtyOrAmtValue(String value, bool isQtyToAmount) {
    if (value.trim().isEmpty) return "";
    double ltp = double.tryParse(widget.orderArg.ltp ?? "0.0") ?? 0.0;
    return isQtyToAmount ? ((double.tryParse(value) ?? 0.0) ~/ ltp).toString() : value;
  }

  String convertLotOrQtyValue(String value, bool isLotToQty) {
    if (value.trim().isEmpty) return "";
    return isLotToQty ? ((int.tryParse(value) ?? 0) ~/ lotSize).toString() : value;
  }

  // Get the final quantity for order placement
  String getFinalQuantity(String value) {
    if (value.trim().isEmpty) return "0";

    if (_isStock) {
      // NSE/BSE: convert amount to qty if in amount mode
      return convertQtyOrAmtValue(value, _isQtyToAmount);
    } else {
      // NFO/BFO: if in lot mode, multiply by lotSize; if in qty mode, use as is
      int inputValue = int.tryParse(value) ?? 0;
      return _isLotToQty ? value : (inputValue * lotSize).toString();
    }
  }
}
