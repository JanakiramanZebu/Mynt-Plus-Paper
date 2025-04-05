import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class PnlSummarBottom extends StatefulWidget {
  const PnlSummarBottom({super.key});

  @override
  State<PnlSummarBottom> createState() => _PnlSummarBottom();
}

class _PnlSummarBottom extends State<PnlSummarBottom> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    double notional = 0.0;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ledgerdata = watch(ledgerProvider);

      if (ledgerdata.reportsloading == false) {
        for (var i = 0; i < ledgerdata.pnlSummaryData!.data!.length; i++) {
          final val = ledgerdata.pnlSummaryData!.data![i];
          double amount = double.tryParse(val.nETAMT?.toString() ?? '0') ?? 0.0;
          notional += amount;
        }
      }

      return DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: .4,
        maxChildSize: .99,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
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
                padding: const EdgeInsets.only(top: 15.0, left: 16),
                child: TextWidget.heroText(
                    text: "Detailed P&L",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "${ledgerdata.pnlSummaryData?.data![0].fULLSCRIPSYMBOL}",
                  style: textStyle(Colors.grey, 12, FontWeight.w500),
                ),
              ),
              Expanded(
                // height: screenheight * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? const Color(0xffB5C0CF).withOpacity(.15)
                                : const Color(0xffF1F3F8)),
                        margin: EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 16, right: 16, bottom: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidget.subText(
                                      text: "Notional",
                                      color: Color(0xFF696969),
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                  Text(
                                    "${notional.toStringAsFixed(2)}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.separated(
                        physics: ScrollPhysics(),
                        itemCount: ledgerdata.pnlSummaryData?.data?.length ?? 0,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final value = ledgerdata.pnlSummaryData!.data![index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 16.0, left: 16.0, top: 16.0),
                                    child: Text(
                                      // "${dateFormatChangeForLedger(ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE.toString())}",
                                      "${value.tRADEDATE}",

                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 2.0, left: 16, right: 16),
                                child: Divider(
                                  color:
                                      const Color.fromARGB(255, 212, 212, 212),
                                  thickness: 0.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 16.0, left: 16.0, top: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          // (ledgerprovider.ledgerAllData!
                                          //             .fullStat![index].cRAMT) !=
                                          //         "0.0"
                                          //     ? "Credit : "
                                          //     : "Debit : ",
                                          "Buy Qty : ",
                                          style: textStyle(Color(0xFF696969),
                                              12, FontWeight.w500),
                                        ),
                                        Text(
                                          // ledgerprovider.ledgerAllData!.fullStat![index]
                                          //             .cRAMT !=
                                          "${value.bQTY} @ ₹${double.parse(value.bRATE.toString()).toStringAsFixed(2)}",
                                          style: textStyle(Colors.green, 12,
                                              FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          // (ledgerprovider.ledgerAllData!
                                          //             .fullStat![index].cRAMT) !=
                                          //         "0.0"
                                          //     ? "Credit : "
                                          //     : "Debit : ",
                                          "Sell Qty : ",
                                          style: textStyle(Color(0xFF696969),
                                              12, FontWeight.w500),
                                        ),
                                        Text(
                                          // ledgerprovider.ledgerAllData!.fullStat![index]
                                          //             .cRAMT !=
                                          "${value.sQTY} @ ₹ ${double.parse(value.sRATE.toString()).toStringAsFixed(2)}",
                                          style: textStyle(
                                              Colors.red, 12, FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       // (ledgerprovider.ledgerAllData!
                                    //       //             .fullStat![index].cRAMT) !=
                                    //       //         "0.0"
                                    //       //     ? "Credit : "
                                    //       //     : "Debit : ",
                                    //       "Net Rate : ",
                                    //       style: textStyle(
                                    //           Color(0xFF696969),
                                    //           13,
                                    //           FontWeight.w500),
                                    //     ),
                                    //     Text(
                                    //       // ledgerprovider.ledgerAllData!.fullStat![index]
                                    //       //             .cRAMT !=
                                    //       "${value.nRATE}",
                                    //       style: textStyle(Colors.black, 12,
                                    //           FontWeight.w600),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //      right: 16.0, left: 16.0, top: 10.0),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Row(
                              //         children: [
                              //           Text(
                              //             // (ledgerprovider.ledgerAllData!
                              //             //             .fullStat![index].cRAMT) !=
                              //             //         "0.0"
                              //             //     ? "Credit : "
                              //             //     : "Debit : ",
                              //             "Buy Qty : ",
                              //             style: textStyle(
                              //                 Color(0xFF696969),
                              //                 13,
                              //                 FontWeight.w500),
                              //           ),
                              //           Text(
                              //             // ledgerprovider.ledgerAllData!.fullStat![index]
                              //             //             .cRAMT !=
                              //             "${value.bQTY} @ ₹${value.bRATE}",
                              //             style: textStyle(Colors.black, 12,
                              //                 FontWeight.w600),
                              //           ),
                              //         ],
                              //       ),
                              //       Row(
                              //         children: [
                              //           Text(
                              //             // (ledgerprovider.ledgerAllData!
                              //             //             .fullStat![index].cRAMT) !=
                              //             //         "0.0"
                              //             //     ? "Credit : "
                              //             //     : "Debit : ",
                              //             "Buy Rate : ",
                              //             style: textStyle(
                              //                 Color(0xFF696969),
                              //                 13,
                              //                 FontWeight.w500),
                              //           ),
                              //           Text(
                              //             // ledgerprovider.ledgerAllData!.fullStat![index]
                              //             //             .cRAMT !=
                              //             "${value.bRATE}",
                              //             style: textStyle(Colors.black, 12,
                              //                 FontWeight.w600),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 16.0, left: 16.0, top: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          // (ledgerprovider.ledgerAllData!
                                          //             .fullStat![index].cRAMT) !=
                                          //         "0.0"
                                          //     ? "Credit : "
                                          //     : "Debit : ",
                                          "Net Qty : ",
                                          style: textStyle(Color(0xFF696969),
                                              12, FontWeight.w500),
                                        ),
                                        Text(
                                          // ledgerprovider.ledgerAllData!.fullStat![index]
                                          //             .cRAMT !=
                                          "${value.nETQTY} @ ₹${value.nRATE}",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              12,
                                              FontWeight.w600),
                                        ),

                                        // Text(
                                        //   ("${ledgerdata.ledgerBillData!.transactions![index].bAMT}"
                                        //                ) ,
                                        //   style: textStyle(
                                        //     double.tryParse(ledgerdata
                                        //                     .ledgerBillData!
                                        //                     .transactions![index]
                                        //                     .bAMT ??
                                        //                 "0")! <
                                        //             0
                                        //         ? Colors.red // Red for less than 0
                                        //         : Colors
                                        //             .green, // Green for greater than or equal to 0
                                        //     14,
                                        //     FontWeight.w500,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       // (ledgerprovider.ledgerAllData!
                                    //       //             .fullStat![index].cRAMT) !=
                                    //       //         "0.0"
                                    //       //     ? "Credit : "
                                    //       //     : "Debit : ",
                                    //       "Sell Qty : ",
                                    //       style: textStyle(
                                    //           Color(0xFF696969),
                                    //           13,
                                    //           FontWeight.w500),
                                    //     ),
                                    //     Text(
                                    //       // ledgerprovider.ledgerAllData!.fullStat![index]
                                    //       //             .cRAMT !=
                                    //       "${value.sQTY} @ ₹ ${value.sRATE}",
                                    //       style: textStyle(Colors.black, 12,
                                    //           FontWeight.w600),
                                    //     ),
                                    //   ],
                                    // ),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       // (ledgerprovider.ledgerAllData!
                                    //       //             .fullStat![index].cRAMT) !=
                                    //       //         "0.0"
                                    //       //     ? "Credit : "
                                    //       //     : "Debit : ",
                                    //       "Sell Rate : ",
                                    //       style: textStyle(
                                    //           Color(0xFF696969),
                                    //           13,
                                    //           FontWeight.w500),
                                    //     ),
                                    //     Text(
                                    //       ("${value.sRATE}"),
                                    //       style: textStyle(
                                    //         double.tryParse(value.sRATE ??
                                    //                     "0")! <
                                    //                 0
                                    //             ? Colors
                                    //                 .red // Red for less than 0
                                    //             : Colors
                                    //                 .green, // Green for greater than or equal to 0
                                    //         12,
                                    //         FontWeight.w600,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 0.0,
                            ),
                            child: Divider(
                              color: theme.isDarkMode
                                  ? const Color(0xffB5C0CF).withOpacity(.15)
                                  : const Color(0xffF1F3F8),
                              thickness: 7.0,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              )
            ]),
          );
        },
      );
    });
  }
}
