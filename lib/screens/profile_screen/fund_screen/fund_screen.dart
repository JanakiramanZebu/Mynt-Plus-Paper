// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
// import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/custom_switch_btn.dart';
import '../../../../sharedWidget/fund_function.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/loader_ui.dart';
import '../../../utils/no_emoji_inputformatter.dart';
import 'ios_fund_screen/ios_no_upi_apps_ui.dart';
import 'ios_fund_screen/ios_upi_apps_bottomsheet.dart';
import 'razorpay/razorpay_failed_ui.dart';
import 'razorpay/razorpay_success_ui.dart';
import 'upi_id_screens/upi_id_cancel_alert.dart';
import 'withdraw/withdraw_screen.dart';

class FundScreen extends ConsumerStatefulWidget {
  final TranctionProvider dd;
  const FundScreen({super.key, required this.dd});

  @override
  ConsumerState<FundScreen> createState() => _FundScreenState();
}

class _FundScreenState extends ConsumerState<FundScreen> {
  @override
  void initState() {
    ref.read(transcationProvider).initialdata(context);
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      checkIosAvailableApps();
    }
  }

  bool _isDisposedIos = false;

  @override
  void dispose() {
    _isDisposedIos = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        final fund = ref.watch(transcationProvider);
        return TransparentLoaderScreen(
          isLoading: fund.loading,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              leadingWidth: 46,
              titleSpacing: 6,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    assets.backArrow,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                    width: 20,
                  ),
                ),
              ),
              elevation: .2,
              title: TextWidget.titleText(
                text: 'Funds',
                theme: theme.isDarkMode,
                fw: 1,
              ),
            ),
            body:
                // fund.loading
                //     ? SizedBox(child: CircularLoaderImage())
                //     // Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                //     //     const ProgressiveDotsLoader(),
                //     //     const SizedBox(height: 3),
                //     //     Text('This will take a few seconds.',
                //     //         style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
                //     //   ])
                //     :
                GestureDetector(
              onTap: () {
                fund.focusNode.unfocus();
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 16, top: 10),
                        child: TextWidget.subText(
                            text: "Choose type",
                            theme: !theme.isDarkMode,
                            fw: 1)),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 10),
                      child: Row(
                        children: [
                          TextWidget.subText(
                            text: 'Deposit Money',
                            theme: false,
                            color: fund.enable
                                ? theme.isDarkMode
                                    ? colors.colorWhite
                                    : const Color(0xff000000)
                                : Colors.grey,
                            fw: 1,
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          CustomSwitch(
                            value: fund.enable,
                            onChanged: (bool val) async {
                              fund.withdrawamount.clear();
                              setState(() {
                                fund.changebool(val);
                              });
                            },
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          TextWidget.subText(
                            text: 'Withdraw Money',
                            theme: false,
                            color: fund.enable == false
                                ? theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack
                                : colors.colorGrey,
                            fw: 1,
                          ),
                        ],
                      ),
                    ),
                    fund.enable == true
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                child: TextFormField(
                                  focusNode: fund.focusNode,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.number,
                                  style: TextWidget.textStyle(
                                      theme: theme.isDarkMode,
                                      fontSize: 35,
                                      fw: 1),
                                  controller: fund.amount,
                                  onChanged: (value) {
                                    fund.textFiledonChange(value);
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    disabledBorder: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    hintText: "0",
                                    hintStyle: TextWidget.textStyle(
                                        theme: false,
                                        color: colors.colorGrey,
                                        fontSize: 40,
                                        fw: 1),
                                    labelStyle: TextWidget.textStyle(
                                        theme: theme.isDarkMode,
                                        fontSize: 40,
                                        fw: 1),
                                    prefixIcon: Container(
                                        margin: const EdgeInsets.all(6),
                                        child: SvgPicture.asset(
                                          assets.ruppeIcon,
                                          fit: BoxFit.contain,
                                          color: theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorGrey,
                                          width: 10,
                                          height: 8,
                                        )),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                  ),
                                  child: fund.amount.text.isEmpty
                                      ? TextWidget.subText(
                                          text: "Enter the amount",
                                          theme: false,
                                          color: colors.colorGrey,
                                          fw: 0)
                                      : fund.amount.text.isEmpty ||
                                              fund.intValue < 50
                                          ? TextWidget.subText(
                                              text: fund.funderror,
                                              theme: false,
                                              color: colors.darkred,
                                              fw: 0)
                                          : fund.intValue > 5000000
                                              ? TextWidget.subText(
                                                  text: fund.maxfunderror,
                                                  theme: false,
                                                  color: colors.darkred,
                                                  fw: 0)
                                              : TextWidget.subText(
                                                  text:
                                                      "${fund.textResult}only",
                                                  theme: false,
                                                  color: colors.colorGrey,
                                                  fw: 0)),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                ),
                                child: headerTitleText(
                                  "Segment",
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheet(fund, theme);
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : const Color(0xffF1F3F8),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    width: MediaQuery.of(context).size.width,
                                    height: 44,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget.titleText(
                                            text: fund.textValue,
                                            theme: theme.isDarkMode,
                                            fw: 1),
                                        SvgPicture.asset(assets.downArrow)
                                      ],
                                    )),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                  ),
                                  child: TextWidget.subText(
                                      text: "Bank account",
                                      theme: false,
                                      fw: 0,
                                      color: colors.colorGrey)),
                              GestureDetector(
                                onTap: () {
                                  fund.focusNode.unfocus();
                                  showBottomSheetbank(fund, theme);
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : const Color(0xffF1F3F8),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    width: MediaQuery.of(context).size.width,
                                    height: 44,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: TextWidget.titleText(
                                              text: fund.initbank,
                                              theme: theme.isDarkMode,
                                              fw: 1,
                                              textOverflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                        SvgPicture.asset(assets.downArrow)
                                      ],
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: TextWidget.subText(
                                    text: "Payment method",
                                    theme: false,
                                    color: colors.colorGrey,
                                    fw: 0),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                padding: const EdgeInsets.all(0),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: fund.defaultUpiapps.length,
                                itemBuilder: (context, index) {
                                  bool shouldDisable = fund.intValue > 100000;

                                  bool isDisabled = shouldDisable &&
                                      (index == 0 || index == 1);
                                  return InkWell(
                                    onTap: isDisabled
                                        ? null
                                        : () {
                                            setState(() {
                                              fund.changeIndex(index);

                                              fund.focusNode.unfocus();
                                            });
                                          },
                                    child: Container(
                                        margin: const EdgeInsets.all(10),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: theme.isDarkMode
                                                  ? fund.selectedindex == index
                                                      ? colors.colorWhite
                                                      : colors.darkGrey
                                                  : fund.selectedindex == index
                                                      ? colors.colorBlack
                                                      : colors.darkGrey,
                                            )),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  '${fund.defaultUpiapps[index]['image']}',
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              TextWidget.titleText(
                                                                  text:
                                                                      '${fund.defaultUpiapps[index]['name']}',
                                                                  theme: theme
                                                                      .isDarkMode,
                                                                  fw: 1),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xffe3f2fd),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 1,
                                                                    horizontal:
                                                                        5),
                                                                margin: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4),
                                                                child: TextWidget.paraText(
                                                                    text:
                                                                        "free",
                                                                    theme:
                                                                        false,
                                                                    color: const Color(
                                                                        0xff0037B7),
                                                                    fw: 0),
                                                              ),
                                                            ],
                                                          ),
                                                          fund.selectedindex ==
                                                                          0 &&
                                                                      fund.defaultUpiapps[index]
                                                                              [
                                                                              'name'] ==
                                                                          'UPI APPS' ||
                                                                  fund.selectedindex ==
                                                                          1 &&
                                                                      fund.defaultUpiapps[index]
                                                                              [
                                                                              'name'] ==
                                                                          'UPI ID' ||
                                                                  fund.selectedindex ==
                                                                          2 &&
                                                                      fund.defaultUpiapps[index]
                                                                              [
                                                                              'name'] ==
                                                                          'NET BANKING'
                                                              ? Row(
                                                                  children: [
                                                                    TextWidget.titleText(
                                                                        text:
                                                                            '₹',
                                                                        theme: theme
                                                                            .isDarkMode,
                                                                        fw: 1),
                                                                    TextWidget.titleText(
                                                                        text: fund.amount.text.isEmpty
                                                                            ? "0.00"
                                                                            : fund
                                                                                .amount.text,
                                                                        theme: theme
                                                                            .isDarkMode,
                                                                        fw: 1),
                                                                  ],
                                                                )
                                                              : Container()
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              TextWidget
                                                                  .paraText(
                                                                text:
                                                                    'Max Limit:',
                                                                theme: false,
                                                                color: colors
                                                                    .colorGrey,
                                                                fw: 0,
                                                              ),
                                                              TextWidget
                                                                  .paraText(
                                                                text:
                                                                    '₹${fund.defaultUpiapps[index]['limit']}',
                                                                theme: theme
                                                                    .isDarkMode,
                                                                fw: 0,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: fund.selectedindex == 1 &&
                                                      fund.defaultUpiapps[index]
                                                              ['name'] ==
                                                          'UPI ID'
                                                  ? 10
                                                  : 0,
                                            ),
                                            if (index == 0 &&
                                                fund.selectedindex == 0) ...[
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                      height: fund.selectedindex ==
                                                                  1 &&
                                                              fund.defaultUpiapps[
                                                                          index]
                                                                      [
                                                                      'name'] ==
                                                                  'NET BANKING'
                                                          ? 10
                                                          : 0),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              elevation: 0,
                                                              backgroundColor: fund
                                                                          .amount
                                                                          .text
                                                                          .isEmpty ||
                                                                      fund.intValue <
                                                                          50
                                                                  ? colors
                                                                      .darkGrey
                                                                  : theme
                                                                          .isDarkMode
                                                                      ? colors
                                                                          .colorbluegrey
                                                                      : colors
                                                                          .colorBlack,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          13),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                              )),
                                                      onPressed: fund
                                                                  .amount
                                                                  .text
                                                                  .isEmpty ||
                                                              fund.intValue < 50
                                                          ? () {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      warningMessage(
                                                                          context,
                                                                          "Min amount ₹50"));
                                                            }
                                                          : defaultTargetPlatform ==
                                                                  TargetPlatform
                                                                      .android
                                                              ? () async {
                                                                  await fund
                                                                      .fetchValidateToken(
                                                                          context);
                                                                  fund.focusNode
                                                                      .unfocus();
                                                                  await fund
                                                                      .fetchUPIPaymet(
                                                                    context,
                                                                    "${fund.amount.text}.00",
                                                                    fund.multipleAccno,
                                                                    fund
                                                                        .decryptclientcheck!
                                                                        .clientCheck!
                                                                        .dATA![fund.indexss][0],
                                                                    fund
                                                                        .decryptclientcheck!
                                                                        .clientCheck!
                                                                        .dATA![fund.indexss][2],
                                                                  );

                                                                  await fund
                                                                      .fetchUpiPaymentstatus(
                                                                    context,
                                                                    "${fund.hdfcdirectpayment?.data?.orderNumber}",
                                                                    "${fund.hdfcdirectpayment?.data?.upiTransactionNo}",
                                                                  );
                                                                }
                                                              : () async {
                                                                  if (availableApps
                                                                      .isEmpty) {
                                                                    showModalBottomSheet(
                                                                        enableDrag:
                                                                            false,
                                                                        useSafeArea:
                                                                            true,
                                                                        isScrollControlled:
                                                                            true,
                                                                        shape: const RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.vertical(
                                                                                top: Radius.circular(
                                                                                    16))),
                                                                        backgroundColor:
                                                                            const Color(
                                                                                0xffffffff),
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return IosNOUpiAppsSheet(
                                                                              theme: theme);
                                                                        });
                                                                  } else {
                                                                    fund.focusNode
                                                                        .unfocus();

                                                                    await fund
                                                                        .fetchUPIPaymet(
                                                                      context,
                                                                      "${fund.amount.text}.00",
                                                                      fund.multipleAccno,
                                                                      fund
                                                                          .decryptclientcheck!
                                                                          .clientCheck!
                                                                          .dATA![fund.indexss][0],
                                                                      fund
                                                                          .decryptclientcheck!
                                                                          .clientCheck!
                                                                          .dATA![fund.indexss][2],
                                                                    );

                                                                    await fund
                                                                        .fetchUpiPaymentstatus(
                                                                      context,
                                                                      "${fund.hdfcdirectpayment?.data?.orderNumber}",
                                                                      "${fund.hdfcdirectpayment?.data?.upiTransactionNo}",
                                                                    );
                                                                    showModalBottomSheet(
                                                                        enableDrag:
                                                                            false,
                                                                        useSafeArea:
                                                                            true,
                                                                        isScrollControlled:
                                                                            true,
                                                                        shape: const RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.vertical(
                                                                                top: Radius.circular(
                                                                                    16))),
                                                                        backgroundColor:
                                                                            const Color(
                                                                                0xffffffff),
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return UpiAppsBottomSheet(
                                                                              upiapps: availableApps,
                                                                              theme: theme);
                                                                        });
                                                                  }
                                                                },
                                                      child: fund.fundisLoad
                                                          ? const SizedBox(
                                                              width: 18,
                                                              height: 20,
                                                              child: CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Color(
                                                                      0xff666666)),
                                                            )
                                                          : TextWidget.subText(
                                                              text:
                                                                  "PAY VIA UPI APPS",
                                                              theme: false,
                                                              color: fund
                                                                          .amount
                                                                          .text
                                                                          .isEmpty ||
                                                                      fund.intValue <
                                                                          50
                                                                  ? colors
                                                                      .colorGrey
                                                                  : theme
                                                                          .isDarkMode
                                                                      ? colors
                                                                          .colorBlack
                                                                      : colors
                                                                          .colorWhite,
                                                              fw: 0,
                                                            ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                            if (index == 1 &&
                                                fund.selectedindex == 1) ...[
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextFormField(
                                                    controller: fund.upiid,
                                                    style: theme.isDarkMode
                                                        ? TextWidget.textStyle(
                                                            fontSize: 14,
                                                            theme: false,
                                                            color: colors
                                                                .colorWhite)
                                                        : TextWidget.textStyle(
                                                            fontSize: 14,
                                                            theme: false,
                                                            color: colors
                                                                .colorBlack),
                                                    inputFormatters: [
                                                      NoEmojiInputFormatter(),
                                                      FilteringTextInputFormatter
                                                          .deny(RegExp(
                                                              '[π£•₹€℅™∆√¶/,.]')),
                                                      FilteringTextInputFormatter
                                                          .deny(RegExp(r'\s')),
                                                    ],
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "example: username@upi",
                                                      hintStyle:
                                                          TextWidget.textStyle(
                                                              fontSize: 14,
                                                              theme: false,
                                                              color: colors
                                                                  .colorGrey),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 8,
                                                              horizontal: 10),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                      border:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                      fillColor:
                                                          theme.isDarkMode
                                                              ? colors.darkGrey
                                                              : const Color(
                                                                  0xffF1F3F8),
                                                      filled: true,
                                                    ),
                                                    onChanged: (value) {
                                                      fund.upiidOnchange(value);
                                                      fund.validateUPI(value);
                                                    },
                                                  ),
                                                  fund.upiiderror == null
                                                      ? Container()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: TextWidget.paraText(
                                                              text:
                                                                  "${fund.upiiderror}",
                                                              theme: false,
                                                              color: colors
                                                                  .darkred,
                                                              fw: 0,
                                                              align: TextAlign
                                                                  .left),
                                                        ),
                                                  SizedBox(
                                                      height: fund.selectedindex ==
                                                                  1 &&
                                                              fund.defaultUpiapps[
                                                                          index]
                                                                      [
                                                                      'name'] ==
                                                                  'UPI ID'
                                                          ? 10
                                                          : 0),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                elevation: 0,
                                                                backgroundColor: fund.upiiderror == 'Please enter a UPI ID' ||
                                                                        fund.upiiderror ==
                                                                            'Please enter a valid UPI ID' ||
                                                                        fund
                                                                            .upiid
                                                                            .text
                                                                            .isEmpty ||
                                                                        fund
                                                                            .amount
                                                                            .text
                                                                            .isEmpty ||
                                                                        fund.intValue <
                                                                            50
                                                                    ? colors
                                                                        .darkGrey
                                                                    : theme
                                                                            .isDarkMode
                                                                        ? colors
                                                                            .colorbluegrey
                                                                        : colors
                                                                            .colorBlack,
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            13),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                )),
                                                        onPressed:
                                                            fund.upiiderror == 'Please enter a UPI ID' ||
                                                                    fund.upiiderror ==
                                                                        'Please enter a valid UPI ID' ||
                                                                    fund
                                                                        .upiid
                                                                        .text
                                                                        .isEmpty ||
                                                                    fund
                                                                        .amount
                                                                        .text
                                                                        .isEmpty ||
                                                                    fund.intValue <
                                                                        50
                                                                ? () {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(warningMessage(
                                                                            context,
                                                                            "Min amount ₹50"));
                                                                  }
                                                                : () async {
                                                                    await fund.fetcUPIIDPayment(
                                                                        context,
                                                                        fund.upiid
                                                                            .text,
                                                                        fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss]
                                                                            [0],
                                                                        fund.bankdetails!.dATA![fund.indexss]
                                                                            [
                                                                            2]);
                                                                    await fund
                                                                        .fetchHdfctranction(
                                                                      context,
                                                                      fund.upiid
                                                                          .text,
                                                                      int.parse(fund
                                                                          .amount
                                                                          .text),
                                                                      fund.accno,
                                                                      fund
                                                                          .decryptclientcheck!
                                                                          .clientCheck!
                                                                          .dATA![fund.indexss][0],
                                                                    );
                                                                    if (fund.hdfcpaymentdata!.data!.verifiedVPAStatus1 ==
                                                                            "Available" ||
                                                                        fund.hdfcpaymentdata!.data!.verifiedVPAStatus2 ==
                                                                            "Available") {
                                                                      showModalBottomSheet(
                                                                          shape: const RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.vertical(
                                                                                  top: Radius.circular(
                                                                                      16))),
                                                                          backgroundColor: const Color(
                                                                              0xffffffff),
                                                                          isDismissible:
                                                                              false,
                                                                          enableDrag:
                                                                              false,
                                                                          showDragHandle:
                                                                              false,
                                                                          useSafeArea:
                                                                              false,
                                                                          isScrollControlled:
                                                                              true,
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return PopScope(
                                                                                canPop: true, // Allows default back navigation
                                                                                onPopInvokedWithResult: (didPop, result) {
                                                                                  if (didPop) return; // If system handled back, do nothing
                                                                                },
                                                                                child: const UPIIDPaymentCancelAlert());
                                                                          });

                                                                      await fund.fetchHdfcpaymetstatus(
                                                                          context,
                                                                          '${fund.hdfctranction!.data!.orderNumber}',
                                                                          '${fund.hdfctranction!.data!.upiTransactionNo}');
                                                                    }
                                                                  },
                                                        child: fund.fundisLoad
                                                            ? const SizedBox(
                                                                width: 18,
                                                                height: 20,
                                                                child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    color: Color(
                                                                        0xff666666)),
                                                              )
                                                            : TextWidget
                                                                .subText(
                                                                text:
                                                                    "PAY VIA UPI ID",
                                                                theme: false,
                                                                color: fund.upiiderror == 'Please enter a UPI ID' ||
                                                                        fund.upiiderror ==
                                                                            'Please enter a valid UPI ID' ||
                                                                        fund
                                                                            .upiid
                                                                            .text
                                                                            .isEmpty ||
                                                                        fund
                                                                            .amount
                                                                            .text
                                                                            .isEmpty ||
                                                                        fund.intValue <
                                                                            50
                                                                    ? colors
                                                                        .colorGrey
                                                                    : theme
                                                                            .isDarkMode
                                                                        ? colors
                                                                            .colorBlack
                                                                        : colors
                                                                            .colorWhite,
                                                                fw: 0,
                                                              )),
                                                  )
                                                ],
                                              ),
                                            ],
                                            if (index == 2 &&
                                                fund.selectedindex == 2) ...[
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                      height: fund.selectedindex ==
                                                                  1 &&
                                                              fund.defaultUpiapps[
                                                                          index]
                                                                      [
                                                                      'name'] ==
                                                                  'NET BANKING'
                                                          ? 10
                                                          : 0),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                elevation: 0,
                                                                backgroundColor: fund
                                                                            .amount
                                                                            .text
                                                                            .isEmpty ||
                                                                        fund.intValue <
                                                                            50 ||
                                                                        fund.intValue >
                                                                            5000000
                                                                    ? colors
                                                                        .darkGrey
                                                                    : theme
                                                                            .isDarkMode
                                                                        ? colors
                                                                            .colorbluegrey
                                                                        : colors
                                                                            .colorBlack,
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            13),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                )),
                                                        onPressed: fund
                                                                    .amount
                                                                    .text
                                                                    .isEmpty ||
                                                                fund.intValue <
                                                                    50 ||
                                                                fund.intValue >
                                                                    5000000
                                                            ? () {
                                                                if (fund.intValue >
                                                                    5000000) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(warningMessage(
                                                                          context,
                                                                          "Max amount ₹5,000,000"));
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(warningMessage(
                                                                          context,
                                                                          "Min amount ₹50"));
                                                                }
                                                              }
                                                            : () async {
                                                                Razorpay
                                                                    razorpay =
                                                                    Razorpay();
                                                                await fund
                                                                    .fetchrazorpay(
                                                                  context,
                                                                  int.parse(fund
                                                                          .amount
                                                                          .text)
                                                                      .toString(),
                                                                  fund.accno,
                                                                  fund
                                                                      .decryptclientcheck!
                                                                      .clientCheck!
                                                                      .dATA![fund.indexss][2],
                                                                  fund.ifsc,
                                                                  razorpay,
                                                                );
                                                                razorpay.on(
                                                                    Razorpay
                                                                        .EVENT_PAYMENT_ERROR,
                                                                    handlePaymentErrorResponse);
                                                                razorpay.on(
                                                                    Razorpay
                                                                        .EVENT_PAYMENT_SUCCESS,
                                                                    handlePaymentSuccessResponse);
                                                              },
                                                        child: fund.fundisLoad
                                                            ? const SizedBox(
                                                                width: 18,
                                                                height: 20,
                                                                child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    color: Color(
                                                                        0xff666666)),
                                                              )
                                                            : TextWidget.subText(
                                                                text:
                                                                    "PAY VIA NET BANKING",
                                                                theme: false,
                                                                color: fund
                                                                            .amount
                                                                            .text
                                                                            .isEmpty ||
                                                                        fund.intValue <
                                                                            50 ||
                                                                        fund.intValue >
                                                                            5000000
                                                                    ? colors
                                                                        .colorGrey
                                                                    : theme
                                                                            .isDarkMode
                                                                        ? colors
                                                                            .colorBlack
                                                                        : colors
                                                                            .colorWhite,
                                                                fw: 0,
                                                              )),
                                                  )
                                                ],
                                              ),
                                            ]
                                          ],
                                        )),
                                  );
                                },
                              ),
                            ],
                          )
                        : WithdrawScreen(
                            segment: fund.textValue,
                            withdarw: fund,
                            foucs: fund.focusNode,
                            theme: theme,
                          )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget headerTitleText(String text) {
    return TextWidget.subText(
        text: text, theme: false, color: colors.colorGrey, fw: 0);
  }

  Widget contantTitleText(String text) {
    return TextWidget.titleText(
      text: text,
      theme: false,
      fw: 1,
    );
  }

  final List<Map<String, dynamic>> upiApptest = [
    {
      'icon': assets.biggpay,
      'name': 'Google Pay',
      'url': 'gpay://',
      'value': '0'
    },
    {
      'icon': assets.bigphnpay,
      'name': 'PhonePe',
      'url': 'phonepe://',
      'value': '1'
    },
    {'icon': assets.bigpaytm, 'name': 'Paytm', 'url': 'paytm://', 'value': '2'},
  ];

  List<Map<String, dynamic>> availableApps = [];

  Future<void> checkIosAvailableApps() async {
    List<Map<String, dynamic>> tempList = [];

    for (var app in upiApptest) {
      bool isInstalled = await canLaunch(app['url']!);
      if (isInstalled) {
        tempList.add(app);
      }
    }
    if (!_isDisposedIos) {
      setState(() {
        availableApps = tempList;
      });
    }

    setState(() {
      availableApps = tempList;
    });
  }

  _showBottomSheet(TranctionProvider fund, ThemesProvider theme) {
    showModalBottomSheet(
      enableDrag: false,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      backgroundColor: const Color(0xffffffff),
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(2.0, 0.0))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomDragHandler(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextWidget.subText(
                  text: 'Choose an Segment:',
                  theme: false,
                  color: colors.colorGrey,
                  fw: 0,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: fund.decryptclientcheck!.companyCode!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      fund.segmentselection(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: fund.decryptclientcheck!.companyCode![index] ==
                              fund.textValue
                          ? const Color(0xff999999).withOpacity(0.2)
                          : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        child: Row(
                          children: [
                            TextWidget.titleText(
                              text:
                                  fund.decryptclientcheck!.companyCode![index],
                              theme: theme.isDarkMode,
                              fw: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }

  showBottomSheetbank(TranctionProvider fund, ThemesProvider theme) {
    showModalBottomSheet(
      enableDrag: false,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      backgroundColor: const Color(0xffffffff),
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(2.0, 0.0))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomDragHandler(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 10),
                child: TextWidget.subText(
                  text: 'Choose an bank:',
                  theme: false,
                  color: colors.colorGrey,
                  fw: 0,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: fund.bankdetails!.dATA!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      fund.bankselection(index);
                      fund.setAccountslist(
                          fund.bankdetails!.dATA![index][2].toString());

                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      color: fund.bankdetails!.dATA![index][1] == fund.bankname
                          ? const Color(0xff999999).withOpacity(0.2)
                          : Colors.transparent,
                      child: TextWidget.titleText(
                        text:
                            '${fund.bankdetails!.dATA![index][1]}-${hideAccountNumber(fund.bankdetails!.dATA![index][2])}',
                        theme: theme.isDarkMode,
                        fw: 1,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }

  handlePaymentErrorResponse(
    PaymentFailureResponse response,
  ) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        backgroundColor: const Color(0xffffffff),
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: false,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
              child: RazorpayFailedUi(
                  acco: widget.dd.accno,
                  ifsc: widget.dd.ifsc,
                  amount: ref.read(transcationProvider).amount.text,
                  bankname: widget.dd.bankname));
        });
  }

  handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    ref.read(transcationProvider).fetchrazorpayStatus("${response.paymentId}");

    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        backgroundColor: const Color(0xffffffff),
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: false,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
              child: RazorpaySuccessUi(
                amount: ref.read(transcationProvider).amount.text,
              ));
        });
  }
}
