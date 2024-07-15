// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../screens/stocks/invest/invest_screens.dart/all_collection.dart';
// import '../../../../screens/stocks/invest/invest_screens.dart/feature_screens.dart';
// import '../../../../screens/stocks/invest/invest_screens.dart/more_flitres.dart'; 
// import '../../../../screens/stocks/invest/invest_screens.dart/top_collection.dart';
// import '../../../../screens/stocks/invest/invest_screens.dart/watch_list.dart';

// class InverstSeeMorePage extends StatefulWidget {
//   const InverstSeeMorePage({super.key});

//   @override
//   State<InverstSeeMorePage> createState() => _InverstSeeMorePageState();
// }

// class _InverstSeeMorePageState extends State<InverstSeeMorePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xffFFFFFF),
//         elevation: 0.3,
//         leadingWidth: 30,
//         iconTheme: const IconThemeData(color: Color(0xff666666)),
//         title: Text(
//           'All Collections',
//           style: textStyle(const Color(0xff000000), 14, FontWeight.w600),
//         ),
//         actions: [
//           Row(
//             children: [
//               // SvgPicture.asset('assets/icon/appbarIcon/filter_lines.svg'),
//               const SizedBox(
//                 width: 12,
//               ),
//               IconButton(
//                   onPressed: () {
//                     // setState(() {
//                     //   if (cusIcon.icon == Icons.search) {
//                     //     cusIcon = const Icon(
//                     //       Icons.cancel_outlined,
//                     //       color: Color(0xff666666),
//                     //     );
//                     //     cusSearchBar = SizedBox(
//                     //       height: 40,
//                     //       width: screenWidth,
//                     //       child: TextField(
//                     //         decoration: InputDecoration(
//                     //             fillColor: const Color(0xffF1F3F8),
//                     //             filled: true,
//                     //             labelStyle: GoogleFonts.inter(
//                     //                 textStyle: textStyle(
//                     //                     const Color(0xff000000),
//                     //                     16,
//                     //                     FontWeight.w600)),
//                     //             hintStyle: GoogleFonts.inter(
//                     //                 textStyle: textStyle(
//                     //                     const Color(0xff69758F),
//                     //                     15,
//                     //                     FontWeight.w500)),
//                     //             prefixIconColor: const Color(0xff586279),
//                     //             prefixIcon: SvgPicture.asset(
//                     //               "assets/img/appbarImg/search.svg",
//                     //               color: const Color(0xff586279),
//                     //               fit: BoxFit.scaleDown,
//                     //               width: 14,
//                     //               height: 14,
//                     //             ),
//                     //             enabledBorder: OutlineInputBorder(
//                     //                 borderSide: BorderSide.none,
//                     //                 borderRadius:
//                     //                     BorderRadius.circular(30)),
//                     //             disabledBorder: InputBorder.none,
//                     //             focusedBorder: OutlineInputBorder(
//                     //                 borderSide: BorderSide.none,
//                     //                 borderRadius:
//                     //                     BorderRadius.circular(30)),
//                     //             hintText: "Search ",
//                     //             contentPadding:
//                     //                 const EdgeInsets.only(top: 20),
//                     //             border: OutlineInputBorder(
//                     //                 borderSide: BorderSide.none,
//                     //                 borderRadius:
//                     //                     BorderRadius.circular(30))),
//                     //         onChanged: (value) {
//                     //           orderBook.orderBookSearch(value);
//                     //         },
//                     //       ),
//                     //     );
//                     //   } else {
//                     //     cusIcon = const Icon(
//                     //       Icons.search,
//                     //       color: Color(0xff666666),
//                     //     );
//                     //     cusSearchBar = Text(
//                     //       "Stocks Orderbook",
//                     //       style: GoogleFonts.inter(
//                     //           color: const Color(0xff000000),
//                     //           fontSize: 14,
//                     //           fontWeight: FontWeight.w600),
//                     //     );
//                     //   }
//                     // });
//                   },
//                   icon: SvgPicture.asset(
//                     'assets/icon/appbarIcon/search.svg',
//                   ))
//             ],
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const FeatureCollection(),
//             const WatchList(),
//             Padding(
//               padding: const EdgeInsets.only(left: 18),
//               child: Text('More filters you can try',
//                   style: GoogleFonts.inter(
//                       textStyle: textStyle(
//                           const Color(0xff000000), 18, FontWeight.w600))),
//             ),
//             const MoreFilters(),
//             Padding(
//               padding: const EdgeInsets.only(left: 16, top: 28),
//               child: Text(
//                 'Top Collections',
//                 style: textStyle(const Color(0xff000000), 18, FontWeight.w600),
//               ),
//             ),
//             const TopCollection(),
//             Padding(
//               padding: const EdgeInsets.only(left: 16, top: 10),
//               child: Text(
//                 'All Collections',
//                 style: textStyle(const Color(0xff000000), 18, FontWeight.w600),
//               ),
//             ),
//             const AllCollection(),
//             // const StockNews(),
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
