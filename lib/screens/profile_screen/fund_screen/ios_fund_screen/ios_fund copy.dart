// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/custom_switch_btn.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/fund_function.dart';
import '../upi_id_screens/upi_id_cancel_alert.dart';
import '../withdraw_screen.dart';
import 'ios_no_upi_apps_ui.dart';
import 'ios_upi_apps_bottomsheet.dart';

class IosFundScreenCopy extends StatefulWidget {
  final TranctionProvider fundIos;
  const IosFundScreenCopy({super.key, required this.fundIos});

  @override
  _IosFundScreenCopyState createState() => _IosFundScreenCopyState();
}

class _IosFundScreenCopyState extends State<IosFundScreenCopy> {
  int _selectedIndex = -1;
  int intValue = 0;
  int indexss = 0;

  String ifsc = '';
  String bankname = '';
  String textValue = '';
  String accno = '';
  String initbank = '';
  String _textResult = "";
  String funderror = '';

  bool _enable = true;

  final FocusNode _focusNode = FocusNode();

  // List<Map<String, String>> upiApps = [
  //   {
  //     'name': 'Google Pay',
  //     'url': 'gpay://',
  //     'image': 'assets/icon/gpay.svg',
  //     'limit': '1,00,000',
  //     'value': '0',
  //   },
  //   {
  //     'name': 'PhonePe',
  //     'url': 'phonepe://',
  //     'image': 'assets/icon/phonepay.svg',
  //     'limit': '1,00,000',
  //     'value': '1',
  //   },
  //   {
  //     'name': 'Paytm',
  //     'url': 'paytm://',
  //     'image': 'assets/icon/paytm.svg',
  //     'limit': '1,00,000',
  //     'value': '2',
  //   }
  // ];

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

  List<Map<String, String>> defaultUpiapps = [
    {
      'name': 'UPI APPS',
      'image': 'assets/icon/icons8-bhim.svg',
      'limit': '1,00,000'
    },
    {
      'name': 'UPI ID',
      'image': 'assets/icon/icons8-bhim.svg',
      'limit': '1,00,000'
    },
    {
      'name': 'NET BANKING',
      'image': 'assets/icon/razpay.svg',
      'limit': '5,00,000'
    },
  ];

  List<Map<String, dynamic>> availableApps = [];

  @override
  void initState() {
    accno = widget.fundIos.bankdetails!.dATA![indexss][2];
    ifsc = widget.fundIos.bankdetails!.dATA![indexss][3];
    bankname = widget.fundIos.bankdetails!.dATA![indexss][1];
    initbank =
        '${widget.fundIos.bankdetails!.dATA![indexss][1]} - ${hideAccountNumber(accno)}';
    textValue = widget.fundIos.decryptclientcheck!.companyCode![0];
    super.initState();
    _checkAvailableApps();
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
          bottomNavigationBar: _enable == true
              ? null
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: EdgeInsets.symmetric(
                      vertical:
                          defaultTargetPlatform == TargetPlatform.iOS ? 20 : 0),
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: theme.isDarkMode
                            ? colors.colorbluegrey
                            : colors.colorBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: fund.withdrawamount.text.isEmpty ||
                              fund.payoutdetails!.withdrawAmount == '0.0' ||
                              int.parse(fund.withdrawamount.text) >
                                  double.parse(fund
                                          .payoutdetails!.withdrawAmount
                                          .toString())
                                      .toInt()
                          ? null
                          : () {},
                      child: Text(
                        'Withdraw amount',
                        style:
                            textStyle(colors.colorWhite, 16, FontWeight.w400),
                      )),
                ),
          body: GestureDetector(
            onTap: () {
              _focusNode.unfocus();
            },
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
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          color: const Color(0xfffcefd4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Text(
                            "Fund withdraw to ${fund.decryptclientcheck!.clientCheck!.dATA![indexss][2]} ${fund.decryptclientcheck!.clientCheck!.dATA![indexss][0]}",
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
                                : null;
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
                                focusNode: _focusNode,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                style: textStyle(
                                    colors.colorBlack, 35, FontWeight.w600),
                                controller: fund.amount,
                                onChanged: (value) {
                                  _selectedIndex = 0;

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
                                _focusNode.unfocus();
                                showBottomSheetbank(fund, theme);
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
                            const SizedBox(
                              height: 10,
                            ),
                            // availableApps.isEmpty
                            //     ? Container()
                            //     :

                            ListView.builder(
                              padding: const EdgeInsets.all(0),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: defaultUpiapps.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                      _focusNode.unfocus();
                                    });
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: _selectedIndex == index
                                                  ? colors.colorBlack
                                                  : colors.colorbluegrey)),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                '${defaultUpiapps[index]['image']}',
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
                                                              '${defaultUpiapps[index]['name']}',
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
                                                        _selectedIndex == 1 &&
                                                                    defaultUpiapps[index]
                                                                            [
                                                                            'name'] ==
                                                                        'UPI ID' ||
                                                                _selectedIndex ==
                                                                        2 &&
                                                                    defaultUpiapps[index]
                                                                            [
                                                                            'name'] ==
                                                                        'NET BANKING'
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
                                                              '₹${defaultUpiapps[index]['limit']}',
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
                                            height: _selectedIndex == 1 &&
                                                    defaultUpiapps[index]
                                                            ['name'] ==
                                                        'UPI ID'
                                                ? 10
                                                : 0,
                                          ),
                                          if (index == 0 &&
                                              _selectedIndex == 0) ...[
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(
                                                    height: _selectedIndex ==
                                                                1 &&
                                                            defaultUpiapps[
                                                                        index]
                                                                    ['name'] ==
                                                                'NET BANKING'
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
                                                            : availableApps
                                                                    .isEmpty
                                                                ? () {
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
                                                                  }
                                                                : () async {
                                                                    _focusNode
                                                                        .unfocus();

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

                                                                    await context
                                                                        .read(
                                                                            transcationProvider)
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
                                                        : Text(
                                                            "PAY VIA UPI APPS",
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
                                                )
                                              ],
                                            ),
                                          ],
                                          if (index == 1 &&
                                              _selectedIndex == 1) ...[
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
                                                    height: _selectedIndex ==
                                                                1 &&
                                                            defaultUpiapps[
                                                                        index]
                                                                    ['name'] ==
                                                                'UPI ID'
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
                                                                            onWillPop:
                                                                                () async {
                                                                              return false;
                                                                            },
                                                                            child:
                                                                                const UPIIDPaymentCancelAlert());
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
                                                )
                                              ],
                                            ),
                                          ],
                                          if (index == 2 &&
                                              _selectedIndex == 2) ...[
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(
                                                    height: _selectedIndex ==
                                                                1 &&
                                                            defaultUpiapps[
                                                                        index]
                                                                    ['name'] ==
                                                                'NET BANKING'
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
                                                    onPressed: fund.amount.text
                                                                .isEmpty ||
                                                            intValue < 50
                                                        ? null
                                                        : () async {},
                                                    child: fund.loading
                                                        ? const SizedBox(
                                                            width: 18,
                                                            height: 20,
                                                            child: CircularProgressIndicator(
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
                                                                FontWeight
                                                                    .w500)),
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
                      : WithdrawScreen(withdarw: fund, foucs: _focusNode)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkAvailableApps() async {
    List<Map<String, dynamic>> tempList = [];

    for (var app in upiApptest) {
      bool isInstalled = await canLaunch(app['url']!);
      if (isInstalled) {
        tempList.add(app);
      }
    }

    setState(() {
      availableApps = tempList;
    });
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

  convertToText(String value) {
    setState(() {
      int number = int.tryParse(value) ?? 0;
      String result = NumberToWord().convert('en-in', number);
      _textResult = capitalizeFirstLetter(result);
    });
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
                      setState(() {
                        initbank =
                            '${fund.bankdetails!.dATA![index][1]}-${hideAccountNumber(fund.bankdetails!.dATA![index][2])}';

                        accno = widget.fundIos.bankdetails!.dATA![index][2];
                        ifsc = widget.fundIos.bankdetails!.dATA![index][3];
                        bankname = widget.fundIos.bankdetails!.dATA![index][1];
                      });
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        '${fund.bankdetails!.dATA![index][1]}-${hideAccountNumber(fund.bankdetails!.dATA![index][2])}',
                        style:
                            textStyle(colors.colorBlack, 15, FontWeight.w600),
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
}
