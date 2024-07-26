import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../res/res.dart'; 
import '../../models/marketwatch_model/scrip_info.dart';
import '../../models/order_book_model/modify_order_model.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../models/order_book_model/order_margin_model.dart';
import '../../provider/network_state_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart'; 
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_widget_button.dart';
import '../../sharedWidget/no_internet_widget.dart';
import '../../sharedWidget/snack_bar.dart';
import 'margin_charges_bottom_sheet.dart';
import 'order_screen_header.dart';

class ModifyPlaceOrderScreen extends StatefulWidget {
  final OrderBookModel modifyOrderArgs;
  final ScripInfoModel scripInfo;
  final OrderScreenArgs orderArg;
  const ModifyPlaceOrderScreen(
      {super.key,
      required this.scripInfo,
      required this.modifyOrderArgs,
      required this.orderArg});

  @override
  State<ModifyPlaceOrderScreen> createState() => _ModifyPlaceOrderScreenState();
}

class _ModifyPlaceOrderScreenState extends State<ModifyPlaceOrderScreen> {
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
  List<String> priceType = ["Limit", "Market", "SL Limit", "SL MKT"];
  List<bool> isActivePrice = [true, false, false, false];
  List<String> validityType = ["Day", "IOC"];
  List<bool> isActiveValidity = [true, false];

  String prcType = "LMT";

  int lotSize = 0;
  String price = "0.00";
  String validity = "DAY";
  @override
  void initState() {
    setState(() {
      lotSize = int.parse("${widget.scripInfo.ls ?? 0}");

      priceCtrl = TextEditingController(text: widget.modifyOrderArgs.prc);
      qtyCtrl = TextEditingController(text: widget.modifyOrderArgs.qty);
      mktProtCtrl = TextEditingController(
          text: widget.modifyOrderArgs.mktProtection == null
              ? "5"
              : widget.modifyOrderArgs.mktProtection!);

      triggerPriceCtrl =
          TextEditingController(text: "${widget.modifyOrderArgs.trgprc ?? 0}");
      discQtyCtrl = TextEditingController(text: widget.modifyOrderArgs.dscqty);
      validity = widget.modifyOrderArgs.ret!;
      // context.read(networkStateProvider).networkStream();

      addStoploss = widget.modifyOrderArgs.sPrdtAli == "BO" ||
              widget.modifyOrderArgs.sPrdtAli == "CO"
          ? true
          : false;
      OrderMarginInput input = OrderMarginInput(
          exch: "${widget.scripInfo.exch}",
          prc: priceCtrl.text,
          prctyp: prcType,
          prd: widget.modifyOrderArgs.prd!,
          qty: qtyCtrl.text,
          rorgprc: '0',
          rorgqty: '0',
          trantype: widget.modifyOrderArgs.trantype!,
          tsym: "${widget.scripInfo.tsym}",
          blprc: '',
          trgprc: isActivePrice[2] || isActivePrice[3]
              ? triggerPriceCtrl.text
              : "");
      context.read(orderProvider).fetchOrderMargin(input, context);
      BrokerageInput brokerageInput = BrokerageInput(
          exch: "${widget.scripInfo.exch}",
          prc: priceCtrl.text,
          prd: widget.modifyOrderArgs.prd!,
          qty: "${widget.scripInfo.ls}",
          trantype: widget.modifyOrderArgs.trantype!,
          tsym: "${widget.scripInfo.tsym}");
      context.read(orderProvider).fetchGetBrokerage(brokerageInput, context);
    });
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
        final internet = watch(networkStateProvider);
        final theme = context.read(themeProvider);
        return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  centerTitle: false,
                  leadingWidth: 41,
                  titleSpacing: 6,
                  leading: const CustomBackBtn(),
                  elevation: .4,
                  title: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                CustomExchBadge(
                                    exch: "${widget.scripInfo.exch}"),
                              ]),
                          const SizedBox(height: 4),
                          OrderScreenHeader(headerData: widget.orderArg),
                        ]),
                  ),
                ),
                body: Stack(
                  children: [
                    SingleChildScrollView(
                        reverse: true,
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
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
                                                    for (var i = 0;
                                                        i <
                                                            isActivePrice
                                                                .length;
                                                        i++) {
                                                      isActivePrice[i] = false;
                                                    }
                                                    isActivePrice[index] = true;
                                                    if (isActivePrice[1] ||
                                                        isActivePrice[3]) {
                                                      double ltp = (double.parse(
                                                                  "${widget.orderArg.ltp}") *
                                                              double.parse(mktProtCtrl
                                                                      .text
                                                                      .isEmpty
                                                                  ? "0"
                                                                  : mktProtCtrl
                                                                      .text)) /
                                                          100;

                                                      if (widget.modifyOrderArgs
                                                              .trantype ==
                                                          "B") {
                                                        price = (double.parse(
                                                                    "${widget.orderArg.ltp ?? 0.00}") +
                                                                ltp)
                                                            .toStringAsFixed(2);

                                                        print("&&&&  $price");
                                                      } else {
                                                        price = (double.parse(
                                                                    "${widget.orderArg.ltp ?? 0.00}") -
                                                                ltp)
                                                            .toStringAsFixed(2);
                                                      }
                                                      priceCtrl.text = "Market";
                                                    } else {
                                                      priceCtrl.text =
                                                          "${widget.orderArg.ltp}";
                                                    }
                                                    if (isActivePrice[0] ||
                                                        isActivePrice[1]) {
                                                      prcType = "LMT";
                                                    } else {
                                                      prcType = "SL-LMT";
                                                    }
                                                  });
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
                                                        ? !isActivePrice[index]
                                                            ? const Color(0xffF1F3F8)
                                                            : colors.colorBlack
                                                        : !isActivePrice[index]
                                                            ? colors.darkGrey
                                                            : colors.colorWhite,
                                                    shape:
                                                        const StadiumBorder()),
                                                child: Text(priceType[index],
                                                    style: textStyle(
                                                        !theme.isDarkMode
                                                            ? !isActivePrice[
                                                                    index]
                                                                ? const Color(
                                                                    0xff666666)
                                                                : colors
                                                                    .colorWhite
                                                            : !isActivePrice[
                                                                    index]
                                                                ? const Color(
                                                                    0xff666666)
                                                                : colors
                                                                    .colorBlack,
                                                        14,
                                                        isActivePrice[index]
                                                            ? FontWeight.w600
                                                            : FontWeight
                                                                .w500)));
                                          },
                                          separatorBuilder: (context, index) {
                                            return const SizedBox(width: 8);
                                          },
                                          itemCount:
                                              widget.modifyOrderArgs.sPrdtAli ==
                                                          "BO" ||
                                                      widget.modifyOrderArgs
                                                              .sPrdtAli ==
                                                          "CO"
                                                  ? 3
                                                  : priceType.length))),
                              const SizedBox(height: 3),
                              const Divider(color: Color(0xffDDDDDD)),
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
                                                  "Quantity", theme),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                  height: 44,
                                                  child: CustomTextFormField(
                                                    fillColor: theme.isDarkMode
                                                        ? colors.darkGrey
                                                        : const Color(
                                                            0xffF1F3F8),
                                                    hintText:
                                                        "${widget.orderArg.lotSize}",
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
                                                          if (qtyCtrl.text
                                                              .isNotEmpty) {
                                                            if (int.parse(
                                                                    qtyCtrl
                                                                        .text) >
                                                                lotSize) {
                                                              qtyCtrl
                                                                  .text = (int.parse(
                                                                          qtyCtrl
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
                                                              theme.isDarkMode?assets.darkCMinus:    theme.isDarkMode?assets.darkCMinus:        assets.minusIcon,
                                                          fit:
                                                              BoxFit.scaleDown),
                                                    ),
                                                    suffixIcon: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (qtyCtrl.text
                                                              .isNotEmpty) {
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
                                                        theme.isDarkMode?assets.darkAdd:   assets.addIcon,
                                                          fit:
                                                              BoxFit.scaleDown),
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
                                                  ))
                                            ])),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              headerTitleText("Price", theme),
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
                                                                    "${widget.scripInfo.lc}")) ||
                                                            (double.parse(
                                                                    value) >
                                                                double.parse(
                                                                    "${widget.scripInfo.uc}"))) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(warningMessage(
                                                                  context,
                                                                  double.parse(
                                                                              value) <
                                                                          double.parse(
                                                                              "${widget.scripInfo.lc}")
                                                                      ? "Limit Price can not be lesser than Lower Circuit Limit ${widget.scripInfo.lc}"
                                                                      : "Limit Price can not be greater than Upper Circuit Limit ${widget.scripInfo.uc}"));
                                                        }
                                                        setState(() {
                                                          price = value;
                                                        });
                                                      }
                                                      },
                                                      hintText:
                                                          "${widget.orderArg.ltp}",
                                                      hintStyle: textStyle(
                                                          theme.isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          15,
                                                          FontWeight.w400),
                                                      style: textStyle(
                                                          const Color(
                                                              0xff000000),
                                                          16,
                                                          FontWeight.w600),
                                                      isReadable: isActivePrice[1] ||
                                                              isActivePrice[3]
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
                                                          color: theme.isDarkMode?const Color(0xff555555):colors.colorWhite ),
                                                        child: SvgPicture.asset(
                                                          color: theme.isDarkMode?colors.colorWhite:colors.colorGrey,
                                                              isActivePrice[1] || isActivePrice[3] ? assets.lock : assets.ruppeIcon,
                                                              fit: BoxFit.scaleDown)),
                                                      textCtrl: priceCtrl,
                                                      textAlign: TextAlign.start)),
                                            ]))
                                      ])),
                              const SizedBox(height: 3),
                              const Divider(color: Color(0xffDDDDDD)),
                              if (isActivePrice[2] || isActivePrice[3])
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                                          : const Color(
                                                              0xffF1F3F8),
                                                      hintText: "0.00",
                                                      hintStyle: textStyle(
                                                          const Color(
                                                              0xff666666),
                                                          15,
                                                          FontWeight.w400),
                                                      onChanged: (value) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .hideCurrentSnackBar();
                                                        if (value.isNotEmpty) {
                                                          if (widget
                                                                  .modifyOrderArgs
                                                                  .trantype ==
                                                              "B") {
                                                            if (double.parse(
                                                                    value) <
                                                                double.parse(
                                                                    "${isActivePrice[3] ? price : widget.orderArg.ltp ?? 0.00}")) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      warningMessage(
                                                                          context,
                                                                          "Trigger Should be Greater than Last Trade Price"));
                                                            } else if (double
                                                                    .parse(
                                                                        value) <
                                                                double.parse(
                                                                    "${priceCtrl.text.isEmpty ? 0.00 : priceCtrl.text == "Market" ? price : priceCtrl.text}")) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      warningMessage(
                                                                          context,
                                                                          "Trigger Should be Greater than Price"));
                                                            }
                                                          } else {
                                                            if (double.parse(
                                                                    value) >
                                                                double.parse(
                                                                    "${widget.orderArg.ltp ?? 0.00}")) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      warningMessage(
                                                                          context,
                                                                          "Trigger Should be Lesser than Last Trade Price"));
                                                            } else if (double
                                                                    .parse(
                                                                        value) >
                                                                double.parse(
                                                                    "${priceCtrl.text.isEmpty ? 0.00 : priceCtrl.text == "Market" ? price : priceCtrl.text}")) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      warningMessage(
                                                                          context,
                                                                          "Trigger Should be Lesser than Price"));
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
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          16,
                                                          FontWeight.w600),
                                                      prefixIcon: Container(
                                                          margin: const EdgeInsets.all(
                                                              12),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            color: theme.isDarkMode?const Color(0xff555555):colors.colorWhite ),
                                                        child: SvgPicture.asset(
                                                          color: theme.isDarkMode?colors.colorWhite:colors.colorGrey,
                                                              assets.ruppeIcon,
                                                              fit: BoxFit
                                                                  .scaleDown)),
                                                      textCtrl: triggerPriceCtrl,
                                                      textAlign: TextAlign.start))
                                            ])),
                                    const SizedBox(height: 12),
                                    const Divider(
                                        color: Color(0xffDDDDDD), height: 0)
                                  ],
                                ),
                              if (addStoploss) ...[
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          isActivePrice[2]
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
                                                        color: theme.isDarkMode?const Color(0xff555555):colors.colorWhite ),
                                                        child: SvgPicture.asset(
                                                          color: theme.isDarkMode?colors.colorWhite:colors.colorGrey,
                                                        assets.ruppeIcon,
                                                        fit: BoxFit.scaleDown),
                                                  ),
                                                  textCtrl: targetCtrl,
                                                  textAlign: TextAlign.start)),
                                          const SizedBox(height: 10),
                                          headerTitleText("Stoploss", theme),
                                          const SizedBox(height: 7),
                                          SizedBox(
                                              height: 44,
                                              child: CustomTextFormField(
                                                  fillColor: theme.isDarkMode
                                                      ? colors.darkGrey
                                                      : const Color(0xffF1F3F8),
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
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                       color: theme.isDarkMode?const Color(0xff555555):colors.colorWhite ),
                                                        child: SvgPicture.asset(
                                                          color: theme.isDarkMode?colors.colorWhite:colors.colorGrey,
                                                        assets.ruppeIcon,
                                                        fit: BoxFit.scaleDown),
                                                  ),
                                                  textCtrl: stopLossCtrl,
                                                  textAlign: TextAlign.start)),
                                        ])),
                                const SizedBox(height: 12),
                                const Divider(
                                    color: Color(0xffDDDDDD), height: 0)
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
                                            icon: SvgPicture.asset(
                                                 theme.isDarkMode?addValidity 
                                                ? assets.darkCheckedboxIcon
                                                : assets.darkCheckboxIcon:
                                              addValidity
                                                ? assets.checkedbox
                                                : assets.checkbox))
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
                                                  height: 43,
                                                  child: ListView.separated(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ElevatedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              for (var i = 0;
                                                                  i <
                                                                      validityType
                                                                          .length;
                                                                  i++) {
                                                                isActiveValidity[
                                                                    i] = false;
                                                              }
                                                              isActiveValidity[
                                                                  index] = true;

                                                              validity =
                                                                  validityType[
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
                                                                      ? !isActiveValidity[
                                                                              index]
                                                                          ? const Color(
                                                                              0xffF1F3F8)
                                                                          : colors
                                                                              .colorBlack
                                                                      : !isActiveValidity[
                                                                              index]
                                                                          ? colors
                                                                              .darkGrey
                                                                          : colors
                                                                              .colorWhite,
                                                                  shape:
                                                                      const StadiumBorder()),
                                                          child: Text(
                                                            validityType[index],
                                                            style: textStyle(
                                                                !theme
                                                                        .isDarkMode
                                                                    ? !isActiveValidity[
                                                                            index]
                                                                        ? const Color(
                                                                            0xff666666)
                                                                        : colors
                                                                            .colorWhite
                                                                    : !isActiveValidity[
                                                                            index]
                                                                        ? const Color(
                                                                            0xff666666)
                                                                        : colors
                                                                            .colorBlack,
                                                                14,
                                                                isActiveValidity[
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
                                                      itemCount:
                                                          validityType.length),
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
                                                                ? colors
                                                                    .darkGrey
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
                                                              if (discQtyCtrl
                                                                  .text
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
                                                                          .text =
                                                                      "0";
                                                                }
                                                              } else {
                                                                discQtyCtrl
                                                                    .text = "0";
                                                              }
                                                            });
                                                          },
                                                          child: SvgPicture.asset(
                                                                  theme.isDarkMode?assets.darkCMinus:    assets.minusIcon,
                                                              fit: BoxFit
                                                                  .scaleDown),
                                                        ),
                                                        suffixIcon: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              if (discQtyCtrl
                                                                  .text
                                                                  .isNotEmpty) {
                                                                discQtyCtrl
                                                                        .text =
                                                                    (int.parse(discQtyCtrl.text) +
                                                                            1)
                                                                        .toString();
                                                              } else {
                                                                discQtyCtrl
                                                                    .text = "0";
                                                              }
                                                            });
                                                          },
                                                          child: SvgPicture.asset(
                                                           theme.isDarkMode?assets.darkAdd:    assets.addIcon,
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
                              const Divider(
                                  color: Color(0xffDDDDDD), height: 0),
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
                                            icon: SvgPicture.asset(
                                                 theme.isDarkMode?isAmo
                                                ? assets.darkCheckedboxIcon
                                                : assets.darkCheckboxIcon:
                                              isAmo
                                                ? assets.checkedbox
                                                : assets.checkbox))
                                      ])),
                              const SizedBox(height: 100)
                            ])),
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
                              if (isActivePrice[1] || isActivePrice[3]) ...[
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
                                                      mktProtCtrl.text = "20";
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "can't enter greater than 20% of market production"));
                                                    } else if (int.parse(
                                                            value) <
                                                        1) {
                                                      mktProtCtrl.text = "1";
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
                                      left: 16.0, right: 3),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(children: [
                                          CustomWidgetButton(
                                              onPress: internet
                                                          .connectionStatus ==
                                                      ConnectivityResult.none
                                                  ? () {}
                                                  : () {
                                                      OrderMarginInput input = OrderMarginInput(
                                                          exch:
                                                              "${widget.scripInfo.exch}",
                                                          prc: isActivePrice[
                                                                      1] ||
                                                                  isActivePrice[
                                                                      3]
                                                              ? price
                                                              : priceCtrl.text,
                                                          prctyp: prcType,
                                                          prd: widget
                                                              .modifyOrderArgs
                                                              .prd!,
                                                          qty: qtyCtrl.text,
                                                          rorgprc: '0',
                                                          rorgqty: '0',
                                                          trantype: widget
                                                              .modifyOrderArgs
                                                              .trantype!,
                                                          tsym:
                                                              "${widget.scripInfo.tsym}",
                                                          blprc: '',
                                                          trgprc: isActivePrice[
                                                                      2] ||
                                                                  isActivePrice[
                                                                      3]
                                                              ? triggerPriceCtrl
                                                                  .text
                                                              : "");
                                                      context
                                                          .read(orderProvider)
                                                          .fetchOrderMargin(
                                                              input, context);
                                                      showModalBottomSheet(
                                                          useSafeArea: true,
                                                          isScrollControlled:
                                                              true,
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.vertical(
                                                                      top: Radius
                                                                          .circular(
                                                                              16))),
                                                          context: context,
                                                          builder: (context) {
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
                                                    : () {
                                                        BrokerageInput brokerageInput = BrokerageInput(
                                                            exch:
                                                                "${widget.scripInfo.exch}",
                                                            prc: priceCtrl.text,
                                                            prd: widget
                                                                .modifyOrderArgs
                                                                .prd!,
                                                            qty:
                                                                "${widget.scripInfo.ls}",
                                                            trantype: widget
                                                                .modifyOrderArgs
                                                                .trantype!,
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
                                          )
                                        ]),
                                        IconButton(
                                            onPressed: internet
                                                        .connectionStatus ==
                                                    ConnectivityResult.none
                                                ? null
                                                : () {
                                                    OrderMarginInput input = OrderMarginInput(
                                                        exch:
                                                            "${widget.scripInfo.exch}",
                                                        prc: isActivePrice[1] ||
                                                                isActivePrice[3]
                                                            ? price
                                                            : priceCtrl.text,
                                                        prctyp: prcType,
                                                        prd: widget
                                                            .modifyOrderArgs
                                                            .prd!,
                                                        qty: qtyCtrl.text,
                                                        rorgprc: '0',
                                                        rorgqty: '0',
                                                        trantype: widget
                                                            .modifyOrderArgs
                                                            .trantype!,
                                                        tsym:
                                                            "${widget.scripInfo.tsym}",
                                                        blprc: '',
                                                        trgprc: isActivePrice[
                                                                    2] ||
                                                                isActivePrice[3]
                                                            ? triggerPriceCtrl
                                                                .text
                                                            : "");
                                                    context
                                                        .read(orderProvider)
                                                        .fetchOrderMargin(
                                                            input, context);

                                                    BrokerageInput
                                                        brokerageInput =
                                                        BrokerageInput(
                                                            exch:
                                                                "${widget.scripInfo.exch}",
                                                            prc: priceCtrl.text,
                                                            prd: widget
                                                                .modifyOrderArgs
                                                                .prd!,
                                                            qty:
                                                                "${widget.scripInfo.ls}",
                                                            trantype: widget
                                                                .modifyOrderArgs
                                                                .trantype!,
                                                            tsym:
                                                                "${widget.scripInfo.tsym}");
                                                    context
                                                        .read(orderProvider)
                                                        .fetchGetBrokerage(
                                                            brokerageInput,
                                                            context);
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
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar();
                                              if (qtyCtrl.text.isEmpty ||
                                                  priceCtrl.text.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        qtyCtrl.text.isEmpty
                                                            ? "Quantity can not be empty"
                                                            : "Price can not be empty"));
                                              } else if (qtyCtrl.text == "0" ||
                                                  priceCtrl.text == "0") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        qtyCtrl.text == "0"
                                                            ? "Quantity can not be 0"
                                                            : "Price can not be 0"));
                                              } else if ((double.parse(isActivePrice[
                                                                  1] ||
                                                              isActivePrice[3]
                                                          ? price
                                                          : priceCtrl.text) <
                                                      double.parse(
                                                          "${widget.scripInfo.lc}")) ||
                                                  (double.parse(isActivePrice[1] ||
                                                              isActivePrice[3]
                                                          ? price
                                                          : priceCtrl.text) >
                                                      double.parse(
                                                          "${widget.scripInfo.uc}"))) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(warningMessage(
                                                        context,
                                                        double.parse(isActivePrice[
                                                                            1] ||
                                                                        isActivePrice[
                                                                            3]
                                                                    ? price
                                                                    : priceCtrl
                                                                        .text) <
                                                                double.parse(
                                                                    "${widget.scripInfo.lc}")
                                                            ? "Price can not be lesser than Lower Circuit Limit ${widget.scripInfo.lc}"
                                                            : "Price can not be greater than Lower Circuit Limit ${widget.scripInfo.uc}"));
                                              } else if ((isActivePrice[2] ||
                                                  isActivePrice[3])) {
                                                if (triggerPriceCtrl
                                                        .text.isEmpty ||
                                                    triggerPriceCtrl.text ==
                                                        "0") {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          triggerPriceCtrl
                                                                  .text.isEmpty
                                                              ? "Trigger can not be empty"
                                                              : "Trigger can not be 0"));
                                                } else {
                                                  if (widget.modifyOrderArgs
                                                          .trantype ==
                                                      "B") {
                                                    if (double.parse(
                                                            triggerPriceCtrl
                                                                .text) <
                                                        double.parse(
                                                            "${isActivePrice[3] ? price : widget.modifyOrderArgs.ltp ?? 0.00}")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(warningMessage(
                                                              context,
                                                              isActivePrice[3]
                                                                  ? "Trigger Should be Greater than Price"
                                                                  : "Trigger Should be Greater than Last Trade Price"));
                                                    } else if (double.parse(
                                                            triggerPriceCtrl
                                                                .text) <
                                                        double.parse(
                                                            "${priceCtrl.text.isEmpty ? 0.00 : priceCtrl.text == "Market" ? price : priceCtrl.text}")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger Should be Greater than Price"));
                                                    } else {
                                                      modifyOrder();
                                                    }
                                                  } else {
                                                    if (double.parse(
                                                            triggerPriceCtrl
                                                                .text) >
                                                        double.parse(
                                                            "${isActivePrice[3] ? price : widget.modifyOrderArgs.ltp ?? 0.00}")) {
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
                                                            "${priceCtrl.text.isEmpty ? 0.00 : priceCtrl.text == "Market" ? price : priceCtrl.text}")) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Trigger Should be Lesser than Price"));
                                                    } else {
                                                      modifyOrder();
                                                    }
                                                  }
                                                }
                                              } else if (widget.modifyOrderArgs
                                                      .sPrdtAli ==
                                                  "BO") {
                                                if (stopLossCtrl.text.isEmpty ||
                                                    targetCtrl.text.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          "${stopLossCtrl.text.isEmpty ? "Stoploss" : "Target"} can not be empty"));
                                                } else {
                                                  modifyOrder();
                                                }
                                              } else if (widget.modifyOrderArgs
                                                      .sPrdtAli ==
                                                  "CO") {
                                                if (stopLossCtrl.text.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          " Stoploss can not be empty"));
                                                } else {
                                                  modifyOrder();
                                                }
                                              } else {
                                                modifyOrder();
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          backgroundColor: !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite,
                                          shape: const StadiumBorder()),
                                      child: Text("Modify Order",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorBlack
                                                  : colors.colorWhite,
                                              14,
                                              FontWeight.w600)))),
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

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }

  modifyOrder() async {
    ModifyOrderInput input = ModifyOrderInput(
        dscqty: widget.modifyOrderArgs.dscqty!,
        token: widget.modifyOrderArgs.token!,
        exch: widget.modifyOrderArgs.exch!,
        mktProt: widget.modifyOrderArgs.mktProtection ?? "",
        orderNum: widget.modifyOrderArgs.norenordno!,
        prc: priceCtrl.text,
        prctyp: prcType,
        qty: qtyCtrl.text,
        ret: widget.modifyOrderArgs.ret!,
        trgprc: triggerPriceCtrl.text,
        tsym: widget.modifyOrderArgs.tsym!);
    await context.read(orderProvider).fetchModifyOrder(input, context);
  }
}
