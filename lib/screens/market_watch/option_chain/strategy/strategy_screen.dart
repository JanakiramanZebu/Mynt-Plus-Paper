// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';

// import '../../../../provider/option_strategy.dart';
// import '../../../../provider/thems.dart';
// import '../../../../res/res.dart';
// import '../../../../sharedWidget/functions.dart';
// import '../../tv_chart/webview_chart.dart';
// import 'stratrgy_list_sheet.dart';

// class StrategyScreen extends ConsumerWidget {
//   final ChartArgs chartArgs;
//   const StrategyScreen({super.key, required this.chartArgs});

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final optStrgy = watch(optStrategyProvider);
//     final theme = watch(themeProvider);
//     return Column(children: [
//       ChartScreenWebView(chartArgs: chartArgs, cHeight: 1.8),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           IconButton(
//               onPressed: () {
//                 showModalBottomSheet(
//                     useSafeArea: true,
//                     isScrollControlled: true,
//                     shape: const RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.vertical(top: Radius.circular(16))),
//                     context: context,
//                     builder: (context) {
//                       return const StrategyListBottomSheet();
//                     });
//               },
//               icon: SvgPicture.asset(assets.filterLines,
//                   width: 19, color: colors.colorGrey))
//         ],
//       ),
//       Expanded(
//         child: ListView(
//           shrinkWrap: true,
//           children: [
//             ListView.separated( 
//               padding: const EdgeInsets.symmetric(horizontal: 16),
                
//             physics: NeverScrollableScrollPhysics(),
//               itemCount: optStrgy.optStrgyStrike.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(children: [
//                               Text("${optStrgy.optStrgyStrike[index].symbol} ",
//                                   overflow: TextOverflow.ellipsis,
//                                   style: textStyles.scripNameTxtStyle.copyWith(
//                                       color: theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack)),
//                               Text("${optStrgy.optStrgyStrike[index].option} ",
//                                   overflow: TextOverflow.ellipsis,
//                                   style: textStyles.scripNameTxtStyle.copyWith(
//                                       color: theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack)),
//                             ]),
//                             Row(children: [
//                               Text(" LTP: ",
//                                   style: textStyle(
//                                       const Color(0xff5E6B7D), 13, FontWeight.w600)),
//                               Text("₹${optStrgy.optStrgyStrike[index].lp}",
//                                   style: textStyle(
//                                       theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack,
//                                       14,
//                                       FontWeight.w500))
//                             ])
//                           ]),
//                       const SizedBox(height: 4),
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(children: [
//                               Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 6, vertical: 3),
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(2),
//                                       color: theme.isDarkMode
//                                           ? const Color(0xff666666).withOpacity(.2)
//                                           : const Color(0xffECEDEE)),
//                                   child: Text(
//                                       "${optStrgy.optStrgyStrike[index].exch}",
//                                       overflow: TextOverflow.ellipsis,
//                                       style: textStyle(
//                                           theme.isDarkMode
//                                               ? colors.colorWhite
//                                               : const Color(0xff666666),
//                                           10,
//                                           FontWeight.w500))),
//                               Text("  ${optStrgy.optStrgyStrike[index].expDate}   ",
//                                   overflow: TextOverflow.ellipsis,
//                                   style: textStyles.scripExchTxtStyle.copyWith(
//                                       color: theme.isDarkMode
//                                           ? colors.colorWhite
//                                           : colors.colorBlack)),
            
//                                           Container(
//                                                               padding:
//                                                                   const EdgeInsets.symmetric(
//                                                                       horizontal: 8,
//                                                                       vertical: 2),
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               4),
//                                                                       color: theme
//                                                                               .isDarkMode
//                                                                           ? optStrgy.optStrgyStrike[index].transType ==
//                                                                                   "S"
//                                                                               ? colors.darkred.withOpacity(
//                                                                                   .2)
//                                                                               : colors.ltpgreen.withOpacity(
//                                                                                   .2)
//                                                                           : Color( optStrgy.optStrgyStrike[index].transType == "S"
//                                                                               ? 0xffFCF3F3
//                                                                               : 0xffECF8F1)),
//                                                               child: Text("${ optStrgy.optStrgyStrike[index].transType}",
//                                                                   style: textStyle(
//                                                                        optStrgy.optStrgyStrike[index].transType == "S"
//                                                                           ? colors.darkred
//                                                                           : colors.ltpgreen,
//                                                                       12,
//                                                                       FontWeight.w600))),
//                             ]),
//                             Text(
//                                 " (${optStrgy.optStrgyStrike[index].perChange ?? 0.00}%)",
//                                 style: textStyle(
//                                     optStrgy.optStrgyStrike[index].perChange
//                                             .toString()
//                                             .startsWith("-")
//                                         ? colors.darkred
//                                         : optStrgy.optStrgyStrike[index].perChange ==
//                                                 "0.00"
//                                             ? colors.ltpgrey
//                                             : colors.ltpgreen,
//                                     12,
//                                     FontWeight.w500))
//                           ]),
//                       Divider(
//                           color:
//                               theme.isDarkMode ? colors.darkGrey : const Color(0xffECEDEE),
//                           thickness: 1.2),
//                       const SizedBox(height: 2),
//                     ]);
//               },
//               separatorBuilder: (BuildContext context, int index) {
//                 return const Divider();
//               },
//             ),
//           ],
//         ),
//       )
//     ]);
//   }
// }
