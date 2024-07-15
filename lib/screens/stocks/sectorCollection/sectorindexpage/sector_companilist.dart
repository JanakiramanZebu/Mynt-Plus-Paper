// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
// import '../../../../provider/stocks_provider.dart';
// import '../../../../res/res.dart'; 
// class SectorCompanyList extends StatefulWidget {
//   const SectorCompanyList({super.key});

//   @override
//   State<SectorCompanyList> createState() => _SectorCompanyListState();
// }

// class _SectorCompanyListState extends State<SectorCompanyList> {
//   int selectedBtn = 0;
//   bool isfalse = true;
//   List<bool> isActiveBtn = [true, false, false, false];
//   String imagePath1 = "assets/icon/watchlistIcon/line-chart.svg";
//   String imagePath2 = "assets/img/onclickimage/linechartonclick.svg";
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(builder: (context, ScopedReader watch, _) {
//       final actionTrade = watch(stocksProvide);
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ExpandedTileList.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             itemCount: actionTrade.actionTrademodel!.length,
//             maxOpened: 1,
//             shrinkWrap: true,
//             reverse: selectedBtn == 0 ? true : false,
//             itemBuilder: (context, index, controller) {
//               return ExpandedTile(
//                 disableAnimation: true,
//                 contentseparator: 0,
//                 trailingRotation: 90,
//                 theme: const ExpandedTileThemeData(
//                     headerColor: Colors.white,
//                     headerPadding:
//                         EdgeInsets.symmetric(vertical: 8, horizontal: 0),
//                     //   headerSplashColor: Colors.red,
//                     contentBackgroundColor: Color(0xffF1F3F8),
//                     contentPadding: EdgeInsets.all(12.0),
//                     //   contentRadius: 12.0,
//                     trailingPadding: EdgeInsets.all(0)),
//                 controller: controller,
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("${actionTrade.actionTrademodel![index].tsym}",
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff000000),
//                                     15, FontWeight.w600))),
//                         const SizedBox(height: 8),
//                         Text(
//                             "Vol. :₹${actionTrade.actionTrademodel![index].volume}k",
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff999999),
//                                     14, FontWeight.w500))),
//                       ],
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text("₹${actionTrade.actionTrademodel![index].ltp}",
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff000000),
//                                     14, FontWeight.w600))),
//                         const SizedBox(height: 8),
//                         Text(
//                             "${actionTrade.actionTrademodel![index].perChange}%",
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(
//                                     actionTrade
//                                             .actionTrademodel![index].perChange!
//                                             .startsWith("-")
//                                         ? const Color(0xffE00000)
//                                         : const Color(0xff43A833),
//                                     14,
//                                     FontWeight.w600))),
//                       ],
//                     ),
//                   ],
//                 ),
//                 content: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         InkWell(
//                           onTap: () {},
//                           child: Container(
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffFFFFFF),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(4))),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(assets.charticon),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         InkWell(
//                           onTap: () {},
//                           child: Container(
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffFFFFFF),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(4))),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(assets.flagicon),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         InkWell(
//                           onTap: () {},
//                           child: Container(
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffFFFFFF),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(4))),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(assets.calendaricon),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         InkWell(
//                           onTap: () {},
//                           child: Container(
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffFFFFFF),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(4))),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(assets.menuicon),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         SizedBox(
//                           height: 30,
//                           child: ElevatedButton(
//                             onPressed: () {},
//                             style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(6)),
//                                 backgroundColor: const Color(0xff43A833)),
//                             child: Text("BUY",
//                                 style: GoogleFonts.inter(
//                                     textStyle: textStyle(
//                                         const Color(0xffFFFFFF),
//                                         12,
//                                         FontWeight.w600))),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         SizedBox(
//                           height: 30,
//                           child: ElevatedButton(
//                             onPressed: () {},
//                             style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(6)),
//                                 backgroundColor: const Color(0xffFF1717)),
//                             child: Text("SELL",
//                                 style: GoogleFonts.inter(
//                                     textStyle: textStyle(
//                                         const Color(0xffFFFFFF),
//                                         12,
//                                         FontWeight.w600))),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 onTap: () {
//                   debugPrint("tapped!!");
//                 },
//                 onLongTap: () {
//                   debugPrint("looooooooooong tapped!!");
//                 },
//               );
//             },
//             separatorBuilder: (BuildContext context, int index) {
//               return const Divider(
//                 color: Color(0xffDDDDDD),
//               );
//             },
//           ),
//           const Divider(
//             color: Color(0xffDDDDDD),
//           ),
//           Container(
//               margin: const EdgeInsets.symmetric(vertical: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CustomTextBtn(
//                     label: 'See all 22 ETFs',
//                     onPress: () {},
//                     icon: assets.downArrow,
//                   ),
//                 ],
//               ))
//         ],
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
