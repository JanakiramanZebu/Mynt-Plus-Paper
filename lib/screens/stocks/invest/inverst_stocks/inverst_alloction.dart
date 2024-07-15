// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../chart/donut_chart.dart';

// class InverstAlloction extends StatefulWidget {
//   const InverstAlloction({super.key});

//   @override
//   State<InverstAlloction> createState() => _InverstAlloctionState();
// }

// class _InverstAlloctionState extends State<InverstAlloction> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16.0,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Asset allocation and Holdings",
//               style: textStyle(const Color(0xff000000), 16, FontWeight.w600)),
//           const SizedBox(height: 20),
//           Text("Fund’s overall asset allocation",
//               style: textStyle(const Color(0xff000000), 16, FontWeight.w600)),
//           const SizedBox(height: 6),
//           Text(
//               "Each fund is uniquely allocated to suit and match customer expectations based on the risk profile and return expectations.",
//               style: textStyle(const Color(0xff666666), 14, FontWeight.w500)),
//           const SizedBox(height: 20),
//           const DonutChaetWidget(),
//           const SizedBox(height: 20),
//         ],
//       ),
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
