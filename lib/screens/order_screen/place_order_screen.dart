import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../res/res.dart';
import '../../models/marketwatch_model/scrip_info.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../models/order_book_model/order_margin_model.dart';
import '../../models/order_book_model/place_order_model.dart';
import '../../provider/index_list_provider.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/network_state_provider.dart';
import '../../provider/order_input_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/shocase_provider.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_switch_btn.dart';
import '../../sharedWidget/custom_widget_button.dart';
import '../../sharedWidget/enums.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/no_internet_widget.dart';
import '../../sharedWidget/snack_bar.dart';
import 'margin_charges_bottom_sheet.dart';
import 'order_screen_header.dart';

class PlaceOrderScreen extends StatefulWidget {
  final OrderScreenArgs orderArg;
  final ScripInfoModel scripInfo;
  const PlaceOrderScreen(
      {super.key, required this.scripInfo, required this.orderArg});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  bool? isBuy;
  bool addStoploss = false;
  bool isAgree = false;
  bool addValidity = false;
  bool isAmo = false;
  TextEditingController priceCtrl = TextEditingController();
  TextEditingController triggerPriceCtrl = TextEditingController();
  TextEditingController mktProtCtrl = TextEditingController();
  TextEditingController qtyCtrl = TextEditingController();
  TextEditingController discQtyCtrl = TextEditingController();
  TextEditingController stopLossCtrl = TextEditingController();
  TextEditingController targetCtrl = TextEditingController();
  TextEditingController trailingTickCtrl = TextEditingController();

  double resultsip = 0.0;
  int frezQty = 0;
  int reminder = 0;
  int maxQty = 0;
  int quantity = 0;
  List orderTypes = [
    "Regular", "Cover", "Bracket"
    // , "SIP"
  ];

  List priceTypes = ["Limit", "Market", "SL Limit", "SL MKT"];
  List<String> validityTypes = ["DAY", "IOC", "EOS"];

  String product = "I";
  String orderType = "Regular";
  String priceType = "Limit";
  int lotSize = 0;
  String price = "0.00";
  String validityType = "DAY";
  @override
  void initState() {
    orderType = "Regular";
    orderTypes = [
      {"type": "Regular"},
      {"type": "Cover"},
      {"type": "Bracket"}
    ];
    if (widget.scripInfo.exch == "NSE" || widget.scripInfo.exch == "BSE") {
      if (context.read(userProfileProvider).userDetailModel != null &&
          context.read(userProfileProvider).userDetailModel!.stat == "Ok") {
        for (var element
            in context.read(userProfileProvider).userDetailModel!.prarr!) {
          if (element.sPrdtAli == "MTF") {
            orderTypes.add({"type": "MTF"});
          }
        }
      }
    }

    if (widget.scripInfo.instname != "UNDIND" &&
        widget.scripInfo.instname != "COM") {
      orderTypes.add({
        "type": "GTT",
        "key": context.read(showcaseProvide).orderscreenBracketcase,
        "case": "Click here to view GTT order details."
      });
    }
    priceType = "Limit";
    priceTypes = [
      {
        "type": "Limit",
        "key": context.read(showcaseProvide).limitprctype,
        "case": "Click here to set your order type to Limit."
      },
      {
        "type": "Market",
        "key": context.read(showcaseProvide).marketprctype,
        "case": "Click here to set your order type to Market."
      },
      {
        "type": "SL Limit",
        "key": context.read(showcaseProvide).sllimitprctype,
        "case": "Click here to set your order type to SL Limit."
      },
      {
        "type": "SL MKT",
        "key": context.read(showcaseProvide).sllimktprctype,
        "case": "Click here to set your order type to SL MKT."
      },
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read(ordInputProvider).chngInvesType(
          widget.scripInfo.seg == "EQT"
              ? InvestType.delivery
              : InvestType.carryForward,
          "PlcOrder");

      context
          .read(ordInputProvider)
          .chngPriceType("Limit", widget.orderArg.exchange);
      marginUpdate();
    });

    setState(() {
      // if (widget.scripInfo.instname != "EQ") {
      //   orderType.remove("SIP");
      // }
      frezQty = int.parse(widget.scripInfo.frzqty ?? "0");
      validityType =
          widget.orderArg.exchange == "BSE" || widget.orderArg.exchange == "BFO"
              ? "EOS"
              : "DAY";
      lotSize = int.parse("${widget.scripInfo.ls ?? 0}");
      isBuy = widget.orderArg.transType;
      priceCtrl = TextEditingController(text: "${widget.orderArg.ltp}");
      qtyCtrl = TextEditingController(
          text: widget.orderArg.isExit
              ? widget.orderArg.holdQty!.replaceAll("-", "")
              : widget.orderArg.lotSize!.replaceAll("-", ""));
      mktProtCtrl = TextEditingController(text: "5");
      discQtyCtrl = TextEditingController(text: "0");
      product = widget.orderArg.orderTpye == "CNC" ? "C" : "I";
      // context.read(networkStateProvider).networkStream();

      price = "${widget.orderArg.ltp}";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await context
            .read(marketWatchProvider)
            .requestMWScrip(context: context, isSubscribe: true);

        return true;
      },
      child: Consumer(builder: (context, ScopedReader watch, _) {
        final orderProvide = watch(orderProvider);
        final orderInput = watch(ordInputProvider);
        final internet = watch(networkStateProvider);
        final theme = context.read(themeProvider);
        return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                    leadingWidth: 41,
                    centerTitle: false,
                    titleSpacing: 0,
                    leading: const CustomBackBtn(),
                    elevation: .4,
                    title: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${widget.scripInfo.symbol!} ",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      16,
                                      FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1),
                              if (widget.scripInfo.option!.isNotEmpty)
                                Text(widget.scripInfo.option!,
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: const Color(0xff666666)),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                              if (widget.scripInfo.expDate!.isNotEmpty)
                                Text(" ${widget.scripInfo.expDate} ",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w600)),
                              CustomExchBadge(exch: "${widget.scripInfo.exch}"),
                            ]),
                        // const SizedBox(height: 4),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OrderScreenHeader(headerData: widget.orderArg),
                              Row(children: [
                                SvgPicture.asset(assets.buyIcon),
                                const SizedBox(width: 6),
                                CustomSwitch(
                                    onChanged: (bool value) {
                                      setState(() {
                                        isBuy = value;
                                      });
                                      marginUpdate();
                                    },
                                    value: isBuy!),
                                const SizedBox(width: 6),
                                SvgPicture.asset(assets.sellIcon)
                              ])
                            ])
                      ]),
                    ),
                    bottom: PreferredSize(
                        preferredSize: Size.fromHeight(
                            widget.orderArg.exchange == "NCOM" ? 10 : 50),
                        child: Column(children: [
                          if (widget.orderArg.exchange != "NCOM") ...[
                            Container(
                                height: 46,
                                decoration: BoxDecoration(
                                    border: (Border(
                                        top: BorderSide(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : colors.colorDivider)))),
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                          onTap: () {
                                            setState(() {
                                              orderType =
                                                  orderTypes[index]['type'];
                                              if (priceType == "SL MKT") {
                                                priceType = "Limit";
                                              }

                                              if (index == 1 || index == 2) {
                                                addStoploss = true;
                                              } else {
                                                addStoploss = false;
                                              }
                                            });

                                            if (orderTypes[index]['type'] !=
                                                "Regular") {
                                              orderInput.chngOrderType(
                                                  orderTypes[index]['type']);
                                            } else {
                                              orderInput.chngInvesType(
                                                  widget.scripInfo.seg == "EQT"
                                                      ? InvestType.delivery
                                                      : InvestType.carryForward,
                                                  "PlcOrder");
                                            }
                                            if (orderType != "GTT") {
                                              marginUpdate();
                                            } else {
                                              Navigator.pop(context);

                                              Navigator.pushNamed(context,
                                                  Routes.gttOrderScreen,
                                                  arguments: {
                                                    "orderArg": widget.orderArg,
                                                    "scripInfo":
                                                        widget.scripInfo
                                                  });
                                            }

                                            FocusScope.of(context).unfocus();
                                          },
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              decoration: BoxDecoration(
                                                  border: orderType ==
                                                          orderTypes[index]
                                                              ['type']
                                                      ? Border(
                                                          bottom: BorderSide(
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              width: 2))
                                                      : null),
                                              child: Text(
                                                  orderTypes[index]['type'],
                                                  style: textStyle(
                                                      orderType == orderTypes[index]['type'] &&
                                                              theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : orderType ==
                                                                  orderTypes[index]
                                                                      ['type']
                                                              ? colors
                                                                  .colorBlack
                                                              : const Color(
                                                                  0xff666666),
                                                      14,
                                                      orderType ==
                                                              orderTypes[index]
                                                                  ['type']
                                                          ? FontWeight.w600
                                                          : FontWeight.w500))));
                                    },
                                    itemCount: orderTypes.length))
                          ]
                        ]))),
                body: Stack(
                  children: [
                    SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            if (orderType == "Regular") ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Text("Investment type",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w500))),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        if (widget.orderArg.exchange !=
                                            "NCOM") ...[
                                          Radio<InvestType>(
                                            fillColor: WidgetStateProperty
                                                .resolveWith<Color>(
                                                    (Set<WidgetState> states) {
                                              if (states.contains(
                                                  WidgetState.disabled)) {
                                                return const Color(0xff666666);
                                              }
                                              return theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : const Color(0xff666666);
                                            }),
                                            activeColor: theme.isDarkMode
                                                ? colors.colorWhite
                                                : const Color(0xff666666),
                                            value: InvestType.intraday,
                                            groupValue: orderInput.investType,
                                            onChanged: (InvestType? value) {
                                              orderInput.chngInvesType(
                                                  value!, "PlcOrder");
                                              if (orderType != "GTT") {
                                                marginUpdate();
                                              }
                                            },
                                          ),
                                          Text('Intraday',
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? Color(orderInput
                                                                  .investType ==
                                                              InvestType
                                                                  .intraday
                                                          ? 0xffffffff
                                                          : 0xff666666)
                                                      : Color(orderInput
                                                                  .investType ==
                                                              InvestType
                                                                  .intraday
                                                          ? 0xff3E4763
                                                          : 0xff666666),
                                                  14,
                                                  FontWeight.w500))
                                        ],
                                        Radio<InvestType>(
                                          fillColor: WidgetStateProperty
                                              .resolveWith<Color>(
                                                  (Set<WidgetState> states) {
                                            if (states.contains(
                                                WidgetState.disabled)) {
                                              return const Color(0xff666666);
                                            }
                                            return theme.isDarkMode
                                                ? colors.colorWhite
                                                : const Color(0xff666666);
                                          }),
                                          activeColor: theme.isDarkMode
                                              ? colors.colorWhite
                                              : const Color(0xff666666),
                                          value: widget.scripInfo.seg == "EQT"
                                              ? InvestType.delivery
                                              : InvestType.carryForward,
                                          groupValue: orderInput.investType,
                                          onChanged: (InvestType? value) {
                                            orderInput.chngInvesType(
                                                value!, "PlcOrder");
                                            if (orderType != "GTT") {
                                              marginUpdate();
                                            }
                                          },
                                        ),
                                        Text(
                                            widget.scripInfo.seg == "EQT"
                                                ? 'Delivery'
                                                : "Carry Forward",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? Color(orderInput
                                                                    .investType ==
                                                                InvestType
                                                                    .delivery ||
                                                            orderInput
                                                                    .investType ==
                                                                InvestType
                                                                    .carryForward
                                                        ? 0xffffffff
                                                        : 0xff666666)
                                                    : Color(orderInput
                                                                    .investType ==
                                                                InvestType
                                                                    .delivery ||
                                                            orderInput
                                                                    .investType ==
                                                                InvestType
                                                                    .carryForward
                                                        ? 0xff3E4763
                                                        : 0xff666666),
                                                14,
                                                FontWeight.w500))
                                      ]),
                                ],
                              ),
                              const SizedBox(height: 8)
                            ],
                            Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: headerTitleText("Price type", theme)),
                            const SizedBox(height: 10),
                            Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: SizedBox(
                                    height: 38,
                                    child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  priceType =
                                                      priceTypes[index]['type'];
                                                  if (priceType == "Market" ||
                                                      priceType == "SL MKT") {
                                                    priceCtrl.text = "Market";

                                                    double ltp = (double.parse(
                                                                "${widget.orderArg.ltp}") *
                                                            double.parse(
                                                                mktProtCtrl.text
                                                                        .isEmpty
                                                                    ? "0"
                                                                    : mktProtCtrl
                                                                        .text)) /
                                                        100;

                                                    if (isBuy!) {
                                                      price = (double.parse(
                                                                  "${widget.orderArg.ltp ?? 0.00}") +
                                                              ltp)
                                                          .toStringAsFixed(2);
                                                    } else {
                                                      price = (double.parse(
                                                                  "${widget.orderArg.ltp ?? 0.00}") -
                                                              ltp)
                                                          .toStringAsFixed(2);
                                                    }
                                                    double result = double
                                                            .parse(price) +
                                                        (double.parse(
                                                                "${widget.scripInfo.ti}") /
                                                            2);
                                                    result -= result %
                                                        double.parse(
                                                            "${widget.scripInfo.ti}");

                                                    if (result >=
                                                        double.parse(
                                                            "${widget.scripInfo.uc ?? 0.00}")) {
                                                      price =
                                                          "${widget.scripInfo.uc}";
                                                    } else if (result <=
                                                        double.parse(
                                                            "${widget.scripInfo.lc ?? 0.00}")) {
                                                      price =
                                                          "${widget.scripInfo.lc}";
                                                    } else {
                                                      price = result
                                                          .toStringAsFixed(2);
                                                    }

                                                    log("Price $result");
                                                  } else {
                                                    priceCtrl.text =
                                                        "${widget.orderArg.ltp}";
                                                    price = priceCtrl.text;
                                                  }
                                                  orderInput.chngPriceType(
                                                      priceTypes[index]['type'],
                                                      widget.orderArg.exchange);
                                                });
                                                marginUpdate();
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 0),
                                                  backgroundColor: !theme
                                                          .isDarkMode
                                                      ? priceType !=
                                                              priceTypes[index]
                                                                  ['type']
                                                          ? const Color(
                                                              0xffF1F3F8)
                                                          : colors.colorBlack
                                                      : priceType !=
                                                              priceTypes[index]
                                                                  ['type']
                                                          ? colors.darkGrey
                                                          : colors.colorWhite,
                                                  shape: const StadiumBorder()),
                                              child: Text(
                                                  priceTypes[index]['type'],
                                                  style: textStyle(
                                                      !theme.isDarkMode
                                                          ? priceType !=
                                                                  priceTypes[
                                                                          index]
                                                                      ['type']
                                                              ? const Color(
                                                                  0xff666666)
                                                              : colors
                                                                  .colorWhite
                                                          : priceType !=
                                                                  priceTypes[
                                                                          index]
                                                                      ['type']
                                                              ? const Color(
                                                                  0xff666666)
                                                              : colors
                                                                  .colorBlack,
                                                      14,
                                                      priceType ==
                                                              priceTypes[index]
                                                                  ['type']
                                                          ? FontWeight.w600
                                                          : FontWeight.w500)));
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(width: 8);
                                        },
                                        itemCount: orderType == "Cover" ||
                                                orderType == "Bracket"
                                            ? 3
                                            : priceTypes.length))),
                            const SizedBox(height: 3),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  headerTitleText(
                                                      "Quantity ", theme),
                                                  Text(
                                                    "Lot: ${widget.scripInfo.ls}   ",
                                                    style: textStyle(
                                                        const Color(0xff777777),
                                                        11,
                                                        FontWeight.w600),
                                                  )
                                                ]),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                                height: 44,
                                                child: CustomTextFormField(
                                                  fillColor: theme.isDarkMode
                                                      ? colors.darkGrey
                                                      : const Color(0xffF1F3F8),
                                                  hintText: qtyCtrl.text,
                                                  hintStyle: textStyle(
                                                      const Color(0xff666666),
                                                      15,
                                                      FontWeight.w400),
                                                  inputFormate: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      16,
                                                      FontWeight.w600),
                                                  prefixIcon: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (qtyCtrl
                                                            .text.isNotEmpty) {
                                                          if (int.parse(qtyCtrl
                                                                  .text) >
                                                              lotSize) {
                                                            qtyCtrl.text =
                                                                (int.parse(qtyCtrl
                                                                            .text) -
                                                                        lotSize)
                                                                    .toString();
                                                          }
                                                        } else {
                                                          qtyCtrl.text =
                                                              "$lotSize";
                                                        }
                                                      });
                                                    },
                                                    child: SvgPicture.asset(
                                                      theme.isDarkMode
                                                          ? assets.darkCMinus
                                                          : assets.minusIcon,
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                  suffixIcon: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (qtyCtrl
                                                            .text.isNotEmpty) {
                                                          qtyCtrl.text =
                                                              (int.parse(qtyCtrl
                                                                          .text) +
                                                                      lotSize)
                                                                  .toString();
                                                        } else {
                                                          qtyCtrl.text =
                                                              "$lotSize";
                                                        }
                                                      });
                                                    },
                                                    child: SvgPicture.asset(
                                                        theme.isDarkMode
                                                            ? assets.darkAdd
                                                            : assets.addIcon,
                                                        fit: BoxFit.scaleDown),
                                                  ),
                                                  textCtrl: qtyCtrl,
                                                  textAlign: TextAlign.center,
                                                  onChanged: (value) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .hideCurrentSnackBar();
                                                    if (value.isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Quntity can not be empty"));
                                                    }
                                                  },
                                                )),
                                            if (widget.scripInfo.frzqty !=
                                                null) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                  "Frz Qty : ${widget.scripInfo.frzqty}",
                                                  style: textStyle(
                                                      const Color(0xff666666),
                                                      12,
                                                      FontWeight.w500))
                                            ]
                                          ])),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                headerTitleText("Price", theme),
                                                Text(
                                                  "Tick: ${widget.scripInfo.ti} ",
                                                  style: textStyle(
                                                      const Color(0xff777777),
                                                      11,
                                                      FontWeight.w600),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                                height: 44,
                                                child: CustomTextFormField(
                                                    fillColor: theme.isDarkMode
                                                        ? colors.darkGrey
                                                        : const Color(
                                                            0xffF1F3F8),
                                                    onChanged: (value) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .hideCurrentSnackBar();
                                                      if (value.isEmpty) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Price can not be empty"));
                                                      } else {
                                                        setState(() {
                                                          price = value;
                                                        });
                                                      }
                                                    },
                                                    hintText:
                                                        "${widget.orderArg.ltp}",
                                                    hintStyle: textStyle(
                                                        const Color(0xff666666),
                                                        15,
                                                        FontWeight.w400),
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        16,
                                                        FontWeight.w600),
                                                    isReadable: priceType == "Limit" || priceType == "SL Limit"
                                                        ? false
                                                        : true,
                                                    prefixIcon: Container(
                                                        margin: const EdgeInsets.all(
                                                            12),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(
                                                                20),
                                                            color: theme.isDarkMode
                                                                ? const Color(
                                                                    0xff555555)
                                                                : colors
                                                                    .colorWhite),
                                                        child: SvgPicture.asset(
                                                            color: theme.isDarkMode
                                                                ? colors.colorWhite
                                                                : colors.colorGrey,
                                                            priceType == "Limit" || priceType == "SL Limit" ? assets.ruppeIcon : assets.lock,
                                                            fit: BoxFit.scaleDown)),
                                                    textCtrl: priceCtrl,
                                                    textAlign: TextAlign.start)),
                                          ]))
                                    ])),
                            const SizedBox(height: 3),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider),
                            if (priceType == "SL Limit" ||
                                priceType == "SL MKT")
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 2),
                                        headerTitleText("Trigger", theme),
                                        const SizedBox(height: 7),
                                        SizedBox(
                                            height: 44,
                                            child: CustomTextFormField(
                                                fillColor: theme.isDarkMode
                                                    ? colors.darkGrey
                                                    : const Color(0xffF1F3F8),
                                                hintText: "0.00",
                                                hintStyle: textStyle(
                                                    const Color(0xff666666),
                                                    15,
                                                    FontWeight.w400),
                                                onChanged: (value) {
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                  if (value.isNotEmpty) {
                                                    if (isBuy!) {
                                                      if (double.parse(value) <
                                                          double.parse(price)) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Greater than Last Trade Price"));
                                                      } else if (double.parse(
                                                              value) <
                                                          double.parse(
                                                              "${priceCtrl.text.isEmpty ? 0.00 : priceCtrl.text == "Market" ? price : priceCtrl.text}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Greater than Limit Price"));
                                                      }
                                                    } else {
                                                      if (double.parse(value) >
                                                          double.parse(
                                                              "${widget.orderArg.ltp ?? 0.00}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Lesser than Last Trade Price"));
                                                      } else if (double.parse(
                                                              value) >
                                                          double.parse(
                                                              "${priceCtrl.text.isEmpty ? 0.00 : price}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Lesser than Limit Price"));
                                                      }
                                                    }
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be empty"));
                                                  }
                                                },
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    16,
                                                    FontWeight.w600),
                                                prefixIcon: Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        color: theme.isDarkMode
                                                            ? const Color(
                                                                0xff555555)
                                                            : colors
                                                                .colorWhite),
                                                    child: SvgPicture.asset(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorGrey,
                                                        assets.ruppeIcon,
                                                        fit: BoxFit.scaleDown)),
                                                textCtrl: triggerPriceCtrl,
                                                textAlign: TextAlign.start)),
                                        const SizedBox(height: 10),
                                      ])),
                            if (priceType == "SL Limit" ||
                                priceType == "SL MKT")
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider,
                                  height: 2),
                            if (addStoploss) ...[
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (orderType == "Bracket") ...[
                                          priceType == "SL Limit"
                                              ? const SizedBox(height: 10)
                                              : Container(),
                                          headerTitleText("Target", theme),
                                          const SizedBox(height: 7),
                                          SizedBox(
                                              height: 44,
                                              child: CustomTextFormField(
                                                  fillColor: theme.isDarkMode
                                                      ? colors.darkGrey
                                                      : const Color(0xffF1F3F8),
                                                  hintText: "0.00",
                                                  onChanged: (value) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .hideCurrentSnackBar();
                                                    if (value.isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Target can not be empty"));
                                                    }
                                                  },
                                                  hintStyle: textStyle(
                                                      const Color(0xff666666),
                                                      15,
                                                      FontWeight.w400),
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      16,
                                                      FontWeight.w600),
                                                  prefixIcon: Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        color: theme.isDarkMode
                                                            ? const Color(
                                                                0xff555555)
                                                            : colors
                                                                .colorWhite),
                                                    child: SvgPicture.asset(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorGrey,
                                                        assets.ruppeIcon,
                                                        fit: BoxFit.scaleDown),
                                                  ),
                                                  textCtrl: targetCtrl,
                                                  textAlign: TextAlign.start)),
                                          const SizedBox(height: 10)
                                        ],
                                        headerTitleText("Stoploss", theme),
                                        const SizedBox(height: 7),
                                        SizedBox(
                                            height: 44,
                                            child: CustomTextFormField(
                                                fillColor: theme.isDarkMode
                                                    ? colors.darkGrey
                                                    : const Color(0xffF1F3F8),
                                                onChanged: (value) {
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                  if (value.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Stoploss can not be empty"));
                                                  }
                                                },
                                                hintText: "0.00",
                                                hintStyle: textStyle(
                                                    const Color(0xff666666),
                                                    15,
                                                    FontWeight.w400),
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    16,
                                                    FontWeight.w600),
                                                prefixIcon: Container(
                                                  margin:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: theme.isDarkMode
                                                          ? const Color(
                                                              0xff555555)
                                                          : colors.colorWhite),
                                                  child: SvgPicture.asset(
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorGrey,
                                                      assets.ruppeIcon,
                                                      fit: BoxFit.scaleDown),
                                                ),
                                                textCtrl: stopLossCtrl,
                                                textAlign: TextAlign.start)),
                                      ]))
                            ],
                            if (orderType != "Regular" &&
                                orderType != "MTF") ...[
                              const SizedBox(height: 12),
                              const ListDivider()
                            ],
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 4),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Add Validity & Disclosed Qty",
                                          style: textStyle(
                                              const Color(0xff666666),
                                              14,
                                              FontWeight.w500)),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              addValidity = !addValidity;
                                            });
                                          },
                                          icon: SvgPicture.asset(theme
                                                  .isDarkMode
                                              ? addValidity
                                                  ? assets.darkCheckedboxIcon
                                                  : assets.darkCheckboxIcon
                                              : addValidity
                                                  ? assets.checkedbox
                                                  : assets.checkbox)),
                                    ])),
                            if (addValidity) ...[
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              headerTitleText(
                                                  "Validity", theme),
                                              const SizedBox(height: 7),
                                              SizedBox(
                                                height: 38,
                                                child: ListView.separated(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            validityType =
                                                                validityTypes[
                                                                    index];
                                                          });
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                elevation: 0,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        0),
                                                                backgroundColor: !theme
                                                                        .isDarkMode
                                                                    ? validityType !=
                                                                            validityTypes[
                                                                                index]
                                                                        ? const Color(
                                                                            0xffF1F3F8)
                                                                        : colors
                                                                            .colorBlack
                                                                    : validityType !=
                                                                            validityTypes[
                                                                                index]
                                                                        ? colors
                                                                            .darkGrey
                                                                        : colors
                                                                            .colorWhite,
                                                                shape:
                                                                    const StadiumBorder()),
                                                        child: Text(
                                                          validityTypes[index],
                                                          style: textStyle(
                                                              !theme.isDarkMode
                                                                  ? validityType !=
                                                                          validityTypes[
                                                                              index]
                                                                      ? const Color(
                                                                          0xff666666)
                                                                      : colors
                                                                          .colorWhite
                                                                  : validityType !=
                                                                          validityTypes[
                                                                              index]
                                                                      ? const Color(
                                                                          0xff666666)
                                                                      : colors
                                                                          .colorBlack,
                                                              14,
                                                              validityType ==
                                                                      validityTypes[
                                                                          index]
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .w500),
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return const SizedBox(
                                                          width: 8);
                                                    },
                                                    itemCount: widget.orderArg
                                                                    .exchange ==
                                                                "BSE" ||
                                                            widget.orderArg
                                                                    .exchange ==
                                                                "BFO"
                                                        ? validityType.length
                                                        : 2),
                                              )
                                            ])),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              headerTitleText(
                                                  "Disclosed Qty", theme),
                                              const SizedBox(height: 7),
                                              SizedBox(
                                                  height: 44,
                                                  child: CustomTextFormField(
                                                      fillColor:
                                                          theme.isDarkMode
                                                              ? colors.darkGrey
                                                              : const Color(
                                                                  0xffF1F3F8),
                                                      // type:"int",
                                                      hintText: "0",
                                                      hintStyle: textStyle(
                                                          const Color(
                                                              0xff666666),
                                                          15,
                                                          FontWeight.w400),
                                                      inputFormate: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      style: textStyle(
                                                          theme.isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          16,
                                                          FontWeight.w600),
                                                      prefixIcon: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (discQtyCtrl.text
                                                                .isNotEmpty) {
                                                              if (int.parse(
                                                                      discQtyCtrl
                                                                          .text) >
                                                                  0) {
                                                                discQtyCtrl
                                                                        .text =
                                                                    (int.parse(discQtyCtrl.text) -
                                                                            1)
                                                                        .toString();
                                                              } else {
                                                                discQtyCtrl
                                                                    .text = "0";
                                                              }
                                                            } else {
                                                              discQtyCtrl.text =
                                                                  "0";
                                                            }
                                                          });
                                                        },
                                                        child: SvgPicture.asset(
                                                            theme.isDarkMode
                                                                ? assets
                                                                    .darkCMinus
                                                                : assets
                                                                    .minusIcon,
                                                            fit: BoxFit
                                                                .scaleDown),
                                                      ),
                                                      suffixIcon: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (discQtyCtrl.text
                                                                .isNotEmpty) {
                                                              discQtyCtrl.text =
                                                                  (int.parse(discQtyCtrl
                                                                              .text) +
                                                                          1)
                                                                      .toString();
                                                            } else {
                                                              discQtyCtrl.text =
                                                                  "0";
                                                            }
                                                          });
                                                        },
                                                        child: SvgPicture.asset(
                                                            theme.isDarkMode
                                                                ? assets.darkAdd
                                                                : assets
                                                                    .addIcon,
                                                            fit: BoxFit
                                                                .scaleDown),
                                                      ),
                                                      textCtrl: discQtyCtrl,
                                                      textAlign:
                                                          TextAlign.center))
                                            ]))
                                      ])),
                              const SizedBox(height: 10)
                            ],
                            const ListDivider(),
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 4),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("After Market Order (AMO)",
                                          style: textStyle(
                                              const Color(0xff666666),
                                              14,
                                              FontWeight.w500)),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isAmo = !isAmo;
                                            });
                                          },
                                          icon: SvgPicture.asset(theme
                                                  .isDarkMode
                                              ? isAmo
                                                  ? assets.darkCheckedboxIcon
                                                  : assets.darkCheckboxIcon
                                              : isAmo
                                                  ? assets.checkedbox
                                                  : assets.checkbox)),
                                    ])),
                            SizedBox(height: priceType == "Market" ? 180 : 100)
                          ],
                        )),
                    if (internet.connectionStatus ==
                        ConnectivityResult.none) ...[const NoInternetWidget()]
                  ],
                ),
                bottomSheet: internet.connectionStatus ==
                        ConnectivityResult.none
                    ? const NoInternetWidget()
                    : orderType == "GTT"
                        ? null
                        : Container(
                            color: theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (priceType == "Market" ||
                                      priceType == "SL MKT") ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, bottom: 6),
                                      child: headerTitleText(
                                          "Market Production", theme),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, bottom: 6),
                                        height: 40,
                                        child: Row(children: [
                                          Expanded(
                                              child: CustomTextFormField(
                                                  fillColor: theme.isDarkMode
                                                      ? colors.darkGrey
                                                      : const Color(0xffF1F3F8),
                                                  inputFormate: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .hideCurrentSnackBar();
                                                      if (value.isNotEmpty) {
                                                        if (int.parse(value) >
                                                            20) {
                                                          mktProtCtrl.text =
                                                              "20";
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  warningMessage(
                                                                      context,
                                                                      "can't enter greater than 20% of market production"));
                                                        } else if (int.parse(
                                                                value) <
                                                            1) {
                                                          mktProtCtrl.text =
                                                              "1";
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  warningMessage(
                                                                      context,
                                                                      "can't enter less than 1% of market production"));
                                                        }
                                                      }
                                                    });
                                                  },
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w600),
                                                  textCtrl: mktProtCtrl,
                                                  textAlign: TextAlign.start))
                                        ]))
                                  ],
                                  Container(
                                      height: 36,
                                      decoration: BoxDecoration(
                                          color: theme.isDarkMode
                                              ? colors.darkGrey
                                              : const Color(0xfffafbff),
                                          border: Border(
                                              top: BorderSide(
                                                  color: theme.isDarkMode
                                                      ? colors.darkColorDivider
                                                      : colors.colorDivider),
                                              bottom: BorderSide(
                                                  color: theme.isDarkMode
                                                      ? colors.darkColorDivider
                                                      : colors.colorDivider))),
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 3, top: 0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(children: [
                                              CustomWidgetButton(
                                                  onPress: internet
                                                              .connectionStatus ==
                                                          ConnectivityResult
                                                              .none
                                                      ? () {}
                                                      : () {
                                                          marginUpdate();
                                                          showModalBottomSheet(
                                                              useSafeArea: true,
                                                              isScrollControlled:
                                                                  true,
                                                              shape: const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                              16))),
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return const MarginDetailsBottomsheet();
                                                              });
                                                        },
                                                  widget: Row(children: [
                                                    Text("Margin: ",
                                                        style: textStyle(
                                                            const Color(
                                                                0xff666666),
                                                            12,
                                                            FontWeight.w500)),
                                                    Text(
                                                        "₹${orderProvide.orderMarginModel == null ? 0.00 : orderProvide.orderMarginModel!.marginused}",
                                                        style: textStyle(
                                                            !theme.isDarkMode
                                                                ? colors
                                                                    .colorBlue
                                                                : colors
                                                                    .colorLightBlue,
                                                            12,
                                                            FontWeight.w600)),
                                                    Icon(
                                                      Icons.arrow_drop_down,
                                                      color: !theme.isDarkMode
                                                          ? colors.colorBlue
                                                          : colors
                                                              .colorLightBlue,
                                                    )
                                                  ])),
                                              const SizedBox(width: 20),
                                              CustomWidgetButton(
                                                onPress: internet
                                                            .connectionStatus ==
                                                        ConnectivityResult.none
                                                    ? () {}
                                                    : () {
                                                        BrokerageInput
                                                            brokerageInput =
                                                            BrokerageInput(
                                                                exch:
                                                                    "${widget.scripInfo.exch}",
                                                                prc: priceCtrl
                                                                    .text,
                                                                prd: orderInput
                                                                    .orderType,
                                                                qty:
                                                                    "${widget.scripInfo.ls}",
                                                                trantype: isBuy!
                                                                    ? "B"
                                                                    : "S",
                                                                tsym:
                                                                    "${widget.scripInfo.tsym}");
                                                        context
                                                            .read(orderProvider)
                                                            .fetchGetBrokerage(
                                                                brokerageInput,
                                                                context);
                                                        showModalBottomSheet(
                                                            useSafeArea: true,
                                                            isScrollControlled:
                                                                true,
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .vertical(
                                                                            top:
                                                                                Radius.circular(16))),
                                                            context: context,
                                                            builder: (context) {
                                                              return const ChargesDetailsBottomsheet();
                                                            });
                                                      },
                                                widget: Row(children: [
                                                  Text("Charges: ",
                                                      style: textStyle(
                                                          const Color(
                                                              0xff666666),
                                                          12,
                                                          FontWeight.w500)),
                                                  Text(
                                                      "₹${orderProvide.getBrokerageModel == null ? 0.00 : orderProvide.getBrokerageModel!.brkageAmt ?? 0.00}",
                                                      style: textStyle(
                                                          !theme.isDarkMode
                                                              ? colors.colorBlue
                                                              : colors
                                                                  .colorLightBlue,
                                                          12,
                                                          FontWeight.w600)),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    color: !theme.isDarkMode
                                                        ? colors.colorBlue
                                                        : colors.colorLightBlue,
                                                  )
                                                ]),
                                              ),
                                            ]),
                                            IconButton(
                                                onPressed: internet
                                                            .connectionStatus ==
                                                        ConnectivityResult.none
                                                    ? null
                                                    : () {
                                                        marginUpdate();
                                                      },
                                                icon: SvgPicture.asset(
                                                    assets.reloadIcon))
                                          ])),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                        onPressed: internet.connectionStatus ==
                                                ConnectivityResult.none
                                            ? null
                                            : () async {
                                                setState(() {
                                                  if (frezQty == 0) {
                                                    quantity = int.parse(
                                                        qtyCtrl.text.isEmpty
                                                            ? "0"
                                                            : qtyCtrl.text);
                                                    // frezQty;
                                                  } else {
                                                    quantity = int.parse(qtyCtrl
                                                                .text.isEmpty
                                                            ? "0"
                                                            : qtyCtrl.text) ~/
                                                        frezQty;
                                                  }
                                                  reminder = int.parse(
                                                          qtyCtrl.text.isEmpty
                                                              ? "0"
                                                              : qtyCtrl.text) -
                                                      (frezQty * quantity);
                                                  maxQty = frezQty * 28;
                                                  print(
                                                      "objectobject{$quantity | $reminder}");
                                                });
                                                if (qtyCtrl.text.isEmpty ||
                                                    priceCtrl.text.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          qtyCtrl.text.isEmpty
                                                              ? "Quantity can not be empty"
                                                              : "Price can not be empty"));
                                                } else if ((int.parse(qtyCtrl.text.isEmpty ? "0" : qtyCtrl.text) > maxQty) &&
                                                    widget.scripInfo.exch !=
                                                        "BSE") {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          "Specified Quantity is more than the instrument maximum quantity of $maxQty"));
                                                } else if (qtyCtrl.text == "0" ||
                                                    priceCtrl.text == "0") {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          qtyCtrl.text == "0"
                                                              ? "Quantity can not be 0"
                                                              : "Price can not be 0"));
                                                } else if ((double.parse(price) <
                                                        double.parse(
                                                            "${widget.scripInfo.lc}")) ||
                                                    (double.parse(price) >
                                                        double.parse(
                                                            "${widget.scripInfo.uc}"))) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          double.parse(price) <
                                                                  double.parse(
                                                                      "${widget.scripInfo.lc}")
                                                              ? "Price can not be lesser than Lower Circuit Limit ${widget.scripInfo.lc}"
                                                              : "Price can not be greater than Upper Circuit Limit ${widget.scripInfo.uc}"));
                                                } else if (orderType == "Regular" &&
                                                    (priceType == "SL Limit" ||
                                                        priceType ==
                                                            "SL MKT")) {
                                                  if (triggerPriceCtrl
                                                          .text.isEmpty ||
                                                      triggerPriceCtrl.text ==
                                                          "0") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(warningMessage(
                                                            context,
                                                            triggerPriceCtrl
                                                                    .text
                                                                    .isEmpty
                                                                ? "Trigger can not be empty"
                                                                : "Trigger can not be 0"));
                                                  } else {
                                                    if (isBuy!) {
                                                      if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) <
                                                          double.parse(price)) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(warningMessage(
                                                                context,
                                                                priceType ==
                                                                        "SL MKT"
                                                                    ? "Trigger Should be Greater than Limit Price"
                                                                    : "Trigger Should be Greater than Last Trade Price"));
                                                      } else if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) <
                                                          double.parse(
                                                              "${priceCtrl.text.isEmpty ? 0.00 : price}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Greater than Limit Price"));
                                                      } else {
                                                        if ((int.parse(qtyCtrl
                                                                        .text
                                                                        .isEmpty
                                                                    ? "0"
                                                                    : qtyCtrl
                                                                        .text) >
                                                                frezQty &&
                                                            widget.scripInfo
                                                                    .frzqty !=
                                                                null)) {
                                                          placeOrder(orderInput,
                                                              true, theme);
                                                        } else {
                                                          placeOrder(orderInput,
                                                              false, theme);
                                                        }
                                                      }
                                                    } else {
                                                      if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) >
                                                          double.parse(
                                                              "${priceType == "SL MKT" ? price : widget.orderArg.ltp ?? 0.00}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Lesser than Last Trade Price"));
                                                      } else if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) >
                                                          double.parse(
                                                              "${priceCtrl.text.isEmpty ? 0.00 : price}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Lesser than Limit Price"));
                                                      } else {
                                                        if ((int.parse(qtyCtrl
                                                                        .text
                                                                        .isEmpty
                                                                    ? "0"
                                                                    : qtyCtrl
                                                                        .text) >
                                                                frezQty &&
                                                            widget.scripInfo
                                                                    .frzqty !=
                                                                null)) {
                                                          placeOrder(orderInput,
                                                              true, theme);
                                                        } else {
                                                          placeOrder(orderInput,
                                                              false, theme);
                                                        }
                                                      }
                                                    }
                                                  }
                                                } else if (orderType == "Cover" &&
                                                    (priceType == "Limit" ||
                                                        priceType ==
                                                            "Market")) {
                                                  if (stopLossCtrl
                                                          .text.isEmpty ||
                                                      stopLossCtrl.text ==
                                                          "0") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(warningMessage(
                                                            context,
                                                            stopLossCtrl.text
                                                                    .isEmpty
                                                                ? "Stoploss can not be empty"
                                                                : "Stoploss can not be 0"));
                                                  } else {
                                                    if ((int.parse(qtyCtrl.text
                                                                    .isEmpty
                                                                ? "0"
                                                                : qtyCtrl
                                                                    .text) >
                                                            frezQty &&
                                                        widget.scripInfo
                                                                .frzqty !=
                                                            null)) {
                                                      placeOrder(orderInput,
                                                          true, theme);
                                                    } else {
                                                      placeOrder(orderInput,
                                                          false, theme);
                                                    }
                                                  }
                                                } else if (orderType == "Cover" &&
                                                    (priceType == "SL Limit")) {
                                                  if (stopLossCtrl
                                                          .text.isEmpty ||
                                                      stopLossCtrl.text ==
                                                          "0") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(warningMessage(
                                                            context,
                                                            stopLossCtrl.text
                                                                    .isEmpty
                                                                ? "Stoploss can not be empty"
                                                                : "Stoploss can not be 0"));
                                                  } else if ((triggerPriceCtrl
                                                              .text.isEmpty ||
                                                          triggerPriceCtrl
                                                                  .text ==
                                                              "0") &&
                                                      priceType == "SL Limit") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(warningMessage(
                                                            context,
                                                            triggerPriceCtrl
                                                                    .text
                                                                    .isEmpty
                                                                ? "Trigger can not be empty"
                                                                : "Trigger can not be 0"));
                                                  } else {
                                                    if (isBuy!) {
                                                      if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) <
                                                          double.parse(
                                                              "${priceType == "SL MKT" ? price : widget.orderArg.ltp ?? 0.00}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(warningMessage(
                                                                context,
                                                                priceType ==
                                                                        "SL MKT"
                                                                    ? "Trigger Should be Greater than Limit Price"
                                                                    : "Trigger Should be Greater than Last Trade Price"));
                                                      } else if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) <
                                                          double.parse(
                                                              "${priceCtrl.text.isEmpty ? 0.00 : price}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Greater than Limit Price"));
                                                      } else {
                                                        if ((int.parse(qtyCtrl
                                                                        .text
                                                                        .isEmpty
                                                                    ? "0"
                                                                    : qtyCtrl
                                                                        .text) >
                                                                frezQty &&
                                                            widget.scripInfo
                                                                    .frzqty !=
                                                                null)) {
                                                          placeOrder(orderInput,
                                                              true, theme);
                                                        } else {
                                                          placeOrder(orderInput,
                                                              false, theme);
                                                        }
                                                      }
                                                    } else {
                                                      if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) >
                                                          double.parse(
                                                              "${priceType == "SL MKT" ? price : widget.orderArg.ltp ?? 0.00}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Lesser than Last Trade Price"));
                                                      } else if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) >
                                                          double.parse(
                                                              "${priceCtrl.text.isEmpty ? 0.00 : price}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Lesser than Price"));
                                                      } else {
                                                        if ((int.parse(qtyCtrl
                                                                        .text
                                                                        .isEmpty
                                                                    ? "0"
                                                                    : qtyCtrl
                                                                        .text) >
                                                                frezQty &&
                                                            widget.scripInfo
                                                                    .frzqty !=
                                                                null)) {
                                                          placeOrder(orderInput,
                                                              true, theme);
                                                        } else {
                                                          placeOrder(orderInput,
                                                              false, theme);
                                                        }
                                                      }
                                                    }
                                                  }
                                                } else if (orderType == "Bracket" &&
                                                    (priceType == "Limit" ||
                                                        priceType ==
                                                            "Market")) {
                                                  if (stopLossCtrl
                                                          .text.isEmpty ||
                                                      targetCtrl.text.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "${stopLossCtrl.text.isEmpty ? "Stoploss" : "Target"} can not be empty"));
                                                  } else {
                                                    if ((int.parse(qtyCtrl.text
                                                                    .isEmpty
                                                                ? "0"
                                                                : qtyCtrl
                                                                    .text) >
                                                            frezQty &&
                                                        widget.scripInfo
                                                                .frzqty !=
                                                            null)) {
                                                      placeOrder(orderInput,
                                                          true, theme);
                                                    } else {
                                                      placeOrder(orderInput,
                                                          false, theme);
                                                    }
                                                  }
                                                } else if (orderType == "Bracket" &&
                                                    (priceType == "SL Limit")) {
                                                  if (stopLossCtrl
                                                          .text.isEmpty ||
                                                      targetCtrl.text.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "${stopLossCtrl.text.isEmpty ? "Stoploss" : "Target"} can not be empty"));
                                                  } else if (triggerPriceCtrl
                                                          .text.isEmpty &&
                                                      priceType == "SL Limit") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be empty"));
                                                  } else {
                                                    if (isBuy!) {
                                                      if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) <
                                                          double.parse(
                                                              "${priceType == "SL MKT" ? price : widget.orderArg.ltp ?? 0.00}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(warningMessage(
                                                                context,
                                                                priceType ==
                                                                        "SL MKT"
                                                                    ? "Trigger Should be Greater than Limit Price"
                                                                    : "Trigger Should be Greater than Last Trade Price"));
                                                      } else if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) <
                                                          double.parse(
                                                              "${priceCtrl.text.isEmpty ? 0.00 : price}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Greater than Limit Price"));
                                                      } else {
                                                        if ((int.parse(qtyCtrl
                                                                        .text
                                                                        .isEmpty
                                                                    ? "0"
                                                                    : qtyCtrl
                                                                        .text) >
                                                                frezQty &&
                                                            widget.scripInfo
                                                                    .frzqty !=
                                                                null)) {
                                                          placeOrder(orderInput,
                                                              true, theme);
                                                        } else {
                                                          placeOrder(orderInput,
                                                              false, theme);
                                                        }
                                                      }
                                                    } else {
                                                      if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) >
                                                          double.parse(
                                                              "${priceType == "SL MKT" ? price : widget.orderArg.ltp ?? 0.00}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Lesser than Last Trade Price"));
                                                      } else if (double.parse(
                                                              triggerPriceCtrl
                                                                  .text) >
                                                          double.parse(
                                                              "${priceCtrl.text.isEmpty ? 0.00 : price}")) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Trigger Should be Lesser than Limit Price"));
                                                      } else {
                                                        if (int.parse(qtyCtrl
                                                                        .text
                                                                        .isEmpty
                                                                    ? "0"
                                                                    : qtyCtrl
                                                                        .text) >
                                                                frezQty &&
                                                            widget.scripInfo
                                                                    .frzqty !=
                                                                null) {
                                                          placeOrder(orderInput,
                                                              true, theme);
                                                        } else {
                                                          placeOrder(orderInput,
                                                              false, theme);
                                                        }
                                                      }
                                                    }
                                                  }
                                                } else {
                                                  if ((int.parse(qtyCtrl
                                                                  .text.isEmpty
                                                              ? "0"
                                                              : qtyCtrl.text) >
                                                          frezQty &&
                                                      widget.scripInfo.frzqty !=
                                                          null)) {
                                                    placeOrder(orderInput, true,
                                                        theme);
                                                  } else {
                                                    placeOrder(orderInput,
                                                        false, theme);
                                                  }
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            backgroundColor: Color(isBuy!
                                                ? 0xff43A833
                                                : 0xffFF1717),
                                            shape: const StadiumBorder()),
                                        child: Text(
                                            isBuy! ? 'Buy Now' : "Sell Now",
                                            style: textStyle(
                                                const Color(0xffffffff),
                                                14,
                                                FontWeight.w600))),
                                  ),
                                  if (defaultTargetPlatform ==
                                      TargetPlatform.iOS)
                                    const SizedBox(height: 18)
                                ]))));
      }),
    );
  }

  placeOrder(OrderInputProvider orderInput, bool isSliceOrd,
      ThemesProvider theme) async {
    print("price tye $priceType");

    if (!isSliceOrd) {
      PlaceOrderInput placeOrderInput = PlaceOrderInput(
        amo: isAmo ? "Yes" : "",
        blprc: orderType == "Cover" || orderType == "Bracket"
            ? stopLossCtrl.text
            : '',
        bpprc: orderType == "Bracket" ? targetCtrl.text : '',
        dscqty: discQtyCtrl.text,
        exch: widget.scripInfo.exch!,
        prc: ((widget.scripInfo.exch == "MCX" ||
                    widget.scripInfo.exch == "BSE") &&
                (priceType == "Market" || priceType == "SL MKT"))
            ? "0"
            : price,
        prctype: orderInput.prcType,
        prd: orderInput.orderType,
        qty: qtyCtrl.text,
        ret: validityType,
        trailprc: '',
        trantype: isBuy! ? 'B' : 'S',
        trgprc: priceType == "SL Limit" || priceType == "SL MKT"
            ? triggerPriceCtrl.text
            : "",
        tsym: widget.scripInfo.tsym!,
        mktProt: priceType == "Market" || priceType == "SL MKT"
            ? mktProtCtrl.text
            : '',
        channel: '',
        userAgent: '',
        appInstaId: '',
      );
      await context
          .read(orderProvider)
          .fetchPlaceOrder(context, placeOrderInput, widget.orderArg.isExit);
    } else {
      showModalBottomSheet(
          isScrollControlled: true,
          useSafeArea: true,
          isDismissible: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          context: context,
          builder: (context) => Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xff999999),
                        blurRadius: 4.0,
                        offset: Offset(2.0, 0.0))
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomDragHandler(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Slice Order",
                          style: textStyles.appBarTitleTxt.copyWith(
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack)),
                    ),
                    Divider(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("${widget.scripInfo.symbol} ",
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack)),
                                  Text("${widget.scripInfo.option}",
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  CustomExchBadge(
                                      exch: "${widget.scripInfo.exch}"),
                                  Text("${widget.scripInfo.expDate}",
                                      style: textStyles.scripExchTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Qty: $frezQty ",
                                  style: textStyles.scripNameTxtStyle.copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack)),
                              Text(" X ${quantity >= 28 ? 28 : quantity}",
                                  style: textStyles.scripExchTxtStyle.copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (reminder != 0) ...[
                      Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("${widget.scripInfo.symbol} ",
                                        style: textStyles.scripNameTxtStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack)),
                                    Text("${widget.scripInfo.option}",
                                        style: textStyles.scripNameTxtStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    CustomExchBadge(
                                        exch: "${widget.scripInfo.exch}"),
                                    Text("${widget.scripInfo.expDate}",
                                        style: textStyles.scripExchTxtStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack)),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Qty: $reminder ",
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack)),
                                Text(" X 1",
                                    style: textStyles.scripExchTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6)
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (quantity >= 28) {
                              for (var i = 0; i < 28; i++) {
                                PlaceOrderInput placeOrderInput =
                                    PlaceOrderInput(
                                  amo: isAmo ? "Yes" : "",
                                  blprc: orderType == "Cover" ||
                                          orderType == "Bracket"
                                      ? stopLossCtrl.text
                                      : '',
                                  bpprc: orderType == "Bracket"
                                      ? targetCtrl.text
                                      : '',
                                  dscqty: discQtyCtrl.text,
                                  exch: widget.scripInfo.exch!,
                                  prc: ((widget.scripInfo.exch == "MCX" ||
                                              widget.scripInfo.exch == "BSE") &&
                                          (priceType == "Market" ||
                                              priceType == "SL MKT"))
                                      ? "0"
                                      : price,
                                  prctype: orderInput.prcType,
                                  prd: orderInput.orderType,
                                  qty: "$frezQty",
                                  ret: validityType,
                                  trailprc: '',
                                  trantype: isBuy! ? 'B' : 'S',
                                  trgprc: priceType == "SL Limit" ||
                                          priceType == "SL MKT"
                                      ? triggerPriceCtrl.text
                                      : "",
                                  tsym: widget.scripInfo.tsym!,
                                  mktProt: priceType == "Market" ||
                                          priceType == "SL MKT"
                                      ? mktProtCtrl.text
                                      : '',
                                  channel: '',
                                  userAgent: '',
                                  appInstaId: '',
                                );
                                await context
                                    .read(orderProvider)
                                    .slicePlaceOrder(context, placeOrderInput);
                              }
                            } else {
                              for (var i = 0; i < quantity; i++) {
                                PlaceOrderInput placeOrderInput =
                                    PlaceOrderInput(
                                  amo: isAmo ? "Yes" : "",
                                  blprc: orderType == "Cover" ||
                                          orderType == "Bracket"
                                      ? stopLossCtrl.text
                                      : '',
                                  bpprc: orderType == "Bracket"
                                      ? targetCtrl.text
                                      : '',
                                  dscqty: discQtyCtrl.text,
                                  exch: widget.scripInfo.exch!,
                                  prc: ((widget.scripInfo.exch == "MCX" ||
                                              widget.scripInfo.exch == "BSE") &&
                                          (priceType == "Market" ||
                                              priceType == "SL MKT"))
                                      ? "0"
                                      : price,
                                  prctype: orderInput.prcType,
                                  prd: orderInput.orderType,
                                  qty: "$frezQty",
                                  ret: validityType,
                                  trailprc: '',
                                  trantype: isBuy! ? 'B' : 'S',
                                  trgprc: priceType == "SL Limit" ||
                                          priceType == "SL MKT"
                                      ? triggerPriceCtrl.text
                                      : "",
                                  tsym: widget.scripInfo.tsym!,
                                  mktProt: priceType == "Market" ||
                                          priceType == "SL MKT"
                                      ? mktProtCtrl.text
                                      : '',
                                  channel: '',
                                  userAgent: '',
                                  appInstaId: '',
                                );
                                await context
                                    .read(orderProvider)
                                    .slicePlaceOrder(context, placeOrderInput);
                              }
                            }

                            if (reminder != 0) {
                              PlaceOrderInput placeOrderInput = PlaceOrderInput(
                                amo: isAmo ? "Yes" : "",
                                blprc: orderType == "Cover" ||
                                        orderType == "Bracket"
                                    ? stopLossCtrl.text
                                    : '',
                                bpprc: orderType == "Bracket"
                                    ? targetCtrl.text
                                    : '',
                                dscqty: discQtyCtrl.text,
                                exch: widget.scripInfo.exch!,
                                prc: ((widget.scripInfo.exch == "MCX" ||
                                            widget.scripInfo.exch == "BSE") &&
                                        (priceType == "Market" ||
                                            priceType == "SL MKT"))
                                    ? "0"
                                    : price,
                                prctype: orderInput.prcType,
                                prd: orderInput.orderType,
                                qty: "$reminder",
                                ret: validityType,
                                trailprc: '',
                                trantype: isBuy! ? 'B' : 'S',
                                trgprc: priceType == "SL Limit" ||
                                        priceType == "SL MKT"
                                    ? triggerPriceCtrl.text
                                    : "",
                                tsym: widget.scripInfo.tsym!,
                                mktProt: priceType == "Market" ||
                                        priceType == "SL MKT"
                                    ? mktProtCtrl.text
                                    : '',
                                channel: '',
                                userAgent: '',
                                appInstaId: '',
                              );
                              await context
                                  .read(orderProvider)
                                  .slicePlaceOrder(context, placeOrderInput);
                            }
                            await context
                                .read(orderProvider)
                                .fetchOrderBook(context, true);

                            await context.read(indexListProvider).bottomMenu(2);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              backgroundColor:
                                  Color(isBuy! ? 0xff43A833 : 0xffFF1717),
                              shape: const StadiumBorder()),
                          child: Text(isBuy! ? 'Buy Now' : "Sell Now",
                              style: textStyle(const Color(0xffffffff), 14,
                                  FontWeight.w600))),
                    ),
                    const SizedBox(height: 10),
                  ])));
    }
  }

  Text headerTitleText(String text, ThemesProvider theme) {
    return Text(text,
        style: textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }

  void marginUpdate() {
    OrderMarginInput input = OrderMarginInput(
        exch: "${widget.scripInfo.exch}",
        prc: ((widget.scripInfo.exch == "MCX" ||
                    widget.scripInfo.exch == "BSE") &&
                (priceType == "Market" || priceType == "SL MKT"))
            ? "0"
            : price,
        prctyp: context.read(ordInputProvider).prcType,
        prd: context.read(ordInputProvider).orderType,
        qty: qtyCtrl.text,
        rorgprc: '0',
        rorgqty: '0',
        trantype: isBuy! ? "B" : "S",
        tsym: "${widget.scripInfo.tsym}",
        blprc: orderType == "Cover" || orderType == "Bracket"
            ? stopLossCtrl.text
            : '',
        trgprc: priceType == "SL Limit" || priceType == "SL MKT"
            ? triggerPriceCtrl.text
            : "");
    context.read(orderProvider).fetchOrderMargin(input, context);
    BrokerageInput brokerageInput = BrokerageInput(
        exch: "${widget.scripInfo.exch}",
        prc: ((widget.scripInfo.exch == "MCX" ||
                    widget.scripInfo.exch == "BSE") &&
                (priceType == "Market" || priceType == "SL MKT"))
            ? "0"
            : price,
        prd: context.read(ordInputProvider).orderType,
        qty: "${widget.scripInfo.ls}",
        trantype: isBuy! ? "B" : "S",
        tsym: "${widget.scripInfo.tsym}");
    context.read(orderProvider).fetchGetBrokerage(brokerageInput, context);
  }
}
