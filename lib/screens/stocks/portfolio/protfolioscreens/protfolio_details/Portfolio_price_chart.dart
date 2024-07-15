// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../../chart/line_chart.dart';

// class PortfolioPriceChart extends StatefulWidget {
//   const PortfolioPriceChart({super.key});

//   @override
//   State<PortfolioPriceChart> createState() => _PortfolioPriceChartState();
// }

// class _PortfolioPriceChartState extends State<PortfolioPriceChart> {
//   double highLow = 490;

//   double weekHighLow = 960;
//   List<String> chartDuration = ["1M", "3M", "6M", "1YR", "3YR", "MAX"];
//   List<bool> isActiveBtn = [true, false, false, false, false, false];
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           child: Text(
//             'Price Chart',
//             style: GoogleFonts.inter(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xff000000),
//                 letterSpacing: 0.28),
//           ),
//         ),
//         Container(
//             decoration: const BoxDecoration(
//                 border: Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
//             height: 50,
//             // padding: const EdgeInsets.only(left: 16),
//             child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context, index) {
//                   return InkWell(
//                     onTap: () {
//                       setState(() {
//                         for (var i = 0; i < isActiveBtn.length; i++) {
//                           isActiveBtn[i] = false;
//                         }
//                         isActiveBtn[index] = true;
//                       });
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                           border: isActiveBtn[index]
//                               ? const Border(
//                                   bottom: BorderSide(
//                                       color: Color(0xff000000), width: 2))
//                               : null),
//                       padding: const EdgeInsets.all(14),
//                       child: Text(chartDuration[index],
//                           style: textStyle(
//                               isActiveBtn[index]
//                                   ? const Color(0xff000000)
//                                   : const Color(0xff666666),
//                               isActiveBtn[index] ? 14 : 13,
//                               FontWeight.w600)),
//                     ),
//                   );
//                 },
//                 separatorBuilder: (context, index) {
//                   return const SizedBox(width: 18);
//                 },
//                 itemCount: chartDuration.length)),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
//           child: Row(
//             children: [
//               Text("RETURNS",
//                   style:
//                       textStyle(const Color(0xff666666), 12, FontWeight.w500)),
//               Text("  18.09%",
//                   style:
//                       textStyle(const Color(0xff43A833), 12, FontWeight.w500)),
//             ],
//           ),
//         ),
//         Container(
//           decoration: const BoxDecoration(
//               border: Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
//           child: AspectRatio(
//             aspectRatio: 1.4,
//             child: LineChartWidget(
//               plotData: PlotData(
//                 maxY: 1000,
//                 minY: 0,
//                 result: [
//                   100,
//                   12,
//                   170,
//                   20,
//                   36,
//                   80,
//                   200,
//                   100,
//                   400,
//                   500,
//                   300,
//                   700,
//                   1000
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//           ),
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             decoration: const BoxDecoration(
//                 border: Border(bottom: BorderSide(color: Color(0xffDDDDDD)))),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'MINIMUM AMOUNT to invest'.toUpperCase(),
//                   style: GoogleFonts.inter(
//                       fontSize: 12,
//                       color: const Color(0xff666666),
//                       fontWeight: FontWeight.w500,
//                       letterSpacing: 0.96),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Text(
//                   '₹1,21,6910',
//                   style: GoogleFonts.inter(
//                     fontSize: 16,
//                     color: const Color(0xff000000),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//               ),
//               child: Container(
//                 width: 150,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 decoration: const BoxDecoration(
//                     border:
//                         Border(bottom: BorderSide(color: Color(0xffDDDDDD)))),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '1yr Cagr'.toUpperCase(),
//                       style: GoogleFonts.inter(
//                           fontSize: 12,
//                           color: const Color(0xff666666),
//                           fontWeight: FontWeight.w500,
//                           letterSpacing: 0.96),
//                     ),
//                     const SizedBox(
//                       height: 8,
//                     ),
//                     Text(
//                       '₹1,21,6910',
//                       style: GoogleFonts.inter(
//                         fontSize: 16,
//                         color: const Color(0xff000000),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//               ),
//               child: Container(
//                 width: 160,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 decoration: const BoxDecoration(
//                     border:
//                         Border(bottom: BorderSide(color: Color(0xffDDDDDD)))),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '5yr Cagr'.toUpperCase(),
//                       style: GoogleFonts.inter(
//                           fontSize: 12,
//                           color: const Color(0xff666666),
//                           fontWeight: FontWeight.w500,
//                           letterSpacing: 0.96),
//                     ),
//                     const SizedBox(
//                       height: 8,
//                     ),
//                     Text(
//                       '₹1,21,6910',
//                       style: GoogleFonts.inter(
//                         fontSize: 16,
//                         color: const Color(0xff000000),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("HIGH-LOW",
//                   style: GoogleFonts.inter(
//                       letterSpacing: 0.96,
//                       textStyle: textStyle(
//                           const Color(0xff666666), 12, FontWeight.w500))),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("₹1,438.80",
//                       style: GoogleFonts.inter(
//                           textStyle: textStyle(
//                               const Color(0xff000000), 14, FontWeight.w500))),
//                   SliderTheme(
//                     data: SliderThemeData(
//                       thumbShape:
//                           const RoundSliderThumbShape(enabledThumbRadius: 6.0),
//                       overlayShape:
//                           const RoundSliderOverlayShape(overlayRadius: 20.0),
//                       inactiveTrackColor: const Color(0xffD9D9D9),
//                       valueIndicatorTextStyle: GoogleFonts.inter(
//                           textStyle: textStyle(
//                               const Color(0xffffffff), 14, FontWeight.w500)),
//                     ),
//                     child: Slider(
//                       min: 100.0,
//                       max: 1348.95,
//                       value: highLow,
//                       activeColor: const Color(0xffD9D9D9),
//                       thumbColor: const Color(0xff000000),
//                       divisions: 10,
//                       label: '₹${highLow.toStringAsFixed(2)}',
//                       onChanged: (value) {
//                         setState(() {
//                           highLow = value;
//                         });
//                       },
//                     ),
//                   ),
//                   Text("₹1,322.65",
//                       style: GoogleFonts.inter(
//                           textStyle: textStyle(
//                               const Color(0xff000000), 14, FontWeight.w500)))
//                 ],
//               ),
//               const Divider(
//                 color: Color(0xffDDDDDD),
//               ),
//               const SizedBox(height: 16),
//               Text("52 Weeks High - 52 Weeks Low".toUpperCase(),
//                   style: GoogleFonts.inter(
//                       letterSpacing: 0.96,
//                       textStyle: textStyle(
//                           const Color(0xff666666), 12, FontWeight.w500))),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("₹1,438.80",
//                       style: GoogleFonts.inter(
//                           textStyle: textStyle(
//                               const Color(0xff000000), 14, FontWeight.w500))),
//                   SliderTheme(
//                     data: SliderThemeData(
//                       thumbShape:
//                           const RoundSliderThumbShape(enabledThumbRadius: 6.0),
//                       overlayShape:
//                           const RoundSliderOverlayShape(overlayRadius: 20.0),
//                       inactiveTrackColor: const Color(0xffD9D9D9),
//                       valueIndicatorTextStyle: GoogleFonts.inter(
//                           textStyle: textStyle(
//                               const Color(0xffffffff), 14, FontWeight.w500)),
//                     ),
//                     child: Slider(
//                       min: 100.0,
//                       max: 2020.95,
//                       value: weekHighLow,
//                       label: '₹${weekHighLow.toStringAsFixed(2)}',
//                       activeColor: const Color(0xffD9D9D9),
//                       thumbColor: const Color(0xff000000),
//                       divisions: 10,
//                       // overlayColor: MaterialStateProperty.resolveWith((states) {
//                       //   return Colors.blue;
//                       // }),
//                       onChanged: (value) {
//                         setState(() {
//                           weekHighLow = value;
//                         });
//                       },
//                     ),
//                   ),
//                   Text("₹1,322.65",
//                       style: GoogleFonts.inter(
//                           textStyle: textStyle(
//                               const Color(0xff000000), 14, FontWeight.w500)))
//                 ],
//               ),
//               const Divider(
//                 color: Color(0xffDDDDDD),
//               ),
//             ],
//           ),
//         )
//       ],
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
