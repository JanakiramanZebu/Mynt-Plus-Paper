// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:expansion_tile_group/expansion_tile_group.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:readmore/readmore.dart';
// import '../../../../../res/res.dart';
// import '../../../../../screens/stocks/invest/inverst_stocks/inverst_details/dornut.dart';

// class InverstWeightSegment extends StatefulWidget {
//   const InverstWeightSegment({super.key});

//   @override
//   State<InverstWeightSegment> createState() => _InverstWeightSegmentState();
// }

// class _InverstWeightSegmentState extends State<InverstWeightSegment> {
//   final List<String> items = [
//     'Item1',
//     'Item2',
//     'Item3',
//     'Item4',
//     'Item5',
//     'Item6',
//     'Item7',
//     'Item8',
//   ];
//   String? selectedValue;
//   bool isexpand = true;
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     // double screenheight = MediaQuery.of(context).size.height;
//     return Container(
//       decoration: const BoxDecoration(
//           border: Border(bottom: BorderSide(color: Color(0xffECEDEE)))),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'About the Venture Capital',
//                   style: GoogleFonts.inter(
//                       color: const Color(0xff000000),
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.36),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                   'Constituents Weights and Segment',
//                   style: GoogleFonts.inter(
//                       color: const Color(0xff000000),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.32),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 ReadMoreText(
//                   "Each fund is uniquely allocated to suit and match customer expectations based on the risk profile and return expectations.",
//                   style: GoogleFonts.inter(
//                       letterSpacing: -0.07,
//                       height: 1.7,
//                       textStyle: textStyle(
//                           const Color(0xff666666), 14, FontWeight.w600)),
//                   trimLines: 3,
//                   colorClickableText: const Color(0xff0037B7),
//                   trimMode: TrimMode.Line,
//                   trimCollapsedText: 'Read more',
//                   trimExpandedText: ' Read less',
//                 ),
//                 const SizedBox(
//                   height: 24,
//                 ),
//                 SizedBox(
//                   width: screenWidth,
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton2<String>(
//                       isExpanded: true,
//                       hint: Row(
//                         children: [
//                           Text(
//                             'Group by :',
//                             style: GoogleFonts.inter(
//                               color: const Color(0xff666666),
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 4,
//                           ),
//                           const Expanded(
//                             child: Text(
//                               'Segment Compositions',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: Color(0xff000000),
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       items: items
//                           .map((String item) => DropdownMenuItem<String>(
//                                 value: item,
//                                 child: Text(
//                                   item,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xff000000),
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ))
//                           .toList(),
//                       value: selectedValue,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedValue = value;
//                         });
//                       },
//                       // buttonStyleData: ButtonStyleData(
//                       //   padding: const EdgeInsets.symmetric(
//                       //     horizontal: 14,
//                       //   ),
//                       //   decoration: BoxDecoration(
//                       //     borderRadius: BorderRadius.circular(24),
//                       //     color: const Color(0xffF1F3F8),
//                       //   ),
//                       //   elevation: 0,
//                       // ),
//                       // iconStyleData: const IconStyleData(
//                       //   icon: Icon(
//                       //     Icons.arrow_forward_ios_outlined,
//                       //   ),
//                       //   iconSize: 14,
//                       //   iconEnabledColor: Color(0xff666666),
//                       //   iconDisabledColor: Color(0xff666666),
//                       // ),
//                       // dropdownStyleData: DropdownStyleData(
//                       //   maxHeight: 200,
//                       //   width: screenWidth,
//                       //   padding: const EdgeInsets.symmetric(horizontal: 16),
//                       //   decoration: BoxDecoration(
//                       //     borderRadius: BorderRadius.circular(14),
//                       //     color: const Color(0xffFFFFFF),
//                       //   ),
//                       //   offset: const Offset(-20, 0),
//                       //   scrollbarTheme: ScrollbarThemeData(
//                       //     radius: const Radius.circular(40),
//                       //     thickness: MaterialStateProperty.all(6),
//                       //     thumbVisibility: MaterialStateProperty.all(true),
//                       //   ),
//                       // ),
//                       // menuItemStyleData: const MenuItemStyleData(
//                       //   height: 40,
//                       //   padding: EdgeInsets.only(left: 14, right: 14),
//                       // ),
//                     ),
//                   ),
//                 ),
//                 const InverstDonutChaetWidget(),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 16),
//             child: Text(
//               'Constituents',
//               style: GoogleFonts.inter(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xff666666),
//                   letterSpacing: 0.28),
//             ),
//           ),
//           const SizedBox(
//             height: 4,
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 16),
//             child: Text(
//               'See detailed composition of smallcase portfolio',
//               style: GoogleFonts.inter(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: const Color(0xff999999),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 16, top: 12),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               decoration: const BoxDecoration(
//                   border: Border(
//                       top: BorderSide(
//                         color: Color(0xffDDDDDD),
//                       ),
//                       bottom: BorderSide(
//                         color: Color(0xffDDDDDD),
//                       ))),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Segments and stocks',
//                         style: GoogleFonts.inter(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666),
//                         ),
//                       ),
//                       Text(
//                         'Weightage (%)',
//                         style: GoogleFonts.inter(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff666666),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(
//               left: 16,
//             ),
//             child: ExpansionTileGroup(children: [
//               ExpansionTileItem(
//                 trailing: Padding(
//                   padding: const EdgeInsets.only(right: 16),
//                   child: Text(
//                     '45.5%',
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xff000000),
//                     ),
//                   ),
//                 ),
//                 collapsedBackgroundColor: const Color(0xffFAFBFF),
//                 title: Container(
//                     height: 40,
//                     decoration: const BoxDecoration(
//                         border: Border(
//                             left: BorderSide(
//                                 width: 4, color: Color(0xff3AAA92)))),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 9),
//                       child: Row(
//                         children: [
//                           Text(
//                             'Banking and Finance',
//                             style: GoogleFonts.inter(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xff000000),
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 9,
//                           ),
//                           SvgPicture.asset(assets.triangledown)
//                         ],
//                       ),
//                     )),
//                 tilePadding: const EdgeInsets.only(),
//                 expendedBorderColor: const Color(0xffFFFFFF),
//                 children: const [
//                   Text('Title of expansion tile item 1'),
//                 ],
//               ),
//               ExpansionTileItem(
//                 trailing: Padding(
//                   padding: const EdgeInsets.only(right: 16),
//                   child: Text(
//                     '9.4%',
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xff000000),
//                     ),
//                   ),
//                 ),
//                 collapsedBackgroundColor: const Color(0xffFAFBFF),
//                 title: Container(
//                     height: 40,
//                     decoration: const BoxDecoration(
//                         border: Border(
//                             left: BorderSide(
//                                 width: 4, color: Color(0xffA8E5D4)))),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 9),
//                       child: Row(
//                         children: [
//                           Text(
//                             'Utilities',
//                             style: GoogleFonts.inter(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xff000000),
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 9,
//                           ),
//                           SvgPicture.asset(assets.triangledown)
//                         ],
//                       ),
//                     )),
//                 tilePadding: const EdgeInsets.only(),
//                 expendedBorderColor: const Color(0xffFFFFFF),
//                 children: const [
//                   Text('Title of expansion tile item 1'),
//                 ],
//               ),
//               ExpansionTileItem(
//                 trailing: Padding(
//                   padding: const EdgeInsets.only(right: 16),
//                   child: Text(
//                     '3.3%',
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xff000000),
//                     ),
//                   ),
//                 ),
//                 collapsedBackgroundColor: const Color(0xffFAFBFF),
//                 title: Container(
//                     height: 40,
//                     decoration: const BoxDecoration(
//                         border: Border(
//                             left: BorderSide(
//                                 width: 4, color: Color(0xffECD7A1)))),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 9),
//                       child: Row(
//                         children: [
//                           Text(
//                             'Software & Services',
//                             style: GoogleFonts.inter(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xff000000),
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 9,
//                           ),
//                           SvgPicture.asset(assets.triangledown)
//                         ],
//                       ),
//                     )),
//                 tilePadding: const EdgeInsets.only(),
//                 expendedBorderColor: const Color(0xffFFFFFF),
//                 children: const [
//                   Text('Title of expansion tile item 1'),
//                 ],
//               ),
//               ExpansionTileItem(
//                 trailing: Padding(
//                   padding: const EdgeInsets.only(right: 16),
//                   child: Text(
//                     '1.8%',
//                     style: GoogleFonts.inter(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xff000000),
//                     ),
//                   ),
//                 ),
//                 collapsedBackgroundColor: const Color(0xffFAFBFF),
//                 title: Container(
//                     height: 40,
//                     decoration: const BoxDecoration(
//                         border: Border(
//                             left: BorderSide(
//                                 width: 4, color: Color(0xffECD7A1)))),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 9),
//                       child: Row(
//                         children: [
//                           Text(
//                             'Pharmaceuticals',
//                             style: GoogleFonts.inter(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xff000000),
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 9,
//                           ),
//                           SvgPicture.asset(assets.triangledown)
//                         ],
//                       ),
//                     )),
//                 tilePadding: const EdgeInsets.only(),
//                 expendedBorderColor: const Color(0xffFFFFFF),
//                 children: const [
//                   Text('Title of expansion tile item 1'),
//                 ],
//               ),
//             ]),
//           ),
//         ],
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
