// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import '../../../../res/res.dart';

// class TradeAlert extends StatefulWidget {
//   final ActionTradeModel tradeaction;
//   const TradeAlert({
//     super.key,
//     required this.tradeaction,
//   });

//   @override
//   State<TradeAlert> createState() => _TradeAlertState();
// }

// class _TradeAlertState extends State<TradeAlert> {
//   List<Tradinganddemataccount> dematedata = [
//     Tradinganddemataccount(
//       date: '25 Jun, 2023',
//       dealalert: 'Block deal',
//       content:
//           'CBI Books IL&FS Transportation Limited for ‘Causing Loss’ of Over Rs 6,524 Cr',
//     ),
//     Tradinganddemataccount(
//       date: '25 Jun, 2023',
//       dealalert: 'MGMT change',
//       content:
//           'CBI Books IL&FS Transportation Limited for ‘Causing Loss’ of Over Rs 6,524 Cr',
//     ),
//     Tradinganddemataccount(
//       date: '25 Jun, 2023',
//       dealalert: 'Volume Spike',
//       content:
//           'CBI Books IL&FS Transportation Limited for ‘Causing Loss’ of Over Rs 6,524 Cr',
//     ),
//     Tradinganddemataccount(
//       date: '25 Jun, 2023',
//       dealalert: 'Technical',
//       content:
//           'CBI Books IL&FS Transportation Limited for ‘Causing Loss’ of Over Rs 6,524 Cr',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     // double screenhight = MediaQuery.of(context).size.height;
//     return SizedBox(
//       height: 560,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(
//             height: 16,
//           ),
//           Container(
//             height: 3,
//             width: 32,
//             decoration: BoxDecoration(
//                 color: const Color(0xffDDDDDD),
//                 borderRadius: BorderRadius.circular(40)),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Align(
//               alignment: Alignment.bottomRight,
//               child: InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                         width: 2,
//                         color: const Color(0xffDDDDDD),
//                       ),
//                       borderRadius: BorderRadius.circular(40)),
//                   child: SvgPicture.asset(assets.remove),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16,
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                       color: const Color(0xffF0FFEE),
//                       borderRadius: BorderRadius.circular(40)),
//                   child: Row(
//                     children: [
//                       Text(
//                         '${widget.tradeaction.tsym}',
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.inter(
//                           color: const Color(0xff000000),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 12,
//                       ),
//                       Text(
//                         '${widget.tradeaction.ltp}',
//                         style: GoogleFonts.inter(
//                           color: const Color(0xff000000),
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       // ignore: prefer_const_constructors
//                       SizedBox(
//                         width: 2,
//                       ),
//                       Text(
//                         '${widget.tradeaction.perChange}%',
//                         style: GoogleFonts.inter(
//                           color: widget.tradeaction.perChange!.startsWith("-")
//                               ? const Color(0xffE00000)
//                               : const Color(0xff43A833),
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: screenWidth,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//             decoration: const BoxDecoration(
//                 border: Border(
//                     bottom: BorderSide(width: 5, color: Color(0xffF1F3F8)))),
//             child: Text(
//               'Alert',
//               style: GoogleFonts.inter(
//                 letterSpacing: 0.32,
//                 color: const Color(0xff000000),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 ...List.generate(
//                   dematedata.length,
//                   (index) => Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 14),
//                     decoration: const BoxDecoration(
//                         border: Border(
//                             bottom: BorderSide(
//                                 width: 5, color: Color(0xffF1F3F8)))),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               dematedata[index].date,
//                               style: GoogleFonts.inter(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff999999)),
//                             ),
//                             const SizedBox(
//                               width: 12,
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 2),
//                               decoration: BoxDecoration(
//                                   color: const Color(0xffF1F3F8),
//                                   borderRadius: BorderRadius.circular(4)),
//                               child: Text(
//                                 dematedata[index].dealalert.toUpperCase(),
//                                 style: GoogleFonts.inter(
//                                     letterSpacing: 1,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w500,
//                                     color: const Color(0xff666666)),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         Text(
//                           dematedata[index].content,
//                           style: GoogleFonts.inter(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                               color: const Color(0xff000000)),
//                         )
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Center(
//             child: TextButton(
//                 onPressed: () {},
//                 child: Text(
//                   'Load more alerts',
//                   style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
//                 )),
//           ),
//         ],
//       ),
//     );
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     );
//   }
// }

// class Tradinganddemataccount {
//   String date;
//   String dealalert;
//   String content;

//   Tradinganddemataccount({
//     required this.date,
//     required this.dealalert,
//     required this.content,
//   });
// }
