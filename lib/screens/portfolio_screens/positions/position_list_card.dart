import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class PositionListCard extends ConsumerWidget {
  final PositionBookModel positionList;

  const PositionListCard({super.key, required this.positionList});

  @override
  Widget build(BuildContext context, watch) {
    final positions = watch(portfolioProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    final theme = context.read(themeProvider);
    return Container(
        color: theme.isDarkMode
            ? positionList.qty == "0"
                ? colors.darkGrey
                : colors.colorBlack
            : Color(positionList.qty == "0" ? 0xffF1F3F8 : 0xffffffff),
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("${positionList.symbol} ",
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.scripNameTxtStyle.copyWith(
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack)),
                      Text("${positionList.option} ",
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.scripNameTxtStyle.copyWith(
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack)),
                    ],
                  ),
                  if (socketDatas.containsKey(positionList.token)) ...[
                    Row(
                      children: [
                        Text(" LTP: ",
                            style: textStyle(
                                const Color(0xff5E6B7D), 13, FontWeight.w600)),
                        Text("₹${positionList.lp}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                      ],
                    ),
                  ]
                ],
              ),

              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                             color: theme.isDarkMode
                                ? positionList.qty == "0"
                                    ? colors.colorBlack
                                    : const Color(0xff666666).withOpacity(.2)
                                : positionList.qty == "0"
                                    ? colors.colorWhite
                                    : const Color(0xffECEDEE)),
                        child: Text("${positionList.exch}",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                              theme.isDarkMode
                              ?colors.colorWhite
                                :const Color(0xff666666), 10, FontWeight.w500)),
                      ),
                      Text("  ${positionList.expDate} ",
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.scripExchTxtStyle.copyWith(
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack)),
                    ],
                  ),
                  if (socketDatas.containsKey(positionList.token)) ...[
                    Text(" (${positionList.perChange ?? 0.00}%)",
                        style: textStyle(
                            positionList.perChange!.startsWith("-")
                                ? colors.darkred
                                : positionList.perChange == "0.00"
                                    ? colors.ltpgrey
                                    : colors.ltpgreen,
                            12,
                            FontWeight.w500)),
                  ]
                ],
              ),
              Divider(
                  color: theme.isDarkMode
                      ? colors.darkGrey
                      : Color(
                          positionList.netqty == "0" ? 0xffffffff : 0xffECEDEE),
                  thickness: 1.2),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("${positionList.sPrdtAli}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              13,
                              FontWeight.w600)),
                    ],
                  ),
                  positions.isNetPnl
                      ? Row(
                          children: [
                            Text("P&L: ",
                                style: textStyle(const Color(0xff5E6B7D), 13,
                                    FontWeight.w500)),
                            Text(
                                "₹${positionList.profitNloss ?? positionList.rpnl}",
                                style: textStyle(
                                  positionList.profitNloss != null
                                        ? positionList.profitNloss!
                                                .startsWith("-")
                                            ? colors.darkred
                                            : positionList.profitNloss == "0.00"
                                                ? colors.ltpgrey
                                                : colors.ltpgreen
                                        : positionList.rpnl!.startsWith("-")
                                            ? colors.darkred
                                            : positionList.rpnl == "0.00"
                                                ? colors.ltpgrey
                                                : colors.ltpgreen,
                                    15,
                                    FontWeight.w600)),
                          ],
                        )
                      : Row(
                          children: [
                            Text("MTM: ",
                                style: textStyle(const Color(0xff5E6B7D), 13,
                                    FontWeight.w500)),
                            Text("₹${positionList.mTm}",
                                style: textStyle(
                                    positionList.mTm!.startsWith("-")
                                        ? colors.darkred
                                        : positionList.mTm == "0.00"
                                            ? colors.ltpgrey
                                            : colors.ltpgreen,
                                    15,
                                    FontWeight.w600)),
                          ],
                        ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("Qty: ",
                          style: textStyle(
                              const Color(0xff5E6B7D), 14, FontWeight.w500)),
                      Text("${positionList.qty}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                    ],
                  ),
                  Row(
                    children: [
                      // Text("MTM: ",
                      //     style: textStyle(
                      //         const Color(0xff5E6B7D), 14, FontWeight.w500)),
                      // Text("₹${positionList.mTm}",
                      //     style: textStyle(
                      //         Color(positionList.mTm!.startsWith("-")
                      //             ? 0XFFFF1717
                      //             : positionList.mTm == "0.00"
                      //                 ? 0xff999999
                      //                 : 0xff43A833),
                      //         15,
                      //         FontWeight.w600)),

                      Text("Avg: ",
                          style: textStyle(
                              const Color(0xff5E6B7D), 14, FontWeight.w500)),
                      Text("${positionList.avgPrc}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                    ],
                  ),
                ],
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
              //         Text("${positionList.netavgprc}",
              //             style: textStyle(6
              //                 const Color(0xff000000), 14, FontWeight.w500)),
              //       ],
              //     ),
              //     // Row(
              //     //   children: [
              //     //     Text("LTP: ",
              //     //         style: textStyle(
              //     //             const Color(0xff5E6B7D), 14, FontWeight.w600)),
              //     //     Text("${positionList.lp}",
              //     //         style: textStyle(
              //     //             const Color(0xff000000), 15, FontWeight.w600)),
              //     //   ],
              //     // ),
              //   ],
              // ),
            ]));
  }

   
}
