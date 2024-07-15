// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/invest/inverst_stocks/inverst_alloction.dart';
// import '../../../../screens/stocks/invest/inverst_stocks/inverst_details/financial_ratios.dart';
// import '../../../../screens/stocks/invest/inverst_stocks/inverst_details/inverst_fund_equity.dart';
// import '../../../../screens/stocks/invest/inverst_stocks/inverst_details/inverst_fund_returns.dart';
// import '../../../../screens/stocks/invest/inverst_stocks/inverst_details/inverst_historical_nav.dart';
// import '../../../../screens/stocks/invest/inverst_stocks/inverst_details/inverst_segment.dart';
// import '../../../../screens/stocks/invest/inverst_stocks/inverst_details/inverst_similar.dart';
// import '../../../../screens/stocks/invest/inverst_stocks/inverst_details/inverst_venture_capita.dart';

// class InfoDetails extends StatelessWidget {
//   const InfoDetails({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xffFFFFFF),
//         elevation: 0.3,
//         shadowColor: const Color(0xffECEFF3),
//         leadingWidth: 30,
//         iconTheme: const IconThemeData(color: Color(0xff666666)),
//         title: Text(
//           "Detail Page",
//           style: textStyle(const Color(0xff000000), 14, FontWeight.w600),
//         ),
//         actions: [
//           Row(
//             children: [
//               SvgPicture.asset(assets.filterlines),
//               IconButton(
//                   onPressed: () {}, icon: SvgPicture.asset(assets.searchIcon)),
//               const SizedBox(
//                 width: 10,
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   color: const Color(0xffFAFBFF),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
//                   child: Column(
//                     children: [
//                       ListTile(
//                         title: Text("Mid and Small Cap Focuse...",
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff000000),
//                                     18, FontWeight.w600))),
//                         contentPadding: EdgeInsets.zero,
//                         trailing: SizedBox(
//                           width: 88,
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(assets.circlebell),
//                               const SizedBox(width: 8),
//                               SvgPicture.asset(assets.circlebookmark),
//                               const SizedBox(width: 10),
//                               SvgPicture.asset(assets.threedots),
//                               const SizedBox(width: 10),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 2),
//                         child: Row(
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.only(right: 4),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                   color: const Color(0xffffffff),
//                                   borderRadius: BorderRadius.circular(4)),
//                               child: Text('growth'.toUpperCase(),
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff666666),
//                                           10,
//                                           FontWeight.w500))),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(right: 4),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                   color: const Color(0xffffffff),
//                                   borderRadius: BorderRadius.circular(4)),
//                               child: Text('equity'.toUpperCase(),
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff666666),
//                                           10,
//                                           FontWeight.w500))),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(right: 4),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                   color: const Color(0xffffffff),
//                                   borderRadius: BorderRadius.circular(4)),
//                               child: Text('elss'.toUpperCase(),
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff666666),
//                                           10,
//                                           FontWeight.w500))),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text("Min. Amount".toUpperCase(),
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff666666),
//                                           12,
//                                           FontWeight.w500))),
//                               const SizedBox(height: 4),
//                               Text("₹ 43,587",
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff000000),
//                                           14,
//                                           FontWeight.w500))),
//                             ],
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text("3Y CAGR",
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff666666),
//                                           12,
//                                           FontWeight.w500))),
//                               const SizedBox(height: 4),
//                               Text("+13.8%",
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff43A833),
//                                           14,
//                                           FontWeight.w500))),
//                             ],
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 6),
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: const Color(0xffffffff),
//                                 border:
//                                     Border.all(color: const Color(0xffEEF0F2))),
//                             child: Row(
//                               children: [
//                                 SvgPicture.asset(
//                                   assets.timerred,
//                                   fit: BoxFit.fill,
//                                   height: 30,
//                                   width: 1,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("RISK METER",
//                                         style: GoogleFonts.inter(
//                                             textStyle: textStyle(
//                                                 const Color(0xff666666),
//                                                 10,
//                                                 FontWeight.w500))),
//                                     Text("HIGH RISK",
//                                         style: GoogleFonts.inter(
//                                             textStyle: textStyle(
//                                                 const Color(0xff000000),
//                                                 14,
//                                                 FontWeight.w500))),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 15,
//                       )
//                     ],
//                   ),
//                 ),
//                 const FinancialRatios(),
//                 const InverstHistrocialNav(),
//                 const InverstFundReturns(),
//                 const InverstVentureCapita(),
//                 const InverstWeightSegment(),
//                 const SizedBox(
//                   height: 15,
//                 ),
//                 const Divider(
//                   color: Color(0xffECEDEE),
//                 ),
//                 const SizedBox(
//                   height: 24,
//                 ),
//                 const InverstAlloction(),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Divider(
//                     color: Color(0xffECEDEE),
//                   ),
//                 ),
//                 const FundEquity(),
//                 const InverstSimilarFunds(),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle: TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     ));
//   }
// }
