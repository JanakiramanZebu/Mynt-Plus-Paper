// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/sectorCollection/sectorindexpage/sector_companilist.dart';

// class SectorAutomobileCompanies extends StatefulWidget {
//   const SectorAutomobileCompanies({super.key});

//   @override
//   State<SectorAutomobileCompanies> createState() =>
//       _SectorAutomobileCompaniesState();
// }

// class _SectorAutomobileCompaniesState extends State<SectorAutomobileCompanies> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Automobile companies',
//                 style: GoogleFonts.inter(
//                     fontSize: 18, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     ' Scrips',
//                     style: GoogleFonts.inter(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: const Color(0xff666666)),
//                   ),
//                   Row(
//                     children: [
//                       SvgPicture.asset(assets.filterlines),
//                       const SizedBox(
//                         width: 12,
//                       ),
//                       SvgPicture.asset(assets.searchIcon),
//                     ],
//                   ),
//                   // SizedBox(
//                   //   height: 25,
//                   //   width: 75,
//                   //   child: ElevatedButton(
//                   //     onPressed: () => {},
//                   //     style: ElevatedButton.styleFrom(
//                   //         elevation: 0,
//                   //         backgroundColor: const Color(0x000000 - 1),
//                   //         side: const BorderSide(
//                   //             width: 1, color: Color(0xff0037B7)),
//                   //         shape: RoundedRectangleBorder(
//                   //           borderRadius: BorderRadius.circular(40),
//                   //         )),
//                   //     child: Row(
//                   //       children: [
//                   //         SvgPicture.asset(assets.filterlines),
//                   //         const SizedBox(
//                   //           width: 5,
//                   //         ),
//                   //         Text(
//                   //           "Sort",
//                   //           style: GoogleFonts.inter(
//                   //               fontSize: 12,
//                   //               fontWeight: FontWeight.w600,
//                   //               color: const Color(0xff0037B7)),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const Divider(
//           color: Color(0xffECEDEE),
//         ),
//         const SectorCompanyList(),
//       ],
//     );
//   }
// }
