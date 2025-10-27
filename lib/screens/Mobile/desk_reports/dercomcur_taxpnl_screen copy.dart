import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/thems.dart';

class DercomcurTaxpnl extends StatefulWidget {
  const DercomcurTaxpnl({super.key});

  @override
  State<DercomcurTaxpnl> createState() => DerComCurTaxpnl();
}

class DerComCurTaxpnl extends State<DercomcurTaxpnl> {
  @override
  void initState() {
    setState(() {
      // context.read(ledgerProvider).taxpnlderselectedtab((context.read(ledgerProvider).eqdertabvalue).toString());
      // context.read(ledgerProvider).checkactivetabincur((context.read(ledgerProvider).eqdertabvalue).toString());
    });
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
      double netvalue = (ledgerprovider.calenderpnlAllData!.realized ?? 0.0) -
          (ledgerprovider.calenderpnlAllData!.totalCharges ?? 0.0);

      return Scaffold(
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
                  // height: screenheight * 0.30,
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  margin: EdgeInsets.only(top: 16),
                  child: Card(
                      color: Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Container(
                        width: screenWidth,
                        // height: screenheight,
                        padding: EdgeInsets.only(
                            top: 10, bottom: 25, left: 20, right: 20),
                        margin: EdgeInsets.only(top: 16),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20.0,
                              ),

                              headingstat(
                                  "Long Term Realized P&L ${ledgerprovider.eqdertabvalue}",
                                  "${ledgerprovider.calenderpnlAllData!.realized.toStringAsFixed(2)}"),
                              headingstat("Short Term Realized P&L",
                                  "${ledgerprovider.calenderpnlAllData!.unrealized.toStringAsFixed(2)}"),
                              headingstat("Trading P&L",
                                  "${ledgerprovider.calenderpnlAllData!.totalCharges!.toStringAsFixed(2)}"),
                              headingstat("Assets P&L",
                                  "${netvalue.toStringAsFixed(2)}"),
                              headingstat("Trading Turnover",
                                  "${netvalue.toStringAsFixed(2)}"),
                              headingstat("Total Charges",
                                  "${netvalue.toStringAsFixed(2)}"),

                              //                         NestedScrollView(
                              //   headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                              //     return [
                              //       SliverAppBar(
                              //         expandedHeight: 200.0,
                              //         floating: false,
                              //         pinned: true,
                              //         flexibleSpace: FlexibleSpaceBar(
                              //           title: Text("NestedScrollView Example"),
                              //           background: Image.network(
                              //             "https://source.unsplash.com/random/800x600",
                              //             fit: BoxFit.cover,
                              //           ),
                              //         ),
                              //       ),
                              //     ];
                              //   },
                              //   body: ListView.builder(
                              //     padding: EdgeInsets.all(8.0),
                              //     itemCount: 20,
                              //     itemBuilder: (context, index) {
                              //       return Card(
                              //         child: ListTile(
                              //           title: Text("Item $index"),
                              //         ),
                              //       );
                              //     },
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      )),
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
              padding: const EdgeInsets.only(top: 10.0),
              child: Divider(
                color: const Color.fromARGB(255, 212, 212, 212),
                thickness: 2.0,
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
              padding: const EdgeInsets.only(right: 15, left: 15, bottom: 15.0),
              child: Row(
                children: [
                  tabsbutton(
                    'Future Closed',
                    ledgerprovider,
                    theme,
                  ),
                  tabsbutton('Future Open', ledgerprovider, theme),
                  tabsbutton('Option Closed', ledgerprovider, theme),
                  tabsbutton('Option Open', ledgerprovider, theme),
                ],
              ),
            ),
            // Text("${ledgerprovider.taxpnlderselectedtabdata}data"),
            ledgerprovider.taxpnleq!.data == null
                ? Center(
                    child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: NoDataFound(),
                  ))
                : Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                          controller: ScrollController(),
                          physics: ScrollPhysics(),
                          itemCount: ledgerprovider.taxpnlderselectedtabdata ==
                                  null
                              ? 0
                              : ledgerprovider.taxpnlderselectedtabdata.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 30.0, left: 30.0, top: 25.0),
                                  child: Text(
                                    "${ledgerprovider.taxpnlderselectedtabdata[index]['SCRIP_SYMBOL']}",
                                    style: textStyle(
                                        Colors.black, 14, FontWeight.w700),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 30.0, left: 30.0, top: 10.0),
                                  child: Divider(
                                    color: const Color.fromARGB(
                                        255, 117, 117, 117),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 30.0, left: 30.0, top: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Net Qty : ",
                                            style: textStyle(Color(0xFF696969),
                                                13, FontWeight.w500),
                                          ),
                                          Text(
                                            "${ledgerprovider.taxpnlderselectedtabdata[index]['NETAMT']}",
                                            style: textStyle(Colors.black, 14,
                                                FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 30.0, left: 30.0, top: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Buy Qty : ",
                                            style: textStyle(Color(0xFF696969),
                                                13, FontWeight.w500),
                                          ),
                                          Text(
                                            "${ledgerprovider.taxpnlderselectedtabdata[index]['BUYQTY']}",
                                            style: textStyle(Colors.black, 14,
                                                FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Sell Qty : ",
                                                style: textStyle(
                                                    Color(0xFF696969),
                                                    13,
                                                    FontWeight.w500),
                                              ),
                                              Text(
                                                "${ledgerprovider.taxpnlderselectedtabdata[index]['SALEQTY']}",
                                                style: textStyle(
                                                  Colors.black,
                                                  14,
                                                  FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 30.0, left: 30.0, top: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Buy Rate : ",
                                                style: textStyle(
                                                    Color(0xFF696969),
                                                    13,
                                                    FontWeight.w500),
                                              ),
                                              Text(
                                                "${ledgerprovider.taxpnlderselectedtabdata[index]['BUYRATE']}",
                                                style: textStyle(
                                                  Colors.black,
                                                  14,
                                                  FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Sell Rate : ",
                                                style: textStyle(
                                                    Color(0xFF696969),
                                                    13,
                                                    FontWeight.w500),
                                              ),
                                              Text(
                                                "${ledgerprovider.taxpnlderselectedtabdata[index]['SALERATE']}",
                                                style: textStyle(
                                                  Colors.black,
                                                  14,
                                                  FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Divider(
                                    color: const Color.fromARGB(
                                        255, 212, 212, 212),
                                    thickness: 2.0,
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
          ],
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
    // if (isDerivativesConditionMet || isCommodityConditionMet) {

    return Container(
        height: 35,
        margin: const EdgeInsets.only(right: 12, top: 15),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor:
                    theme.isDarkMode || ledgerprovider.dertypestring != text
                        ? colors.colorbluegrey
                        : colors.colorBlack,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50))),
            onPressed: () {
              setState(() {
                // Ensure UI rebuilds when selection changes
                // ledgerprovider.clickedvalueder = text;
                // ledgerprovider.taxpnlderselectedtab(ledgerprovider.eqdertabvalue.toString());
              });
            },
            child: Text("${text}",
                textAlign: TextAlign.center,
                style: textStyle(
                    !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500))));
    // } else {
    // print("${ledgerprovider.taxpnleq!.data!.aSSETS}");
    // return SizedBox();
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
// }
