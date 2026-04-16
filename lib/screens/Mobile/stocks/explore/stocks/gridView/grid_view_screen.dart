// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class GridViewScreen extends StatelessWidget {
//   const GridViewScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       crossAxisCount: 2,
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       crossAxisSpacing: 18,
//         mainAxisSpacing: 3,
//        childAspectRatio: 1.1,
//       children: List.generate(2, (index) {
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12 ,vertical: 6),
//           decoration: BoxDecoration(
//               border: Border.all(color: const Color(0xffDDDDDD)),
//               borderRadius: BorderRadius.circular(4)),
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(
//               index == 0 ? "POPULAR" : "DISCOVER",
//               style: GoogleFonts.inter(
//                   textStyle:
//                       textStyle(const Color(0xff0037B7), 11, FontWeight.w600)),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               index == 0
//                   ? "Stocks above daily moving average"
//                   : "High-Dividend stocks for april 2023",
//               style: GoogleFonts.inter(
//                   textStyle:
//                       textStyle(const Color(0xff000000), 14, FontWeight.w600)),
//             ),
//             const SizedBox(height: 12),
//             Image.asset(
//               index == 1
//                   ? "assets/img/discover_icon.png"
//                   : "assets/img/popular_icon.png",
//               fit: BoxFit.cover,
//               height: 81,
//             )
//           ]),
//         );
//       }),
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
