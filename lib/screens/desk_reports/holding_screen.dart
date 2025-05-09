import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/desk_reports/bottom_sheets/holdings_inner_detail.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';

import '../../models/desk_reports_model/holdings_model.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/no_data_found.dart';

class HoldingScreen extends StatelessWidget {
  final String ddd;
  const HoldingScreen({super.key, required this.ddd});

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
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      final socketDatas = watch(websocketProvider).socketDatas;
      double currentval = 0.0;
      double pnlstat = 0.0;
      final ledgerprovider = watch(ledgerProvider);
      Future<void> _refresh() async {
        await Future.delayed(Duration(seconds: 0)); // simulate refresh delay
        print("refresh ");
        await ledgerprovider.getCurrentDate('else');
        ledgerprovider.fetchholdingsData(ledgerprovider.today, context);
      }

      if (ledgerprovider.holdingsAllData != null) {
        final lengthval = ledgerprovider.holdingsAllData?.holdings?.length ?? 0;
        for (var i = 0; i < lengthval; i++) {
          final val = ledgerprovider.holdingsAllData!.holdings![i];
          num currentcal = 0; // Ensure it starts from 0
          num pnl = 0; // Ensure it starts from 0
          // print("${socketDatas[val['Token']]} socketdataavalue");
          if (val['Token'] != null && val['Token'].toString().isNotEmpty) {
            if (socketDatas.containsKey(val['Token'])) {
              num buyPrice = num.tryParse(val['buy_price'].toString()) ?? 0;
              num net = num.tryParse(val['NET'].toString()) ?? 0;
              num livePrice = num.tryParse(
                      socketDatas[val['Token']]?['lp']?.toString() ?? '0') ??
                  0;

              if (buyPrice > 0) {
                val['pnl'] =
                    ((livePrice * net) - (buyPrice * net)).toStringAsFixed(2);
                currentcal = livePrice * net;

                val['pnlch'] =
                    ((double.parse(val['pnl']) / (buyPrice * net)) * 100)
                        .toStringAsFixed(2);

                currentcal = livePrice * net;

                val['ltp'] = "${socketDatas[val['Token']]?['lp'] ?? 0.00}";
                val['ltpch'] = "${socketDatas[val['Token']]?['pc'] ?? 0.00}";
              } else {
                val['pnl'] = 0;
                val['pnlch'] = 0;

                val['ltp'] = "${socketDatas[val['Token']]?['lp'] ?? 0.00}";
                val['ltpch'] = "${socketDatas[val['Token']]?['pc'] ?? 0.00}";
              }
              pnl = num.tryParse(val['pnl'].toString()) ?? 0;
            }
          } else {
            num buyPrice = num.tryParse(val['buy_price'].toString()) ?? 0;
            num net = num.tryParse(val['NET'].toString()) ?? 0;
            num livePrice = num.tryParse(val['nav_price'].toString()) ?? 0;

            if (buyPrice > 0) {
              val['pnl'] =
                  ((livePrice * net) - (buyPrice * net)).toStringAsFixed(2);
              currentcal = livePrice * net;
              val['pnlch'] =
                  ((double.parse(val['pnl']) / (buyPrice * net)) * 100)
                      .toStringAsFixed(2);

              val['ltp'] = livePrice.toString();
              val['ltpch'] = "${socketDatas[val['Token']]?['pc'] ?? 0.00}";
            } else {
              val['pnl'] = 0;
              val['pnlch'] = 0;

              val['ltp'] = livePrice;
              val['ltpch'] = "${socketDatas[val['Token']]?['pc'] ?? 0.00}";
            }
            pnl = num.tryParse(val['pnl'].toString()) ?? 0;
          }

          currentval += currentcal;
          pnlstat += pnl;
        }
      }

      return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: InkWell(
            onTap: () {
              ledgerprovider.falseloader('holdings');
            },
            child: const CustomBackBtn(),
          ),
          elevation: 0.2,
          title: TextWidget.heroText(
              text: "Holdings",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 1),

          // leading: InkWell(
          //   onTap: () {
          //     ledgerprovider.requestWS(context: context, isSubscribe: true);
          //   },
          // )
          //   child: Icon(Icons.ios_share)),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: TransparentLoaderScreen(
            isLoading: ledgerprovider.holdingsloading,
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
                        decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? const Color(0xffB5C0CF).withOpacity(.15)
                                : const Color(0xffF1F3F8)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget.subText(
                                        text: "Total Investment",
                                        color: Color(0xFF696969),
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: TextWidget.titleText(
                                          text: ledgerprovider
                                                          .holdingsAllData ==
                                                      null ||
                                                  ledgerprovider.holdingsAllData
                                                          ?.totalInvested
                                                          .toString() ==
                                                      'null'
                                              ? "0.00"
                                              : "₹ ${ledgerprovider.holdingsAllData?.totalInvested}", // Default text if data is null",
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 1),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget.subText(
                                          text: "Current Value    ",
                                          color: Color(0xFF696969),
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextWidget.titleText(
                                            text: ledgerprovider
                                                            .holdingsAllData !=
                                                        null &&
                                                    ledgerprovider
                                                            .holdingsAllData!
                                                            .totalInvested !=
                                                        null
                                                ? "₹ ${currentval.toStringAsFixed(2)}"
                                                : '0.00',
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            color: (num.tryParse(currentval
                                                            .toString()) ??
                                                        0) >
                                                    0
                                                ? Colors.green
                                                : currentval < 0
                                                    ? Colors.red
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                            fw: 1),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextWidget.subText(
                                      align: TextAlign.right,
                                      text: "Total P&L    ",
                                      color: Color(0xFF696969),
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextWidget.titleText(
                                            color: pnlstat > 0
                                                ? Colors.green
                                                : pnlstat < 0
                                                    ? Colors.red
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                            text:
                                                "₹ ${pnlstat.toStringAsFixed(2)}",
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 1),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextWidget.subText(
                                            text: ledgerprovider.holdingsAllData
                                                            ?.totalInvested ==
                                                        null ||
                                                    ledgerprovider
                                                            .holdingsAllData
                                                            ?.totalInvested
                                                            .toString() ==
                                                        'null'
                                                ? '0.00'
                                                : "(${((pnlstat / (double.tryParse(ledgerprovider.holdingsAllData?.totalInvested?.toString() ?? '1'))!) * 100).toStringAsFixed(2)}%)",
                                            color: pnlstat > 0
                                                ? Colors.green
                                                : pnlstat < 0
                                                    ? Colors.red
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                            theme: theme.isDarkMode,
                                            fw: 0),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ))

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
                // Row(
                //   // mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Container(
                //       width: screenWidth,
                //       // height: screenheight * 0.27,
                //       padding: EdgeInsets.symmetric(horizontal: 22),
                //       margin: EdgeInsets.only(top: 16),
                //       child: Card(
                //           color: Color(0xFFEEEEEE),
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(8.0)),
                //           child: Container(
                //             width: screenWidth,
                //             // height: screenheight,
                //             padding: EdgeInsets.only(
                //                 top: 10, bottom: 25, left: 20, right: 20),
                //             margin: EdgeInsets.only(top: 16),
                //             child: Card(
                //               color: Colors.white,
                //               shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(8.0)),
                //               child: Column(
                //                 children: [
                //                   Padding(
                //                     padding: const EdgeInsets.only(
                //                         top: 30, left: 20, right: 20, bottom: 15),
                //                     child: Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceBetween,
                //                       children: [
                //                         Text(
                //                           "Total investment",
                //                           style: textStyle(Color(0xFF696969), 14,
                //                               FontWeight.w400),
                //                         ),
                //                         Text(
                //                           ledgerprovider.holdingsAllData !=
                //                                       null &&
                //                                   ledgerprovider.holdingsAllData!
                //                                           .totalInvested !=
                //                                       null
                //                               ? "${ledgerprovider.holdingsAllData!.totalInvested}"
                //                               : "N/A", // Default text if data is null
                //                           style: textStyle(colors.colorBlack, 13,
                //                               FontWeight.w500),
                //                         )
                //                       ],
                //                     ),
                //                   ),
                //                   Padding(
                //                     padding: const EdgeInsets.only(
                //                         left: 20, right: 20, bottom: 15),
                //                     child: Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceBetween,
                //                       children: [
                //                         Text(
                //                           "Current Value",
                //                           style: textStyle(Color(0xFF696969), 14,
                //                               FontWeight.w400),
                //                         ),
                //                         Text(
                //                           ledgerprovider.holdingsAllData !=
                //                                       null &&
                //                                   ledgerprovider.holdingsAllData!
                //                                           .holdingsValueBuyprice !=
                //                                       null
                //                               ? "${ledgerprovider.holdingsAllData!.holdingsValueBuyprice}"
                //                               : "${ledgerprovider.holdingsAllData}", // Default text if data is null
                //                           style: textStyle(colors.colorBlack, 13,
                //                               FontWeight.w500),
                //                         )
                //                       ],
                //                     ),
                //                   ),
                //                   Padding(
                //                     padding: const EdgeInsets.only(
                //                         left: 20, right: 20, bottom: 25),
                //                     child: Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceBetween,
                //                       children: [
                //                         Text(
                //                           "Total P&L",
                //                           style: textStyle(Color(0xFF696969), 14,
                //                               FontWeight.w400),
                //                         ),
                //                         Text(
                //                           ledgerprovider.holdingsAllData !=
                //                                       null &&
                //                                   ledgerprovider.holdingsAllData!
                //                                           .totalPnl !=
                //                                       null
                //                               ? "${ledgerprovider.holdingsAllData!.totalPnl}"
                //                               : "N/A", // Default text if data is null
                //                           style: textStyle(colors.colorBlack, 13,
                //                               FontWeight.w500),
                //                         )
                //                       ],
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           )),
                //     ),

                //     // Expanded(
                //     //   child: Padding(
                //     //     padding: const EdgeInsets.all(14.0),
                //     //     child: TextField(

                //     //       decoration: InputDecoration(
                //     //         filled: true,
                //     //          fillColor: const Color(0xffF1F3F8),
                //     //       hintText: "Search",
                //     //         border: OutlineInputBorder(
                //     //           borderRadius: BorderRadius.circular(30.0),
                //     //         ),
                //     //         focusedBorder: OutlineInputBorder(
                //     //           borderRadius: BorderRadius.circular(30.0),
                //     //           borderSide: BorderSide(color:  Colors.grey, width: 2.0),
                //     //         ),
                //     //         enabledBorder: OutlineInputBorder(
                //     //           borderRadius: BorderRadius.circular(30.0),
                //     //           borderSide: BorderSide(color: Colors.grey, width: 1.0),
                //     //         ),
                //     //         contentPadding: EdgeInsets.symmetric(
                //     //           horizontal: 20.0,
                //     //           vertical: 15.0,
                //     //         ),
                //     //         prefixIconColor: const Color(0xff586279),
                //     //         prefixIcon: SvgPicture.asset(
                //     //           "assets/icon/appbarIcon/search.svg",
                //     //           color: const Color(0xff586279),
                //     //           fit: BoxFit.scaleDown,
                //     //           width: 14,
                //     //           height: 14,
                //     //         ),
                //     //       ),
                //     //     ),
                //     //   ),

                //     // ),
                //   ],
                // ),
                // Padding(
                //                   padding: const EdgeInsets.only(top: 2.0,bottom: 0.0,),
                //                   child: Divider(
                //                     color: theme.isDarkMode
                //                         ? const Color(0xffB5C0CF).withOpacity(.15)
                //                         : const Color(0xffF1F3F8),
                //                     thickness: 7.0,
                //                   ),
                //                 ),
                // Text("${ledgerprovider.holdingsAllData!.holdings}"),

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

                // ledgerprovider.holdingsAllData!.holdings == null
                //     ? Center(
                //         child: Padding(
                //         padding: EdgeInsets.only(top: 60),
                //         child: NoDataFound(),
                //       ))
                //     :

                ledgerprovider.holdingsAllData?.holdings == null
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
                                    .holdingsAllData?.holdings?.length ??
                                0,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              // if (ledgerprovider.holdingsAllData != null) {
                              //   final holddata =
                              //       ledgerprovider.holdingsAllData!.holdings![index];
                              //   if (holddata['Token'] != '') {
                              //     if (socketDatas.containsKey(holddata['Token'])) {
                              //       holddata['ltp'] =
                              //           "${socketDatas["${holddata['Token']}"]['lp'] ?? 0.00}";
                              //       num buyPrice = num.tryParse(
                              //               holddata['buy_price'].toString()) ??
                              //           0;
                              //       num net =
                              //           num.tryParse(holddata['NET'].toString()) ?? 0;

                              //       num livePrice = num.tryParse(
                              //               socketDatas[holddata['Token']]?['lp']
                              //                       ?.toString() ??
                              //                   '0') ??
                              //           0;

                              //       holddata['pnl'] =
                              //           ((livePrice * net) - (buyPrice * net))
                              //               .toStringAsFixed(2);
                              //     } else {
                              //       holddata['ltp'] = '0.00';
                              //     }
                              //   } else {
                              //     holddata['ltp'] = '0.00';
                              //   }
                              // }
                              return InkWell(
                                onTap: () {
                                  // ledgerprovider.setholdingdetailindex = index;
                                  // print(ledgerprovider.holdingdetailindex);
                                  _showBottomSheet(
                                      context,
                                      HoldingInnerDetails(
                                          data: ledgerprovider.holdingsAllData!
                                              .holdings![index]));
                                },
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16.0),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextWidget.subText(
                                                    text:
                                                        "${ledgerprovider.holdingsAllData!.holdings![index]['SCRIP_SYMBOL']}",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4.0),
                                                  child: CustomExchBadge(
                                                    exch:
                                                        "${ledgerprovider.holdingsAllData?.holdings?[index]['seg_type']}",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextWidget.subText(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : Color(0xFF696969),
                                                        text: "LTP : ",
                                                        textOverflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        theme: theme.isDarkMode,
                                                        fw: 0),
                                                    TextWidget.subText(
                                                        text:
                                                            "₹${ledgerprovider.holdingsAllData!.holdings![index]['ltp']}",
                                                        textOverflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        theme: theme.isDarkMode,
                                                        fw: 0),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4.0),
                                                  child: TextWidget.paraText(
                                                      text:
                                                          "(${ledgerprovider.holdingsAllData!.holdings![index]['ltpch']} %)",
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      color: (double.tryParse(ledgerprovider
                                                                          .holdingsAllData
                                                                          ?.holdings?[
                                                                              index]
                                                                              [
                                                                              'ltpch']
                                                                          .toString() ??
                                                                      '0') ??
                                                                  0) >
                                                              0
                                                          ? Colors.green
                                                          : (double.tryParse(ledgerprovider
                                                                              .holdingsAllData
                                                                              ?.holdings?[index]['ltpch']
                                                                              .toString() ??
                                                                          '0') ??
                                                                      0) <
                                                                  0
                                                              ? Colors.red
                                                              : Colors.black,
                                                      fw: 0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: const Color.fromARGB(
                                          255, 212, 212, 212),
                                      thickness: 0.5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                          top: 2.0,
                                          bottom: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              TextWidget.subText(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : Color(0xFF696969),
                                                  text: "Qty : ",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  text:
                                                      "${ledgerprovider.holdingsAllData!.holdings![index]['NET']} @ ₹${ledgerprovider.holdingsAllData?.holdings?[index]['buy_price']}",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              // Text("P&L : ",
                                              //     style: textStyle(
                                              //         theme.isDarkMode
                                              //             ? colors.colorWhite
                                              //             : Color(0xFF696969),
                                              //         13,
                                              //         FontWeight.w500)),
                                              Row(
                                                children: [
                                                  TextWidget.subText(
                                                      text:
                                                          "₹${(ledgerprovider.holdingsAllData!.holdings![index]['pnl'])}",
                                                      color: (num.tryParse(ledgerprovider
                                                                      .holdingsAllData!
                                                                      .holdings![
                                                                          index]
                                                                          [
                                                                          'pnl']
                                                                      .toString()) ??
                                                                  0) >
                                                              0
                                                          ? Colors.green
                                                          : (num.tryParse(ledgerprovider
                                                                          .holdingsAllData!
                                                                          .holdings![
                                                                              index]
                                                                              [
                                                                              'pnl']
                                                                          .toString()) ??
                                                                      0) <
                                                                  0
                                                              ? Colors.red
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                  TextWidget.paraText(
                                                      color: (num.tryParse(ledgerprovider
                                                                      .holdingsAllData!
                                                                      .holdings![
                                                                          index][
                                                                          'pnl']
                                                                      .toString()) ??
                                                                  0) >
                                                              0
                                                          ? Colors.green
                                                          : (num.tryParse(ledgerprovider
                                                                          .holdingsAllData!
                                                                          .holdings![
                                                                              index]
                                                                              [
                                                                              'pnl']
                                                                          .toString()) ??
                                                                      0) <
                                                                  0
                                                              ? Colors.red
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                      text:
                                                          " (${(ledgerprovider.holdingsAllData!.holdings![index]['pnlch'])}%)",
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16.0, bottom: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              TextWidget.subText(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : Color(0xFF696969),
                                                  text: "Inv : ",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  text:
                                                      "₹ ${((double.tryParse(ledgerprovider.holdingsAllData?.holdings?[index]['buy_price'].toString() ?? '0') ?? 0) * (double.tryParse(ledgerprovider.holdingsAllData?.holdings?[index]['NET'].toString() ?? '0') ?? 0)).toStringAsFixed(2)}",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              TextWidget.subText(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : Color(0xFF696969),
                                                  text: "Cur : ",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  text:
                                                      "₹${((double.tryParse(ledgerprovider.holdingsAllData?.holdings?[index]['ltp'].toString() ?? '0') ?? 0) * (double.tryParse(ledgerprovider.holdingsAllData?.holdings?[index]['NET'].toString() ?? '0') ?? 0)).toStringAsFixed(2)}",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ],
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
                              return Divider(
                                color: theme.isDarkMode
                                    ? const Color(0xffB5C0CF).withOpacity(.15)
                                    : const Color(0xffF1F3F8),
                                thickness: 7.0,
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
