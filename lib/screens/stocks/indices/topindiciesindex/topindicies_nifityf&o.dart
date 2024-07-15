// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../screens/stocks/indices/topindiciesindex/optionstabarviewpage/nifity50options.dart';

// class NifityFO extends StatefulWidget {
//   const NifityFO({super.key});

//   @override
//   State<NifityFO> createState() => _NifityFOState();
// }

// class _NifityFOState extends State<NifityFO> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Nifty F&O',
//                 style: GoogleFonts.inter(
//                     fontSize: 18, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(
//                 height: 3,
//               ),
//               Text(
//                 'Live Nifty Futures & Options data',
//                 style: GoogleFonts.inter(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xfff666666)),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffCCCCCC)),
//                     borderRadius: BorderRadius.circular(4)),
//                 child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       SizedBox(
//                         height: 60,
//                         width: 100,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'TOTAL CALL OI',
//                               style: GoogleFonts.inter(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff666666)),
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Text(
//                               '17,88,062',
//                               style: GoogleFonts.inter(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black),
//                             )
//                           ],
//                         ),
//                       ),
//                       Container(
//                         height: 60,
//                         width: 80,
//                         color: const Color(0xffF1F3F8),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'PUT : CALL',
//                               style: GoogleFonts.inter(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff666666)),
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Text(
//                               '1.23',
//                               style: GoogleFonts.inter(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black),
//                             )
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 60,
//                         width: 100,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'TOTAL PUT OI',
//                               style: GoogleFonts.inter(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff666666)),
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Text(
//                               '17,88,062',
//                               style: GoogleFonts.inter(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black),
//                             ),
//                           ],
//                         ),
//                       )
//                     ]),
//               )
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 5,
//         ),
//         SizedBox(
//           height: 1400,
//           child: DefaultTabController(
//             initialIndex: 0,
//             length: 2,
//             child: Column(
//               children: [
//                 TabBar(
//                     indicatorColor: const Color(0xff0037B7),
//                     labelColor:
//                         const Color(0xff0037B7), //<-- selected text color
//                     unselectedLabelColor: const Color(0xff666666),
//                     tabs: [
//                       Tab(
//                         child: Text(
//                           'Nifty 50 Options',
//                           style: GoogleFonts.inter(
//                               fontSize: 14, fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                       Tab(
//                         child: Text(
//                           'Nifty 50 FUTURE',
//                           style: GoogleFonts.inter(
//                               fontSize: 14, fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ]),
//                 const Expanded(
//                     child: TabBarView(children: [
//                   Nifity50Options(),
//                   Nifity50Options(),
//                 ]))
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
