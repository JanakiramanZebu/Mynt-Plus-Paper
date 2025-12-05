import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/Mobile/desk_reports/bottom_sheets/ledger_bill.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/list_divider.dart';
import 'bottom_sheets/ledger_filter.dart';

class UnpledgeHistoryScreen extends StatelessWidget {
  const UnpledgeHistoryScreen({super.key});

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
                                 SizedBox(height: 10),

            ledgerprovider.unPledgeHistoryData?.data?.isEmpty ?? true
                ? Center(
                    child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: NoDataFound(
                    secondaryEnabled: false,
                    ),
                  ))
                : Expanded(
                    child: SingleChildScrollView(
                      child: ListView.separated(
                        physics: ClampingScrollPhysics(),
                        itemCount:
                            ledgerprovider.unPledgeHistoryData?.data?.length ??
                                0,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final value =
                              ledgerprovider.unPledgeHistoryData!.data![index];
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
                                        TextWidget.subText(
                                            text: "${value.script}",
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 0),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: value.status == 'Approved'
                                              ? const Color.fromARGB(
                                                      255, 177, 255, 208)
                                                  .withOpacity(.3)
                                              : const Color.fromARGB(
                                                  255, 246, 197, 197),
                                        ),
                                        child: TextWidget.paraText(
                                          text:"${value.status}",
                                          theme: false,
                                          textOverflow: TextOverflow.ellipsis,
                                          fw: 0,
                                          maxLines: 1,
                                          color :  value.status == 'Approved'
                                                    ?  theme.isDarkMode ? colors.profitDark : colors.profitLight
                                                    :  theme.isDarkMode ? colors.lossDark : colors.lossLight
                                        ),    
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 0, left: 14.0, bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Row(
                                        children: [
                                          TextWidget.paraText(
                                              align: TextAlign.right,
                                              text: "ISIN : ",
                                               color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                          TextWidget.paraText(
                                              align: TextAlign.right,
                                              text: " ${value.iSIN}",
                                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
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
                                              text: "REQ ",
                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                          Row(
                                            children: [
                                              TextWidget.paraText(
                                                  align: TextAlign.right,
                                                  text:
                                                      " ${value.reqDatTime!.split(" ")[0]}",
                                                   color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.paraText(
                                                  align: TextAlign.right,
                                                  text:
                                                      " ${value.reqDatTime!.split(" ")[1]}",
                                                   color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
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
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 0, left: 14.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Row(
                                        children: [
                                          TextWidget.paraText(
                                              align: TextAlign.right,
                                              text: "QTY ",
                                               color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                          TextWidget.paraText(
                                              align: TextAlign.right,
                                              text: " ${value.unPlegeQty}",
                                               color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
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
                                              text: "APP ",
                                               color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                          Row(
                                            children: [
                                              TextWidget.paraText(
                                                  align: TextAlign.right,
                                                  text:
                                                      " ${value.appDatTime!.split(" ")[0]}",
                                                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                 fw: 0),
                                              TextWidget.paraText(
                                                  align: TextAlign.right,
                                                  text:
                                                      " ${value.appDatTime!.split(" ")[1]}",
                                                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
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
                              top: 8.0,
                              bottom: 0.0,
                            ),
                            child: ListDivider(),
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
