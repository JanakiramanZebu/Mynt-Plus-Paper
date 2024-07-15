// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import '../../../../res/res.dart';
// import '../../../../sharedWidget/custom_switch_btn.dart'; 

// class SectorFinancialHealth extends StatefulWidget {
//   const SectorFinancialHealth({super.key});

//   @override
//   State<SectorFinancialHealth> createState() => _SectorFinancialHealthState();
// }

// class _SectorFinancialHealthState extends State<SectorFinancialHealth> {
//   bool _enable = true;
//   @override
//   Widget build(BuildContext context) {
//     List<String> sectorList = ["Income", "Balance Sheet", "Earning"];
//     List<bool> isActiveBtn = [true, false, false];
//     List<String> sectorList1 = ["Operating", "Investing", "Financing"];
//     List<bool> isActiveBtn1 = [true, false, false];

//     double screenWidth = MediaQuery.of(context).size.width;
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(
//         'Financial Health',
//         style: GoogleFonts.inter(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xff000000)),
//       ),
//       const SizedBox(
//         height: 24,
//       ),
//       SizedBox(
//         width: screenWidth,
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Higher Return Expection',
//                   style: GoogleFonts.inter(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xff000000)),
//                 ),
//                 Container(
//                     width: 25,
//                     height: 25,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(100),
//                         border: Border.all(
//                           width: 1,
//                           color: Colors.grey,
//                         )),
//                     child: SvgPicture.asset(
//                       "assets/icon/iosrightarrow.svg",
//                       width: 30,
//                       fit: BoxFit.none,
//                     )),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               children: [
//                 SvgPicture.asset('assets/icon/greentick.svg'),
//                 const SizedBox(
//                   width: 6,
//                 ),
//                 SvgPicture.asset('assets/icon/greentick.svg'),
//                 const SizedBox(
//                   width: 6,
//                 ),
//                 SvgPicture.asset('assets/icon/greentick.svg'),
//                 const SizedBox(
//                   width: 6,
//                 ),
//                 SvgPicture.asset('assets/icon/greentick.svg'),
//                 const SizedBox(
//                   width: 6,
//                 ),
//                 SvgPicture.asset('assets/icon/greentick.svg'),
//                 const SizedBox(
//                   width: 6,
//                 ),
//                 SvgPicture.asset('assets/icon/redtick.svg')
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Text(
//               'Forecasting uses historical data as inputs to make informed predictive estimates..',
//               style: GoogleFonts.inter(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: const Color(0xff666666)),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             const Divider(
//               color: Color(0xffECEDEE),
//             )
//           ],
//         ),
//       ),
//       const SizedBox(
//         height: 18,
//       ),
//       SizedBox(
//           height: 30,
//           child: ScrollableBtn(btnActive: isActiveBtn, btnName: sectorList)),
//       const SizedBox(
//         height: 20,
//       ),
//       Text(
//         'Analyst Forecasts',
//         style: GoogleFonts.inter(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xff000000)),
//       ),
//       const SizedBox(
//         height: 8,
//       ),
//       ReadMoreText(
//         "Reliance Global Group's total assets for Q1 2023 were \$33.88M, a decrease of -11.82% from the previous quarter. RELI total liabilities were \$21.65M for the fiscal quarter, a -26.66% a decrease from the previous quarter. See a summary of the company's assets, liabilities, and equity.",
//         style: GoogleFonts.inter(
//             letterSpacing: -0.07,
//             height: 1.5,
//             textStyle: textStyle(const Color(0xff666666), 14, FontWeight.w500)),
//         trimLines: 3,
//         colorClickableText: const Color(0xff0037B7),
//         trimMode: TrimMode.Line,
//         trimCollapsedText: 'Read more',
//         trimExpandedText: ' Read less',
//       ),
//       const SizedBox(
//         height: 20,
//       ),
//       const Divider(
//         color: Color(0xffECEDEE),
//       ),
//       const SizedBox(
//         height: 18,
//       ),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Income Statement',
//             style: GoogleFonts.inter(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xff000000)),
//           ),
//           // Container(color: Color(0xffFFFFFF), child: IncomeBarChart()),
//           SvgPicture.asset(
//             'assets/icon/iosuparrow.svg',
//             width: 20,
//           )
//         ],
//       ),
//       const SizedBox(
//         height: 18,
//       ),
//       SizedBox(
//           height: 30,
//           child: ScrollableBtn(btnActive: isActiveBtn1, btnName: sectorList1)),
//       const SizedBox(
//         height: 20,
//       ),
//       SvgPicture.asset('assets/icon/chart_income.svg'),
//       const SizedBox(
//         height: 30,
//       ),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Quarterly',
//             style: GoogleFonts.inter(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: _enable ? const Color(0xff000000) : Colors.grey),
//           ),
//           const SizedBox(
//             width: 16,
//           ),
//           CustomSwitch(
//             value: _enable,
//             onChanged: (bool val) {
//               setState(() {
//                 _enable = val;
//               });
//             },
//           ),
//           const SizedBox(
//             width: 16,
//           ),
//           Text(
//             'Yearly',
//             style: GoogleFonts.inter(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: _enable ? Colors.grey : const Color(0xff000000)),
//           ),
//         ],
//       ),
//       const SizedBox(
//         height: 15,
//       ),
//       const Divider(
//         color: Color(0xffECEDEE),
//       ),
//       const SizedBox(
//         height: 15,
//       ),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Balance Sheet Statement',
//                 style: GoogleFonts.inter(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0xff000000)),
//               ),
//               const SizedBox(
//                 height: 4,
//               ),
//               Text(
//                 'All Figures in Cr.',
//                 style: GoogleFonts.inter(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xff666666)),
//               ),
//             ],
//           ),
//           Container(
//             width: 109,
//             height: 32,
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             decoration: BoxDecoration(
//                 color: const Color(0xffF1F3F8),
//                 borderRadius: BorderRadius.circular(24)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 SvgPicture.asset(
//                   "assets/icon/filter_check.svg",
//                   fit: BoxFit.scaleDown,
//                 ),
//                 Text("Filter",
//                     style: GoogleFonts.inter(
//                         textStyle: textStyle(
//                             const Color(0xff000000), 13, FontWeight.w500))),
//                 SvgPicture.asset(
//                   assets.downArrow,
//                   color: const Color(0xff666666),
//                   fit: BoxFit.scaleDown,
//                 )
//               ],
//             ),
//           ),
//         ],
//       )
//     ]);
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
