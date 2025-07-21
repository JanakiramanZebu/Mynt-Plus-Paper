import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/desk_reports/bottom_sheets/ledger_bill.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/custom_switch_btn.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../utils/no_emoji_inputformatter.dart';
import 'bottom_sheets/ledger_filter.dart';

class LedgerScreen extends StatelessWidget {
  final String ddd;
  const LedgerScreen({super.key, required this.ddd});

  @override
  Widget build(BuildContext context) {
    final List<String> staticColumn = [
      'Row 1',
      'Row 2',
      'Row 3',
      'Row 4',
      'Row 4'
    ];
    final List<String> Header = [
      'Date',
      "Debit",
      "Credit",
      "Net Amount",
      "Details"
    ];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      double crdamount = 0.0;
      double dtamount = 0.0;

      final ledgerprovider = ref.watch(ledgerProvider);
      Future<void> _refresh() async {
        await Future.delayed(Duration(seconds: 0)); // simulate refresh delay
        print("refresh ");
        await ledgerprovider.getCurrentDate('else');
        ledgerprovider.fetchLegerData(
            context, ledgerprovider.startDate, ledgerprovider.endDate);
      }

      String opbalance = ledgerprovider.ledgerAllData?.openingBalance ?? '0.0';
      // String tdebit = ledgerprovider.ledgerAllData?.drAmt ?? '0.0';
      // String tcredit = ledgerprovider.ledgerAllData?.crAmt ?? '0.0';
      String clbalance = ledgerprovider.ledgerAllData?.closingBalance ?? '0.0';

      return RefreshIndicator(
        onRefresh: _refresh,
        child: Scaffold(
          appBar: AppBar(
            // automaticallyImplyLeading: false,
            leadingWidth: 41,
            titleSpacing: 6,
            centerTitle: false,
            leading: InkWell(
              onTap: () {
                ledgerprovider.falseloader('ledger');
              },
              child: const CustomBackBtn(),
            ),
            elevation: 0.2,
            title: TextWidget.heroText(
                text: "Ledger",
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                fw: 1),
            // leading: InkWell(
            //   onTap: () {

            //   },
            //   child: Icon(Icons.ios_share)),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text("${ddd}")
              // Padding(
              //     padding: EdgeInsets.only(left: 4.0, top: 10.0),
              //     child: Text(
              //       "Financial activities through debits and credits ",
              //       style: textStyle(colors.colorBlack, 14, FontWeight.w600),
              //     )),
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextWidget.paraText(
                                      text: "Balance  ",
                                      color: Color(0xFF696969),
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 3),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: TextWidget.subText(
                                        text: ledgerprovider.ledgerAllData
                                                    ?.closingBalance ==
                                                'null'
                                            ? '0.00'
                                            : (double.tryParse(ledgerprovider
                                                            .ledgerAllData
                                                            ?.closingBalance ??
                                                        '')
                                                    ?.toStringAsFixed(2) ??
                                                '0.00'),
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(14.0),
                  //     child: TextField(

                  //       decoration: InputDecoration(
                  //         filled: true,
                  //          fillColor: const Color(0xffF1F3F8),
                  //       hintText: "Search",
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(30.0),
                  //         ),
                  //         focusedBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(30.0),
                  //           borderSide: BorderSide(color:  Colors.grey, width: 2.0),
                  //         ),
                  //         enabledBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(30.0),
                  //           borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  //         ),
                  //         contentPadding: EdgeInsets.symmetric(
                  //           horizontal: 20.0,
                  //           vertical: 15.0,
                  //         ),
                  //         prefixIconColor: const Color(0xff586279),
                  //         prefixIcon: SvgPicture.asset(
                  //           "assets/icon/appbarIcon/search.svg",
                  //           color: const Color(0xff586279),
                  //           fit: BoxFit.scaleDown,
                  //           width: 14,
                  //           height: 14,
                  //         ),
                  //       ),
                  //     ),
                  //   ),

                  // ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Divider(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8),
                  thickness: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    right: 16.0, left: 16.0, top: 16.0, bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          ledgerprovider.datePickerStart(context, theme);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.paraText(
                                text: "Start Date",
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 3),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8)),
                              child: Text("${ledgerprovider.startDate}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      11,
                                      FontWeight.w400)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          ledgerprovider.datePickerEnd(context, theme);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.paraText(
                                text: "End Date",
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 3),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8)),
                              child: Text("${ledgerprovider.endDate}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      11,
                                      FontWeight.w400)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                      child: SizedBox(
                          height: 27,
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5)))),
                              onPressed: () async {
                                ledgerprovider.fetchLegerData(
                                    context,
                                    ledgerprovider.startDate,
                                    ledgerprovider.endDate);
                              },
                              child: Text("Get",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.primaryDark
                                          : colors.primaryLight,
                                      12,
                                      FontWeight.w600)))),
                    ),
                    InkWell(
                        onTap: () async {
                          ledgerprovider.setfilterpage = 'ledger';
                          _showBottomSheet(context, LedgerFilter());
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SvgPicture.asset(assets.filterLines,
                              color: theme.isDarkMode
                                  ? const Color(0xffBDBDBD)
                                  : colors.colorGrey),
                        )),
                    SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 14.0),
                      child: IconButton(
                        iconSize: 20,
                        icon: Icon(Icons.download,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack),
                        onPressed: () => {
                          ledgerprovider.pdfdownloadforledger(
                              context,
                              ledgerprovider.ledgerAllData?.toJson() ?? {},
                              ledgerprovider.ledgerAllData?.drAmt ?? '0.00',
                              ledgerprovider.ledgerAllData?.crAmt ?? '0.00',
                              ledgerprovider.ledgerAllData?.closingBalance ??
                                  '0.00',
                              ledgerprovider.ledgerAllData?.openingBalance ??
                                  '0.00',
                              ledgerprovider.startDate,
                              ledgerprovider.endDate),
                        },
                      ),
                    ),
                  ],
                ),
              ),

              ledgerprovider.showLedgerSearch ? 

              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 10, bottom: 8),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: colors.searchBg,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      splashColor: theme.isDarkMode
                                          ? colors.splashColorDark
                                          : colors.splashColorLight,
                                      highlightColor: theme.isDarkMode
                                          ? colors.highlightDark
                                          : colors.highlightLight,
                                      onTap: () {
                                        Future.delayed(const Duration(milliseconds: 150),
                                            () {
                                          // positionBook.showPositionSearch(true);
                                          ledgerprovider.showledgerSearch(false);
                                        });
                                        
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgPicture.asset(
                                          assets.searchIcon,
                                          color: colors.textPrimaryLight,
                                          width: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      splashColor: theme.isDarkMode
                                          ? colors.splashColorDark
                                          : colors.splashColorLight,
                                      highlightColor: theme.isDarkMode
                                          ? colors.highlightDark
                                          : colors.highlightLight,
                                      onTap: () {
                                        ledgerprovider.setfilterpage = 'ledger';
                                        _showBottomSheet(
                                            context, LedgerFilter());
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgPicture.asset(
                                          assets.filterLinesDark,
                                          color: colors.textPrimaryLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // TextButton(
                    //     onPressed: () {
                    //       positionBook.showPositionSearch(false);
                    //     },
                    //     child: TextWidget.paraText(
                    //         text: "Close",
                    //         theme: false,
                    //         color: theme.isDarkMode
                    //             ? colors.colorLightBlue
                    //             : colors.colorBlue,
                    //         fw: 0))
                  ],
                ),
              ) : Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: SizedBox(
          height: 40,
          child: TextFormField(
            autofocus: true,
            controller: ledgerprovider.ledgerSearchCtrl,
            style: TextWidget.textStyle(
              fontSize: 14,
              theme: theme.isDarkMode,
              fw: 1,
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              UpperCaseTextFormatter(),
              NoEmojiInputFormatter(),
              FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
            ],
            decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextWidget.textStyle(
                    fontSize: 14,
                    theme: theme.isDarkMode,
                    fw: 0,
                    color: colors.textSecondaryLight),
                fillColor: colors.searchBg,
                filled: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(assets.searchIcon,
                      color: colors.textPrimaryLight,
                      fit: BoxFit.scaleDown,
                      width: 20),
                ),
                suffixIcon: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    splashColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    highlightColor: theme.isDarkMode
                        ? colors.highlightDark
                        : colors.highlightLight,
                    onTap: () async {
                      Future.delayed(const Duration(milliseconds: 150), () {
                        FocusScope.of(context).unfocus();
                        ledgerprovider.clearLedgerSearch();                     
                           ledgerprovider.showledgerSearch(true);
                        
                      });
                    },
                    child: SvgPicture.asset(assets.removeIcon,
                        fit: BoxFit.scaleDown, width: 20),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20)),
                disabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20))),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // positionBook.showPositionSearch(false);
              } else {
                // positionBook.showPositionSearch(false);
              }

              ledgerprovider.ledgerSearch(value, context);
            },
          ),
        ),
      ),

              Padding(
                padding:
                    const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget.subText(
                              text: "Bill Margin  :",
                              textOverflow: TextOverflow.ellipsis,
                              theme: theme.isDarkMode,
                              fw: 3),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextWidget.paraText(
                                    text: "Yes",
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 3),
                                const SizedBox(width: 10),
                                CustomSwitch(
                                    onChanged: (bool value) {
                                      ledgerprovider.billnotbill(value);
                                      print("${value}");
                                    },
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                        : const Color(0xffF1F3F8),
                                    value: ledgerprovider.billmargin),
                                const SizedBox(width: 10),
                                TextWidget.paraText(
                                    text: "No",
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 30 , right: 30),
              //   child: Row(
              //     children: [
              //       // Static Column
              //       Column(
              //         children: [
              //           Container(
              //             margin: EdgeInsets.only(top: 20),
              //             width: 100,
              //             color: Colors
              //                 .cardbgrey, // Header cell for the static column
              //             padding: EdgeInsets.all(8.0),
              //             child: Text(
              //               'Exchange',
              //               style: TextStyle(fontWeight: FontWeight.bold),
              //             ),
              //           ),
              //           for (var item in ledgerprovider.ledgerAllData!.fullStat!)
              //             Container(
              //               width: 100, // Fixed width for the static column
              //               height: 50,

              //               padding: EdgeInsets.all(8.0),
              //               decoration: BoxDecoration(
              //                 border: Border.all(color: const Color.fromARGB(255, 224, 224, 224)),
              //               ),
              //               child: Text("${item.cOCD}",
              //               style: textStyle(Colors.black, 14, FontWeight.w600),
              //               ),
              //             ),
              //         ],
              //       ),
              //       // Scrollable Content

              //       Expanded(
              //         child: SingleChildScrollView(
              //           scrollDirection: Axis.horizontal,
              //           child: Column(
              //             children: [
              //               // Header Row for the scrollable content
              //               Row(
              //                 children: [
              //                   for (int i = 0; i < Header.length; i++)
              //                     Container(
              //                        margin: EdgeInsets.only(top: 20),
              //                       width: i == 4 ? 275 : 100, // Column width

              //                       padding: EdgeInsets.all(8.0),
              //                       color: Color(0xFFEEEEEE),
              //                       child: Text(
              //                         '${Header[i]}',
              //                         style:
              //                             TextStyle(fontWeight: FontWeight.bold),
              //                       ),
              //                     ),
              //                 ],
              //               ),
              //               // Data Rows for the scrollable content
              //               for (int rowIndex = 0;
              //                   rowIndex <
              //                       ledgerprovider
              //                           .ledgerAllData!.fullStat!.length;
              //                   rowIndex++)
              //                 Row(
              //                   children: [
              //                     for (int colIndex = 0; colIndex < 5; colIndex++)
              //                       Container(
              //                          width: colIndex == 4 ? 275 : 100,  // Column width
              //                         height: 50,
              //                         padding: EdgeInsets.all(8.0),
              //                         decoration: BoxDecoration(
              //                           border: Border.all(color: Color.fromARGB(255, 224, 224, 224)),
              //                         ),
              //                         child: Text(colIndex == 0 ? dateFormatChangeForLedger(ledgerprovider
              //                             .tablearray[rowIndex][colIndex]) : ledgerprovider
              //                             .tablearray[rowIndex][colIndex] ,
              //                             textAlign: colIndex == 1 ||colIndex == 2 || colIndex == 3  ? TextAlign.right : TextAlign.start ,
              //                             ) ,
              //                         //  child: Text(  ledgerprovider
              //                         //     .tablearray[rowIndex][colIndex] ) ,
              //                       ),
              //                   ],
              //                 ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Divider(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8),
                  thickness: 1.0,
                ),
              ),
              ledgerprovider.ledgerAllData?.fullStat?.isEmpty ?? true
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: NoDataFound(),
                    ))
                  : Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ListView.separated(
                          physics: ScrollPhysics(),
                          itemCount:
                              ledgerprovider.ledgerAllData?.fullStat?.length ??
                                  0,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async {
                                if (ledgerprovider.ledgerAllData
                                            ?.fullStat?[index].tYPE ==
                                        'Bill' &&
                                    ledgerprovider.ledgerAllData
                                            ?.fullStat?[index].bill ==
                                        'Yes') {
                                  final ledgerEntry = ledgerprovider
                                      .ledgerAllData?.fullStat?[index];

                                  if (ledgerEntry != null) {
                                    await ledgerprovider.fetchBillDetails(
                                      context,
                                      ledgerEntry.sETTLEMENTNO ?? '',
                                      ledgerEntry.mKTTYPE ?? '',
                                      ledgerEntry.cOCD ?? '',
                                      dateFormatChangeForLedger(
                                          ledgerEntry.vOUCHERDATE ?? ''),
                                    );
                                    _showBottomSheet(
                                      context,
                                      const LedgerBillBottom(),
                                    );
                                  }
                                } else {}
                              },
                              child: Column(
                                children: [
                                  // if (index != 0 &&
                                  //     ledgerprovider.ledgerAllData!
                                  //             .fullStat![index].vOUCHERDATE !=
                                  //         ledgerprovider
                                  //             .ledgerAllData!
                                  //             .fullStat![index - 1]
                                  //             .vOUCHERDATE) ...[
                                  //   Card(
                                  //     elevation: 0.0,
                                  //     color: theme.isDarkMode
                                  //         ? const Color(0xffB5C0CF)
                                  //             .withOpacity(.15)
                                  //         : const Color(0xffF1F3F8),
                                  //     child: Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.start,
                                  //       children: [
                                  //         Padding(
                                  //           padding: const EdgeInsets.all(8.0),
                                  //           child: Text(
                                  //               "${index == 0 ? dateFormatChangeForLedger(ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE.toString()) : ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE == ledgerprovider.ledgerAllData!.fullStat![index - 1].vOUCHERDATE ? '' : dateFormatChangeForLedger(ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE.toString())}",
                                  //               style: textStyle(
                                  //                   theme.isDarkMode
                                  //                       ? colors.colorWhite
                                  //                       : colors.colorBlack,
                                  //                   14,
                                  //                   FontWeight.w600)),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ],
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            TextWidget.subText(
                                                text:
                                                    "${ledgerprovider.ledgerAllData!.fullStat![index].tYPE} ",
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                            TextWidget.paraText(
                                                text:
                                                    " ${dateFormatChangeForLedger(ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE.toString())}",
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: TextWidget.paraText(
                                              align: TextAlign.right,
                                              text: ledgerprovider
                                                          .ledgerAllData!
                                                          .fullStat![index]
                                                          .cRAMT !=
                                                      "0.0"
                                                  ? "₹+${(double.tryParse(ledgerprovider.ledgerAllData!.fullStat![index].cRAMT ?? '')?.toStringAsFixed(2) ?? '0.00')}"
                                                  : " ₹-${ledgerprovider.ledgerAllData!.fullStat![index].dRAMT}  ",
                                              color: ledgerprovider
                                                          .ledgerAllData!
                                                          .fullStat![index]
                                                          .cRAMT !=
                                                      "0.0"
                                                  ? Colors.green
                                                  : Colors.red,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            // CustomExchBadge(exch: "${ledgerprovider.ledgerAllData!.fullStat![index].tYPE}",),
                                            TextWidget.paraText(
                                                align: TextAlign.right,
                                                text:
                                                    "${ledgerprovider.ledgerAllData!.fullStat![index].cOCD}",
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: Row(
                                            children: [
                                              TextWidget.paraText(
                                                  align: TextAlign.right,
                                                  text: "CL Bal : ",
                                                  color: theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors
                                                          .textSecondaryLight,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 3),
                                              TextWidget.paraText(
                                                  align: TextAlign.right,
                                                  text:
                                                      " ₹${(double.tryParse(ledgerprovider.ledgerAllData!.fullStat![index].nETAMT ?? '')?.toStringAsFixed(2) ?? '0.00')}",
                                                  color: theme.isDarkMode
                                                      ? colors.textPrimaryDark
                                                      : colors.textPrimaryLight,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 3),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 2.0,
                                        bottom: 4.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Ensures left alignment
                                      mainAxisSize: MainAxisSize
                                          .min, // Prevents unnecessary centering
                                      children: [
                                        Align(
                                          alignment: Alignment
                                              .centerLeft, // Forces text to the left
                                          child: TextWidget.captionText(
                                              align: TextAlign.start,
                                              maxLines: 5,
                                              text:
                                                  "${ledgerprovider.ledgerAllData!.fullStat![index].nARRATION}",
                                              color: ledgerprovider
                                                              .ledgerAllData
                                                              ?.fullStat?[index]
                                                              .tYPE ==
                                                          'Bill' &&
                                                      ledgerprovider
                                                              .ledgerAllData
                                                              ?.fullStat?[index]
                                                              .bill ==
                                                          'Yes'
                                                  ? theme.isDarkMode
                                                      ? colors.primaryDark
                                                      : colors.primaryLight
                                                  : theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors
                                                          .textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            // if (index != 0 &&
                            //     ledgerprovider.ledgerAllData!.fullStat![index - 1]
                            //             .vOUCHERDATE ==
                            //         ledgerprovider.ledgerAllData!
                            //             .fullStat![index ].vOUCHERDATE) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 4.0,
                                bottom: 0.0,
                              ),
                              child: Divider(
                                color: theme.isDarkMode
                                    ? const Color(0xffB5C0CF).withOpacity(.15)
                                    : const Color(0xffF1F3F8),
                                thickness: 1.0,
                              ),
                            );
                            // }else{
                            // return SizedBox();
                            // }
                          },
                        ),
                      ),
                    )
            ],
          ),
        ),
      );
    });
  }

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: bottomSheet));
  }
}
