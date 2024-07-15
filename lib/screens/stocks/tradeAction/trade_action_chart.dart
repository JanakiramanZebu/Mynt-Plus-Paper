// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../model/action_trade_model.dart';
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/tradeAction/trade_action_live_chart.dart';

// class TradeActionChart extends StatefulWidget {
//   final ActionTradeModel tradeaction;
//   const TradeActionChart({
//     super.key,
//     required this.tradeaction,
//   });

//   @override
//   State<TradeActionChart> createState() => _TradeActionChartState();
// }

// class _TradeActionChartState extends State<TradeActionChart> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 580,
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
//           const TradeActionLiveChart(),
//           const SizedBox(
//             height: 10,
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             decoration: const BoxDecoration(
//                 border: Border(
//                     bottom: BorderSide(color: Color(0xffF1F3F5)),
//                     top: BorderSide(color: Color(0xffF1F3F5)))),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(
//                   width: 166,
//                   height: 40,
//                   child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xff43A833),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(32))),
//                       onPressed: () {},
//                       child: Text(
//                         'Buy',
//                         style: GoogleFonts.inter(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: const Color(0xffFFFFFF)),
//                       )),
//                 ),
//                 SizedBox(
//                   width: 166,
//                   height: 40,
//                   child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xffFF1717),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(32))),
//                       onPressed: () {},
//                       child: Text(
//                         'Sell',
//                         style: GoogleFonts.inter(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: const Color(0xffFFFFFF)),
//                       )),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
