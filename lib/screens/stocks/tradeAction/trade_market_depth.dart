// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
// import '../../../../model/action_trade_model.dart';
// import '../../../../res/res.dart';

// class TradeMarketDepth extends StatefulWidget {
//   final ActionTradeModel tradedata;
//   const TradeMarketDepth({
//     super.key,
//     required this.tradedata,
//   });

//   @override
//   State<TradeMarketDepth> createState() => _TradeMarketDepthState();
// }

// class _TradeMarketDepthState extends State<TradeMarketDepth> {
//   @override
//   Widget build(BuildContext context) {
//     double screenWidths = MediaQuery.of(context).size.width;
//     double screenWidthss = MediaQuery.of(context).size.width / 2.1;
//     return SizedBox(
//       height: 480,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(
//             height: 16,
//           ),
//           Center(
//             child: Container(
//               height: 3,
//               width: 32,
//               decoration: BoxDecoration(
//                   color: const Color(0xffDDDDDD),
//                   borderRadius: BorderRadius.circular(40)),
//             ),
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
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${widget.tradedata.tsym}',
//                   style: GoogleFonts.inter(
//                       fontSize: 18,
//                       color: const Color(0xff000000),
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.36),
//                 ),
//                 const SizedBox(
//                   height: 6,
//                 ),
//                 Text(
//                   '₹ ${widget.tradedata.ltp}',
//                   style: GoogleFonts.inter(
//                     color: const Color(0xff000000),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 2,
//                 ),
//                 Text(
//                   '${widget.tradedata.perChange} (${widget.tradedata.change}%)',
//                   style: GoogleFonts.inter(
//                     color: widget.tradedata.perChange!.startsWith("-")
//                         ? const Color(0xffFF1717)
//                         : const Color(0xff43A833),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 28,
//                 ),
//                 Text(
//                   'Market Depth',
//                   style: GoogleFonts.inter(
//                     letterSpacing: 0.36,
//                     color: const Color(0xff000000),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Quantity',
//                   style: GoogleFonts.inter(
//                     color: const Color(0xff506D84),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 15,
//                 ),
//                 Text(
//                   'Bid',
//                   style: GoogleFonts.inter(
//                     color: const Color(0xff148564),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   'Ask',
//                   style: GoogleFonts.inter(
//                     color: const Color(0xffD34645),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 15,
//                 ),
//                 Text(
//                   'Quantity',
//                   style: GoogleFonts.inter(
//                     color: const Color(0xff506D84),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                 width: screenWidthss,
//                 // color: Color(0xffDAECE7),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     LinearPercentIndicator(
//                       width: screenWidthss,
//                       backgroundColor: const Color(0xffFFFFFF),
//                       animation: true,
//                       animationDuration: 3000,
//                       lineHeight: 20.0,
//                       percent: 0.20,
//                       center: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '5,007',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff000000)),
//                           ),
//                           Text(
//                             '116.80',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff666666)),
//                           ),
//                         ],
//                       ),
//                       linearStrokeCap: LinearStrokeCap.butt,
//                       progressColor: const Color(0xffDAECE7),
//                     ),
//                   ],
//                 ),
//               ),
//               LinearPercentIndicator(
//                 width: screenWidthss,
//                 backgroundColor: const Color(0xffFCDDDC),
//                 animation: true,
//                 animationDuration: 3000,
//                 lineHeight: 20.0,
//                 percent: 0,
//                 center: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '116.80',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff000000)),
//                     ),
//                     Text(
//                       '5,007',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666)),
//                     ),
//                   ],
//                 ),
//                 progressColor: const Color(0xffFFFFFF),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                 width: screenWidthss,
//                 // color: Color(0xffDAECE7),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     LinearPercentIndicator(
//                       width: screenWidthss,
//                       backgroundColor: const Color(0xffFFFFFF),
//                       animation: true,
//                       animationDuration: 2000,
//                       lineHeight: 20.0,
//                       percent: 0.70,
//                       center: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '5,007',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff000000)),
//                           ),
//                           Text(
//                             '116.80',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff666666)),
//                           ),
//                         ],
//                       ),
//                       linearStrokeCap: LinearStrokeCap.butt,
//                       progressColor: const Color(0xffDAECE7),
//                     ),
//                   ],
//                 ),
//               ),
//               LinearPercentIndicator(
//                 width: screenWidthss,
//                 backgroundColor: const Color(0xffFCDDDC),
//                 animation: true,
//                 animationDuration: 3000,
//                 lineHeight: 20.0,
//                 percent: 0.60,
//                 center: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '116.80',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff000000)),
//                     ),
//                     Text(
//                       '5,007',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666)),
//                     ),
//                   ],
//                 ),
//                 progressColor: const Color(0xffFFFFFF),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                 width: screenWidthss,
//                 // color: Color(0xffDAECE7),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     LinearPercentIndicator(
//                       width: screenWidthss,
//                       backgroundColor: const Color(0xffDAECE7),
//                       animation: true,
//                       animationDuration: 2000,
//                       lineHeight: 20.0,
//                       percent: 0,
//                       center: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '5,007',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff000000)),
//                           ),
//                           Text(
//                             '116.80',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff666666)),
//                           ),
//                         ],
//                       ),
//                       linearStrokeCap: LinearStrokeCap.butt,
//                       progressColor: const Color(0xffFFFFFF),
//                     ),
//                   ],
//                 ),
//               ),
//               LinearPercentIndicator(
//                 width: screenWidthss,
//                 backgroundColor: const Color(0xffFCDDDC),
//                 animation: true,
//                 animationDuration: 3000,
//                 lineHeight: 20.0,
//                 percent: 0.40,
//                 center: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '116.80',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff000000)),
//                     ),
//                     Text(
//                       '5,007',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666)),
//                     ),
//                   ],
//                 ),
//                 progressColor: const Color(0xffFFFFFF),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                 width: screenWidthss,
//                 // color: Color(0xffDAECE7),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     LinearPercentIndicator(
//                       width: screenWidthss,
//                       backgroundColor: const Color(0xffFFFFFF),
//                       animation: true,
//                       animationDuration: 2000,
//                       lineHeight: 20.0,
//                       percent: 0.60,
//                       center: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '5,007',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff000000)),
//                           ),
//                           Text(
//                             '116.80',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff666666)),
//                           ),
//                         ],
//                       ),
//                       progressColor: const Color(0xffDAECE7),
//                     ),
//                   ],
//                 ),
//               ),
//               LinearPercentIndicator(
//                 width: screenWidthss,
//                 backgroundColor: const Color(0xffFCDDDC),
//                 animation: true,
//                 animationDuration: 3000,
//                 lineHeight: 20.0,
//                 percent: 0.30,
//                 center: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '116.80',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff000000)),
//                     ),
//                     Text(
//                       '5,007',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666)),
//                     ),
//                   ],
//                 ),
//                 progressColor: const Color(0xffFFFFFF),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                 width: screenWidthss,
//                 // color: Color(0xffDAECE7),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     LinearPercentIndicator(
//                       width: screenWidthss,
//                       backgroundColor: const Color(0xffFFFFFF),
//                       animation: true,
//                       animationDuration: 2000,
//                       lineHeight: 20.0,
//                       percent: 0.60,
//                       center: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '5,007',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff000000)),
//                           ),
//                           Text(
//                             '116.80',
//                             style: GoogleFonts.inter(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff666666)),
//                           ),
//                         ],
//                       ),
//                       progressColor: const Color(0xffDAECE7),
//                     ),
//                   ],
//                 ),
//               ),
//               LinearPercentIndicator(
//                 width: screenWidthss,
//                 backgroundColor: const Color(0xffFCDDDC),
//                 animation: true,
//                 animationDuration: 3000,
//                 lineHeight: 20.0,
//                 percent: 0.30,
//                 center: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '116.80',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff000000)),
//                     ),
//                     Text(
//                       '5,007',
//                       style: GoogleFonts.inter(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666)),
//                     ),
//                   ],
//                 ),
//                 progressColor: const Color(0xffFFFFFF),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Buy Qty.'.toUpperCase(),
//                       style: GoogleFonts.inter(
//                           letterSpacing: 0.96,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666)),
//                     ),
//                     const SizedBox(
//                       height: 3,
//                     ),
//                     Text(
//                       '65.45%',
//                       style: GoogleFonts.inter(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff000000)),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       'Sell QTY.'.toUpperCase(),
//                       style: GoogleFonts.inter(
//                           letterSpacing: 0.96,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666)),
//                     ),
//                     const SizedBox(
//                       height: 3,
//                     ),
//                     Text(
//                       '32.78%',
//                       style: GoogleFonts.inter(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff000000)),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//           LinearPercentIndicator(
//             barRadius: const Radius.circular(10),
//             backgroundColor: const Color(0xffD34645),
//             width: screenWidths,
//             animation: true,
//             animationDuration: 3000,
//             // fillColor: Color(0xff148564),
//             lineHeight: 5,

//             percent: 0.65,

//             progressColor: const Color(0xff148564),
//           ),
//         ],
//       ),
//     );
//   }
// }
