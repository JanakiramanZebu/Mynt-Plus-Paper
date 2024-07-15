// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../../chart/indicator.dart';

// class InverstDonutChaetWidget extends StatefulWidget {
//   const InverstDonutChaetWidget({super.key});

//   @override
//   State<InverstDonutChaetWidget> createState() => _LineCharrtWidgetState();
// }

// class _LineCharrtWidgetState extends State<InverstDonutChaetWidget> {
//   int touchedIndex = -1;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Text("Fund asset allocation",
//         //     style: textStyle(const Color(0xff999999), 16, FontWeight.w500)),

//         const SizedBox(height: 40),
//         AspectRatio(
//           aspectRatio: 1.3,
//           child: Stack(
//             children: [
//               PieChart(
//                 PieChartData(
//                   pieTouchData: PieTouchData(
//                     touchCallback: (FlTouchEvent event, pieTouchResponse) {
//                       setState(() {
//                         if (!event.isInterestedForInteractions ||
//                             pieTouchResponse == null ||
//                             pieTouchResponse.touchedSection == null) {
//                           touchedIndex = -1;
//                           return;
//                         }
//                         touchedIndex = pieTouchResponse
//                             .touchedSection!.touchedSectionIndex;
//                       });

//                       log(touchedIndex);
//                     },
//                   ),
//                   borderData: FlBorderData(
//                     show: false,
//                   ),
//                   sectionsSpace: 1,
//                   centerSpaceRadius: 97,
//                   sections: showingSections(),
//                 ),
//               ),
//               Center(
//                 child: Text(
//                   " 23 Segment \nCompositions",
//                   style: GoogleFonts.inter(
//                       letterSpacing: 0.28,
//                       fontSize: 14.0,
//                       color: const Color(0xff999999),
//                       fontWeight: FontWeight.bold),
//                 ),
//               )
//             ],
//           ),
//         ),
//         const SizedBox(height: 40),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Row(
//               children: [
//                 Indicator(
//                   color: const Color(0xff3AAA92),
//                   textColor: touchedIndex == 0
//                       ? const Color(0xff666666)
//                       : const Color(0xff000000),
//                   title: 'Banking and Finance',
//                   size: 12,
//                   isSquare: false,
//                 ),
//                 const SizedBox(
//                   width: 45,
//                 ),
//                 Indicator(
//                   color: const Color(0xffA8E5D4),
//                   textColor: touchedIndex == 0
//                       ? const Color(0xff666666)
//                       : const Color(0xff000000),
//                   title: 'Utilities',
//                   size: 12,
//                   isSquare: false,
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 12,
//             ),
//             Row(
//               children: [
//                 Indicator(
//                   color: const Color(0xffECD7A1),
//                   textColor: touchedIndex == 1
//                       ? const Color(0xff666666)
//                       : const Color(0xff000000),
//                   title: 'Software & Services',
//                   size: 12,
//                   isSquare: false,
//                 ),
//                 const SizedBox(
//                   width: 48,
//                 ),
//                 Indicator(
//                   color: const Color(0xffF6CE47),
//                   textColor: touchedIndex == 1
//                       ? const Color(0xff666666)
//                       : const Color(0xff000000),
//                   title: 'Pharmaceuticals',
//                   size: 12,
//                   isSquare: false,
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 12,
//             ),
//             Row(
//               children: [
//                 Indicator(
//                   color: const Color(0xfff93cf85),
//                   textColor: touchedIndex == 2
//                       ? const Color(0xff666666)
//                       : const Color(0xff000000),
//                   title: 'FMCG',
//                   size: 12,
//                   isSquare: false,
//                 ),
//                 const SizedBox(
//                   width: 128,
//                 ),
//                 Indicator(
//                   color: const Color(0xfff93cf85),
//                   textColor: touchedIndex == 2
//                       ? const Color(0xff666666)
//                       : const Color(0xff000000),
//                   title: 'Retailing',
//                   size: 12,
//                   isSquare: false,
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 12,
//             ),
//             Row(
//               children: [
//                 Indicator(
//                   color: const Color(0xfffcad168),
//                   textColor: touchedIndex == 2
//                       ? const Color(0xff666666)
//                       : const Color(0xff000000),
//                   title: 'Automobile',
//                   size: 12,
//                   isSquare: false,
//                 ),
//                 const SizedBox(
//                   width: 98,
//                 ),
//                 Indicator(
//                   color: const Color(0xfffe19226),
//                   textColor: touchedIndex == 2
//                       ? const Color(0xff666666)
//                       : const Color(0xff000000),
//                   title: 'Restaurants & Tourism',
//                   size: 12,
//                   isSquare: false,
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 12,
//             ),
//             Indicator(
//               color: const Color(0xfffd86f10),
//               textColor: touchedIndex == 2
//                   ? const Color(0xff666666)
//                   : const Color(0xff000000),
//               title: 'Telecom Services',
//               size: 12,
//               isSquare: false,
//             ),
//           ],
//         ),
//         const SizedBox(height: 16)
//       ],
//     );
//   }

//   List<PieChartSectionData> showingSections() {
//     return List.generate(8, (i) {
//       final isTouched = i == touchedIndex;
//       // final fontSize = isTouched ? 25.0 : 16.0;
//       final radius = isTouched ? 60.0 : 50.0;
//       // const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
//       switch (i) {
//         case 0:
//           return PieChartSectionData(
//               color: const Color(0xff3AAA92),
//               value: 30,
//               radius: radius,
//               showTitle: false);
//         case 1:
//           return PieChartSectionData(
//               color: const Color(0xffECD7A1),
//               value: 15,
//               radius: radius,
//               showTitle: false);
//         case 2:
//           return PieChartSectionData(
//               color: const Color(0xfff93cf85),
//               value: 5,
//               radius: radius,
//               showTitle: false);
//         case 3:
//           return PieChartSectionData(
//               color: const Color(0xffA8E5D4),
//               value: 20,
//               radius: radius,
//               showTitle: false);
//         case 4:
//           return PieChartSectionData(
//               color: const Color(0xffF6CE47),
//               value: 30,
//               radius: radius,
//               showTitle: false);
//         case 5:
//           return PieChartSectionData(
//               color: const Color(0xfffcad168),
//               value: 45,
//               radius: radius,
//               showTitle: false);
//         case 6:
//           return PieChartSectionData(
//               color: const Color(0xfffe19226),
//               value: 20,
//               radius: radius,
//               showTitle: false);
//         case 7:
//           return PieChartSectionData(
//               color: const Color(0xfffd86f10),
//               value: 45,
//               radius: radius,
//               showTitle: false);
//         default:
//           throw Error();
//       }
//     });
//   }

//   Widget bottomTitleWidgets(double value, TitleMeta meta) {
//     const style = TextStyle(
//       fontWeight: FontWeight.bold,
//       fontSize: 16,
//     );
//     Widget text;
//     switch (value.toInt()) {
//       case 2:
//         text = const Text('MAR', style: style);
//         break;
//       case 5:
//         text = const Text('JUN', style: style);
//         break;
//       case 8:
//         text = const Text('SEP', style: style);
//         break;
//       default:
//         text = const Text('', style: style);
//         break;
//     }

//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       child: text,
//     );
//   }

//   LineChartData mainData() {
//     return LineChartData(
//       gridData: const FlGridData(
//           // show: true,
//           // drawVerticalLine: true,
//           // horizontalInterval: 1,
//           // verticalInterval: 1,
//           // getDrawingHorizontalLine: (value) {
//           //   return const FlLine(
//           //     strokeWidth: 1,
//           //   );
//           // },
//           // getDrawingVerticalLine: (value) {
//           //   return const FlLine(
//           //     strokeWidth: 1,
//           //   );
//           // },
//           ),
//       titlesData: FlTitlesData(
//         show: true,
//         rightTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 30,
//             interval: 1,
//             getTitlesWidget: bottomTitleWidgets,
//           ),
//         ),
//         leftTitles: const AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: false,
//           ),
//         ),
//       ),
//       borderData: FlBorderData(
//         show: true,
//         border: Border.all(color: const Color(0xff37434d)),
//       ),
//       minX: 0,
//       maxX: 15,
//       minY: 0,
//       maxY: 6,
//       lineBarsData: [
//         LineChartBarData(
//           spots: const [],
//           color: const Color(0xff717171),
//           isCurved: true,
//           // gradient: LinearGradient(
//           //   // colors: gradientColors,
//           // ),
//           // barWidth: 5,
//           isStrokeCapRound: true,
//           dotData: const FlDotData(
//             show: false,
//           ),
//           belowBarData: BarAreaData(
//             show: true,
//             // gradient: LinearGradient(
//             //   colors: gradientColors
//             //       .map((color) => color.withOpacity(0.3))
//             //       .toList(),
//             // ),
//           ),
//         ),
//       ],
//     );
//   }

//   textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle: TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     ));
//   }
// }
