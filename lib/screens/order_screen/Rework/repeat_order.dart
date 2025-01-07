import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/order_book_model/order_margin_model.dart';
import '../../../models/order_book_model/place_order_model.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/network_state_provider.dart';
import '../../../provider/order_input_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/custom_switch_btn.dart';
import '../../../sharedWidget/custom_widget_button.dart';
import '../../../sharedWidget/enums.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/no_internet_widget.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../margin_charges_bottom_sheet.dart';
import '../order_screen_header.dart';

class RepeatOrder extends StatefulWidget {
  final OrderBookModel orderBookList;
  const RepeatOrder({super.key, required this.orderBookList});

  @override
  State<RepeatOrder> createState() => _RepeatOrderState();
}

class _RepeatOrderState extends State<RepeatOrder> {
  bool? isBuy;
  bool addStoploss = false;
  bool isAgree = false;
  bool addValidity = false;
  bool isAmo = false;
  int lotSize = 0;
  int frezQty = 0;
  int reminder = 0;
  int maxQty = 0;
  int quantity = 0;
  String validityType = "DAY";
  OrderScreenArgs? headerData;
  @override
  void initState() {
    setState(() {
      isBuy = widget.orderBookList.trantype == "B";
      isAmo = widget.orderBookList.amo == "Yes";
      frezQty = int.parse(
          context.read(marketWatchProvider).scripInfoModel!.frzqty ?? "0");
      validityType = widget.orderBookList.exch == "BSE" ||
              widget.orderBookList.exch == "BFO"
          ? "EOS"
          : "DAY";
      lotSize = int.parse("${widget.orderBookList.ls ?? 0}");
      addStoploss = widget.orderBookList.blprc != null;

      headerData = OrderScreenArgs(
          exchange: "${widget.orderBookList.exch}",
          token: "${widget.orderBookList.token}",
          tSym: "${widget.orderBookList.tsym}",
          transType: false,
          perChange: "${widget.orderBookList.perChange}",
          lotSize: "${widget.orderBookList.ls}",
          ltp: "${widget.orderBookList.ltp}",
          isExit: false,
          orderTpye: '',
          isModify: false,
          holdQty: '');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read(ordInputProvider).getOrderData(widget.orderBookList);
    });
    marginUpdate(context.read(ordInputProvider));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Consumer(builder: (context, ScopedReader watch, _) {
        final orderProvide = watch(orderProvider);
        final scripInfo = watch(marketWatchProvider);
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
                              Text("${widget.orderBookList.symbol!} ",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      16,
                                      FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1),
                              if (widget.orderBookList.option!.isNotEmpty)
                                Text(widget.orderBookList.option!,
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: const Color(0xff666666)),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                              if (widget.orderBookList.expDate!.isNotEmpty)
                                Text(" ${widget.orderBookList.expDate} ",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w600)),
                              CustomExchBadge(exch: widget.orderBookList.exch!)
                            ]),
                        // const SizedBox(height: 4),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OrderScreenHeader(headerData: headerData!),
                              Row(children: [
                                SvgPicture.asset(assets.buyIcon),
                                const SizedBox(width: 6),
                                CustomSwitch(
                                    onChanged: (bool value) {
                                      setState(() {
                                        isBuy = value;
                                      });
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
                            widget.orderBookList.exch == "NCOM" ? 10 : 50),
                        child: Column(children: [
                          if (widget.orderBookList.exch != "NCOM") ...[
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
                                            // setState(() {
                                            orderInput.chngOrderName(
                                                orderInput.orderNames[index]);
                                            if (orderInput.priceName ==
                                                "SL MKT") {
                                              orderInput.chngPriceName("Limit");
                                            }

                                            if (index == 1 || index == 2) {
                                              addStoploss = true;
                                            } else {
                                              addStoploss = false;
                                            }
                                            // });

                                            if (orderInput.orderName !=
                                                "Regular") {
                                              orderInput.chngOrderType(
                                                  orderInput.orderNames[index]);
                                            } else {
                                              orderInput.chngInvesType(
                                                  scripInfo.scripInfoModel!.seg
                                                              .toString() ==
                                                          "EQT"
                                                      ? InvestType.delivery
                                                      : InvestType.carryForward,
                                                  "PlcOrder");
                                            }
                                            FocusScope.of(context).unfocus();
                                          },
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              decoration: BoxDecoration(
                                                  border: orderInput.orderName ==
                                                          orderInput
                                                              .orderNames[index]
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
                                                  '${orderInput.orderNames[index]}',
                                                  style: textStyle(
                                                      orderInput.orderName ==
                                                                  orderInput.orderNames[
                                                                      index] &&
                                                              theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : orderInput.orderName ==
                                                                  orderInput
                                                                      .orderNames[index]
                                                              ? colors.colorBlack
                                                              : const Color(0xff666666),
                                                      14,
                                                      FontWeight.w600))));
                                    },
                                    itemCount: orderInput.orderNames.length))
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
                            if (orderInput.orderName == "Regular") ...[
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    if (widget.orderBookList.exch !=
                                        "NCOM") ...[
                                      Radio<InvestType>(
                                        fillColor: WidgetStateProperty
                                            .resolveWith<Color>(
                                                (Set<WidgetState> states) {
                                          if (states
                                              .contains(WidgetState.disabled)) {
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
                                        },
                                      ),
                                      Text('Intraday',
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? Color(orderInput
                                                              .investType ==
                                                          InvestType.intraday
                                                      ? 0xffffffff
                                                      : 0xff666666)
                                                  : Color(orderInput
                                                              .investType ==
                                                          InvestType.intraday
                                                      ? 0xff3E4763
                                                      : 0xff666666),
                                              14,
                                              FontWeight.w500))
                                    ],
                                    Radio<InvestType>(
                                      fillColor:
                                          WidgetStateProperty.resolveWith<
                                              Color>((Set<WidgetState> states) {
                                        if (states
                                            .contains(WidgetState.disabled)) {
                                          return const Color(0xff666666);
                                        }
                                        return theme.isDarkMode
                                            ? colors.colorWhite
                                            : const Color(0xff666666);
                                      }),
                                      activeColor: theme.isDarkMode
                                          ? colors.colorWhite
                                          : const Color(0xff666666),
                                      value: scripInfo.scripInfoModel!.seg
                                                  .toString() ==
                                              "EQT"
                                          ? InvestType.delivery
                                          : InvestType.carryForward,
                                      groupValue: orderInput.investType,
                                      onChanged: (InvestType? value) {
                                        orderInput.chngInvesType(
                                            value!, "PlcOrder");
                                      },
                                    ),
                                    Text(
                                        scripInfo.scripInfoModel!.seg
                                                    .toString() ==
                                                "EQT"
                                            ? 'Delivery'
                                            : "Carry Forward",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? Color(orderInput.investType ==
                                                            InvestType
                                                                .delivery ||
                                                        orderInput.investType ==
                                                            InvestType
                                                                .carryForward
                                                    ? 0xffffffff
                                                    : 0xff666666)
                                                : Color(orderInput.investType ==
                                                            InvestType
                                                                .delivery ||
                                                        orderInput.investType ==
                                                            InvestType
                                                                .carryForward
                                                    ? 0xff3E4763
                                                    : 0xff666666),
                                            14,
                                            FontWeight.w500))
                                  ]),
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
                                                orderInput.chngPriceName(
                                                    orderInput
                                                        .priceNames[index]);

                                                if (orderInput.priceName ==
                                                        "Market" ||
                                                    orderInput.priceName ==
                                                        "SL MKT") {
                                                  orderInput.prcCtrl.text =
                                                      "Market";

                                                  double ltp = (double.parse(
                                                              "${widget.orderBookList.ltp}") *
                                                          double.parse(orderInput
                                                                  .mktProtCtrl
                                                                  .text
                                                                  .isEmpty
                                                              ? "0"
                                                              : orderInput
                                                                  .mktProtCtrl
                                                                  .text)) /
                                                      100;

                                                  if (isBuy!) {
                                                    orderInput
                                                        .priceVal = (double.parse(
                                                                "${widget.orderBookList.ltp ?? 0.00}") +
                                                            ltp)
                                                        .toStringAsFixed(2);
                                                  } else {
                                                    orderInput
                                                        .priceVal = (double.parse(
                                                                "${widget.orderBookList.ltp ?? 0.00}") -
                                                            ltp)
                                                        .toStringAsFixed(2);
                                                  }
                                                  double result = double.parse(
                                                          orderInput.priceVal) +
                                                      (double.parse(
                                                              "${scripInfo.scripInfoModel!.ti}") /
                                                          2);
                                                  result -= result %
                                                      double.parse(
                                                          "${scripInfo.scripInfoModel!.ti}");

                                                  if (result >=
                                                      double.parse(
                                                          "${scripInfo.scripInfoModel!.uc ?? 0.00}")) {
                                                    orderInput.priceVal =
                                                        "${scripInfo.scripInfoModel!.uc}";
                                                  } else if (result <=
                                                      double.parse(
                                                          "${scripInfo.scripInfoModel!.lc ?? 0.00}")) {
                                                    orderInput.priceVal =
                                                        "${scripInfo.scripInfoModel!.lc}";
                                                  } else {
                                                    orderInput.priceVal = result
                                                        .toStringAsFixed(2);
                                                  }
                                                } else {
                                                  orderInput.prcCtrl.text =
                                                      "${widget.orderBookList.ltp}";

                                                  orderInput.priceVal =
                                                      orderInput.prcCtrl.text;
                                                }

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
                                                      ? orderInput.priceName !=
                                                              orderInput
                                                                      .priceNames[
                                                                  index]
                                                          ? const Color(
                                                              0xffF1F3F8)
                                                          : colors.colorBlack
                                                      : orderInput.priceName !=
                                                              orderInput
                                                                      .priceNames[
                                                                  index]
                                                          ? colors.darkGrey
                                                          : colors.colorWhite,
                                                  shape: const StadiumBorder()),
                                              child: Text(
                                                  orderInput.priceNames[index],
                                                  style: textStyle(
                                                      !theme.isDarkMode
                                                          ? orderInput.priceName !=
                                                                  orderInput
                                                                          .priceNames[
                                                                      index]
                                                              ? const Color(
                                                                  0xff666666)
                                                              : colors
                                                                  .colorWhite
                                                          : orderInput.priceName !=
                                                                  orderInput
                                                                          .priceNames[
                                                                      index]
                                                              ? const Color(
                                                                  0xff666666)
                                                              : colors
                                                                  .colorBlack,
                                                      14,
                                                      FontWeight.w500)));
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(width: 8);
                                        },
                                        itemCount:
                                            orderInput.orderName == "Regular"
                                                ? orderInput.priceNames.length
                                                : 3))),
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
                                                      "Quantity", theme),
                                                  Text(
                                                    "Lot: ${widget.orderBookList.ls}   ",
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
                                                  hintText:
                                                      orderInput.qtyCrl.text,
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
                                                        if (orderInput.qtyCrl
                                                            .text.isNotEmpty) {
                                                          if (int.parse(
                                                                  orderInput
                                                                      .qtyCrl
                                                                      .text) >
                                                              lotSize) {
                                                            orderInput.qtyCrl
                                                                .text = (int.parse(
                                                                        orderInput
                                                                            .qtyCrl
                                                                            .text) -
                                                                    lotSize)
                                                                .toString();
                                                          }
                                                        } else {
                                                          orderInput
                                                                  .qtyCrl.text =
                                                              "$lotSize";
                                                        }
                                                      });
                                                    },
                                                    child: SvgPicture.asset(
                                                        theme.isDarkMode
                                                            ? assets.darkCMinus
                                                            : assets.minusIcon,
                                                        fit: BoxFit.scaleDown),
                                                  ),
                                                  suffixIcon: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (orderInput.qtyCrl
                                                            .text.isNotEmpty) {
                                                          orderInput.qtyCrl
                                                              .text = (int.parse(
                                                                      orderInput
                                                                          .qtyCrl
                                                                          .text) +
                                                                  lotSize)
                                                              .toString();
                                                        } else {
                                                          orderInput
                                                                  .qtyCrl.text =
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
                                                  textCtrl: orderInput.qtyCrl,
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
                                            if (scripInfo
                                                    .scripInfoModel!.frzqty !=
                                                null) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                  "Frz Qty : ${scripInfo.scripInfoModel!.frzqty}",
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
                                                  "Tick: ${widget.orderBookList.ti} ",
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
                                                          .removeCurrentSnackBar();
                                                      if (value.isEmpty) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Limit Price can not be empty"));
                                                      } else {
                                                        if ((double.parse(
                                                                    value) <
                                                                double.parse(
                                                                    "${scripInfo.scripInfoModel!.lc}")) ||
                                                            (double.parse(
                                                                    value) >
                                                                double.parse(
                                                                    "${scripInfo.scripInfoModel!.uc}"))) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(warningMessage(
                                                                  context,
                                                                  double.parse(
                                                                              value) <
                                                                          double.parse(
                                                                              "${scripInfo.scripInfoModel!.lc}")
                                                                      ? "Limit Price can not be lesser than Lower Circuit Limit ${scripInfo.scripInfoModel!.lc}"
                                                                      : "Limit Price can not be greater than Upper Circuit Limit ${scripInfo.scripInfoModel!.uc}"));
                                                        }
                                                      }
                                                    },
                                                    hintText:
                                                        orderInput.prcCtrl.text,
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
                                                    isReadable: orderInput.priceName ==
                                                                "Market" ||
                                                            orderInput.priceName ==
                                                                "SL MKT"
                                                        ? true
                                                        : false,
                                                    prefixIcon: Container(
                                                        margin:
                                                            const EdgeInsets.all(
                                                                12),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    20),
                                                            color: theme.isDarkMode
                                                                ? const Color(0xff555555)
                                                                : colors.colorWhite),
                                                        child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, orderInput.priceName == "Limit" || orderInput.priceName == "SL Limit" ? assets.ruppeIcon : assets.lock, fit: BoxFit.scaleDown)),
                                                    textCtrl: orderInput.prcCtrl,
                                                    textAlign: TextAlign.start)),
                                          ]))
                                    ])),
                            const SizedBox(height: 3),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider),
                            if (orderInput.priceName == "SL Limit" ||
                                orderInput.priceName == "SL MKT")
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
                                                      .removeCurrentSnackBar();

                                                  if (value.isEmpty ||
                                                      value == "0") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(warningMessage(
                                                            context,
                                                            value.isEmpty
                                                                ? "Trigger can not be empty"
                                                                : "Trigger can not be 0"));
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
                                                textCtrl:
                                                    orderInput.triggerPriceCtrl,
                                                textAlign: TextAlign.start)),
                                        const SizedBox(height: 10),
                                      ])),
                            if (orderInput.priceName == "SL Limit" ||
                                orderInput.priceName == "SL MKT")
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
                                        if (orderInput.orderName ==
                                            "Bracket") ...[
                                          orderInput.priceName == "SL Limit"
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
                                                        .removeCurrentSnackBar();

                                                    if (value.isEmpty ||
                                                        value == "0") {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(warningMessage(
                                                              context,
                                                              value.isEmpty
                                                                  ? "Target can not be empty"
                                                                  : "Target can not be 0"));
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
                                                  textCtrl:
                                                      orderInput.targetCtrl,
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
                                                      .removeCurrentSnackBar();

                                                  if (value.isEmpty ||
                                                      value == "0") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(warningMessage(
                                                            context,
                                                            value.isEmpty
                                                                ? "Stoploss can not be empty"
                                                                : "Stoploss can not be 0"));
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
                                                textCtrl:
                                                    orderInput.stopLossCtrl,
                                                textAlign: TextAlign.start)),
                                      ]))
                            ],
                            if (orderInput.orderName != "Regular") ...[
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
                                                                orderInput
                                                                        .validityNames[
                                                                    index];
                                                          });
                                                          orderInput.chngeValidity(
                                                              orderInput
                                                                      .validityNames[
                                                                  index]);
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
                                                                    ? orderInput.validityName !=
                                                                            orderInput.validityNames[
                                                                                index]
                                                                        ? const Color(
                                                                            0xffF1F3F8)
                                                                        : colors
                                                                            .colorBlack
                                                                    : orderInput.validityName !=
                                                                            orderInput.validityNames[
                                                                                index]
                                                                        ? colors
                                                                            .darkGrey
                                                                        : colors
                                                                            .colorWhite,
                                                                shape:
                                                                    const StadiumBorder()),
                                                        child: Text(
                                                          orderInput
                                                                  .validityNames[
                                                              index],
                                                          style: textStyle(
                                                              !theme.isDarkMode
                                                                  ? orderInput.validityName !=
                                                                          orderInput.validityNames[
                                                                              index]
                                                                      ? const Color(
                                                                          0xff666666)
                                                                      : colors
                                                                          .colorWhite
                                                                  : orderInput.validityName !=
                                                                          orderInput.validityNames[
                                                                              index]
                                                                      ? const Color(
                                                                          0xff666666)
                                                                      : colors
                                                                          .colorBlack,
                                                              14,
                                                              orderInput.validityName ==
                                                                      orderInput
                                                                              .validityNames[
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
                                                    itemCount: widget
                                                                    .orderBookList
                                                                    .exch ==
                                                                "BSE" ||
                                                            widget.orderBookList
                                                                    .exch ==
                                                                "BFO"
                                                        ? orderInput
                                                            .validityNames
                                                            .length
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
                                                            if (orderInput
                                                                .discQtyCtrl
                                                                .text
                                                                .isNotEmpty) {
                                                              if (int.parse(orderInput
                                                                      .discQtyCtrl
                                                                      .text) >
                                                                  0) {
                                                                orderInput
                                                                    .discQtyCtrl
                                                                    .text = (int.parse(orderInput
                                                                            .discQtyCtrl
                                                                            .text) -
                                                                        1)
                                                                    .toString();
                                                              } else {
                                                                orderInput
                                                                    .discQtyCtrl
                                                                    .text = "0";
                                                              }
                                                            } else {
                                                              orderInput
                                                                  .discQtyCtrl
                                                                  .text = "0";
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
                                                            if (orderInput
                                                                .discQtyCtrl
                                                                .text
                                                                .isNotEmpty) {
                                                              orderInput
                                                                  .discQtyCtrl
                                                                  .text = (int.parse(orderInput
                                                                          .discQtyCtrl
                                                                          .text) +
                                                                      1)
                                                                  .toString();
                                                            } else {
                                                              orderInput
                                                                  .discQtyCtrl
                                                                  .text = "0";
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
                                                      textCtrl: orderInput
                                                          .discQtyCtrl,
                                                      textAlign:
                                                          TextAlign.center))
                                            ]))
                                      ])),
                              const SizedBox(height: 10)
                            ],
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider,
                                height: 0),
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
                            SizedBox(
                                height: orderInput.priceName == "Market"
                                    ? 180
                                    : 100)
                          ],
                        )),
                    if (internet.connectionStatus ==
                        ConnectivityResult.none) ...[const NoInternetWidget()]
                  ],
                ),
                bottomSheet: internet.connectionStatus ==
                        ConnectivityResult.none
                    ? const NoInternetWidget()
                    : Container(
                        color: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (orderInput.priceName == "Market" ||
                                  orderInput.priceName == "SL MKT") ...[
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
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                  if (value.isNotEmpty) {
                                                    if (int.parse(value) > 20) {
                                                      orderInput.mktProtCtrl
                                                          .text = "20";
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "can't enter greater than 20% of market production"));
                                                    } else if (int.parse(
                                                            value) <
                                                        1) {
                                                      orderInput.mktProtCtrl
                                                          .text = "1";
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
                                              textCtrl: orderInput.mktProtCtrl,
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
                                              onPress:
                                                  internet.connectionStatus ==
                                                          ConnectivityResult
                                                              .none
                                                      ? () {}
                                                      : () async {
                                                          await marginUpdate(
                                                              orderInput);
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
                                                        const Color(0xff666666),
                                                        12,
                                                        FontWeight.w500)),
                                                Text(
                                                    "₹${orderProvide.orderMarginModel == null ? 0.00 : orderProvide.orderMarginModel!.marginused}",
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
                                              ])),
                                          const SizedBox(width: 20),
                                          CustomWidgetButton(
                                            onPress:
                                                internet.connectionStatus ==
                                                        ConnectivityResult.none
                                                    ? () {}
                                                    : () async {
                                                        await marginUpdate(
                                                            orderInput);
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
                                                      const Color(0xff666666),
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
                                            onPressed:
                                                internet.connectionStatus ==
                                                        ConnectivityResult.none
                                                    ? null
                                                    : () async {
                                                        await marginUpdate(
                                                            orderInput);
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
                                                quantity = int.parse(orderInput
                                                        .qtyCrl.text.isEmpty
                                                    ? "0"
                                                    : orderInput.qtyCrl.text);
                                                // frezQty;
                                              } else {
                                                quantity = int.parse(orderInput
                                                            .qtyCrl.text.isEmpty
                                                        ? "0"
                                                        : orderInput
                                                            .qtyCrl.text) ~/
                                                    frezQty;
                                              }
                                              reminder = int.parse(orderInput
                                                          .qtyCrl.text.isEmpty
                                                      ? "0"
                                                      : orderInput
                                                          .qtyCrl.text) -
                                                  (frezQty * quantity);
                                              maxQty = frezQty * 28;
                                              print(
                                                  "objectobject{$quantity | $reminder | $maxQty}");
                                            });
                                            if (orderInput.qtyCrl.text
                                                    .trim()
                                                    .isEmpty ||
                                                orderInput.prcCtrl.text
                                                    .trim()
                                                    .isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(warningMessage(
                                                      context,
                                                      orderInput.qtyCrl.text
                                                              .isEmpty
                                                          ? "Quantity can not be empty"
                                                          : "Price can not be empty"));
                                            } else if (orderInput.qtyCrl.text
                                                        .trim() ==
                                                    "0" ||
                                                orderInput.prcCtrl.text
                                                        .trim() ==
                                                    "0") {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(warningMessage(
                                                      context,
                                                      orderInput.qtyCrl.text ==
                                                              "0"
                                                          ? "Quantity can not be 0"
                                                          : "Price can not be 0"));
                                            } else if ((double.parse(
                                                        orderInput.priceVal) <
                                                    double.parse(
                                                        "${scripInfo.scripInfoModel!.lc ?? 0.00}")) ||
                                                (double.parse(
                                                        orderInput.priceVal) >
                                                    double.parse(
                                                        "${scripInfo.scripInfoModel!.uc ?? 0.00}"))) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(warningMessage(
                                                      context,
                                                      double.parse(orderInput
                                                                  .priceVal) <
                                                              double.parse(
                                                                  "${scripInfo.scripInfoModel!.lc ?? 0.00}")
                                                          ? "Price can not be lesser than Lower Circuit Limit ${scripInfo.scripInfoModel!.lc ?? 0.00}"
                                                          : "Price can not be greater than Upper Circuit Limit ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                            }

                                            //
                                            //
                                            // --------------

                                            else if (orderInput.orderName ==
                                                    "Regular" &&
                                                (orderInput.priceName ==
                                                        "SL Limit" ||
                                                    orderInput.priceName ==
                                                        "SL MKT")) {
                                              if (orderInput.triggerPriceCtrl
                                                      .text.isEmpty ||
                                                  orderInput.triggerPriceCtrl
                                                          .text ==
                                                      "0") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        orderInput
                                                                .triggerPriceCtrl
                                                                .text
                                                                .isEmpty
                                                            ? "Trigger can not be empty"
                                                            : "Trigger can not be 0"));
                                              } else {
                                                if (isBuy!) {
                                                  if (orderInput.priceName ==
                                                      "SL MKT") {
                                                    if (double.parse(orderInput
                                                            .triggerPriceCtrl
                                                            .text) <
                                                        double.parse(widget
                                                                .orderBookList
                                                                .ltp ??
                                                            "0.00")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger should be greater than LTP"));
                                                    } else if (double.parse(
                                                            orderInput
                                                                .triggerPriceCtrl
                                                                .text) >
                                                        double.parse(scripInfo
                                                                .scripInfoModel!
                                                                .uc ??
                                                            "0.00")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger can not be greater than upper circuit limit of ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                                    } else {
                                                      if ((int.parse(orderInput
                                                                      .qtyCrl
                                                                      .text
                                                                      .isEmpty
                                                                  ? "0"
                                                                  : orderInput
                                                                      .qtyCrl
                                                                      .text) >
                                                              frezQty &&
                                                          scripInfo
                                                                  .scripInfoModel!
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
                                                    if (double.parse(orderInput.triggerPriceCtrl.text) <
                                                        double.parse(scripInfo
                                                                .scripInfoModel!
                                                                .lc ??
                                                            "0.00")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger can not be lesser than lower circuit limit of ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                                    } else if (double.parse(orderInput.priceVal) <
                                                        double.parse(orderInput
                                                            .triggerPriceCtrl
                                                            .text)) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger should be less than price"));
                                                    } else if (double.parse(
                                                            orderInput
                                                                .triggerPriceCtrl
                                                                .text) >
                                                        double.parse(scripInfo
                                                                .scripInfoModel!
                                                                .uc ??
                                                            "0.00")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger can not be greater than upper circuit limit of ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                                    } else {
                                                      if ((int.parse(orderInput
                                                                      .qtyCrl
                                                                      .text
                                                                      .isEmpty
                                                                  ? "0"
                                                                  : orderInput
                                                                      .qtyCrl
                                                                      .text) >
                                                              frezQty &&
                                                          scripInfo
                                                                  .scripInfoModel!
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
                                                } else {
                                                  if (orderInput.priceName ==
                                                      "SL MKT") {
                                                    if (double.parse(orderInput
                                                            .triggerPriceCtrl
                                                            .text) >
                                                        double.parse(widget
                                                                .orderBookList
                                                                .ltp ??
                                                            "0.00")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger should be lesser than LTP"));
                                                    } else if (double.parse(
                                                            orderInput
                                                                .triggerPriceCtrl
                                                                .text) <
                                                        double.parse(scripInfo
                                                                .scripInfoModel!
                                                                .lc ??
                                                            "0.00")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger can not be lesser than lower circuit limit of ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                                    } else {
                                                      if ((int.parse(orderInput
                                                                      .qtyCrl
                                                                      .text
                                                                      .isEmpty
                                                                  ? "0"
                                                                  : orderInput
                                                                      .qtyCrl
                                                                      .text) >
                                                              frezQty &&
                                                          scripInfo
                                                                  .scripInfoModel!
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
                                                    if (double.parse(orderInput.triggerPriceCtrl.text) >
                                                        double.parse(scripInfo
                                                                .scripInfoModel!
                                                                .uc ??
                                                            "0.00")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger can not be greater than upper circuit limit of ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                                    } else if (double.parse(orderInput.priceVal) >
                                                        double.parse(orderInput
                                                            .triggerPriceCtrl
                                                            .text)) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger should be greater than price"));
                                                    } else if (double.parse(
                                                            orderInput
                                                                .triggerPriceCtrl
                                                                .text) <
                                                        double.parse(scripInfo
                                                                .scripInfoModel!
                                                                .lc ??
                                                            "0.00")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger can not be lesser than lower circuit limit of ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                                    } else {
                                                      if ((int.parse(orderInput
                                                                      .qtyCrl
                                                                      .text
                                                                      .isEmpty
                                                                  ? "0"
                                                                  : orderInput
                                                                      .qtyCrl
                                                                      .text) >
                                                              frezQty &&
                                                          scripInfo
                                                                  .scripInfoModel!
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
                                              }
                                            } else if (orderInput.orderName ==
                                                    "Cover" &&
                                                (orderInput.priceName ==
                                                        "Limit" ||
                                                    orderInput.priceName ==
                                                        "Market")) {
                                              if (orderInput.stopLossCtrl.text
                                                      .isEmpty ||
                                                  orderInput
                                                          .stopLossCtrl.text ==
                                                      "0") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        orderInput.stopLossCtrl
                                                                .text.isEmpty
                                                            ? "Stoploss can not be empty"
                                                            : "Stoploss can not be 0"));
                                              } else {
                                                if (isBuy!) {
                                                  if ((double.parse(orderInput
                                                              .priceVal) -
                                                          double.parse(
                                                              orderInput
                                                                  .stopLossCtrl
                                                                  .text)) <
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .lc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Price(Order price - Stoploss = ${(double.parse(orderInput.priceVal) - double.parse(orderInput.stopLossCtrl.text))}) Stoploss can not be lower than ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                                  } else {
                                                    if ((int.parse(orderInput
                                                                    .qtyCrl
                                                                    .text
                                                                    .isEmpty
                                                                ? "0"
                                                                : orderInput
                                                                    .qtyCrl
                                                                    .text) >
                                                            frezQty &&
                                                        scripInfo
                                                                .scripInfoModel!
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
                                                  if ((double.parse(orderInput
                                                              .priceVal) +
                                                          double.parse(
                                                              orderInput
                                                                  .stopLossCtrl
                                                                  .text)) >
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .uc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Price(Order price + Stoploss = ${(double.parse(orderInput.priceVal) + double.parse(orderInput.stopLossCtrl.text))}) Stoploss can not be greater than ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                                  } else {
                                                    if ((int.parse(orderInput
                                                                    .qtyCrl
                                                                    .text
                                                                    .isEmpty
                                                                ? "0"
                                                                : orderInput
                                                                    .qtyCrl
                                                                    .text) >
                                                            frezQty &&
                                                        scripInfo
                                                                .scripInfoModel!
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
                                            } else if (orderInput.orderName ==
                                                    "Cover" &&
                                                (orderInput.priceName ==
                                                    "SL Limit")) {
                                              if (orderInput.stopLossCtrl.text
                                                      .isEmpty ||
                                                  orderInput.stopLossCtrl.text ==
                                                      "0") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        orderInput.stopLossCtrl
                                                                .text.isEmpty
                                                            ? "Stoploss can not be empty"
                                                            : "Stoploss can not be 0"));
                                              } else if (isBuy! &&
                                                  (double.parse(orderInput.priceVal) - double.parse(orderInput.stopLossCtrl.text)) <
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .lc ??
                                                          "0.00")) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        "Price(Order price - Stoploss = ${(double.parse(orderInput.priceVal) - double.parse(orderInput.stopLossCtrl.text))}) Stoploss can not be lower than ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                              } else if (!isBuy! &&
                                                  (double.parse(orderInput.priceVal) + double.parse(orderInput.stopLossCtrl.text)) >
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .uc ??
                                                          "0.00")) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        "Price(Order price + Stoploss = ${(double.parse(orderInput.priceVal) + double.parse(orderInput.stopLossCtrl.text))}) Stoploss can not be greater than ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                              } else if ((orderInput
                                                          .triggerPriceCtrl
                                                          .text
                                                          .isEmpty ||
                                                      orderInput.triggerPriceCtrl.text == "0") &&
                                                  orderInput.priceName == "SL Limit") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        orderInput
                                                                .triggerPriceCtrl
                                                                .text
                                                                .isEmpty
                                                            ? "Trigger can not be empty"
                                                            : "Trigger can not be 0"));
                                              } else {
                                                if (isBuy!) {
                                                  if (double.parse(orderInput.triggerPriceCtrl.text) <
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .lc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be lesser than lower circuit limit of ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                                  } else if (double.parse(orderInput.priceVal) <
                                                      double.parse(orderInput
                                                          .triggerPriceCtrl
                                                          .text)) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger should be less than price"));
                                                  } else if (double.parse(
                                                          orderInput
                                                              .triggerPriceCtrl
                                                              .text) >
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .uc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be greater than upper circuit limit of ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                                  } else {
                                                    if ((int.parse(orderInput
                                                                    .qtyCrl
                                                                    .text
                                                                    .isEmpty
                                                                ? "0"
                                                                : orderInput
                                                                    .qtyCrl
                                                                    .text) >
                                                            frezQty &&
                                                        scripInfo
                                                                .scripInfoModel!
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
                                                  if (double.parse(orderInput.triggerPriceCtrl.text) >
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .uc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be greater than upper circuit limit of ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                                  } else if (double.parse(orderInput.priceVal) >
                                                      double.parse(orderInput
                                                          .triggerPriceCtrl
                                                          .text)) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger should be greater than price"));
                                                  } else if (double.parse(
                                                          orderInput
                                                              .triggerPriceCtrl
                                                              .text) <
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .lc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be lesser than lower circuit limit of ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                                  } else {
                                                    if ((int.parse(orderInput
                                                                    .qtyCrl
                                                                    .text
                                                                    .isEmpty
                                                                ? "0"
                                                                : orderInput
                                                                    .qtyCrl
                                                                    .text) >
                                                            frezQty &&
                                                        scripInfo
                                                                .scripInfoModel!
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
                                            } else if (orderInput.orderName ==
                                                    "Bracket" &&
                                                (orderInput.priceName ==
                                                        "Limit" ||
                                                    orderInput.priceName ==
                                                        "Market")) {
                                              if (orderInput.stopLossCtrl.text.isEmpty ||
                                                  orderInput.targetCtrl.text
                                                      .isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        "${orderInput.stopLossCtrl.text.isEmpty ? "Stoploss" : "Target"} can not be empty"));
                                              } else if (isBuy! &&
                                                  (double.parse(orderInput.priceVal) -
                                                          double.parse(orderInput
                                                              .stopLossCtrl
                                                              .text)) <
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .lc ??
                                                          "0.00")) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        "Price(Order price - Stoploss = ${(double.parse(orderInput.priceVal) - double.parse(orderInput.stopLossCtrl.text))}) Stoploss can not be lower than ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                              } else if (!isBuy! &&
                                                  (double.parse(orderInput.priceVal) +
                                                          double.parse(
                                                              orderInput
                                                                  .stopLossCtrl
                                                                  .text)) >
                                                      double.parse(scripInfo.scripInfoModel!.uc ?? "0.00")) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        "Price(Order price + Stoploss = ${(double.parse(orderInput.priceVal) + double.parse(orderInput.stopLossCtrl.text))}) Stoploss can not be greater than ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                              } else {
                                                if ((int.parse(orderInput.qtyCrl
                                                                .text.isEmpty
                                                            ? "0"
                                                            : orderInput
                                                                .qtyCrl.text) >
                                                        frezQty &&
                                                    scripInfo.scripInfoModel!
                                                            .frzqty !=
                                                        null)) {
                                                  placeOrder(
                                                      orderInput, true, theme);
                                                } else {
                                                  placeOrder(
                                                      orderInput, false, theme);
                                                }
                                              }
                                            } else if (orderInput.orderName ==
                                                    "Bracket" &&
                                                (orderInput.priceName ==
                                                    "SL Limit")) {
                                              if (orderInput.stopLossCtrl.text
                                                      .isEmpty ||
                                                  orderInput.targetCtrl.text
                                                      .isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        "${orderInput.stopLossCtrl.text.isEmpty ? "Stoploss" : "Target"} can not be empty"));
                                              } else if (isBuy! &&
                                                  (double.parse(orderInput.priceVal) - double.parse(orderInput.stopLossCtrl.text)) <
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .lc ??
                                                          "0.00")) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        "Price(Order price - Stoploss = ${(double.parse(orderInput.priceVal) - double.parse(orderInput.stopLossCtrl.text))}) Stoploss can not be lower than ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                              } else if (!isBuy! &&
                                                  (double.parse(orderInput.priceVal) + double.parse(orderInput.stopLossCtrl.text)) >
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .uc ??
                                                          "0.00")) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        "Price(Order price + Stoploss = ${(double.parse(orderInput.priceVal) + double.parse(orderInput.stopLossCtrl.text))}) Stoploss can not be greater than ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                              } else if (orderInput
                                                      .triggerPriceCtrl
                                                      .text
                                                      .isEmpty &&
                                                  orderInput.priceName ==
                                                      "SL Limit") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        "Trigger can not be empty"));
                                              } else {
                                                if (isBuy!) {
                                                  if (double.parse(orderInput.triggerPriceCtrl.text) <
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .lc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be lesser than lower circuit limit of ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                                  } else if (double.parse(orderInput.priceVal) <
                                                      double.parse(orderInput
                                                          .triggerPriceCtrl
                                                          .text)) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger should be less than price"));
                                                  } else if (double.parse(
                                                          orderInput
                                                              .triggerPriceCtrl
                                                              .text) >
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .uc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be greater than upper circuit limit of ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                                  } else {
                                                    if ((int.parse(orderInput
                                                                    .qtyCrl
                                                                    .text
                                                                    .isEmpty
                                                                ? "0"
                                                                : orderInput
                                                                    .qtyCrl
                                                                    .text) >
                                                            frezQty &&
                                                        scripInfo
                                                                .scripInfoModel!
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
                                                  if (double.parse(orderInput.triggerPriceCtrl.text) >
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .uc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be greater than upper circuit limit of ${scripInfo.scripInfoModel!.uc ?? 0.00}"));
                                                  } else if (double.parse(orderInput.priceVal) >
                                                      double.parse(orderInput
                                                          .triggerPriceCtrl
                                                          .text)) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger should be greater than price"));
                                                  } else if (double.parse(
                                                          orderInput
                                                              .triggerPriceCtrl
                                                              .text) <
                                                      double.parse(scripInfo
                                                              .scripInfoModel!
                                                              .lc ??
                                                          "0.00")) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger can not be lesser than lower circuit limit of ${scripInfo.scripInfoModel!.lc ?? 0.00}"));
                                                  } else {
                                                    if ((int.parse(orderInput
                                                                    .qtyCrl
                                                                    .text
                                                                    .isEmpty
                                                                ? "0"
                                                                : orderInput
                                                                    .qtyCrl
                                                                    .text) >
                                                            frezQty &&
                                                        scripInfo
                                                                .scripInfoModel!
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
                                            } else {
                                              if ((int.parse(orderInput.qtyCrl
                                                              .text.isEmpty
                                                          ? "0"
                                                          : orderInput
                                                              .qtyCrl.text) >
                                                      frezQty &&
                                                  scripInfo.scripInfoModel!
                                                          .frzqty !=
                                                      null)) {
                                                placeOrder(
                                                    orderInput, true, theme);
                                              } else {
                                                placeOrder(
                                                    orderInput, false, theme);
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        backgroundColor: isBuy!
                                            ? colors.ltpgreen
                                            : colors.darkred,
                                        shape: const StadiumBorder()),
                                    child: Text(isBuy! ? 'Buy Now' : "Sell Now",
                                        style: textStyle(
                                            const Color(0xffffffff),
                                            14,
                                            FontWeight.w600))),
                              ),
                              if (defaultTargetPlatform == TargetPlatform.iOS)
                                const SizedBox(height: 18)
                            ]))));
      }),
    );
  }

  Text headerTitleText(String text, ThemesProvider theme) {
    return Text(text,
        style: textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500));
  }

  

  placeOrder(OrderInputProvider orderInput, bool isSliceOrd,
      ThemesProvider theme) async {
    if (!isSliceOrd) {
      PlaceOrderInput placeOrderInput = PlaceOrderInput(
        amo: isAmo ? "Yes" : "",
        blprc:
            orderInput.orderName == "Cover" || orderInput.orderName == "Bracket"
                ? orderInput.stopLossCtrl.text
                : '',
        bpprc:
            orderInput.orderName == "Bracket" ? orderInput.targetCtrl.text : '',
        dscqty: orderInput.discQtyCtrl.text,
        exch: widget.orderBookList.exch!,
        prc: ((widget.orderBookList.exch == "MCX" ||
                    widget.orderBookList.exch == "BSE") &&
                (orderInput.priceName == "Market" ||
                    orderInput.priceName == "SL MKT"))
            ? "0"
            : orderInput.priceVal,
        prctype: orderInput.prcType,
        prd: orderInput.orderType,
        qty: orderInput.qtyCrl.text,
        ret: validityType,
        trailprc: '',
        trantype: isBuy! ? 'B' : 'S',
        trgprc: orderInput.priceName == "SL Limit" ||
                orderInput.priceName == "SL MKT"
            ? orderInput.triggerPriceCtrl.text
            : "",
        tsym: widget.orderBookList.tsym!,
        mktProt:
            orderInput.priceName == "Market" || orderInput.priceName == "SL MKT"
                ? orderInput.mktProtCtrl.text
                : '',
        channel: '' 
      );
      await context
          .read(orderProvider)
          .fetchPlaceOrder(context, placeOrderInput, false);
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
                                  Text("${widget.orderBookList.symbol} ",
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack)),
                                  Text("${widget.orderBookList.option}",
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
                                      exch: "${widget.orderBookList.exch}"),
                                  Text("${widget.orderBookList.expDate}",
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
                                    Text("${widget.orderBookList.symbol} ",
                                        style: textStyles.scripNameTxtStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack)),
                                    Text("${widget.orderBookList.option}",
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
                                        exch: "${widget.orderBookList.exch}"),
                                    Text("${widget.orderBookList.expDate}",
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
                            for (var i = 0; i < quantity; i++) {
                              PlaceOrderInput placeOrderInput = PlaceOrderInput(
                                amo: isAmo ? "Yes" : "",
                                blprc: orderInput.orderName == "Cover" ||
                                        orderInput.orderName == "Bracket"
                                    ? orderInput.stopLossCtrl.text
                                    : '',
                                bpprc: orderInput.orderName == "Bracket"
                                    ? orderInput.targetCtrl.text
                                    : '',
                                dscqty: orderInput.discQtyCtrl.text,
                                exch: widget.orderBookList.exch!,
                                prc: ((widget.orderBookList.exch == "MCX" ||
                                            widget.orderBookList.exch ==
                                                "BSE") &&
                                        (orderInput.priceName == "Market" ||
                                            orderInput.priceName == "SL MKT"))
                                    ? "0"
                                    : orderInput.priceVal,
                                prctype: orderInput.prcType,
                                prd: orderInput.orderType,
                                qty: "$frezQty",
                                ret: validityType,
                                trailprc: '',
                                trantype: isBuy! ? 'B' : 'S',
                                trgprc: orderInput.priceName == "SL Limit" ||
                                        orderInput.priceName == "SL MKT"
                                    ? orderInput.triggerPriceCtrl.text
                                    : "",
                                tsym: widget.orderBookList.tsym!,
                                mktProt: orderInput.priceName == "Market" ||
                                        orderInput.priceName == "SL MKT"
                                    ? orderInput.mktProtCtrl.text
                                    : '',
                                channel: '' 
                              );
                              await context
                                  .read(orderProvider)
                                  .slicePlaceOrder(context, placeOrderInput);
                            }

                            if (reminder != 0) {
                              PlaceOrderInput placeOrderInput = PlaceOrderInput(
                                amo: isAmo ? "Yes" : "",
                                blprc: orderInput.orderName == "Cover" ||
                                        orderInput.orderName == "Bracket"
                                    ? orderInput.stopLossCtrl.text
                                    : '',
                                bpprc: orderInput.orderName == "Bracket"
                                    ? orderInput.targetCtrl.text
                                    : '',
                                dscqty: orderInput.discQtyCtrl.text,
                                exch: widget.orderBookList.exch!,
                                prc: ((widget.orderBookList.exch == "MCX" ||
                                            widget.orderBookList.exch ==
                                                "BSE") &&
                                        (orderInput.priceName == "Market" ||
                                            orderInput.priceName == "SL MKT"))
                                    ? "0"
                                    : orderInput.priceVal,
                                prctype: orderInput.prcType,
                                prd: orderInput.orderType,
                                qty: "$reminder",
                                ret: validityType,
                                trailprc: '',
                                trantype: isBuy! ? 'B' : 'S',
                                trgprc: orderInput.priceName == "SL Limit" ||
                                        orderInput.priceName == "SL MKT"
                                    ? orderInput.triggerPriceCtrl.text
                                    : "",
                                tsym: widget.orderBookList.tsym!,
                                mktProt: orderInput.priceName == "Market" ||
                                        orderInput.priceName == "SL MKT"
                                    ? orderInput.mktProtCtrl.text
                                    : '',
                                channel: '' 
                              );
                              await context
                                  .read(orderProvider)
                                  .slicePlaceOrder(context, placeOrderInput);
                            }
                            await context
                                .read(orderProvider)
                                .fetchOrderBook(context, true);

                            context.read(indexListProvider).bottomMenu(2, context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              backgroundColor:
                                  isBuy! ? colors.ltpgreen : colors.darkred,
                              shape: const StadiumBorder()),
                          child: Text(isBuy! ? 'Buy Now' : "Sell Now",
                              style: textStyle(const Color(0xffffffff), 14,
                                  FontWeight.w600))),
                    ),
                    const SizedBox(height: 10),
                  ])));
    }
  }

  marginUpdate(OrderInputProvider orderInput) {
    OrderMarginInput input = OrderMarginInput(
        exch: "${widget.orderBookList.exch}",
        prc: ((widget.orderBookList.exch == "MCX" ||
                    widget.orderBookList.exch == "BSE") &&
                (orderInput.priceName == "Market" ||
                    orderInput.priceName == "SL MKT"))
            ? "0"
            : orderInput.priceVal,
        prctyp: context.read(ordInputProvider).prcType,
        prd: orderInput.orderType,
        qty: orderInput.qtyCrl.text.isEmpty ? "0" : orderInput.qtyCrl.text,
        rorgprc: '0',
        rorgqty: '0',
        trantype: isBuy! ? "B" : "S",
        tsym: "${widget.orderBookList.tsym}",
        blprc:
            orderInput.orderName == "Cover" || orderInput.orderName == "Bracket"
                ? orderInput.stopLossCtrl.text
                : '',
        trgprc: orderInput.priceName == "SL Limit" ||
                orderInput.priceName == "SL MKT"
            ? orderInput.triggerPriceCtrl.text
            : "");
    context.read(orderProvider).fetchOrderMargin(input, context);
    BrokerageInput brokerageInput = BrokerageInput(
        exch: "${widget.orderBookList.exch}",
        prc: ((widget.orderBookList.exch == "MCX" ||
                    widget.orderBookList.exch == "BSE") &&
                (orderInput.priceName == "Market" ||
                    orderInput.priceName == "SL MKT"))
            ? "0"
            : orderInput.priceVal,
        prd: orderInput.orderType,
        qty: orderInput.qtyCrl.text.isEmpty ? "0" : orderInput.qtyCrl.text,
        trantype: isBuy! ? "B" : "S",
        tsym: "${widget.orderBookList.tsym}");
    context.read(orderProvider).fetchGetBrokerage(brokerageInput, context);
  }
}
