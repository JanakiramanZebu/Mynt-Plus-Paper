// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import '../../../../models/indices/all_indices_model.dart';
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/indices/topindiciesindex/topindicies_chart.dart';
// import '../../../../screens/stocks/indices/topindiciesindex/topindicies_efts_tracking.dart';
// import '../../../../screens/stocks/indices/topindiciesindex/topindicies_fundamental_info.dart';

// import '../topindiciesindex/topindicies_nifityf&o.dart';

// class McxIndexPage extends StatefulWidget {
//   final MCX mcxindexdata;
//   const McxIndexPage({
//     super.key,
//     required this.mcxindexdata,
//   });

//   @override
//   State<McxIndexPage> createState() => _McxIndexPageState();
// }

// class _McxIndexPageState extends State<McxIndexPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       bottomNavigationBar: Container(
//         height: 65,
//         decoration: const BoxDecoration(
//             border: Border(
//                 top: BorderSide(color: Color(0xffEFF2F5)),
//                 bottom: BorderSide(color: Color(0xffEFF2F5)))),
//         child: BottomAppBar(
//           child: Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               SizedBox(
//                 width: 175,
//                 height: 35,
//                 child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xffFFFFFF),
//                       side: const BorderSide(
//                           width: 1.5, color: Color(0xffFF1717)),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30)),
//                     ),
//                     onPressed: () {},
//                     child: Text(
//                       "Sell",
//                       style: GoogleFonts.inter(
//                           fontSize: 14,
//                           color: const Color(0xffFF1717),
//                           fontWeight: FontWeight.w600),
//                     )),
//               ),
//               SizedBox(
//                 width: 175,
//                 height: 35,
//                 child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       // ignore: deprecated_member_use
//                       backgroundColor: const Color(0xff43A833),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30)),
//                     ),
//                     onPressed: () {},
//                     child: Text(
//                       "Buy",
//                       style: GoogleFonts.inter(
//                           fontSize: 14,
//                           color: const Color(0xffffffffff),
//                           fontWeight: FontWeight.w600),
//                     )),
//               ),
//             ],
//           ),
//         ),
//       ),
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
//                         assets.bookmark,
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
//                     padding: const EdgeInsets.only(top: 3),
//                     child: Image.asset(
//                       assets.mcxlogo,
//                       width: 35,
//                     )),
//                 title: Text(
//                   '${widget.mcxindexdata.idxname}'.toUpperCase(),
//                   style: GoogleFonts.inter(
//                       color: const Color(0xff000000),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Row(
//                     children: [
//                       Text('₹${widget.mcxindexdata.lp}',
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff666666), 16,
//                                   FontWeight.w500))),
//                       const SizedBox(
//                         width: 6,
//                       ),
//                       Text(
//                           '${widget.mcxindexdata.change} (${widget.mcxindexdata.change}%)',
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(
//                                   '${widget.mcxindexdata.change}'
//                                               .toString()
//                                               .startsWith("-") ||
//                                           '${widget.mcxindexdata.change}'
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
//           children: [
//             PriceChart(),
//             Divider(
//               color: Color(0xffF2F2F2),
//             ),
//             TopIndiciesFundamentalInfo(),
//             EftTraking(),
//             NifityFO(),
//           ],
//         ),
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
