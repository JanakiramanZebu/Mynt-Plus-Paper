// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// // import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../../res/res.dart';
// import '../../../../../screens/stocks/indices/topindiciesindex/optionstabarviewpage/nifity50companies.dart';
// import '../../../../../sharedWidget/scrollable_btn.dart';
 

// class Nifity50Options extends StatefulWidget {
//   const Nifity50Options({super.key});

//   @override
//   State<Nifity50Options> createState() => _Nifity50OptionsState();
// }

// class _Nifity50OptionsState extends State<Nifity50Options> {
//   List<String> tradeAction = [
//     "Put",
//     "Call",
//   ];

//   List<bool> isActiveBtn = [
//     true,
//     false,
//   ];
//   List<Cars> dummyData = [
//     Cars(
//       futurename: 'NIFTY 25 MAY FUT',
//       expriye: 'Expiry',
//       monthdate: 'May 25',
//       lp: '₹236.05',
//       percentage: '(+1.65%)',
//       oi: 'OI  ',
//       oivalue: '17,47,578',
//       oipercentage: '(-0.47%)',
//     ),
//     Cars(
//       futurename: 'NIFTY 10 JUN FUT',
//       expriye: 'Expiry',
//       monthdate: 'Jun 25',
//       lp: '₹999.05',
//       percentage: '(+1.65%)',
//       oi: 'OI  ',
//       oivalue: '15,45,345',
//       oipercentage: '(-0.34%)',
//     ),
//     Cars(
//       futurename: 'NIFTY 29 JUL FUT',
//       expriye: 'Expiry',
//       monthdate: 'Jul; 25',
//       lp: '₹299.05',
//       percentage: '(+1.25%)',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '(-0.48%)',
//     ),
//     Cars(
//       futurename: 'NIFTY 30 AUG FUT',
//       expriye: 'Expiry',
//       monthdate: 'Aug 25',
//       lp: '₹299.05',
//       percentage: '(+1.25%)',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '(-0.48%)',
//     ),
//     Cars(
//       futurename: 'NIFTY 30 AUG FUT',
//       expriye: 'Expiry',
//       monthdate: 'Aug 25',
//       lp: '₹299.05',
//       percentage: '(+1.25%)',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '(-0.48%)',
//     ),
//     Cars(
//       futurename: 'NIFTY 30 SEP FUT',
//       expriye: 'Expiry',
//       monthdate: 'Sep 25',
//       lp: '₹299.05',
//       percentage: '(+1.25%)',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '(-0.48%)',
//     ),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 16, top: 16),
//           child: SizedBox(
//               height: 30,
//               child:
//                   ScrollableBtn(btnActive: isActiveBtn, btnName: tradeAction)),
//         ),
//         const SizedBox(
//           height: 15,
//         ),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: dummyData.length,
//           itemBuilder: (context, index) {
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         dummyData[index].futurename,
//                         style: GoogleFonts.inter(
//                             fontSize: 14, fontWeight: FontWeight.w500),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: Row(
//                           children: [
//                             Text(
//                               dummyData[index].expriye,
//                               style: GoogleFonts.inter(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff999999)),
//                             ),
//                             const SizedBox(
//                               width: 7,
//                             ),
//                             Text(
//                               dummyData[index].monthdate,
//                               style: GoogleFonts.inter(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color.fromARGB(255, 0, 0, 0)),
//                             )
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Text(
//                             dummyData[index].lp,
//                             style: GoogleFonts.inter(
//                                 fontSize: 14, fontWeight: FontWeight.w500),
//                           ),
//                           const SizedBox(
//                             width: 5,
//                           ),
//                           Text(
//                             dummyData[index].percentage,
//                             style: GoogleFonts.inter(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff43A833)),
//                           )
//                         ],
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               dummyData[index].oi,
//                               style: GoogleFonts.inter(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff999999)),
//                             ),
//                             Text(
//                               dummyData[index].oivalue,
//                               style: GoogleFonts.inter(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff0000000)),
//                             ),
//                             const SizedBox(
//                               width: 5,
//                             ),
//                             Text(
//                               dummyData[index].oipercentage,
//                               style: GoogleFonts.inter(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xffFF1717)),
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//           separatorBuilder: (context, index) {
//             return const Padding(
//               padding: EdgeInsets.symmetric(vertical: 7, horizontal: 16),
//               child: Divider(
//                 color: Color(0xffECEDEE),
//               ),
//             );
//           },
//         ),
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 7, horizontal: 16),
//           child: Divider(
//             color: Color(0xffECEDEE),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: CustomTextBtn(
//             label: 'Nifty 50 option chain',
//             icon: "assets/icon/arrow_right.svg",
//             onPress: () {},
//           ),
//         ),
//         const SizedBox(
//           height: 32,
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//           ),
//           child: Text(
//             'Nifty 50 companies',
//             style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//         ),
//         const SizedBox(
//           height: 17,
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '78 Scrips',
//                 style: GoogleFonts.inter(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xff666666)),
//               ),
//               SizedBox(
//                 height: 25,
//                 width: 75,
//                 child: ElevatedButton(
//                   onPressed: () => {},
//                   style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       backgroundColor: const Color(0x000000 - 1),
//                       side:
//                           const BorderSide(width: 1, color: Color(0xff0037B7)),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(40),
//                       )),
//                   child: Row(
//                     children: [
//                       SvgPicture.asset(assets.sorttool),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       Text(
//                         "Sort",
//                         style: GoogleFonts.inter(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: const Color(0xff0037B7)),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const Divider(
//           color: Color(0xffDDDDDD),
//         ),
//         const Nifity50Companies(),
//       ],
//     );
//   }
// }

// class Cars {
//   String futurename;
//   String expriye;
//   String monthdate;
//   String lp;
//   String percentage;
//   String oi;
//   String oivalue;
//   String oipercentage;
//   Cars({
//     required this.futurename,
//     required this.expriye,
//     required this.monthdate,
//     required this.lp,
//     required this.percentage,
//     required this.oi,
//     required this.oivalue,
//     required this.oipercentage,
//   });
// }
