// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:readmore/readmore.dart';

// import '../../../sharedWidget/scrollable_btn.dart';

// class EftAnalystRecommendation extends StatefulWidget {
//   const EftAnalystRecommendation({super.key});

//   @override
//   State<EftAnalystRecommendation> createState() =>
//       _EftAnalystRecommendationState();
// }

// class _EftAnalystRecommendationState extends State<EftAnalystRecommendation> {
//   int selectedBtn = 0;
//   List<String> sectorList = ["Price", "Revenue", "Earning"];
//   List<bool> isActiveBtn = [true, false, false];
//   bool isVisbel = true;
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     // double screenHeight = MediaQuery.of(context).size.height;

//     return Column(
//       children: [
//         const SizedBox(
//           height: 10,
//         ),
//         Visibility(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Analyst Recommendation',
//                 style: GoogleFonts.inter(
//                     fontSize: 18, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     width: 200,
//                     height: 110,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Analyst Rating',
//                           style: GoogleFonts.inter(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xff000000)),
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         Text(
//                           'Based on 33 analysts offering long term price targets for Reliance Industries Ltd. An average target of ₹2856.09',
//                           style: GoogleFonts.inter(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: const Color(0xff666666),
//                               letterSpacing: -0.07,
//                               height: 1.4),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       width: 120,
//                       height: 119,
//                       decoration: BoxDecoration(
//                           border: Border.all(color: const Color(0xffCCCCCC)),
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(8))),
//                       child: Column(
//                         children: [
//                           Container(
//                             width: 35,
//                             height: 35,
//                             decoration: const BoxDecoration(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(4),
//                                 ),
//                                 color: Color(0xff43A833)),
//                             child: const Center(
//                               child: Text(
//                                 "B",
//                                 style: TextStyle(
//                                     color: Color(0xffFFFFFF), fontSize: 21),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 16,
//                           ),
//                           Text(
//                             'People BID',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff666666)),
//                           ),
//                           const SizedBox(
//                             height: 2,
//                           ),
//                           Text(
//                             '90.5%',
//                             style: GoogleFonts.inter(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff000000)),
//                           )
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               const Divider(
//                 color: Color(0xffECEDEE),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Visibility(
//                 visible: isVisbel,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Analyst Forecasts',
//                       style: GoogleFonts.inter(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xff000000)),
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     ReadMoreText(
//                       'Forecasting uses historical data as inputs to make informed predictive estimates determining the direction of future trends. Price, revenue & earnings forecasts represent where the stock level, business prospects and profits are potentially expected to be at the end of the forecast period',
//                       style: GoogleFonts.inter(
//                           letterSpacing: -0.07,
//                           height: 1.5,
//                           textStyle: textStyle(
//                               const Color(0xff666666), 14, FontWeight.w500)),
//                       trimLines: 3,
//                       colorClickableText: const Color(0xff0037B7),
//                       trimMode: TrimMode.Line,
//                       trimCollapsedText: 'Read more',
//                       trimExpandedText: ' Read less',
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     SizedBox(
//                         height: 30,
//                         child: ScrollableBtn(
//                             btnActive: isActiveBtn, btnName: sectorList)),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     Center(
//                       child: Column(
//                         children: [
//                           Text(
//                             'Price Forecasts',
//                             style: GoogleFonts.inter(
//                                 color: const Color(0xff999999),
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600),
//                           ),
//                           const SizedBox(
//                             height: 4,
//                           ),
//                           SvgPicture.asset('assets/icon/priority-lowest 1.svg'),
//                           const SizedBox(
//                             height: 19,
//                           ),
//                           Image.asset('assets/img/priceforcastchart.png'),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     Container(
//                       height: 40,
//                       width: 109,
//                       decoration: BoxDecoration(
//                           color: const Color(0xffF1F3F8),
//                           borderRadius: BorderRadius.circular(24)),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("May 2023",
//                               style: GoogleFonts.inter(
//                                   textStyle: textStyle(const Color(0xff666666),
//                                       12, FontWeight.w500))),
//                           SvgPicture.asset(
//                             "assets/icon/vector.svg",
//                             width: 38,
//                             height: 40,
//                             fit: BoxFit.scaleDown,
//                           )
//                         ],
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           width: 96,
//                           height: 100,
//                           decoration: const BoxDecoration(
//                             border: Border(
//                               top: BorderSide(
//                                 //                   <--- left side
//                                 color: Color(0xff148564),
//                                 width: 2.5,
//                               ),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(
//                                 height: 12,
//                               ),
//                               Text(
//                                 'High'.toUpperCase(),
//                                 style: GoogleFonts.inter(
//                                     fontSize: 13,
//                                     color: const Color(0xfff666666),
//                                     fontWeight: FontWeight.w500,
//                                     letterSpacing: 1.04),
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 '₹3,379.05',
//                                 style: GoogleFonts.inter(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 16),
//                               ),
//                               const SizedBox(height: 3),
//                               Text(
//                                 '+37.64',
//                                 style: GoogleFonts.inter(
//                                     color: const Color(0xff43A833),
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 14),
//                               )
//                             ],
//                           ),
//                         ),
//                         Container(
//                           width: 96,
//                           height: 100,
//                           decoration: const BoxDecoration(
//                             border: Border(
//                               top: BorderSide(
//                                 //                   <--- left side
//                                 color: Color(0xff7CD36E),
//                                 width: 2.5,
//                               ),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(
//                                 height: 12,
//                               ),
//                               Text(
//                                 'Median'.toUpperCase(),
//                                 style: GoogleFonts.inter(
//                                     fontSize: 13,
//                                     color: const Color(0xfff666666),
//                                     fontWeight: FontWeight.w500,
//                                     letterSpacing: 1.04),
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 '₹2822.23',
//                                 style: GoogleFonts.inter(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 16),
//                               ),
//                               const SizedBox(height: 3),
//                               Text(
//                                 '+37.64',
//                                 style: GoogleFonts.inter(
//                                     color: const Color(0xff43A833),
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 14),
//                               )
//                             ],
//                           ),
//                         ),
//                         Container(
//                           width: 96,
//                           height: 100,
//                           decoration: const BoxDecoration(
//                             border: Border(
//                               top: BorderSide(
//                                 //                   <--- left side
//                                 color: Color(0xffF6CF7D),
//                                 width: 2.5,
//                               ),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(
//                                 height: 12,
//                               ),
//                               Text(
//                                 'Low'.toUpperCase(),
//                                 style: GoogleFonts.inter(
//                                     fontSize: 13,
//                                     color: const Color(0xfff666666),
//                                     fontWeight: FontWeight.w500,
//                                     letterSpacing: 1.04),
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 '₹2050.00',
//                                 style: GoogleFonts.inter(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 16),
//                               ),
//                               const SizedBox(height: 3),
//                               Text(
//                                 '+37.64',
//                                 style: GoogleFonts.inter(
//                                     color: const Color(0xffFF1717),
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 14),
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 15),
//                       width: screenWidth,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(4),
//                           color: const Color(0xffECF5EA)),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Higher Return Expection',
//                                 style: GoogleFonts.inter(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: const Color(0xff000000)),
//                               ),
//                               SvgPicture.asset(
//                                   'assets/icon/greenroundedarrow.svg')
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           Text(
//                             'Expected return of 14.5% from current price level is less than last 3 tr CAGR of 22.5%',
//                             style: GoogleFonts.inter(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff666666)),
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 12,
//         ),
//         InkWell(
//           onTap: () {
//             setState(() {
//               isVisbel = !isVisbel;
//             });
//           },
//           child: isVisbel
//               ? Row(
//                   children: [
//                     Text(
//                       'View less',
//                       style: GoogleFonts.inter(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666)),
//                     ),
//                     const SizedBox(
//                       width: 3,
//                     ),
//                     const Icon(
//                       Icons.keyboard_arrow_up_outlined,
//                     )
//                   ],
//                 )
//               : Row(
//                   children: [
//                     Text(
//                       'View more',
//                       style: GoogleFonts.inter(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666)),
//                     ),
//                     const SizedBox(
//                       width: 3,
//                     ),
//                     const Icon(
//                       Icons.keyboard_arrow_down_outlined,
//                     )
//                   ],
//                 ),
//         )
//       ],
//     );
//   }
// }

// textStyle(Color color, double fontSize, fWeight) {
//   return GoogleFonts.inter(
//       textStyle: TextStyle(
//     fontWeight: fWeight,
//     color: color,
//     fontSize: fontSize,
//   ));
// }
