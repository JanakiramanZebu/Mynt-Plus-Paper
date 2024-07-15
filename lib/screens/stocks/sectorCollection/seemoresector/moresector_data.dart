// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import '../../../../res/res.dart';
// import '../../../../routes/route_names.dart';
// import '../../../sharedWidget/custom_text_btn.dart';

// class MoreSectorData extends StatefulWidget {
//   const MoreSectorData({super.key});

//   @override
//   State<MoreSectorData> createState() => _MoreSectorDataState();
// }

// class _MoreSectorDataState extends State<MoreSectorData> {
//   double low = 0.00;
//   double high = 0.00;
//   double price = 0.00;
//   int indicesLength = 0;
//   bool hideMore = false;
//   List<Cars> dummyData = [
//     Cars(
//       futurename: 'Automobile',
//       expriye: 'Mcap',
//       monthdate: 'May 25',
//       lp: '₹18,428.30',
//       percentage: '-1.65%',
//       oi: 'OI  ',
//       oivalue: '17,47,578',
//       oipercentage: '34',
//     ),
//     Cars(
//       futurename: 'Healthcare',
//       expriye: 'Mcap',
//       monthdate: 'May 25',
//       lp: '₹18,428.30',
//       percentage: '-1.65%',
//       oi: 'OI  ',
//       oivalue: '17,47,578',
//       oipercentage: '34',
//     ),
//     Cars(
//       futurename: 'Finance',
//       expriye: 'Mcap',
//       monthdate: 'Jun 25',
//       lp: '₹18,428.30',
//       percentage: '+1.65%',
//       oi: 'OI  ',
//       oivalue: '15,45,345',
//       oipercentage: '23',
//     ),
//     Cars(
//       futurename: 'Jewelry',
//       expriye: 'Mcap',
//       monthdate: 'Jul; 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '10',
//     ),
//     Cars(
//       futurename: 'Trading',
//       expriye: 'Mcap',
//       monthdate: 'Aug 25',
//       lp: '₹18,428.30',
//       percentage: '+1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '50',
//     ),
//     Cars(
//       futurename: 'Banks',
//       expriye: 'Mcap',
//       monthdate: 'Aug 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '45',
//     ),
//     Cars(
//       futurename: 'Private banks',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '+1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '12',
//     ),
//     Cars(
//       futurename: 'Public banks',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '100',
//     ),
//     Cars(
//       futurename: 'Chemicals',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '+1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '32',
//     ),
//     Cars(
//       futurename: 'Renewables',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '41',
//     ),
//     Cars(
//       futurename: 'Metals',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '41',
//     ),
//     Cars(
//       futurename: 'Homecare',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '41',
//     ),
//     Cars(
//       futurename: 'Telecom',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '41',
//     ),
//     Cars(
//       futurename: 'Infrastucture',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '41',
//     ),
//     Cars(
//       futurename: 'Technology',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '41',
//     ),
//     Cars(
//       futurename: 'Hospitals',
//       expriye: 'Mcap',
//       monthdate: 'Sep 25',
//       lp: '₹18,428.30',
//       percentage: '-1.25%',
//       oi: 'OI  ',
//       oivalue: '21,33,455',
//       oipercentage: '41',
//     ),
//   ];
//   @override
//   void initState() {
//     setState(() {
//       indicesLength = int.parse("${(dummyData.length / 2).ceil()}");
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           height: 15,
//         ),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: dummyData.length,
//           itemBuilder: (context, index) {
//             return InkWell(
//               onTap: () {
//                 Navigator.pushNamed(context, Routes.SectorIndexPage,
//                     arguments: dummyData[index]);
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 13),
//                 decoration: const BoxDecoration(
//                     border:
//                         Border(bottom: BorderSide(color: Color(0xffECEDEE)))),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     dummyData[index].futurename,
//                                     style: textStyle(const Color(0xff000000),
//                                         14, FontWeight.w600),
//                                   ),
//                                   Text(
//                                     dummyData[index].lp,
//                                     style: textStyle(const Color(0xff000000),
//                                         14, FontWeight.w600),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 7),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text("#Stocks :",
//                                           style: textStyle(
//                                               const Color(0xff999999),
//                                               13,
//                                               FontWeight.w500)),
//                                       Text(
//                                           dummyData[index].oipercentage.isEmpty
//                                               ? "0.00"
//                                               : dummyData[index].oipercentage,
//                                           style: textStyle(
//                                               const Color(0xff000000),
//                                               13,
//                                               FontWeight.w500)),
//                                     ],
//                                   ),
//                                   Text(
//                                     dummyData[index].percentage,
//                                     style: textStyle(
//                                         dummyData[index]
//                                                 .percentage
//                                                 .startsWith("-")
//                                             ? const Color(0xffFF1717)
//                                             : const Color(0xff43A833),
//                                         14,
//                                         FontWeight.w600),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 10),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 14),
//                         SvgPicture.asset(
//                           "assets/icon/watchlistIcon/bookmark_group.svg",
//                           height: 20,
//                           width: 20,
//                         )
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 6, vertical: 4),
//                               color: const Color(0xffF1F3F8),
//                               child: Row(
//                                 children: [
//                                   Text("${dummyData[index].expriye} ",
//                                       style: textStyle(const Color(0xff999999),
//                                           12, FontWeight.w500)),
//                                   Text("29,534Cr",
//                                       style: textStyle(const Color(0xff000000),
//                                           12, FontWeight.w500)),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(left: 8),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 6, vertical: 4),
//                               color: const Color(0xffF1F3F8),
//                               child: Row(
//                                 children: [
//                                   Text("PE ",
//                                       style: textStyle(const Color(0xff999999),
//                                           12, FontWeight.w500)),
//                                   Text("22.86",
//                                       style: textStyle(const Color(0xff000000),
//                                           12, FontWeight.w500)),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         Container(
//                           margin: const EdgeInsets.only(left: 8),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 6, vertical: 4),
//                           color: const Color(0xffF1F3F8),
//                           child: Row(
//                             children: [
//                               Text("PB ",
//                                   style: textStyle(const Color(0xff999999), 12,
//                                       FontWeight.w500)),
//                               Text("2.86",
//                                   style: textStyle(const Color(0xff000000), 12,
//                                       FontWeight.w500)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//           separatorBuilder: (context, index) {
//             return const Padding(
//               padding: EdgeInsets.symmetric(
//                 vertical: 7,
//               ),
//               // child: Divider(
//               //   color: Color(0xffECEDEE),
//               // ),
//             );
//           },
//         ),
//         hideMore ? Container() : const SizedBox(height: 10),
//         hideMore
//             ? Container()
//             : Center(
//                 child: SizedBox(
//                   width: 160,
//                   child: CustomTextBtn(
//                     icon: assets.downArrow,
//                     label: "See more indices",
//                     onPress: () {
//                       setState(() {
//                         hideMore = true;
//                         indicesLength = dummyData.length;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//         hideMore ? Container() : const SizedBox(height: 10),
//       ],
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

// class Cars {
//   String futurename;
//   String expriye;
//   String monthdate;
//   String lp;
//   String percentage;
//   String oi;
//   String oivalue;
//   String oipercentage;
//   Cars({
//     required this.futurename,
//     required this.expriye,
//     required this.monthdate,
//     required this.lp,
//     required this.percentage,
//     required this.oi,
//     required this.oivalue,
//     required this.oipercentage,
//   });
// }
