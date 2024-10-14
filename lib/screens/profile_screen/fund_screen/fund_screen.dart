// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_switch_btn.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/fund_function.dart';
import 'cancel_request_alert_box.dart';
import 'no_upi_apps_alert.dart';
import 'upi_id_cancel_alert.dart';
import 'withdraw_screen.dart';

class FundScreen extends StatefulWidget {
  final TranctionProvider dd;
  const FundScreen({
    super.key,
    required this.dd,
  });

  @override
  State<FundScreen> createState() => _FundScreenState();
}

class _FundScreenState extends State<FundScreen> {
  int intValue = 0;
  int _selectedIndex = -1;
  String initbank = '';
  String amountValue = '0';
  int indexss = 0;
  String textValue = '';
  String accno = '';
  bool _enable = true;
  bool segmentslection = true;
  String ifsc = '';
  String bankname = '';
  String _textResult = "";
  String funderror = '';

  convertToText(String value) {
    setState(() {
      int number = int.tryParse(value) ?? 0;
      String result = NumberToWord().convert('en-in', number);
      _textResult = capitalizeFirstLetter(result);
    });
  }

  @override
  void initState() {
    checkForUpiApps();
    accno = widget.dd.bankdetails!.dATA![indexss][2];
    ifsc = widget.dd.bankdetails!.dATA![indexss][3];
    bankname = widget.dd.bankdetails!.dATA![indexss][1];
    initbank =
        '${widget.dd.bankdetails!.dATA![indexss][1]} - ${hideAccountNumber(accno)}';
    textValue = widget.dd.decryptclientcheck!.companyCode![0];
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer(
      builder: (
        context,
        watch,
        child,
      ) {
        final theme = watch(themeProvider);
        final fund = watch(transcationProvider);
        return Scaffold(
          backgroundColor: const Color(0xffffffff),
          appBar: AppBar(
            leadingWidth: 41,
            titleSpacing: 6,
            elevation: .3,
            backgroundColor: const Color(0xffffffff),
            title: Text(
              "Fund",
              style: textStyles.appBarTitleTxt,
            ),
            leading: InkWell(
                onTap: () {
                  fund.amount.clear();
                  Navigator.pop(context);
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: SvgPicture.asset(assets.backArrow))),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _enable == true
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          color: const Color(0xfffcefd4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Text(
                            "Fund adding to ${fund.decryptclientcheck!.clientCheck!.dATA![indexss][2]} ${fund.decryptclientcheck!.clientCheck!.dATA![indexss][0]}",
                            style: textStyle(
                                colors.colorBlack, 14, FontWeight.w500),
                          ))
                      : Container(),
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
                              color: _enable
                                  ? const Color(0xff000000)
                                  : Colors.grey),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        CustomSwitch(
                          value: _enable,
                          onChanged: (bool val) {
                            val == false
                                ? context
                                    .read(transcationProvider)
                                    .fetchcwithdraw(context)
                                : context
                                    .read(transcationProvider)
                                    .fetchc(context);
                            setState(() {
                              _enable = val;
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
                              color: _enable
                                  ? Colors.grey
                                  : const Color(0xff000000)),
                        ),
                      ],
                    ),
                  ),
                  _enable == true
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              child: TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.datetime,
                                style: textStyle(
                                    colors.colorBlack, 35, FontWeight.w600),
                                controller: fund.amount,
                                onChanged: (value) {
                                  // fund.validateamount();
                                  convertToText(value);

                                  setState(() {
                                    intValue = int.tryParse(value) ?? 0;
                                    if (intValue < 50) {
                                      funderror = 'Min amount ₹50';
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(30)),
                                  disabledBorder: InputBorder.none,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(30)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(30)),
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  hintText: "0",
                                  labelStyle: textStyle(const Color(0xff000000),
                                      40, FontWeight.w600),
                                  prefixIcon: Container(
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: const Color(0xffffffff)),
                                      child: SvgPicture.asset(
                                        assets.ruppeIcon,
                                        // fit: BoxFit.cover,
                                        color: colors.colorBlack,
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
                              child: headerTitleText(fund.amount.text.isEmpty
                                  ? "Enter the amount"
                                  : fund.amount.text.isEmpty || intValue < 50
                                      ? funderror
                                      : "${_textResult}only"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 20),
                              child: headerTitleText(
                                "Bank account",
                              ),
                            ),
                            InkWell(
                              splashFactory: NoSplash.splashFactory,
                              splashColor: Colors.transparent,
                              onTap: () {
                                showBottomSheetbank(fund);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xffF1F3F8),
                                      borderRadius: BorderRadius.circular(30)),
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
                                        child: Text(
                                          initbank,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyle(
                                            colors.colorBlack,
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
                            ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                      FocusScope.of(context).unfocus();
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _selectedIndex == index
                                            ? colors.colorBlack
                                            : colors.colorbluegrey,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (index == 0) ...[
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                assets.upiIcon,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'UPI Apps',
                                                              style: textStyle(
                                                                  colors
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
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          1,
                                                                      horizontal:
                                                                          5),
                                                              margin:
                                                                  const EdgeInsets
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
                                                        _selectedIndex == 0
                                                            ? Row(
                                                                children: [
                                                                  Text(
                                                                    '₹',
                                                                    style: textStyle(
                                                                        colors
                                                                            .colorBlack,
                                                                        15,
                                                                        FontWeight
                                                                            .w600),
                                                                  ),
                                                                  Text(
                                                                    fund.amount.text
                                                                            .isEmpty
                                                                        ? "0.00"
                                                                        : fund
                                                                            .amount
                                                                            .text,
                                                                    style: textStyle(
                                                                        colors
                                                                            .colorBlack,
                                                                        15,
                                                                        FontWeight
                                                                            .w600),
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
                                                              '₹1,00,000',
                                                              style: textStyle(
                                                                  colors
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
                                            height:
                                                _selectedIndex == 0 ? 10 : 0,
                                          ),
                                          if (_selectedIndex == 0)
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          elevation: 0,
                                                          backgroundColor: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .colorbluegrey
                                                              : colors
                                                                  .colorBlack,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 13),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          )),
                                                  onPressed:
                                                      fund.amount.text.isEmpty
                                                          //     ||
                                                          // intValue < 50
                                                          ? null
                                                          : () async {
                                                              if (_isUpiAppAvailable ==
                                                                  true) {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return const NoUPIAppsAlert();
                                                                    });
                                                              } else if (_isUpiAppAvailable ==
                                                                  false) {
                                                                await context
                                                                    .read(
                                                                        transcationProvider)
                                                                    .fetchUPIPaymet(
                                                                      context,
                                                                      "${fund.amount.text}.00",
                                                                      accno,
                                                                      fund
                                                                          .decryptclientcheck!
                                                                          .clientCheck!
                                                                          .dATA![indexss][0],
                                                                      fund
                                                                          .decryptclientcheck!
                                                                          .clientCheck!
                                                                          .dATA![indexss][2],
                                                                    );

                                                                // await context
                                                                //     .read(
                                                                //         transcationProvider)
                                                                //     .fetchUpiPaymentstatus(
                                                                //       context,
                                                                //       "${fund.hdfcdirectpayment?.data?.orderNumber}",
                                                                //       "${fund.hdfcdirectpayment?.data?.upiTransactionNo}",
                                                                //     );

                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return PaymentCancelAlert(
                                                                          fund:
                                                                              fund);
                                                                    });

                                                                // Navigator.pushNamed(
                                                                //     context,
                                                                //     Routes
                                                                //         .paymentstatus,
                                                                //     arguments:
                                                                //         fund);
                                                              }
                                                            },
                                                  child: fund.loading
                                                      ? const SizedBox(
                                                          width: 18,
                                                          height: 20,
                                                          child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Color(
                                                                  0xff666666)),
                                                        )
                                                      : Text("PAY VIA UPI",
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorBlack
                                                                  : colors
                                                                      .colorWhite,
                                                              14,
                                                              FontWeight.w500)),
                                                )),
                                        ],
                                        if (index == 1) ...[
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                assets.upiIcon,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'UPI ID',
                                                              style: textStyle(
                                                                  colors
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
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          1,
                                                                      horizontal:
                                                                          5),
                                                              margin:
                                                                  const EdgeInsets
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
                                                        _selectedIndex == 1
                                                            ? Row(
                                                                children: [
                                                                  Text(
                                                                    '₹',
                                                                    style: textStyle(
                                                                        colors
                                                                            .colorBlack,
                                                                        15,
                                                                        FontWeight
                                                                            .w600),
                                                                  ),
                                                                  Text(
                                                                    fund.amount.text
                                                                            .isEmpty
                                                                        ? "0.00"
                                                                        : fund
                                                                            .amount
                                                                            .text,
                                                                    style: textStyle(
                                                                        colors
                                                                            .colorBlack,
                                                                        15,
                                                                        FontWeight
                                                                            .w600),
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
                                                              '₹1,00,000',
                                                              style: textStyle(
                                                                  colors
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
                                            height:
                                                _selectedIndex == 1 ? 10 : 0,
                                          ),
                                          if (_selectedIndex == 1)
                                            Column(
                                              children: [
                                                TextFormField(
                                                  controller: fund.upiid,
                                                  style: textStyles
                                                      .textFieldLabelStyle,
                                                  inputFormatters: [
                                                    RemoveEmojiInputFormatter(),
                                                    FilteringTextInputFormatter
                                                        .deny(RegExp(
                                                            '[π£•₹€℅™∆√¶/,.]')),
                                                    FilteringTextInputFormatter
                                                        .deny(RegExp(r'\s')),
                                                  ],
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "example: username@upi",
                                                    hintStyle: textStyles
                                                        .textFieldLabelStyle
                                                        .copyWith(
                                                      color: colors.colorGrey,
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 8,
                                                            horizontal: 10),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                    disabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                    border: OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30)),
                                                    fillColor:
                                                        const Color(0xffF1F3F8),
                                                    filled: true,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: _selectedIndex == 1
                                                        ? 10
                                                        : 0),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            elevation: 0,
                                                            backgroundColor: theme
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
                                                    onPressed:
                                                        fund.amount.text
                                                                    .isEmpty ||
                                                                intValue < 50
                                                            ? null
                                                            : () async {
                                                                await context.read(transcationProvider).fetcUPIIDPayment(
                                                                    context,
                                                                    fund.upiid
                                                                        .text,
                                                                    fund.decryptclientcheck!.clientCheck!
                                                                            .dATA![indexss]
                                                                        [0],
                                                                    fund.bankdetails!
                                                                            .dATA![
                                                                        indexss][2]);
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
                                                                      accno,
                                                                      fund
                                                                          .decryptclientcheck!
                                                                          .clientCheck!
                                                                          .dATA![indexss][0],
                                                                    );
                                                                if (fund.hdfcpaymentdata!.data!
                                                                            .verifiedVPAStatus1 ==
                                                                        "Available" ||
                                                                    fund.hdfcpaymentdata!.data!
                                                                            .verifiedVPAStatus2 ==
                                                                        "Available") {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return const UPIIDPaymentCancelAlert();
                                                                      });
                                                                  // Navigator.pushNamed(
                                                                  //     context,
                                                                  //     Routes
                                                                  //         .upiIDpaymentstatus,
                                                                  //     arguments:
                                                                  //         fund);
                                                                  context
                                                                      .read(
                                                                          transcationProvider)
                                                                      .fetchHdfcpaymetstatus(
                                                                          context,
                                                                          '${fund.hdfctranction!.data!.orderNumber}',
                                                                          '${fund.hdfctranction!.data!.upiTransactionNo}');
                                                                }
                                                              },
                                                    child: fund.loading
                                                        ? const SizedBox(
                                                            width: 18,
                                                            height: 20,
                                                            child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Color(
                                                                    0xff666666)),
                                                          )
                                                        : Text("PAY VIA UPI ID",
                                                            style: textStyle(
                                                                theme.isDarkMode
                                                                    ? colors
                                                                        .colorBlack
                                                                    : colors
                                                                        .colorWhite,
                                                                14,
                                                                FontWeight
                                                                    .w500)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                        if (index == 2) ...[
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                assets.razPayicon,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Net Banking',
                                                              style: textStyle(
                                                                  colors
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
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          1,
                                                                      horizontal:
                                                                          5),
                                                              margin:
                                                                  const EdgeInsets
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
                                                        _selectedIndex == 2
                                                            ? Row(
                                                                children: [
                                                                  Text(
                                                                    '₹',
                                                                    style: textStyle(
                                                                        colors
                                                                            .colorBlack,
                                                                        15,
                                                                        FontWeight
                                                                            .w600),
                                                                  ),
                                                                  Text(
                                                                    fund.amount.text
                                                                            .isEmpty
                                                                        ? "0.00"
                                                                        : fund
                                                                            .amount
                                                                            .text,
                                                                    style: textStyle(
                                                                        colors
                                                                            .colorBlack,
                                                                        15,
                                                                        FontWeight
                                                                            .w600),
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
                                                              '₹5,00,000',
                                                              style: textStyle(
                                                                  colors
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
                                            height:
                                                _selectedIndex == 2 ? 10 : 0,
                                          ),
                                          if (_selectedIndex == 2)
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor: theme
                                                            .isDarkMode
                                                        ? colors.colorbluegrey
                                                        : colors.colorBlack,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 13),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    )),
                                                onPressed: fund.amount.text
                                                            .isEmpty ||
                                                        intValue < 50
                                                    ? null
                                                    : () async {
                                                        context
                                                            .read(
                                                                transcationProvider)
                                                            .fetchrazorpay(
                                                                context,
                                                                int.parse(fund
                                                                        .amount
                                                                        .text)
                                                                    .toString(),
                                                                accno,
                                                                fund
                                                                    .decryptclientcheck!
                                                                    .clientCheck!
                                                                    .dATA![indexss][2],
                                                                ifsc);
                                                        Razorpay razorpay =
                                                            Razorpay();
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          var options = {
                                                            'key':
                                                                'rzp_live_M3tazzVCcFf8Iq',
                                                            'amount': int.parse(
                                                                    "${fund.razorpay!.amount}")
                                                                .toString(),
                                                            'name': 'Zebu Fund',
                                                            'currency': 'INR',
                                                            'order_id': fund
                                                                .razorpay!.id,
                                                            'image':
                                                                "https://zebuetrade.com/wp-content/uploads/2020/07/logo.png",
                                                            'description':
                                                                "Fund add to ${fund.decryptclientcheck!.clientCheck!.dATA![indexss][0]}",
                                                            'retry': {
                                                              'enabled': true,
                                                              'max_count': 1
                                                            },
                                                            'send_sms_hash':
                                                                true,
                                                            'prefill': {
                                                              'name': fund
                                                                  .decryptclientcheck!
                                                                  .clientCheck!
                                                                  .dATA![indexss][2],
                                                              'email': fund
                                                                  .decryptclientcheck!
                                                                  .clientCheck!
                                                                  .dATA![indexss][4],
                                                              'contact': fund
                                                                  .decryptclientcheck!
                                                                  .clientCheck!
                                                                  .dATA![indexss][5],
                                                              'method':
                                                                  'netbanking',
                                                              'bank': bankname,
                                                            },
                                                            'notes': {
                                                              'clientcode':
                                                                  "${fund.decryptclientcheck!.clientCheck!.dATA![indexss][0]}",
                                                              'acc_no': accno,
                                                              'ifsc': ifsc,
                                                              'bankname':
                                                                  bankname,
                                                              'company_code':
                                                                  textValue,
                                                            },
                                                            'theme': {
                                                              'color':
                                                                  "#3399cc",
                                                            },
                                                          };

                                                          razorpay
                                                              .open(options);
                                                        });
                                                      },
                                                child: fund.loading
                                                    ? const SizedBox(
                                                        width: 18,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Color(
                                                                    0xff666666)),
                                                      )
                                                    : Text(
                                                        "PAY VIA NET BANKING",
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorBlack
                                                                : colors
                                                                    .colorWhite,
                                                            14,
                                                            FontWeight.w500)),
                                              ),
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : WithdrawScreen(withdarw: fund)
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

  Future<void> checkForUpiApps() async {
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps();

    bool isUpiAppFound = installedApps.any((app) {
      return _upiAppPackageNames.contains(app.packageName);
    });

    setState(() {
      _isUpiAppAvailable = isUpiAppFound;
      print("APPS $_isUpiAppAvailable");
    });
  }

  showBottomSheetbank(TranctionProvider fund) {
    showModalBottomSheet(
      enableDrag: false,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      backgroundColor: const Color(0xffffffff),
      context: context,
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
              ),
              child: headerTitleText('Choose an bank:'),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: fund.bankdetails!.dATA!.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      initbank =
                          '${fund.bankdetails!.dATA![index][1]}-${hideAccountNumber(fund.bankdetails!.dATA![index][2])}';

                      accno = widget.dd.bankdetails!.dATA![index][2];
                      ifsc = widget.dd.bankdetails!.dATA![index][3];
                      bankname = widget.dd.bankdetails!.dATA![index][1];
                      print("$accno $ifsc $bankname");
                    });
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    child: Text(
                      '${fund.bankdetails!.dATA![index][1]}-${hideAccountNumber(fund.bankdetails!.dATA![index][2])}',
                      style: textStyle(colors.colorBlack, 15, FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
