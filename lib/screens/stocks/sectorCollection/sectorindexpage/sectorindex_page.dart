// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/sectorCollection/sectorindexpage/sector_automobile_companies.dart';
// import '../../../../screens/stocks/sectorCollection/sectorindexpage/sectorchartpage.dart';
// import '../../../../screens/stocks/sectorCollection/sectorindexpage/sectorfundamental_info.dart';
// import '../../../../screens/stocks/sectorCollection/seemoresector/moresector_data.dart';

// class SectorIndexPage extends StatefulWidget {
//   final Cars sectorindexdata;
//   const SectorIndexPage({
//     super.key,
//     required this.sectorindexdata,
//   });

//   @override
//   State<SectorIndexPage> createState() => _SectorIndexPageState();
// }

// class _SectorIndexPageState extends State<SectorIndexPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leadingWidth: 30,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 7),
//           child: InkWell(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: const Icon(
//                 Icons.arrow_back,
//                 color: Color(0xff212121),
//               )),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Container(
//                       width: 25,
//                       height: 25,
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(100),
//                           border: Border.all(
//                             width: 1,
//                             color: Colors.grey,
//                           )),
//                       child: SvgPicture.asset(
//                         assets.appbarbell,
//                         fit: BoxFit.none,
//                       )),
//                   const SizedBox(
//                     width: 6,
//                   ),
//                   Container(
//                       width: 25,
//                       height: 25,
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(100),
//                           border: Border.all(width: 1, color: Colors.grey)),
//                       child: SvgPicture.asset(
//                         assets.appbarbookmark,
//                         fit: BoxFit.none,
//                       )),
//                   const Icon(
//                     Icons.more_vert_outlined,
//                     color: Colors.black,
//                     size: 25,
//                   )
//                 ]),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(65),
//           child: Container(
//               height: 74,
//               decoration: BoxDecoration(
//                   color: const Color(0xffFAFBFF),
//                   border: Border.all(
//                     color: const Color(0xffEEF0F2),
//                   )),
//               child: ListTile(
//                 minLeadingWidth: 20,
//                 leading: Padding(
//                     padding: const EdgeInsets.only(top: 5),
//                     child: SvgPicture.asset('assets/icon/Frame (1).svg')),
//                 title: Text(
//                   widget.sectorindexdata.futurename.toUpperCase(),
//                   style: GoogleFonts.inter(
//                       color: const Color(0xff000000),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Row(
//                     children: [
//                       Text(widget.sectorindexdata.lp,
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff666666), 16,
//                                   FontWeight.w500))),
//                       const SizedBox(
//                         width: 6,
//                       ),
//                       Text(
//                           '${widget.sectorindexdata.percentage} (${widget.sectorindexdata.oipercentage}%)',
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(
//                                   widget.sectorindexdata.percentage
//                                               .toString()
//                                               .startsWith("-") ||
//                                           widget.sectorindexdata.oipercentage
//                                               .toString()
//                                               .startsWith("-")
//                                       ? const Color(0xffE00000)
//                                       : const Color(0xff43A833),
//                                   16,
//                                   FontWeight.w500)))
//                     ],
//                   ),
//                 ),
//               )),
//         ),
//       ),
//       body: const SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SectorPriceChart(),
//             SectorFundamentalInfo(),
//             SectorAutomobileCompanies(),
//           ],
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
