// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:readmore/readmore.dart';
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/sectorCollection/seemoresector/moresector_data.dart';

// class SeeAllSector extends StatefulWidget {
//   const SeeAllSector({super.key});

//   @override
//   State<SeeAllSector> createState() => _SeeAllSectorState();
// }

// class _SeeAllSectorState extends State<SeeAllSector> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       appBar: AppBar(
//         elevation: .4,
//         backgroundColor: const Color(0xffFFFFFF),
//         leadingWidth: 35,
//         iconTheme: const IconThemeData(color: Color(0xff000000)),
//         title: Text(
//           'All Sectors',
//           style: GoogleFonts.inter(
//               textStyle:
//                   textStyle(const Color(0xff000000), 14, FontWeight.w600)),
//         ),
//         actions: [
//           Row(
//             children: [
//               // ignore: deprecated_member_use
//               SvgPicture.asset(
//                 assets.searchIcon,
//                 color: const Color(0xff000000),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               const Icon(Icons.more_vert_outlined),
//               const SizedBox(
//                 width: 6,
//               ),
//             ],
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(
//               'All Indian Sectors',
//               style: GoogleFonts.inter(
//                   textStyle:
//                       textStyle(const Color(0xff000000), 16, FontWeight.w600)),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             ReadMoreText(
//               "With an AUM of Rs 465,145 crores, HDFC Mutual Funds offers 80 schemes across different categories including 26 equity, 26 debt, and 7 hybrid mutual funds. Know the HDFC MF scheme details, historical returns, compare and invest in Best HDFC Mutual Funds. Invest in mutual fund schemes that suit your investment objectives, risk level, and fund options.",
//               style: GoogleFonts.inter(
//                   letterSpacing: -0.07,
//                   height: 1.7,
//                   textStyle:
//                       textStyle(const Color(0xff666666), 14, FontWeight.w600)),
//               trimLines: 3,
//               colorClickableText: const Color(0xff0037B7),
//               trimMode: TrimMode.Line,
//               trimCollapsedText: 'Read more',
//               trimExpandedText: ' Read less',
//             ),
//             const SizedBox(
//               height: 24,
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: SizedBox(
//                     height: 40,
//                     child: TextField(
//                       decoration: InputDecoration(
//                           fillColor: const Color(0xffF1F3F8),
//                           filled: true,
//                           labelStyle: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff000000), 16,
//                                   FontWeight.w600)),
//                           hintStyle: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff000000), 13,
//                                   FontWeight.w500)),
//                           prefixIconColor: const Color(0xff586279),
//                           prefixIcon: SvgPicture.asset(
//                             assets.searchIcon,
//                             color: const Color(0xff586279),
//                             fit: BoxFit.scaleDown,
//                             width: 14,
//                             height: 14,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                               borderRadius: BorderRadius.circular(30)),
//                           disabledBorder: InputBorder.none,
//                           focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                               borderRadius: BorderRadius.circular(30)),
//                           hintText: "Search Indian Indices",
//                           contentPadding: const EdgeInsets.only(top: 20),
//                           border: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                               borderRadius: BorderRadius.circular(30))),
//                       onChanged: (value) {},
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Container(
//                   height: 40,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//                   decoration: BoxDecoration(
//                       color: const Color(0xffF1F3F8),
//                       borderRadius: BorderRadius.circular(24)),
//                   child: Row(
//                     children: [
//                       Text("Sort by",
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff666666), 13,
//                                   FontWeight.w500))),
//                       const SizedBox(
//                         width: 8,
//                       ),
//                       SvgPicture.asset(
//                         "assets/icon/vector.svg",
//                         color: const Color(0xff000000),
//                         width: 38,
//                         height: 40,
//                         fit: BoxFit.scaleDown,
//                       )
//                     ],
//                   ),
//                 )
//               ],
//             ),
//             const MoreSectorData(),
//           ]),
//         ),
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
