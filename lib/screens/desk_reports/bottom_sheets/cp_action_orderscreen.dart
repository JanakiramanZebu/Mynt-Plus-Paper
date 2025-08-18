import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/desk_reports/bottom_sheets/cp_cancelorder_screen.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/profile_all_details_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/fund_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/snack_bar.dart';

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

      final dataval = widget.data;

      void _handleOrderAction(BuildContext context) {
        if (ledgerprovider.selectvalueofcpaction == 'OFS') {
          ledgerprovider.setordervalueforofs(
            '1',
            dataval.baseprice,
            fundState.fundDetailModel?.cash ?? '0',
          );
        } else {
          ledgerprovider.setCPActionQty('', '', '', '');
          ledgerprovider.setCPActionPrice('', 0, 0, '', '');
        }

        if (dataval.orderstatus == 'pending') {
          showModalBottomSheet(
            context: context,
            builder: (context) => cancelOrderScreenCopAction(data: dataval),
          );
        } else {
          if ((dataval.eligibleornot == 'yes') ||
              (dataval.approvedqty != '0' && dataval.eligibleornot == 'yes') ||
              (ledgerprovider.selectvalueofcpaction == 'OFS')) {
            showModalBottomSheet(
              context: context,
              builder: (context) => CPActionOrderScreen(data: dataval),
            );
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(error(context, "Not Eligible"));
            return;
          }
        }
      }

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
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                  decoration: BoxDecoration(
           borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
         color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
         border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),

         
        ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.60,
                              child: TextWidget.titleText(
                                text: "${widget.data?.name}",
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 1,
                              ),
                            ),
                            TextWidget.subText(
                              text: (((profiledetails.clientAllDetails
                                                      .clientData?.pOA ==
                                                  'Y' ||
                                              profiledetails.clientAllDetails
                                                      .clientData?.dDPI ==
                                                  'Y') ||
                                          (widget.data?.approvedqty != '0' &&
                                              widget.data?.approvedqty !=
                                                  'null'))) ||
                                      (ledgerprovider.selectvalueofcpaction ==
                                          'OFS')
                                  // ? _getTypeLabel(widget.data?.issueType)
                                  ? ''
                                  : 'Need e-DIS',
                              textOverflow: TextOverflow.ellipsis,
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 0,
                            ),
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
                                    ? colors.highlightDark
                                    : colors.highlightLight,
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
                      ),
                        ListDivider(),
                      if ((profiledetails.clientAllDetails.clientData?.pOA ==
                                  'Y' ||
                              profiledetails
                                      .clientAllDetails.clientData?.dDPI ==
                                  'Y' ||
                              (widget.data?.approvedqty != '0' &&
                                  widget.data?.approvedqty != 'null')) ||
                          ledgerprovider.selectvalueofcpaction == 'OFS')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (ledgerprovider
                                                .selectvalueofcpaction !=
                                            'OFS') ...[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: TextWidget.paraText(
                                              text:
                                                  "Open ${widget.data?.biddingStartDate} / Close ${widget.data?.biddingEndDate}",
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 3,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (ledgerprovider.selectvalueofcpaction !=
                                        'OFS') ...[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextWidget.subText(
                                            text: "${widget.data?.cutOffPrice}",
                                            color: theme.isDarkMode
                                                ? colors.textSecondaryDark
                                                : colors.textSecondaryLight,
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 0,
                                          ),
                                        ],
                                      )
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
                              ),
                              if (ledgerprovider.selectvalueofcpaction !=
                                  'OFS') ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // if (widget.data?.approvedqty != '0' &&
                                          //     widget.data?.approvedqty != 'null')
                                          TextWidget.subText(
                                              text: "Held / Approved : ",
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 3),
                                          TextWidget.subText(
                                              text:
                                                  "${widget.data?.havingqty == 'null' ? '0' : widget.data?.havingqty} / ${widget.data?.approvedqty == 'null' ? '0' : widget.data?.approvedqty}",
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 3),
                                        ],
                                      ),
                                      // if (widget.data?.approvedqty == '0' ||
                                      //     widget.data?.approvedqty == 'null')
                                      //   TextWidget.paraText(
                                      //       text:
                                      //           "${widget.data?.havingqty == 'null' ? '0' : widget.data?.havingqty}",
                                      //       color: colors.colorBlack,
                                      //       textOverflow: TextOverflow.ellipsis,
                                      //       theme: theme.isDarkMode,
                                      //       fw: 1),
                                    ],
                                  ),
                                ),
                              ],
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Row(
                                        //   children: [
                                        //     TextWidget.paraText(
                                        //         text:
                                        //             "${ledgerprovider.selectvalueofcpaction != 'OFS' ? 'Lot Size :' : 'Bid Qty'}  ",
                                        //         textOverflow: TextOverflow.ellipsis,
                                        //         theme: theme.isDarkMode,
                                        //         color: colors.colorGrey,
                                        //         fw: 0),
                                        //     TextWidget.paraText(
                                        //         text:
                                        //             "${(widget.data?.lotSize.toString())}",
                                        //         textOverflow: TextOverflow.ellipsis,
                                        //         theme: theme.isDarkMode,
                                        //         color: colors.colorBlack,
                                        //         fw: 0),
                                        //   ],
                                        // ),
                                        if (ledgerprovider
                                                .selectvalueofcpaction !=
                                            'OFS') ...[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: SizedBox(
                                                height: 44,
                                                child: CustomTextFormField(
                                                    textAlign: TextAlign.start,
                                                    fillColor: theme.isDarkMode
                                                        ? colors.darkGrey
                                                        : const Color(
                                                            0xffF1F3F8),
                                                    hintText: 'Enter quantity',
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormate: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                          10), // Limit to 10 characters
                                                    ],
                                                    hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                                                    style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                  ),
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
                                                              ? widget.data
                                                                      ?.havingqty
                                                                      .toString() ??
                                                                  '0'
                                                              : widget.data
                                                                  ?.approvedqty,
                                                          ledgerprovider
                                                              .selectvalueofcpaction,
                                                          '${fundState.fundDetailModel?.cash}');
                                                    })),
                                          ),
                                          if (ledgerprovider.cpactionerrormsgqty
                                                  .isNotEmpty &&
                                              ledgerprovider
                                                      .selectvalueofcpaction !=
                                                  'OFS')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: TextWidget.captionText(
                                                    text: ledgerprovider
                                                        .cpactionerrormsgqty,
                                                    color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ),
                                            ),
                                        ],
                                        if (ledgerprovider
                                                .selectvalueofcpaction ==
                                            'OFS') ...[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: SizedBox(
                                                height: 44,
                                                child: CustomTextFormField(
                                                    textAlign: TextAlign.start,
                                                    fillColor: theme.isDarkMode
                                                        ? colors.darkGrey
                                                        : const Color(
                                                            0xffF1F3F8),
                                                    hintText: 'Enter quantity',
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormate: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                          10), // Limit to 10 characters
                                                    ],
                                                    hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                                                     style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                  ),
                                                    textCtrl: ledgerprovider
                                                        .selectedqtyforcpaction,
                                                    onChanged: (value) {
                                                      ledgerprovider.setofqtybox(
                                                          value,
                                                          '${fundState.fundDetailModel?.cash}');
                                                    })),
                                          ),
                                        ],
                                        if (ledgerprovider.cpactionerrormsgqty
                                                .isNotEmpty &&
                                            ledgerprovider
                                                    .selectvalueofcpaction ==
                                                'OFS')
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: TextWidget.captionText(
                                                  text: ledgerprovider
                                                      .cpactionerrormsgqty,
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
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Row(
                                        //   children: [
                                        //     TextWidget.paraText(
                                        //         text:
                                        //             "${ledgerprovider.selectvalueofcpaction != 'OFS' ? 'Price Range :' : 'Price'}  ",
                                        //         textOverflow: TextOverflow.ellipsis,
                                        //         theme: theme.isDarkMode,
                                        //         color: colors.colorGrey,
                                        //         fw: 0),
                                        //     if (ledgerprovider
                                        //             .selectvalueofcpaction !=
                                        //         'OFS') ...[
                                        //       TextWidget.paraText(
                                        //           text: "${(widget.data?.minPrice)} ",
                                        //           textOverflow: TextOverflow.ellipsis,
                                        //           theme: theme.isDarkMode,
                                        //           color: colors.colorBlack,
                                        //           fw: 0),
                                        //       TextWidget.paraText(
                                        //           text:
                                        //               "to ${(widget.data?.maxPrice)}",
                                        //           textOverflow: TextOverflow.ellipsis,
                                        //           theme: theme.isDarkMode,
                                        //           color: colors.colorBlack,
                                        //           fw: 0),
                                        //     ],
                                        //   ],
                                        // ),
                                        if (ledgerprovider
                                                .selectvalueofcpaction !=
                                            'OFS') ...[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: SizedBox(
                                                height: 44,
                                                child: CustomTextFormField(
                                                    textAlign: TextAlign.start,
                                                    fillColor: theme.isDarkMode
                                                        ? colors.darkGrey
                                                        : const Color(
                                                            0xffF1F3F8),
                                                    hintText: 'Price',
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormate: [
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                        RegExp(
                                                            r'^\d*\.?\d{0,9}$'),
                                                      ),
                                                      LengthLimitingTextInputFormatter(
                                                          10), // Limit to 10 characters
                                                    ],
                                                     hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                                                    style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                  ),
                                                    textCtrl: ledgerprovider
                                                        .selectedpriceforcpaction,
                                                    onChanged: (value) {
                                                      ledgerprovider.setCPActionPrice(
                                                          value,
                                                          double.tryParse(widget
                                                                      .data
                                                                      ?.minPrice
                                                                      .toString() ??
                                                                  '0') ??
                                                              0,
                                                          double.tryParse(widget
                                                                      .data
                                                                      ?.maxPrice
                                                                      .toString() ??
                                                                  '0') ??
                                                              0,
                                                          ledgerprovider
                                                              .selectvalueofcpaction,
                                                          '${fundState.fundDetailModel?.cash}');
                                                    })),
                                          ),
                                          if (ledgerprovider.cpactionerrormsg
                                                  .isNotEmpty &&
                                              ledgerprovider
                                                      .selectvalueofcpaction !=
                                                  'OFS')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: TextWidget.captionText(
                                                    text: ledgerprovider
                                                        .cpactionerrormsg,
                                                    color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ),
                                            ),
                                        ],
                                        if (ledgerprovider
                                                .selectvalueofcpaction ==
                                            'OFS') ...[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
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
                                                        : const Color(
                                                            0xffF1F3F8),
                                                    hintText: 'Price',
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormate: [
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                        RegExp(
                                                            r'^\d*\.?\d{0,9}$'),
                                                      ),
                                                      LengthLimitingTextInputFormatter(
                                                          10), // Limit to 10 characters
                                                    ],
                                                    hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                                                   style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                  ),
                                                    textCtrl: ledgerprovider
                                                        .selectedpriceforcpaction,
                                                    onChanged: (value) {
                                                      ledgerprovider.setofpricebox(
                                                          value,
                                                          '${fundState.fundDetailModel?.cash}',
                                                          widget
                                                              .data?.baseprice);
                                                    })),
                                          ),
                                        ],
                                        if (ledgerprovider
                                                .cpactionerrormsg.isNotEmpty &&
                                            ledgerprovider
                                                    .selectvalueofcpaction ==
                                                'OFS')
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: TextWidget.captionText(
                                                  text: ledgerprovider
                                                      .cpactionerrormsg,
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
                                  if (ledgerprovider.selectvalueofcpaction ==
                                      'OFS')
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4.0, top: 20.0),
                                      child: Row(children: [
                                        IconButton(
                                            onPressed: () {
                                              checkval = !checkval;
                                              ledgerprovider
                                                  .setCutoffcheckboxforofs(
                                                      checkval,
                                                      widget.data?.baseprice,
                                                      fundState.fundDetailModel
                                                              ?.cash ??
                                                          '0');
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
                                                ? checkval == false
                                                    ? assets.darkCheckedboxIcon
                                                    : assets.darkCheckboxIcon
                                                : checkval == true
                                                    ? assets.checkedbox
                                                    : assets.checkbox)),
                                        Text("Cut off price ",
                                            style: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                                    ),
                                      ]),
                                    ),
                                ],
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //     top: 10.0,
                              //   ),
                              //   child: Divider(
                              //     color: theme.isDarkMode
                              //         ? const Color(0xffB5C0CF).withOpacity(.15)
                              //         : const Color(0xffF1F3F8),
                              //     thickness: 1.0,
                              //   ),
                              // ),
                              if (ledgerprovider.selectvalueofcpaction !=
                                  'OFS') ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          elevation: 0,
                                          minimumSize: const Size(
                                              0, 45), // width, height

                                          backgroundColor:
                                              colors.btnOutlinedBorder,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed:
                                            ledgerprovider.cpactionsubtn ==
                                                    false
                                                ? () {
                                                    ledgerprovider.showofserrormsg(
                                                        'You don\'t hold any quantity');
                                                  }
                                                : () {
                                                    ledgerprovider
                                                        .showofserrormsg('');
                                                    _handleOrderAction(context);
                                                  },
                                        child: TextWidget.subText(
                                            text: "Submit",
                                            theme: theme.isDarkMode,
                                            fw: 2,
                                            color: colors.colorWhite)),
                                  ),
                                )
                              ],
                              if (ledgerprovider.selectvalueofcpaction ==
                                  'OFS') ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: TextWidget.captionText(
                                              text:
                                                  "${ledgerprovider.captionforofs}",
                                              textOverflow:
                                                  TextOverflow.ellipsis,
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
                                    OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          elevation: 0,
                                          minimumSize: const Size(
                                              0, 45), // width, height

                                          backgroundColor:
                                              colors.btnOutlinedBorder,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () {
                                          ledgerprovider.putordercopaction(
                                            ledgerprovider
                                                .selectvalueofcpaction,
                                            widget.data?.symbol ?? '',
                                            widget.data?.exchange ?? '',
                                            widget.data?.issueType ?? '',
                                            ledgerprovider
                                                .selectedqtyforcpaction.text,
                                            ledgerprovider
                                                .selectedpriceforcpaction.text,
                                            context,
                                            'ER',
                                            '',
                                          );
                                        },
                                        child: TextWidget.subText(
                                            text: "Submit",
                                            theme: theme.isDarkMode,
                                            fw: 2,
                                            color: colors.colorWhite)),
                                  ],
                                )
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      if (((profiledetails.clientAllDetails.clientData?.pOA ==
                                      'N' &&
                                  profiledetails
                                          .clientAllDetails.clientData?.dDPI ==
                                      'N') &&
                              (widget.data?.approvedqty == '0' ||
                                  widget.data?.approvedqty == 'null')) &&
                          (ledgerprovider.selectvalueofcpaction != 'OFS')) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              TextWidget.subText(
                                text:
                                    "${ledgerprovider.selectvalueofcpaction} You're not eligible to perform this action as your DDPI and POA are inactive. To proceed, please complete your e-DIS.",
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 3,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: SizedBox(
                                  width: screenWidth,
                                  child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        elevation: 0,
                                        minimumSize:
                                            const Size(0, 45), // width, height

                                        backgroundColor:
                                            colors.btnOutlinedBorder,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await ref
                                            .read(fundProvider)
                                            .fetchHstoken(context);
                                        await ref
                                            .read(fundProvider)
                                            .eDis(context);
                                        // ledgerprovider
                                        //     .setedisclickfromcpaction = true;
                                        // ledgerprovider.putordercopaction(
                                        //     widget.data?.exchange ?? '',
                                        //     widget.data?.issueType ?? '',
                                        //     widget.data?.symbol ?? '',
                                        //     context);
                                      },
                                      child: ledgerprovider.loading
                                          ?  SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colors.colorWhite,
                                              ),
                                            )
                                          : TextWidget.subText(
                                              text: "Proceed",
                                              theme: theme.isDarkMode,
                                              fw: 2,
                                              color: colors.colorWhite)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ]),
              ),
            ),
          ));
    });
  }

  String _getTypeLabel(String? issueType) {
    switch (issueType) {
      case 'BB':
      case 'BUYBACK':
        return 'Buyback';
      case 'DLST':
      case 'DS':
        return 'Delisting';
      case 'TAKEOVER':
      case 'TO':
        return 'Takeover';
      case 'IS':
      case 'RS':
        return 'OFS';
      case 'RIGHTS':
        return 'Rights';
      default:
        return issueType ?? '';
    }
  }
}
