import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/marketwatch_model/scrip_info.dart';
import '../../../models/order_book_model/gtt_order_book.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/order_book_model/place_gtt_order.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/network_state_provider.dart';
import '../../../provider/order_input_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/custom_switch_btn.dart';
import '../../../sharedWidget/no_internet_widget.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../gtt_condition.dart';
import '../invest_type_widget.dart';
import '../order_screen_header.dart';

class ModifyGTT extends ConsumerStatefulWidget {
  final GttOrderBookModel gttOrderBook;
  final ScripInfoModel scripInfo;
  const ModifyGTT(
      {super.key, required this.scripInfo, required this.gttOrderBook});

  @override
  ConsumerState<ModifyGTT> createState() => _ModifyGTTState();
}

class _ModifyGTTState extends ConsumerState<ModifyGTT> {
  bool? isBuy;

  bool isOco = false;

  bool isGtt = true;

  // List<String> validityTypes = ["DAY", "GTT"];

  String product = "I";

  int lotSize = 0;
  int multiplayer = 0;
  String price = "0.00";
  String validityType = "GTT";
  OrderScreenArgs? headerData;
  bool _GTTPriceTypeIsMarket = false;
  bool _GTTOCOPriceTypeIsMarket = false;


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordInputProvider).getModifyData(widget.gttOrderBook);
    });

    setState(() {
      headerData = OrderScreenArgs(
          exchange: "${widget.gttOrderBook.exch}",
          token: "${widget.gttOrderBook.token}",
          tSym: "${widget.gttOrderBook.tsym}",
          transType: false,
          perChange: "${widget.gttOrderBook.perChange}",
          lotSize: "${widget.gttOrderBook.ls}",
          ltp: "${widget.gttOrderBook.ltp}",
          isExit: false,
          orderTpye: '',
          isModify: false,
          holdQty: '',
          raw: {});

      isOco = widget.gttOrderBook.placeOrderParamsLeg2 != null;
      lotSize = int.parse("${widget.scripInfo.ls ?? 0}");
      isBuy = widget.gttOrderBook.trantype == "B";

      multiplayer = int.parse((widget.gttOrderBook.exch == "MCX"
              ? widget.scripInfo.prcqqty
              : widget.gttOrderBook.ls)
          .toString());

      product = "I";

      // ref.read(ordInputProvider).chngGTTPriceType(
      //     _GTTPriceTypeIsMarket ? "Market" : "Limit");

      // ref.read(networkStateProvider).networkStream();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return PopScope(
      canPop: true, // Allows back navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If system handled back, do nothing

        ref.read(ordInputProvider).clearTextField();
        await ref.read(marketWatchProvider)
            .requestMWScrip(context: context, isSubscribe: true);
      },
      child: Consumer(builder: (context, WidgetRef ref, _) {
        final orderInput = ref.watch(ordInputProvider);
        final internet = ref.watch(networkStateProvider);
        return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  leadingWidth: 41,
                  centerTitle: false,
                  titleSpacing: 6,
                  leading: InkWell(
                      onTap: () {
                        orderInput.clearTextField();
                        Navigator.pop(context);
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: SvgPicture.asset(
                            assets.backArrow,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                          ))),
                  elevation: .4,
                  title: Column(
                    children: [
                      Row(children: [
                        Text("${widget.scripInfo.symbol!} ",
                            style: textStyles.scripNameTxtStyle.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                        if (widget.scripInfo.option!.isNotEmpty)
                          Text(widget.scripInfo.option!,
                              style: textStyles.scripNameTxtStyle
                                  .copyWith(color: const Color(0xff666666)),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        if (widget.scripInfo.expDate!.isNotEmpty)
                          Text(" ${widget.scripInfo.expDate} ",
                              style: textStyles.scripExchTxtStyle.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack)),
                        Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: const Color(0xffF1F3F8)),
                            child: Text("${widget.scripInfo.exch}",
                                overflow: TextOverflow.ellipsis,
                                style: textStyle(const Color(0xff666666), 10,
                                    FontWeight.w500)))
                      ]),
                      const SizedBox(height: 4),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OrderScreenHeader(headerData: headerData!),
                            // Row(children: [
                            //   SvgPicture.asset(assets.buyIcon),
                            //   const SizedBox(width: 6),
                            //   CustomSwitch(
                            //       onChanged: (bool value) {
                            //         setState(() {
                            //           isBuy = value;
                            //         });
                            //       },
                            //       value: isBuy!),
                            //   const SizedBox(width: 6),
                            //   SvgPicture.asset(assets.sellIcon)
                            // ])
                          ])
                    ],
                  ),
                ),
                body: Stack(
                  children: [
                    SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        headerTitleText(
                                            isOco
                                                ? "Target Trigger Price"
                                                : "Trigger Price",
                                            theme),
                                      ]),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                          height: 44,
                                          child: CustomTextFormField(
                                              fillColor: theme.isDarkMode
                                                  ? colors.darkGrey
                                                  : const Color(0xffF1F3F8),
                                              onChanged: (value) {
                                                double inputPrice =
                                                    double.tryParse(value) ?? 0;

                                                if (value.isNotEmpty &&
                                                    inputPrice > 0) {
                                                  final regex = RegExp(
                                                      r'^(\d+)?(\.\d{0,2})?$');
                                                  if (!regex.hasMatch(value)) {
                                                    orderInput.val1Ctrl.text =
                                                        value.substring(0,
                                                            value.length - 1);
                                                    orderInput.val1Ctrl
                                                            .selection =
                                                        TextSelection.collapsed(
                                                            offset: orderInput
                                                                .val1Ctrl
                                                                .text
                                                                .length);
                                                  }
                                                }
                                                ScaffoldMessenger.of(context)
                                                    .removeCurrentSnackBar();
                                                if (value.isEmpty ||
                                                    inputPrice <= 0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          "Trigger Price can not be ${inputPrice <= 0 ? 'zero' : 'empty'}"));
                                                }
                                              },
                                              hintText:
                                                  "${widget.gttOrderBook.ltp}",
                                              hintStyle: textStyle(
                                                  const Color(0xff666666),
                                                  15,
                                                  FontWeight.w400),
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  16,
                                                  FontWeight.w600),
                                              textCtrl: orderInput.val1Ctrl,
                                              textAlign: TextAlign.start)),
                                    ]),
                              ),

                            const SizedBox(height: 16),
                            // GttCondition(
                            //     isOco: false, isGtt: isGtt, isModify: true),
                            // const SizedBox(height: 8),
                            // InvesTypeWidget(
                            //   scripInfo: widget.scripInfo,
                            //   ordType: "GTT",
                            // ),
                            // const SizedBox(height: 8),
                            // Padding(
                            //     padding: const EdgeInsets.only(left: 16),
                            //     child: headerTitleText("Price type", theme)),
                            // const SizedBox(height: 10),
                            // PriceTypeBtn(
                            //     isOco: false,
                            //     isGtt: isGtt,
                            //     ltp: "${widget.gttOrderBook.ltp}"),
                            // const SizedBox(height: 3),
                            // Divider(
                            //     color: theme.isDarkMode
                            //         ? colors.darkColorDivider
                            //         : colors.colorDivider),
                            const SizedBox(height: 16),
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
                                            headerTitleText("Qty", theme),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                                height: 44,
                                                child: CustomTextFormField(
                                                  fillColor: theme.isDarkMode
                                                      ? colors.darkGrey
                                                      : const Color(0xffF1F3F8),
                                                  hintText:
                                                      orderInput.qtyCtrl.text,
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
                                                  // prefixIcon: InkWell(
                                                  //   onTap: () {
                                                  //     setState(() {
                                                  //       if (orderInput.qtyCtrl
                                                  //           .text.isNotEmpty) {
                                                  //         if (int.parse(
                                                  //                 orderInput
                                                  //                     .qtyCtrl
                                                  //                     .text) >
                                                  //             multiplayer) {
                                                  //           orderInput.qtyCtrl
                                                  //               .text = (int.parse(orderInput
                                                  //                       .qtyCtrl
                                                  //                       .text) -
                                                  //                   multiplayer)
                                                  //               .toString();
                                                  //         }
                                                  //       } else {
                                                  //         orderInput.qtyCtrl
                                                  //                 .text =
                                                  //             "$multiplayer";
                                                  //       }
                                                  //     });
                                                  //   },
                                                  //   child: SvgPicture.asset(
                                                  //       theme.isDarkMode
                                                  //           ? assets.darkCMinus
                                                  //           : assets.minusIcon,
                                                  //       fit: BoxFit.scaleDown),
                                                  // ),
                                                  // suffixIcon: InkWell(
                                                  //   onTap: () {
                                                  //     setState(() {
                                                  //       int number = int.parse(
                                                  //           orderInput
                                                  //               .qtyCtrl.text);
                                                  //       if (orderInput.qtyCtrl
                                                  //           .text.isNotEmpty) {
                                                  //         if (number < 999999) {
                                                  //           orderInput.qtyCtrl
                                                  //               .text = (int.parse(orderInput
                                                  //                       .qtyCtrl
                                                  //                       .text) +
                                                  //                   multiplayer)
                                                  //               .toString();
                                                  //         }
                                                  //       } else {
                                                  //         orderInput.qtyCtrl
                                                  //                 .text =
                                                  //             "$multiplayer";
                                                  //       }
                                                  //     });
                                                  //   },
                                                  //   child: SvgPicture.asset(
                                                  //       theme.isDarkMode
                                                  //           ? assets.darkAdd
                                                  //           : assets.addIcon,
                                                  //       fit: BoxFit.scaleDown),
                                                  // ),
                                                  textCtrl: orderInput.qtyCtrl,
                                                  textAlign: TextAlign.start,
                                                  onChanged: (value) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .hideCurrentSnackBar();
                                                   if (value.isEmpty || value == "0") {
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
                                                      if (newValue != value) {
                                                        orderInput.qtyCtrl
                                                            .text = newValue;
                                                        orderInput.qtyCtrl
                                                                .selection =
                                                            TextSelection
                                                                .fromPosition(
                                                          TextPosition(
                                                              offset: newValue
                                                                  .length),
                                                        );
                                                      }
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
                                            Row(
                                                // mainAxisAlignment:
                                                //     MainAxisAlignment
                                                //         .spaceBetween,
                                                children: [
                                                  headerTitleText(
                                                      "Price", theme),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                      "${orderInput.actPrcType}",
                                                      style: textStyle(
                                                          const Color(
                                                              0xff777777),
                                                          14,
                                                          FontWeight.w600))
                                                ]),
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
                                                        "${widget.gttOrderBook.placeOrderParams!.prc}",
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
                                                    isReadable: orderInput.actPrcType ==
                                                                "Limit" || orderInput.actPrcType ==
                                                                "SL Limit" ? false : true,
                                                    // prefixIcon: Container(
                                                    //     margin:
                                                    //         const EdgeInsets.all(
                                                    //             12),
                                                    //     decoration: BoxDecoration(
                                                    //         borderRadius:
                                                    //             BorderRadius.circular(
                                                    //                 20),
                                                    //         color: theme.isDarkMode
                                                    //             ? const Color(0xff555555)
                                                    //             : colors.colorWhite),
                                                    //     child: SvgPicture.asset(color: theme.isDarkMode ? colors.colorWhite : colors.colorGrey, orderInput.actPrcType == "Limit" || orderInput.actPrcType == "SL Limit" ? assets.ruppeIcon : assets.lock, fit: BoxFit.scaleDown)),
                                                    
                                                     suffixIcon: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _GTTPriceTypeIsMarket =
                                                                !_GTTPriceTypeIsMarket;
                                                            orderInput.chngGTTPriceType(
                                                                _GTTPriceTypeIsMarket ? "Market" : "Limit");
                                                            if (orderInput.actPrcType == "Market" || orderInput.actPrcType =="SL MKT") {
                                                              orderInput.priceCtrl.text ="Market";
                                                            } else {
                                                              orderInput
                                                                      .priceCtrl
                                                                      .text =
                                                                  "${widget.gttOrderBook.ltp}";
                                                            }
                                                          });
                                                        },
                                                        child: SvgPicture.asset(
                                                            assets.switchIcon,
                                                            fit: BoxFit.scaleDown),
                                                      ),
                                                    textCtrl: orderInput.priceCtrl,
                                                    textAlign: TextAlign.start)),
                                          ]))
                                    ])),
                            const SizedBox(height: 16),
                            // Divider(
                            //     color: theme.isDarkMode
                            //         ? colors.darkColorDivider
                            //         : colors.colorDivider),
                            // if (orderInput.actPrcType == "SL Limit" ||
                            //     orderInput.actPrcType == "SL MKT")
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
                            //                       ScaffoldMessenger.of(context)
                            //                           .hideCurrentSnackBar();
                            //                       if (value.isNotEmpty) {
                            //                       } else {
                            //                         ScaffoldMessenger.of(
                            //                                 context)
                            //                             .showSnackBar(
                            //                                 warningMessage(
                            //                                     context,
                            //                                     "Trigger can not be empty"));
                            //                       }
                            //                     },
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
                            //                                 BorderRadius
                            //                                     .circular(20),
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
                            //                     textCtrl: orderInput.trgPrcCtrl,
                            //                     textAlign: TextAlign.start)),
                            //           ])),
                            // if (orderInput.actPrcType == "SL Limit" ||
                            //     orderInput.actPrcType == "SL MKT") ...[
                            //   const SizedBox(height: 3),
                            //   Divider(
                            //     color: theme.isDarkMode
                            //         ? colors.darkColorDivider
                            //         : colors.colorDivider,
                            //     thickness: .68,
                            //   ),
                            // ],
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Expanded(
                                      //     child: Column(
                                      //         crossAxisAlignment:
                                      //             CrossAxisAlignment.start,
                                      //         children: [
                                      //       headerTitleText("Validity", theme),
                                      //       const SizedBox(height: 7),
                                      //       SizedBox(
                                      //         height: 38,
                                      //         child: ListView.separated(
                                      //             scrollDirection:
                                      //                 Axis.horizontal,
                                      //             itemBuilder:
                                      //                 (context, index) {
                                      //               return ElevatedButton(
                                      //                 onPressed: () {
                                      //                   setState(() {
                                      //                     validityType =
                                      //                         validityTypes[
                                      //                             index];
                                      //                   });
                                      //                 },
                                      //                 style: ElevatedButton
                                      //                     .styleFrom(
                                      //                         elevation: 0,
                                      //                         padding:
                                      //                             const EdgeInsets
                                      //                                 .symmetric(
                                      //                                 horizontal:
                                      //                                     12,
                                      //                                 vertical:
                                      //                                     0),
                                      //                         backgroundColor: !theme
                                      //                                 .isDarkMode
                                      //                             ? validityType !=
                                      //                                     validityTypes[
                                      //                                         index]
                                      //                                 ? const Color(
                                      //                                     0xffF1F3F8)
                                      //                                 : colors
                                      //                                     .colorBlack
                                      //                             : validityType !=
                                      //                                     validityTypes[
                                      //                                         index]
                                      //                                 ? colors
                                      //                                     .darkGrey
                                      //                                 : colors
                                      //                                     .colorWhite,
                                      //                         shape:
                                      //                             const StadiumBorder()),
                                      //                 child: Text(
                                      //                   validityTypes[index],
                                      //                   style: textStyle(
                                      //                       !theme.isDarkMode
                                      //                           ? validityType !=
                                      //                                   validityTypes[
                                      //                                       index]
                                      //                               ? const Color(
                                      //                                   0xff666666)
                                      //                               : colors
                                      //                                   .colorWhite
                                      //                           : validityType !=
                                      //                                   validityTypes[
                                      //                                       index]
                                      //                               ? const Color(
                                      //                                   0xff666666)
                                      //                               : colors
                                      //                                   .colorBlack,
                                      //                       14,
                                      //                       validityType ==
                                      //                               validityTypes[
                                      //                                   index]
                                      //                           ? FontWeight
                                      //                               .w600
                                      //                           : FontWeight
                                      //                               .w500),
                                      //                 ),
                                      //               );
                                      //             },
                                      //             separatorBuilder:
                                      //                 (context, index) {
                                      //               return const SizedBox(
                                      //                   width: 8);
                                      //             },
                                      //             itemCount:
                                      //                 validityTypes.length),
                                      //       )
                                      //     ],
                                      //     ),
                                      //     ),
                                      if (isOco) ...[
                                        const SizedBox(width: 16),
                                        Row(children: [
                                          Text("OCO",
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  14,
                                                  FontWeight.w500)),
                                          IconButton(
                                              onPressed: () {
                                                // setState(() {
                                                //   isOco = !isOco;

                                                //   if (isOco) {
                                                //     orderInput.chngAlert("LTP");
                                                //     orderInput.chngCond("Less");
                                                //     orderInput.chngOCOPriceType(
                                                //         "Limit");
                                                //     orderInput
                                                //         .disableCondGTT(true);
                                                //   } else {
                                                //     orderInput
                                                //         .disableCondGTT(false);
                                                //   }
                                                // });

                                                // context
                                                //     .read(ordInputProvider)
                                                //     .chngInvesType(
                                                //         widget.scripInfo.seg ==
                                                //                 "EQT"
                                                //             ? InvestType.delivery
                                                //             : InvestType
                                                //                 .carryForward,
                                                //         "OCO");
                                              },
                                              icon: SvgPicture.asset(theme
                                                      .isDarkMode
                                                  ? isOco
                                                      ? assets
                                                          .darkCheckedboxIcon
                                                      : assets.darkCheckboxIcon
                                                  : isOco
                                                      ? assets.checkedbox
                                                      : assets.checkbox))
                                        ])
                                      ]
                                    ])),
                            if (isOco) ...[
                              // Divider(
                              //     color: theme.isDarkMode
                              //         ? colors.darkColorDivider
                              //         : colors.colorDivider,
                              //     thickness: .4),
                              // const SizedBox(height: 10),
                              // GttCondition(
                              //     isOco: isOco, isGtt: isGtt, isModify: true),
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
                              //     ltp: "${widget.gttOrderBook.ltp}"),
                              // const SizedBox(height: 3),
                              // Divider(
                              //     color: theme.isDarkMode
                              //         ? colors.darkColorDivider
                              //         : colors.colorDivider),
                              const SizedBox(height: 16),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          headerTitleText(
                                              isOco
                                                  ? "Stoploss Trigger Price"
                                                  : "Trigger Price",
                                              theme),
                                        ]),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                            height: 44,
                                            child: CustomTextFormField(
                                                fillColor: theme.isDarkMode
                                                    ? colors.darkGrey
                                                    : const Color(0xffF1F3F8),
                                                onChanged: (value) {
                                                  double inputPrice =
                                                      double.tryParse(value) ??
                                                          0;

                                                  if (value.isNotEmpty &&
                                                      inputPrice > 0) {
                                                    final regex = RegExp(
                                                        r'^(\d+)?(\.\d{0,2})?$');
                                                    if (!regex
                                                        .hasMatch(value)) {
                                                      orderInput.val2Ctrl.text =
                                                          value.substring(0,
                                                              value.length - 1);
                                                      orderInput.val2Ctrl
                                                              .selection =
                                                          TextSelection.collapsed(
                                                              offset: orderInput
                                                                  .val2Ctrl
                                                                  .text
                                                                  .length);
                                                    }
                                                  }
                                                  ScaffoldMessenger.of(context)
                                                      .removeCurrentSnackBar();
                                                  if (value.isEmpty ||
                                                      inputPrice <= 0) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                "Trigger Price can not be ${inputPrice <= 0 ? 'zero' : 'empty'}"));
                                                  }
                                                },
                                                hintText:
                                                    "${widget.gttOrderBook.ltp}",
                                                hintStyle: textStyle(
                                                    const Color(0xff666666),
                                                    15,
                                                    FontWeight.w400),
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    16,
                                                    FontWeight.w600),
                                                textCtrl: orderInput.val2Ctrl,
                                                textAlign: TextAlign.start)),
                                      ]),
                                ),



                              const SizedBox(height: 16),
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
                                                  "Qty", theme),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                  height: 44,
                                                  child: CustomTextFormField(
                                                    fillColor: theme.isDarkMode
                                                        ? colors.darkGrey
                                                        : const Color(
                                                            0xffF1F3F8),
                                                    hintText: orderInput
                                                        .ocoQtyCtrl.text,
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
                                                    // prefixIcon: InkWell(
                                                    //   onTap: () {
                                                    //     setState(() {
                                                    //       if (orderInput
                                                    //           .ocoQtyCtrl
                                                    //           .text
                                                    //           .isNotEmpty) {
                                                    //         if (int.parse(
                                                    //                 orderInput
                                                    //                     .ocoQtyCtrl
                                                    //                     .text) >
                                                    //             multiplayer) {
                                                    //           orderInput
                                                    //               .ocoQtyCtrl
                                                    //               .text = (int.parse(orderInput
                                                    //                       .ocoQtyCtrl
                                                    //                       .text) -
                                                    //                   multiplayer)
                                                    //               .toString();
                                                    //         }
                                                    //       } else {
                                                    //         orderInput
                                                    //                 .ocoQtyCtrl
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
                                                    //   onTap: () {
                                                    //     setState(() {
                                                    //       int number = int
                                                    //           .parse(orderInput
                                                    //               .ocoQtyCtrl
                                                    //               .text);

                                                    //       if (orderInput
                                                    //           .ocoQtyCtrl
                                                    //           .text
                                                    //           .isNotEmpty) {
                                                    //         if (number <
                                                    //             999999) {
                                                    //           orderInput
                                                    //               .ocoQtyCtrl
                                                    //               .text = (int.parse(orderInput
                                                    //                       .ocoQtyCtrl
                                                    //                       .text) +
                                                    //                   multiplayer)
                                                    //               .toString();
                                                    //         }
                                                    //       } else {
                                                    //         orderInput
                                                    //                 .ocoQtyCtrl
                                                    //                 .text =
                                                    //             "$multiplayer";
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
                                                    textCtrl:
                                                        orderInput.ocoQtyCtrl,
                                                    textAlign: TextAlign.start,
                                                    onChanged: (value) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .hideCurrentSnackBar();
                                                      if (value.isEmpty || value == "0") {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                warningMessage(
                                                                    context,
                                                                    "Quantity can not be ${value == "0" ? 'zero' : 'empty'}"));
                                                      } else {
                                                        String newValue =
                                                            value.replaceAll(
                                                                RegExp(
                                                                    r'[^0-9]'),
                                                                '');
                                                        if (newValue != value) {
                                                          orderInput.ocoQtyCtrl
                                                              .text = newValue;
                                                          orderInput.ocoQtyCtrl
                                                                  .selection =
                                                              TextSelection
                                                                  .fromPosition(
                                                            TextPosition(
                                                                offset: newValue
                                                                    .length),
                                                          );
                                                        }
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
                                              Row(
                                                  // mainAxisAlignment:
                                                  //     MainAxisAlignment
                                                  //         .spaceBetween,
                                                  children: [
                                                    headerTitleText(
                                                        "Price", theme),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                        "${orderInput.actOcoPrcType}",
                                                        style: textStyle(
                                                            const Color(
                                                                0xff777777),
                                                            14,
                                                            FontWeight.w600))
                                                  ]),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                  height: 44,
                                                  child: CustomTextFormField(
                                                      fillColor: theme.isDarkMode
                                                          ? colors.darkGrey
                                                          : const Color(
                                                              0xffF1F3F8),
                                                      onChanged: (value) {},
                                                      hintText:
                                                          "${widget.gttOrderBook.placeOrderParamsLeg2!.prc}",
                                                      hintStyle: textStyle(
                                                          const Color(
                                                              0xff666666),
                                                          15,
                                                          FontWeight.w400),
                                                      style: textStyle(
                                                          theme.isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          16,
                                                          FontWeight.w600),
                                                      isReadable: orderInput.actOcoPrcType ==
                                                                  "Limit" ||
                                                              orderInput.actOcoPrcType ==
                                                                  "SL Limit"
                                                          ? false
                                                          : true,
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
                                                              _GTTOCOPriceTypeIsMarket =
                                                                  !_GTTOCOPriceTypeIsMarket;
                                                              orderInput.chngOCOPriceType(
                                                                  _GTTOCOPriceTypeIsMarket
                                                                      ? "Market"
                                                                      : "Limit");
                                                              if (orderInput
                                                                          .actOcoPrcType ==
                                                                      "Market" ||
                                                                  orderInput
                                                                          .actOcoPrcType ==
                                                                      "SL MKT") {
                                                                orderInput
                                                                        .ocoPriceCtrl
                                                                        .text =
                                                                    "Market";
                                                              } else {
                                                                orderInput
                                                                        .ocoPriceCtrl
                                                                        .text =
                                                                    "${widget.gttOrderBook.ltp}";
                                                              }
                                                            });
                                                          },
                                                          child: SvgPicture.asset(
                                                              assets.switchIcon,
                                                              fit: BoxFit
                                                                  .scaleDown),
                                                        ),
                                                      
                                                      textCtrl: orderInput.ocoPriceCtrl,
                                                      textAlign: TextAlign.start)),
                                            ]))
                                      ])),
                              // const SizedBox(height: 3),
                              // Divider(
                              //     color: theme.isDarkMode
                              //         ? colors.darkColorDivider
                              //         : colors.colorDivider),
                              // if (orderInput.actOcoPrcType == "SL Limit" ||
                              //     orderInput.actOcoPrcType == "SL MKT")
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
                              //                                     "Trigger can not be empty"));
                              //                       }
                              //                     },
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
                              //                                 BorderRadius
                              //                                     .circular(20),
                              //                             color: theme.isDarkMode
                              //                                 ? const Color(
                              //                                     0xff555555)
                              //                                 : colors
                              //                                     .colorWhite),
                              //                         child: SvgPicture.asset(
                              //                             color: theme.isDarkMode
                              //                                 ? colors
                              //                                     .colorWhite
                              //                                 : colors
                              //                                     .colorGrey,
                              //                             assets.ruppeIcon,
                              //                             fit: BoxFit.scaleDown)),
                              //                     textCtrl: orderInput.ocoTrgPrcCtrl,
                              //                     textAlign: TextAlign.start)),
                              //           ])),
                              // if (orderInput.actOcoPrcType == "SL Limit" ||
                              //     orderInput.actOcoPrcType == "SL MKT") ...[
                              //   const SizedBox(height: 3),
                              //   Divider(
                              //     color: theme.isDarkMode
                              //         ? colors.darkColorDivider
                              //         : colors.colorDivider,
                              //     thickness: .68,
                              //   ),
                              // ],
                            ],
                            // if (!isOco) ...[
                            //   const SizedBox(height: 3),
                            //   Divider(
                            //       color: theme.isDarkMode
                            //           ? colors.darkColorDivider
                            //           : colors.colorDivider,
                            //       thickness: .4)
                            // ],
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.only(bottom: 8, left: 16),
                            //   child: headerTitleText("Remarks", theme),
                            // ),
                            // Container(
                            //     padding:
                            //         const EdgeInsets.symmetric(horizontal: 16),
                            //     height: 40,
                            //     child: CustomTextFormField(
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
                            //       textCtrl: orderInput.reMarksCtrl,
                            //     )),
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
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                      onPressed: internet.connectionStatus ==
                                              ConnectivityResult.none || ref.read(orderProvider).loading
                                          ? null
                                          : () async {
                                              if (orderInput.disableGTTCond) {
                                                if ((orderInput.val1Ctrl.text
                                                            .isNotEmpty &&
                                                        orderInput.val2Ctrl.text
                                                            .isNotEmpty &&
                                                        orderInput.priceCtrl
                                                            .text.isNotEmpty &&
                                                        orderInput.ocoPriceCtrl
                                                            .text.isNotEmpty &&
                                                        orderInput.ocoQtyCtrl
                                                            .text.isNotEmpty) &&
                                                    orderInput.qtyCtrl.text
                                                        .isNotEmpty) {
                                                  // if (orderInput
                                                  //             .actOcoPrcType ==
                                                  //         "SL Limit" ||
                                                  //     orderInput
                                                  //             .actOcoPrcType ==
                                                  //         "SL MKT") {
                                                  //   if (orderInput.ocoTrgPrcCtrl
                                                  //       .text.isEmpty) {
                                                  //     ScaffoldMessenger.of(
                                                  //             context)
                                                  //         .showSnackBar(
                                                  //             warningMessage(
                                                  //                 context,
                                                  //                 "Trigger can not be empty"));
                                                  //   } else {
                                                  //     prepareToModifyOCOOrder(
                                                  //         orderInput);
                                                  //   }
                                                  // } 
                                                  // else {

                                                          double ltp = double
                                                              .parse(widget
                                                                      .gttOrderBook
                                                                      .ltp ??
                                                                  "0.00");
                                                          double val1 =
                                                              double.parse(
                                                                  orderInput
                                                                      .val1Ctrl
                                                                      .text);
                                                          double val2 =
                                                              double.parse(
                                                                  orderInput
                                                                      .val2Ctrl
                                                                      .text);

                                                           if (val1 > ltp &&
                                                              val2 < ltp) {
                                                            prepareToModifyOCOOrder(orderInput);
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(warningMessage(
                                                                    context,
                                                                    val1 <= ltp
                                                                        ? "Target Trigger Price can not be Less than LTP"
                                                                        : val2 >= ltp
                                                                            ? "Stoploss Trigger Price can not be Greater than LTP"
                                                                            : "Trigger Price can not be equal to LTP"));
                                                          }
                                                  // }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          "Enter all Input fields"));
                                                }
                                              } else {
                                                if ((orderInput.val1Ctrl.text
                                                            .isNotEmpty &&
                                                        orderInput.priceCtrl
                                                            .text.isNotEmpty) &&
                                                    orderInput.qtyCtrl.text
                                                        .isNotEmpty) {
                                                  // if (orderInput.actPrcType ==
                                                  //         "SL Limit" ||
                                                  //     orderInput.actPrcType ==
                                                  //         "SL MKT") {
                                                  //   if (orderInput.trgPrcCtrl
                                                  //       .text.isEmpty) {
                                                  //     ScaffoldMessenger.of(
                                                  //             context)
                                                  //         .showSnackBar(
                                                  //             warningMessage(
                                                  //                 context,
                                                  //                 "Trigger can not be empty"));
                                                  //   } else {
                                                  //     prepareToModifyGttOrder(
                                                  //         orderInput);
                                                  //   }
                                                  // } 
                                                  // else {
                                                  double ltp = double.parse(widget.gttOrderBook.ltp ?? "0.00");
                                                          double val1 = double.parse(orderInput.val1Ctrl.text);
                                                          // double val2 = double.parse(orderInput.val2Ctrl.text);

                                                          if (val1 > ltp) {
                                                            // orderInput.chngCond("Greater than");
                                                            // orderInput.chngAlert("LTP");
                                                            prepareToModifyGttOrder(orderInput);

                                                          // } else if (val1 < ltp) {
                                                          //   // orderInput.chngCond("Less than");
                                                          //   // orderInput.chngAlert("LTP");
                                                          //   prepareToModifyGttOrder(orderInput);

                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    warningMessage(
                                                                        context,
                                                                        "Trigger Price can not be equal to LTP"));
                                                          }
                                                    // prepareToModifyGttOrder(orderInput);
                                                  // }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(warningMessage(
                                                          context,
                                                          "Enter all Input fields"));
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          backgroundColor: isBuy!
                                              ? colors.ltpgreen
                                              : colors.darkred,
                                          // shape: const StadiumBorder()
                                          ),
                                      child: ref.read(orderProvider).loading? 
                                        const SizedBox(
                                            width: 18,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xff666666)),
                                          )
                                        : 
                                      
                                      Text("Modify",
                                          style: textStyle(
                                              const Color(0xffffffff),
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

  prepareToModifyGttOrder(OrderInputProvider orderInput) async {
    PlaceGTTOrderInput input = PlaceGTTOrderInput(
        exch: '${widget.gttOrderBook.exch}',
        qty: orderInput.qtyCtrl.text,
        tsym: '${widget.gttOrderBook.tsym}',
        validity: "GTT",
        prc: orderInput.priceCtrl.text,
        prd: orderInput.orderType,
        trantype: isBuy! ? 'B' : "S",
        ret: 'DAY',
        ait: orderInput.ait,
        d: orderInput.val1Ctrl.text,
        prctyp: orderInput.prcType,
        remarks: orderInput.reMarksCtrl.text,
        trgprc: orderInput.actPrcType == "SL Limit" ||
                orderInput.actPrcType == "SL MKT"
            ? orderInput.trgPrcCtrl.text
            : "",
        alid: '${widget.gttOrderBook.alId}');
    await ref.read(orderProvider).modifyGTTOrder(input, context);
  }

  prepareToModifyOCOOrder(OrderInputProvider orderInput) async {
    PlaceOcoOrderInput input = PlaceOcoOrderInput(
        exch: '${widget.gttOrderBook.exch}',
        tsym: '${widget.gttOrderBook.tsym}',
        validity: "GTT",
        trantype: isBuy! ? 'B' : "S",
        ret: 'DAY',
        remarks: orderInput.reMarksCtrl.text,
        qty1: orderInput.qtyCtrl.text,
        trgprc1: orderInput.actOcoPrcType == "SL Limit" ||
                orderInput.actOcoPrcType == "SL MKT"
            ? orderInput.trgPrcCtrl.text
            : "",
        prc1: orderInput.priceCtrl.text,
        prd1: orderInput.orderType,
        d1: orderInput.val1Ctrl.text,
        prctyp1: orderInput.prcType,
        d2: orderInput.val2Ctrl.text,
        prctyp2: orderInput.ocoPrcType,
        prc2: orderInput.ocoPriceCtrl.text,
        prd2: orderInput.ocoOrderType,
        qty2: orderInput.ocoQtyCtrl.text,
        trgprc2: orderInput.actOcoPrcType == "SL Limit" ||
                orderInput.actOcoPrcType == "SL MKT"
            ? orderInput.ocoTrgPrcCtrl.text
            : "",
        alid: '${widget.gttOrderBook.alId}');
    await ref.read(orderProvider).modifyOCOOrder(input, context);
  }
}
