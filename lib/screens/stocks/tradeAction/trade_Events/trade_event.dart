// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import '../../../../res/res.dart';

// class TradeEvent extends StatefulWidget {
//   final ActionTradeModel tradeaction;
//   const TradeEvent({
//     super.key,
//     required this.tradeaction,
//   });

//   @override
//   State<TradeEvent> createState() => _TradeEventState();
// }

// class _TradeEventState extends State<TradeEvent> {
//   int selectedBtn = 0;

//   List<String> tradeAction = [
//     "Dividends",
//     "Corp. action",
//     "Announcement",
//     "Judiciary",
//   ];
//   List<String> chartDuration = [
//     "Upcoming Corp. action",
//     "Past Corp. action",
//   ];
//   List<bool> isActivecrop = [
//     true,
//     false,
//   ];
//   List<bool> isActiveBtn = [true, false, false, false];
//   List<Tradinganddemataccount> dematedata = [
//     Tradinganddemataccount(
//       date: 'Ex date -',
//       dealalert: 'Block deal',
//     ),
//     Tradinganddemataccount(
//       date: 'Ex date -',
//       dealalert: 'Block deal',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     // double screenhight = MediaQuery.of(context).size.height;
//     return SizedBox(
//       height: isActiveBtn[0]
//           ? 500
//           : isActiveBtn[1]
//               ? 505
//               : isActiveBtn[2]
//                   ? 490
//                   : isActiveBtn[3]
//                       ? 490
//                       : 0,
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
//             padding: const EdgeInsets.only(left: 16, top: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Event',
//                   style: GoogleFonts.inter(
//                     letterSpacing: 0.32,
//                     color: const Color(0xff000000),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 12,
//                 ),
//                 SizedBox(
//                   height: 34,
//                   child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       itemBuilder: (context, index) {
//                         return InkWell(
//                           onTap: () {
//                             setState(() {
//                               for (var i = 0; i < isActiveBtn.length; i++) {
//                                 isActiveBtn[i] = false;
//                               }
//                               isActiveBtn[index] = true;
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(40),
//                               border: Border.all(
//                                   color: Color(!isActiveBtn[index]
//                                       ? 0xff666666
//                                       : 0xff000000)),
//                             ),
//                             child: Center(
//                               child: Text(tradeAction[index],
//                                   style: textStyle(
//                                       Color(isActiveBtn[index]
//                                           ? 0xff000000
//                                           : 0xff666666),
//                                       14,
//                                       isActiveBtn[index]
//                                           ? FontWeight.w600
//                                           : FontWeight.w500)),
//                             ),
//                           ),
//                         );
//                       },
//                       separatorBuilder: (context, index) {
//                         return const SizedBox(width: 8);
//                       },
//                       itemCount: isActiveBtn[1] || isActiveBtn[2]
//                           ? 4
//                           : tradeAction.length),
//                 ),
//               ],
//             ),
//           ),

//           if (isActiveBtn[0]) ...[diviDend()],
//           if (isActiveBtn[1]) ...[cropAction()],
//           if (isActiveBtn[2]) ...[announceMent()],
//           if (isActiveBtn[3]) ...[judiciary()],
//           // Expanded(
//           //   child: ListView(
//           //     scrollDirection: Axis.vertical,
//           //     shrinkWrap: true,
//           //     physics: NeverScrollableScrollPhysics(),
//           //     children: [
//           //       ...List.generate(
//           //         dematedata.length,
//           //         (index) => Container(
//           //           padding: const EdgeInsets.symmetric(
//           //               horizontal: 16, vertical: 14),
//           //           decoration: const BoxDecoration(
//           //               border: Border(
//           //                   bottom: BorderSide(
//           //                       width: 5, color: Color(0xffF1F3F8)))),
//           //           child: Column(
//           //             children: [
//           //               Row(
//           //                 children: [
//           //                   Text(
//           //                     dematedata[index].date,
//           //                     style: GoogleFonts.inter(
//           //                         fontSize: 12,
//           //                         fontWeight: FontWeight.w500,
//           //                         color: Color(0xff999999)),
//           //                   ),
//           //                   const SizedBox(
//           //                     width: 12,
//           //                   ),
//           //                   Container(
//           //                     padding: const EdgeInsets.symmetric(
//           //                         horizontal: 8, vertical: 2),
//           //                     decoration: BoxDecoration(
//           //                         color: const Color(0xffF1F3F8),
//           //                         borderRadius: BorderRadius.circular(4)),
//           //                     child: Text(
//           //                       dematedata[index].dealalert.toUpperCase(),
//           //                       style: GoogleFonts.inter(
//           //                           letterSpacing: 1,
//           //                           fontSize: 10,
//           //                           fontWeight: FontWeight.w500,
//           //                           color: const Color(0xff666666)),
//           //                     ),
//           //                   ),
//           //                 ],
//           //               ),
//           //               const SizedBox(
//           //                 height: 8,
//           //               ),
//           //               Text(
//           //                 dematedata[index].content,
//           //                 style: GoogleFonts.inter(
//           //                     fontSize: 13,
//           //                     fontWeight: FontWeight.w500,
//           //                     color: const Color(0xff000000)),
//           //               )
//           //             ],
//           //           ),
//           //         ),
//           //       )
//           //     ],
//           //   ),
//           // ),
//           // Center(
//           //   child: TextButton(
//           //       onPressed: () {},
//           //       child: Text(
//           //         'Load more alerts',
//           //         style: textStyle(Color(0xff0037B7), 14, FontWeight.w600),
//           //       )),
//           // ),
//         ],
//       ),
//     );
//   }

// /////DIVIDENDS/////////
//   SizedBox diviDend() {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return SizedBox(
//       height: 337,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 6),
//           SizedBox(
//             width: screenWidth,
//             child: Column(
//               children: [
//                 Container(
//                   width: screenWidth,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   decoration: const BoxDecoration(
//                       border: Border(
//                           bottom:
//                               BorderSide(width: 5, color: Color(0xffF1F3F8)))),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '2023 Dividends',
//                         style: GoogleFonts.inter(
//                           letterSpacing: 1.04,
//                           color: const Color(0xff000000),
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Container(
//                         height: 33,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                         ),
//                         decoration: BoxDecoration(
//                             color: const Color(0xffF1F3F8),
//                             borderRadius: BorderRadius.circular(24)),
//                         child: Row(
//                           children: [
//                             Text("2023",
//                                 style: GoogleFonts.inter(
//                                     textStyle: textStyle(
//                                         const Color(0xff000000),
//                                         13,
//                                         FontWeight.w500))),
//                             SvgPicture.asset(
//                               assets.vector,
//                               width: 38,
//                               height: 40,
//                               fit: BoxFit.scaleDown,
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
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
//                     decoration: const BoxDecoration(
//                         border: Border(
//                             bottom: BorderSide(
//                                 width: 6, color: Color(0xffF1F3F8)))),
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(vertical: 2),
//                           decoration: const BoxDecoration(
//                               border: Border(
//                                   bottom:
//                                       BorderSide(color: Color(0xffECEDEE)))),
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const SizedBox(
//                                         width: 16,
//                                       ),
//                                       Text(
//                                         dematedata[index].date,
//                                         style: GoogleFonts.inter(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w500,
//                                             color: const Color(0xff666666)),
//                                       ),
//                                       Text(
//                                         ' 25 Jun, 2023',
//                                         style: GoogleFonts.inter(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w500,
//                                             color: const Color(0xff000000)),
//                                       ),
//                                     ],
//                                   ),
//                                   TextButton(
//                                       onPressed: () {},
//                                       child: Text(
//                                         'Read Documents',
//                                         style: textStyle(const Color(0xff0037B7), 13,
//                                             FontWeight.w500),
//                                       )),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Dividend'.toUpperCase(),
//                                       style: GoogleFonts.inter(
//                                         letterSpacing: 0.66,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff666666),
//                                       )),
//                                   Text('23 /share',
//                                       style: GoogleFonts.inter(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff000000),
//                                       )),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Total dividend'.toUpperCase(),
//                                       style: GoogleFonts.inter(
//                                         letterSpacing: 0.66,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff666666),
//                                       )),
//                                   Text('750',
//                                       style: GoogleFonts.inter(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff000000),
//                                       )),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text('Yield'.toUpperCase(),
//                                       style: GoogleFonts.inter(
//                                         letterSpacing: 0.66,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff666666),
//                                       )),
//                                   Text('2.3%',
//                                       style: GoogleFonts.inter(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff000000),
//                                       )),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
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

// /////Crop Action////////
//   SizedBox cropAction() {
//     return SizedBox(
//       height: 340,
//       child: Column(
//         children: [
//           const SizedBox(
//             height: 15,
//           ),
//           Container(
//               decoration: const BoxDecoration(
//                   border: Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
//               height: 50,
//               child: ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   scrollDirection: Axis.horizontal,
//                   itemBuilder: (context, index) {
//                     return InkWell(
//                       onTap: () {
//                         setState(() {
//                           for (var i = 0; i < isActivecrop.length; i++) {
//                             isActivecrop[i] = false;
//                           }
//                           isActivecrop[index] = true;
//                         });
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                             border: isActivecrop[index]
//                                 ? const Border(
//                                     bottom: BorderSide(
//                                         color: Color(0xff0037B7), width: 2))
//                                 : null),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 40, vertical: 14),
//                         child: Text(chartDuration[index],
//                             style: textStyle(
//                                 isActivecrop[index]
//                                     ? const Color(0xff0037B7)
//                                     : const Color(0xff777777),
//                                 isActivecrop[index] ? 14 : 13,
//                                 FontWeight.w600)),
//                       ),
//                     );
//                   },
//                   separatorBuilder: (context, index) {
//                     return const SizedBox(
//                       width: 0,
//                     );
//                   },
//                   itemCount: isActivecrop[0] || isActivecrop[1]
//                       ? 2
//                       : chartDuration.length)),
//           if (isActivecrop[0]) ...[
//             upcomingCropaction(),
//           ],
//           if (isActivecrop[1]) ...[
//             pastCropaciton(),
//           ]
//         ],
//       ),
//     );
//   }

// /////Crop Action (TAB_VIEW)  upcomingCropaction Tab//////
//   SizedBox upcomingCropaction() {
//     return SizedBox(
//       height: 270,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: ListView(
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 ...List.generate(
//                   dematedata.length,
//                   (index) => Container(
//                     decoration: const BoxDecoration(
//                         border: Border(
//                             bottom: BorderSide(
//                                 width: 6, color: Color(0xffF1F3F8)))),
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(vertical: 2),
//                           decoration: const BoxDecoration(
//                               border: Border(
//                                   bottom:
//                                       BorderSide(color: Color(0xffECEDEE)))),
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const SizedBox(
//                                         width: 16,
//                                       ),
//                                       Text(
//                                         dematedata[index].date,
//                                         style: GoogleFonts.inter(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w500,
//                                             color: const Color(0xff666666)),
//                                       ),
//                                       Text(
//                                         ' 25 Jun, 2023',
//                                         style: GoogleFonts.inter(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w500,
//                                             color: const Color(0xff000000)),
//                                       ),
//                                     ],
//                                   ),
//                                   TextButton(
//                                       onPressed: () {},
//                                       child: Text(
//                                         'Read Documents',
//                                         style: textStyle(const Color(0xff0037B7), 13,
//                                             FontWeight.w500),
//                                       )),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8, vertical: 6),
//                                     decoration: BoxDecoration(
//                                         color: const Color(0xffF1F3F8),
//                                         borderRadius: BorderRadius.circular(4)),
//                                     child: Text(
//                                       'Rights'.toUpperCase(),
//                                       style: GoogleFonts.inter(
//                                         letterSpacing: 1.2,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff666666),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Total dividend'.toUpperCase(),
//                                       style: GoogleFonts.inter(
//                                         letterSpacing: 0.66,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff666666),
//                                       )),
//                                   Text('750',
//                                       style: GoogleFonts.inter(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff000000),
//                                       )),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text('Yield'.toUpperCase(),
//                                       style: GoogleFonts.inter(
//                                         letterSpacing: 0.66,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff666666),
//                                       )),
//                                   Text('2.3%',
//                                       style: GoogleFonts.inter(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff000000),
//                                       )),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
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

// /////Crop Action (TAB_VIEW) pastCropaciton Tab//////
//   SizedBox pastCropaciton() {
//     return SizedBox(
//       height: 270,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: ListView(
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 ...List.generate(
//                   dematedata.length,
//                   (index) => Container(
//                     decoration: const BoxDecoration(
//                         border: Border(
//                             bottom: BorderSide(
//                                 width: 6, color: Color(0xffF1F3F8)))),
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(vertical: 2),
//                           decoration: const BoxDecoration(
//                               border: Border(
//                                   bottom:
//                                       BorderSide(color: Color(0xffECEDEE)))),
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const SizedBox(
//                                         width: 16,
//                                       ),
//                                       Text(
//                                         dematedata[index].date,
//                                         style: GoogleFonts.inter(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w500,
//                                             color: const Color(0xff666666)),
//                                       ),
//                                       Text(
//                                         ' 25 Jun, 2023',
//                                         style: GoogleFonts.inter(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w500,
//                                             color: const Color(0xff000000)),
//                                       ),
//                                     ],
//                                   ),
//                                   TextButton(
//                                       onPressed: () {},
//                                       child: Text(
//                                         'Read Documents',
//                                         style: textStyle(const Color(0xff0037B7), 13,
//                                             FontWeight.w500),
//                                       )),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8, vertical: 6),
//                                     decoration: BoxDecoration(
//                                         color: const Color(0xffF1F3F8),
//                                         borderRadius: BorderRadius.circular(4)),
//                                     child: Text(
//                                       'Bounces'.toUpperCase(),
//                                       style: GoogleFonts.inter(
//                                         letterSpacing: 1.2,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff666666),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Total dividend'.toUpperCase(),
//                                       style: GoogleFonts.inter(
//                                         letterSpacing: 0.66,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff666666),
//                                       )),
//                                   Text('750',
//                                       style: GoogleFonts.inter(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff000000),
//                                       )),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text('Yield'.toUpperCase(),
//                                       style: GoogleFonts.inter(
//                                         letterSpacing: 0.66,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff666666),
//                                       )),
//                                   Text('2.3%',
//                                       style: GoogleFonts.inter(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: const Color(0xff000000),
//                                       )),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
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

// /////Announcement//////
//   SizedBox announceMent() {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return SizedBox(
//       height: 325,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 6),
//           SizedBox(
//             width: screenWidth,
//             child: Column(
//               children: [
//                 Container(
//                   width: screenWidth,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   decoration: const BoxDecoration(
//                       border: Border(
//                           bottom:
//                               BorderSide(width: 5, color: Color(0xffF1F3F8)))),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Announcement'.toUpperCase(),
//                         style: GoogleFonts.inter(
//                           letterSpacing: 0.96,
//                           color: const Color(0xff000000),
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 ...List.generate(
//                   5,
//                   (index) => Container(
//                       padding:
//                           const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                       decoration: const BoxDecoration(
//                           border: Border(
//                               bottom: BorderSide(
//                                   width: 6, color: Color(0xffF1F3F8)))),
//                       child: Row(
//                         children: [
//                           SvgPicture.asset(assets.note),
//                           const SizedBox(
//                             width: 18,
//                           ),
//                           Expanded(
//                             child: Text(
//                               'Disposal of 17,333 equity shares worth Rs 68.47 lacs by director',
//                               style: GoogleFonts.inter(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff000000)),
//                             ),
//                           ),
//                         ],
//                       )),
//                 )
//               ],
//             ),
//           ),
//           Center(
//             child: TextButton(
//                 onPressed: () {},
//                 child: Text(
//                   'Load more announcement',
//                   style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
//                 )),
//           ),
//         ],
//       ),
//     );
//   }

// //////judiciary///////
//   SizedBox judiciary() {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return SizedBox(
//       height: 325,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 6),
//           SizedBox(
//             width: screenWidth,
//             child: Column(
//               children: [
//                 Container(
//                   width: screenWidth,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   decoration: const BoxDecoration(
//                       border: Border(
//                           bottom:
//                               BorderSide(width: 5, color: Color(0xffF1F3F8)))),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Judiciary'.toUpperCase(),
//                         style: GoogleFonts.inter(
//                           letterSpacing: 0.96,
//                           color: const Color(0xff000000),
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 ...List.generate(
//                   5,
//                   (index) => Container(
//                       padding:
//                           const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                       decoration: const BoxDecoration(
//                           border: Border(
//                               bottom: BorderSide(
//                                   width: 6, color: Color(0xffF1F3F8)))),
//                       child: Row(
//                         children: [
//                           SvgPicture.asset(assets.judiciry),
//                           const SizedBox(
//                             width: 18,
//                           ),
//                           Expanded(
//                             child: Text(
//                               'Announcement under Regulation 30 (LODR)-Analyst / Investor Meet - Outcome',
//                               style: GoogleFonts.inter(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff000000)),
//                             ),
//                           ),
//                         ],
//                       )),
//                 )
//               ],
//             ),
//           ),
//           Center(
//             child: TextButton(
//                 onPressed: () {},
//                 child: Text(
//                   'Load more announcement',
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

//   Tradinganddemataccount({
//     required this.date,
//     required this.dealalert,
//   });
// }
