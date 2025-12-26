import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';

class PledgeHistoryScreen extends StatelessWidget {
  const PledgeHistoryScreen({super.key});

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            ledgerprovider.pledgeHistoryData?.data?.isEmpty ?? true
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: NoDataFound(
                      secondaryEnabled: false,
                    ),
                  ))
                : Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child:
                          // ListView.separated(
                          //   physics: ScrollPhysics(),
                          //   itemCount:
                          //       ledgerprovider.pledgeHistoryData?.data?.length ?? 0,
                          //   shrinkWrap: true,
                          //   itemBuilder: (context, index) {
                          //     final value =
                          //         ledgerprovider.pledgeHistoryData!.data![index];
                          //     return InkWell(
                          //       onTap: () {
                          //         _showBottomSheet(
                          //             context, PledgeHistoryDetails(data: value));
                          //       },
                          //       child: Column(
                          //         children: [

                          //           Padding(
                          //             padding: const EdgeInsets.only(
                          //                 left: 16.0, top: 8.0),
                          //             child: Row(
                          //               mainAxisAlignment:
                          //                   MainAxisAlignment.spaceBetween,
                          //               children: [
                          //                 Row(
                          //                   children: [
                          //                     // TextWidget.captionText(
                          //                     //     text: ((value.reqid).toString())
                          //                     //         .substring(
                          //                     //             0,
                          //                     //             (value.reqid)
                          //                     //                     .toString()
                          //                     //                     .length -
                          //                     //                 4),
                          //                     //     color: theme.isDarkMode
                          //                     //         ? colors.colorWhite
                          //                     //         : colors.colorBlack,
                          //                     //     textOverflow:
                          //                     //         TextOverflow.ellipsis,
                          //                     //     theme: theme.isDarkMode,
                          //                     //     fw: 1),
                          //                     // TextWidget.subText(
                          //                     //     text: ((value.reqid).toString())
                          //                     //         .substring((value.reqid)
                          //                     //                 .toString()
                          //                     //                 .length -
                          //                     //             4),
                          //                     //     color: theme.isDarkMode
                          //                     //         ? colors.colorWhite
                          //                     //         : colors.colorBlack,
                          //                     //     textOverflow:
                          //                     //         TextOverflow.ellipsis,
                          //                     //     theme: theme.isDarkMode,
                          //                     //     fw: 1),
                          //                       TextWidget.subText(
                          //                         text: ((value.reqid).toString()),
                          //                         color: theme.isDarkMode
                          //                             ? colors.colorWhite
                          //                             : colors.colorBlack,
                          //                         textOverflow:
                          //                             TextOverflow.ellipsis,
                          //                         theme: theme.isDarkMode,
                          //                         fw: 3),
                          //                   ],
                          //                 ),
                          //                 Padding(
                          //                   padding:
                          //                       const EdgeInsets.only(right: 16.0),
                          //                   child: Container(
                          //                     margin:
                          //                         const EdgeInsets.only(right: 4),
                          //                     padding: const EdgeInsets.symmetric(
                          //                         horizontal: 6, vertical: 3),
                          //                     decoration: BoxDecoration(
                          //                       borderRadius:
                          //                           BorderRadius.circular(2),
                          //                       color: value.status == 'completed'
                          //                           ? const Color.fromARGB(
                          //                                   255, 177, 255, 208)
                          //                               .withOpacity(.3)
                          //                           : const Color(0xffF6F6C5),
                          //                     ),
                          //                     child: Text(
                          //                         value.status == 'completed'
                          //                             ? 'Completed'
                          //                             : 'Requested',
                          //                         overflow: TextOverflow.ellipsis,
                          //                         maxLines: 1,
                          //                         style: textStyle(
                          //                             value.status == 'completed'
                          //                                 ? const Color.fromARGB(
                          //                                     193, 68, 168, 53)
                          //                                 : const Color(0xffF9B039),
                          //                             10,
                          //                             FontWeight.w500)),
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //            SizedBox(height: 10),
                          //           Padding(
                          //             padding: const EdgeInsets.only(
                          //                 top: 2.0, left: 14.0, bottom: 4.0),
                          //             child: Row(
                          //               mainAxisAlignment:
                          //                   MainAxisAlignment.spaceBetween,
                          //               children: [
                          //                 Padding(
                          //                   padding:
                          //                       const EdgeInsets.only(right: 16.0),
                          //                   child: Row(
                          //                     children: [
                          //                       TextWidget.paraText(
                          //                           align: TextAlign.right,
                          //                           text: "Req : ",
                          //                           color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                          //                           textOverflow:
                          //                               TextOverflow.ellipsis,
                          //                           theme: theme.isDarkMode,
                          //                           fw: 3),
                          //                       Row(
                          //                         children: [
                          //                           TextWidget.paraText(
                          //                               align: TextAlign.right,
                          //                               text: " ${value.datTim}",
                          //                               color: theme.isDarkMode
                          //                                   ? colors.textPrimaryDark
                          //                                   : colors.textPrimaryLight,
                          //                               textOverflow:
                          //                                   TextOverflow.ellipsis,
                          //                               theme: theme.isDarkMode,
                          //                               fw: 3),
                          //                           // TextWidget.captionText(
                          //                           //     align: TextAlign.right,
                          //                           //     text:
                          //                           //         " ${value.cdslReqTime!.split(" ")[0]  }",
                          //                           //     color: theme.isDarkMode
                          //                           //         ? colors.colorWhite
                          //                           //         : colors.colorBlack,
                          //                           //     textOverflow:
                          //                           //         TextOverflow.ellipsis,
                          //                           //     theme: theme.isDarkMode,
                          //                           //     fw: 0),
                          //                         ],
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.only(
                          //                 top: 2.0, left: 14.0, bottom: 4.0),
                          //             child: Row(
                          //               mainAxisAlignment:
                          //                   MainAxisAlignment.spaceBetween,
                          //               children: [
                          //                 Padding(
                          //                   padding:
                          //                       const EdgeInsets.only(right: 16.0),
                          //                   child: Row(
                          //                     children: [
                          //                       TextWidget.paraText(
                          //                           align: TextAlign.right,
                          //                           text: "Res : ",
                          //                           color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                          //                           textOverflow:
                          //                               TextOverflow.ellipsis,
                          //                           theme: theme.isDarkMode,
                          //                           fw: 3),
                          //                       Row(
                          //                         children: [
                          //                           TextWidget.paraText(
                          //                               align: TextAlign.right,
                          //                               text:
                          //                                   " ${value.cdslReqTime}",
                          //                              color: theme.isDarkMode
                          //                                   ? colors.textPrimaryDark
                          //                                   : colors.textPrimaryLight,
                          //                               textOverflow:
                          //                                   TextOverflow.ellipsis,
                          //                               theme: theme.isDarkMode,
                          //                               fw: 3),

                          //                           // TextWidget.captionText(
                          //                           //     align: TextAlign.right,
                          //                           //     text:
                          //                           //         " ${value.datTim  }",
                          //                           //     color: theme.isDarkMode
                          //                           //         ? colors.colorWhite
                          //                           //         : colors.colorBlack,
                          //                           //     textOverflow:
                          //                           //         TextOverflow.ellipsis,
                          //                           //     theme: theme.isDarkMode,
                          //                           //     fw: 0),
                          //                         ],
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          //   separatorBuilder: (BuildContext context, int index) {
                          //     // if (index != 0 &&
                          //     //     ledgerprovider.ledgerAllData!.fullStat![index - 1]
                          //     //             .vOUCHERDATE ==
                          //     //         ledgerprovider.ledgerAllData!
                          //     //             .fullStat![index ].vOUCHERDATE) {
                          //     return Padding(
                          //       padding: const EdgeInsets.only(
                          //         top: 2.0,
                          //         bottom: 0.0,
                          //       ),
                          //       child: Divider(
                          //         color: theme.isDarkMode
                          //             ? const Color(0xffB5C0CF).withOpacity(.15)
                          //             : const Color(0xffF1F3F8),
                          //         thickness: 1.0,
                          //       ),
                          //     );
                          //     // }else{
                          //     // return SizedBox();
                          //     // }
                          //   },
                          // ),
                          ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        itemCount: ledgerprovider.historyalterlist.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final value = ledgerprovider.historyalterlist[index];
                          return Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16.0, top: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            TextWidget.subText(
                                              text: "${value.symbol}",
                                              color: theme.isDarkMode
                                                  ? colors.textPrimaryDark
                                                  : colors.textPrimaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              
                                            padding:
                                                                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: value.status == '0'
                                                    ?  theme.isDarkMode ? colors.profitDark.withOpacity(0.1) : colors.profitLight.withOpacity(0.1)
                                                    : value.status == '1'
                                                        ?  theme.isDarkMode ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1)
                                                        :  theme.isDarkMode ? colors.pending.withOpacity(0.1) : colors.pending.withOpacity(0.1),
                                              ),
                                              child: 
                                              
                                              TextWidget.paraText(
                                                text:  value.status == '0'
                                                      ? 'Success'
                                                      : value.status == '1'
                                                          ? 'Rejected'
                                                          : 'Pending',
                                                          theme: false,
                                                          textOverflow: TextOverflow.ellipsis,
                                                          fw: 0,
                                                          maxLines: 1,
                                                          color :  value.status == '0'
                                                          ?  theme.isDarkMode ? colors.profitDark : colors.profitLight
                                                          : value.status ==
                                                                  '1'
                                                              ?  theme.isDarkMode ? colors.lossDark : colors.lossLight
                                                              :  theme.isDarkMode ? colors.pending : colors.pending

                                              )    
                                            ),
                                            // TextWidget.captionText(
                                            // text: "${value.reqid}",
                                            // color: theme.isDarkMode
                                            //     ? colors.colorWhite
                                            //     : colors.colorBlack,
                                            // textOverflow:
                                            //     TextOverflow.ellipsis,
                                            // theme: theme.isDarkMode,
                                            // fw: 0),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: TextWidget.paraText(
                                          align: TextAlign.right,
                                          text:
                                              " ${value.datetime.split(' ')[0]}",
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                    ),
                                  ],
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       top: 6.0, left: 14.0,  ),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Padding(
                              //         padding:
                              //             const EdgeInsets.only(right: 16.0),
                              //         child: Row(

                              //           children: [

                              //             TextWidget.captionText(
                              //                 align: TextAlign.right,
                              //                 text: " ${value.reqid}",
                              //                      color: theme.isDarkMode
                              //                     ? colors.textPrimaryDark
                              //                     : colors.textPrimaryLight,
                              //                 textOverflow:
                              //                     TextOverflow.ellipsis,
                              //                 theme: theme.isDarkMode,
                              //                 fw: 3),
                              //           ],
                              //         ),
                              //       ),
                              //       Padding(
                              //         padding:
                              //             const EdgeInsets.only(right: 16.0),
                              //         child: Row(

                              //           children: [

                              //             TextWidget.captionText(
                              //                 align: TextAlign.right,
                              //                 text: " ${value.datetime}",
                              //                      color: theme.isDarkMode
                              //                     ? colors.textPrimaryDark
                              //                     : colors.textPrimaryLight,
                              //                 textOverflow:
                              //                     TextOverflow.ellipsis,
                              //                 theme: theme.isDarkMode,
                              //                 fw: 3),
                              //           ],
                              //         ),
                              //       ),

                              //     ],
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       top: 8.0, left: 14.0,  ),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Padding(
                              //         padding:
                              //             const EdgeInsets.only(right: 16.0),
                              //         child: Row(
                              //           children: [
                              //             TextWidget.paraText(
                              //                 align: TextAlign.right,
                              //                 text: "ISIN : ",
                              //                 color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                              //                 textOverflow:
                              //                     TextOverflow.ellipsis,
                              //                 theme: theme.isDarkMode,
                              //                 fw: 3),
                              //             TextWidget.paraText(
                              //                 align: TextAlign.right,
                              //                 text: " ${value.isin}",
                              //                      color: theme.isDarkMode
                              //                     ? colors.textPrimaryDark
                              //                     : colors.textPrimaryLight,
                              //                 textOverflow:
                              //                     TextOverflow.ellipsis,
                              //                 theme: theme.isDarkMode,
                              //                 fw: 3),
                              //           ],
                              //         ),
                              //       ),
                              //       Padding(
                              //         padding:
                              //             const EdgeInsets.only(right: 16.0),
                              //         child: Row(
                              //           children: [
                              //             TextWidget.paraText(
                              //                 align: TextAlign.right,
                              //                 text: "Req ID : ",
                              //                 color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                              //                 textOverflow:
                              //                     TextOverflow.ellipsis,
                              //                 theme: theme.isDarkMode,
                              //                 fw: 3),
                              //             TextWidget.paraText(
                              //                 align: TextAlign.right,
                              //                 text: " ${value.isinreqid}",
                              //                     color: theme.isDarkMode
                              //                     ? colors.textPrimaryDark
                              //                     : colors.textPrimaryLight,
                              //                 textOverflow:
                              //                     TextOverflow.ellipsis,
                              //                 theme: theme.isDarkMode,
                              //                 fw: 3),
                              //           ],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, left: 14.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Row(
                                        children: [
                                          // TextWidget.paraText(
                                          //     align: TextAlign.right,
                                          //     text: "Qty : ",
                                          //     color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                          //     textOverflow:
                                          //         TextOverflow.ellipsis,
                                          //     theme: theme.isDarkMode,
                                          //     fw: 3),
                                          TextWidget.paraText(
                                              align: TextAlign.right,
                                              text: " ${value.quantity} QTY",
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Row(
                                        children: [
                                          TextWidget.paraText(
                                              align: TextAlign.right,
                                              text:
                                                  " ${value.datetime.split(' ')[1]}",
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                        ],
                                      ),
                                    ),
                                    // Padding(
                                    //   padding:
                                    //       const EdgeInsets.only(right: 16.0),
                                    //   child: Row(
                                    //     children: [
                                    //       TextWidget.paraText(
                                    //           align: TextAlign.right,
                                    //           text: "Seg : ",
                                    //           color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                    //           textOverflow:
                                    //               TextOverflow.ellipsis,
                                    //           theme: theme.isDarkMode,
                                    //           fw: 3),
                                    //       Row(
                                    //         children: [
                                    //           TextWidget.paraText(
                                    //               align: TextAlign.right,
                                    //               text: " ${value.segments}",
                                    //                   color: theme.isDarkMode
                                    //               ? colors.textPrimaryDark
                                    //               : colors.textPrimaryLight,
                                    //               textOverflow:
                                    //                   TextOverflow.ellipsis,
                                    //               theme: theme.isDarkMode,
                                    //               fw: 3),
                                    //         ],
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          // if (index != 0 &&
                          //     ledgerdata.ledgerAllData!.fullStat![index - 1]
                          //             .vOUCHERDATE ==
                          //         ledgerdata.ledgerAllData!
                          //             .fullStat![index ].vOUCHERDATE) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 0.0,
                            ),
                            child: Divider(
        thickness: 0,
        color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        height: 0)
                          );
                          // }else{
                          // return SizedBox();
                          // }
                        },
                      ),
                    ),
                  ),
            const SizedBox(height: 4.0),
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
