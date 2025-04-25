// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_timeline.dart';
import 'package:mynt_plus/screens/mutual_fund/redeem_new_bottomsheet.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/ipo_time_line.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
// import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/loader_ui.dart';
import '../mutual_fund_old/cancle_xsip_resone.dart';
// import '../mutual_fund_old/mf_order_filter_sheet.dart';
import '../portfolio_screens/mfHoldings/mf_holding_screen.dart';
import '../mutual_fund/mf_cancel_alert.dart';

class mfholdsinlepage extends StatefulWidget {
  const mfholdsinlepage({super.key});
  @override
  State<mfholdsinlepage> createState() => _mfholdsinlepage();
}

class _mfholdsinlepage extends State<mfholdsinlepage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final theme = watch(themeProvider);
      final mfdata = watch(mfProvider);
      // print("11111111111111111${mfdata.mfsinglepageres!.invList}");
// print("13434312${mfdata.holssinglelist![0].sCHEMECODE}");
      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            leadingWidth: 41,
            titleSpacing: 6,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            backgroundColor:
                theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            shadowColor: const Color(0xffECEFF3),
            title: Text("Holding details",
                style: textStyles.appBarTitleTxt.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                )),
          ),
          body: Stack(children: [
            TransparentLoaderScreen(
              isLoading: mfdata.bestmfloader!,
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 0),
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          // const SizedBox(
                                          //     width: 6),

                                          // const SizedBox(
                                          //     width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start, // Aligns text properly
                                                    children: [
                                                      // const SizedBox(height: 4), // Now it's correctly placed
                                                      Text(
                                                        "${mfdata.holssinglelist![0]?.sCHEMENAME}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: textStyles
                                                            .scripNameTxtStyle
                                                            .copyWith(
                                                          color: theme.isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // const SizedBox(height: 8),
                                                // SizedBox(
                                                //     height: 16,
                                                //     child: ListView(
                                                //         scrollDirection: Axis.horizontal,
                                                //         children: [

                                                //           // CustomExchBadge(exch: "${"${mfdata.mfsinglepageres?.liveCancel}"}"),

                                                //           // Container(
                                                //           //   decoration: BoxDecoration(
                                                //           //     color: mfdata.mfsinglepageres
                                                //           //                 ?.liveCancel ==
                                                //           //             "LIVE"
                                                //           //         ? const Color(0xFFE5F5EA)
                                                //           //         : const Color(0xFFFFC7C7),
                                                //           //     borderRadius:
                                                //           //         BorderRadius.circular(3),
                                                //           //   ),
                                                //           //   padding:
                                                //           //       const EdgeInsets.symmetric(
                                                //           //           horizontal: 4,
                                                //           //           vertical: 2),
                                                //           //   child: Text(
                                                //           //     "${mfdata.mfsinglepageres?.liveCancel}",
                                                //           //     style: textStyle(
                                                //           //       mfdata.mfsinglepageres
                                                //           //                   ?.liveCancel ==
                                                //           //               "LIVE"
                                                //           //           ? const Color(0xFF42A833)
                                                //           //           : const Color(0xFFF33E4B),
                                                //           //       10,
                                                //           //       FontWeight.w400,
                                                //           //     ),
                                                //           //   ),
                                                //           // ),
                                                //         ]))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    ]),
                              )),
                              Column(
                                children: [
                                  Text(
                                    "₹ ${(((double.tryParse(mfdata.holssinglelist![0]?.gainOrLoss ?? '0') ?? 0) )).toStringAsFixed(2)} ",
                                    style: textStyle(
                                      (((double.tryParse(mfdata.holssinglelist![0]?.gainOrLoss ?? '0') ??
                                                          0) )) >=
                                              0
                                          ? Colors.green
                                          : Colors.red, // Dynamic color change
                                      14,
                                      FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "(${(double.tryParse(mfdata.holssinglelist?[0]?.percentage ?? '0') ?? 0).toStringAsFixed(2)}%)",
                                    style: textStyle(
                                      (double.tryParse(mfdata.holssinglelist?[0]
                                                          ?.percentage ??
                                                      '0') ??
                                                  0) >=
                                              0
                                          ? Colors.green
                                          : Colors.red,
                                      14,
                                      FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                              // const SizedBox(width: 7),
                            ]),
                        const SizedBox(height: 2),
                        Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          thickness: 1.0,
                        ),

// const SizedBox(height: 8),
//               Text(
//                 "Order Details",
//                 style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w500),
//               ),

                        const SizedBox(height: 16),

  rowOfInfoData(
     "Units",
                            "${mfdata.holssinglelist![0]?.nET}",
                            "Avg Price",
                            "${(double.tryParse(mfdata.holssinglelist?[0]?.bought ?? '0') ?? 0).toStringAsFixed(4)}",
                           
                            theme),
                        const SizedBox(height: 16),


  rowOfInfoData(
                            "Pledged Qty",
                            "${(double.tryParse(mfdata.holssinglelist![0]?.pLEDGEQTY ?? '0') ?? 0).toStringAsFixed(4)}",
                            "Current NAV",
                            "${mfdata.holssinglelist![0]?.nav}",
                            theme),

                        const SizedBox(height: 16),

                        rowOfInfoData(
                            "Invested",
                            "₹ ${((double.tryParse(mfdata.holssinglelist![0]?.buyPrice ?? '0') ?? 0) * (double.tryParse(mfdata.holssinglelist![0]?.nET ?? '0') ?? 0)).toStringAsFixed(4)}",
                            "Current",
                            "₹ ${((double.tryParse(mfdata.holssinglelist![0]?.sCRIPVALUE ?? '0') ?? 0) * (double.tryParse(mfdata.holssinglelist![0]?.nET ?? '0') ?? 0)).toStringAsFixed(4)}",
                            theme),
                      
                        const SizedBox(height: 16),
                        // rowOfInfoData(
                        //     "Price",
                        //     "${(double.tryParse(mfdata.holssinglelist![0]?.purchase ?? '0') ?? 0).toStringAsFixed(4)}",
                        //     "Avg Price",
                        //     "${(double.tryParse(mfdata.holssinglelist?[0]?.bought ?? '0') ?? 0).toStringAsFixed(2)}",
                        //     theme),
                        //      rowOfInfoData(
                        //        "Pledged Qty",
                        //     "${(double.tryParse(mfdata.holssinglelist![0]?.pLEDGEQTY ?? '0') ?? 0).toStringAsFixed(2)}",
                        //     "",
                        //     "",
                        //     theme),
                        const SizedBox(height: 16),

                        Spacer(),
                        SafeArea(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6, // Takes 6 columns
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showBottomSheet(
                                        context,
                                        RedemptionBottomScreenNew(),
                                      );
                                      mfdata.recdemevalu();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.white, // White background
                                      foregroundColor: const Color.fromARGB(
                                          255, 0, 0, 0), // Text and icon color
                                      side: const BorderSide(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          width: 1), // Outlined border
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            20), // Optional: rounded corners
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Icon(
                                        //   Icons.cancel,
                                        //   color: Color.fromARGB(255, 0, 0, 0),
                                        //   size: 18,
                                        // ),
                                        // SizedBox(width: 6),
                                        Text(
                                          "Redeem",
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // const SizedBox(width: 10),
                            ],
                          ),
                        ),

//               const SizedBox(height: 16),
//               Text(
//                 "SIP Status",
//                 style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w500),
//               ),
//               const SizedBox(height: 16),
//               ListView.builder(
//                 itemCount: mfdata.mfsinglepageres!.invList!.length,
//                 physics: const NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 itemBuilder: (BuildContext context, int index) {
//                   final isFirst = index == 0;
//                   final isLasts =
//                       index == mfdata.mfsinglepageres!.invList!.length;
//                   print(
//                       "Index: $index, Data: ${mfdata.mfsinglepageres!.invList![index]}");

//                   return MFtimelineWidget(
//                     isfFrist: isFirst,
//                     isLast: isLasts,
//                     orderHistoryData: mfdata.mfsinglepageres?.invList?[index],
//                   );
//                 },
//               ),
//             if(mfdata.mfsinglepageres?.nextInstallmentDate == "")...[
//            const SizedBox(height: 16),
//               Text(
//                 "Rejected Reason",
//                 style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w500),
//               ),
//            const SizedBox(height: 8),

//  Text(
//             "${mfdata.mfsinglepageres!.invList![0]["orderremarks"]}",
//                 style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : const Color(0xFFF33E4B),
//                     13,
//                     FontWeight.w500),
//               ),
//             ]
                      ])

//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               Text(
//                 "₹ ${mfdata.mfsinglepageres?.installmentAmount}",
//                 style: TextStyle(
//                   color:
//                       theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const SizedBox(height: 10),

// if(mfdata.mfsinglepageres?.nextInstallmentDate != "")...[
//   Text(
//                 "Next Due Date : ${mfdata.mfsinglepageres?.nextInstallmentDate}",
//                 style: const TextStyle(color: Color(0xFF666666), fontSize: 14,fontWeight:  FontWeight.w500),
//               ),

//               const SizedBox(height: 20),
// ],

//               const Text(
//                 "Nippon India Retirement Fund Income Generation Scheme (G) ",
//                   style: TextStyle(
//                     fontSize: 19,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF181B19)),
//               ),
//               // const SizedBox(height: 8),
//               // Divider(
//               //     color: theme.isDarkMode
//               //         ? colors.darkColorDivider
//               //         : colors.colorDivider,thickness: 1.0,),
//               const SizedBox(height: 17),

//               // Text(
//               //   "Upcoming",
//               //   style: TextStyle(
//               //     color:
//               //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//               //     fontSize: 18,
//               //     fontWeight: FontWeight.w500,
//               //   ),
//               // ),

//               // const SizedBox(height: 14),
//               // Row(
//               //   children: [
//               //     Icon(
//               //       Icons.calendar_today, // Calendar icon
//               //       size: 15,
//               //       color:
//               //           theme.isDarkMode ? colors.colorWhite : colors.colorGrey,
//               //     ),
//               //     const SizedBox(width: 8), // Space between icon and text
//               //     Text(
//               //       "3rd March",
//               //       style: TextStyle(
//               //         color: theme.isDarkMode
//               //             ? colors.colorWhite
//               //             : colors.colorGrey,
//               //         fontSize: 15,
//               //         fontWeight: FontWeight.w500,
//               //       ),
//               //     ),
//               //   ],
//               // ),

//               // const SizedBox(height: 8),
//               // Divider(
//               //   color: theme.isDarkMode
//               //       ? colors.darkColorDivider
//               //       : colors.colorDivider,
//               //   thickness: 1.0,
//               // ),
//               // const SizedBox(height: 10),

//                Text(
//                 "Order Status",
//                 style: TextStyle(
//                   color:
//                       theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),

//               // SIP Amount
//               // Text(
//               //   "Amount: ₹5000",
//               //   style: textStyles.smallText.copyWith(color: colors.colorGrey),
//               // ),
//               // const SizedBox(height: 10),

//               // // SIP Status
//               // Text(
//               //   "Status: Active",
//               //   style: textStyles.smallText.copyWith(color: colors.colorGreen),
//               // ),
//               // const SizedBox(height: 10),

//               // // Next Due Date
//               // Text(
//               //   "Next Due Date: 15 March 2025",
//               //   style: textStyles.smallText.copyWith(color: colors.colorBlack),
//               // ),
//               // const SizedBox(height: 10),

//               // // Frequency
//               // Text(
//               //   "Frequency: Monthly",
//               //   style: textStyles.smallText.copyWith(color: colors.colorGrey),
//               // ),
//               // const SizedBox(height: 20),

//               // Cancel Button
//               // SizedBox(
//               //   width: double.infinity,
//               //   child: ElevatedButton(
//               //     onPressed: () {
//               //       // Handle SIP cancellation
//               //     },
//               //     style: ElevatedButton.styleFrom(
//               //       backgroundColor: colors.colorRed,
//               //       padding: const EdgeInsets.symmetric(vertical: 12),
//               //     ),
//               //     child: Text(
//               //       "Cancel SIP",
//               //       style: textStyles.buttonText.copyWith(
//               //         color: colors.colorWhite,
//               //       ),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
                  ),
            )
          ]));
    });
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      ThemesProvider theme) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title1,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value1,
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w500)),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ])),
      const SizedBox(width: 34),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title2,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value2,
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ]))
    ]);
  }

  void _showBottomSheet(BuildContext context, Widget BottomSheet) {
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
            child: BottomSheet));
  }
}
