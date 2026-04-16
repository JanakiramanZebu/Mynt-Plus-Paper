import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';

class PledgenUnpledgeResponse extends StatelessWidget {
  final String ddd;
  const PledgenUnpledgeResponse({super.key, required this.ddd});

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

      return WillPopScope(
        onWillPop: () async {
          await ledgerprovider.getCurrentDate("pandu");
          ledgerprovider.fetchpledgeandunpledge(context);
          Navigator.pop(context);
          // print("objectobjectobjectobjectobjectobjectobjectobject");
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            // automaticallyImplyLeading: false,
            leadingWidth: 41,
            titleSpacing: 6,
            centerTitle: false,
            // leading: const CustomBackBtn(),
            elevation: 0.2,
            title: TextWidget.heroText(
                text: "Pledge Report Details" ,
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                fw: 1),
            leading: InkWell(
              onTap: () async {
                await ledgerprovider.getCurrentDate("pandu");
                ledgerprovider.fetchpledgeandunpledge(context);
                Navigator.pop(context);
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

            //   child: Icon(Icons.ios_share)),
          ),
          body: TransparentLoaderScreen(
            isLoading: ledgerprovider.reportsloading,
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
                SizedBox(
                  width: screenWidth,
                  child: Container(
                    decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffF1F3F8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              headingstat(
                                  "Client Name",
                                  '${ledgerprovider.cdslresponsedata?.cLIENTNAME}',
                                  theme,
                                  'left'),
                              Column(
                                children: [
                                  TextWidget.subText(
                                      text: "Status",
                                      color: const Color(0xFF696969),
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: ledgerprovider
                                                    .cdslresponsedata
                                                    ?.cDSLResp
                                                    ?.pledgeresdtls
                                                    ?.pledgeresdtlstwo
                                                    ?.resstatus ==
                                                '0'
                                            ? const Color.fromARGB(
                                                    255, 177, 255, 208)
                                                .withOpacity(.3)
                                            : ledgerprovider
                                                        .cdslresponsedata
                                                        ?.cDSLResp
                                                        ?.pledgeresdtls
                                                        ?.pledgeresdtlstwo
                                                        ?.resstatus ==
                                                    '1'
                                                ? const Color.fromARGB(
                                                    255, 246, 197, 197)
                                                : const Color.fromARGB(
                                                    255, 246, 235, 197),
                                      ),
                                      child: Text(
                                          ledgerprovider
                                                      .cdslresponsedata
                                                      ?.cDSLResp
                                                      ?.pledgeresdtls
                                                      ?.pledgeresdtlstwo
                                                      ?.resstatus ==
                                                  '0'
                                              ? 'Completed'
                                              : ledgerprovider
                                                          .cdslresponsedata
                                                          ?.cDSLResp
                                                          ?.pledgeresdtls
                                                          ?.pledgeresdtlstwo
                                                          ?.resstatus ==
                                                      '1'
                                                  ? 'Rejected'
                                                  : 'Pending',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: textStyle(
                                              ledgerprovider
                                                          .cdslresponsedata
                                                          ?.cDSLResp
                                                          ?.pledgeresdtls
                                                          ?.pledgeresdtlstwo
                                                          ?.resstatus ==
                                                      '0'
                                                  ? const Color.fromARGB(
                                                      193, 68, 168, 53)
                                                  : ledgerprovider
                                                              .cdslresponsedata
                                                              ?.cDSLResp
                                                              ?.pledgeresdtls
                                                              ?.pledgeresdtlstwo
                                                              ?.resstatus ==
                                                          '1'
                                                      ? const Color.fromARGB(
                                                          255, 249, 57, 57)
                                                      : const Color.fromARGB(
                                                          255, 249, 201, 57),
                                              10,
                                              FontWeight.w500)),
                                    ),
                                  ),
                                ],
                              ),

                              // headingstat(
                              //     "Status",
                              //     '${ledgerprovider.cdslresponsedata?.cDSLResp?.pledgeresdtls?.pledgeresdtlstwo?.resstatus == '1' ? 'Rejected' : ledgerprovider.cdslresponsedata?.cDSLResp?.pledgeresdtls?.pledgeresdtlstwo?.resstatus == '0' ? 'Success' : 'Pending'}',
                              //     theme),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              headingstat(
                                  "Client ID ",
                                  '${ledgerprovider.cdslresponsedata?.uccid}',
                                  theme,
                                  'left'),
                              headingstat(
                                  "CDSL Req",
                                  '${ledgerprovider.cdslresponsedata?.pledgeReqTime}',
                                  theme,
                                  'right'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              headingstat(
                                  "BO ID",
                                  '${ledgerprovider.cdslresponsedata?.clientBoId}',
                                  theme,
                                  'left'),
                              headingstat(
                                  "CDSL Res",
                                  '${ledgerprovider.cdslresponsedata?.cDSLRespTime}',
                                  theme,
                                  'right'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              headingstat(
                                  "Request ID",
                                  '${ledgerprovider.cdslresponsedata?.cDSLResp?.pledgeresdtls?.pledgeresdtlstwo?.reqid}',
                                  theme,
                                  'left'),
                              headingstat(
                                  "CDSL ID",
                                  '${ledgerprovider.cdslresponsedata?.cDSLResp?.pledgeresdtls?.pledgeresdtlstwo?.resid}',
                                  theme,
                                  'right'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.only(
                //     top: 2.0,
                //     bottom: 0.0,
                //   ),
                //   child: Divider(
                //     color: theme.isDarkMode
                //         ? const Color(0xffB5C0CF).withOpacity(.15)
                //         : const Color(0xffF1F3F8),
                //     thickness: 7.0,
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
                //           for (var item in ledgerprovider.ledgerAllData?.fullStat!)
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
                //                           .ledgerAllData?.fullStat?.length;
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

                ledgerprovider.cdslresponsedata == null ||
                        ledgerprovider.cdslresponsedata?.cDSLResp?.pledgeresdtls
                                ?.pledgeresdtlstwo?.isinresdtls ==
                            null
                    // Handle the null or empty case
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: NoDataFound(
                        secondaryEnabled: false,
                        ),
                      ))
                    : Expanded(
                        child: SingleChildScrollView(
                          child: ListView.separated(
                            physics: const ClampingScrollPhysics(),
                            itemCount: ledgerprovider
                                    .cdslresponsedata
                                    ?.cDSLResp
                                    ?.pledgeresdtls
                                    ?.pledgeresdtlstwo
                                    ?.isinresdtls
                                    ?.length ??
                                0,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final val = ledgerprovider
                                  .cdslresponsedata!
                                  .cDSLResp!
                                  .pledgeresdtls!
                                  .pledgeresdtlstwo!
                                  .isinresdtls![index];
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
                                            align: TextAlign.start,
                                            text: "${val.isin}",
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            fw: 3),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: TextWidget.paraText(
                                              align: TextAlign.start,
                                              text: "${val.quantity}",
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              fw: 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2.0),
                                    child: Divider(
                                      color: Color.fromARGB(
                                          255, 212, 212, 212),
                                      thickness: 0.5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            TextWidget.paraText(
                                                text: "Req ID :  ",
                                                color: const Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                            TextWidget.paraText(
                                                text: "${val.isinreqid}",
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
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
                                                    text: "Res ID : ",
                                                    color: const Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                                TextWidget.paraText(
                                                    text: "${val.isinresid}",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16.0, top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 16.0),
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 4),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 3),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      color: val.status == '0'
                                                          ? const Color
                                                                  .fromARGB(255,
                                                                  177, 255, 208)
                                                              .withOpacity(.3)
                                                          : const Color
                                                              .fromARGB(255,
                                                              246, 197, 197),
                                                    ),
                                                    child: Text(
                                                        val.status == '0'
                                                            ? 'Completed'
                                                            : 'Rejected',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: textStyle(
                                                            val.status == '0'
                                                                ? const Color
                                                                    .fromARGB(
                                                                    193,
                                                                    68,
                                                                    168,
                                                                    53)
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    249,
                                                                    57,
                                                                    57),
                                                            10,
                                                            FontWeight.w500)),
                                                  ),
                                                ),
                                                // TextWidget.subText(
                                                //     text: "Status : ",
                                                //     color: Color(0xFF696969),
                                                //     textOverflow:
                                                //         TextOverflow.ellipsis,
                                                //     theme: theme.isDarkMode,
                                                //     fw: 0),
                                                // TextWidget.subText(
                                                //     text:
                                                //         "${val.status == '1' ? 'Rejected' : val.status == '0' ? 'Success' : 'Pending'}",
                                                //     color: theme.isDarkMode
                                                //         ? colors.colorWhite
                                                //         : colors.colorBlack,
                                                //     textOverflow:
                                                //         TextOverflow.ellipsis,
                                                //     theme: theme.isDarkMode,
                                                //     fw: 1),
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

  int getDisplayQty(dynamic value) {
    final unPledge = int.tryParse(value.unPlegeQty.toString()) ?? 0;
    final nsoh = int.tryParse(value.nSOHQTY.toString()) ?? 0;
    final soh = int.tryParse(value.sOHQTY.toString()) ?? 0;

    if (unPledge > 0) return unPledge;
    if (nsoh > 0) return nsoh;
    if (soh > 0) return soh;

    return 0;
  }

  headingstat(String heading, String value, theme, String side) {
    return Column(
      crossAxisAlignment:
          side == 'right' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
            text: heading,
            color: const Color(0xFF696969),
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 3),
        // Text(
        //   "Opening Balance",
        //   style: textStyle(Color(0xFF696969), 14,
        //       FontWeight.w500),
        // ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextWidget.paraText(
              text: value,
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 3),
        ),
      ],
    );
  }
}
