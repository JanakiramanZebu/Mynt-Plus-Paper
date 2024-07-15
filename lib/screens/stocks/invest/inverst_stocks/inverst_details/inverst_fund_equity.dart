// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../../../../provider/mutual_fund_provider.dart';

// class FundEquity extends ConsumerWidget {
//   const FundEquity({super.key});

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final equityAllocation = watch(mutualFundProvide).equityAllocation;
//     double level = 0.00;
//     return Column(
//       children: [
//         Theme(
//           data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//           child: ExpansionTile(
//               iconColor: Colors.grey,
//               expandedCrossAxisAlignment: CrossAxisAlignment.start,
//               childrenPadding: const EdgeInsets.all(16),
//               collapsedIconColor: Colors.grey,
//               initiallyExpanded: true,
//               title: Text("Fund’s equity sector distribution",
//                   style:
//                       textStyle(const Color(0xff000000), 16, FontWeight.w600)),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 4),
//                   Text(
//                       "Each fund is uniquely allocated to suit and match customer expectations based on the risk profile and return expectations.",
//                       style: textStyle(
//                           const Color(0xff666666), 14, FontWeight.w500)),
//                 ],
//               ),
//               children: [
//                 Text("Equity allocation by Sector",
//                     style: textStyle(
//                         const Color(0xff999999), 14, FontWeight.w600)),
//                 const SizedBox(height: 20),
//                 ListView.separated(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemBuilder: (context, index) {
//                       level = double.parse("${equityAllocation[index].level}") /
//                           100;
//                       return Column(
//                         children: [
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                     "${equityAllocation[index].allocationType}",
//                                     style: textStyle(const Color(0xff666666),
//                                         14, FontWeight.w500)),
//                                 Text("${equityAllocation[index].level}%",
//                                     style: textStyle(const Color(0xff489522),
//                                         14, FontWeight.w500)),
//                               ]),
//                           const SizedBox(height: 10),
//                           LinearPercentIndicator(
//                             lineHeight: 8.0,
//                             barRadius: const Radius.circular(5),
//                             backgroundColor: const Color(0xffF1F3F8),
//                             percent: level,
//                             padding: const EdgeInsets.symmetric(horizontal: 0),
//                             progressColor: const Color(0xffB7DBA6),
//                           ),
//                         ],
//                       );
//                     },
//                     separatorBuilder: (context, index) {
//                       return const SizedBox(height: 20);
//                     },
//                     itemCount: equityAllocation!.length)
//               ]),
//         ),
//         const Divider(color: Color(0xffECEDEE)),
//         Theme(
//           data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//           child: ExpansionTile(
//               iconColor: Colors.grey,
//               expandedCrossAxisAlignment: CrossAxisAlignment.start,
//               childrenPadding: const EdgeInsets.all(16),
//               collapsedIconColor: Colors.grey,
//               title: Text("Fund’s top stock holdings",
//                   style:
//                       textStyle(const Color(0xff000000), 16, FontWeight.w600)),
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   child: Text("No Data Found",
//                       style: textStyle(
//                           const Color(0xff666666), 14, FontWeight.w500)),
//                 ),
//               ]),
//         ),
//         const Divider(color: Color(0xffECEDEE)),
//       ],
//     );
//   }

//   textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle: TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     ));
//   }
// }
