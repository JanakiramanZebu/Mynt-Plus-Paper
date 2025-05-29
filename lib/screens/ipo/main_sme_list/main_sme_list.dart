// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/models/ipo_model/ipo_mainstream_model.dart';
import 'package:mynt_plus/screens/ipo/preclose_ipo/preclose_ipo_screen.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';
import 'single_page.dart';

class MainSmeListCard extends StatelessWidget {
  const MainSmeListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ipos = ref.watch(ipoProvide);
      final mainstreamipo = ref.watch(ipoProvide);
      final upi = ref.watch(transcationProvider);
      final theme = ref.watch(themeProvider);
      final dev_height = MediaQuery.of(context).size.height;

      List<dynamic> openIpos = mainstreamipo.mainsme
          .where((ipo) =>
              ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) == "Open")
          .toList();

      List<dynamic> preOpenIpos = mainstreamipo.mainsme
          .where((ipo) =>
              ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) ==
              "Pre-open")
          .toList();

          String formatDate(String date) {
            List<String> parts = date.split('-');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
  DateTime parsedDate = DateTime(year,month,day);
  return DateFormat('d MMM').format(parsedDate); 
}

      return ((openIpos.isEmpty) &&
              (ipos.ipoPreClose!.msg.isEmpty) &&
              (preOpenIpos.isEmpty))
          ? Padding(
              padding: const EdgeInsets.only(top: 225),
              child: Container(
                height: dev_height - 140,
                child: const Column(
                  children: [
                    NoDataFound(),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (openIpos.isNotEmpty) ...[
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //       left: 16, right: 16, top: 8, bottom: 0),
                      //   child: Text(
                      //     "Live",
                      //     style: textStyle(
                      //         theme.isDarkMode
                      //             ? colors.colorWhite.withOpacity(0.3)
                      //             : colors.colorBlack.withOpacity(0.3),
                      //         16,
                      //         FontWeight.w600),
                      //   ),
                      // ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              await ipos.getIpoSinglePage(
                                  ipoName: "${openIpos[index].name}");
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  isDismissible: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16))),
                                  context: context,
                                  builder: (context) => Container(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child: MainSmeSinglePage(
                                          pricerange:
                                              "₹${double.parse(openIpos[index].minPrice!).toInt()} - ₹${double.parse(openIpos[index].maxPrice!).toInt()}",
                                          mininv:
                                              "₹${convertCurrencyINRStandard(mininv(double.parse(openIpos[index].minPrice!).toDouble(), int.parse(openIpos[index].minBidQuantity!).toInt()).toInt())}",
                                          enddate:
                                              "${openIpos[index].biddingEndDate}",
                                          startdate:
                                              "${openIpos[index].biddingStartDate}",
                                          ipotype: "${openIpos[index].key}",
                                          ipodetails:
                                              jsonEncode(openIpos[index]),
                                        ),
                                      ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  
                                   
                              
                                    // leading: ClipOval(
                                    //   child: Container(
                                    //     alignment: Alignment.center,
                                    //     color: colors.colorDivider.withOpacity(.3),
                                    //     width: 50,
                                    //     height: 50,
                                    //     child: Container(
                                    //       padding: EdgeInsets.all(8),
                                    //       child: Text(
                                    //         "${mainstreamipo.mainsme[index].name.substring(0, 1)}",
                                    //         style: textStyle(
                                    //             theme.isDarkMode
                                    //                 ? colors.colorWhite.withOpacity(0.3)
                                    //                 : colors.colorBlack.withOpacity(0.3),
                                    //             20,
                                    //             FontWeight.w600),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                     Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             // ClipOval(
                                             //   child: Container(
                                             //     color: colors.colorDivider.withOpacity(.3),
                                             //     width: 40,
                                             //     height: 40,
                                             //     child: Container(
                                             //       padding: const EdgeInsets.all(3),
                                             //       child: Image.network(
                                             //       openIpos[index].imageLink,
                                                                       
                                             //       ),
                                             //     ),
                                             //   ),
                                             // ),
                                                                       
                                             // SizedBox(width: 8),
                                                                       
                                             SizedBox(
                                               width: 250,
                                               child: Text(
                                                   openIpos[index]
                                                       .name
                                                      ,
                                                   overflow:
                                                       TextOverflow.ellipsis,
                                                   style: textStyle(
                                                       theme.isDarkMode
                                                           ? colors.colorWhite
                                                           : colors.colorBlack,
                                                       14,
                                                       FontWeight.w600)),
                                             ),
                                             SizedBox(height: 4,),
                                              Container(
                                                     padding: const EdgeInsets.symmetric(
                                                         horizontal: 8,
                                                         vertical: 4),
                                                     decoration: BoxDecoration(
                                                         color: openIpos[index].key ==
                                                                 "SME"
                                                             ? theme.isDarkMode
                                                                 ? colors.colorGrey
                                                                     .withOpacity(
                                                                         .3)
                                                                 : const Color.fromARGB(
                                                                     255, 243, 242, 174)
                                                             : theme.isDarkMode
                                                                 ? colors.colorGrey
                                                                     .withOpacity(
                                                                         .3)
                                                                 : const Color.fromARGB(
                                                                     255,
                                                                     251,
                                                                     215,
                                                                     148), //(0xffF1F3F8),
                                                         borderRadius:
                                                             BorderRadius.circular(
                                                                 4)),
                                                     child: Text(
                                                         "${openIpos[index].key}",
                                                         style: textStyle(const Color(0xff666666), 10, FontWeight.w500))),
                                           ],
                                         ),

                                          openIpos[index].totalsub != null && openIpos[index].totalsub != ''
                                           ? Column(
                                               crossAxisAlignment:
                                                   CrossAxisAlignment.start,
                                               children: [
                                                 Text(
                                                     "${openIpos[index].totalsub}x",
                                                     style: textStyle(
                                                         theme.isDarkMode
                                                             ? colors.colorWhite
                                                             : colors.colorBlack,
                                                         14,
                                                         FontWeight.w500)),
                                                 const SizedBox(
                                                   height: 4,
                                                 ),
                                                 

                                                         Text("Subscription",
                                                     style: textStyle(
                                                         const Color(0xff666666),
                                                         10,
                                                         FontWeight.w500)),
                                               ],
                                             )
                                           : SizedBox.shrink(),
                                       ],
                                     ),
                                     SizedBox(height: 8,),
                              
                                     Row(
                                       mainAxisAlignment:
                                           MainAxisAlignment.spaceBetween,
                                       children: [
                                         // open tag ----------
                                     
                                         // Container(
                                         //     padding: const EdgeInsets.symmetric(
                                         //         horizontal: 8, vertical: 4),
                                         //     decoration: BoxDecoration(
                                         //         color: theme.isDarkMode
                                         //             ? colors.colorGrey.withOpacity(.1)
                                         //             : const Color(0xffF1F3F8),
                                         //         borderRadius: BorderRadius.circular(4)),
                                         //     child: Text(
                                         //         "${mainstreamipo.mainsme[index].symbol}",
                                         //         style: textStyle(colors.colorGrey, 11,
                                         //             FontWeight.w500))),
                                         // const SizedBox(width: 10),
                                         // Container(
                                         //     padding: const EdgeInsets.symmetric(
                                         //         horizontal: 8, vertical: 4),
                                         //     decoration: BoxDecoration(
                                         //         color: ipostartdate(
                                         //                     "${mainstreamipo.mainsme[index].biddingStartDate}",
                                         //                     "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                         //                 "Open"
                                         //             ? theme.isDarkMode
                                         //                 ? const Color(0xffECF8F1)
                                         //                     .withOpacity(.3)
                                         //                 : const Color(0xffECF8F1)
                                         //             : theme.isDarkMode
                                         //                 ? const Color(0xffFFF6E6)
                                         //                     .withOpacity(.3)
                                         //                 : const Color(0xffFFF6E6),
                                         //         borderRadius:
                                         //             BorderRadius.circular(4)),
                                         //     child: Text(
                                         //         // for text open, closed or upcoming
                                         //         ipostartdate(
                                         //             "${mainstreamipo.mainsme[index].biddingStartDate}",
                                         //             "${mainstreamipo.mainsme[index].biddingEndDate}"),
                                         //         style: textStyle(
                                         //             Color(
                                         //                 ipostartdate("${mainstreamipo.mainsme[index].biddingStartDate}", "${mainstreamipo.mainsme[index].biddingEndDate}") == "Open"
                                         //                     ? 0xff43A833
                                         //                     : 0xffB37702),
                                         //             11,
                                         //             FontWeight.w500)
                                         //             )
                                         //             ),
                                     
                                         // Container(
                                         //     margin: const EdgeInsets.symmetric(
                                         //         horizontal: 4),
                                         //         horizontal: 4),
                                         //     padding: const EdgeInsets.symmetric(
                                         //         horizontal: 8, vertical: 4),
                                         //     decoration: BoxDecoration(
                                         //         color:
                                         //             mainstreamipo.mainsme[index].key ==
                                         //                     "SME"
                                         //                 ? theme.isDarkMode
                                         //                     ? colors.colorGrey
                                         //                         .withOpacity(.1)
                                         //                     : const Color.fromARGB(
                                         //                         255, 243, 242, 174)
                                         //                 : theme.isDarkMode
                                         //                     ? colors.colorGrey
                                         //                         .withOpacity(.1)
                                         //                     : const Color.fromARGB(
                                         //                         255,
                                         //                         251,
                                         //                         215,
                                         //                         148), //(0xffF1F3F8),
                                         //         borderRadius: BorderRadius.circular(4)),
                                         //     child: Text(
                                         //         "${mainstreamipo.mainsme[index].key}",
                                         //         style: textStyle(
                                         //             const Color(0xff666666),
                                         //             9,
                                         //             FontWeight.w500))),
                                         // const SizedBox(width: 10),
                                     
                                         // time period
                                     
                                         Column(
                                           crossAxisAlignment:
                                               CrossAxisAlignment.start,
                                           children: [
                                             Text("Closes on",
                                                 style: textStyle(
                                                     const Color(0xff666666),
                                                     10,
                                                     FontWeight.w500)),
                                             const SizedBox(
                                               height: 4,
                                             ),
                                             Text(
                                                 "${openIpos[index].biddingEndDate!.substring(5, 11)}",
                                                 style: textStyle(
                                                     theme.isDarkMode
                                                         ? colors.colorWhite
                                                         : colors.colorBlack,
                                                     14,
                                                     FontWeight.w500)),
                                           ],
                                         ),
                                     
                                         
                                     
                                         SizedBox(
                                          height: 30,
                                           child: ElevatedButton(
                                             style: ElevatedButton.styleFrom(
                                                 elevation: 0,
                                                 minimumSize: const Size(0, 30),
                                                 padding:
                                                     const EdgeInsets.symmetric(
                                                         horizontal: 14,
                                                         vertical: 5),
                                                 backgroundColor: theme.isDarkMode
                                                     ? colors.colorWhite
                                                     : colors.colorBlack,
                                                 shape: RoundedRectangleBorder(
                                                   borderRadius:
                                                       BorderRadius.circular(50),
                                                 )),
                                             onPressed: () async {
                                               ipos.setisSMEPlaceOrderBtnActiveValue =
                                                   false;
                                               ipos.setisMainIPOPlaceOrderBtnActiveValue =
                                                   false;
                                               await upi.fetchupiIdView(
                                                   upi.bankdetails!
                                                       .dATA![upi.indexss][1],
                                                   upi.bankdetails!
                                                       .dATA![upi.indexss][2]);
                                               openIpos[index].key == "SME"
                                                   ? await ref
                                                       .read(ipoProvide)
                                                       .smeipocategory()
                                                   : await ref
                                                       .read(ipoProvide)
                                                       .mainipocategory();
                                                                                
                                               openIpos[index].key == "SME"
                                                   ? Navigator.pushNamed(
                                                       context,
                                                       Routes.smeapplyIPO,
                                                       arguments: openIpos[index],
                                                     )
                                                   : Navigator.pushNamed(
                                                       context, Routes.applyIPO,
                                                       arguments: openIpos[index]);
                                             },
                                             child: ipos.loading
                                                 ? const SizedBox(
                                                     width: 18,
                                                     height: 20,
                                                     child:
                                                         CircularProgressIndicator(
                                                             strokeWidth: 2,
                                                             color: Color(
                                                                 0xff666666)),
                                                   )
                                                 : Text(
                                                     'Apply',
                                                     style: textStyle(
                                                         theme.isDarkMode
                                                             ? colors.colorBlack
                                                             : colors.colorWhite,
                                                         12,
                                                         FontWeight.w500),
                                                   ),
                                                                                
                                             // ipostartdate(
                                             //               "${mainstreamipo.mainsme[index].biddingStartDate}",
                                             //               "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                             //           "Open"
                                             //       ? "Apply"
                                             //       : "Pre Apply"
                                           ),
                                         )
                                         // ipostartdate(
                                         //             "${mainstreamipo.mainsme[index].biddingStartDate}",
                                         //             "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                         //         "Open"
                                         //     ? Text(
                                         //         "Left ${mainstreamipo.mainsme[index]!.days_to_end_ipo} days"
                                         //             .toString(),
                                         //         style: textStyle(
                                         //             const Color(0xff666666),
                                         //             11,
                                         //             FontWeight.w500))
                                         //     : Container()
                                       ],
                                     ),
                                  
                                  // Divider(
                                  //     color: theme.isDarkMode
                                  //         ? colors.darkColorDivider
                                  //         : colors.colorDivider),
                              
                                  // Price range and invest part
                                  // Padding(
                                  //   padding: const EdgeInsets.only(
                                  //    left: 16, right: 16, bottom: 8),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Column(
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //         children: [
                                  //           Text("Price Range",
                                  //               style: textStyle(
                                  //                   const Color(0xff666666),
                                  //                   10,
                                  //                   FontWeight.w500)),
                                  //           const SizedBox(
                                  //             height: 4,
                                  //           ),
                                  //           Text(
                                  //               "₹ ${double.parse(mainstreamipo.mainsme[index].minPrice!).toInt()} - ₹ ${double.parse(mainstreamipo.mainsme[index].maxPrice!).toInt()}",
                                  //               style: textStyle(
                                  //                   theme.isDarkMode
                                  //                       ? colors.colorWhite
                                  //                       : colors.colorBlack,
                                  //                   15,
                                  //                   FontWeight.w500)),
                                  //         ],
                                  //       ),
                                  // Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: [
                                  //     Text("Issue size",
                                  //         style: textStyle(const Color(0xff666666),
                                  //             13, FontWeight.w500)),
                                  //     Text(
                                  //         "${mainstreamipo.mainsme[index].issueSize}",
                                  //         style: textStyle(
                                  //             theme.isDarkMode
                                  //                 ? colors.colorWhite
                                  //                 : colors.colorBlack,
                                  //             15,
                                  //             FontWeight.w500)),
                                  //   ],
                                  // ),
                                  // ElevatedButton(
                                  //     style: ElevatedButton.styleFrom(
                                  //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  //         // fixedSize: const Size(170, 30),
                                  //         elevation: 0,
                                  //         minimumSize: const Size(0, 30),
                                  //         backgroundColor: theme.isDarkMode
                                  //             ? colors.colorbluegrey
                                  //             : const Color(0xffF1F3F8),
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius:
                                  //               BorderRadius.circular(50),
                                  //         )),
                                  //     onPressed: () async {
                                  //       ipos.setisSMEPlaceOrderBtnActiveValue =
                                  //           false;
                                  //       ipos.setisMainIPOPlaceOrderBtnActiveValue =
                                  //           false;
                                  //       await upi.fetchupiIdView(
                                  //           upi.bankdetails!
                                  //               .dATA![upi.indexss][1],
                                  //           upi.bankdetails!
                                  //               .dATA![upi.indexss][2]);
                                  //       mainstreamipo.mainsme[index].key ==
                                  //               "SME"
                                  //           ? await context
                                  //               .read(ipoProvide)
                                  //               .smeipocategory()
                                  //           : await context
                                  //               .read(ipoProvide)
                                  //               .mainipocategory();
                              
                                  //       mainstreamipo.mainsme[index].key ==
                                  //               "SME"
                                  //           ? Navigator.pushNamed(
                                  //               context,
                                  //               Routes.smeapplyIPO,
                                  //               arguments:
                                  //                   ipos.mainsme[index],
                                  //             )
                                  //           : Navigator.pushNamed(
                                  //               context, Routes.applyIPO,
                                  //               arguments:
                                  //                   ipos.mainsme[index]);
                                  //     },
                                  //     child: ipos.loading
                                  //         ? const SizedBox(
                                  //             width: 18,
                                  //             height: 20,
                                  //             child:
                                  //                 CircularProgressIndicator(
                                  //                     strokeWidth: 2,
                                  //                     color:
                                  //                         Color(0xff666666)),
                                  //           )
                                  //         : Column(
                                  //             crossAxisAlignment:
                                  //                 CrossAxisAlignment.start,
                                  //             mainAxisAlignment:
                                  //                 MainAxisAlignment.center,
                                  //             children: [
                                  //               // Text("Invest",
                                  //               //     style: textStyle(
                                  //               //         theme.isDarkMode
                                  //               //             ? colors.colorBlack
                                  //               //             : colors.colorBlue,
                                  //               //         10,
                                  //               //         FontWeight.w500)),
                                  //               // const SizedBox(
                                  //               //   height: 4,
                                  //               // ),
                                  //               Text(
                                  //                   "Invest ₹ ${convertCurrencyINRStandard(mininv(double.parse(mainstreamipo.mainsme[index].minPrice!).toDouble(), int.parse(mainstreamipo.mainsme[index].minBidQuantity!).toInt()).toInt())}",
                                  //                   style: textStyle(
                                  //                       theme.isDarkMode
                                  //                           ? colors
                                  //                               .colorBlack
                                  //                           : colors
                                  //                               .colorBlue,
                                  //                       12,
                                  //                       FontWeight.w500))
                                  //             ],
                                  //           )),
                                  // Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: [
                                  //     Text("Min Amount",
                                  //         style: textStyle(
                                  //             const Color(0xff666666),
                                  //             10,
                                  //             FontWeight.w500)),
                                  //     const SizedBox(
                                  //       height: 4,
                                  //     ),
                                  //     Text(
                                  //         "₹${convertCurrencyINRStandard(mininv(double.parse(mainstreamipo.mainsme[index].minPrice!).toDouble(), int.parse(mainstreamipo.mainsme[index].minBidQuantity!).toInt()).toInt())}",
                                  //         style: textStyle(
                                  //             theme.isDarkMode
                                  //                 ? colors.colorWhite
                                  //                 : colors.colorBlack,
                                  //             15,
                                  //             FontWeight.w500))
                                  //   ],
                                  // )
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: openIpos.length,
                        separatorBuilder: (context, index) {
                          return 
                          Divider(
                            height: 0,
                              color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider);
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        color: mainstreamipo.mainStreamIpoModel?.msg ==
                                "no IPO found"
                            ? Colors.transparent
                            : theme.isDarkMode
                                ? colors.darkColorDivider
                                : const Color(0xffF1F3F8),
                        height: mainstreamipo.mainStreamIpoModel?.msg ==
                                "no IPO found"
                            ? 0
                            : 7,
                      ),
                      Divider(
                        height: 0,
                          color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,),
                    ],

//Pre-open snippet

                    if (preOpenIpos.isNotEmpty) ...[
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //       left: 16, right: 16, top: 8, bottom: 0),
                      //   child: Text(
                      //     "Pre-open",
                      //     style: textStyle(
                      //         theme.isDarkMode
                      //             ? colors.colorWhite.withOpacity(0.3)
                      //             : colors.colorBlack.withOpacity(0.3),
                      //         16,
                      //         FontWeight.w600),
                      //   ),
                      // ),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              await ipos.getIpoSinglePage(
                                  ipoName: "${preOpenIpos[index].name}");
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  isDismissible: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16))),
                                  context: context,
                                  builder: (context) => Container(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child: MainSmeSinglePage(
                                          pricerange:
                                              "₹${double.parse(preOpenIpos[index].minPrice!).toInt()} - ₹${double.parse(preOpenIpos[index].maxPrice!).toInt()}",
                                          mininv:
                                              "₹${convertCurrencyINRStandard(mininv(double.parse(preOpenIpos[index].minPrice!).toDouble(), int.parse(preOpenIpos[index].minBidQuantity!).toInt()).toInt())}",
                                          enddate:
                                              "${preOpenIpos[index].biddingEndDate}",
                                          startdate:
                                              "${preOpenIpos[index].biddingStartDate}",
                                          ipotype: "${preOpenIpos[index].key}",
                                          ipodetails:
                                              jsonEncode(preOpenIpos[index]),
                                        ),
                                      ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                               CrossAxisAlignment.start,
                                children: [
                                 
                                  
                              
                                    // leading: ClipOval(
                                    //   child: Container(
                                    //     alignment: Alignment.center,
                                    //     color: colors.colorDivider.withOpacity(.3),
                                    //     width: 50,
                                    //     height: 50,
                                    //     child: Container(
                                    //       padding: EdgeInsets.all(8),
                                    //       child: Text(
                                    //         "${mainstreamipo.mainsme[index].name.substring(0, 1)}",
                                    //         style: textStyle(
                                    //             theme.isDarkMode
                                    //                 ? colors.colorWhite.withOpacity(0.3)
                                    //                 : colors.colorBlack.withOpacity(0.3),
                                    //             20,
                                    //             FontWeight.w600),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                     SizedBox(
                                       width: 250,
                                       child: Text(
                                           preOpenIpos[index]
                                               .name
                                               ,
                                           overflow:
                                               TextOverflow.ellipsis,
                                           style: textStyle(
                                               theme.isDarkMode
                                                   ? colors.colorWhite
                                                   : colors.colorBlack,
                                               14,
                                               FontWeight.w600)),
                                     ),
                                     SizedBox(height: 4,),
                                                                      
                                      Container(
                                         padding: const EdgeInsets.symmetric(
                                             horizontal: 8,
                                             vertical: 4),
                                         decoration: BoxDecoration(
                                             color: preOpenIpos[index].key ==
                                                     "SME"
                                                 ? theme.isDarkMode
                                                     ? colors.colorGrey
                                                         .withOpacity(
                                                             .3)
                                                     : const Color.fromARGB(
                                                         255, 243, 242, 174)
                                                 : theme.isDarkMode
                                                     ? colors.colorGrey
                                                         .withOpacity(
                                                             .3)
                                                     : const Color.fromARGB(
                                                         255,
                                                         251,
                                                         215,
                                                         148), //(0xffF1F3F8),
                                             borderRadius:
                                                 BorderRadius.circular(
                                                     4)),
                                         child: Text(
                                             "${preOpenIpos[index].key}",
                                             style: textStyle(const Color(0xff666666), 10, FontWeight.w500))),
                                              SizedBox(height: 8,),
                              
                                     Row(
                                       mainAxisAlignment:
                                           MainAxisAlignment.spaceBetween,
                                       children: [
                                         // open tag ----------
                                                                   
                                         // Container(
                                         //     padding: const EdgeInsets.symmetric(
                                         //         horizontal: 8, vertical: 4),
                                         //     decoration: BoxDecoration(
                                         //         color: theme.isDarkMode
                                         //             ? colors.colorGrey.withOpacity(.1)
                                         //             : const Color(0xffF1F3F8),
                                         //         borderRadius: BorderRadius.circular(4)),
                                         //     child: Text(
                                         //         "${mainstreamipo.mainsme[index].symbol}",
                                         //         style: textStyle(colors.colorGrey, 11,
                                         //             FontWeight.w500))),
                                         // const SizedBox(width: 10),
                                         // Container(
                                         //     padding: const EdgeInsets.symmetric(
                                         //         horizontal: 8, vertical: 4),
                                         //     decoration: BoxDecoration(
                                         //         color: ipostartdate(
                                         //                     "${mainstreamipo.mainsme[index].biddingStartDate}",
                                         //                     "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                         //                 "Open"
                                         //             ? theme.isDarkMode
                                         //                 ? const Color(0xffECF8F1)
                                         //                     .withOpacity(.3)
                                         //                 : const Color(0xffECF8F1)
                                         //             : theme.isDarkMode
                                         //                 ? const Color(0xffFFF6E6)
                                         //                     .withOpacity(.3)
                                         //                 : const Color(0xffFFF6E6),
                                         //         borderRadius:
                                         //             BorderRadius.circular(4)),
                                         //     child: Text(
                                         //         // for text open, closed or upcoming
                                         //         ipostartdate(
                                         //             "${mainstreamipo.mainsme[index].biddingStartDate}",
                                         //             "${mainstreamipo.mainsme[index].biddingEndDate}"),
                                         //         style: textStyle(
                                         //             Color(
                                         //                 ipostartdate("${mainstreamipo.mainsme[index].biddingStartDate}", "${mainstreamipo.mainsme[index].biddingEndDate}") == "Open"
                                         //                     ? 0xff43A833
                                         //                     : 0xffB37702),
                                         //             11,
                                         //             FontWeight.w500)
                                         //             )
                                         //             ),
                                                                   
                                         // Container(
                                         //     margin: const EdgeInsets.symmetric(
                                         //         horizontal: 4),
                                         //         horizontal: 4),
                                         //     padding: const EdgeInsets.symmetric(
                                         //         horizontal: 8, vertical: 4),
                                         //     decoration: BoxDecoration(
                                         //         color:
                                         //             mainstreamipo.mainsme[index].key ==
                                         //                     "SME"
                                         //                 ? theme.isDarkMode
                                         //                     ? colors.colorGrey
                                         //                         .withOpacity(.1)
                                         //                     : const Color.fromARGB(
                                         //                         255, 243, 242, 174)
                                         //                 : theme.isDarkMode
                                         //                     ? colors.colorGrey
                                         //                         .withOpacity(.1)
                                         //                     : const Color.fromARGB(
                                         //                         255,
                                         //                         251,
                                         //                         215,
                                         //                         148), //(0xffF1F3F8),
                                         //         borderRadius: BorderRadius.circular(4)),
                                         //     child: Text(
                                         //         "${mainstreamipo.mainsme[index].key}",
                                         //         style: textStyle(
                                         //             const Color(0xff666666),
                                         //             9,
                                         //             FontWeight.w500))),
                                         // const SizedBox(width: 10),
                                                                   
                                         // time period
                                                                   
                                         Column(
                                           crossAxisAlignment:
                                               CrossAxisAlignment.start,
                                           children: [
                                             Text("Opens on",
                                                 style: textStyle(
                                                     const Color(0xff666666),
                                                     10,
                                                     FontWeight.w500)),
                                             const SizedBox(
                                               height: 4,
                                             ),
                                             Text(
                                                 // "${preOpenIpos[index].biddingEndDate!.substring(5, 11)}",
                                                                   
                                                 // "${preOpenIpos[index].biddingStartDate!.substring(0, 2)} - ${preOpenIpos[index].biddingEndDate!.substring(5, 11)}", 
                                                                   
                                                 formatDate(preOpenIpos[index].biddingStartDate!),
                                                                   
                                                 style: textStyle(
                                                     theme.isDarkMode
                                                         ? colors.colorWhite
                                                         : colors.colorBlack,
                                                     14,
                                                     FontWeight.w500)),
                                           ],
                                         ),
                                                                   
                                         SizedBox(
                                          height: 30,
                                           child: ElevatedButton(
                                             style: ElevatedButton.styleFrom(
                                                 elevation: 0,
                                                 minimumSize: const Size(0, 30),
                                                 padding:
                                                     const EdgeInsets.symmetric(
                                                         horizontal: 14,
                                                         vertical: 5),
                                                 backgroundColor: theme.isDarkMode
                                                     ? colors.colorWhite
                                                     : colors.colorBlack,
                                                 shape: RoundedRectangleBorder(
                                                   borderRadius:
                                                       BorderRadius.circular(50),
                                                 )),
                                             onPressed: () async {
                                               ipos.setisSMEPlaceOrderBtnActiveValue =
                                                   false;
                                               ipos.setisMainIPOPlaceOrderBtnActiveValue =
                                                   false;
                                               await upi.fetchupiIdView(
                                                   upi.bankdetails!
                                                       .dATA![upi.indexss][1],
                                                   upi.bankdetails!
                                                       .dATA![upi.indexss][2]);
                                               preOpenIpos[index].key == "SME"
                                                   ? await ref
                                                       .read(ipoProvide)
                                                       .smeipocategory()
                                                   : await ref
                                                       .read(ipoProvide)
                                                       .mainipocategory();
                                                                     
                                               preOpenIpos[index].key == "SME"
                                                   ? Navigator.pushNamed(
                                                       context,
                                                       Routes.smeapplyIPO,
                                                       arguments:
                                                           preOpenIpos[index],
                                                     )
                                                   : Navigator.pushNamed(
                                                       context, Routes.applyIPO,
                                                       arguments:
                                                           preOpenIpos[index]);
                                             },
                                             child: ipos.loading
                                                 ? const SizedBox(
                                                     width: 18,
                                                     height: 20,
                                                     child:
                                                         CircularProgressIndicator(
                                                             strokeWidth: 2,
                                                             color: Color(
                                                                 0xff666666)),
                                                   )
                                                 : Text(
                                                     'Pre Apply',
                                                     style: textStyle(
                                                         theme.isDarkMode
                                                             ? colors.colorBlack
                                                             : colors.colorWhite,
                                                         12,
                                                         FontWeight.w500),
                                                   ),
                                                                     
                                             // ipostartdate(
                                             //               "${mainstreamipo.mainsme[index].biddingStartDate}",
                                             //               "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                             //           "Open"
                                             //       ? "Apply"
                                             //       : "Pre Apply"
                                           ),
                                         )
                                         // ipostartdate(
                                         //             "${mainstreamipo.mainsme[index].biddingStartDate}",
                                         //             "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                         //         "Open"
                                         //     ? Text(
                                         //         "Left ${mainstreamipo.mainsme[index]!.days_to_end_ipo} days"
                                         //             .toString(),
                                         //         style: textStyle(
                                         //             const Color(0xff666666),
                                         //             11,
                                         //             FontWeight.w500))
                                         //     : Container()
                                       ],
                                     ),
                                  
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: preOpenIpos.length,
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 0,
                              color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,);
                        },
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(top: 8),
                      //   color: mainstreamipo.mainStreamIpoModel?.msg ==
                      //           "no IPO found"
                      //       ? Colors.transparent
                      //       : theme.isDarkMode
                      //           ? colors.darkColorDivider
                      //           : const Color(0xffF1F3F8),
                      //   height: mainstreamipo.mainStreamIpoModel?.msg ==
                      //           "no IPO found"
                      //       ? 0
                      //       : 7,
                      // ),

                     Divider(
                      height: 0,
                         color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                    ],

                    if (ipos.ipoPreClose!.msg.isNotEmpty) ...[
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //       left: 16, right: 16, top: 8, bottom: 0),
                      //   child: Text(
                      //     "Closed",
                      //     style: textStyle(
                      //         theme.isDarkMode
                      //             ? colors.colorWhite.withOpacity(0.3)
                      //             : colors.colorBlack.withOpacity(0.3),
                      //         16,
                      //         FontWeight.w600),
                      //   ),
                      // ),
                      ClosedIPOScreen(),
                    ],

                    SizedBox(height: 24,)
                  ]),
            );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}
