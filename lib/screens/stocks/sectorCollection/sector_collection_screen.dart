// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../res/res.dart';
// import '../../../../routes/route_names.dart';

// import '../../../../provider/stocks_provider.dart';
// import '../../sharedWidget/custom_text_btn.dart';
// import '../../sharedWidget/scrollable_btn.dart';

// class SectorCollectionScreen extends StatefulWidget {
//   const SectorCollectionScreen({super.key});

//   @override
//   State<SectorCollectionScreen> createState() => _SectorCollectionScreenState();
// }

// class _SectorCollectionScreenState extends State<SectorCollectionScreen> {
//   int selectedBtn = 0;
//   List<String> sectorList = ["Turnaround", "High return", "Compounding"];
//   List<bool> isActiveBtn = [true, false, false];
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(builder: (context, ScopedReader watch, _) {
//       final sectorCollection = watch(stocksProvide).sectorCollectionModel;
//       return Container(
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.symmetric(vertical: 22),
//         color: const Color(0xffF1F3F8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Sector Collections",
//                     style: GoogleFonts.inter(
//                         textStyle: textStyle(
//                             const Color(0xff181B19), 18, FontWeight.w600)),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Handpicked global baskets of stocks managed by global institutions and fund managers",
//                     style: GoogleFonts.inter(
//                         textStyle: textStyle(
//                             const Color(0xff666666), 14, FontWeight.w500)),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 18),
//             Padding(
//               padding: const EdgeInsets.only(left: 16.0),
//               child: ScrollableBtn(btnActive: isActiveBtn, btnName: sectorList),
//             ),
//             const SizedBox(height: 18),
//             SizedBox(
//               height: 230,
//               child: ListView.separated(
//                 padding: const EdgeInsets.only(left: 16),
//                 scrollDirection: Axis.horizontal,
//                 itemCount: sectorCollection!.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return Container(
//                     decoration: BoxDecoration(
//                         color: const Color(0xffFFFFFF),
//                         borderRadius: BorderRadius.circular(8)),
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "${sectorCollection[index].sectorName}",
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff000000), 16,
//                                   FontWeight.w600)),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           "₹ ${sectorCollection[index].ltp}",
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff000000), 15,
//                                   FontWeight.w600)),
//                         ),
//                         Text(
//                           "${sectorCollection[index].perChange}%",
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(
//                                   sectorCollection[index]
//                                           .perChange!
//                                           .startsWith('-')
//                                       ? const Color(0xffE00000)
//                                       : const Color(0xff43A833),
//                                   14,
//                                   FontWeight.w500)),
//                         ),
//                         const SizedBox(height: 15),
//                         Row(
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "1M CHANGE",
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff666666),
//                                           12,
//                                           FontWeight.w500)),
//                                 ),
//                                 Text(
//                                   "${sectorCollection[index].mChange}%",
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff000000),
//                                           14,
//                                           FontWeight.w500)),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(width: 62),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "1Y CHANGE",
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff666666),
//                                           12,
//                                           FontWeight.w500)),
//                                 ),
//                                 Text(
//                                   "${sectorCollection[index].yChange}%",
//                                   style: GoogleFonts.inter(
//                                       textStyle: textStyle(
//                                           const Color(0xff000000),
//                                           14,
//                                           FontWeight.w500)),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             Card(
//                                 elevation: 2,
//                                 child: Image.asset(
//                                     "${sectorCollection[index].icon1}")),
//                             const SizedBox(width: 3),
//                             Card(
//                                 elevation: 2,
//                                 child: Image.asset(
//                                     "${sectorCollection[index].icon2}")),
//                             const SizedBox(width: 3),
//                             Card(
//                                 elevation: 2,
//                                 child: Image.asset(
//                                     "${sectorCollection[index].icon3}")),
//                             const SizedBox(width: 3),
//                             Card(
//                                 elevation: 2,
//                                 child: Image.asset(
//                                     "${sectorCollection[index].icon4}")),
//                             const SizedBox(width: 3),
//                             Card(
//                                 elevation: 2,
//                                 child: Image.asset(
//                                     "${sectorCollection[index].icon5}"))
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "+${sectorCollection[index].more} more",
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff666666), 12,
//                                   FontWeight.w500)),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 separatorBuilder: (BuildContext context, int index) {
//                   return const SizedBox(width: 16);
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 18.0, left: 16),
//               child: CustomTextBtn(
//                 label: 'See more sectors',
//                 onPress: () {
//                   Navigator.pushNamed(
//                     context,
//                     Routes.sellAllsector,
//                   );
//                 },
//                 icon: assets.rightarrow,
//               ),
//             )
//           ],
//         ),
//       );
//     });
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     );
//   }
// }
