import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart'
    as auth;
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../../models/desk_reports_model/holdings_model.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class HoldingInnerDetails extends StatefulWidget {
  final Map data;
  const HoldingInnerDetails({super.key, required this.data});

  @override
  State<HoldingInnerDetails> createState() => _HoldingInnerDetails();
}

class _HoldingInnerDetails extends State<HoldingInnerDetails> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    double notional = 0.0;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ledgerdata = watch(ledgerProvider);

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
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
                child: TextWidget.heroText(
                    text: "Holding Details",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 2.0,
                  bottom: 0.0,
                ),
                child: Divider(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8),
                  thickness: 6.0,
                ),
              ),
              widget.data['avg_res'].length == 0
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
                            ListView.separated(
                              physics: ScrollPhysics(),
                              itemCount: widget.data['avg_res'].length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final indexval = widget.data['avg_res'][index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2.0, left: 16.0),
                                      child: TextWidget.subText(
                                          align: TextAlign.right,
                                          text:
                                              " ${dateFormatChangeForLedger(indexval['PUR_DATE'])} ",
                                          color: theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 1),
                                    ),
                                    Divider(
                                      color: const Color.fromARGB(
                                          255, 212, 212, 212),
                                      thickness: 0.5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 16.0, left: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              TextWidget.subText(
                                                  text: "Qty : ",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  color: Color(0xFF696969),
                                                  fw: 0),
                                              TextWidget.subText(
                                                  text:
                                                      "${indexval['QUANTITY']}",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  fw: 1),

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
                                              TextWidget.subText(
                                                  text: "Amount : ",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  color: Color(0xFF696969),
                                                  fw: 0),
                                              TextWidget.subText(
                                                  text:
                                                      "${indexval['PRICE_PREMIUM']}",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  fw: 1),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 16.0, left: 16.0, top: 10.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // Aligns text to the top
                                        children: [
                                          // Text(
                                          //   "Description: ",
                                          //   style: textStyle(Color(0xFF696969), 13, FontWeight.w500),
                                          // ),
                                          Expanded(
                                            // Ensures text wraps within available space
                                            child: Text(
                                              "${indexval['Description']}",
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow
                                                  .visible, // Ensures visibility
                                              style: textStyle(
                                                Color(0xFF696969),
                                                12,
                                                FontWeight.w500,
                                              ),
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
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 0.0,
                                  ),
                                  child: Divider(
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
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
