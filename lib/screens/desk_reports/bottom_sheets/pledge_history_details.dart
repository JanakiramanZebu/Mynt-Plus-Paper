import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';

import '../../../models/desk_reports_model/pledge_history_model.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class PledgeHistoryDetails extends StatefulWidget {
  final PledgeData data;
  const PledgeHistoryDetails({super.key, required this.data});

  @override
  State<PledgeHistoryDetails> createState() => _PledgeHistoryDetails();
}

class _PledgeHistoryDetails extends State<PledgeHistoryDetails> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ledgerdata = watch(ledgerProvider);

      return DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: .4,
        maxChildSize: .99,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        child: NoDataFound(),
                      ))
                    : Expanded(
                        // height: screenheight * 0.5,
                        child: SingleChildScrollView(
                          child: ListView.separated(
                            physics: ScrollPhysics(),
                            itemCount: widget.data.reqList!.length ??
                                0,
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
                                                fw: 1),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: TextWidget.subText(
                                              align: TextAlign.right,
                                              text: "${value.status}",
                                              color: Colors.black,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0),
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
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: Row(
                                            children: [
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text: "ISIN : ",
                                                  color: Color(0xFF696969),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text: " ${value.isin}",
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: Row(
                                            children: [
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text: "Req ID : ",
                                                  color: Color(0xFF696969),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text:
                                                      " ${value.isinreqid}",
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 14.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
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
                                                  text: " ${value.quantity}",
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: Row(
                                            children: [
                                              TextWidget.subText(
                                                  align: TextAlign.right,
                                                  text: "Seg : ",
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
                                                          " ${value.segments}",
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
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
                            separatorBuilder:
                                (BuildContext context, int index) {
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
              ]);
        },
      );
    });
  }
}
