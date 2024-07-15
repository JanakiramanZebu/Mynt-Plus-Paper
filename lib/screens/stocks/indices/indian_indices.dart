// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../model/indices/all_indices_model.dart';

// import '../../../provider/stocks_provider.dart';
// // import 'bse_screen.dart';
// // import 'mcx_screen.dart';
// // import 'nse_screen.dart';

// class IndianIndices extends StatefulWidget {
//   final AllIndicesModel? indianIndices;
//   const IndianIndices({super.key, this.indianIndices});

//   @override
//   State<IndianIndices> createState() => _IndianIndicesState();
// }

// class _IndianIndicesState extends State<IndianIndices>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<Tab> indicesList = const [
//     Tab(text: "NSE"),
//     Tab(text: "BSE"),
//     Tab(text: "MCX")
//   ];
//   @override
//   void initState() {
//     _tabController = TabController(length: indicesList.length, vsync: this);

//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _tabController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(builder: (context, ScopedReader watch, _) {
//       _tabController.addListener(() {
//         setState(() {
//           WidgetsBinding.instance.addPostFrameCallback((_) async {
//             if (_tabController.index == 0) {
//               await context.read(stocksProvide).getAllIndices(
//                   context: context, exchane: 'NSE', isSubscribe: true);
//               await context.read(stocksProvide).getAllIndices(
//                   context: context, exchane: 'MCX', isSubscribe: false);
//               await context.read(stocksProvide).getAllIndices(
//                   context: context, exchane: 'BSE', isSubscribe: false);
//             } else if (_tabController.index == 1) {
//               await context.read(stocksProvide).getAllIndices(
//                   context: context, exchane: 'BSE', isSubscribe: true);
//               await context.read(stocksProvide).getAllIndices(
//                   context: context, exchane: 'NSE', isSubscribe: false);
//               await context.read(stocksProvide).getAllIndices(
//                   context: context, exchane: 'MCX', isSubscribe: false);
//             } else {
//               await context.read(stocksProvide).getAllIndices(
//                   context: context, exchane: 'MCX', isSubscribe: true);
//               await context.read(stocksProvide).getAllIndices(
//                   context: context, exchane: 'BSE', isSubscribe: false);
//               await context.read(stocksProvide).getAllIndices(
//                   context: context, exchane: 'NSE', isSubscribe: false);
//             }
//           });
//         });
//       });

//       return Scaffold(
//         body: Column(
//           children: [
//             Container(
//               height: 45,
//               decoration: const BoxDecoration(
//                   border: Border(bottom: BorderSide(color: Color(0xffD7DCE4)))),
//               child: TabBar(
//                   indicatorColor: const Color(0xff000000),
//                   indicatorSize: TabBarIndicatorSize.label,
//                   unselectedLabelColor: const Color(0XFF666666),
//                   unselectedLabelStyle:
//                       textStyle(const Color(0XFF666666), 13, FontWeight.w500),
//                   labelColor: const Color(0xff000000),
//                   labelStyle:
//                       textStyle(const Color(0xff000000), 13.5, FontWeight.w600),
//                   controller: _tabController,
//                   tabs: indicesList),
//             ),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: SizedBox(
//                       height: 40,
//                       child: TextField(
//                         decoration: InputDecoration(
//                             fillColor: const Color(0xffF1F3F8),
//                             filled: true,
//                             labelStyle: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff000000),
//                                     16, FontWeight.w600)),
//                             hintStyle: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff69758F),
//                                     15, FontWeight.w500)),
//                             prefixIconColor: const Color(0xff586279),
//                             prefixIcon: SvgPicture.asset(
//                               "assets/icon/appbarIcon/search.svg",
//                               color: const Color(0xff586279),
//                               fit: BoxFit.scaleDown,
//                               width: 14,
//                               height: 14,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide.none,
//                                 borderRadius: BorderRadius.circular(30)),
//                             disabledBorder: InputBorder.none,
//                             focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide.none,
//                                 borderRadius: BorderRadius.circular(30)),
//                             hintText: "Search Indian Indices",
//                             contentPadding: const EdgeInsets.only(top: 20),
//                             border: OutlineInputBorder(
//                                 borderSide: BorderSide.none,
//                                 borderRadius: BorderRadius.circular(30))),
//                         onChanged: (value) {},
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     height: 40,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//                     decoration: BoxDecoration(
//                         color: const Color(0xffF1F3F8),
//                         borderRadius: BorderRadius.circular(24)),
//                     child: Row(
//                       children: [
//                         Text("Sort by",
//                             style: GoogleFonts.inter(
//                                 textStyle: textStyle(const Color(0xff666666),
//                                     13, FontWeight.w500))),
//                         SvgPicture.asset(
//                           "assets/icon/vector.svg",
//                           width: 38,
//                           height: 40,
//                           fit: BoxFit.scaleDown,
//                         )
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   NseScreen(nseData: widget.indianIndices!.nSE),
//                   BseScreen(bseData: widget.indianIndices!.bSE),
//                   McxScreen(mcxData: widget.indianIndices!.mCX)
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     });
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
