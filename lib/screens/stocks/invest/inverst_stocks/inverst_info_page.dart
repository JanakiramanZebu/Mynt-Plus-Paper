// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../model/invest_model.dart';
// import '../../../../routes/route_names.dart';

// class InverstInfoPage extends StatelessWidget {
//   final InvestModel infodetails;
//   const InverstInfoPage({
//     super.key,
//     required this.infodetails,
//   });

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xffFFFFFF),
//         elevation: 0.3,
//         leadingWidth: 30,
//         iconTheme: const IconThemeData(color: Color(0xff666666)),
//         title: Text(
//           "${infodetails.groupName}",
//           style: textStyle(const Color(0xff000000), 14, FontWeight.w600),
//         ),
//         actions: [
//           Row(
//             children: [
//               // SvgPicture.asset('assets/icon/appbarIcon/filter_lines.svg'),
//               const SizedBox(
//                 width: 12,
//               ),
//               IconButton(
//                   onPressed: () {},
//                   icon: SvgPicture.asset(
//                     'assets/icon/appbarIcon/search.svg',
//                   ))
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: screenWidth,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//             decoration: const BoxDecoration(
//                 border: Border(
//                     bottom: BorderSide(
//               width: 6,
//               color: Color(0xffF1F3F8),
//             ))),
//             child: Text(
//               '8 Baskets for balanced wealth',
//               style: textStyle(const Color(0xff666666), 13, FontWeight.w500),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//               decoration: BoxDecoration(
//                   color: const Color(0xffFFF1D6),
//                   borderRadius: BorderRadius.circular(3)),
//               child: Text(
//                 "RECOMMENDED",
//                 style: GoogleFonts.inter(
//                     textStyle: textStyle(
//                         const Color(0xffC07F00), 10, FontWeight.w600)),
//               ),
//             ),
//           ),
//           ListView.separated(
//               padding: EdgeInsets.zero,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     Navigator.pushNamed(context, Routes.inverstinfodetails);
//                   },
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ListTile(
//                         title: Text("Mid and Small Cap Focuse...",
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff000000),
//                                     15, FontWeight.w600))),
//                         subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 8),
//                               Text('Managed by Niveshaay'.toUpperCase(),
//                                   style: GoogleFonts.inter(
//                                       fontWeight: FontWeight.w500,
//                                       color: const Color(0xff666666),
//                                       letterSpacing: 0.96,
//                                       fontSize: 12)),
//                             ]),
//                         trailing: SizedBox(
//                           width: 85,
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               SvgPicture.asset('${infodetails.timerIcon}'),
//                               const SizedBox(width: 8),
//                               SvgPicture.asset(
//                                 '${infodetails.bookMarkIcon}',
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const Divider(
//                         color: Color(0xffECEDEE),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16.0, vertical: 9),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("₹27,400",
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff000000),
//                                             15,
//                                             FontWeight.w500))),
//                                 const SizedBox(height: 5),
//                                 Text("MIN.INVEST",
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff666666),
//                                             12,
//                                             FontWeight.w500)))
//                               ],
//                             ),
//                             Column(
//                               children: [
//                                 Text("1.15%",
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff000000),
//                                             15,
//                                             FontWeight.w500))),
//                                 const SizedBox(height: 5),
//                                 Text("3Y CAGR",
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff666666),
//                                             12,
//                                             FontWeight.w500)))
//                               ],
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text("20",
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff000000),
//                                             15,
//                                             FontWeight.w500))),
//                                 const SizedBox(height: 5),
//                                 Text("TOT.STOCKS",
//                                     style: GoogleFonts.inter(
//                                         textStyle: textStyle(
//                                             const Color(0xff666666),
//                                             12,
//                                             FontWeight.w500)))
//                               ],
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 );
//               },
//               separatorBuilder: (context, index) {
//                 return Container(
//                   color: const Color(0xffF1F3F8),
//                   height: 7,
//                   width: MediaQuery.of(context).size.width,
//                 );
//               },
//               itemCount: 2)
//         ],
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
