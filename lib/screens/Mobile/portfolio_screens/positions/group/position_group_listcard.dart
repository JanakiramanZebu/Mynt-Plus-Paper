import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../../../../provider/portfolio_provider.dart';
import '../../../../../provider/thems.dart'; 
import '../../../../../res/res.dart';
import '../../../../../res/mynt_web_text_styles.dart';
import '../../../../../res/mynt_web_color_styles.dart';

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
                  Text(
                    "${groupData['symbol']} ",
                    style: MyntWebTextStyles.body(
                      context,
                      color: theme.isDarkMode
                          ? MyntColors.textPrimaryDark
                          : MyntColors.textPrimary,
                      fontWeight: MyntFonts.semiBold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${groupData['option']} ",
                    style: MyntWebTextStyles.body(
                      context,
                      color: theme.isDarkMode
                          ? MyntColors.textPrimaryDark
                          : MyntColors.textPrimary,
                      fontWeight: MyntFonts.semiBold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                ]),
                Row(children: [
                  Text(
                    " LTP: ",
                    style: MyntWebTextStyles.body(
                      context,
                      color: const Color(0xff5E6B7D),
                      fontWeight: MyntFonts.semiBold,
                    ),
                  ),
                  Text(
                    "₹${groupData['lp']}",
                    style: MyntWebTextStyles.body(
                      context,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      fontWeight: MyntFonts.medium,
                    ),
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
                      child: Text(
                        "${groupData['exch']}",
                        style: MyntWebTextStyles.para(
                          context,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : const Color(0xff666666),
                          fontWeight: MyntFonts.medium,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                  Text(
                    "  ${groupData['expDate']} ",
                    style: MyntWebTextStyles.para(
                      context,
                      color: theme.isDarkMode
                          ? MyntColors.textPrimaryDark
                          : MyntColors.textPrimary,
                      fontWeight: MyntFonts.medium,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                ]),
                Text(
                  " (${groupData['perChange'] ?? 0.00}%)",
                  style: MyntWebTextStyles.para(
                    context,
                    color: groupData['perChange'].toString().startsWith("-")
                        ? colors.darkred
                        : groupData['perChange'] == "0.00"
                            ? colors.ltpgrey
                            : colors.ltpgreen,
                    fontWeight: MyntFonts.medium,
                  ),
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
                  Text(
                    "${groupData['s_prdt_ali']}",
                    style: MyntWebTextStyles.body(
                      context,
                      color: theme.isDarkMode
                          ? MyntColors.textPrimaryDark
                          : MyntColors.textPrimary,
                      fontWeight: MyntFonts.semiBold,
                    ),
                  )
                ]),
                positions.isNetPnl
                    ? Row(children: [
                        Text(
                          "P&L: ",
                          style: MyntWebTextStyles.body(
                            context,
                            color: const Color(0xff5E6B7D),
                            fontWeight: MyntFonts.medium,
                          ),
                        ),
                        Text(
                          "₹${groupData['profitNloss'] ?? groupData['rpnl']}",
                          style: MyntWebTextStyles.title(
                            context,
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
                            fontWeight: MyntFonts.semiBold,
                          ),
                        )
                      ])
                    : Row(children: [
                        Text(
                          "MTM: ",
                          style: MyntWebTextStyles.body(
                            context,
                            color: const Color(0xff5E6B7D),
                            fontWeight: MyntFonts.medium,
                          ),
                        ),
                        Text(
                          "₹${groupData['mTm']}",
                          style: MyntWebTextStyles.title(
                            context,
                            color: groupData['mTm'].toString().startsWith("-")
                                ? colors.darkred
                                : groupData['mTm'] == "0.00"
                                    ? colors.ltpgrey
                                    : colors.ltpgreen,
                            fontWeight: MyntFonts.semiBold,
                          ),
                        )
                      ])
              ]),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                  Text(
                    "Qty: ",
                    style: MyntWebTextStyles.body(
                      context,
                      color: const Color(0xff5E6B7D),
                      fontWeight: MyntFonts.medium,
                    ),
                  ),
                  Text(
                    "${groupData['qty']}",
                    style: MyntWebTextStyles.body(
                      context,
                      color: theme.isDarkMode
                          ? MyntColors.textPrimaryDark
                          : MyntColors.textPrimary,
                      fontWeight: MyntFonts.medium,
                    ),
                  )
                  ]),
                  Row(
                    children: [
                  Text(
                    "Avg: ",
                    style: MyntWebTextStyles.body(
                      context,
                      color: const Color(0xff5E6B7D),
                      fontWeight: MyntFonts.medium,
                    ),
                  ),
                  Text(
                    "${groupData['avgPrc']}",
                    style: MyntWebTextStyles.body(
                      context,
                      color: theme.isDarkMode
                          ? MyntColors.textPrimaryDark
                          : MyntColors.textPrimary,
                      fontWeight: MyntFonts.medium,
                    ),
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
