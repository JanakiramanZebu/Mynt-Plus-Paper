import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/Mobile/desk_reports/bottom_sheets/ledger_bill.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import 'bottom_sheets/ledger_filter.dart';

class Tradebook extends StatelessWidget {
  final String ddd;
  const Tradebook({super.key, required this.ddd});

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
    final List<List<String>> scrollableContent = [
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
      ['Data 1.1', 'Data 1.2', 'Data 1.3', 'Data 1.3', 'Data 1.3'],
    ];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);

      final ledgerprovider = ref.watch(ledgerProvider);

      Future<void> _refresh() async {
        await Future.delayed(Duration(seconds: 0)); // simulate refresh delay
        print("refresh ");
        await ledgerprovider.getCurrentDate('tradebook');
        ledgerprovider.fetchtradebookdata(
            context, ledgerprovider.startDate, ledgerprovider.today);
      }

      return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: InkWell(
            onTap: () {
              ledgerprovider.falseloader('tradebook');
            },
            child: const CustomBackBtn(),
          ),
          elevation: 0.2,
          title: TextWidget.heroText(
              text: "TradeBook",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 1),

          // leading: InkWell(
          //   onTap: () {

          //   },
          //   child: Icon(Icons.ios_share)),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: TransparentLoaderScreen(
            isLoading: ledgerprovider.tradebookloading,
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

                Padding(
                  padding:
                      const EdgeInsets.only(right: 30.0, left: 30.0, top: 8.0),
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
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8),
                                ),
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
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8),
                                ),
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
                                  ledgerprovider.fetchtradebookdata(
                                      context,
                                      ledgerprovider.startDate,
                                      ledgerprovider.today);
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
                            ledgerprovider.setfilterpage = 'tradebook';

                            _showBottomSheet(context, LedgerFilter());
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: SvgPicture.asset(assets.filterLines,
                                color: theme.isDarkMode
                                    ? const Color(0xffBDBDBD)
                                    : colors.colorGrey),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 2.0,
                    bottom: 0.0,
                  ),
                  child: Divider(
                    color: theme.isDarkMode
                        ? const Color(0xffB5C0CF).withOpacity(.15)
                        : const Color(0xffF1F3F8),
                    thickness: 1.0,
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

                ledgerprovider.tradebookdata == null ||
                        ledgerprovider.tradebookdata?.trades == null ||
                        ledgerprovider.tradebookdata!.trades!.isEmpty
                    // Handle the null or empty case

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
                                ledgerprovider.tradebookdata?.trades?.length ??
                                    0,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final value =
                                  ledgerprovider.tradebookdata!.trades![index];
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.subText(
                                                    text: "${value.sCRIPNAME} ",
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    fw: 3),
                                                TextWidget.paraText(
                                                    text:
                                                        "${value.sTRIKEPRICE} ",
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                                TextWidget.paraText(
                                                    text:
                                                        "${value.oPTIONTYPE} ",
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                                TextWidget.paraText(
                                                    text:
                                                        "${value.eXPIRYDATE} ",
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Row(
                                                children: [
                                                  TextWidget.captionText(
                                                      text:
                                                          "${value.cOMPANYCODE}",
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                  TextWidget.captionText(
                                                      text:
                                                          "${value.tRADENUMBER}",
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            // Text((ledgerprovider
                                            //               .ledgerAllData!
                                            //               .fullStat![index]
                                            //               .cRAMT) !=
                                            //           "0.0"
                                            //       ? "Credit : "
                                            //       : "Debit : ",
                                            //     style: textStyle(
                                            //         theme.isDarkMode
                                            //             ? colors.colorWhite
                                            //             : Color(0xFF696969),
                                            //         14,
                                            //         FontWeight.w500)),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16.0),
                                              child: TextWidget.paraText(
                                                  text: "${value.showtype}",
                                                  color: value.showtype == "BUY"
                                                      ? Colors.green
                                                      : Colors.red,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 3),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16.0,top: 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Trade Date : ",
                                                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                                TextWidget.paraText(
                                                    text: "${value.tRADEDATE}",
                                                     color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors.textPrimaryLight,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            TextWidget.paraText(
                                                text: "Qty :  ",
                                                 color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                            TextWidget.paraText(
                                                text:
                                                    "${double.tryParse(value.showqnt.toString())!.toInt()}",
                                                 color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors.textPrimaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),

                                            //         Text(
                                            // " (${value.tRADEDATE})",
                                            // style: textStyle(
                                            //     theme.isDarkMode
                                            //         ? colors.colorWhite
                                            //         : colors.colorBlack,
                                            //     12,
                                            //     FontWeight.w600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16.0, top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            TextWidget.paraText(
                                                text: "Amount :  ",
                                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                            TextWidget.paraText(
                                                // text:  "₹ ${value.showamt}",
                                                text:
                                                    "${(double.tryParse(value.showamt ?? '')?.toStringAsFixed(2) ?? '0.00')}",
                                                 color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors.textPrimaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),

                                            //         Text(
                                            // " (${value.tRADEDATE})",
                                            // style: textStyle(
                                            //     theme.isDarkMode
                                            //         ? colors.colorWhite
                                            //         : colors.colorBlack,
                                            //     12,
                                            //     FontWeight.w600)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Price :  ",
                                                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                                TextWidget.paraText(
                                                    // text:  "₹ ${value.showprice}",
                                                    text:
                                                        "${(double.tryParse(value.showprice ?? '')?.toStringAsFixed(2) ?? '0.00')}",
                                                     color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors.textPrimaryLight,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 2.0, 
                                ),
                                child: Divider(
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8),
                                  thickness: 1.0,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
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
