// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import '../../../../models/indices/top_indices_model.dart';
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/indices/topindiciesindex/optionstabarviewpage/nifity50companies.dart';
// import '../../../../screens/stocks/indices/topindiciesindex/topindicies_chart.dart';
// import '../../../../screens/stocks/indices/topindiciesindex/topindicies_efts_tracking.dart';
// import '../../../../screens/stocks/indices/topindiciesindex/topindicies_nifityf&o.dart';

// class TopIndiciesIndex extends StatefulWidget {
//   final TopIndicesModel topindiciesindex;
//   const TopIndiciesIndex({
//     super.key,
//     required this.topindiciesindex,
//   });

//   @override
//   State<TopIndiciesIndex> createState() => _TopIndiciesIndexState();
// }

// class _TopIndiciesIndexState extends State<TopIndiciesIndex> {
//   double low = 0.00;
//   double high = 0.00;
//   double price = 0.00;
//   int indicesLength = 0;
//   bool hideMore = false;
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
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
//                       backgroundColor: const Color(0xffFF1717),
//                       side: const BorderSide(
//                           width: 1.5, color: Color(0xffFF1717)),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30)),
//                     ),
//                     onPressed: () {
//                       // OrderScreenArgs orderArgs = OrderScreenArgs(
//                       //     exchange: '${widget.topindiciesindex.exchange}',
//                       //     tSym: '${widget.topindiciesindex.idxname}',
//                       //     token: '',
//                       //     type: true);
//                       // showModalBottomSheet(
//                       //     showDragHandle: true,
//                       //     isScrollControlled: true,
//                       //     useSafeArea: true,
//                       //     shape: const RoundedRectangleBorder(
//                       //         borderRadius: BorderRadius.vertical(
//                       //             top: Radius.circular(16))),
//                       //     backgroundColor: const Color(0xffffffff),
//                       //     context: context,
//                       //     builder: (context) =>
//                       //         OrderBottomScreen(orderScreenArgs: orderArgs));
//                     },
//                     child: Text(
//                       "Sell",
//                       style: GoogleFonts.inter(
//                           fontSize: 14,
//                           color: const Color(0xffFFFFFF),
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
//                     onPressed: () {
//                       // OrderScreenArgs orderArgs = OrderScreenArgs(
//                       //     exchange: '${widget.topindiciesindex.exchange}',
//                       //     tSym: '${widget.topindiciesindex.idxname}',
//                       //     token: '',
//                       //     type: true);
//                       // showModalBottomSheet(
//                       //     showDragHandle: true,
//                       //     isScrollControlled: true,
//                       //     useSafeArea: true,
//                       //     shape: const RoundedRectangleBorder(
//                       //         borderRadius: BorderRadius.vertical(
//                       //             top: Radius.circular(16))),
//                       //     backgroundColor: const Color(0xffffffff),
//                       //     context: context,
//                       //     builder: (context) =>
//                       //         OrderBottomScreen(orderScreenArgs: orderArgs));
//                     },
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
//                     width: 8,
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
//                     padding: const EdgeInsets.only(top: 4.5),
//                     child: Image.asset(assets.nselogo)),
//                 title: Text(
//                   '${widget.topindiciesindex.idxname}'.toUpperCase(),
//                   style: GoogleFonts.inter(
//                       color: const Color(0xff000000),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Row(
//                     children: [
//                       Text('₹${widget.topindiciesindex.lp}',
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff666666), 16,
//                                   FontWeight.w500))),
//                       const SizedBox(
//                         width: 6,
//                       ),
//                       Text(
//                           '${widget.topindiciesindex.perChange} (${widget.topindiciesindex.change}%)',
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(
//                                   '${widget.topindiciesindex.change}'
//                                               .toString()
//                                               .startsWith("-") ||
//                                           '${widget.topindiciesindex.perChange}'
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
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const PriceChart(),
//             const Divider(
//               color: Color(0xffF2F2F2),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: 100,
//                         height: 50,
//                         decoration: const BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               //                   <--- left side
//                               color: Color(0xffddddddddd),
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'PE RATIO',
//                               style: GoogleFonts.inter(
//                                   fontSize: 12,
//                                   color: const Color(0xfff666666),
//                                   fontWeight: FontWeight.w500),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               '22.86',
//                               style: GoogleFonts.inter(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 15),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         width: 100,
//                         height: 50,
//                         decoration: const BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               //                   <--- left side
//                               color: Color(0xffddddddddd),
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'PB RATIO',
//                               style: GoogleFonts.inter(
//                                   fontSize: 12,
//                                   color: const Color(0xfff666666),
//                                   fontWeight: FontWeight.w500),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               '22.86',
//                               style: GoogleFonts.inter(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 15),
//                             )
//                           ],
//                         ),
//                       ),
//                       Container(
//                         width: 100,
//                         height: 50,
//                         decoration: const BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               color: Color(0xffddddddddd),
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'TRADED VALUE',
//                               style: GoogleFonts.inter(
//                                   fontSize: 12,
//                                   color: const Color(0xfff666666),
//                                   fontWeight: FontWeight.w500),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               '2,21,060',
//                               style: GoogleFonts.inter(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 15),
//                             )
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 24,
//                   ),
//                   Text(
//                     'HIGH-LOW',
//                     style: GoogleFonts.inter(
//                         fontSize: 12,
//                         color: const Color(0xff666666),
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 0.96),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '₹${widget.topindiciesindex.high}',
//                         style: GoogleFonts.inter(
//                           fontSize: 15,
//                           color: const Color(0xff000000),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(
//                         width: 170,
//                         child: SliderTheme(
//                           data: SliderThemeData(
//                             disabledSecondaryActiveTrackColor:
//                                 const Color(0xff000000),
//                             trackHeight: 2,
//                             thumbShape: const RoundSliderThumbShape(
//                                 enabledThumbRadius: 6.0),
//                             overlayShape: const RoundSliderOverlayShape(
//                                 overlayRadius: 10.0),
//                             inactiveTrackColor: const Color(0xffD9D9D9),
//                             valueIndicatorTextStyle: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xffffffff),
//                                     14, FontWeight.w500)),
//                           ),
//                           child: Slider(
//                             min: widget.topindiciesindex.low == "0.00"
//                                 ? double.parse(
//                                         "${widget.topindiciesindex.lp}") -
//                                     10
//                                 : double.parse(
//                                     "${widget.topindiciesindex.low}"),
//                             max: widget.topindiciesindex.high == "0.00"
//                                 ? double.parse(
//                                         "${widget.topindiciesindex.lp}") +
//                                     20
//                                 : double.parse(
//                                     "${widget.topindiciesindex.high}"),
//                             value:
//                                 double.parse("${widget.topindiciesindex.lp}"),
//                             label: "₹${widget.topindiciesindex.lp}",
//                             activeColor: const Color(0xffD9D9D9),
//                             thumbColor: const Color(0xff000000),
//                             // divisions: 10,
//                             onChanged: (value) {},
//                           ),
//                         ),
//                       ),
//                       Text(
//                         '₹${widget.topindiciesindex.low}',
//                         style: GoogleFonts.inter(
//                           fontSize: 15,
//                           color: const Color(0xff000000),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   const Divider(
//                     color: Color(0xffDDDDDD),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     '52 Weeks High - 52 Weeks Low'.toUpperCase(),
//                     style: GoogleFonts.inter(
//                         fontSize: 12,
//                         color: const Color(0xff666666),
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 0.96),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '₹1,438.80',
//                         style: GoogleFonts.inter(
//                           fontSize: 15,
//                           color: const Color(0xff000000),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(
//                         width: 170,
//                         child: SliderTheme(
//                           data: SliderThemeData(
//                             disabledSecondaryActiveTrackColor:
//                                 const Color(0xff000000),
//                             trackHeight: 2,
//                             thumbShape: const RoundSliderThumbShape(
//                                 enabledThumbRadius: 6.0),
//                             overlayShape: const RoundSliderOverlayShape(
//                                 overlayRadius: 10.0),
//                             inactiveTrackColor: const Color(0xffD9D9D9),
//                             valueIndicatorTextStyle: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xffffffff),
//                                     14, FontWeight.w500)),
//                           ),
//                           child: Slider(
//                             min: widget.topindiciesindex.low == "0.00"
//                                 ? double.parse(
//                                         "${widget.topindiciesindex.lp}") -
//                                     10
//                                 : double.parse(
//                                     "${widget.topindiciesindex.low}"),
//                             max: widget.topindiciesindex.high == "0.00"
//                                 ? double.parse(
//                                         "${widget.topindiciesindex.lp}") +
//                                     20
//                                 : double.parse(
//                                     "${widget.topindiciesindex.high}"),
//                             value:
//                                 double.parse("${widget.topindiciesindex.lp}"),
//                             label: "₹${widget.topindiciesindex.lp}",
//                             activeColor: const Color(0xffD9D9D9),
//                             thumbColor: const Color(0xff000000),
//                             // divisions: 10,
//                             onChanged: (value) {},
//                           ),
//                         ),
//                       ),
//                       Text(
//                         '₹1300.34',
//                         style: GoogleFonts.inter(
//                           fontSize: 15,
//                           color: const Color(0xff000000),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   const Divider(
//                     color: Color(0xffDDDDDD),
//                   ),
//                   const SizedBox(
//                     height: 22,
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(6),
//                       color: const Color(0xffF1F3F8),
//                     ),
//                     width: screenWidth,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 25),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           SizedBox(
//                             width: 200,
//                             child: Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(
//                                       'Top NIFTY 50 Options',
//                                       style: GoogleFonts.inter(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600),
//                                     ),
//                                     const SizedBox(
//                                       width: 10,
//                                     ),
//                                     SvgPicture.asset(
//                                       assets.rightarrow,
//                                       // ignore: deprecated_member_use
//                                     )
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Text(
//                                   'It represents the top 50 Largecap companies based on market capitalisation.',
//                                   style: GoogleFonts.inter(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                       color: const Color(0xfff666666)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Image.asset(assets.nifity50image),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const EftTraking(),
//             const NifityFO(),
//             const Nifity50Companies(),
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
