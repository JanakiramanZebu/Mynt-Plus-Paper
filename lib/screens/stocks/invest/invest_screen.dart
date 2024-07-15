// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../provider/mutual_fund_provider.dart';
// import '../../../../res/res.dart';
// import '../../../../routes/route_names.dart';

// import '../../../../provider/stocks_provider.dart';
// import '../../sharedWidget/custom_text_btn.dart';
// import '../../sharedWidget/scrollable_btn.dart';

// class InvestScreen extends StatefulWidget {
//   const InvestScreen({super.key});

//   @override
//   State<InvestScreen> createState() => _InvestScreenState();
// }

// class _InvestScreenState extends State<InvestScreen> {
//   int selectedBtn = 0;
//   List<String> investType = ["Growth factor", "Lower risk", "ESG investing"];
//   List<bool> isActiveBtn = [true, false, false];
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(builder: (context, ScopedReader watch, _) {
//       final invests = watch(stocksProvide).investModel;
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 24),
//         color: const Color(0xffF1F3F8),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 "Invest easy with curated ideas and ready made collections",
//                 style: GoogleFonts.inter(
//                     textStyle: textStyle(
//                         const Color(0xff181B19), 18, FontWeight.w600)),
//               ),
//             ),
//             const SizedBox(height: 18),
//             Padding(
//               padding: const EdgeInsets.only(left: 16.0),
//               child: SizedBox(
//                   height: 35,
//                   child: ScrollableBtn(
//                       btnActive: isActiveBtn, btnName: investType)),
//             ),
//             const SizedBox(height: 18),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 "Handpicked global baskets of stocks managed by global institutions and fund managers",
//                 style: GoogleFonts.inter(
//                     textStyle: textStyle(
//                         const Color(0xff666666), 14, FontWeight.w500)),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ListView.separated(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: invests!.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return InkWell(
//                   onTap: () async {
//                     await context.read(mutualFundProvide).getEquityAllocation();
//                     Navigator.pushNamed(context, Routes.inverstinfopage,
//                         arguments: invests[index]);
//                   },
//                   child: Container(
//                       decoration: const BoxDecoration(color: Color(0xffFFFFFF)),
//                       child: Column(
//                         children: [
//                           ListTile(
//                             minLeadingWidth: 20,
//                             leading: Image.asset("${invests[index].groupIcon}"),
//                             title: Text(
//                               "${invests[index].groupName}",
//                               style: GoogleFonts.inter(
//                                   textStyle: textStyle(const Color(0xff000000),
//                                       15, FontWeight.w600)),
//                             ),
//                             subtitle: Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 2),
//                                   decoration: BoxDecoration(
//                                       color: const Color(0xffF1F3F8),
//                                       borderRadius: BorderRadius.circular(4)),
//                                   child: Text(
//                                     "${invests[index].multiCap}",
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff666666),
//                                             10,
//                                             FontWeight.w600)),
//                                   ),
//                                 ),
//                                 Container(
//                                   margin: const EdgeInsets.only(left: 8),
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 2),
//                                   decoration: BoxDecoration(
//                                       color: const Color(0xffF1F3F8),
//                                       borderRadius: BorderRadius.circular(4)),
//                                   child: Text(
//                                     "${invests[index].longTerm}",
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff666666),
//                                             10,
//                                             FontWeight.w600)),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             trailing: SizedBox(
//                               width: 65,
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   SvgPicture.asset(
//                                     "${invests[index].timerIcon}",
//                                   ),
//                                   const SizedBox(width: 8),
//                                   SvgPicture.asset(
//                                     "${invests[index].bookMarkIcon}",
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'MIN. INVEST',
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff666666),
//                                             12,
//                                             FontWeight.w600)),
//                                   ),
//                                   Text(
//                                     '₹ ${invests[index].minInvest}',
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff000000),
//                                             15,
//                                             FontWeight.w600)),
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '3Y CAGR',
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff666666),
//                                             12,
//                                             FontWeight.w600)),
//                                   ),
//                                   Text(
//                                     '${invests[index].yCAGR}%',
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             invests[index]
//                                                     .yCAGR!
//                                                     .startsWith("-")
//                                                 ? const Color(0xffE00000)
//                                                 : const Color(0xff43A833),
//                                             15,
//                                             FontWeight.w600)),
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'TOTAL STOCKS',
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff666666),
//                                             12,
//                                             FontWeight.w600)),
//                                   ),
//                                   Text(
//                                     '${invests[index].totalStocks} stocks',
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff000000),
//                                             15,
//                                             FontWeight.w600)),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                         ],
//                       )),
//                 );
//               },
//               separatorBuilder: (BuildContext context, int index) {
//                 return const SizedBox(
//                   height: 16,
//                 );
//               },
//             ),
//             Container(
//                 margin: const EdgeInsets.only(right: 16, left: 14, top: 18),
//                 width: MediaQuery.of(context).size.width,
//                 child: CustomTextBtn(
//                     label: 'See more collections',
//                     onPress: () {
//                       Navigator.pushNamed(context, Routes.investcollecyion);
//                     },
//                     icon: assets.rightarrow))
//           ],
//         ),
//       );
//     });
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     );
//   }
// }
