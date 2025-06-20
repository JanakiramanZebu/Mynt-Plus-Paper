import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/thems.dart';

class curTaxpnl extends StatefulWidget {
  const curTaxpnl({super.key});

  @override
  State<curTaxpnl> createState() => curTaxpnlScreen();
}

class curTaxpnlScreen extends State<curTaxpnl> {
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

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
      final eqtypestring = ref.watch(ledgerProvider).eqtypestring;
      final dertypestring = ref.watch(ledgerProvider).dertypestring;
      final ledgerprovider = ref.watch(ledgerProvider);

      return Scaffold(
        body: TransparentLoaderScreen(
          isLoading: ledgerprovider.taxderloading,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Futures",
                                  style: textStyle(
                                      Color(0xFF696969), 14, FontWeight.w500),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    double.parse(ledgerprovider.taxpnldercomcur!
                                            .data!.currency!.currFutPnl!)
                                        .toStringAsFixed(2),
                                    style: textStyle(
                                        (ledgerprovider.taxpnldercomcur!.data!
                                                    .currency!.currFutPnl !=
                                                null)
                                            ? (double.parse(ledgerprovider
                                                        .taxpnldercomcur!
                                                        .data!
                                                        .currency!
                                                        .currFutPnl!) >
                                                    0
                                                ? Colors.green
                                                : double.parse(ledgerprovider
                                                            .taxpnldercomcur!
                                                            .data!
                                                            .currency!
                                                            .currFutPnl!) <
                                                        0
                                                    ? Colors.red
                                                    : Colors.black)
                                            : Colors.black,
                                        16,
                                        FontWeight.w600),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Futures Turnover",
                                  textAlign: TextAlign.right,
                                  style: textStyle(
                                      Color(0xFF696969), 14, FontWeight.w500),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '0.0',
                                    style: textStyle(
                                        (ledgerprovider.taxpnldercomcur!.data!
                                                    .currency!.currFutTo !=
                                                null)
                                            ? (double.parse(ledgerprovider
                                                        .taxpnldercomcur!
                                                        .data!
                                                        .currency!
                                                        .currFutTo!) >
                                                    0
                                                ? Colors.green
                                                : double.parse(ledgerprovider
                                                            .taxpnldercomcur!
                                                            .data!
                                                            .currency!
                                                            .currFutTo!) <
                                                        0
                                                    ? Colors.red
                                                    : Colors.black)
                                            : Colors.black,
                                        16,
                                        FontWeight.w600),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 18.0, right: 18.0, top: 4.0, bottom: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Options",
                                  style: textStyle(
                                      Color(0xFF696969), 14, FontWeight.w500),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    double.parse(ledgerprovider.taxpnldercomcur!
                                            .data!.currency!.currOptPnl!)
                                        .toStringAsFixed(2),
                                    textAlign: TextAlign.right,
                                    style: textStyle(
                                        (ledgerprovider.taxpnldercomcur!.data!
                                                    .currency!.currOptPnl !=
                                                null)
                                            ? (double.parse(ledgerprovider
                                                        .taxpnldercomcur!
                                                        .data!
                                                        .currency!
                                                        .currOptPnl!) >
                                                    0
                                                ? Colors.green
                                                : double.parse(ledgerprovider
                                                            .taxpnldercomcur!
                                                            .data!
                                                            .currency!
                                                            .currOptPnl!) <
                                                        0
                                                    ? Colors.red
                                                    : Colors.black)
                                            : Colors.black,
                                        16,
                                        FontWeight.w600),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Options Turnover",
                                  textAlign: TextAlign.right,
                                  style: textStyle(
                                      Color(0xFF696969), 14, FontWeight.w500),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    double.parse(ledgerprovider.taxpnldercomcur!
                                            .data!.currency!.currOptTo!)
                                        .toStringAsFixed(2),
                                    textAlign: TextAlign.right,
                                    style: textStyle(
                                        (ledgerprovider.taxpnldercomcur!.data!
                                                    .derivatives!.derFutPnl !=
                                                null)
                                            ? (double.parse(ledgerprovider
                                                        .taxpnldercomcur!
                                                        .data!
                                                        .currency!
                                                        .currOptTo!) >
                                                    0
                                                ? Colors.green
                                                : double.parse(ledgerprovider
                                                            .taxpnldercomcur!
                                                            .data!
                                                            .currency!
                                                            .currOptTo!) <
                                                        0
                                                    ? Colors.red
                                                    : Colors.black)
                                            : Colors.black,
                                        16,
                                        FontWeight.w600),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 18.0, right: 18.0, top: 4.0, bottom: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Charges",
                                  style: textStyle(
                                      Color(0xFF696969), 14, FontWeight.w500),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '0.0',
                                    textAlign: TextAlign.right,
                                    style: textStyle(
                                        Colors.red, 16, FontWeight.w600),
                                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, color: Colors.black),
                    onPressed: () => {
                      ledgerprovider.fetchtaxpnleqdata(
                          context, ledgerprovider.yearforTaxpnl - 1)
                    },
                  ),
                  // Center(
                  //   child: Container(
                  //     width: screenWidth * 0.5,
                  //     alignment: Alignment.centerLeft,
                  //     padding: const EdgeInsets.symmetric(
                  //         vertical: 10, horizontal: 10),
                  //     decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(30),
                  //         color: theme.isDarkMode
                  //             ? const Color(0xffB5C0CF).withOpacity(.15)
                  //             : const Color(0xffF1F3F8)),
                  //     child: Center(
                  //       child:
                  Text("${ledgerprovider.yearforTaxpnl}",
                      textAlign: TextAlign.right,
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w500)),

                  //     ),
                  //   ),
                  // ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, color: Colors.black),
                    onPressed: () => {
                      ledgerprovider.fetchtaxpnleqdata(
                          context, ledgerprovider.yearforTaxpnl + 1)
                    },
                  ),
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 10.0),
              //   child: Divider(
              //     color: const Color.fromARGB(255, 212, 212, 212),
              //     thickness: 2.0,
              //   ),
              // ),

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
              // Padding(
              //   padding:
              //       const EdgeInsets.only(right: 15, left: 15, bottom: 15.0),
              //   child: SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     child: Row(
              //       children: [
              //         tabsbutton(
              //           'Future Closed',
              //           ledgerprovider,
              //           theme,
              //         ),
              //         tabsbutton('Future Open', ledgerprovider, theme),
              //         tabsbutton('Option Closed', ledgerprovider, theme),
              //         tabsbutton('Option Open', ledgerprovider, theme),
              //       ],
              //     ),
              //   ),
              // ),
              // Text("${ledgerprovider.taxpnlcurselectedtabdata}data"),
              // ledgerprovider.taxpnleq!.data == null
              //     ? Center(
              //         child: Padding(
              //         padding: EdgeInsets.only(top: 60),
              //         child: NoDataFound(),
              //       ))
              //     : Expanded(
              //         child: SingleChildScrollView(
              //           child: ListView.builder(
              //               controller: ScrollController(),
              //               physics: ScrollPhysics(),
              //               itemCount:
              //                   ledgerprovider.taxpnlcurselectedtabdata == null
              //                       ? 0
              //                       : ledgerprovider
              //                           .taxpnlcurselectedtabdata.length,
              //               shrinkWrap: true,
              //               itemBuilder: (context, index) {
              //                 return Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     Padding(
              //                       padding: const EdgeInsets.only(
              //                           right: 30.0, left: 30.0, top: 25.0),
              //                       child: Text(
              //                         "${ledgerprovider.taxpnlcurselectedtabdata[index]['SCRIP_SYMBOL']}",
              //                         style: textStyle(
              //                             Colors.black, 14, FontWeight.w700),
              //                       ),
              //                     ),
              //                     Padding(
              //                       padding: const EdgeInsets.only(
              //                           right: 30.0, left: 30.0, top: 10.0),
              //                       child: Divider(
              //                         color: const Color.fromARGB(
              //                             255, 117, 117, 117),
              //                       ),
              //                     ),
              //                     Padding(
              //                       padding: const EdgeInsets.only(
              //                           right: 30.0, left: 30.0, top: 10.0),
              //                       child: Row(
              //                         mainAxisAlignment:
              //                             MainAxisAlignment.spaceBetween,
              //                         children: [
              //                           Row(
              //                             children: [
              //                               Text(
              //                                 "Net Qty : ",
              //                                 style: textStyle(
              //                                     Color(0xFF696969),
              //                                     13,
              //                                     FontWeight.w500),
              //                               ),
              //                               Text(
              //                                 "${ledgerprovider.taxpnlcurselectedtabdata[index]['NETAMT']}",
              //                                 style: textStyle(Colors.black, 14,
              //                                     FontWeight.w500),
              //                               ),
              //                             ],
              //                           ),
              //                         ],
              //                       ),
              //                     ),
              //                     Padding(
              //                       padding: const EdgeInsets.only(
              //                           right: 30.0, left: 30.0, top: 10.0),
              //                       child: Row(
              //                         mainAxisAlignment:
              //                             MainAxisAlignment.spaceBetween,
              //                         children: [
              //                           Row(
              //                             children: [
              //                               Text(
              //                                 "Buy Qty : ",
              //                                 style: textStyle(
              //                                     Color(0xFF696969),
              //                                     13,
              //                                     FontWeight.w500),
              //                               ),
              //                               Text(
              //                                 "${ledgerprovider.taxpnlcurselectedtabdata[index]['BUYQTY']}",
              //                                 style: textStyle(Colors.black, 14,
              //                                     FontWeight.w500),
              //                               ),
              //                             ],
              //                           ),
              //                           Row(
              //                             children: [
              //                               Row(
              //                                 children: [
              //                                   Text(
              //                                     "Sell Qty : ",
              //                                     style: textStyle(
              //                                         Color(0xFF696969),
              //                                         13,
              //                                         FontWeight.w500),
              //                                   ),
              //                                   Text(
              //                                     "${ledgerprovider.taxpnlcurselectedtabdata[index]['SALEQTY']}",
              //                                     style: textStyle(
              //                                       Colors.black,
              //                                       14,
              //                                       FontWeight.w500,
              //                                     ),
              //                                   ),
              //                                 ],
              //                               ),
              //                             ],
              //                           ),
              //                         ],
              //                       ),
              //                     ),
              //                     Padding(
              //                       padding: const EdgeInsets.only(
              //                           right: 30.0, left: 30.0, top: 10.0),
              //                       child: Row(
              //                         mainAxisAlignment:
              //                             MainAxisAlignment.spaceBetween,
              //                         children: [
              //                           Row(
              //                             children: [
              //                               Row(
              //                                 children: [
              //                                   Text(
              //                                     "Buy Rate : ",
              //                                     style: textStyle(
              //                                         Color(0xFF696969),
              //                                         13,
              //                                         FontWeight.w500),
              //                                   ),
              //                                   Text(
              //                                     "${ledgerprovider.taxpnlcurselectedtabdata[index]['BUYRATE']}",
              //                                     style: textStyle(
              //                                       Colors.black,
              //                                       14,
              //                                       FontWeight.w500,
              //                                     ),
              //                                   ),
              //                                 ],
              //                               ),
              //                             ],
              //                           ),
              //                           Row(
              //                             children: [
              //                               Row(
              //                                 children: [
              //                                   Text(
              //                                     "Sell Rate : ",
              //                                     style: textStyle(
              //                                         Color(0xFF696969),
              //                                         13,
              //                                         FontWeight.w500),
              //                                   ),
              //                                   Text(
              //                                     "${ledgerprovider.taxpnlcurselectedtabdata[index]['SALERATE']}",
              //                                     style: textStyle(
              //                                       Colors.black,
              //                                       14,
              //                                       FontWeight.w500,
              //                                     ),
              //                                   ),
              //                                 ],
              //                               ),
              //                             ],
              //                           ),
              //                         ],
              //                       ),
              //                     ),
              //                     Padding(
              //                       padding: const EdgeInsets.only(top: 10),
              //                       child: Divider(
              //                         color: const Color.fromARGB(
              //                             255, 212, 212, 212),
              //                         thickness: 2.0,
              //                       ),
              //                     ),
              //                   ],
              //                 );
              //               }),
              //         ),
              //       ),
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Center(
                  child: Column(children: [
                    // SvgPicture.asset(assets.noDatafound,
                    //     color: theme.isDarkMode
                    //         ? colors.darkColorDivider
                    //         : colors.colorDivider),
                    // const SizedBox(height: 2),
                    IconButton(
                      icon: Icon(Icons.download, color: Colors.black),
                      onPressed: () => {},
                    ),
                    Text("Here you can download your ",
                        style: textStyle(
                            const Color(0xff777777), 14, FontWeight.w500)),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("Tax p&l data",
                          style: textStyle(Color.fromARGB(255, 119, 119, 119),
                              14, FontWeight.w500)),
                    )
                  ]),
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

  tabsbutton(String text, LDProvider ledgerprovider, ThemesProvider theme) {
    if ((ledgerprovider.taxpnldercomcur?.data?.currency?.currFutBooked
                    ?.isNotEmpty ==
                true &&
            text == "Future Closed") ||
        (ledgerprovider
                    .taxpnldercomcur?.data?.currency?.currFutOpen?.isNotEmpty ==
                true &&
            text == "Future Open") ||
        (ledgerprovider.taxpnldercomcur?.data?.currency?.currOptBooked
                    ?.isNotEmpty ==
                true &&
            text == "Option Closed") ||
        (ledgerprovider
                    .taxpnldercomcur?.data?.currency?.currOptOpen?.isNotEmpty ==
                true &&
            text == "Option Open")) {
      return Container(
          height: 35,
          margin: const EdgeInsets.only(right: 12, top: 15),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor:
                      theme.isDarkMode || ledgerprovider.curtypestring != text
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              onPressed: () {
                setState(() {
                  // Ensure UI rebuilds when selection changes
                  ledgerprovider.clickedvaluecur = text;
                  ledgerprovider.taxpnlcurselectedtab();
                });
              },
              child: Text("${text}",
                  textAlign: TextAlign.center,
                  style: textStyle(
                      !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w500))));
    } else {
      print("${ledgerprovider.taxpnleq!.data!.aSSETS}");
      return SizedBox();
    }
  }

  headingstat(String heading, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${heading}",
            style: textStyle(Color(0xFF696969), 14, FontWeight.w400),
          ),
          Text(
            "${value}",
            style: textStyle(colors.colorBlack, 13, FontWeight.w500),
          )
        ],
      ),
    );
  }
}
