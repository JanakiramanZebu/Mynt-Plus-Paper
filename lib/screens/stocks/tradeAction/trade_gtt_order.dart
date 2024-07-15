// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/tradeAction/tabbar_gtt.dart';
// import '../../../sharedWidget/custom_switch_btn.dart'; 

// class SetGttOrder extends StatefulWidget {
//   final ActionTradeModel tradedata;
//   const SetGttOrder({super.key, required this.tradedata});

//   @override
//   State<SetGttOrder> createState() => _SetGttOrderState();
// }

// class _SetGttOrderState extends State<SetGttOrder>
//     with TickerProviderStateMixin {
//   bool _enable = true;
//   bool? isBuy;
//   late TabController tabCtrl;

//   List<Tab> tabList = const [
//     Tab(
//       text: 'Regular',
//     ),
//     Tab(
//       text: 'Gtt',
//     )
//   ];
//   @override
//   void initState() {
//     tabCtrl =
//         TabController(length: tabList.length, vsync: this, initialIndex: 0);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       appBar: AppBar(
//         shadowColor: const Color(0xffECEFF3),
//         elevation: .3,
//         backgroundColor: const Color(0xffFFFFFF),
//         leadingWidth: 30,
//         iconTheme: const IconThemeData(color: Color(0xff000000)),
//         title: Text(
//           '${widget.tradedata.tsym}',
//           style: GoogleFonts.inter(
//               color: const Color(0xff000000),
//               fontSize: 14,
//               fontWeight: FontWeight.w600),
//         ),
//         bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(110),
//             child: Column(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   alignment: Alignment.centerLeft,
//                   decoration: const BoxDecoration(
//                       border: Border(
//                           top: BorderSide(
//                             color: Color(0xffECEFF3),
//                           ),
//                           bottom: BorderSide(
//                             color: Color(0xffECEFF3),
//                           ))),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Overall P&L',
//                             style: GoogleFonts.inter(
//                                 color: const Color(0xff5E6B7D),
//                                 textStyle: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                     letterSpacing: -0.12)),
//                           ),
//                           const SizedBox(
//                             height: 3,
//                           ),
//                           Text(
//                             '${widget.tradedata.ltp} (${widget.tradedata.perChange}) ',
//                             style: GoogleFonts.inter(
//                                 color:
//                                     widget.tradedata.perChange!.startsWith('-')
//                                         ? const Color(0xffFF1717)
//                                         : const Color(0xff43A833),
//                                 textStyle: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 )),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           SvgPicture.asset(assets.buyIcon),
//                           const SizedBox(width: 8),
//                           CustomSwitch(
//                             value: _enable,
//                             onChanged: (bool val) {
//                               setState(() {
//                                 _enable = val;
//                               });
//                             },
//                           ),
//                           const SizedBox(width: 8),
//                           SvgPicture.asset(assets.sellIcon),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 Container(
//                   alignment: Alignment.centerLeft,
//                   decoration: const BoxDecoration(
//                       border: Border(
//                           top: BorderSide(
//                             color: Color(0xffECEFF3),
//                           ),
//                           bottom: BorderSide(
//                             color: Color(0xffECEFF3),
//                           ))),
//                   child: TabBar(
//                       isScrollable: true,
//                       indicatorColor: const Color(0xff000000),
//                       indicatorSize: TabBarIndicatorSize.label,
//                       unselectedLabelColor: const Color(0XFF666666),
//                       unselectedLabelStyle: GoogleFonts.inter(
//                           textStyle: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               letterSpacing: -0.28)),
//                       labelColor: const Color(0XFF000000),
//                       labelStyle: GoogleFonts.inter(
//                           textStyle: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: -0.28)),
//                       controller: tabCtrl,
//                       tabs: tabList),
//                 ),
//               ],
//             )),
//       ),
//       body: TabBarView(controller: tabCtrl, children: const [
//         Center(child: Text('REGULAR')),
//         GttTabView(),
//       ]),
//     );
//   }
// }
