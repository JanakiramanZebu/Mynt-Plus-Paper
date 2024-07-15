// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_price_compersion_list.dart';

// class PriceCompersion extends StatefulWidget {
//   const PriceCompersion({super.key});

//   @override
//   State<PriceCompersion> createState() => _PriceCompersionState();
// }

// class _PriceCompersionState extends State<PriceCompersion> {
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const SizedBox(
//           height: 20,
//         ),
//         Text(
//           'Price Comparison ',
//           style: GoogleFonts.inter(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xff000000)),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         RichText(
//           textAlign: TextAlign.justify,
//           text: TextSpan(
//             text: 'Compare',
//             style: GoogleFonts.inter(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xff666666),
//             ),
//             children: [
//               TextSpan(
//                 text: ' RELIANCE ',
//                 style: GoogleFonts.inter(
//                     color: const Color(0xff0037B7),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600),
//               ),
//               TextSpan(
//                 text: 'with any stock or ETF',
//                 style: GoogleFonts.inter(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xff666666),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 24,
//         ),
//         Container(
//           width: screenWidth,
//           height: 40,
//           decoration: BoxDecoration(
//               color: const Color(0xffF1F3F8),
//               borderRadius: BorderRadius.circular(24)),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SvgPicture.asset('assets/icon/Calendaricon.svg'),
//               const SizedBox(
//                 width: 10,
//               ),
//               Text("Select dates",
//                   style: GoogleFonts.inter(
//                       textStyle: textStyle(
//                           const Color(0xff000000), 14, FontWeight.w600))),
//               const SizedBox(
//                 width: 10,
//               ),
//               SvgPicture.asset(
//                 "assets/icon/arrow_sm_down.svg",
//                 fit: BoxFit.scaleDown,
//               )
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 24,
//         ),
//         Image.asset('assets/img/line-chart.png'),
//         const SizedBox(
//           height: 30,
//         ),
//         const EftPriceComperstionlist(),
//         const SizedBox(
//           height: 10,
//         ),
//         const Divider(
//           color: Color(0xffECEDEE),
//         ),
//         const SizedBox(
//           height: 16,
//         ),
//         ReadMoreText(
//           "Reliance Global Group's total assets for Q1 2023 were \$33.88M, a decrease of -11.82% from the previous quarter. RELI total liabilities were \$21.65M for the fiscal quarter, a -26.66% a decrease from the previous quarter. See a summary of the company’s assets, liabilities, and equity.",
//           style: GoogleFonts.inter(
//               letterSpacing: -0.07,
//               height: 1.7,
//               textStyle:
//                   textStyle(const Color(0xff666666), 14, FontWeight.w500)),
//           trimLines: 3,
//           colorClickableText: const Color(0xff0037B7),
//           trimMode: TrimMode.Line,
//           trimCollapsedText: 'Read more',
//           trimExpandedText: ' Read less',
//         ),
//         const SizedBox(
//           height: 24,
//         ),
//         const Divider(
//           color: Color(0xffECEDEE),
//         ),
//       ]),
//     );
//   }
// }

// textStyle(
//   Color color,
//   double fontSize,
//   fWeight,
// ) {
//   return GoogleFonts.inter(
//       textStyle: TextStyle(
//     fontWeight: fWeight,
//     color: color,
//     fontSize: fontSize,
//   ));
// }
