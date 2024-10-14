import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart'; 
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';

class PositionListGrpCard extends ConsumerWidget {
 final Map<String, dynamic> groupData;

  const PositionListGrpCard({super.key, required this. groupData});

  @override
  Widget build(BuildContext context, watch) {
    final positions = watch(portfolioProvider); 
    final theme = context.read(themeProvider);
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
                  Text("${groupData['symbol']} ",
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.scripNameTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
                  Text("${groupData['option']} ",
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.scripNameTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack))
                ]),
                Row(children: [
                  Text(" LTP: ",
                      style: textStyle(
                          const Color(0xff5E6B7D), 13, FontWeight.w600)),
                  Text("₹${groupData['lp']}",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w500))
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
                      child: Text("${groupData['exch']}",
                          overflow: TextOverflow.ellipsis,
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : const Color(0xff666666),
                              10,
                              FontWeight.w500))),
                  Text("  ${groupData['expDate']} ",
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.scripExchTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack))
                ]),
                Text(" (${groupData['perChange'] ?? 0.00}%)",
                    style: textStyle(
                        groupData['perChange'].toString().startsWith("-")
                            ? colors.darkred
                            : groupData['perChange'] == "0.00"
                                ? colors.ltpgrey
                                : colors.ltpgreen,
                        12,
                        FontWeight.w500))
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
                  Text("${groupData['s_prdt_ali']}",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          13,
                          FontWeight.w600))
                ]),
                positions.isNetPnl
                    ? Row(children: [
                        Text("P&L: ",
                            style: textStyle(
                                const Color(0xff5E6B7D), 13, FontWeight.w500)),
                        Text(
                            "₹${groupData['profitNloss'] ?? groupData['rpnl']}",
                            style: textStyle(
                                groupData['profitNloss'] != null
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
                                15,
                                FontWeight.w600))
                      ])
                    : Row(children: [
                        Text("MTM: ",
                            style: textStyle(
                                const Color(0xff5E6B7D), 13, FontWeight.w500)),
                        Text("₹${groupData['mTm']}",
                            style: textStyle(
                                groupData['mTm'].toString().startsWith("-")
                                    ? colors.darkred
                                    : groupData['mTm'] == "0.00"
                                        ? colors.ltpgrey
                                        : colors.ltpgreen,
                                15,
                                FontWeight.w600))
                      ])
              ]),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Text("Qty: ",
                        style: textStyle(
                            const Color(0xff5E6B7D), 14, FontWeight.w500)),
                    Text("${groupData['qty']}",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w500))
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

                      Text("Avg: ",
                          style: textStyle(
                              const Color(0xff5E6B7D), 14, FontWeight.w500)),
                      Text("${groupData['avgPrc']}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500))
                    ]
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
            ]));
  }
}
