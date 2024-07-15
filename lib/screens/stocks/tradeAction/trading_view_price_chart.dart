// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:readmore/readmore.dart';
// import '../../../../chart/line_chart.dart';
// import '../../../../screens/mutualfund/topFund/fundDetail/fund_returns.dart';
// import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_market_depth.dart';

// class TradingViewPriceChart extends StatefulWidget {
//   const TradingViewPriceChart({super.key});

//   @override
//   State<TradingViewPriceChart> createState() => _TradingViewPriceChartState();
// }

// class _TradingViewPriceChartState extends State<TradingViewPriceChart> {
//   @override
//   Widget build(BuildContext context) {
//     double low = 0.00;
//     double high = 0.00;
//     double price = 0.00;

//     List<String> chartDuration = ["1M", "3M", "6M", "1YR", "3YR", "MAX"];
//     List<bool> isActiveBtn = [true, false, false, false, false, false];

//     return Column(
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               child: Text("Price Chart",
//                   style:
//                       textStyle(const Color(0xff000000), 16, FontWeight.w600)),
//             ),
//             Container(
//                 height: 50,
//                 decoration: const BoxDecoration(
//                     border: Border(
//                         bottom:
//                             BorderSide(color: Color(0xff666666), width: 0.1))),
//                 child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     itemBuilder: (context, index) {
//                       return InkWell(
//                         onTap: () {
//                           setState(() {
//                             for (var i = 0; i < isActiveBtn.length; i++) {
//                               isActiveBtn[i] = false;
//                             }
//                             isActiveBtn[index] = true;
//                           });
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                               border: isActiveBtn[index]
//                                   ? const Border(
//                                       bottom: BorderSide(
//                                           color: Color(0xff000000), width: 2))
//                                   : null),
//                           padding: const EdgeInsets.all(14),
//                           child: Text(chartDuration[index],
//                               style: textStyle(
//                                   isActiveBtn[index]
//                                       ? const Color(0xff000000)
//                                       : const Color(0xff666666),
//                                   isActiveBtn[index] ? 13 : 13,
//                                   FontWeight.w600)),
//                         ),
//                       );
//                     },
//                     separatorBuilder: (context, index) {
//                       return const SizedBox(width: 16);
//                     },
//                     itemCount: chartDuration.length)),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//               child: Row(
//                 children: [
//                   Text("RETURNS",
//                       style: textStyle(
//                         const Color(0xff666666),
//                         12,
//                         FontWeight.w500,
//                       )),
//                   Text("  +13.30%",
//                       style: textStyle(
//                           const Color(0xff43A833), 12, FontWeight.w500)),
//                 ],
//               ),
//             ),
//             AspectRatio(
//               aspectRatio: 1.4,
//               child: LineChartWidget(
//                 plotData: PlotData(
//                   maxY: 1000,
//                   minY: 0,
//                   result: [
//                     100,
//                     12,
//                     170,
//                     20,
//                     36,
//                     80,
//                     200,
//                     100,
//                     400,
//                     500,
//                     300,
//                     700,
//                     1000
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 28,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 158,
//                     height: 55,
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           //                   <--- left side
//                           color: Color(0xffDDDDDD),
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Market Cap'.toUpperCase(),
//                           style: GoogleFonts.inter(
//                               letterSpacing: 0.96,
//                               fontSize: 12,
//                               color: const Color(0xfff666666),
//                               fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '1575681.48Cr',
//                           style: GoogleFonts.inter(
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: 158,
//                     height: 55,
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           //                   <--- left side
//                           color: Color(0xffDDDDDD),
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Volume'.toUpperCase(),
//                           style: GoogleFonts.inter(
//                               letterSpacing: 0.96,
//                               fontSize: 12,
//                               color: const Color(0xfff666666),
//                               fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '8,00,231.00',
//                           style: GoogleFonts.inter(
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 158,
//                     height: 55,
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           //                   <--- left side
//                           color: Color(0xffDDDDDD),
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Open Value'.toUpperCase(),
//                           style: GoogleFonts.inter(
//                               letterSpacing: 0.96,
//                               fontSize: 12,
//                               color: const Color(0xfff666666),
//                               fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '₹2,435.00',
//                           style: GoogleFonts.inter(
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: 158,
//                     height: 55,
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           //                   <--- left side
//                           color: Color(0xffDDDDDD),
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Close Value'.toUpperCase(),
//                           style: GoogleFonts.inter(
//                               letterSpacing: 0.96,
//                               fontSize: 12,
//                               color: const Color(0xfff666666),
//                               fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '₹2,441.95',
//                           style: GoogleFonts.inter(
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 'HIGH-LOW',
//                 style: GoogleFonts.inter(
//                     fontSize: 12,
//                     color: const Color(0xff666666),
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 0.96),
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '₹1,348.95',
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       color: const Color(0xff000000),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 162,
//                     child: SliderTheme(
//                       data: SliderThemeData(
//                         thumbColor: const Color(0xffFFFFFF),
//                         thumbShape: const RoundSliderThumbShape(
//                             enabledThumbRadius: 6.0),
//                         overlayShape:
//                             const RoundSliderOverlayShape(overlayRadius: 1),
//                         inactiveTrackColor: const Color(0xff000000),
//                         valueIndicatorTextStyle: GoogleFonts.inter(
//                             textStyle: textStyle(
//                                 const Color(0xffffffff), 14, FontWeight.w500)),
//                       ),
//                       child: Slider(
//                           min: low == 0.00 ? price - 10 : low,
//                           max: high == 0.00 ? price + 10 : high,
//                           value: price,
//                           label: "₹$price",
//                           activeColor: const Color(0xffD9D9D9),
//                           thumbColor: const Color(0xff000000),
//                           // divisions: 10,
//                           onChanged: null),
//                     ),
//                   ),
//                   Text(
//                     '₹1,322.65',
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       color: const Color(0xff000000),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Divider(
//                 color: Color(0xffDDDDDD),
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 '52 Weeks High - 52 Weeks Low'.toUpperCase(),
//                 style: GoogleFonts.inter(
//                     fontSize: 12,
//                     color: const Color(0xff666666),
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 0.96),
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '₹1,438.80',
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       color: const Color(0xff000000),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 162,
//                     child: SliderTheme(
//                       data: SliderThemeData(
//                         thumbShape: const RoundSliderThumbShape(
//                             enabledThumbRadius: 6.0),
//                         overlayShape:
//                             const RoundSliderOverlayShape(overlayRadius: 8.0),
//                         inactiveTrackColor: const Color(0xff000000),
//                         valueIndicatorTextStyle: GoogleFonts.inter(
//                             textStyle: textStyle(
//                                 const Color(0xffffffff), 14, FontWeight.w500)),
//                       ),
//                       child: Slider(
//                           thumbColor: Colors.black,
//                           min: low == 0.00 ? price - 10 : low,
//                           max: high == 0.00 ? price + 10 : high,
//                           value: price,
//                           label: "₹$price",
//                           activeColor: const Color(0xffD9D9D9),

//                           // divisions: 10,
//                           onChanged: null),
//                     ),
//                   ),
//                   Text(
//                     '₹1300.34',
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       color: const Color(0xff000000),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Divider(
//                 color: Color(0xffDDDDDD),
//               ),
//             ),
//             const FundReturns(),
//             const SectorMarketDepth(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 'RELIANCE Stock Overview',
//                 style: GoogleFonts.inter(
//                     fontSize: 16,
//                     color: const Color(0xff000000),
//                     fontWeight: FontWeight.w600),
//               ),
//             ),
//             const SizedBox(
//               height: 4,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: ReadMoreText(
//                 'Reliance Industries is an Indian multinational company incorporated in 1973 by Dhirubhai Ambani and is headquartered in Mumbai, India. Reliance Industries Ltd has diversified into several segments like energy, petrochemical, natural gas, retail, telecommunication, media and textile.',
//                 style: GoogleFonts.inter(
//                     letterSpacing: -0.07,
//                     height: 1.5,
//                     textStyle: textStyle(
//                         const Color(0xff666666), 14, FontWeight.w600)),
//                 trimLines: 3,
//                 colorClickableText: const Color(0xff0037B7),
//                 trimMode: TrimMode.Line,
//                 trimCollapsedText: 'Show more',
//                 trimExpandedText: 'Show less',
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             const Divider(
//               color: Color(0xffDDDDDD),
//             ),
//           ],
//         ),
//       ],
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
