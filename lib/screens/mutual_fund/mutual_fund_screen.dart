
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';

// import '../../provider/mf_provider.dart';
// import '../../provider/portfolio_provider.dart';
// import '../../provider/thems.dart';
// import '../../res/res.dart';
// import '../../routes/route_names.dart';
// import '../../sharedWidget/custom_back_btn.dart';
// import '../../sharedWidget/functions.dart';

// class MutualFundScreen extends ConsumerWidget {
//   const MutualFundScreen({super.key});
  

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final theme = watch(themeProvider);
//     final mfData = watch(mfProvider);
//     final portfolio = watch(portfolioProvider);
    
//     // print("mf data ${portfolio.mfHoldingsModel![0]}");

//     return Scaffold(
//       appBar: AppBar(
//             actions: [
//               InkWell(
//                   onTap: () async {
//                     await portfolio.fetchMFHoldings(context);
//                   },
//                   child: SvgPicture.asset(
//                       color: theme.isDarkMode
//                           ? colors.colorWhite
//                           : colors.colorBlack,
//                       assets.bookmarkadd)),
//               const SizedBox(
//                 width: 15,
//               ),
//               InkWell(
//                   onTap: () {
//                     Navigator.pushNamed(context, Routes.mfOrderbookscreen);
//                   },
//                   child: const Icon(Icons.shopping_bag_outlined)),
//               const SizedBox(
//                 width: 15,
//               ),
//               InkWell(
//                   onTap: () {
//                     Navigator.pushNamed(context, Routes.mfsearchscreen);
//                   },
//                   child: SvgPicture.asset(
//                     assets.searchIcon,
//                     color: theme.isDarkMode
//                         ? colors.colorWhite
//                         : colors.colorBlack,
//                     width: 18,
//                   )),
//               const SizedBox(
//                 width: 15,
//               ),
//             ],
//             elevation: .2,
//             leadingWidth: 41,
//             centerTitle: false,
//             titleSpacing: 6,
//             leading: const CustomBackBtn(),
//             shadowColor: const Color(0xffECEFF3),
//             title: Text("Mutual Funds",
//                 style: textStyles.appBarTitleTxt.copyWith(
//                     color: theme.isDarkMode
//                         ? colors.colorWhite
//                         : colors.colorBlack))),
//                         body: ListView(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           children: [
//                             Container(
//       margin: const EdgeInsets.symmetric(vertical: 16),
//                   padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 1,
//             offset: const Offset(0, 0),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.access_time, color: Colors.green),
//               const SizedBox(width: 8),
//               Text('Mutual funds', style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w600)),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(portfolio.mfTotCurrentVal.toString(), style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w600)),
//                   Text('Stock value', style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w400)),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(portfolio.mfTotInveest.toString(), style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w600)),
//                   Text('Stock investments', style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w400)),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(portfolio.mfTotalPnl.toString(), style: textStyle(
//                         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                         16,
//                         FontWeight.w600)),
//                         const SizedBox(width:8),
//                         Text("${portfolio.mfTotalPnlPerchng.toStringAsFixed(2)}%", style: textStyle(
//                                         portfolio.mfTotalPnlPerchng
//                                                 .toString()
//                                                 .startsWith("-")
//                                             ? colors.darkred
//                                             : colors.ltpgreen,
//                                         14,
//                                         FontWeight.w500))
//                     ],
//                   ),
//                   Text('Total P&L', style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w400)),
//                 ],
//               ),
//               // Column(
//               //   crossAxisAlignment: CrossAxisAlignment.end,
//               //   children: [
//               //     Text('₹5.5K -2.56%', style: textStyle(
//               //       theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//               //       16,
//               //       FontWeight.w600)),
//               //     Text('1 Day P&L', style: textStyle(
//               //       theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//               //       16,
//               //       FontWeight.w600)),
//               //   ],
//               // ),
//             ],
//           ),
//           const Divider(height: 32),
//           Text('No of funds invested - ${portfolio.mfHoldingsModel!.length}', style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w400)),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: LinearProgressIndicator(
//                   value: 0.4,
//                   backgroundColor: Colors.grey[300],
//                   valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: LinearProgressIndicator(
//                   value: 0.6,
//                   backgroundColor: Colors.grey[300],
//                   valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               ElevatedButton(
//                 onPressed: () {},
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Colors.green),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.arrow_upward, color: Colors.white),
//                     const SizedBox(width: 4),
//                     Text('${portfolio.mfTotalpositive} Positive', style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w600)),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               OutlinedButton(
//                 onPressed: () {},
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Colors.red),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.arrow_downward, color: Colors.red),
//                     const SizedBox(width: 4),
//                     Text('${portfolio.mfTotalnegative} Negative', style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w600)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//     Container(
//                   margin: const EdgeInsets.symmetric(vertical: 16),
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                           color: theme.isDarkMode
//                               ? colors.darkGrey
//                               : const Color(0xffEEF0F2),
//                           width: 1.5),
//                       color: theme.isDarkMode
//                           ? colors.darkGrey
//                           : const Color(0xffF1F3F8),
//                       borderRadius: BorderRadius.circular(6)),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Best mutual funds",
//                             style: textStyle(
//                                 theme.isDarkMode
//                                     ? colors.colorWhite
//                                     : colors.colorBlack,
//                                 16,
//                                 FontWeight.w600)),
//                         const SizedBox(height: 8),
//                         Text(
//                             "Find the right mutual fund across these asset classes",
//                             style: textStyle(
//                                 const Color(0xff666666), 13, FontWeight.w500)),
//                         const SizedBox(height: 14),
//                         SizedBox(
//                             height: 176,
//                             child: ListView.separated(
//                               scrollDirection: Axis.horizontal,
//                               itemCount: mfData.bestMFModel!.bestMFList!.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 return InkWell(
//                                   onTap: () async{
//                                     await mfData.filterItem(mfData
//                                         .bestMFModel!.bestMFList![index].title
//                                         .toString());
//                                         Navigator.pushNamed(
//                                         context, Routes.bestMfScreen);
                                      
//                                   },
//                                   child: Container(
//                                     width: 160,
//                                     padding: const EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         color: theme.isDarkMode
//                                             ? colors.colorBlack
//                                             : colors.colorWhite,
//                                         borderRadius: BorderRadius.circular(6)),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         SvgPicture.asset(
//                                           "${mfData.bestMFModel!.bestMFList![index].icon}",
//                                           height: 50,
//                                           width: 60,
//                                         ),
//                                         Text(
//                                             "${mfData.bestMFModel!.bestMFList![index].title}",
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: textStyle(
//                                                 theme.isDarkMode
//                                                     ? colors.colorWhite
//                                                     : colors.colorBlack,
//                                                 16,
//                                                 FontWeight.w500)),
//                                         Text(
//                                             "${mfData.bestMFModel!.bestMFList![index].subtitle}",
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: textStyle(
//                                                 const Color(0xff999999),
//                                                 13,
//                                                 FontWeight.w500)),
//                                         // Text(
//                                         //     "${mfData.bestMFModel!.bestMFList![index].funds!.length} Funds",
//                                         //     style: textStyle(
//                                         //         theme.isDarkMode
//                                         //             ? colors.colorWhite
//                                         //             : colors.colorBlack,
//                                         //         14,
//                                         //         FontWeight.w500)),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                               separatorBuilder:
//                                   (BuildContext context, int index) {
//                                 return const SizedBox(width: 14);
//                               },
//                             ))
//                       ])),
//                       Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           const BoxShadow(
//             color: Colors.black12,
//             blurRadius: 4.0,
//             spreadRadius: 1.0,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "INVEST IN",
//                 style: textStyle(
//                                                 theme.isDarkMode
//                                                     ? colors.colorWhite
//                                                     : colors.colorBlue,
//                                                 16,
//                                                 FontWeight.w500)
//               ),
//               const Icon(
//                 Icons.card_giftcard,
//                 color: Colors.red,
//               ),
//             ],
//           ),
//           const SizedBox(height: 8.0),
//           Text(
//             "Ongoing new fund offerings",
//             style: textStyle(
//                                                 theme.isDarkMode
//                                                     ? colors.colorWhite
//                                                     : colors.colorBlack,
//                                                 18,
//                                                 FontWeight.w600)
//           ),
//           const SizedBox(height: 8.0),
//           Text(
//             "A new fund offer (NFO) is the first subscription for any new fund by an investment company.",
//             style: textStyle(
//                                                 theme.isDarkMode
//                                                     ? colors.colorWhite
//                                                     : colors.colorBlack,
//                                                 14,
//                                                 FontWeight.w400)
//           ),
//           const SizedBox(height: 12.0),
//           GestureDetector(
//             onTap: () {
//                Navigator.pushNamed(context, Routes.mfnfoscreen);
//             },
//             child: Text(
//               "See all NFOs →",
//               style: textStyle(
//                                                 theme.isDarkMode
//                                                     ? colors.colorWhite
//                                                     : colors.colorBlue,
//                                                 16,
//                                                 FontWeight.w500)
//             ),
//           ),
//         ],
//       ),
//     ),
//     const SizedBox(
//       height: 15,
//     ),
//     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
//       Text("All Categories",style:textStyle(
//                                                 theme.isDarkMode
//                                                     ? colors.colorWhite
//                                                     : colors.colorBlack,
//                                                 16,
//                                                 FontWeight.w500)),
//       Text("Show All",style:textStyle(
//                                                 theme.isDarkMode
//                                                     ? colors.colorWhite
//                                                     : colors.colorBlue,
//                                                 16,
//                                                 FontWeight.w500))
//     ],
//     ),
//     const SizedBox(
//       height: 15,
//     ),
//     SingleChildScrollView(
//       child: ListView.separated(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//                                 scrollDirection: Axis.vertical,
//                                 itemCount: mfData.bestMFModel!.bestMFList!.length,
//                                 itemBuilder: (BuildContext context, int index) {
//                                   return InkWell(
//                                     onTap: () async{
//                                       await mfData.filterItem(mfData
//                                           .bestMFModel!.bestMFList![index].title
//                                           .toString());
//                                           Navigator.pushNamed(
//                                           context, Routes.bestMfScreen);
                                        
//                                     },
//                                     child: Container(
//                                       width: 160,
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                           color: theme.isDarkMode
//                                               ? colors.colorBlack
//                                               : colors.colorWhite,
//                                           borderRadius: BorderRadius.circular(6),
//                                           boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 1,
//             offset: const Offset(0, 0),
//           ),
//         ],),
                                          
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceEvenly,
//                                         children: [
//                                           SvgPicture.asset(
//                                             "${mfData.bestMFModel!.bestMFList![index].icon}",
//                                             height: 50,
//                                             width: 60,
//                                           ),
//                                           const SizedBox(height: 15,),
//                                           Text(
//                                               "${mfData.bestMFModel!.bestMFList![index].title}",
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: textStyle(
//                                                   theme.isDarkMode
//                                                       ? colors.colorWhite
//                                                       : colors.colorBlack,
//                                                   16,
//                                                   FontWeight.w500)),
//                                                   const SizedBox(height: 10,),
                                                  
//                                           Text(
//                                               "${mfData.bestMFModel!.bestMFList![index].subtitle}",
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: textStyle(
//                                                   const Color(0xff999999),
//                                                   14,
//                                                   FontWeight.w500)),
//                                                   const SizedBox(height: 10,),
//                                                   Text(
//                                               "See All",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: textStyle(
//                                                   theme.isDarkMode
//                                                       ? colors.colorWhite
//                                                       : colors.colorBlue,
//                                                   16,
//                                                   FontWeight.w500))
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 separatorBuilder:
//                                     (BuildContext context, int index) {
//                                   return const SizedBox(height: 14);
//                                 },
//                               ),
//     ),
//     const SizedBox(height: 10,)
//                           ]   
            
//     ));
//   }
//   }