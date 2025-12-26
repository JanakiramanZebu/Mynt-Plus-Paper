import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';

class CAEventRights extends StatelessWidget {
  const CAEventRights({super.key});

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

      String opbalance = ledgerprovider.ledgerAllData?.openingBalance ?? '0.0';
      // String tdebit = ledgerprovider.ledgerAllData?.drAmt ?? '0.0';
      // String tcredit = ledgerprovider.ledgerAllData?.crAmt ?? '0.0';
      String clbalance = ledgerprovider.ledgerAllData?.closingBalance ?? '0.0';

      return Scaffold(
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

              ledgerprovider.caeventalldata?.rights?.isEmpty ?? true
                  ? const Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: NoDataFound(),
                    ))
                  : Expanded(
                      child: SingleChildScrollView(
                        child: ListView.separated(
                          physics: const ScrollPhysics(),
                          itemCount:
                              ledgerprovider.caeventalldata?.rights?.length ??
                                  0,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Column(
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
                                      SizedBox(
                                        width: screenWidth * 0.60,
                                        child: TextWidget.subText(
                                            text:
                                                "${ledgerprovider.caeventalldata!.rights![index].companyName}",
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 1),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        child: TextWidget.subText(
                                            align: TextAlign.right,
                                            text:
                                                "${double.tryParse(ledgerprovider.caeventalldata!.rights![index].ratioN.toString())!.toInt()} : ${double.tryParse(ledgerprovider.caeventalldata!.rights![index].rationD.toString())!.toInt()}",
                                            color: Colors.black,
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 0),
                                      ),
                                    ],
                                  ),
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Divider(
                                    color: Color.fromARGB(
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
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text: "Rec Date : ",
                                                  color: const Color(0xFF696969),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text:
                                                      "${ledgerprovider.caeventalldata!.rights![index].recordDate}",
                                                  color: theme.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text: "Premium : ",
                                                  color: const Color(0xFF696969),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text:
                                                      " ${ledgerprovider.caeventalldata!.rights![index].premiumRs}",
                                                  color: theme.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: "Ex Date : ",
                                                color: const Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text:
                                                    "${ledgerprovider.caeventalldata!.rights![index].exRightsDate}",
                                                color: theme.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
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
                              ],
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
