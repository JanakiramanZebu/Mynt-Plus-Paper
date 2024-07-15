// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../res/res.dart';
// import '../../../sharedWidget/custom_text_btn.dart';

// class FeatureCollection extends StatelessWidget {
//   const FeatureCollection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     List<Tradinganddemataccount> dematedata = [
//       Tradinganddemataccount(
//         topic: 'High Risk',
//         info: 'Ideal for investors with a high risk appetite',
//         basket: '12 baskets',
//         recommmended: '2 recommended',
//         img: 'assets/icon/direction_up.svg',
//       ),
//       Tradinganddemataccount(
//         topic: 'Balanced Wealth',
//         info: 'Stable income and growth',
//         basket: '16 baskets',
//         recommmended: '2 recommended',
//         img: 'assets/icon/balance_scale.svg',
//       ),
//       Tradinganddemataccount(
//         topic: 'Top 100 Infinity',
//         info: 'Hybrid of active and passive',
//         basket: '8 baskets',
//         recommmended: '2 recommended',
//         img: 'assets/icon/Jewelry.svg',
//       ),
//       Tradinganddemataccount(
//         topic: 'Hidden Gems',
//         info: 'Diversify your portfolio globally',
//         basket: '6 baskets',
//         recommmended: '2 recommended',
//         img: 'assets/icon/repeat 1 (1).svg',
//       ),
//     ];

//     return Container(
//       width: MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.only(left: 16, right: 16, top: 22, bottom: 16),
//       color: const Color(0xffF1F3F8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Featured Collection",
//                 style: GoogleFonts.inter(
//                     textStyle: textStyle(
//                         const Color(0xff181B19), 18, FontWeight.w600)),
//               ),
//               CustomTextBtn(
//                 label: 'View all',
//                 icon: assets.rightArrowIcon,
//                 onPress: () {
//                   // Navigator.pushNamed(context, Routes.fundAmc);
//                 },
//               )
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Collections of stocks (baskets) curated \nby experts",
//             style: GoogleFonts.inter(
//                 textStyle:
//                     textStyle(const Color(0xff666666), 14, FontWeight.w500)),
//           ),
//           const SizedBox(height: 22),
//           GridView.count(
//             crossAxisCount: 2,
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             crossAxisSpacing: 13,
//             mainAxisSpacing: 11,
//             childAspectRatio: .9,
//             children: List.generate(dematedata.length, (index) {
//               return InkWell(
//                 onTap: () {
//                   // Navigator.pushNamed(context, Routes.fundList);
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.only(right: 16, left: 16, top: 18),
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         dematedata[index].img == 'assets/icon/direction_up.svg'
//                             ? Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 5, vertical: 5),
//                                 decoration: BoxDecoration(
//                                     color: const Color(0xffDC2626),
//                                     borderRadius: BorderRadius.circular(70)),
//                                 child: SvgPicture.asset(dematedata[index].img))
//                             : SvgPicture.asset(dematedata[index].img),
//                         const SizedBox(height: 14),
//                         Text(
//                           dematedata[index].topic,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff000000), 16,
//                                   FontWeight.w600)),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           dematedata[index].info,
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff666666), 12,
//                                   FontWeight.w500)),
//                         ),
//                         const SizedBox(height: 14),
//                         Text(
//                           dematedata[index].basket,
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff000000), 14,
//                                   FontWeight.w600)),
//                         ),
//                         const SizedBox(
//                           height: 4,
//                         ),
//                         Text(
//                           dematedata[index].recommmended,
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff43A833), 12,
//                                   FontWeight.w600)),
//                         ),
//                       ]),
//                 ),
//               );
//             }),
//           )
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

// class Tradinganddemataccount {
//   String topic;
//   String info;
//   String basket;
//   String recommmended;
//   String img;

//   Tradinganddemataccount(
//       {required this.topic,
//       required this.info,
//       required this.basket,
//       required this.recommmended,
//       required this.img});
// }
