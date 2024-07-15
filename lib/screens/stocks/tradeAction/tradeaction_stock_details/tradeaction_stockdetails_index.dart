// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import '../../../../res/res.dart';

// class TradeActionStockDetails extends StatefulWidget {
//   const TradeActionStockDetails({super.key});

//   @override
//   State<TradeActionStockDetails> createState() => _TradeActionStockDetailsState();
// }

// class _TradeActionStockDetailsState extends State<TradeActionStockDetails> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leadingWidth: 30,
//        iconTheme: const IconThemeData(color: Color(0xff000000)),
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
//                     child: SvgPicture.asset('assets/img/automobile.svg')),
//                 title: Text(
//                   '${widget.sectorindexdata.futurename}'.toUpperCase(),
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
//                                   '${widget.sectorindexdata.percentage}'
//                                               .toString()
//                                               .startsWith("-") ||
//                                           '${widget.sectorindexdata.oipercentage}'
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
      
//     );
//   }
// }