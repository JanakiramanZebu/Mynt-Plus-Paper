// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../chart/line_chart.dart';

// class TradeActionLiveChart extends StatefulWidget {
//   const TradeActionLiveChart({super.key});

//   @override
//   State<TradeActionLiveChart> createState() => _TradeActionLiveChartState();
// }

// class _TradeActionLiveChartState extends State<TradeActionLiveChart> {
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
//         AspectRatio(
//           aspectRatio: 1.4,
//           child: LineChartWidget(
//             plotData: PlotData(
//               maxY: 1000,
//               minY: 0,
//               result: [
//                 100,
//                 12,
//                 170,
//                 20,
//                 36,
//                 80,
//                 200,
//                 100,
//                 400,
//                 500,
//                 300,
//                 700,
//                 1000
//               ],
//             ),
//           ),
//         ),
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
