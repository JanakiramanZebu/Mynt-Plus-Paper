import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/routes/route_names.dart';
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
import '../../sharedWidget/custom_switch_btn.dart';
import '../../sharedWidget/custom_widget_button.dart';
import '../../sharedWidget/no_internet_widget.dart';
import '../../sharedWidget/snack_bar.dart';
import 'margin_charges_bottom_sheet.dart';
import 'order_screen_header.dart';

class ModifyPlaceOrderScreen extends ConsumerStatefulWidget {
  final OrderBookModel modifyOrderArgs;
  final ScripInfoModel scripInfo;
  final OrderScreenArgs orderArg;
  const ModifyPlaceOrderScreen(
      {super.key,
      required this.scripInfo,
      required this.modifyOrderArgs,
      required this.orderArg});

  @override
  ConsumerState<ModifyPlaceOrderScreen> createState() =>
      _ModifyPlaceOrderScreenState();
}

class _ModifyPlaceOrderScreenState
    extends ConsumerState<ModifyPlaceOrderScreen> {
  // bool addStoploss = false;
  bool isAgree = false;
  bool addValidity = false;
  bool isAmo = false;
  bool isBuy = false;
  TextEditingController priceCtrl = TextEditingController();
  TextEditingController triggerPriceCtrl = TextEditingController();
  TextEditingController mktProtCtrl = TextEditingController();
  TextEditingController qtyCtrl = TextEditingController();
  TextEditingController discQtyCtrl = TextEditingController();
  TextEditingController stopLossCtrl = TextEditingController();
  TextEditingController targetCtrl = TextEditingController();
  TextEditingController trailingTickCtrl = TextEditingController();
  List<String> priceType = ["Limit", "Market", "SL Limit", "SL MKT"];
  // List<bool> isActivePrice = [];
  List<String> validityType = ["Day", "IOC"];
  // List<bool> isActiveValidity = [true, false];

  String prcType = "";

  int frezQty = 0;
  int lotSize = 0;
  int multiplayer = 0;
  String price = "0.00";
  String validity = "DAY";
  bool _isMarketOrder = false;
  bool _isStoplossOrder = false;
  bool _isBOCOOrderEnabled = false;
  bool isAdvancedOptionClicked = false;
  // String orderType = "Delivery";

  double tik = 0.00;
  double roundOffWithInterval(double input, double interval) {
    return ((input / interval).round() * interval);
  }

  @override
  void initState() {
    ref.read(fundProvider).fetchFunds(context);

    tik = double.parse(widget.scripInfo.ti.toString());

    prcType = widget.modifyOrderArgs.prctyp!;
    // isActivePrice = [
    //   prcType == 'LMT' ? true : false,
    //   prcType == 'MKT' ? true : false,
    //   prcType == 'SL-LMT' ? true : false,
    //   prcType == 'SL-MKT' ? true : false
    // ];
    int sfq = int.tryParse(widget.scripInfo.frzqty?.toString() ?? '1') ?? 1;
    lotSize = int.parse("${widget.scripInfo.ls ?? 0}");

    frezQty = sfq > 1 ? (sfq / lotSize).floor() * lotSize : lotSize;

    setState(() {
      multiplayer = int.parse((widget.orderArg.exchange == "MCX"
              ? widget.scripInfo.prcqqty
              : widget.orderArg.lotSize)
          .toString());
      isBuy = widget.modifyOrderArgs.trantype == "B" ? true : false;
      priceCtrl = TextEditingController(text: widget.modifyOrderArgs.prc);
      qtyCtrl = TextEditingController(text: widget.modifyOrderArgs.qty);

      if (widget.modifyOrderArgs.fillshares != null &&
          int.parse(widget.modifyOrderArgs.fillshares.toString()) > 0 &&
          widget.modifyOrderArgs.fillshares != widget.modifyOrderArgs.qty) {
        int fqty = (int.parse(widget.modifyOrderArgs.qty.toString()) -
            int.parse(widget.modifyOrderArgs.fillshares.toString()));
        if (fqty != 0) {
          qtyCtrl.text = fqty.toString();
        }
      }
      if (widget.orderArg.exchange == "MCX") {
        qtyCtrl.text = (int.parse(qtyCtrl.text) ~/ lotSize).toString();
      }
      mktProtCtrl = TextEditingController(
          text: widget.modifyOrderArgs.mktProtection == null
              ? "5"
              : widget.modifyOrderArgs.mktProtection!);

      stopLossCtrl =
          TextEditingController(text: "${widget.modifyOrderArgs.blprc ?? 0}");
      targetCtrl =
          TextEditingController(text: "${widget.modifyOrderArgs.bpprc ?? 0}");
      triggerPriceCtrl =
          TextEditingController(text: "${widget.modifyOrderArgs.trgprc ?? 0}");
      discQtyCtrl = TextEditingController(text: widget.modifyOrderArgs.dscqty);
      validity = widget.modifyOrderArgs.ret!.toUpperCase();

      // isActiveValidity = [
      //   validity == 'DAY' ? true : false,
      //   validity == 'IOC' ? true : false,
      // ];
      addValidity = validity.toUpperCase() == 'IOC' ||
              (widget.modifyOrderArgs.dscqty != null &&
                  int.parse(widget.modifyOrderArgs.dscqty.toString()) > 0)
          ? true
          : false;

      if (prcType == "MKT" || prcType == "SL-MKT") {
        double ltp = (double.parse("${widget.orderArg.ltp}") *
                double.parse(
                    mktProtCtrl.text.isEmpty ? "0" : mktProtCtrl.text)) /
            100;
        if (widget.modifyOrderArgs.trantype == "B") {
          price = (double.parse("${widget.orderArg.ltp ?? 0.00}") + ltp)
              .toStringAsFixed(2);
        } else {
          price = (double.parse("${widget.orderArg.ltp ?? 0.00}") - ltp)
              .toStringAsFixed(2);
        }
        priceCtrl.text = "Market";
      } else {
        priceCtrl.text = "${widget.modifyOrderArgs.prc}";
      }

      _isMarketOrder = prcType == "MKT";
      _isStoplossOrder = prcType == "SL-LMT" || prcType == "SL-MKT";
      _isBOCOOrderEnabled = widget.modifyOrderArgs.sPrdtAli == "BO" ||
          widget.modifyOrderArgs.sPrdtAli == "CO";

      marginUpdate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Allows back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // If system handled back, do nothing
      },

      child: Consumer(builder: (context, WidgetRef ref, _) {
        final orderProvide = ref.watch(orderProvider);
        final internet = ref.watch(networkStateProvider);
        final theme = ref.read(themeProvider);
        final clientFundDetail = ref.watch(fundProvider).fundDetailModel;
        final trancation = ref.watch(transcationProvider);

        int frezQtyOrderSliceMaxLimit =
            ref.read(orderProvider).frezQtyOrderSliceMaxLimit;

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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextWidget.subText(
                                      text: "${widget.scripInfo.symbol!} ",
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      fw: 3),
                                  // Text("${widget.scripInfo.symbol!} ",
                                  //     style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 14, FontWeight.w400),
                                  //     overflow: TextOverflow.ellipsis,
                                  //     maxLines: 1),
                                  if (widget.scripInfo.option!.isNotEmpty)
                                    TextWidget.subText(
                                        text: widget.scripInfo.option!,
                                        theme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        fw: 3),
                                  // Text(widget.scripInfo.option!,
                                  //     style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 14, FontWeight.w400),
                                  //     overflow: TextOverflow.ellipsis,
                                  //     maxLines: 1),
                                  if (widget.scripInfo.expDate!.isNotEmpty)
                                    TextWidget.subText(
                                        text: " ${widget.scripInfo.expDate} ",
                                        theme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        fw: 3),
                                  // Text(" ${widget.scripInfo.expDate} ",
                                  //     style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 14, FontWeight.w400)),
                                  CustomExchBadge(
                                      exch: "${widget.scripInfo.exch}"),
                                ]),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OrderScreenHeader(headerData: widget.orderArg),
                              // Row(children: [
                              //   SvgPicture.asset(assets.buyIcon),
                              //   const SizedBox(width: 6),
                              //   CustomSwitch(
                              //       onChanged: (bool value) {}, value: isBuy),
                              //   const SizedBox(width: 6),
                              //   SvgPicture.asset(assets.sellIcon)
                              // ])
                            ],
                          ),
                        ]),
                  ),
                ),
                body: SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                          reverse: true,
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                // Padding(
                                //     padding: const EdgeInsets.only(left: 16),
                                //     child: headerTitleText("Price type", theme)),
                                // const SizedBox(height: 10),
                                // Padding(
                                //     padding: const EdgeInsets.only(left: 16),
                                //     child: SizedBox(
                                //         height: 38,
                                //         child: ListView.separated(
                                //             scrollDirection: Axis.horizontal,
                                //             itemBuilder: (context, index) {
                                //               return ElevatedButton(
                                //                   onPressed: () {
                                //                     setState(() {
                                //                       for (var i = 0;i <isActivePrice.length;i++) {
                                //                         isActivePrice[i] = false;
                                //                       }
                                //                       isActivePrice[index] = true;
                                //                       if (isActivePrice[1] ||
                                //                           isActivePrice[3]) {
                                //                         double ltp = (double.parse("${widget.orderArg.ltp}") *
                                //                                 double.parse(mktProtCtrl.text.isEmpty
                                //                                     ? "0" : mktProtCtrl.text)) / 100;

                                //                         if (widget.modifyOrderArgs.trantype =="B") {
                                //                           price = (double.parse("${widget.orderArg.ltp ?? 0.00}") + ltp).toStringAsFixed(2);
                                //                         } else {
                                //                           price = (double.parse("${widget.orderArg.ltp ?? 0.00}") - ltp)
                                //                               .toStringAsFixed(2);
                                //                         }
                                //                         priceCtrl.text = "Market";
                                //                       } else {
                                //                         priceCtrl.text =
                                //                             "${widget.modifyOrderArgs.prc}";
                                //                       }
                                //                       prcType = isActivePrice[0] ? 'LMT' : isActivePrice[1] ? 'MKT' : isActivePrice[2] ? 'SL-LMT' : "SL-MKT";
                                //                     });
                                //                     FocusScope.of(context)
                                //                         .unfocus();
                                //                   },
                                //                   style: ElevatedButton.styleFrom(
                                //                       elevation: 0,
                                //                       padding: const EdgeInsets
                                //                           .symmetric(
                                //                           horizontal: 12,
                                //                           vertical: 0),
                                //                       backgroundColor: !theme
                                //                               .isDarkMode
                                //                           ? !isActivePrice[index]
                                //                               ? const Color(
                                //                                   0xffF1F3F8)
                                //                               : colors.colorBlack
                                //                           : !isActivePrice[index]
                                //                               ? colors.darkGrey
                                //                               : colors.colorWhite,
                                //                       shape:
                                //                           const StadiumBorder()),
                                //                   child: Text(priceType[index],
                                //                       style: textStyle(
                                //                           !theme.isDarkMode
                                //                               ? !isActivePrice[
                                //                                       index]
                                //                                   ? const Color(
                                //                                       0xff666666)
                                //                                   : colors
                                //                                       .colorWhite
                                //                               : !isActivePrice[
                                //                                       index]
                                //                                   ? const Color(
                                //                                       0xff666666)
                                //                                   : colors
                                //                                       .colorBlack,
                                //                           14,
                                //                           isActivePrice[index]
                                //                               ? FontWeight.w600
                                //                               : FontWeight
                                //                                   .w500)));
                                //             },
                                //             separatorBuilder: (context, index) {
                                //               return const SizedBox(width: 8);
                                //             },
                                //             itemCount:
                                //                 widget.modifyOrderArgs.sPrdtAli == "BO" ||
                                //                 widget.modifyOrderArgs.sPrdtAli == "CO" ? 3 : priceType.length))),
                                // const SizedBox(height: 3),
                                // const Divider(color: Color(0xffDDDDDD)),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                headerTitleText("Qty", theme),
                                                // Text(
                                                //   "Lot: ${widget.scripInfo.ls} ${widget.scripInfo.prcunt ?? ''}  ",
                                                //   style: textStyle(
                                                //       const Color(0xff777777),
                                                //       11,
                                                //       FontWeight.w600),
                                                // )
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 45,
                                              child: CustomTextFormField(
                                                fillColor: theme.isDarkMode
                                                    ? colors.darkGrey
                                                    : const Color(0xffF1F3F8),
                                                hintText:
                                                    "${widget.orderArg.lotSize}",
                                                hintStyle: TextWidget.textStyle(
                                                  fontSize: 14,
                                                  theme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors
                                                          .textSecondaryLight,
                                                ),
                                                inputFormate: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextWidget.textStyle(
                                                  fontSize: 16,
                                                  color: theme.isDarkMode
                                                      ? colors.textPrimaryDark
                                                      : colors.textPrimaryLight,
                                                  theme: theme.isDarkMode,
                                                ),
                                                // prefixIcon: InkWell(
                                                //   onTap: () {
                                                //     setState(() {

                                                //        String input =
                                                //                 qtyCtrl
                                                //                     .text;
                                                //             int currentQty =
                                                //                 int.tryParse(input) ??
                                                //                     0;
                                                //             int adjustedQty =
                                                //                 ((currentQty / multiplayer).floor()) *
                                                //                     multiplayer;
                                                //             if (currentQty !=
                                                //                 adjustedQty) {
                                                //               qtyCtrl.text =
                                                //                   adjustedQty
                                                //                       .toString();
                                                //             } else if (input
                                                //                   .isNotEmpty && currentQty >
                                                //                   multiplayer) {

                                                //                   qtyCtrl
                                                //                       .text = (currentQty -
                                                //                           multiplayer)
                                                //                       .toString();
                                                //               } else {
                                                //               qtyCtrl.text =
                                                //                   "$multiplayer";
                                                //               }
                                                //               marginUpdate();
                                                //           },
                                                //           );

                                                //       // String input = qtyCtrl.text;
                                                //       // int quantityValue = int.tryParse(input) ?? 0;

                                                //       // if (input.isNotEmpty && quantityValue > multiplayer) {
                                                //       //     qtyCtrl.text = (quantityValue - multiplayer).toString();
                                                //       // } else {
                                                //       //   qtyCtrl.text = "$multiplayer";
                                                //       // }
                                                //       // marginUpdate();
                                                //     // });
                                                //   },
                                                //   child: SvgPicture.asset(
                                                //       theme.isDarkMode
                                                //           ? assets
                                                //               .darkCMinus
                                                //           : theme.isDarkMode
                                                //               ? assets
                                                //                   .darkCMinus
                                                //               : assets
                                                //                   .minusIcon,
                                                //       fit:
                                                //           BoxFit.scaleDown),
                                                // ),
                                                // suffixIcon: InkWell(
                                                //   onTap: () {
                                                //     setState(() {
                                                //             String input =
                                                //                 qtyCtrl
                                                //                 .text;
                                                //         int currentQty =
                                                //             int.tryParse(input) ??
                                                //                 0;
                                                //         int adjustedQty =
                                                //             ((currentQty / multiplayer).round()) *
                                                //                 multiplayer;

                                                //         if (currentQty !=
                                                //             adjustedQty) {
                                                //           qtyCtrl.text =
                                                //               adjustedQty
                                                //                   .toString();
                                                //         }

                                                //           else if (input
                                                //               .isNotEmpty && currentQty <
                                                //               ((frezQtyOrderSliceMaxLimit*frezQty)==frezQtyOrderSliceMaxLimit?999999:frezQtyOrderSliceMaxLimit*frezQty)) {
                                                //               qtyCtrl.text = (currentQty + multiplayer).toString();
                                                //           } else {
                                                //             ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                //             ScaffoldMessenger.of(context)
                                                //                 .showSnackBar(warningMessage(context,"Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit*frezQty}"));
                                                //           // qtyCtrl.text =
                                                //           //     "$multiplayer";
                                                //           }
                                                //           marginUpdate();
                                                //       });

                                                //     //   String input = qtyCtrl.text;
                                                //     //   int quantityValue =int.parse(input);

                                                //     //   if (input.isNotEmpty quantityValue) {
                                                //     //     if (number <
                                                //     //         999999) {
                                                //     //       qtyCtrl
                                                //     //           .text = (int.parse(discQtyCtrl.text) +
                                                //     //                       1)
                                                //     //                   .toString();
                                                //     //     }
                                                //     //   } else {
                                                //     //     qtyCtrl.text =
                                                //     //         "$multiplayer";
                                                //     //   }
                                                //     //   marginUpdate();
                                                //     // });
                                                //   },
                                                //   child: SvgPicture.asset(
                                                //       theme.isDarkMode
                                                //           ? assets.darkAdd
                                                //           : assets.addIcon,
                                                //       fit:
                                                //           BoxFit.scaleDown),
                                                // ),
                                                textCtrl: qtyCtrl,
                                                textAlign: TextAlign.start,
                                                onChanged: (value) {
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                  if (value.isEmpty ||
                                                      value == "0") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Quantity can not be ${value == "0" ? 'zero' : 'empty'}"));
                                                  } else {
                                                    String newValue =
                                                        value.replaceAll(
                                                            RegExp(r'[^0-9]'),
                                                            '');
                                                    int number = int.tryParse(
                                                            newValue) ??
                                                        0;
                                                    if (number >
                                                        (frezQty == lotSize
                                                            ? 999999
                                                            : frezQtyOrderSliceMaxLimit *
                                                                frezQty)) {
                                                      qtyCtrl.text =
                                                          qtyCtrl.text;
                                                      // .substring(
                                                      //     0,
                                                      //     10); // Restrict max value
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .removeCurrentSnackBar();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Maximum Allowed Quantity $frezQty x $frezQtyOrderSliceMaxLimit = ${frezQtyOrderSliceMaxLimit * frezQty}"));
                                                    }
                                                    if (newValue != value) {
                                                      qtyCtrl.text = newValue;
                                                      qtyCtrl.selection =
                                                          TextSelection
                                                              .fromPosition(
                                                        TextPosition(
                                                            offset: newValue
                                                                .length),
                                                      );
                                                    }
                                                    marginUpdate();
                                                  }
                                                },
                                              ),

                                              // ScaffoldMessenger.of(
                                              //         context)
                                              //     .hideCurrentSnackBar();
                                              // if (value.isEmpty) {
                                              //   ScaffoldMessenger.of(
                                              //           context)
                                              //       .showSnackBar(
                                              //           warningMessage(
                                              //               context,
                                              //               "Quantity can not be empty"));
                                              // } else {
                                              //   String newValue =
                                              //       value.replaceAll(
                                              //           RegExp(
                                              //               r'[^0-9]'),
                                              //           '');
                                              //   if (newValue != value) {
                                              //     qtyCtrl.text =
                                              //         newValue;
                                              //     qtyCtrl.selection =
                                              //         TextSelection
                                              //             .fromPosition(
                                              //       TextPosition(
                                              //           offset: newValue
                                              //               .length),
                                              //     );
                                              //   }
                                              //   marginUpdate();
                                              // }
                                              //   },
                                              // )
                                            )
                                          ])),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                // mainAxisAlignment:
                                                //     MainAxisAlignment
                                                //         .spaceBetween,
                                                // crossAxisAlignment:
                                                //     CrossAxisAlignment.end,
                                                children: [
                                                  headerTitleText(
                                                      "Price", theme),
                                                  const SizedBox(width: 4),
                                                  TextWidget.subText(
                                                      text: prcType == "MKT"
                                                          ? "Market"
                                                          : prcType == "SL-MKT"
                                                              ? "SL MKT"
                                                              : prcType ==
                                                                      "SL-LMT"
                                                                  ? "SL Limit"
                                                                  : "Limit",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                ]),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 45,
                                              child: CustomTextFormField(
                                                  fillColor: theme.isDarkMode
                                                      ? colors.darkGrey
                                                      : const Color(0xffF1F3F8),
                                                  onChanged: (value) {
                                                    double inputPrice =
                                                        double.tryParse(
                                                                value) ??
                                                            0;
                                                    if (value.isNotEmpty &&
                                                        inputPrice > 0) {
                                                      final regex = RegExp(
                                                          r'^(\d+)?(\.\d{0,2})?$');
                                                      if (!regex
                                                          .hasMatch(value)) {
                                                        priceCtrl.text =
                                                            value.substring(
                                                                0,
                                                                value.length -
                                                                    1); // Revert to previous valid input
                                                        priceCtrl.selection =
                                                            TextSelection.collapsed(
                                                                offset: priceCtrl
                                                                    .text
                                                                    .length); // Keep cursor at the end
                                                      }
                                                    }
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .removeCurrentSnackBar();
                                                    if (value.isEmpty ||
                                                        inputPrice <= 0) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  "Limit Price can not be ${inputPrice <= 0 ? 'zero' : 'empty'}"));
                                                    } else {
                                                      if ((double.parse(value) <
                                                              double.parse(
                                                                  "${widget.scripInfo.lc}")) ||
                                                          (double.parse(value) >
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
                                                        marginUpdate();
                                                      });
                                                    }
                                                  },
                                                  hintText:
                                                      "${widget.orderArg.ltp}",
                                                  hintStyle:
                                                      TextWidget.textStyle(
                                                    fontSize: 14,
                                                    theme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                  ),
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  style: TextWidget.textStyle(
                                                    fontSize: 16,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,
                                                    theme: theme.isDarkMode,
                                                  ),
                                                  isReadable: prcType ==
                                                              "MKT" ||
                                                          prcType == "SL-MKT"
                                                      ? true
                                                      : false,
                                                  // prefixIcon: Container(
                                                  //     margin: const EdgeInsets.all(
                                                  //         12),
                                                  //     decoration: BoxDecoration(
                                                  //         borderRadius:
                                                  //             BorderRadius.circular(20),
                                                  //         color: theme.isDarkMode
                                                  //             ? const Color(0xff555555)
                                                  //             : colors.colorWhite),
                                                  //     child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, isActivePrice[1] || isActivePrice[3] ? assets.lock : assets.ruppeIcon, fit: BoxFit.scaleDown)),
                                                  suffixIcon: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _isMarketOrder =
                                                            !_isMarketOrder;
                                                        updatePriceType();

                                                        marginUpdate();
                                                      });
                                                    },
                                                    child: SvgPicture.asset(
                                                        assets.switchIcon,
                                                        fit: BoxFit.scaleDown),
                                                  ),
                                                  textCtrl: priceCtrl,
                                                  textAlign: TextAlign.start),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // const SizedBox(height: 16),
                                // Advance Option section
                                // Column(
                                //   children: [
                                //     GestureDetector(
                                //       onTap: () {
                                //         setState(() {
                                //           isAdvancedOptionClicked =
                                //               !isAdvancedOptionClicked;
                                //           updatePriceType();
                                //         });
                                //       },
                                //       child: Container(
                                //         color: Colors
                                //             .transparent, // To make the full width tappable
                                //         height: 48,
                                //         child: Center(
                                //           child: Row(
                                //             mainAxisSize: MainAxisSize.min,
                                //             children: [
                                //               Text('Advance',
                                //                   style: textStyle(
                                //                     colors.colorBlue,
                                //                     14,
                                //                     FontWeight.w600,
                                //                   )),
                                //               Padding(
                                //                 padding: const EdgeInsets.only(
                                //                     left: 4),
                                //                 child: Icon(
                                //                   isAdvancedOptionClicked
                                //                       ? Icons.keyboard_arrow_up
                                //                       : Icons.keyboard_arrow_down,
                                //                   color: colors.colorBlue,
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     Visibility(
                                //       visible: isAdvancedOptionClicked,
                                //       child: Column(
                                //         children: [
                                //           CheckboxListTile(
                                //               title: Text(
                                //                 'Stoploss order',
                                //                 style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400,
                                //                 ),
                                //               ),
                                //               value: _isStoplossOrder,
                                //               onChanged: (bool? value) {
                                //                 setState(() {
                                //                   _isStoplossOrder = value!;
                                //                   updatePriceType();
                                //                   // orderInput.chngPriceType(
                                //                   //     priceType,
                                //                   //     widget.orderArg.exchange);
                                //                   marginUpdate();
                                //                 });
                                //               },
                                //               controlAffinity:
                                //                   ListTileControlAffinity
                                //                       .trailing,
                                //               activeColor: colors.colorBlue,
                                //               checkboxShape:
                                //                   const RoundedRectangleBorder(
                                //                 borderRadius: BorderRadius.all(
                                //                     Radius.circular(5)),
                                //               )),
                                //           if (prcType == "SL-LMT" ||
                                //               prcType == "SL-MKT") ...[
                                //             triggerOption(
                                //                 theme, context, widget.scripInfo),
                                //             Divider(
                                //               color: theme.isDarkMode
                                //                   ? colors.darkColorDivider
                                //                   : colors.colorDivider,
                                //             ),
                                //           ],

                                //           // Divider(
                                //           //     color: theme.isDarkMode
                                //           //         ? colors.darkColorDivider
                                //           //         : colors.colorDivider),
                                //           // CheckboxListTile(
                                //           //     title: Text(
                                //           //       'After market order (AMO)',
                                //           //       style: textStyle(
                                //           //         theme.isDarkMode
                                //           //             ? colors.colorWhite
                                //           //             : colors.colorBlack,
                                //           //         14,
                                //           //         FontWeight.w400,
                                //           //       ),
                                //           //     ),
                                //           //     value: _afterMarketOrder,
                                //           //     onChanged: (bool? value) {
                                //           //       setState(() {
                                //           //         _afterMarketOrder = value!;
                                //           //         //   isAmo = !isAmo;
                                //           //       });
                                //           //     },
                                //           //     controlAffinity:
                                //           //         ListTileControlAffinity
                                //           //             .trailing,
                                //           //     activeColor: colors.colorBlue,
                                //           //     checkboxShape:
                                //           //         const RoundedRectangleBorder(
                                //           //       borderRadius: BorderRadius.all(
                                //           //           Radius.circular(5)),
                                //           //     )),
                                //           // Divider(
                                //           //     color: theme.isDarkMode
                                //           //         ? colors.darkColorDivider
                                //           //         : colors.colorDivider),
                                //           // CheckboxListTile(
                                //           //   title: Text(
                                //           //     'Add validity & Disclosed quantity',
                                //           //     style: textStyle(
                                //           //       theme.isDarkMode
                                //           //           ? colors.colorWhite
                                //           //           : colors.colorBlack,
                                //           //       14,
                                //           //       FontWeight.w400,
                                //           //     ),
                                //           //   ),
                                //           //   value: _addValidityAndDisclosedQty,
                                //           //   onChanged: (bool? value) {
                                //           //     setState(() {
                                //           //       _addValidityAndDisclosedQty =
                                //           //           value!;
                                //           //     });
                                //           //   },
                                //           //   controlAffinity:
                                //           //       ListTileControlAffinity
                                //           //           .trailing,
                                //           //   activeColor: colors.colorBlue,
                                //           //   checkboxShape:
                                //           //       const RoundedRectangleBorder(
                                //           //     borderRadius: BorderRadius.all(
                                //           //         Radius.circular(5)),
                                //           //   ),
                                //           // ),
                                //           // if (_addValidityAndDisclosedQty) ...[
                                //           //   addValidityAndDisclosedQtyOption(
                                //           //       theme,
                                //           //       context,
                                //           //       widget.scripInfo),
                                //           //   const SizedBox(height: 10)
                                //           // ],
                                //           // Divider(
                                //           //     color: theme.isDarkMode
                                //           //         ? colors.darkColorDivider
                                //           //         : colors.colorDivider),
                                //           // SizedBox(
                                //           //     height: priceType == "Market"
                                //           //         ? 180
                                //           //         : 100)
                                //         ],
                                //       ),
                                //     ),
                                //   ],
                                // ),

                                // const SizedBox(height: 16),
                                // const Divider(color: Color(0xffDDDDDD)),
                                // (widget.modifyOrderArgs.sPrdtAli != "BO" && widget.modifyOrderArgs.sPrdtAli != "CO") &&
                                if ((prcType == "SL-LMT" ||
                                    prcType == "SL-MKT")) ...[
                                  const SizedBox(height: 16),
                                  triggerOption(
                                      theme, context, widget.scripInfo),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                ],
                                if (_isBOCOOrderEnabled) ...[
                                  const SizedBox(height: 16),
                                  stopLossOption(
                                      theme, context, widget.scripInfo)
                                ],
                                // Padding(
                                //     padding:
                                //         const EdgeInsets.only(left: 16, right: 4),
                                //     child: Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.spaceBetween,
                                //         children: [
                                //           Text("Add Validity & Disclosed Qty",
                                //               style: textStyle(
                                //                   const Color(0xff666666),
                                //                   14,
                                //                   FontWeight.w500)),
                                //           IconButton(
                                //               onPressed: () {
                                //                 setState(() {
                                //                   addValidity = !addValidity;
                                //                 });
                                //               },
                                //               icon: SvgPicture.asset(theme
                                //                       .isDarkMode
                                //                   ? addValidity
                                //                       ? assets.darkCheckedboxIcon
                                //                       : assets.darkCheckboxIcon
                                //                   : addValidity
                                //                       ? assets.checkedbox
                                //                       : assets.checkbox))
                                //         ])),
                                // if (addValidity) ...[
                                //   Padding(
                                //       padding: const EdgeInsets.symmetric(
                                //           horizontal: 16),
                                //       child: Row(
                                //           crossAxisAlignment:
                                //               CrossAxisAlignment.start,
                                //           children: [
                                //             Expanded(
                                //                 child: Column(
                                //                     crossAxisAlignment:
                                //                         CrossAxisAlignment.start,
                                //                     children: [
                                //                   headerTitleText(
                                //                       "Validity", theme),
                                //                   const SizedBox(height: 7),
                                //                   SizedBox(
                                //                     height: 43,
                                //                     child: ListView.separated(
                                //                         scrollDirection:
                                //                             Axis.horizontal,
                                //                         itemBuilder:
                                //                             (context, index) {
                                //                           return ElevatedButton(
                                //                             onPressed: () {
                                //                               setState(() {
                                //                                 for (var i = 0;
                                //                                     i <
                                //                                         validityType
                                //                                             .length;
                                //                                     i++) {
                                //                                   isActiveValidity[
                                //                                       i] = false;
                                //                                 }
                                //                                 isActiveValidity[
                                //                                     index] = true;

                                //                                 validity =
                                //                                     validityType[
                                //                                         index];
                                //                               });
                                //                             },
                                //                             style: ElevatedButton
                                //                                 .styleFrom(
                                //                                     elevation: 0,
                                //                                     padding: const EdgeInsets
                                //                                         .symmetric(
                                //                                         horizontal:
                                //                                             12,
                                //                                         vertical:
                                //                                             0),
                                //                                     backgroundColor: !theme
                                //                                             .isDarkMode
                                //                                         ? !isActiveValidity[
                                //                                                 index]
                                //                                             ? const Color(
                                //                                                 0xffF1F3F8)
                                //                                             : colors
                                //                                                 .colorBlack
                                //                                         : !isActiveValidity[
                                //                                                 index]
                                //                                             ? colors
                                //                                                 .darkGrey
                                //                                             : colors
                                //                                                 .colorWhite,
                                //                                     shape:
                                //                                         const StadiumBorder()),
                                //                             child: Text(
                                //                               validityType[index],
                                //                               style: textStyle(
                                //                                   !theme
                                //                                           .isDarkMode
                                //                                       ? !isActiveValidity[
                                //                                               index]
                                //                                           ? const Color(
                                //                                               0xff666666)
                                //                                           : colors
                                //                                               .colorWhite
                                //                                       : !isActiveValidity[
                                //                                               index]
                                //                                           ? const Color(
                                //                                               0xff666666)
                                //                                           : colors
                                //                                               .colorBlack,
                                //                                   14,
                                //                                   isActiveValidity[
                                //                                           index]
                                //                                       ? FontWeight
                                //                                           .w600
                                //                                       : FontWeight
                                //                                           .w500),
                                //                             ),
                                //                           );
                                //                         },
                                //                         separatorBuilder:
                                //                             (context, index) {
                                //                           return const SizedBox(
                                //                               width: 8);
                                //                         },
                                //                         itemCount:
                                //                             validityType.length),
                                //                   )
                                //                 ])),
                                //             const SizedBox(width: 16),
                                //             Expanded(
                                //                 child: Column(
                                //                     crossAxisAlignment:
                                //                         CrossAxisAlignment.start,
                                //                     children: [
                                //                   headerTitleText(
                                //                       "Disclosed Qty", theme),
                                //                   const SizedBox(height: 7),
                                //                   SizedBox(
                                //                       height: 44,
                                //                       child: CustomTextFormField(
                                //                           fillColor:
                                //                               theme.isDarkMode
                                //                                   ? colors
                                //                                       .darkGrey
                                //                                   : const Color(
                                //                                       0xffF1F3F8),
                                //                           // type:"int",
                                //                           hintText: "0",
                                //                           hintStyle: textStyle(
                                //                               const Color(
                                //                                   0xff666666),
                                //                               15,
                                //                               FontWeight.w400),
                                //                           inputFormate: [
                                //                             FilteringTextInputFormatter
                                //                                 .digitsOnly
                                //                           ],
                                //                           keyboardType:
                                //                               TextInputType
                                //                                   .number,
                                //                           style: textStyle(
                                //                               theme.isDarkMode
                                //                                   ? colors
                                //                                       .colorWhite
                                //                                   : colors
                                //                                       .colorBlack,
                                //                               16,
                                //                               FontWeight.w600),
                                //                           prefixIcon: InkWell(
                                //                             onTap: () {
                                //                               setState(() {
                                //                                 if (discQtyCtrl
                                //                                     .text
                                //                                     .isNotEmpty) {
                                //                                   if (int.parse(
                                //                                           discQtyCtrl
                                //                                               .text) >
                                //                                       0) {
                                //                                     discQtyCtrl
                                //                                             .text =
                                //                                         (int.parse(discQtyCtrl.text) -
                                //                                                 1)
                                //                                             .toString();
                                //                                   } else {
                                //                                     discQtyCtrl
                                //                                             .text =
                                //                                         "0";
                                //                                   }
                                //                                 } else {
                                //                                   discQtyCtrl
                                //                                       .text = "0";
                                //                                 }
                                //                               });
                                //                             },
                                //                             child: SvgPicture.asset(
                                //                                 theme.isDarkMode
                                //                                     ? assets
                                //                                         .darkCMinus
                                //                                     : assets
                                //                                         .minusIcon,
                                //                                 fit: BoxFit
                                //                                     .scaleDown),
                                //                           ),
                                //                           suffixIcon: InkWell(
                                //                             onTap: () {
                                //                               setState(() {
                                //                                 int number =
                                //                                     int.parse(
                                //                                         discQtyCtrl
                                //                                             .text);
                                //                                 if (discQtyCtrl
                                //                                     .text
                                //                                     .isNotEmpty) {
                                //                                   if (number <
                                //                                       999999) {
                                //                                     discQtyCtrl
                                //                                             .text =
                                //                                         (int.parse(discQtyCtrl.text) +
                                //                                                 1)
                                //                                             .toString();
                                //                                   }
                                //                                 } else {
                                //                                   discQtyCtrl.text = "0";
                                //                                 }
                                //                               });
                                //                             },
                                //                             child: SvgPicture.asset(
                                //                                 theme.isDarkMode
                                //                                     ? assets
                                //                                         .darkAdd
                                //                                     : assets
                                //                                         .addIcon,
                                //                                 fit: BoxFit
                                //                                     .scaleDown),
                                //                           ),
                                //                           textCtrl: discQtyCtrl,
                                //                           textAlign:
                                //                               TextAlign.center))
                                //                 ]))
                                //           ])),
                                //   const SizedBox(height: 10)
                                // ],
                                // const Divider(
                                //     color: Color(0xffDDDDDD), height: 0),
                                // Padding(
                                //     padding:
                                //         const EdgeInsets.only(left: 16, right: 4),
                                //     child: Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.spaceBetween,
                                //         children: [
                                //           Text("After Market Order (AMO)",
                                //               style: textStyle(
                                //                   const Color(0xff666666),
                                //                   14,
                                //                   FontWeight.w500)),
                                //           IconButton(
                                //               onPressed: () {
                                //                 setState(() {
                                //                   isAmo = !isAmo;
                                //                 });
                                //               },
                                //               icon: SvgPicture.asset(theme
                                //                       .isDarkMode
                                //                   ? isAmo
                                //                       ? assets.darkCheckedboxIcon
                                //                       : assets.darkCheckboxIcon
                                //                   : isAmo
                                //                       ? assets.checkedbox
                                //                       : assets.checkbox))
                                //         ])),
                                if (prcType == "MKT" ||
                                    prcType == "SL-MKT") ...[
                                  const SizedBox(height: 16),
                                  marketProtectionDisclaimer(theme, context,
                                      widget.scripInfo, mktProtCtrl.text),
                                  const SizedBox(height: 16),
                                ],
                                const SizedBox(height: 100)
                              ])),
                      if (internet.connectionStatus ==
                          ConnectivityResult.none) ...[const NoInternetWidget()]
                    ],
                  ),
                ),
                bottomNavigationBar:
                    internet.connectionStatus == ConnectivityResult.none
                        ? const NoInternetWidget()
                        : SafeArea(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                  color: theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // if (prcType == "MKT" || prcType == "SL-MKT") ...[
                                        //   Padding(
                                        //     padding: const EdgeInsets.only(
                                        //         left: 16.0, bottom: 6),
                                        //     child: headerTitleText(
                                        //         "Market Protection", theme),
                                        //   ),
                                        //   Container(
                                        //       padding: const EdgeInsets.only(
                                        //           left: 16.0, bottom: 6),
                                        //       height: 40,
                                        //       child: Row(children: [
                                        //         Expanded(
                                        //             child: CustomTextFormField(
                                        //                 fillColor: theme.isDarkMode
                                        //                     ? colors.darkGrey
                                        //                     : const Color(0xffF1F3F8),
                                        //                 inputFormate: [
                                        //                   FilteringTextInputFormatter
                                        //                       .digitsOnly
                                        //                 ],
                                        //                 onChanged: (value) {
                                        //                   setState(() {
                                        //                     ScaffoldMessenger.of(context)
                                        //                         .hideCurrentSnackBar();
                                        //                     if (value.isNotEmpty) {
                                        //                       if (int.parse(value) > 20) {
                                        //                         mktProtCtrl.text = "20";
                                        //                         ScaffoldMessenger.of(
                                        //                                 context)
                                        //                             .showSnackBar(
                                        //                                 warningMessage(
                                        //                                     context,
                                        //                                     "can't enter greater than 20% of Market Protection"));
                                        //                       } else if (int.parse(
                                        //                               value) <
                                        //                           1) {
                                        //                         mktProtCtrl.text = "1";
                                        //                         ScaffoldMessenger.of(
                                        //                                 context)
                                        //                             .showSnackBar(
                                        //                                 warningMessage(
                                        //                                     context,
                                        //                                     "can't enter less than 1% of Market Protection"));
                                        //                       }
                                        //                     }
                                        //                   });
                                        //                 },
                                        //                 keyboardType:
                                        //                     TextInputType.number,
                                        //                 style: textStyle(
                                        //                     theme.isDarkMode
                                        //                         ? colors.colorWhite
                                        //                         : colors.colorBlack,
                                        //                     14,
                                        //                     FontWeight.w600),
                                        //                 textCtrl: mktProtCtrl,
                                        //                 textAlign: TextAlign.start))
                                        //       ]))
                                        // ],
                                        Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            // height: 36,
                                            decoration: BoxDecoration(
                                                color: theme.isDarkMode
                                                    ? colors.darkGrey
                                                    : const Color(0xfffafbff),
                                                border: Border(
                                                    top: BorderSide(
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .darkColorDivider
                                                            : colors
                                                                .colorDivider),
                                                    bottom: BorderSide(
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .darkColorDivider
                                                            : colors
                                                                .colorDivider))),
                                            padding: const EdgeInsets.only(
                                                left: 16.0, right: 3, top: 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SingleChildScrollView(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
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
                                                                          useSafeArea:
                                                                              true,
                                                                          isScrollControlled:
                                                                              true,
                                                                          shape:
                                                                              const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                                                          context: context,
                                                                          builder: (context) {
                                                                            return const MarginDetailsBottomsheet();
                                                                          });
                                                                    },
                                                              widget: Row(
                                                                  children: [
                                                                    TextWidget.paraText(
                                                                        text:
                                                                            "Ord Mrg : ",
                                                                        theme: theme
                                                                            .isDarkMode,
                                                                        color: theme.isDarkMode
                                                                            ? colors.textSecondaryDark
                                                                            : colors.textSecondaryLight,
                                                                        fw: 3),
                                                                    Text(
                                                                        "₹${orderProvide.orderMarginModel == null ? 0.00 : orderProvide.orderMarginModel!.ordermargin}  + ${orderProvide.getBrokerageModel == null ? 0.00 : orderProvide.getBrokerageModel!.brkageAmt ?? 0.00}",
                                                                        style: textStyle(
                                                                            !theme.isDarkMode
                                                                                ? colors.colorBlue
                                                                                : colors.colorLightBlue,
                                                                            12,
                                                                            FontWeight.w600)),
                                                                    Icon(
                                                                      Icons
                                                                          .arrow_drop_down,
                                                                      color: !theme.isDarkMode
                                                                          ? colors
                                                                              .colorBlue
                                                                          : colors
                                                                              .colorLightBlue,
                                                                    )
                                                                  ])),
                                                          const SizedBox(
                                                              width: 16),
                                                          Row(
                                                            children: [
                                                              TextWidget.paraText(
                                                                  text:
                                                                      "Avl Mrg : ",
                                                                  theme: theme
                                                                      .isDarkMode,
                                                                  color: theme.isDarkMode
                                                                      ? colors
                                                                          .textSecondaryDark
                                                                      : colors
                                                                          .textSecondaryLight,
                                                                  fw: 3),

                                                              // const SizedBox(width: 4),
                                                              TextWidget.paraText(
                                                                  text:
                                                                      " ${clientFundDetail?.avlMrg ?? ''}",
                                                                  theme: theme
                                                                      .isDarkMode,
                                                                  color: theme.isDarkMode
                                                                      ? colors
                                                                          .textPrimaryDark
                                                                      : colors
                                                                          .textPrimaryLight,
                                                                  fw: 3),
                                                              // const SizedBox(width: 4),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          orderProvide.orderMarginModel !=
                                                                  null
                                                              ? orderProvide
                                                                          .orderMarginModel!
                                                                          .remarks ==
                                                                      "Insufficient Balance"
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () {
                                                                        ref.read(transcationProvider).fetchValidateToken(
                                                                            context);
                                                                        Future.delayed(
                                                                            const Duration(milliseconds: 100),
                                                                            () async {
                                                                          await trancation
                                                                              .ip();
                                                                          await trancation.fetchupiIdView(
                                                                              trancation.bankdetails!.dATA![trancation.indexss][1],
                                                                              trancation.bankdetails!.dATA![trancation.indexss][2]);
                                                                          await trancation
                                                                              .fetchcwithdraw(context);
                                                                        });

                                                                        trancation
                                                                            .changebool(true);
                                                                        Navigator.pushNamed(
                                                                            context,
                                                                            Routes
                                                                                .fundscreen,
                                                                            arguments:
                                                                                trancation);
                                                                      },
                                                                      child:
                                                                          Row(
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
                                                                          Text(
                                                                            '+ Add fund',
                                                                            style: textStyle(
                                                                                !theme.isDarkMode ? colors.colorBlue : colors.colorLightBlue,
                                                                                12,
                                                                                FontWeight.w600),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : const SizedBox()
                                                              : const SizedBox(),
                                                          // CustomWidgetButton(
                                                          //   onPress:
                                                          //       internet.connectionStatus ==
                                                          //               ConnectivityResult
                                                          //                   .none
                                                          //           ? () {}
                                                          //           : () {
                                                          //               marginUpdate();

                                                          //               showModalBottomSheet(
                                                          //                   useSafeArea: true,
                                                          //                   isScrollControlled:
                                                          //                       true,
                                                          //                   shape: const RoundedRectangleBorder(
                                                          //                       borderRadius:
                                                          //                           BorderRadius.vertical(
                                                          //                               top: Radius.circular(
                                                          //                                   16))),
                                                          //                   context: context,
                                                          //                   builder:
                                                          //                       (context) {
                                                          //                     return const ChargesDetailsBottomsheet();
                                                          //                   });
                                                          //             },
                                                          //   widget: Row(children: [
                                                          //     Text("Charges: ",
                                                          //         style: textStyle(
                                                          //             const Color(0xff666666),
                                                          //             12,
                                                          //             FontWeight.w500)),
                                                          //     Text(
                                                          //         "₹${orderProvide.getBrokerageModel == null ? 0.00 : orderProvide.getBrokerageModel!.brkageAmt ?? 0.00}",
                                                          //         style: textStyle(
                                                          //             !theme.isDarkMode
                                                          //                 ? colors.colorBlue
                                                          //                 : colors
                                                          //                     .colorLightBlue,
                                                          //             12,
                                                          //             FontWeight.w600)),
                                                          //     Icon(
                                                          //       Icons.arrow_drop_down,
                                                          //       color: !theme.isDarkMode
                                                          //           ? colors.colorBlue
                                                          //           : colors.colorLightBlue,
                                                          //     )
                                                          //   ]),
                                                          // )
                                                        ]),
                                                        IconButton(
                                                            onPressed: internet
                                                                        .connectionStatus ==
                                                                    ConnectivityResult
                                                                        .none
                                                                ? null
                                                                : () {
                                                                    marginUpdate();
                                                                  },
                                                            icon: SvgPicture
                                                                .asset(assets
                                                                    .reloadIcon))
                                                      ]),
                                                ),
                                              ],
                                            )),
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 4),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: ElevatedButton(
                                                onPressed:
                                                    internet.connectionStatus ==
                                                            ConnectivityResult
                                                                .none
                                                        ? null
                                                        : () async {
                                                            if (!orderProvide
                                                                .orderloader) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .hideCurrentSnackBar();
                                                              if (qtyCtrl.text
                                                                      .isEmpty ||
                                                                  priceCtrl.text
                                                                      .isEmpty) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(warningMessage(
                                                                        context,
                                                                        qtyCtrl.text.isEmpty
                                                                            ? "Quantity can not be empty"
                                                                            : "Price can not be empty"));
                                                              } else if (qtyCtrl
                                                                          .text ==
                                                                      "0" ||
                                                                  priceCtrl.text ==
                                                                      "0") {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(warningMessage(
                                                                        context,
                                                                        qtyCtrl.text ==
                                                                                "0"
                                                                            ? "Quantity can not be 0"
                                                                            : "Price can not be 0"));
                                                              } else if ((double.parse(prcType == "MKT" || prcType == "SL-MKT" ? price : priceCtrl.text) < double.parse("${widget.scripInfo.lc}")) ||
                                                                  (double.parse(prcType == "MKT" || prcType == "SL-MKT" ? price : priceCtrl.text) >
                                                                      double.parse(
                                                                          "${widget.scripInfo.uc}"))) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(warningMessage(
                                                                        context,
                                                                        double.parse(prcType == "MKT" || prcType == "SL-MKT" ? price : priceCtrl.text) <
                                                                                double.parse("${widget.scripInfo.lc}")
                                                                            ? "Price can not be lesser than Lower Circuit Limit ${widget.scripInfo.lc} 2 $price ${priceCtrl.text}"
                                                                            : "Price can not be greater than Lower Circuit Limit ${widget.scripInfo.uc} 2"));
                                                              } else if ((prcType ==
                                                                      "SL-LMT" ||
                                                                  prcType ==
                                                                      "SL-MKT")) {
                                                                if (triggerPriceCtrl
                                                                        .text
                                                                        .isEmpty ||
                                                                    triggerPriceCtrl
                                                                            .text ==
                                                                        "0") {
                                                                  ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                      context,
                                                                      triggerPriceCtrl
                                                                              .text
                                                                              .isEmpty
                                                                          ? "Trigger can not be empty"
                                                                          : "Trigger can not be 0"));
                                                                } else {
                                                                  if (isBuy) {
                                                                    if (prcType ==
                                                                        "SL-LMT") {
                                                                      if (double.parse(triggerPriceCtrl
                                                                              .text) <
                                                                          double.parse(widget.orderArg.ltp ??
                                                                              "0.00")) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger should be greater than LTP ${double.parse(triggerPriceCtrl.text) > double.parse(widget.orderArg.ltp ?? "0.00")}"));
                                                                      } else if (double.parse(triggerPriceCtrl
                                                                              .text) >
                                                                          double.parse(widget.scripInfo.uc ??
                                                                              "0.00")) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger can not be greater than upper circuit limit of ${widget.scripInfo.uc ?? 0.00}"));
                                                                      } else {
                                                                        if ((int.parse(qtyCtrl.text.isEmpty ? "0" : qtyCtrl.text) >
                                                                                frezQty &&
                                                                            widget.scripInfo.frzqty !=
                                                                                null)) {
                                                                          modifyOrder();
                                                                        } else {
                                                                          modifyOrder();
                                                                        }
                                                                      }
                                                                    } else {
                                                                      if (double.parse(triggerPriceCtrl
                                                                              .text) <
                                                                          double.parse(widget.scripInfo.lc ??
                                                                              "0.00")) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger can not be lesser than lower circuit limit of ${widget.scripInfo.lc ?? 0.00}"));
                                                                      } else if (double.parse(priceCtrl
                                                                              .text) <
                                                                          double.parse(triggerPriceCtrl
                                                                              .text)) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger should be less than price"));
                                                                      } else if (double.parse(triggerPriceCtrl
                                                                              .text) >
                                                                          double.parse(widget.scripInfo.uc ??
                                                                              "0.00")) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger can not be greater than upper circuit limit of ${widget.scripInfo.uc ?? 0.00}"));
                                                                      } else {
                                                                        if ((int.parse(qtyCtrl.text.isEmpty ? "0" : qtyCtrl.text) >
                                                                                frezQty &&
                                                                            widget.scripInfo.frzqty !=
                                                                                null)) {
                                                                          modifyOrder();
                                                                        } else {
                                                                          modifyOrder();
                                                                        }
                                                                      }
                                                                    }
                                                                  } else {
                                                                    if (prcType ==
                                                                        "SL-LMT") {
                                                                      if (double.parse(triggerPriceCtrl
                                                                              .text) >
                                                                          double.parse(widget.orderArg.ltp ??
                                                                              "0.00")) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger should be lesser than LTP"));
                                                                      } else if (double.parse(triggerPriceCtrl
                                                                              .text) <
                                                                          double.parse(widget.scripInfo.lc ??
                                                                              "0.00")) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger can not be lesser than lower circuit limit of ${widget.scripInfo.lc ?? 0.00}"));
                                                                      } else {
                                                                        if ((int.parse(qtyCtrl.text.isEmpty ? "0" : qtyCtrl.text) >
                                                                                frezQty &&
                                                                            widget.scripInfo.frzqty !=
                                                                                null)) {
                                                                          modifyOrder();
                                                                        } else {
                                                                          modifyOrder();
                                                                        }
                                                                      }
                                                                    } else {
                                                                      if (double.parse(triggerPriceCtrl
                                                                              .text) >
                                                                          double.parse(widget.scripInfo.uc ??
                                                                              "0.00")) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger can not be greater than upper circuit limit of ${widget.scripInfo.uc ?? 0.00}"));
                                                                      } else if (double.parse(
                                                                              price) >
                                                                          double.parse(triggerPriceCtrl
                                                                              .text)) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger should be greater than price"));
                                                                      } else if (double.parse(triggerPriceCtrl
                                                                              .text) <
                                                                          double.parse(widget.scripInfo.lc ??
                                                                              "0.00")) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                                                            context,
                                                                            "Trigger can not be lesser than lower circuit limit of ${widget.scripInfo.lc ?? 0.00}"));
                                                                      } else {
                                                                        if ((int.parse(qtyCtrl.text.isEmpty ? "0" : qtyCtrl.text) >
                                                                                frezQty &&
                                                                            widget.scripInfo.frzqty !=
                                                                                null)) {
                                                                          modifyOrder();
                                                                        } else {
                                                                          modifyOrder();
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              } else if (widget
                                                                      .modifyOrderArgs
                                                                      .sPrdtAli ==
                                                                  "BO") {
                                                                if (stopLossCtrl
                                                                        .text
                                                                        .isEmpty ||
                                                                    targetCtrl
                                                                        .text
                                                                        .isEmpty) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(warningMessage(
                                                                          context,
                                                                          "${stopLossCtrl.text.isEmpty ? "Stoploss" : "Target"} can not be empty"));
                                                                } else {
                                                                  modifyOrder();
                                                                }
                                                              } else if (widget
                                                                      .modifyOrderArgs
                                                                      .sPrdtAli ==
                                                                  "CO") {
                                                                if (stopLossCtrl
                                                                    .text
                                                                    .isEmpty) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(warningMessage(
                                                                          context,
                                                                          " Stoploss can not be empty"));
                                                                } else {
                                                                  modifyOrder();
                                                                }
                                                              } else {
                                                                modifyOrder();
                                                              }
                                                            }
                                                          },
                                                style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    minimumSize: const Size(
                                                        double.infinity, 45),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    backgroundColor: theme
                                                            .isDarkMode
                                                        ? isBuy
                                                            ? colors.primary
                                                            : colors.tertiary
                                                        : isBuy
                                                            ? colors.primary
                                                            : colors.tertiary
                                                    // shape: const StadiumBorder()
                                                    ),
                                                child: orderProvide.orderloader
                                                    ? SizedBox(
                                                        width: 18,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: theme.isDarkMode
                                                                ? colors
                                                                    .colorBlack
                                                                : colors
                                                                    .colorWhite),
                                                      )
                                                    : TextWidget.subText(
                                                        text: "Modify Order",
                                                        color:
                                                            colors.colorWhite,
                                                        fw: 2,
                                                        theme: theme.isDarkMode)

                                                // Text(, style: textStyle(theme.isDarkMode ? colors.colorBlack : colors.colorWhite, 14, FontWeight.w600))

                                                )),
                                        if (defaultTargetPlatform ==
                                            TargetPlatform.iOS)
                                          const SizedBox(height: 18)
                                      ])),
                            ),
                          )));
      }),
    );
  }

  headerTitleText(String text, ThemesProvider theme) {
    return TextWidget.subText(
      text: text,
      theme: theme.isDarkMode,
      color:
          theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
      fw: 0,
    );

    // Text(text,
    //     style: textStyle(
    //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
    //         14,
    //         FontWeight.w500));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }

  Padding triggerOption(
      ThemesProvider theme, BuildContext context, ScripInfoModel scripInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  hintStyle:
                      textStyle(const Color(0xff666666), 15, FontWeight.w400),
                  onChanged: (value) {
                    double inputPrice = double.tryParse(value) ?? 0;
                    if (value.isNotEmpty && inputPrice > 0) {
                      final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                      if (!regex.hasMatch(value)) {
                        triggerPriceCtrl.text = value.substring(0,
                            value.length - 1); // Revert to previous valid input
                        triggerPriceCtrl.selection = TextSelection.collapsed(
                            offset: triggerPriceCtrl
                                .text.length); // Keep cursor at the end
                      }
                    }
                    if (value.isEmpty || inputPrice <= 0) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                          context,
                          "Trigger can not be ${inputPrice <= 0 ? 'zero' : 'empty'}"));
                    }
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      16,
                      FontWeight.w600),
                  // prefixIcon: Container(
                  //     margin: const EdgeInsets.all(12),
                  //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                  //     child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, assets.ruppeIcon, fit: BoxFit.scaleDown)),
                  textCtrl: triggerPriceCtrl,
                  textAlign: TextAlign.start))
        ],
      ),
    );
  }

  Padding stopLossOption(
      ThemesProvider theme, BuildContext context, ScripInfoModel scripInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          prcType == "SL-LMT" ? const SizedBox(height: 10) : Container(),
          if (widget.modifyOrderArgs.sPrdtAli == "BO" &&
              widget.modifyOrderArgs.bpprc != null) ...[
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
                      double inputPrice = double.tryParse(value) ?? 0;

                      if (value.isNotEmpty && inputPrice > 0) {
                        final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                        if (!regex.hasMatch(value)) {
                          targetCtrl.text = value.substring(
                              0,
                              value.length -
                                  1); // Revert to previous valid input
                          targetCtrl.selection = TextSelection.collapsed(
                              offset: targetCtrl
                                  .text.length); // Keep cursor at the end
                        }
                      }

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      if (value.isEmpty || inputPrice <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                            context,
                            "Target can not be ${inputPrice <= 0 ? 'zero' : 'empty'}"));
                      }
                    },
                    hintStyle:
                        textStyle(const Color(0xff666666), 15, FontWeight.w400),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600),
                    // prefixIcon: Container(
                    //   margin: const EdgeInsets.all(12),
                    //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                    //   child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, assets.ruppeIcon, fit: BoxFit.scaleDown),
                    // ),
                    textCtrl: targetCtrl,
                    textAlign: TextAlign.start)),
            const SizedBox(height: 10),
          ],
          if ((widget.modifyOrderArgs.sPrdtAli == "CO" ||
                  widget.modifyOrderArgs.sPrdtAli == "BO") &&
              widget.modifyOrderArgs.blprc != null) ...[
            headerTitleText("Stoploss", theme),
            const SizedBox(height: 7),
            SizedBox(
                height: 44,
                child: CustomTextFormField(
                    fillColor: theme.isDarkMode
                        ? colors.darkGrey
                        : const Color(0xffF1F3F8),
                    onChanged: (value) {
                      double inputPrice = double.tryParse(value) ?? 0;

                      if (value.isNotEmpty && inputPrice > 0) {
                        final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                        if (!regex.hasMatch(value)) {
                          stopLossCtrl.text = value.substring(
                              0,
                              value.length -
                                  1); // Revert to previous valid input
                          stopLossCtrl.selection = TextSelection.collapsed(
                              offset: stopLossCtrl
                                  .text.length); // Keep cursor at the end
                        }
                      }
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      if (value.isEmpty || inputPrice <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                            context,
                            "Stoploss can not be ${inputPrice <= 0 ? 'zero' : 'empty'}"));
                      }
                    },
                    hintText: "0.00",
                    hintStyle:
                        textStyle(const Color(0xff666666), 15, FontWeight.w400),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600),
                    // prefixIcon: Container(
                    //   margin: const EdgeInsets.all(12),
                    //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: theme.isDarkMode ? const Color(0xff555555) : colors.colorWhite),
                    //   child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, assets.ruppeIcon, fit: BoxFit.scaleDown),
                    // ),
                    textCtrl: stopLossCtrl,
                    textAlign: TextAlign.start)),
          ],
        ],
      ),
    );
  }

  Padding marketProtectionDisclaimer(ThemesProvider theme, BuildContext context,
      ScripInfoModel scripInfo, String marketProtection) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Market Protected by",
                style: textStyle(
                    theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
                    14,
                    FontWeight.w600),
              ),
              InkWell(
                // borderRadius: BorderRadius.circular(8),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: theme.isDarkMode
                            ? const Color(0xFF121212)
                            : const Color(0xFFF1F3F8),
                        titlePadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        scrollable: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        actionsPadding: const EdgeInsets.only(
                            bottom: 16, right: 16, left: 16, top: 8),
                        insetPadding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        // title: Text('Enter Market Protection', style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 16, FontWeight.w600)),

                        title: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: () async {
                                    await Future.delayed(
                                        const Duration(milliseconds: 150));
                                    Navigator.pop(context);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  splashColor: theme.isDarkMode
                                      ? colors.splashColorDark
                                      : colors.splashColorLight,
                                  highlightColor: theme.isDarkMode
                                      ? colors.splashColorDark
                                      : colors.splashColorLight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 22,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 45,
                            child: CustomTextFormField(
                              fillColor: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              inputFormate: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                               hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                                    
                              onChanged: (value) {
                                setState(() {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  if (value.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        warningMessage(context,
                                            "Market Protection can not be empty"));
                                  }
                                  if (value.isNotEmpty) {
                                    String newValue =
                                        value.replaceAll(RegExp(r'[^0-9]'), '');
                                    if (newValue != value) {
                                      mktProtCtrl.text = newValue;
                                      mktProtCtrl.selection =
                                          TextSelection.fromPosition(TextPosition(
                                              offset: newValue.length));
                                    }
                                    if (int.parse(value) > 20) {
                                      mktProtCtrl.text = "20";
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          warningMessage(context,
                                              "can't enter greater than 20% of Market Protection"));
                                    } else if (int.parse(value) < 1) {
                                      mktProtCtrl.text = "1";
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          warningMessage(context,
                                              "can't enter less than 1% of Market Protection"));
                                    }
                                  }
                                });
                              },
                              keyboardType: TextInputType.number,
                              style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                  ),
                              textCtrl: mktProtCtrl,
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: theme.isDarkMode
                                        ? const Color(0xff555555)
                                        : colors.colorWhite),
                                child: SvgPicture.asset(
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorGrey,
                                    assets.precentIcon,
                                    fit: BoxFit.scaleDown),
                              ),
                              textAlign: TextAlign.start,
                              hintText: "Add Market Protection %",
                            ),
                          ),
                        ]),

                        actions: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 45), // width, height
                                side: BorderSide(
                                    color: colors
                                        .btnOutlinedBorder), // Outline border color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: colors
                                    .primaryDark, // Transparent background
                              ),
                              child: TextWidget.subText(
                                  text: "Ok",
                                  color: colors.colorWhite,
                                  theme: theme.isDarkMode,
                                  fw: 2),
                            ),
                          ),
                        ],

                        //                         actions: [
                        //   TextButton(
                        //     onPressed: () => Navigator.of(context).pop(),
                        //     child: const Text('Cancel'),
                        //   ),
                        //   TextButton(
                        //     onPressed: () {
                        //       Navigator.of(context).pop();
                        //     },
                        //     child: const Text('OK'),
                        //   ),
                        // ],
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    " $marketProtection %",
                    style: textStyle(
                      theme.isDarkMode
                          ? colors.colorLightBlue
                          : colors.colorBlue,
                      14,
                      FontWeight.w600,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
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

  void marginUpdate() {
    OrderMarginInput input = OrderMarginInput(
        exch: "${widget.scripInfo.exch}",
        prc: priceCtrl.text,
        prctyp: prcType,
        prd: widget.modifyOrderArgs.prd!,
        qty: widget.scripInfo.exch == 'MCX'
            ? (double.parse(qtyCtrl.text).toInt() * lotSize).toString()
            : qtyCtrl.text,
        rorgprc: '0',
        rorgqty: '0',
        trantype: widget.modifyOrderArgs.trantype!,
        tsym: "${widget.scripInfo.tsym}",
        blprc: '',
        bpprc: '',
        trgprc: prcType == "SL-LMT" || prcType == "SL-MKT"
            ? triggerPriceCtrl.text
            : "");
    ref.read(orderProvider).fetchOrderMargin(input, context);
    BrokerageInput brokerageInput = BrokerageInput(
        exch: "${widget.scripInfo.exch}",
        prc: priceCtrl.text,
        prd: widget.modifyOrderArgs.prd!,
        qty: widget.scripInfo.exch == 'MCX'
            ? (double.parse(qtyCtrl.text).toInt() * lotSize).toString()
            : qtyCtrl.text,
        trantype: widget.modifyOrderArgs.trantype!,
        tsym: "${widget.scripInfo.tsym}");
    ref.read(orderProvider).fetchGetBrokerage(brokerageInput, context);
  }

  modifyOrder() async {
    bool placeorder = true;
    if (prcType == "LMT" || prcType == "SL-LMT") {
      String r = roundOffWithInterval(double.parse(priceCtrl.text), tik)
          .toStringAsFixed(2);
      if (double.parse(priceCtrl.text) != double.parse(r)) {
        placeorder = false;
        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
            context, "Price should be multiple of tick size $tik => $r"));
      }
    }
    if (placeorder && (prcType == "SL-LMT" || prcType == "SL-MKT")) {
      String r = roundOffWithInterval(double.parse(triggerPriceCtrl.text), tik)
          .toStringAsFixed(2);
      if (double.parse(triggerPriceCtrl.text) != double.parse(r)) {
        placeorder = false;
        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
            context, "Trigger should be multiple of tick size $tik => $r"));
      }
    }
    int q = ((int.parse(qtyCtrl.text) / lotSize).round() * lotSize);
    if (int.parse(qtyCtrl.text) != q && widget.scripInfo.exch != 'MCX') {
      placeorder = false;
      ScaffoldMessenger.of(context).showSnackBar(warningMessage(
          context, "Quantity should be multiple of lot size $lotSize => $q"));
    }
    if (placeorder) {
      ref.read(orderProvider).setOrderloader(true);
      ModifyOrderInput input = ModifyOrderInput(
          dscqty: widget.modifyOrderArgs.dscqty ?? "0",
          token: widget.modifyOrderArgs.token!,
          exch: widget.modifyOrderArgs.exch!,
          mktProt: mktProtCtrl.text.isEmpty
              ? widget.modifyOrderArgs.mktProtection ?? ""
              : mktProtCtrl.text,
          orderNum: widget.modifyOrderArgs.norenordno!,
          prc: prcType == "LMT" || prcType == "SL-LMT" ? priceCtrl.text : "0",
          prd: widget.modifyOrderArgs.prd!,
          trantype: widget.modifyOrderArgs.trantype!,
          prctyp: prcType,
          blprc: stopLossCtrl.text,
          bpprc: targetCtrl.text,
          qty: int.parse(widget.modifyOrderArgs.qty ?? "0") == (int.parse(qtyCtrl.text) + int.parse((widget.modifyOrderArgs.fillshares ?? "0"))) ? widget.modifyOrderArgs.exch == 'MCX' ? (int.parse(widget.modifyOrderArgs.qty.toString()) * lotSize).toString() : (widget.modifyOrderArgs.qty.toString()) : widget.modifyOrderArgs.exch == 'MCX' ? ((int.parse(qtyCtrl.text) + int.parse((widget.modifyOrderArgs.fillshares ?? "0"))) * lotSize).toString() : (int.parse(qtyCtrl.text) + int.parse(widget.modifyOrderArgs.fillshares ?? "0")).toString(),
          ret: validity,
          trgprc: triggerPriceCtrl.text,
          tsym: widget.modifyOrderArgs.tsym!);
      await ref.read(orderProvider).fetchModifyOrder(input, context);
      ref.read(orderProvider).setOrderloader(false);
    }
  }

  void updatePriceType() {
    if (_isStoplossOrder && _isMarketOrder) {
      prcType = "SL-MKT";
    } else if (_isStoplossOrder && !_isMarketOrder) {
      prcType = "SL-LMT";
    } else if (_isMarketOrder) {
      prcType = "MKT";
    } else {
      prcType = "LMT";
    }

    // Update price controller based on type
    if (prcType == "MKT" || prcType == "SL-MKT") {
      double ltp = (double.parse("${widget.orderArg.ltp}") *
              double.parse(mktProtCtrl.text.isEmpty ? "0" : mktProtCtrl.text)) /
          100;
      if (widget.modifyOrderArgs.trantype == "B") {
        price = (double.parse("${widget.orderArg.ltp ?? 0.00}") + ltp)
            .toStringAsFixed(2);
      } else {
        price = (double.parse("${widget.orderArg.ltp ?? 0.00}") - ltp)
            .toStringAsFixed(2);
      }
      priceCtrl.text = "Market";
    } else if (priceCtrl.text == "Market") {
      priceCtrl.text = (widget.modifyOrderArgs.prc?.isNotEmpty ?? false) &&
              double.tryParse(widget.modifyOrderArgs.prc!) != null &&
              double.tryParse(widget.modifyOrderArgs.prc!)! > 0
          ? "${widget.modifyOrderArgs.prc}"
          : "${widget.orderArg.ltp}";
      price = priceCtrl.text;
    }
  }
}
