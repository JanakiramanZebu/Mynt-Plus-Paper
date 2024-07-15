// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../../res/res.dart';

// import '../../../../sharedWidget/custom_text_btn.dart';

// class InverstSimilarFunds extends StatelessWidget {
//   const InverstSimilarFunds({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Similar Basket",
//               style: textStyle(
//                   const Color.fromRGBO(0, 0, 0, 1), 16, FontWeight.w600)),
//           const SizedBox(height: 20),
//           SizedBox(
//             height: 148,
//             child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 shrinkWrap: true,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     width: 300,
//                     // padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                         border: Border.all(color: const Color(0xffCCCCCC)),
//                         borderRadius: BorderRadius.circular(8)),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           decoration: const BoxDecoration(
//                               color: Color(0xffFAFBFF),
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(8),
//                                   topRight: Radius.circular(8))),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 8),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text("Mirae Asset Tax Saver Fund",
//                                   style: textStyle(const Color(0xff000000), 14,
//                                       FontWeight.w600)),
//                               Container(
//                                 decoration: BoxDecoration(
//                                     color: const Color(0xffFFFFFF),
//                                     borderRadius: BorderRadius.circular(4)),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8, vertical: 3),
//                                 child: Text("ELSS",
//                                     style: textStyle(const Color(0xff666666), 9,
//                                         FontWeight.w500)),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text("AUM ",
//                                       style: textStyle(const Color(0xff666666),
//                                           13, FontWeight.w500)),
//                                   Text("₹29,534",
//                                       style: textStyle(const Color(0xff000000),
//                                           13, FontWeight.w600)),
//                                   Text(" Cr",
//                                       style: textStyle(const Color(0xff666666),
//                                           13, FontWeight.w500)),
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   Text("Expense ",
//                                       style: textStyle(const Color(0xff666666),
//                                           13, FontWeight.w500)),
//                                   Text("1.15%",
//                                       style: textStyle(const Color(0xff000000),
//                                           13, FontWeight.w600)),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Divider(color: Color(0xffDDDDDD)),
//                         const SizedBox(height: 6),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text("PE ",
//                                       style: textStyle(const Color(0xff666666),
//                                           13, FontWeight.w500)),
//                                   Text("29.34",
//                                       style: textStyle(const Color(0xff000000),
//                                           13, FontWeight.w600))
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   Text("1yrs ",
//                                       style: textStyle(const Color(0xff666666),
//                                           13, FontWeight.w500)),
//                                   Text("21.15%",
//                                       style: textStyle(const Color(0xff43A833),
//                                           13, FontWeight.w600)),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Divider(color: Color(0xffDDDDDD)),
//                         const SizedBox(height: 6),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text("Sharpe ",
//                                       style: textStyle(const Color(0xff666666),
//                                           13, FontWeight.w500)),
//                                   Text("9.02%",
//                                       style: textStyle(const Color(0xff000000),
//                                           13, FontWeight.w600))
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   Text("3yrs ",
//                                       style: textStyle(const Color(0xff666666),
//                                           13, FontWeight.w500)),
//                                   Text("21.15%",
//                                       style: textStyle(const Color(0xff43A833),
//                                           13, FontWeight.w600)),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                       ],
//                     ),
//                   );
//                 },
//                 separatorBuilder: (context, index) {
//                   return const SizedBox(width: 16);
//                 },
//                 itemCount: 10),
//           ),
//           const SizedBox(height: 10),
//           CustomTextBtn(
//               icon: assets.rightarrow,
//               label: "See other funds",
//               onPress: () {}),
//           const SizedBox(height: 16),
//         ],
//       ),
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
