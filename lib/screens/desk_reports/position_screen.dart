import 'dart:math';

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

class PositionScreen extends StatefulWidget {
  final String ddd;
  const PositionScreen({super.key, required this.ddd});

  @override
  _PositionScreen createState() => _PositionScreen();
}

class _PositionScreen extends State<PositionScreen>
    with SingleTickerProviderStateMixin {
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

      final ledgerprovider = ref.watch(ledgerProvider);
      Future<void> _refresh() async {
        await Future.delayed(Duration(seconds: 0)); // simulate refresh delay
        print("refresh ");
        ledgerprovider.fetchposition(context);
      }

      double realised = 0.0;
      int closed = 0;
      // int negative = 0;
      // int positive = 0;
      double unrealised = 0.0;
      final pnl = 0;
      if (ledgerprovider.positiondata?.data != null) {
        for (var i = 0; i < ledgerprovider.positiondata!.data!.length; i++) {
          if (double.tryParse(
                      ledgerprovider.positiondata!.data![i].netqty.toString())!
                  .toInt() ==
              0) {
            realised += double.tryParse(
                ledgerprovider.positiondata!.data![i].rpnl.toString())!;
            closed = closed + 1;
          } else {
            unrealised += double.tryParse(
                ledgerprovider.positiondata!.data![i].rpnl.toString())!;
          }
          // if (double.tryParse(
          //             ledgerprovider.positiondata!.data![i].rpnl.toString())!
          //         .toInt() >
          //     0) {
          //   positive = positive + 1;
          // } else {
          //   negative = negative + 1;
          // }
        }
      }
      // String tdebit = ledgerprovider.ledgerAllData?.drAmt ?? '0.0';
      // String tcredit = ledgerprovider.ledgerAllData?.crAmt ?? '0.0';

      return RefreshIndicator(
        onRefresh: _refresh,
        child: WillPopScope(
          onWillPop: () async {
            ledgerprovider.falseloader('ledger');
            ledgerprovider.settime = '';
            ledgerprovider.timer?.cancel();
            Navigator.pop(context);
            print("objectobjectobjectobjectobjectobjectobjectobject");
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              // automaticallyImplyLeading: false,
              leadingWidth: 41,
              titleSpacing: 6,
              centerTitle: false,
              leading: InkWell(
                onTap: () async {
                  ledgerprovider.falseloader('ledger');
                  ledgerprovider.settime = '';
                  ledgerprovider.timer?.cancel();
                  Navigator.pop(context);
                  print("objectobjectobjectobjectobjectobjectobjectobject");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    assets.backArrow,
                    width: 46,
                    height: 46,
                  ),
                ),
              ),
              elevation: 0.2,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.heroText(
                      text: "Positions-(Beta)",
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 1),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextWidget.captionText(
                        text: "Last update : ${ledgerprovider.timedis}",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 1),
                  ),
                ],
              ),
              // leading: InkWell(
              //   onTap: () {

              //   },
              //   child: Icon(Icons.ios_share)),
            ),
            body: TransparentLoaderScreen(
              isLoading: ledgerprovider.positionloading,
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
                                            text: "Realised",
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
                                                  "₹ ${realised.toStringAsFixed(2)}",
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              color: realised < 0
                                                  ? Colors.red
                                                  : realised < 0
                                                      ? Colors.green
                                                      : Colors.black,
                                              theme: theme.isDarkMode,
                                              fw: 1),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        TextWidget.subText(
                                            text: "Unrealised",
                                            color: Color(0xFF696969),
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 0),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: TextWidget.titleText(
                                              text:
                                                  "₹ ${unrealised.toStringAsFixed(2)}",
                                              color: unrealised < 0
                                                  ? Colors.red
                                                  : unrealised < 0
                                                      ? Colors.green
                                                      : Colors.black,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
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
                                    // Column(
                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     TextWidget.subText(
                                    //         text: "Trade position",
                                    //         color: Color(0xFF696969),
                                    //         textOverflow: TextOverflow.ellipsis,
                                    //         theme: theme.isDarkMode,
                                    //         fw: 0),
                                    //     Column(
                                    //       children: [
                                    //         Row(
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.only(
                                    //                   top: 8.0),
                                    //               child: TextWidget.titleText(
                                    //                   text: "$positive /",
                                    //                   textOverflow:
                                    //                       TextOverflow.ellipsis,
                                    //                   theme: theme.isDarkMode,
                                    //                   color: Colors.green,
                                    //                   fw: 1),
                                    //             ),
                                    //             Padding(
                                    //               padding: const EdgeInsets.only(
                                    //                   top: 8.0),
                                    //               child: TextWidget.titleText(
                                    //                   text: " $negative /",
                                    //                   textOverflow:
                                    //                       TextOverflow.ellipsis,
                                    //                   color: Colors.red,

                                    //                   theme: theme.isDarkMode,
                                    //                   fw: 1),
                                    //             ),
                                    //             Padding(
                                    //               padding: const EdgeInsets.only(
                                    //                   top: 8.0),
                                    //               child: TextWidget.titleText(
                                    //                   text: " ${closed} ",
                                    //                   textOverflow:
                                    //                       TextOverflow.ellipsis,
                                    //                   theme: theme.isDarkMode,
                                    //                   fw: 1),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ],
                                    // ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget.subText(
                                            text: "Net P&L",
                                            color: Color(0xFF696969),
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 0),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: TextWidget.titleText(
                                              text:
                                                  "₹ ${(unrealised + realised).toStringAsFixed(2)}",
                                              color: unrealised + realised > 0
                                                  ? Colors.green
                                                  : unrealised + realised < 0
                                                      ? Colors.red
                                                      : Colors.black,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
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

                  ledgerprovider.positiondata?.data?.isEmpty ?? true
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
                                  ledgerprovider.positiondata?.data?.length ??
                                      0,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final val =
                                    ledgerprovider.positiondata!.data![index];

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, top: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget.subText(
                                              text: "${val.tsym}",
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 1),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: TextWidget.subText(
                                                align: TextAlign.right,
                                                text:
                                                    "₹ ${double.tryParse(val.rpnl.toString())!.toStringAsFixed(2)}",
                                                color: double.tryParse(
                                                                val.rpnl!)!
                                                            .toInt() >
                                                        0
                                                    ? Colors.green
                                                    : double.tryParse(
                                                                    val.rpnl!)!
                                                                .toInt() <
                                                            0
                                                        ? Colors.red
                                                        : Colors.black,
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
                                                exch: "${val.exch}",
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
                                                    text: "Qty : ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: " ${val.netqty}",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),
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
                                          top: 4.0, left: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text: "Buy Qty : ",
                                                  color: Color(0xFF696969),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text:
                                                      " ${val.buyPrice} @ ₹${val.buyValue}",
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 1),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: Row(
                                              children: [
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: "Avg Price : ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:
                                                        " ₹${double.tryParse(val.netAvgPrc.toString())!.toStringAsFixed(2)}",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, left: 16.0, bottom: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text: "Sell Qty : ",
                                                  color: Color(0xFF696969),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text:
                                                      " ${val.sellQuantity} @ ₹${val.sellValue}",
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 1),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: Row(
                                              children: [
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: "LTP : ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: " ₹${val.ltp}",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
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
