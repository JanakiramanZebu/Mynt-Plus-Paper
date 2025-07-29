 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart'; 
import '../../../provider/profile_all_details_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/fund_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart'; 

class CPActionOrderScreen extends StatefulWidget {
  final dynamic data;
  const CPActionOrderScreen({super.key, required this.data});

  @override
  State<CPActionOrderScreen> createState() => _CPActionOrderScreen();
}

class DropdownItem {
  final String value;
  final String label;
  final bool isEnabled;

  DropdownItem({
    required this.value,
    required this.label,
    this.isEnabled = true,
  });
}

class _CPActionOrderScreen extends State<CPActionOrderScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height; 

    return Consumer(builder: (context, WidgetRef ref, _) {
      final ledgerprovider = ref.watch(ledgerProvider);
      final profiledetails = ref.watch(profileAllDetailsProvider);
      final fundState = ref.watch(fundProvider);
      bool checkval = ledgerprovider.cutoffcheckboxofs;

      final theme = ref.read(themeProvider);

      // final myController = TextEditingController(text: ledgerprovider.selectnetpledge.text);
      // String selectedValue = ledgerprovider.segmentvalue;

// Optional: remove duplicates if needed (based on value) 

      return WillPopScope(
        onWillPop: () async {
          if (ledgerprovider.listforpledge == []) {
            ledgerprovider.changesegvaldummy('');
          }
          Navigator.pop(context);
          print(
              "objectobjectobjectobjectobjectobjectobjectobject ${screenheight * 0.00038}");
          return true;
        },
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.isDarkMode
                    ? Color.fromARGB(255, 0, 0, 0)
                    : Color.fromARGB(255, 255, 255, 255)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: const Color.fromARGB(255, 219, 218, 218),
                    width: 40,
                    height: 4.0,
                    padding: EdgeInsets.only(
                        top: 10, bottom: 25, left: 20, right: 20),
                    margin: EdgeInsets.only(top: 16),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
                child: TextWidget.heroText(
                    text:
                        "${(((profiledetails.clientAllDetails.clientData?.pOA == 'Y' || profiledetails.clientAllDetails.clientData?.dDPI == 'Y') || (widget.data?.approvedqty != '0' && widget.data?.approvedqty != 'null'))) || (ledgerprovider.selectvalueofcpaction == 'OFS') ? ledgerprovider.selectvalueofcpaction : 'Need Edis'}",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 2.0,
                  bottom: 6.0,
                ),
                child: Divider(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8),
                  thickness: 6.0,
                ),
              ),
              if ((profiledetails.clientAllDetails.clientData?.pOA == 'Y' ||
                      profiledetails.clientAllDetails.clientData?.dDPI == 'Y' ||
                      (widget.data?.approvedqty != '0' &&
                          widget.data?.approvedqty != 'null')) ||
                  ledgerprovider.selectvalueofcpaction == 'OFS')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.40,
                                child: TextWidget.subText(
                                    text: "${widget.data?.name}",
                                    color: colors.colorBlack,
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 1),
                              ),
                              if (ledgerprovider.selectvalueofcpaction !=
                                  'OFS') ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: TextWidget.captionText(
                                      text:
                                          "${widget.data?.biddingStartDate} : ${widget.data?.biddingEndDate}",
                                      color: colors.kColorGreyDarkTheme,
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 1),
                                ),
                              ],
                            ],
                          ),
                          if (ledgerprovider.selectvalueofcpaction !=
                              'OFS') ...[
                            TextWidget.paraText(
                                text: "${widget.data?.cutOffPrice}",
                                color: colors.colorBlack,
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 1)
                          ],
                          if (ledgerprovider.selectvalueofcpaction ==
                              'OFS') ...[
                            TextWidget.paraText(
                                text: "${widget.data?.baseprice}",
                                color: colors.colorBlack,
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 1)
                          ]
                        ],
                      ),
                      if (ledgerprovider.selectvalueofcpaction != 'OFS') ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.subText(
                                      text: "Qty held ",
                                      color: colors.colorBlack,
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 1),
                                  if (widget.data?.approvedqty != '0' &&
                                      widget.data?.approvedqty != 'null')
                                    TextWidget.subText(
                                        text: ": ${widget.data?.havingqty}",
                                        color: colors.colorBlack,
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 1),
                                ],
                              ),
                              if (widget.data?.approvedqty == '0' ||
                                  widget.data?.approvedqty == 'null')
                                TextWidget.paraText(
                                    text: "${widget.data?.havingqty}",
                                    color: colors.colorBlack,
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 1),
                              if (widget.data?.approvedqty != '0' &&
                                  widget.data?.approvedqty != 'null')
                                TextWidget.subText(
                                    text:
                                        "Approved Qty : ${widget.data?.approvedqty}",
                                    color: colors.colorBlack,
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 1),
                            ],
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      TextWidget.paraText(
                                          text:
                                              "${ledgerprovider.selectvalueofcpaction != 'OFS' ? 'Lot Size :' : 'Bid Qty'}  ",
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          color: colors.colorGrey,
                                          fw: 0),
                                      TextWidget.paraText(
                                          text:
                                              "${(widget.data?.lotSize.toString())}",
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          color: colors.colorBlack,
                                          fw: 0),
                                    ],
                                  ),
                                  if (ledgerprovider.selectvalueofcpaction !=
                                      'OFS') ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: SizedBox(
                                          height: 44,
                                          child: CustomTextFormField(
                                              textAlign: TextAlign.start,
                                              fillColor: theme.isDarkMode
                                                  ? colors.darkGrey
                                                  : const Color(0xffF1F3F8),
                                              hintText: 'Enter quantity',
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormate: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    10), // Limit to 10 characters
                                              ],
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
                                              textCtrl: ledgerprovider
                                                  .selectedqtyforcpaction,
                                              onChanged: (value) {
                                                ledgerprovider.setCPActionQty(
                                                    value,
                                                    (profiledetails
                                                                    .clientAllDetails
                                                                    .clientData
                                                                    ?.dDPI ==
                                                                'Y' ||
                                                            profiledetails
                                                                    .clientAllDetails
                                                                    .clientData
                                                                    ?.pOA ==
                                                                'Y')
                                                        ? widget.data?.havingqty
                                                                .toString() ??
                                                            '0'
                                                        : widget
                                                            .data?.approvedqty,
                                                    ledgerprovider
                                                        .selectvalueofcpaction,
                                                    '${fundState.fundDetailModel?.cash}');
                                              })),
                                    ),
                                  ],
                                  if (ledgerprovider.selectvalueofcpaction ==
                                      'OFS') ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: SizedBox(
                                          height: 44,
                                          child: CustomTextFormField(
                                              textAlign: TextAlign.start,
                                              fillColor: theme.isDarkMode
                                                  ? colors.darkGrey
                                                  : const Color(0xffF1F3F8),
                                              hintText: 'Enter quantity',
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormate: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    10), // Limit to 10 characters
                                              ],
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
                                              textCtrl: ledgerprovider
                                                  .selectedqtyforcpaction,
                                              onChanged: (value) {
                                                ledgerprovider.setofqtybox(
                                                    value,
                                                    '${fundState.fundDetailModel?.cash}');
                                              })),
                                    ),
                                  ],
                                  if (ledgerprovider
                                      .cpactionerrormsg.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: TextWidget.captionText(
                                            text: ledgerprovider.cpactionerrormsg,
                                            color: colors.kColorRedText,   
                                            textOverflow:
                                                TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 0),
                                      ),
                                    ),

                                  // Error message display
                                  // if (ledgerprovider
                                  //     .cpactionerrormsg.isNotEmpty)
                                  //   Padding(
                                  //     padding:
                                  //         const EdgeInsets.only(top: 4.0),
                                  //     child: SizedBox(
                                  //       width: double.infinity,
                                  //       child: TextWidget.captionText(
                                  //           text: ledgerprovider
                                  //               .cpactionerrormsg,
                                  //           color: colors.kColorRedText,
                                  //           textOverflow:
                                  //               TextOverflow.ellipsis,
                                  //           theme: theme.isDarkMode,
                                  //           fw: 0),
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      TextWidget.paraText(
                                          text:
                                              "${ledgerprovider.selectvalueofcpaction != 'OFS' ? 'Price Range :' : 'Price'}  ",
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          color: colors.colorGrey,
                                          fw: 0),
                                      if (ledgerprovider
                                              .selectvalueofcpaction !=
                                          'OFS') ...[
                                        TextWidget.paraText(
                                            text: "${(widget.data?.minPrice)} ",
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            color: colors.colorBlack,
                                            fw: 0),
                                        TextWidget.paraText(
                                            text:
                                                "to ${(widget.data?.maxPrice)}",
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            color: colors.colorBlack,
                                            fw: 0),
                                      ],
                                    ],
                                  ),
                                  if (ledgerprovider.selectvalueofcpaction !=
                                      'OFS') ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: SizedBox(
                                          height: 44,
                                          child: CustomTextFormField(
                                              textAlign: TextAlign.start,
                                              fillColor: theme.isDarkMode
                                                  ? colors.darkGrey
                                                  : const Color(0xffF1F3F8),
                                              hintText: 'Price',
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormate: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    10), // Limit to 10 characters
                                              ],
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
                                              textCtrl: ledgerprovider
                                                  .selectedpriceforcpaction,
                                              onChanged: (value) {
                                                ledgerprovider.setCPActionPrice(
                                                    value,
                                                    double.tryParse(widget
                                                                .data?.minPrice
                                                                .toString() ??
                                                            '0') ??
                                                        0,
                                                    double.tryParse(widget
                                                                .data?.maxPrice
                                                                .toString() ??
                                                            '0') ??
                                                        0,
                                                    ledgerprovider
                                                        .selectvalueofcpaction,
                                                    '${fundState.fundDetailModel?.cash}');
                                              })),
                                    ),
                                  ],
                                  if (ledgerprovider.selectvalueofcpaction ==
                                      'OFS') ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: SizedBox(
                                          height: 44,
                                          child: CustomTextFormField(
                                              isReadable: ledgerprovider
                                                          .cutoffcheckboxofs ==
                                                      true
                                                  ? true
                                                  : false,
                                              textAlign: TextAlign.start,
                                              fillColor: theme.isDarkMode
                                                  ? colors.darkGrey
                                                  : const Color(0xffF1F3F8),
                                              hintText: 'Price',
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormate: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    10), // Limit to 10 characters
                                              ],
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
                                              textCtrl: ledgerprovider
                                                  .selectedpriceforcpaction,
                                              onChanged: (value) {
                                                ledgerprovider.setofpricebox(
                                                    value,
                                                    '${fundState.fundDetailModel?.cash}', widget.data?.baseprice);
                                              })),
                                    ),
                                  ],
                                  // Error message display
                                  // if (ledgerprovider
                                  //     .cpactionerrormsg.isNotEmpty)
                                  //   Padding(
                                  //     padding:
                                  //         const EdgeInsets.only(top: 4.0),
                                  //     child: SizedBox(
                                  //       width: double.infinity,
                                  //       child: TextWidget.captionText(
                                  //           text: ledgerprovider
                                  //               .cpactionerrormsg,
                                  //           color: colors.kColorRedText,
                                  //           textOverflow:
                                  //               TextOverflow.ellipsis,
                                  //           theme: theme.isDarkMode,
                                  //           fw: 0),
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
                             
                            if (ledgerprovider.selectvalueofcpaction == 'OFS')
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, top: 20.0),
                              child: Row(children: [
                                IconButton(
                                    onPressed: () {
                                      checkval = !checkval;
                                      ledgerprovider.setCutoffcheckboxforofs(
                                          checkval, widget.data?.baseprice,fundState.fundDetailModel?.cash ?? '0');
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
                                    icon: SvgPicture.asset(theme.isDarkMode
                                        ? checkval == false
                                            ? assets.darkCheckedboxIcon
                                            : assets.darkCheckboxIcon
                                        : checkval == true
                                            ? assets.checkedbox
                                            : assets.checkbox)),
                                Text("Cut off price ",
                                    style: textStyle(const Color(0xff666666),
                                        14, FontWeight.w500)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                        ),
                        child: Divider(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          thickness: 1.0,
                        ),
                      ),
                      if (ledgerprovider.selectvalueofcpaction != 'OFS') ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(screenWidth, 40),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor:
                                      ledgerprovider.cpactionsubtn == false
                                          ? colors.kColorGreyDarkTheme
                                          : colors.colorBlack,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              onPressed: () {
                                ledgerprovider.putordercopaction(
                                  ledgerprovider.selectvalueofcpaction,
                                  widget.data?.symbol ?? '',
                                  widget.data?.exchange ?? '',
                                  widget.data?.issueType ?? '',
                                  ledgerprovider.selectedqtyforcpaction.text,
                                  ledgerprovider.selectedpriceforcpaction.text,
                                  context,
                                  'ER',
                                  '',
                                );
                              },
                              child: Text("Submit",
                                  textAlign: TextAlign.center,
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      12,
                                      FontWeight.w500))),
                        )
                      ],
                      if (ledgerprovider.selectvalueofcpaction == 'OFS') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: TextWidget.captionText(
                                      text: "${ledgerprovider.captionforofs}",
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      color: colors.colorGrey,
                                      fw: 0),
                                ),
                                TextWidget.paraText(
                                    text:
                                        "${ledgerprovider.requiredamountforofs}",
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    color: colors.colorBlack,
                                    fw: 0),
                              ],
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    backgroundColor:
                                        ledgerprovider.cpactionsubtn == false
                                            ? colors.kColorGreyDarkTheme
                                            : colors.colorBlack,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                                onPressed: () {
                                  ledgerprovider.putordercopaction(
                                    ledgerprovider.selectvalueofcpaction,
                                    widget.data?.symbol ?? '',
                                    widget.data?.exchange ?? '',
                                    widget.data?.issueType ?? '',
                                    ledgerprovider.selectedqtyforcpaction.text,
                                    ledgerprovider
                                        .selectedpriceforcpaction.text,
                                    context,
                                    'ER',
                                    '',
                                  );
                                },
                                child: Text("Submit",
                                    textAlign: TextAlign.center,
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        12,
                                        FontWeight.w500))),
                          ],
                        )
                      ],
                    ],
                  ),
                ),
              SizedBox(
                height: 20.0,
              ),
              if (((profiledetails.clientAllDetails.clientData?.pOA == 'N' &&
                          profiledetails.clientAllDetails.clientData?.dDPI ==
                              'N') &&
                      (widget.data?.approvedqty == '0' ||
                          widget.data?.approvedqty == 'null')) &&
                  (ledgerprovider.selectvalueofcpaction != 'OFS')) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: screenWidth * 0.90,
                            child: Text(
                              "${ledgerprovider.selectvalueofcpaction}You are not eligible for this action because DDPI and POA are inactive. To proceed, you need to complete EDIs.",
                              style: TextStyle(
                                color: colors.colorBlack,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true, // ensure text wraps
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(screenWidth, 40),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                backgroundColor: colors.colorBlack,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                            onPressed: () {
                              Navigator.pop(context);

                              ledgerprovider.setedisclickfromcpaction = true;

                              ref.read(fundProvider).fetchHstoken(context);
                              ref.read(fundProvider).eDis(context);
                              // ledgerprovider.putordercopaction(
                              //     widget.data?.exchange ?? '',
                              //     widget.data?.issueType ?? '',
                              //     widget.data?.symbol ?? '',
                              //     context);
                            },
                            child: Text("Proceed",
                                textAlign: TextAlign.center,
                                style: textStyle(
                                    !theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    12,
                                    FontWeight.w500))),
                      )
                    ],
                  ),
                ),
              ],
            ]),
          ),
        ),
      );
    });
  }
}
