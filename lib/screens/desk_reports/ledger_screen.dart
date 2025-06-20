import 'package:flutter/material.dart';
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
          body: TransparentLoaderScreen(
            isLoading: ledgerprovider.ledgerloading,
            child: Column(
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
                      child: Container(
                        decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? const Color(0xffB5C0CF).withOpacity(.15)
                                : const Color(0xffF1F3F8)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget.subText(
                                          text: "Opening Balance",
                                          color: Color(0xFF696969),
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                      // Text(
                                      //   "Opening Balance",
                                      //   style: textStyle(Color(0xFF696969), 14,
                                      //       FontWeight.w500),
                                      // ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextWidget.titleText(
                                            text:
                                                "₹ ${ledgerprovider.ledgerAllData?.openingBalance == 'null' ? '0.00' : (double.tryParse(ledgerprovider.ledgerAllData!.openingBalance ?? '')?.toStringAsFixed(2) ?? '0.00')}",
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 1),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextWidget.subText(
                                          text: "Total Debit",
                                          color: Color(0xFF696969),
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextWidget.titleText(
                                            text:
                                                "₹ ${ledgerprovider.ledgerAllData?.drAmt == 'null' ? '0.00' : (double.tryParse(ledgerprovider.ledgerAllData!.drAmt ?? '')?.toStringAsFixed(2) ?? '0.00')}",
                                            color: Colors.red,
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 16.0, bottom: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget.subText(
                                          text: "Closing Balance  ",
                                          color: Color(0xFF696969),
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextWidget.titleText(
                                            text:
                                                "₹ ${ledgerprovider.ledgerAllData?.closingBalance == 'null' ? '0.00' : (double.tryParse(ledgerprovider.ledgerAllData!.closingBalance ?? '')?.toStringAsFixed(2) ?? '0.00')}",
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 1),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextWidget.subText(
                                          text: "Total Credit",
                                          color: Color(0xFF696969),
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextWidget.titleText(
                                            text:
                                                "₹ ${ledgerprovider.ledgerAllData?.crAmt == 'null' ? '0.00' : (double.tryParse(ledgerprovider.ledgerAllData!.crAmt ?? '')?.toStringAsFixed(2) ?? '0.00')}",
                                            color: Colors.green,
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 1),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                                  fw: 1),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                        : const Color(0xffF1F3F8)),
                                child: Text("${ledgerprovider.startDate}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        11,
                                        FontWeight.w500)),
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
                                  fw: 1),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                        : const Color(0xffF1F3F8)),
                                child: Text("${ledgerprovider.endDate}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        11,
                                        FontWeight.w500)),
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
                                      color: !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(32)))),
                                onPressed: () async {
                                  ledgerprovider.fetchLegerData(
                                      context,
                                      ledgerprovider.startDate,
                                      ledgerprovider.endDate);
                                },
                                child: Text("Get",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
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
                    thickness: 7.0,
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
                            itemCount: ledgerprovider
                                    .ledgerAllData?.fullStat?.length ??
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
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 1),
                                              TextWidget.paraText(
                                                  text:
                                                      " ${dateFormatChangeForLedger(ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE.toString())}",
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: TextWidget.subText(
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
                                                fw: 0),
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
                                              CustomExchBadge(
                                                exch:
                                                    "${ledgerprovider.ledgerAllData!.fullStat![index].cOCD}",
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: Row(
                                              children: [
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: "CL Bal :   ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:
                                                        " ₹${(double.tryParse(ledgerprovider.ledgerAllData!.fullStat![index].nETAMT ?? '')?.toStringAsFixed(2) ?? '0.00')}",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Divider(
                                        color: const Color.fromARGB(
                                            255, 212, 212, 212),
                                        thickness: 0.5,
                                      ),
                                    ),
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
                                            child: Text(
                                              "${ledgerprovider.ledgerAllData!.fullStat![index].nARRATION}",
                                              textAlign: TextAlign
                                                  .start, // Ensures left alignment
                                              style: textStyle(
                                                ledgerprovider
                                                                .ledgerAllData
                                                                ?.fullStat?[
                                                                    index]
                                                                .tYPE ==
                                                            'Bill' &&
                                                        ledgerprovider
                                                                .ledgerAllData
                                                                ?.fullStat?[
                                                                    index]
                                                                .bill ==
                                                            'Yes'
                                                    ? Colors.blue
                                                    : Color(0xFF696969),
                                                12,
                                                FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              // if (index != 0 &&
                              //     ledgerprovider.ledgerAllData!.fullStat![index - 1]
                              //             .vOUCHERDATE ==
                              //         ledgerprovider.ledgerAllData!
                              //             .fullStat![index ].vOUCHERDATE) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 2.0,
                                  bottom: 0.0,
                                ),
                                child: Divider(
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8),
                                  thickness: 7.0,
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
