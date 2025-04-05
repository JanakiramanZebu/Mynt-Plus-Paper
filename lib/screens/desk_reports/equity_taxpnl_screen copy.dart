import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/desk_reports/bottom_sheets/ledger_bill.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/thems.dart';
import 'bottom_sheets/ledger_filter.dart';

class EqTaxpnlEq2 extends StatefulWidget {
  const EqTaxpnlEq2({super.key});

  @override
  State<EqTaxpnlEq2> createState() => EqTaxpnl();
}

class EqTaxpnl extends State<EqTaxpnlEq2> {
  @override
  Widget build(BuildContext context) {
    final Map<String, bool> _expandedPanels = {};

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
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);

      final ledgerprovider = watch(ledgerProvider);
       

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
                  height: screenheight * 0.30,
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  margin: EdgeInsets.only(top: 16),
                  child: Card(
                      color: Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Container(
                        width: screenWidth,
                        height: screenheight,
                        padding: EdgeInsets.only(
                            top: 10, bottom: 25, left: 20, right: 20),
                        margin: EdgeInsets.only(top: 16),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 30, left: 20, right: 20, bottom: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Realised P&L",
                                      style: textStyle(Color(0xFF696969), 14,
                                          FontWeight.w400),
                                    ),
                                    Text(
                                      "${ledgerprovider.calenderpnlAllData!.realized}",
                                      style: textStyle(colors.colorBlack, 13,
                                          FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
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
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Unrealised P&L",
                                      style: textStyle(Color(0xFF696969), 14,
                                          FontWeight.w400),
                                    ),
                                    Text(
                                      ledgerprovider
                                          .calenderpnlAllData!.unrealized
                                          .toStringAsFixed(2),
                                      style: textStyle(
                                          Colors.red, 13, FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Charges and Taxes",
                                      style: textStyle(Color(0xFF696969), 14,
                                          FontWeight.w400),
                                    ),
                                    Text(
                                      ledgerprovider!
                                          .calenderpnlAllData!.totalCharges!
                                          .toStringAsFixed(2),
                                      style: textStyle(
                                          Colors.green, 13, FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Net Realised P&L",
                                      style: textStyle(Color(0xFF696969), 14,
                                          FontWeight.w400),
                                    ),
                                    Text(
                                      "rvfrvsd",
                                      style: textStyle(colors.colorBlack, 13,
                                          FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
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

            ledgerprovider.calenderpnlAllData!.data == null
                ? Center(
                    child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: NoDataFound(),
                  ))
                : Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                          physics: ScrollPhysics(),
                          itemCount: ledgerprovider.calenderpnlAllData!.data !=
                                  null
                              ? ledgerprovider.calenderpnlAllData!.data!.length
                              : 0,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final indexdata =
                                ledgerprovider.calenderpnlAllData!.data![index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                            "${indexdata.sCRIPNAME}",
                                            style: textStyle(Colors.black, 14,
                                                FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ],
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
                                            "${indexdata.updatedNETQTY}",
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
                                            "${indexdata.totalBuyQty}",
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
                                                "${indexdata.totalSellQty}",
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
                                          Text(
                                            "Buy Rate : ",
                                            style: textStyle(Color(0xFF696969),
                                                13, FontWeight.w500),
                                          ),
                                          Text(
                                            "${indexdata.totalBuyRate}",
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
                                                "Sell Rate : ",
                                                style: textStyle(
                                                    Color(0xFF696969),
                                                    13,
                                                    FontWeight.w500),
                                              ),
                                              Text(
                                                "${indexdata.totalSellRate}",
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
                                          Text(
                                            "Buy Amount : ",
                                            style: textStyle(Color(0xFF696969),
                                                13, FontWeight.w500),
                                          ),
                                          Text(
                                            "${indexdata.bAMT}",
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
                                                "Sell Amount : ",
                                                style: textStyle(
                                                    Color(0xFF696969),
                                                    13,
                                                    FontWeight.w500),
                                              ),
                                              Text(
                                                "${indexdata.sAMT}",
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
                                          Text(
                                            "Realised : ",
                                            style: textStyle(Color(0xFF696969),
                                                13, FontWeight.w500),
                                          ),
                                          Text(
                                            "${indexdata.realisedpnl}",
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
                                                "Unrealised : ",
                                                style: textStyle(
                                                    Color(0xFF696969),
                                                    13,
                                                    FontWeight.w500),
                                              ),
                                              Text(
                                                " ${indexdata.unrealisedpnl}",
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
            ListView.separated(
                separatorBuilder: (context, index) => Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                itemCount: 0,
                itemBuilder: (context, index) {
                  // String key = ;

                  // _expandedPanels.putIfAbsent(key, () => false);
                  // if (!_expandedPanels.containsKey(key)) {
                  //   _expandedPanels[key] = false;
                  // }
                  return ExpansionPanelList(
                    elevation: 0,
                    expandIconColor: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                    expansionCallback: (panelIndex, isExpanded) {
                      setState(() {
                        // _expandedPanels[index] = !_expandedPanels[index]!;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        backgroundColor: !theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        headerBuilder: (context, isExpanded) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: isExpanded ? 0 : 6),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [Text("daa")],
                              ),
                            ),
                          );
                        },
                        body: Column(
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.fromLTRB(
                            //       6, 0, 6, 16),
                            //   child: LinearPercentIndicator(
                            //     // width: 280,
                            //     lineHeight: 16,
                            //     center: Text(
                            //         (panelsum).toStringAsFixed(2)),
                            //     percent: sumis,
                            //     progressColor: Colors.blue,
                            //   ),
                            // ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: 0,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: []));
                                })
                          ],
                        ),
                        // isExpanded: _expandedPanels[key]!,
                        canTapOnHeader: true,
                      ),
                    ],
                  );
                })
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
}
