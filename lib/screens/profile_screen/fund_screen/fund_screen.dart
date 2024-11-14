// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/custom_switch_btn.dart';
import '../../../../sharedWidget/fund_function.dart';
import '../../../sharedWidget/payment_loader.dart';
import 'ios_fund_screen/ios_no_upi_apps_ui.dart';
import 'ios_fund_screen/ios_upi_apps_bottomsheet.dart';
import 'upi_apps_screens/no_upi_apps_alert.dart';
import 'razorpay/razorpay_failed_ui.dart';
import 'razorpay/razorpay_success_ui.dart';
import 'upi_apps_screens/cancel_request_alert_box.dart';
import 'upi_id_screens/upi_id_cancel_alert.dart';
import 'withdraw/withdraw_screen.dart';

class FundScreen extends StatefulWidget {
  final TranctionProvider dd;
  const FundScreen({super.key, required this.dd});

  @override
  _FundScreenState createState() => _FundScreenState();
}

class _FundScreenState extends State<FundScreen> {
  @override
  void initState() {
    context.read(transcationProvider).initialdata(context);
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      checkIosAvailableApps();
    } else {
      checkForUpiApps();
    }
  }

  bool _isDisposed = false;
  bool _isDisposedIos = false;
   Razorpay razorpay = Razorpay();

  @override
  void dispose() {
    razorpay .clear();
    _isDisposed = true;
    _isDisposedIos = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final theme = watch(themeProvider);
        final fund = watch(transcationProvider);
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            leadingWidth: 41,
            titleSpacing: 6,
            leading: const CustomBackBtn(),
            elevation: .4,
            title: Text('Funds',
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600)),
          ),
          body: fund.loading
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const ProgressiveDotsLoader(),
                  const SizedBox(height: 3),
                  Text('This will take a few seconds.',
                      style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
                ])
              : GestureDetector(
                  onTap: () {
                    fund.focusNode.unfocus();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        fund.enable == true
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                color: const Color(0xfffcefd4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Text(
                                  "Fund adding to ${fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][2]} ${fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0]}",
                                  style: textStyle(
                                      colors.colorBlack, 14, FontWeight.w500),
                                ))
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                color: const Color(0xfffcefd4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Text(
                                  "Fund withdraw to ${fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][2]} ${fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0]}",
                                  style: textStyle(
                                      colors.colorBlack, 14, FontWeight.w500),
                                )),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 10),
                          child: headerTitleText(
                            "Choose type",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 10),
                          child: Row(
                            children: [
                              Text(
                                'Deposit Money',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: fund.enable
                                        ? theme.isDarkMode
                                            ? colors.colorWhite
                                            : const Color(0xff000000)
                                        : Colors.grey),
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
                              Text(
                                'Withdraw Money',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: fund.enable == false
                                        ? theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack
                                        : colors.colorGrey),
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
                                      keyboardType: TextInputType.datetime,
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          35,
                                          FontWeight.w600),
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
                                        hintStyle: textStyle(colors.colorGrey,
                                            40, FontWeight.w600),
                                        labelStyle: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            40,
                                            FontWeight.w600),
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
                                          ? Text(
                                              "Enter the amount",
                                              style: textStyle(colors.colorGrey,
                                                  14, FontWeight.w500),
                                            )
                                          : fund.amount.text.isEmpty ||
                                                  fund.intValue < 50
                                              ? Text(
                                                  fund.funderror,
                                                  style: textStyle(
                                                      colors.darkred,
                                                      14,
                                                      FontWeight.w500),
                                                )
                                              : fund.intValue > 5000000
                                                  ? Text(
                                                      fund.maxfunderror,
                                                      style: textStyle(
                                                          colors.darkred,
                                                          14,
                                                          FontWeight.w500),
                                                    )
                                                  : Text(
                                                      "${fund.textResult}only",
                                                      style: textStyle(
                                                          colors.colorGrey,
                                                          14,
                                                          FontWeight.w500),
                                                    )),
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
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 44,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 16),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              fund.textValue,
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  15,
                                                  FontWeight.w600),
                                            ),
                                            SvgPicture.asset(assets.downArrow)
                                          ],
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                    ),
                                    child: headerTitleText(
                                      "Bank account",
                                    ),
                                  ),
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
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                              child: Text(
                                                fund.initbank,
                                                overflow: TextOverflow.ellipsis,
                                                style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  15,
                                                  FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SvgPicture.asset(assets.downArrow)
                                          ],
                                        )),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: headerTitleText(
                                        "Payment method",
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                    padding: const EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: fund.defaultUpiapps.length,
                                    itemBuilder: (context, index) {
                                      bool shouldDisable =
                                          fund.intValue > 100000;
    
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
                                                      ? fund.selectedindex ==
                                                              index
                                                          ? colors.colorWhite
                                                          : colors.darkGrey
                                                      : fund.selectedindex ==
                                                              index
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
                                                                  Text(
                                                                    '${fund.defaultUpiapps[index]['name']}',
                                                                    style: textStyle(
                                                                        theme.isDarkMode
                                                                            ? colors
                                                                                .colorWhite
                                                                            : colors
                                                                                .colorBlack,
                                                                        15,
                                                                        FontWeight
                                                                            .w600),
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        color: const Color(
                                                                            0xffe3f2fd),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            1,
                                                                        horizontal:
                                                                            5),
                                                                    margin: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            4),
                                                                    child: Text(
                                                                      "free",
                                                                      style: textStyle(
                                                                          const Color(
                                                                              0xff0037B7),
                                                                          12,
                                                                          FontWeight
                                                                              .w500),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              fund.selectedindex == 0 && fund.defaultUpiapps[index]['name'] == 'UPI APPS' ||
                                                                      fund.selectedindex ==
                                                                              1 &&
                                                                          fund.defaultUpiapps[index]['name'] ==
                                                                              'UPI ID' ||
                                                                      fund.selectedindex ==
                                                                              2 &&
                                                                          fund.defaultUpiapps[index]['name'] ==
                                                                              'NET BANKING'
                                                                  ? Row(
                                                                      children: [
                                                                        Text(
                                                                          '₹',
                                                                          style: textStyle(
                                                                              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                                              15,
                                                                              FontWeight.w600),
                                                                        ),
                                                                        Text(
                                                                          fund.amount.text.isEmpty
                                                                              ? "0.00"
                                                                              : fund.amount.text,
                                                                          style: textStyle(
                                                                              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                                              15,
                                                                              FontWeight.w600),
                                                                        ),
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
                                                                  Text(
                                                                    'Max Limit:',
                                                                    style: textStyle(
                                                                        colors
                                                                            .colorGrey,
                                                                        13,
                                                                        FontWeight
                                                                            .w500),
                                                                  ),
                                                                  Text(
                                                                    '₹${fund.defaultUpiapps[index]['limit']}',
                                                                    style: textStyle(
                                                                        theme.isDarkMode
                                                                            ? colors
                                                                                .colorWhite
                                                                            : colors
                                                                                .colorBlack,
                                                                        13,
                                                                        FontWeight
                                                                            .w500),
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
                                                  height: fund.selectedindex ==
                                                              1 &&
                                                          fund.defaultUpiapps[
                                                                      index]
                                                                  ['name'] ==
                                                              'UPI ID'
                                                      ? 10
                                                      : 0,
                                                ),
                                                if (index == 0 &&
                                                    fund.selectedindex ==
                                                        0) ...[
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
                                                        width: MediaQuery.of(
                                                                context)
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
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          13),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                  )),
                                                          onPressed: fund
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
                                                              : defaultTargetPlatform ==
                                                                      TargetPlatform
                                                                          .android
                                                                  ? () async {
                                                                      if (_isUpiAppAvailable ==
                                                                          false) {
                                                                        fund.focusNode
                                                                            .unfocus();
                                                                        showModalBottomSheet(
                                                                            shape:
                                                                                const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                                                            backgroundColor: const Color(0xffffffff),
                                                                            context: context,
                                                                            builder: (BuildContext context) {
                                                                              return const NoUPIAppsAlert();
                                                                            });
                                                                      } else if (_isUpiAppAvailable ==
                                                                          true) {
                                                                        await fund
                                                                            .fetchValidateToken(context);
                                                                        fund.focusNode
                                                                            .unfocus();
                                                                        await context
                                                                            .read(transcationProvider)
                                                                            .fetchUPIPaymet(
                                                                              context,
                                                                              "${fund.amount.text}.00",
                                                                              fund.accno,
                                                                              fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0],
                                                                              fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][2],
                                                                            );
    
                                                                        await context
                                                                            .read(transcationProvider)
                                                                            .fetchUpiPaymentstatus(
                                                                              context,
                                                                              "${fund.hdfcdirectpayment?.data?.orderNumber}",
                                                                              "${fund.hdfcdirectpayment?.data?.upiTransactionNo}",
                                                                            );
    
                                                                        showModalBottomSheet(
                                                                            shape:
                                                                                const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                                                            backgroundColor: const Color(0xffffffff),
                                                                            isDismissible: false,
                                                                            enableDrag: false,
                                                                            showDragHandle: false,
                                                                            useSafeArea: false,
                                                                            isScrollControlled: true,
                                                                            context: context,
                                                                            builder: (BuildContext context) {
                                                                              return WillPopScope(
                                                                                  onWillPop: () async {
                                                                                    return false;
                                                                                  },
                                                                                  child: const PaymentCancelAlert());
                                                                            });
                                                                      }
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
                                                                            shape:
                                                                                const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                                                            backgroundColor: const Color(0xffffffff),
                                                                            context: context,
                                                                            builder: (context) {
                                                                              return IosNOUpiAppsSheet(theme: theme);
                                                                            });
                                                                      } else {
                                                                        fund.focusNode
                                                                            .unfocus();
    
                                                                        await context
                                                                            .read(transcationProvider)
                                                                            .fetchUPIPaymet(
                                                                              context,
                                                                              "${fund.amount.text}.00",
                                                                              fund.accno,
                                                                              fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0],
                                                                              fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][2],
                                                                            );
    
                                                                        await context
                                                                            .read(transcationProvider)
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
                                                                            shape:
                                                                                const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                                                            backgroundColor: const Color(0xffffffff),
                                                                            context: context,
                                                                            builder: (context) {
                                                                              return UpiAppsBottomSheet(upiapps: availableApps, theme: theme);
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
                                                              : Text(
                                                                  "PAY VIA UPI APPS",
                                                                  style: textStyle(
                                                                      fund.amount.text.isEmpty || fund.intValue < 50
                                                                          ? colors.colorGrey
                                                                          : theme.isDarkMode
                                                                              ? colors.colorBlack
                                                                              : colors.colorWhite,
                                                                      14,
                                                                      FontWeight.w500)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                                if (index == 1 &&
                                                    fund.selectedindex ==
                                                        1) ...[
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextFormField(
                                                        controller: fund.upiid,
                                                        style: theme.isDarkMode
                                                            ? textStyles
                                                                .textFieldLabelStyle
                                                                .copyWith(
                                                                    color: colors
                                                                        .colorWhite)
                                                            : textStyles
                                                                .textFieldLabelStyle,
                                                        inputFormatters: [
                                                          RemoveEmojiInputFormatter(),
                                                          FilteringTextInputFormatter
                                                              .deny(RegExp(
                                                                  '[π£•₹€℅™∆√¶/,.]')),
                                                          FilteringTextInputFormatter
                                                              .deny(RegExp(
                                                                  r'\s')),
                                                        ],
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "example: username@upi",
                                                          hintStyle: textStyles
                                                              .textFieldLabelStyle
                                                              .copyWith(
                                                            color: colors
                                                                .colorGrey,
                                                          ),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      10),
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
                                                          border: OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                          fillColor: theme
                                                                  .isDarkMode
                                                              ? colors.darkGrey
                                                              : const Color(
                                                                  0xffF1F3F8),
                                                          filled: true,
                                                        ),
                                                        onChanged: (value) {
                                                          fund.upiidOnchange(
                                                              value);
                                                          fund.validateUPI(
                                                              value);
                                                        },
                                                      ),
                                                      fund.upiiderror == null
                                                          ? Container()
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 5),
                                                              child: Text(
                                                                "${fund.upiiderror}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: textStyle(
                                                                    colors
                                                                        .darkred,
                                                                    12,
                                                                    FontWeight
                                                                        .w500),
                                                              ),
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
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  elevation: 0,
                                                                  backgroundColor: fund
                                                                                  .upiiderror ==
                                                                              'Please enter a UPI ID' ||
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
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          13),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                  )),
                                                          onPressed: fund.upiiderror == 'Please enter a UPI ID' ||
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
                                                                  await context.read(transcationProvider).fetcUPIIDPayment(
                                                                      context,
                                                                      fund.upiid
                                                                          .text,
                                                                      fund.decryptclientcheck!.clientCheck!
                                                                              .dATA![fund.indexss]
                                                                          [0],
                                                                      fund.bankdetails!
                                                                              .dATA![
                                                                          fund.indexss][2]);
                                                                  await context
                                                                      .read(
                                                                          transcationProvider)
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
                                                                  if (fund.hdfcpaymentdata!.data!
                                                                              .verifiedVPAStatus1 ==
                                                                          "Available" ||
                                                                      fund.hdfcpaymentdata!.data!
                                                                              .verifiedVPAStatus2 ==
                                                                          "Available") {
                                                                    showModalBottomSheet(
                                                                        shape: const RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.vertical(
                                                                                top: Radius.circular(
                                                                                    16))),
                                                                        backgroundColor:
                                                                            const Color(
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
                                                                            (BuildContext
                                                                                context) {
                                                                          return WillPopScope(
                                                                              onWillPop: () async {
                                                                                return false;
                                                                              },
                                                                              child: const UPIIDPaymentCancelAlert());
                                                                        });
    
                                                                    context
                                                                        .read(
                                                                            transcationProvider)
                                                                        .fetchHdfcpaymetstatus(
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
                                                              : Text(
                                                                  "PAY VIA UPI ID",
                                                                  style: textStyle(
                                                                      fund.upiiderror == 'Please enter a UPI ID' || fund.upiiderror == 'Please enter a valid UPI ID' || fund.upiid.text.isEmpty || fund.amount.text.isEmpty || fund.intValue < 50
                                                                          ? colors.colorGrey
                                                                          : theme.isDarkMode
                                                                              ? colors.colorBlack
                                                                              : colors.colorWhite,
                                                                      14,
                                                                      FontWeight.w500)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                                if (index == 2 &&
                                                    fund.selectedindex ==
                                                        2) ...[
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
                                                        width: MediaQuery.of(
                                                                context)
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
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          13),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
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
                                                                  context.read(transcationProvider).fetchrazorpay(
                                                                      context,
                                                                      int.parse(fund
                                                                              .amount
                                                                              .text)
                                                                          .toString(),
                                                                      fund
                                                                          .accno,
                                                                      fund
                                                                          .decryptclientcheck!
                                                                          .clientCheck!
                                                                          .dATA![fund.indexss][2],
                                                                      fund.ifsc);
                                                                 
    
                                                                  Future.delayed(
                                                                      const Duration(
                                                                          seconds:
                                                                              2),
                                                                      () {
                                                                    var options =
                                                                        {
                                                                      'key':
                                                                          'rzp_live_M3tazzVCcFf8Iq',
                                                                      'amount': "${fund.razorpay!.amount}" ,
                                                                      'name':
                                                                          'Zebu Fund',
                                                                      'currency':
                                                                          'INR',
                                                                      'order_id': fund
                                                                          .razorpay!
                                                                          .id,
                                                                      'image':
                                                                          "https://zebuetrade.com/wp-content/uploads/2020/07/logo.png",
                                                                      'description':
                                                                          "Fund add to ${fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0]}",
                                                                      'retry': {
                                                                        'enabled':
                                                                            true,
                                                                        'max_count':
                                                                            1
                                                                      },
                                                                      'send_sms_hash':
                                                                          true,
                                                                      'prefill':
                                                                          {
                                                                        'name': fund
                                                                            .decryptclientcheck!
                                                                            .clientCheck!
                                                                            .dATA![fund.indexss][2],
                                                                        'email': fund
                                                                            .decryptclientcheck!
                                                                            .clientCheck!
                                                                            .dATA![fund.indexss][4],
                                                                        'contact': fund
                                                                            .decryptclientcheck!
                                                                            .clientCheck!
                                                                            .dATA![fund.indexss][5],
                                                                        'method':
                                                                            'netbanking',
                                                                        'bank':
                                                                            fund.bankname,
                                                                      },
                                                                      'notes': {
                                                                        'clientcode':
                                                                            "${fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0]}",
                                                                        'acc_no':
                                                                            fund.accno,
                                                                        'ifsc':
                                                                            fund.ifsc,
                                                                        'bankname':
                                                                            fund.bankname,
                                                                        'company_code':
                                                                            fund.textValue,
                                                                      },
                                                                      'theme': {
                                                                        'color':
                                                                            "#3399cc",
                                                                      }, "ondismiss":  true
                                                                    };
      
                                                                    razorpay.on(
                                                                        Razorpay
                                                                            .EVENT_PAYMENT_ERROR,
                                                                        handlePaymentErrorResponse);
                                                                    razorpay.on(
                                                                        Razorpay
                                                                            .EVENT_PAYMENT_SUCCESS,
                                                                        handlePaymentSuccessResponse);
       razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
                                                                    razorpay.open(
                                                                        options);
    
                                                                 });
    
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
                                                              : Text(
                                                                  "PAY VIA NET BANKING",
                                                                  style: textStyle(
                                                                      fund.amount.text.isEmpty || fund.intValue < 50 || fund.intValue > 5000000
                                                                          ? colors.colorGrey
                                                                          : theme.isDarkMode
                                                                              ? colors.colorBlack
                                                                              : colors.colorWhite,
                                                                      14,
                                                                      FontWeight.w500)),
                                                        ),
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
        );
      },
    );
  }

  Text headerTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorGrey, 14, FontWeight.w500),
    );
  }

  Text contantTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorBlack, 15, FontWeight.w600),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
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

  bool _isUpiAppAvailable = false;

  final List<String> _upiAppPackageNames = [
    'com.google.android.apps.nbu.paisa.user',
    'net.one97.paytm',
    'com.phonepe.app',
    'in.org.npci.upiapp',
    'in.amazon.mShop.android.shopping',
    'com.mobikwik_new',
    'com.myairtelapp',
    'com.freecharge.android',
  ];

  Future checkForUpiApps() async {
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps();

    bool isUpiAppFound = installedApps.any((app) {
      return _upiAppPackageNames.contains(app.packageName);
    });
    if (!_isDisposed) {
      setState(() {
        _isUpiAppAvailable = isUpiAppFound;
      });
    }
  }
   void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet callback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
    );
    Navigator.pop(context); // Close the screen
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              headerTitleText('Choose an Segment:'),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      child: Text(
                        fund.decryptclientcheck!.companyCode![index],
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            15,
                            FontWeight.w600),
                      ),
                    ),
                  );
                },
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              headerTitleText('Choose an bank:'),
              ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shrinkWrap: true,
                itemCount: fund.bankdetails!.dATA!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      fund.bankselection(index);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        '${fund.bankdetails!.dATA![index][1]}-${hideAccountNumber(fund.bankdetails!.dATA![index][2])}',
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            15,
                            FontWeight.w600),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 5,
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
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: RazorpayFailedUi(
                  acco: widget.dd.accno,
                  ifsc: widget.dd.ifsc,
                  amount: context.read(transcationProvider).amount.text,
                  bankname: widget.dd.bankname));
        });
  }

  handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    context
        .read(transcationProvider)
        .fetchrazorpayStatus("${response.paymentId}");

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
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: RazorpaySuccessUi(
                amount: context.read(transcationProvider).amount.text,
              ));
        });
  }
}
