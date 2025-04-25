import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class MfHoldNewScreen extends ConsumerWidget {
  const MfHoldNewScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final fund = watch(fundProvider);
    final mfData = watch(mfProvider);
    final mfHolding = watch(portfolioProvider);

    return Scaffold(
      body: Stack(
        children: [
          // TransparentLoaderScreen(
          //   isLoading: mfData.bestmfloader!,
          Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffF1F3F8)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Invested",
                                      style: textStyle(const Color(0xff5E6B7D),
                                          12, FontWeight.w500)),
                                  const SizedBox(height: 6),
                                  Text(
                                      "₹${(mfData.mfholdingnew?.purchaseValue == "" || mfData.mfholdingnew?.purchaseValue == null) ? "0.00" : mfData.mfholdingnew?.purchaseValue}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Abs Returns %",
                                      style: textStyle(const Color(0xff5E6B7D),
                                          12, FontWeight.w500)),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${(mfData.mfholdingnew?.gainOrLoss == "" || mfData.mfholdingnew?.gainOrLoss == null) ? "0.00" : mfData.mfholdingnew?.gainOrLoss}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: (double.tryParse(mfData
                                                              .mfholdingnew
                                                              ?.gainOrLoss ??
                                                          "0") ??
                                                      0) >=
                                                  0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      Text(
                                        "(${mfData.mfholdingnew?.percentage?.toString() ?? "0"}%)",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: (double.tryParse(mfData
                                                              .mfholdingnew
                                                              ?.percentage
                                                              ?.toString() ??
                                                          "0") ??
                                                      0) >=
                                                  0
                                              ? Colors.green
                                              : const Color(
                                                  0xFFFF1717), // Red color for negative values
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Current Value",
                                        style: textStyle(
                                            const Color(0xff5E6B7D),
                                            12,
                                            FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Text(
                                        "₹${mfData.mfholdingnew?.currentValue}",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w500)),
                                  ],
                                ),
                                // Column(
                                //     crossAxisAlignment: CrossAxisAlignment.end,
                                //     children: [
                                //       Text("1D Change",
                                //           style: textStyle(
                                //               const Color(0xff5E6B7D),
                                //               12,
                                //               FontWeight.w500)),
                                //       const SizedBox(height: 6),
                                //       Row(children: [
                                //         Text(
                                //             "₹${getFormatter(value: oneDayChng, v4d: false, noDecimal: false)}",
                                //             style: textStyle(
                                //                 oneDayChng
                                //                         .toStringAsFixed(2)
                                //                         .startsWith("-")
                                //                     ? colors.darkred
                                //                     : colors.ltpgreen,
                                //                 16,
                                //                 FontWeight.w500)),
                                //         Text(
                                //             " (${oneDayChngPer.isNaN ? "0.00" : oneDayChngPer.toStringAsFixed(2)}%)",
                                //             style: textStyle(
                                //                 oneDayChngPer
                                //                         .toStringAsFixed(2)
                                //                         .startsWith("-")
                                //                     ? colors.darkred
                                //                     : colors.ltpgreen,
                                //                 14,
                                //                 FontWeight.w500))
                                //       ])
                                //     ])
                              ])
                        ])),

                //               Container(
                //                 padding: const EdgeInsets.all(16),
                //                 decoration: BoxDecoration(
                //                   color: theme.isDarkMode
                //                       ? const Color(0xffB5C0CF).withOpacity(.15)
                //                       : const Color(0xffF1F3F8),
                //                 ),
                //                 child: Column(
                //                   children: [
                //                     Row(
                //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                       children: [
                //                         Column(
                //                           crossAxisAlignment: CrossAxisAlignment.start,
                //                           children: [
                //                             Text(
                //                               "Invested",
                //                               style: textStyle(const Color(0xff5E6B7D), 14,
                //                                   FontWeight.w500),
                //                             ),
                //                             const SizedBox(height: 8),
                //                             Text(
                //                               "₹${(mfData.mfholdingnew?.purchaseValue == "" || mfData.mfholdingnew?.purchaseValue == null) ? "0.00" : mfData.mfholdingnew?.purchaseValue}",
                //                               style: textStyle(
                //                                 theme.isDarkMode
                //                                     ? colors.colorWhite
                //                                     : colors.colorBlack,
                //                                 14,
                //                                 FontWeight.w500,
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                         Column(
                //                           crossAxisAlignment: CrossAxisAlignment.end,
                //                           children: [
                //                             Text(
                //                               "Abs Returns %",
                //                               style: textStyle(const Color(0xff5E6B7D), 14,
                //                                   FontWeight.w500),
                //                             ),
                //                             const SizedBox(height: 8),
                //                             Row(
                //                               crossAxisAlignment: CrossAxisAlignment.end,
                //                               children: [
                //                                 Text(
                //                                    "${(mfData.mfholdingnew?.gainOrLoss == "" ||mfData.mfholdingnew?.gainOrLoss == null) ? "0.00" : mfData.mfholdingnew?.gainOrLoss}",
                //                                    style: TextStyle(
                //                                 fontSize: 14,
                //                                 fontWeight: FontWeight.w500,
                //                                 color: (double.tryParse(mfData.mfholdingnew
                //                                                     ?.gainOrLoss ??
                //                                                 "0") ??
                //                                             0) >=
                //                                         0
                //                                     ? Colors.green
                //                                     : Colors.red,
                //                               ),
                //                                 ),
                //                                 Text(
                //                                   "(${mfData.mfholdingnew?.percentage?.toString() ?? "0"}%)",
                //                                   style: TextStyle(
                //   fontSize: 14,
                //   fontWeight: FontWeight.w500,
                //   color: (double.tryParse(mfData.mfholdingnew?.percentage?.toString() ?? "0") ?? 0) >= 0
                //       ? Colors.green
                //       : const Color(0xFFFF1717), // Red color for negative values
                // ),
                //                                 ),
                //                               ],
                //                             ),
                //                           ],
                //                         ),
                //                       ],
                //                     ),
                //                   ],
                //                 ),
                //               ),
                // const SizedBox(height: 10),
                mfData.mfholdingnew?.stat == "Not Ok"
                    ? const Padding(
                        padding: EdgeInsets.only(top: 280),
                        child: Center(child: NoDataFound()),
                      )
                    : mfData.mfholdingnew?.msg == "No Data Found"
                        ? const Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: Center(child: NoDataFound()),
                          )
                        :

                        // Expanded(
                        //     child: ListView.builder(
                        //       padding: const EdgeInsets.all(0),
                        //       itemCount: mfData.mfholdingnew?.data?.length ?? 0,
                        //       itemBuilder: (BuildContext context, int index) {
                        //         return Column(
                        //           children: [
                        //             InkWell(
                        //               onTap: () async {
                        //                 mfData.fetchmfholdsingpage(
                        //                     "${mfData.mfholdingnew!.data?[index].iSIN}");
                        //                 Navigator.pushNamed(
                        //                     context, Routes.mfholdsinlepage);
                        //                 // mfData.loaderfun();
                        //                 // await mfData.fetchmfholdsinglelist(
                        //                 //     "${mfData.mfholdingnew!.data?[index].iSIN}");
                        //                 // if (mfData.mfholdsingepage?.stat == "Ok") {
                        //                 //   Navigator.pushNamed(
                        //                 //       context, Routes.mfholdsinlepage);
                        //                 // } else {
                        //                 //   ScaffoldMessenger.of(context).showSnackBar(
                        //                 //       successMessage(context, "Error In Server"));
                        //                 // }
                        //               },
                        //               child: Container(
                        //                 decoration: BoxDecoration(
                        //                   border: Border.symmetric(
                        //                     vertical: BorderSide(
                        //                       color: theme.isDarkMode
                        //                           ? colors.darkGrey
                        //                           : const Color(0xffEEF0F2),
                        //                       width: 0,
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 padding: const EdgeInsets.all(11),
                        //                 child: Column(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.start,
                        //                   children: [
                        //                     Row(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment
                        //                               .spaceBetween,
                        //                       children: [
                        //                         Expanded(
                        //                           child: Column(
                        //                             crossAxisAlignment:
                        //                                 CrossAxisAlignment
                        //                                     .start,
                        //                             children: [
                        //                               Row(
                        //                                 children: [
                        //                                   Expanded(
                        //                                     flex:
                        //                                         3, // Takes 75% of the width
                        //                                     child: Padding(
                        //                                       padding:
                        //                                           const EdgeInsets
                        //                                               .only(
                        //                                               left:
                        //                                                   8.0),
                        //                                       child: Text(
                        //                                         "${mfData.mfholdingnew!.data?[index].sCHEMENAME}",
                        //                                         maxLines: 2,
                        //                                         overflow:
                        //                                             TextOverflow
                        //                                                 .ellipsis,
                        //                                         style: textStyles
                        //                                             .scripNameTxtStyle
                        //                                             .copyWith(
                        //                                           color: theme.isDarkMode
                        //                                               ? colors
                        //                                                   .colorWhite
                        //                                               : colors
                        //                                                   .colorBlack,
                        //                                         ),
                        //                                       ),
                        //                                     ),
                        //                                   ),
                        //                                   const Spacer(),
                        //                                   Align(
                        //                                     alignment: Alignment
                        //                                         .centerRight, // Aligns the entire Column to the right
                        //                                     child: Column(
                        //                                       crossAxisAlignment:
                        //                                           CrossAxisAlignment
                        //                                               .end, // Aligns text to the right
                        //                                       children: [
                        //                                         Text(
                        //                                           "₹ ${(((double.tryParse(mfData.mfholdingnew!.data?[index]?.sCRIPVALUE ?? '0') ?? 0) * (double.tryParse(mfData.mfholdingnew!.data?[index]?.nET ?? '0') ?? 0)) - ((double.tryParse(mfData.mfholdingnew!.data?[index]?.buyPrice ?? '0') ?? 0) * (double.tryParse(mfData.mfholdingnew!.data?[index]?.nET ?? '0') ?? 0))).toStringAsFixed(2)} ",
                        //                                           style:
                        //                                               textStyle(
                        //                                             (((double.tryParse(mfData.mfholdingnew!.data?[index]?.sCRIPVALUE ?? '0') ?? 0) * (double.tryParse(mfData.mfholdingnew!.data?[index]?.nET ?? '0') ?? 0)) - ((double.tryParse(mfData.mfholdingnew!.data?[index]?.buyPrice ?? '0') ?? 0) * (double.tryParse(mfData.mfholdingnew!.data?[index]?.nET ?? '0') ?? 0))) >=
                        //                                                     0
                        //                                                 ? Colors
                        //                                                     .green
                        //                                                 : Colors
                        //                                                     .red,
                        //                                             14,
                        //                                             FontWeight
                        //                                                 .w500,
                        //                                           ),
                        //                                         ),
                        //                                         Text(
                        //                                           "(${(double.tryParse(mfData.mfholdingnew!.data?[index]?.percentage ?? '0') ?? 0).toStringAsFixed(2)}%)",
                        //                                           style:
                        //                                               textStyle(
                        //                                             (double.tryParse(mfData.mfholdingnew!.data?[index]?.percentage ?? '0') ??
                        //                                                         0) >=
                        //                                                     0
                        //                                                 ? Colors
                        //                                                     .green
                        //                                                 : Colors
                        //                                                     .red, // Color selection based on value
                        //                                             14,
                        //                                             FontWeight
                        //                                                 .w500,
                        //                                           ),
                        //                                         )
                        //                                       ],
                        //                                     ),
                        //                                   )
                        //                                 ],
                        //                               ),
                        //                             ],
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //             Divider(
                        //               color: theme.isDarkMode
                        //                   ? colors.darkColorDivider
                        //                   : const Color(0xffECEDEE),
                        //               thickness: 2.0,
                        //             ),
                        //           ],
                        //         );
                        //       },
                        //     ),
                        //   ),
                        const SizedBox(height: 4),

                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: mfData.mfholdingnew?.data?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final item = mfData.mfholdingnew?.data?[index];
                      if (item == null) return SizedBox();

                      String ltp =
                          '544949'; 
                      String ch =
                          '0.00';
                      String chp =
                          '0.00';
                      String val = item.current ?? '0.00';

                      return Container(
                        
                        padding: const EdgeInsets.all(8),
                        child: InkWell(
                             onTap: () async {
                              mfData.fetchmfholdsingpage( "${item.iSIN}");
                                Navigator.pushNamed(
                                    context, Routes.mfholdsinlepage);
        },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              // Name + LTP
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${item.sCHEMENAME}",
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyles.scripNameTxtStyle.copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(" NAV: ",
                                          style: textStyle(Color(0xff5E6B7D), 13,
                                              FontWeight.w600)),
                                      Text("₹ ${item.nav}",
                                          style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w500,
                                          )),
                                    ],
                                  )
                                ],
                              ),
                          
                              const SizedBox(height: 4),
                          
                              // Exchange badge + change %
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomExchBadge(
                                      exch: "NSE"), // hardcoded NSE like old
                                  // Text(
                                  //   "$ch ($chp%)",
                                  //   style: textStyle(
                                  //     ch.startsWith("-")
                                  //         ? colors.darkred
                                  //         : ch == "0.00"
                                  //             ? colors.ltpgrey
                                  //             : colors.ltpgreen,
                                  //     12,
                                  //     FontWeight.w500,
                                  //   ),
                                  // )
                                ],
                              ),
                              const SizedBox(height: 4),
                          
                              Divider(
                                height: 12,
                                thickness: 0.4,
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider,
                              ),
                          
                              // Qty + Current Value
                              const SizedBox(height: 4),
                          
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Units: ",
                                          style: textStyle(Color(0xff5E6B7D), 14,
                                              FontWeight.w500)),
                                      Text(
                                        "${item.nET ?? 0} @ ${item.buyPrice}",
                                        style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "₹${(double.tryParse(item.gainOrLoss ?? '') ?? 0.0).toStringAsFixed(2)}",
                                        style: textStyle(
                                          (double.tryParse(item.gainOrLoss ??
                                                          '') ??
                                                      0.0) >=
                                                  0
                                              ? Colors.green
                                              : Colors.red,
                                          14,
                                          FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "(${(double.tryParse(item.percentage ?? '') ?? 0.0).toStringAsFixed(2)}%)",
                                        style: textStyle(
                                          (double.tryParse(item.percentage ??
                                                          '') ??
                                                      0.0) >=
                                                  0
                                              ? Colors.green
                                              : Colors.red,
                                          14,
                                          FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          
                              const SizedBox(height: 8),
                          
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Inv: ₹ ",
                                          style: textStyle(Color(0xff5E6B7D), 14,
                                              FontWeight.w500)),
                                      Text(
                                       "${(double.tryParse(item.purchase ?? '') ?? 0.0).toStringAsFixed(4)}",
                                        style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Cur: ",
                                          style: textStyle(Color(0xff5E6B7D), 14,
                                              FontWeight.w500)),
                                      Text(
                                          "₹${double.tryParse(val)?.toStringAsFixed(2) ?? '0.00'}",
                                          style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w500,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                          
                              const SizedBox(height: 16),
                              Divider(
                                height: 0,
                                thickness: 2,
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider,
                              ),
                            ],
                          ),
                        ),
                     
                     
                      );
                    }
                  )
                )
            
            
            
            
              ],
            ),
            // ),
          ),
        ],
      ),
    );
  }
}
