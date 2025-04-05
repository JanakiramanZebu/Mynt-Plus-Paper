import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';

import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class LedgerBillBottom extends StatefulWidget {
  const LedgerBillBottom({super.key});

  @override
  State<LedgerBillBottom> createState() => _LedgerBillBottomState();
}

class _LedgerBillBottomState extends State<LedgerBillBottom> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Consumer(builder: (context, ScopedReader watch, _){
    final ledgerdata = watch(ledgerProvider);

      return DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: .4,
        maxChildSize: .99,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: const Color.fromARGB(255, 219, 218, 218),
              width: 40,
              height: 4.0,
              padding:
                  EdgeInsets.only(top: 10, bottom: 25, left: 20, right: 20),
              margin: EdgeInsets.only(top: 16),
            ),
          ],
                        ),
                         
                       
                        ledgerdata!.ledgerBillData!.expenses == null
            ? Center(
                child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: NoDataFound(),
              ))
            : Expanded(
          // height: screenheight * 0.5,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Card(
                //     color: Color(0xFFEEEEEE),
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8.0)),
                //     child: Container(
                //       padding: EdgeInsets.only(
                //           top: 10, bottom: 25, left: 20, right: 20),
                //       margin: EdgeInsets.only(top: 16),
                //       child: Card(
                //         color: Colors.white,
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(8.0)),
                //         child: Column(
                //           children: [
                //             for (var item
                //                 in ledgerdata.ledgerBillData!.expenses! != null ? ledgerdata.ledgerBillData!.expenses! : [])
                //               Padding(
                //                 padding: const EdgeInsets.only(
                //                     top: 10, left: 20, right: 20, bottom: 15),
                //                 child: Row(
                //                   mainAxisAlignment:
                //                       MainAxisAlignment.spaceBetween,
                //                   children: [
                //                     Text(
                //                       "${item.sCRIPSYMBOL}",
                //                       style: textStyle(Color(0xFF696969), 14,
                //                           FontWeight.w400),
                //                     ),
                //                     Text(
                //                       "${item.nETAMT}",
                //                       style: textStyle(colors.colorBlack, 13,
                //                           FontWeight.w500),
                //                     )
                //                   ],
                //                 ),
                //               ),
                //           ],
                //         ),
                //       ),
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
                child:  
                Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adds margin to the grid
  child: GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // Two columns
      crossAxisSpacing: 130.0, // Space between columns
      mainAxisSpacing: 0.0, // No vertical space between rows
      childAspectRatio: 3.4, // Adjust layout
    ),
    itemCount: ledgerdata.ledgerBillData?.expenses?.length ?? 0,
    itemBuilder: (context, index) {
      var item = ledgerdata.ledgerBillData!.expenses![index];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Space between rows
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Left & right alignment
          children: [
            // Left-aligned text
            Text(
              "${item.sCRIPSYMBOL}",
              style: textStyle(const Color(0xFF696969), 14, FontWeight.w400),
            ),

            // Right-aligned text
            Text(
              "₹ ${item.nETAMT}",
              style: textStyle(colors.colorBlack, 13, FontWeight.w500),
            ),
          ],
        ),
      );
    },
  ),
)

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
                    
          
                ListView.builder(
                    physics: ScrollPhysics(),
                    itemCount: ledgerdata.ledgerBillData!.transactions!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 30.0, left: 30.0, top: 25.0),
                                child: Text(
                                  // "${dateFormatChangeForLedger(ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE.toString())}",
                                  ledgerdata.ledgerBillData!
                                      .transactions![index].sCRIPNAME!,
            
                                  style: textStyle(
                                      Colors.black, 15, FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 30.0, left: 30.0, top: 10.0),
                            child: Divider(
                              color: const Color.fromARGB(255, 117, 117, 117),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 30.0, left: 30.0, top: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      // (ledgerprovider.ledgerAllData!
                                      //             .fullStat![index].cRAMT) !=
                                      //         "0.0"
                                      //     ? "Credit : "
                                      //     : "Debit : ",
                                      "BRate/Bqty : ",
                                      style: textStyle(Color(0xFF696969), 13,
                                          FontWeight.w500),
                                    ),
                                    Text(
                                      // ledgerprovider.ledgerAllData!.fullStat![index]
                                      //             .cRAMT !=
                                      "${ledgerdata.ledgerBillData!.transactions![index].bRATE} ",
                                      style: textStyle(
                                          Colors.black, 14, FontWeight.w500),
                                    ),
                                    Text(
                                      // ledgerprovider.ledgerAllData!.fullStat![index]
                                      //             .cRAMT !=
                                      "(${ledgerdata.ledgerBillData!.transactions![index].bQTY})",
                                      style: textStyle(
                                          Colors.black, 11, FontWeight.w500),
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
                                Row(
                                  children: [
                                    Text(
                                      // (ledgerprovider.ledgerAllData!
                                      //             .fullStat![index].cRAMT) !=
                                      //         "0.0"
                                      //     ? "Credit : "
                                      //     : "Debit : ",
                                      "BAmt : ",
                                      style: textStyle(Color(0xFF696969), 13,
                                          FontWeight.w500),
                                    ),
                                    Text(
                                      // ledgerprovider.ledgerAllData!.fullStat![index]
                                      //             .cRAMT !=
                                      "${ledgerdata.ledgerBillData!.transactions![index].bAMT}",
                                      style: textStyle(
                                          Colors.black, 14, FontWeight.w500),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      // (ledgerprovider.ledgerAllData!
                                      //             .fullStat![index].cRAMT) !=
                                      //         "0.0"
                                      //     ? "Credit : "
                                      //     : "Debit : ",
                                      "SRate/Sqty : ",
                                      style: textStyle(Color(0xFF696969), 13,
                                          FontWeight.w500),
                                    ),
                                    Text(
                                      // ledgerprovider.ledgerAllData!.fullStat![index]
                                      //             .cRAMT !=
                                      "${ledgerdata.ledgerBillData!.transactions![index].sRATE} ",
                                      style: textStyle(
                                          Colors.black, 14, FontWeight.w500),
                                    ),
                                    Text(
                                      // ledgerprovider.ledgerAllData!.fullStat![index]
                                      //             .cRAMT !=
                                      "(${ledgerdata.ledgerBillData!.transactions![index].sQTY})",
                                      style: textStyle(
                                          Colors.black, 11, FontWeight.w500),
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
                                      "SAmount : ",
                                      style: textStyle(Color(0xFF696969), 13,
                                          FontWeight.w500),
                                    ),
                                    Text(
                                      // ledgerprovider.ledgerAllData!.fullStat![index]
                                      //             .cRAMT !=
                                      "${ledgerdata.ledgerBillData!.transactions![index].sAMT}",
                                      style: textStyle(
                                          Colors.black, 14, FontWeight.w500),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      // (ledgerprovider.ledgerAllData!
                                      //             .fullStat![index].cRAMT) !=
                                      //         "0.0"
                                      //     ? "Credit : "
                                      //     : "Debit : ",
                                      "NQty : ",
                                      style: textStyle(Color(0xFF696969), 13,
                                          FontWeight.w500),
                                    ),
                                    Text(
                                      // ledgerprovider.ledgerAllData!.fullStat![index]
                                      //             .cRAMT !=
                                      "${ledgerdata.ledgerBillData!.transactions![index].nETQTY} ",
                                      style: textStyle(
                                          Colors.black, 14, FontWeight.w500),
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
                                      "NAmt : ",
                                      style: textStyle(Color(0xFF696969), 13,
                                          FontWeight.w500),
                                    ),
                                    Text(
                                      ("${ledgerdata.ledgerBillData!.transactions![index].nETAMT}"),
                                      style: textStyle(
                                        double.tryParse(ledgerdata
                                                        .ledgerBillData!
                                                        .transactions![index]
                                                        .nETAMT ??
                                                    "0")! <
                                                0
                                            ? Colors.red // Red for less than 0
                                            : Colors
                                                .green, // Green for greater than or equal to 0
                                        14,
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Divider(
                              color: const Color.fromARGB(255, 212, 212, 212),
                              thickness: 2.0,
                            ),
                          ),
                        ],
                      );
                    })
              ],
            ),
          ),
                        )
                      ]);
        },
      );
    });
    
  }
}
