import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/desk_reports/bottom_sheets/ledger_bill.dart';
import 'package:mynt_plus/screens/desk_reports/bottom_sheets/pledge_history_details.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import 'bottom_sheets/ledger_filter.dart';

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
            ledgerprovider.pledgeHistoryData?.data?.isEmpty ?? true
                ? Center(
                    child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: NoDataFound(),
                  ))
                : Expanded(
                    child: SingleChildScrollView(
                      child: ListView.separated(
                        physics: ScrollPhysics(),
                        itemCount:
                            ledgerprovider.pledgeHistoryData?.data?.length ?? 0,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final value =
                              ledgerprovider.pledgeHistoryData!.data![index];
                          return InkWell(
                            onTap: () {
                              _showBottomSheet(
                                  context, PledgeHistoryDetails(data: value));
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, top: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          TextWidget.captionText(
                                              text: ((value.reqid).toString())
                                                  .substring(
                                                      0,
                                                      (value.reqid)
                                                              .toString()
                                                              .length -
                                                          4),
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 1),
                                          TextWidget.subText(
                                              text: ((value.reqid).toString())
                                                  .substring((value.reqid)
                                                          .toString()
                                                          .length -
                                                      4),
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
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(right: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: value.status == 'completed'
                                                ? const Color.fromARGB(
                                                        255, 177, 255, 208)
                                                    .withOpacity(.3)
                                                : const Color(0xffF6F6C5),
                                          ),
                                          child: Text(
                                              value.status == 'completed'
                                                  ? 'Completed'
                                                  : 'Requested',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: textStyle(
                                                  value.status == 'completed'
                                                      ? const Color.fromARGB(
                                                          193, 68, 168, 53)
                                                      : const Color(0xffF9B039),
                                                  10,
                                                  FontWeight.w500)),
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
                                      top: 2.0, left: 14.0, bottom: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        child: Row(
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: "Req : ",
                                                color: Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                            Row(
                                              children: [
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: " ${value.datTim}",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                // TextWidget.captionText(
                                                //     align: TextAlign.right,
                                                //     text:
                                                //         " ${value.cdslReqTime!.split(" ")[0]  }",
                                                //     color: theme.isDarkMode
                                                //         ? colors.colorWhite
                                                //         : colors.colorBlack,
                                                //     textOverflow:
                                                //         TextOverflow.ellipsis,
                                                //     theme: theme.isDarkMode,
                                                //     fw: 0),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, left: 14.0, bottom: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        child: Row(
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: "Res : ",
                                                color: Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                            Row(
                                              children: [
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:
                                                        " ${value.cdslReqTime}",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),

                                                // TextWidget.captionText(
                                                //     align: TextAlign.right,
                                                //     text:
                                                //         " ${value.datTim  }",
                                                //     color: theme.isDarkMode
                                                //         ? colors.colorWhite
                                                //         : colors.colorBlack,
                                                //     textOverflow:
                                                //         TextOverflow.ellipsis,
                                                //     theme: theme.isDarkMode,
                                                //     fw: 0),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                  ),
            SizedBox(height: 4.0),
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
