// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../res/res.dart';
// import '../../../routes/route_names.dart';

// import '../../sharedWidget/custom_text_btn.dart';
// import '../../sharedWidget/scrollable_btn.dart';

// class PortfolioScreen extends StatefulWidget {
//   const PortfolioScreen({super.key});

//   @override
//   State<PortfolioScreen> createState() => _PortfolioScreenState();
// }

// class _PortfolioScreenState extends State<PortfolioScreen> {
//   int selectedBtn = 0;
//   List<String> portfolioList = ["Growth factor", "Wealth managers"];
//   List<bool> isActiveBtn = [true, false];
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       color: const Color(0xffF1F3F8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Pick portfolio’s like your superstars. Follow them below.",
//             style: GoogleFonts.inter(
//                 textStyle:
//                     textStyle(const Color(0xff181B19), 18, FontWeight.w600)),
//           ),
//           const SizedBox(height: 18),
//           ScrollableBtn(btnActive: isActiveBtn, btnName: portfolioList),
//           const SizedBox(height: 18),
//           ListView.separated(
//               reverse: selectedBtn == 0 ? true : false,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemBuilder: (context, index) {
//                 return Card(
//                   elevation: 0,
//                   child: ListTile(
//                     title: Text(
//                       index.isEven ? "Prem kumar" : "Aravind kumar",
//                       style: GoogleFonts.inter(
//                           textStyle: textStyle(
//                               const Color(0xff171717), 15, FontWeight.w600)),
//                     ),
//                     leading: CircleAvatar(
//                         backgroundColor: index.isEven
//                             ? Colors.blue.shade50
//                             : Colors.red.shade50,
//                         child: Text(
//                           index.isEven ? "Pk" : "Ak",
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff000000), 18,
//                                   FontWeight.w700)),
//                         )),
//                     subtitle: Row(
//                       children: [
//                         Text(
//                           "Min. Invest :",
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff707070), 14,
//                                   FontWeight.w500)),
//                         ),
//                         Text(
//                           "₹12,344",
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff171717), 15,
//                                   FontWeight.w600)),
//                         ),
//                       ],
//                     ),
//                     trailing: SvgPicture.asset(
//                       "assets/icon/circle_bookmark_group.svg",
//                     ),
//                   ),
//                 );
//               },
//               separatorBuilder: (context, index) {
//                 return const SizedBox(height: 8);
//               },
//               itemCount: 3),
//           Container(
//               margin: const EdgeInsets.only(right: 16, left: 3, top: 18),
//               width: MediaQuery.of(context).size.width,
//               child: CustomTextBtn(
//                 label: 'See more portfolios',
//                 onPress: () {
//                   Navigator.pushNamed(context, Routes.superstarportfolio);
//                 },
//                 icon: assets.rightarrow,
//               ))
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
