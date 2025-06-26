import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart'; 
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../res/global_state_text.dart';

class PositionListGrpCard extends ConsumerWidget {
 final Map<String, dynamic> groupData;

  const PositionListGrpCard({super.key, required this. groupData});

  @override
  Widget build(BuildContext context, ref) {
    final positions = ref.watch(portfolioProvider); 
    final theme = ref.read(themeProvider);
    return Container(
        color: theme.isDarkMode
            ? groupData['qty'] == "0"
                ? colors.darkGrey
                : colors.colorBlack
            : Color(groupData['qty'] == "0" ? 0xffF1F3F8 : 0xffffffff),
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  TextWidget.subText(
                    text: "${groupData['symbol']} ",
                    theme: theme.isDarkMode,
                    textOverflow: TextOverflow.ellipsis,
                    fw: 1,
                  ),
                  TextWidget.subText(
                    text: "${groupData['option']} ",
                    theme: theme.isDarkMode,
                    textOverflow: TextOverflow.ellipsis,
                    fw: 1,
                  )
                ]),
                Row(children: [
                  TextWidget.subText(
                    text: " LTP: ",
                    theme: theme.isDarkMode,
                    color: const Color(0xff5E6B7D),
                    fw: 1,
                  ),
                  TextWidget.subText(
                    text: "₹${groupData['lp']}",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                    fw: 0,
                  )
                ])
              ]),

              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: theme.isDarkMode
                              ? groupData['qty'] == "0"
                                  ? colors.colorBlack
                                  : const Color(0xff666666).withOpacity(.2)
                              : groupData['qty'] == "0"
                                  ? colors.colorWhite
                                  : const Color(0xffECEDEE)),
                      child: TextWidget.captionText(
                        text: "${groupData['exch']}",
                        theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                            : const Color(0xff666666),
                        textOverflow: TextOverflow.ellipsis,
                        fw: 0,
                      )),
                  TextWidget.paraText(
                    text: "  ${groupData['expDate']} ",
                    theme: theme.isDarkMode,
                    textOverflow: TextOverflow.ellipsis,
                    fw: 0,
                  )
                ]),
                TextWidget.paraText(
                  text: " (${groupData['perChange'] ?? 0.00}%)",
                  theme: theme.isDarkMode,
                  color: groupData['perChange'].toString().startsWith("-")
                            ? colors.darkred
                            : groupData['perChange'] == "0.00"
                                ? colors.ltpgrey
                                : colors.ltpgreen,
                  fw: 0,
                )
              ]),
              Divider(
                  color: theme.isDarkMode
                      ? colors.darkGrey
                      : Color(
                          groupData['netqty'] == "0" ? 0xffffffff : 0xffECEDEE),
                  thickness: 1.2),
              const SizedBox(height: 2),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  TextWidget.subText(
                    text: "${groupData['s_prdt_ali']}",
                    theme: theme.isDarkMode,
                    fw: 1,
                  )
                ]),
                positions.isNetPnl
                    ? Row(children: [
                        TextWidget.subText(
                          text: "P&L: ",
                          theme: theme.isDarkMode,
                          color: const Color(0xff5E6B7D),
                          fw: 0,
                        ),
                        TextWidget.titleText(
                          text:
                            "₹${groupData['profitNloss'] ?? groupData['rpnl']}",
                          theme: theme.isDarkMode,
                          color: groupData['profitNloss'] != null
                                    ? groupData['profitNloss']!.startsWith("-")
                                        ? colors.darkred
                                        : groupData['profitNloss'] == "0.00"
                                            ? colors.ltpgrey
                                            : colors.ltpgreen
                                    : groupData['rpnl'].toString().startsWith("-")
                                        ? colors.darkred
                                        : groupData['rpnl'] == "0.00"
                                            ? colors.ltpgrey
                                            : colors.ltpgreen,
                          fw: 1,
                        )
                      ])
                    : Row(children: [
                        TextWidget.subText(
                          text: "MTM: ",
                          theme: theme.isDarkMode,
                          color: const Color(0xff5E6B7D),
                          fw: 0,
                        ),
                        TextWidget.titleText(
                          text: "₹${groupData['mTm']}",
                          theme: theme.isDarkMode,
                          color: groupData['mTm'].toString().startsWith("-")
                                    ? colors.darkred
                                    : groupData['mTm'] == "0.00"
                                        ? colors.ltpgrey
                                        : colors.ltpgreen,
                          fw: 1,
                        )
                      ])
              ]),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                  TextWidget.subText(
                    text: "Qty: ",
                    theme: theme.isDarkMode,
                    color: const Color(0xff5E6B7D),
                    fw: 0,
                  ),
                  TextWidget.subText(
                    text: "${groupData['qty']}",
                    theme: theme.isDarkMode,
                    fw: 0,
                  )
                  ]),
                  Row(
                    children: [
                      // Text("MTM: ",
                      //     style: textStyle(
                      //         const Color(0xff5E6B7D), 14, FontWeight.w500)),
                      // Text("₹${groupData[mTm}",
                      //     style: textStyle(
                      //         Color(groupData[mTm!.startsWith("-")
                      //             ? 0XFFFF1717
                      //             : groupData[mTm == "0.00"
                      //                 ? 0xff999999
                      //                 : 0xff43A833),
                      //         15,
                      //         FontWeight.w600)),
                  TextWidget.subText(
                    text: "Avg: ",
                    theme: theme.isDarkMode,
                    color: const Color(0xff5E6B7D),
                    fw: 0,
                  ),
                  TextWidget.subText(
                    text: "${groupData['avgPrc']}",
                    theme: theme.isDarkMode,
                    fw: 0,
                  )
                ]
              ),
              // const SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Row(
              //       children: [
              //         Text("Avg: ",
              //             style: textStyle(
              //                 const Color(0xff5E6B7D), 14, FontWeight.w500)),
              //         Text("${groupData[netavgprc}",
              //             style: textStyle(6
              //                 const Color(0xff000000), 14, FontWeight.w500)),
              //       ],
              //     ),
              //     // Row(
              //     //   children: [
              //     //     Text("LTP: ",
              //     //         style: textStyle(
              //     //             const Color(0xff5E6B7D), 14, FontWeight.w600)),
              //     //     Text("${groupData[lp}",
              //     //         style: textStyle(
              //     //             const Color(0xff000000), 15, FontWeight.w600)),
              //     //   ],
              //     // ),
              //   ],
              // ),
              ])
            ]));
  }
}
