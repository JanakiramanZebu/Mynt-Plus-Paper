import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/Mobile/authentication/password/forgot_pass_unblock_user.dart';

import '../../../../models/desk_reports_model/pledge_history_model.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart';

class PledgeHistoryDetails extends StatefulWidget {
  final PledgeData data;
  const PledgeHistoryDetails({super.key, required this.data});

  @override
  State<PledgeHistoryDetails> createState() => _PledgeHistoryDetails();
}

class _PledgeHistoryDetails extends State<PledgeHistoryDetails> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ledgerdata = ref.watch(ledgerProvider);
      final theme = ref.read(themeProvider);

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
              widget.data.reqList == null
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: NoDataFound(
                        secondaryEnabled: false,
                      ),
                    ))
                  : Expanded(
                      // height: screenheight * 0.5,
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: ListView.separated(
                          physics: ClampingScrollPhysics(),
                          itemCount: widget.data.reqList!.length ?? 0,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final value = widget.data.reqList![index];
                            return Column(
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
                                          TextWidget.subText(
                                              text: "${value.symbol}",
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0),
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
                                            color: value.status == '0'
                                                ? const Color.fromARGB(
                                                        255, 177, 255, 208)
                                                    .withOpacity(.3)
                                                : value.status == '1'
                                                    ? const Color.fromARGB(
                                                        255, 246, 197, 197)
                                                    : const Color(0xffF6F6C5),
                                          ),
                                          child: Text(
                                              value.status == '0'
                                                  ? 'Success'
                                                  : value.status == '1'
                                                      ? 'Rejected'
                                                      : 'Pending',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: textStyle(
                                                  value.status == '0'
                                                      ? const Color.fromARGB(
                                                          193, 68, 168, 53)
                                                      : value.status == '1'
                                                          ? const Color
                                                              .fromARGB(
                                                              193, 187, 41, 41)
                                                          : const Color(
                                                              0xffF9B039),
                                                  10,
                                                  FontWeight.w600)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 14.0,  ),
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
                                                fw: 3),
                                            TextWidget.paraText(
                                                align: TextAlign.right,
                                                text: " ${value.isin}",
                                                     color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
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
                                                text: "Req ID : ",
                                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                            TextWidget.paraText(
                                                align: TextAlign.right,
                                                text: " ${value.isinreqid}",
                                                    color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 14.0),
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
                                                text: "Qty : ",
                                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                            TextWidget.paraText(
                                                align: TextAlign.right,
                                                text: " ${value.quantity}",
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
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
                                                text: "Seg : ",
                                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 3),
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    align: TextAlign.right,
                                                    text: " ${value.segments}",
                                                        color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
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
                                color: theme.isDarkMode
                                    ? const Color(0xffB5C0CF).withOpacity(.15)
                                    : const Color(0xffF1F3F8),
                                thickness: 1.0,
                              ),
                            );
                            // }else{
                            // return SizedBox();
                            // }
                          },
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
