// ignore_for_file: deprecated_member_use

//import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/ipo_model/ipo_pre_close_model.dart';
import 'package:mynt_plus/screens/ipo/main_sme_list/single_page.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class ClosedIPOScreen extends StatefulWidget {
  const ClosedIPOScreen({super.key});

  @override
  State<ClosedIPOScreen> createState() => _ClosedIPOScreenState();
}

class _ClosedIPOScreenState extends State<ClosedIPOScreen> {
  late List<Msg> ipoList;
  List<int> years = [];
  int? selectedYear;
  bool showAll = false;

  @override
  void initState() {
    ipoList = context.read(ipoProvide).ipoPreClose!.msg;
    context.read(ipoProvide).sortpreCloseIPOListByDate(ipoList);
    super.initState();
    var currentYear = DateTime.now().year;
    for (var year = 2000; year <= currentYear; year++) {
      years.add(year);
    }
    selectedYear = years.last;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final preClose = watch(ipoProvide);
      final theme = watch(themeProvider);
      final devHeight = MediaQuery.of(context).size.height;
      // final internet = watch(networkStateProvider);
      // final market = watch(marketWatchProvider);

      return SingleChildScrollView(
        // child: Expanded(
          // child: Container(
            // height: preClose.ipoPreClose!.msg.isNotEmpty
            //     ? devHeight
            //     : devHeight - 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // const SizedBox(
                //   height: 10,
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         children: [
                //           Expanded(
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text("IPO Performance $selectedYear",
                //                     style: textStyle(const Color(0xff000000), 18,
                //                         FontWeight.w600)),
                //                 const SizedBox(height: 2),
                //                 Text(
                //                     "Monitor the IPO Performance of Mainline IPO Stocks listed at BSE and NSE",
                //                     style: textStyle(const Color(0xff666666), 14,
                //                         FontWeight.w500)),
                //                 const SizedBox(height: 10),
                //               ],
                //             ),
                //           )
                //         ],
                //       ),
                //       SizedBox(
                //         height: 40,
                //         child: TextField(
                //           controller: perfomance.performancesearchcontroller,
                //           style: textStyle(
                //               theme.isDarkMode
                //                   ? colors.colorWhite
                //                   : colors.colorBlack,
                //               15,
                //               FontWeight.w500),
                //           decoration: InputDecoration(
                //               fillColor: theme.isDarkMode
                //                   ? const Color(0xffB5C0CF).withOpacity(.15)
                //                   : const Color(0xffF1F3F8),
                //               filled: true,
                //               hintStyle: textStyle(
                //                   theme.isDarkMode
                //                       ? colors.colorWhite
                //                       : colors.colorBlack,
                //                   14,
                //                   FontWeight.w500),
                //               prefixIconColor: const Color(0xff586279),
                //               prefixIcon: Padding(
                //                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
                //                 child: SvgPicture.asset(assets.searchIcon,
                //                     color: const Color(0xff586279),
                //                     fit: BoxFit.contain,
                //                     width: 15),
                //               ),
                //               suffixIcon: InkWell(
                //                 onTap: () async {
                //                   perfomance.clearPerformanceSearch();
                //                 },
                //                 child: Padding(
                //                   padding:
                //                       const EdgeInsets.symmetric(horizontal: 20.0),
                //                   child: perfomance
                //                           .performancesearchcontroller.text.isEmpty
                //                       ? null
                //                       : SvgPicture.asset(assets.removeIcon,
                //                           fit: BoxFit.scaleDown, width: 20),
                //                 ),
                //               ),
                //               enabledBorder: OutlineInputBorder(
                //                   borderSide: BorderSide.none,
                //                   borderRadius: BorderRadius.circular(30)),
                //               disabledBorder: InputBorder.none,
                //               focusedBorder: OutlineInputBorder(
                //                   borderSide: BorderSide.none,
                //                   borderRadius: BorderRadius.circular(30)),
                //               hintText: "Search company",
                //               contentPadding: const EdgeInsets.all(14),
                //               border: OutlineInputBorder(
                //                   borderSide: BorderSide.none,
                //                   borderRadius: BorderRadius.circular(30))),
                //           onChanged: (value) {
                //             perfomance.searchperformance(value, context);
                //             if (value.isEmpty) {
                //               perfomance.clearPerformanceSearch();
                //             }
                //             if (internet.connectionStatus !=
                //                 ConnectivityResult.none) {
                //               perfomance.searchperformance(value, context);
                //             }
                //           },
                //         ),
                //       ),
                //       const SizedBox(width: 10),
                //     ],
                //   ),
                // ),
          
                preClose.ipoPreClose!.msg.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListView.separated(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemBuilder: (context, index) {
                              final ipo = ipoList[index];
                              // var ipofun = 0;
                              return InkWell(
                                onTap: () async {
                                  await preClose.getIpoSinglePage(
                                      ipoName:
                                          "${preClose.ipoPreClose!.msg[index].companyName}");
          
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
                                                  "₹${preClose.ipoPreClose!.msg[index].priceRange!}",
                                              // "₹${(double.parse(preClose.ipoPreClose!.msg[index].minPrice!).toInt()).toString()}- ₹${double.parse(preClose.ipoPreClose!.msg[index].maxPrice!).toInt()}",
                                              mininv:
                                                  "₹${convertCurrencyINRStandard(mininv(preClose.ipoPreClose!.msg[index].minPrice!.toDouble(), preClose.ipoPreClose!.msg[index].minBidQu!.toInt()).toInt())}",
                                              enddate: convertClosedIpoDates(
                                                  preClose.ipoPreClose!.msg[index]
                                                      .iPOEndDate!,
                                                  "MMM dd, yyyy",
                                                  "EEE, dd MMM yyyy HH:mm:ss"),
                                              startdate: convertClosedIpoDates(
                                                  preClose.ipoPreClose!.msg[index]
                                                      .iPOStartDate!,
                                                  "MMM dd, yyyy",
                                                  "dd-MM-yyyy"),
                                              ipotype:
                                                  "${preClose.ipoPreClose!.msg[index].ipoType}",
                                              ipodetails: "")));
                                },
                                child: Column(
                                  children: [
                                    ListTile(
                                        // leading: ClipOval(
                                        //   child: Container(
                                        //     color:
                                        //         colors.colorDivider.withOpacity(.3),
                                        //     width: 50,
                                        //     height: 50,
                                        //     child: Container(
                                        //       padding: EdgeInsets.all(8),
                                        //       child: Image.network(
                                        //         context
                                        //                 .read(ipoProvide)
                                        //                 .api
                                        //                 .apiLinks
                                        //                 .ipourlendpoint +
                                        //             ipo.imageLink.toString(),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        title: Row(children: [
                                          Expanded(
                                            child: Text(
                                                ipo.companyName!
                                                    .split(" ")
                                                    .map((word) => word.isNotEmpty
                                                        ? word[0].toUpperCase() +
                                                            word
                                                                .substring(1)
                                                                .toLowerCase()
                                                        : "")
                                                    .join(" "),
                                                overflow: TextOverflow.ellipsis,
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    15,
                                                    FontWeight.w600)),
                                          ),
                                          Container(
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: ipo.ipoType == "SME"
                                                      ? theme.isDarkMode
                                                          ? colors.colorGrey
                                                              .withOpacity(.1)
                                                          : const Color.fromARGB(
                                                              255, 243, 242, 174)
                                                      : theme.isDarkMode
                                                          ? colors.colorGrey
                                                              .withOpacity(.1)
                                                          : const Color.fromARGB(
                                                              255,
                                                              251,
                                                              215,
                                                              148), //(0xffF1F3F8),
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Text("${ipo.ipoType}",
                                                  style: textStyle(
                                                      const Color(0xff666666),
                                                      9,
                                                      FontWeight.w500))),
                                        ]),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 9),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              // Container(
                                              //   margin: const EdgeInsets.symmetric(
                                              //       horizontal: 4),
                                              //   padding: const EdgeInsets.symmetric(
                                              //       horizontal: 8, vertical: 4),
                                              //   decoration: BoxDecoration(
                                              //       color: ipo.ipoType != "MAIN_IPO"
                                              //           ? theme.isDarkMode
                                              //               ? colors.colorGrey
                                              //                   .withOpacity(.1)
                                              //               : const Color.fromARGB(
                                              //                   255, 251, 215, 148)
                                              //           : theme.isDarkMode
                                              //               ? colors.colorGrey
                                              //                   .withOpacity(.1)
                                              //               : const Color.fromARGB(
                                              //                   255,
                                              //                   243,
                                              //                   242,
                                              //                   174), //(0xffF1F3F8),
                                              //       borderRadius:
                                              //           BorderRadius.circular(4)),
                                              //   child: Text(
                                              //     ipo.ipoType != "MAIN_IPO"
                                              //         ? 'MAIN'
                                              //         : 'SME',
                                              //     style: textStyle(
                                              //         const Color(0xff666666),
                                              //         9,
                                              //         FontWeight.w500),
                                              //   ),
                                              // ),
                                              Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: theme.isDarkMode
                                                          ? const Color(
                                                                  0xffFFF6E6)
                                                              .withOpacity(.3)
                                                          : const Color(
                                                              0xffFFF6E6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                  child: Text("Close",
                                                      style: textStyle(
                                                          const Color(0xffB37702),
                                                          11,
                                                          FontWeight.w500))),
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 1),
                                                child: Text(
                                                    "Listing on ${ipo.listingDate!.substring(4, 6)} ${ipo.listingDate!.substring(0, 3)}",
                                                    style: textStyle(
                                                        const Color(0xff666666),
                                                        11,
                                                        FontWeight.w500)),
                                              ),
                                            ],
                                          ),
                                        )),
                                    Divider(
                                        color: theme.isDarkMode
                                            ? colors.darkColorDivider
                                            : const Color(0xffECEDEE)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical:
                                              16), //.fromLTRB(16, 2, 16, 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Price Range",
                                                  style: GoogleFonts.inter(
                                                      textStyle: textStyle(
                                                          const Color(0xff666666),
                                                          10,
                                                          FontWeight.w500))),
                                              const SizedBox(height: 4),
                                              Text("₹ ${ipo.priceRange}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      15,
                                                      FontWeight.w500)),
                                            ],
                                          ),
          
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Min Amount",
                                                  style: textStyle(
                                                      const Color(0xff666666),
                                                      10,
                                                      FontWeight.w500)),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                  "₹ ${convertCurrencyINRStandard(mininv(ipo.minPrice!.toDouble(), ipo.minBidQu!.toInt()).toInt())}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      15,
                                                      FontWeight.w500))
                                            ],
                                          ),
          
                                          // Column(
                                          //   crossAxisAlignment:
                                          //       CrossAxisAlignment.start,
                                          //   children: [
                                          //     Text("Price range",
                                          //         style: textStyle(
                                          //             const Color(0xff666666),
                                          //             13,
                                          //             FontWeight.w500)),
                                          //     const SizedBox(height: 4),
                                          //     Text("₹ ${ipo.priceRange}",
                                          //         style: textStyle(
                                          //             theme.isDarkMode
                                          //                 ? colors.colorWhite
                                          //                 : colors.colorBlack,
                                          //             15,
                                          //             FontWeight.w500)),
                                          //   ],
                                          // ),
                                          // Column(
                                          //   crossAxisAlignment:
                                          //       CrossAxisAlignment.start,
                                          //   children: [
                                          //     Text("Gain/Loss",
                                          //         style: GoogleFonts.inter(
                                          //             textStyle: textStyle(
                                          //                 const Color(0xff666666),
                                          //                 13,
                                          //                 FontWeight.w500))),
                                          //     const SizedBox(height: 4),
                                          //     Text("₹${ipo.listingGain}",
                                          //         style: textStyle(
                                          //             perfomance
                                          //                     .ipoPerformanceModel!
                                          //                     .data![index]
                                          //                     .listingGain!
                                          //                     .toStringAsFixed(2)
                                          //                     .startsWith("-")
                                          //                 ? colors.darkred
                                          //                 : colors.ltpgreen,
                                          //             15,
                                          //             FontWeight.w500)),
                                          //   ],
                                          // ),
                                          // Column(
                                          //   crossAxisAlignment:
                                          //       CrossAxisAlignment.start,
                                          //   children: [
                                          //     Text("Lisiting Gain",
                                          //         style: textStyle(
                                          //             const Color(0xff666666),
                                          //             13,
                                          //             FontWeight.w500)),
                                          //     const SizedBox(height: 4),
                                          //     Text("${ipo.listingGainPer}%",
                                          //         style: textStyle(
                                          //             perfomance
                                          //                     .ipoPerformanceModel!
                                          //                     .data![index]
                                          //                     .listingGainPer!
                                          //                     .toStringAsFixed(2)
                                          //                     .startsWith("-")
                                          //                 ? colors.darkred
                                          //                 : colors.ltpgreen,
                                          //             15,
                                          //             FontWeight.w500)),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Container(
                                height: 7,
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : const Color(0xffF1F3F8),
                              );
                            },
                            itemCount: showAll
                                ? ipoList.length
                                : ipoList.length < 5
                                    ? ipoList.length
                                    : 5),
                      )
                    :
                    //  ListView.separated(
                    //     shrinkWrap: true,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     itemBuilder: (context, index) {
                    //       return Column(
                    //         children: [
                    //           ListTile(
                    //               leading: ClipOval(
                    //                 child: Container(
                    //                   color: colors.colorDivider.withOpacity(.3),
                    //                   width: 50,
                    //                   height: 50,
                    //                   child: Container(
                    //                     padding: const EdgeInsets.all(8),
                    //                     child: Image.network(
                    //                       ipoList
                    //                           .performancesearch![index].imageLink
                    //                           .toString(),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //               title: Text(
                    //                   "${perfomance.performancesearch![index].companyName}",
                    //                   style: textStyle(
                    //                       theme.isDarkMode
                    //                           ? colors.colorWhite
                    //                           : colors.colorBlack,
                    //                       15,
                    //                       FontWeight.w600)),
                    //               subtitle: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   const SizedBox(height: 8),
                    //                   Text(
                    //                       "Listing on : ${perfomance.performancesearch![index].listedDate}",
                    //                       style: textStyle(Color(0xff666666), 13,
                    //                           FontWeight.w500)),
                    //                 ],
                    //               )),
                    //           Divider(
                    //               color: theme.isDarkMode
                    //                   ? colors.darkColorDivider
                    //                   : const Color(0xffECEDEE)),
                    //           Padding(
                    //             padding:
                    //                 const EdgeInsets.fromLTRB(16.0, 12, 16, 14),
                    //             child: Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceBetween,
                    //               children: [
                    //                 Column(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.start,
                    //                   children: [
                    //                     Text("Issue Price",
                    //                         style: GoogleFonts.inter(
                    //                             textStyle: textStyle(
                    //                                 const Color(0xff666666),
                    //                                 13,
                    //                                 FontWeight.w500))),
                    //                     const SizedBox(height: 4),
                    //                     Text(
                    //                         "₹${perfomance.performancesearch![index].priceRange}",
                    //                         style: textStyle(
                    //                             theme.isDarkMode
                    //                                 ? colors.colorWhite
                    //                                 : colors.colorBlack,
                    //                             15,
                    //                             FontWeight.w500)),
                    //                   ],
                    //                 ),
                    //                 Column(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.start,
                    //                   children: [
                    //                     Text("Close Price",
                    //                         style: textStyle(
                    //                             const Color(0xff666666),
                    //                             13,
                    //                             FontWeight.w500)),
                    //                     const SizedBox(height: 4),
                    //                     Text(
                    //                         "₹ ${perfomance.performancesearch![index].clsPric}",
                    //                         style: textStyle(
                    //                             theme.isDarkMode
                    //                                 ? colors.colorWhite
                    //                                 : colors.colorBlack,
                    //                             15,
                    //                             FontWeight.w500)),
                    //                   ],
                    //                 ),
                    //                 Column(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.start,
                    //                   children: [
                    //                     Text("Gain/Loss",
                    //                         style: GoogleFonts.inter(
                    //                             textStyle: textStyle(
                    //                                 const Color(0xff666666),
                    //                                 13,
                    //                                 FontWeight.w500))),
                    //                     const SizedBox(height: 4),
                    //                     Text(
                    //                         "₹${perfomance.performancesearch![index].listingGain}",
                    //                         style: textStyle(
                    //                             perfomance
                    //                                     .performancesearch![index]
                    //                                     .listingGain!
                    //                                     .toStringAsFixed(2)
                    //                                     .startsWith("-")
                    //                                 ? colors.darkred
                    //                                 : colors.ltpgreen,
                    //                             15,
                    //                             FontWeight.w500)),
                    //                   ],
                    //                 ),
                    //                 Column(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.start,
                    //                   children: [
                    //                     Text("Lisiting Gain",
                    //                         style: textStyle(
                    //                             const Color(0xff666666),
                    //                             13,
                    //                             FontWeight.w500)),
                    //                     const SizedBox(height: 4),
                    //                     Text(
                    //                         "${perfomance.performancesearch![index].listingGainPer}%",
                    //                         style: textStyle(
                    //                             perfomance
                    //                                     .performancesearch![index]
                    //                                     .listingGainPer!
                    //                                     .toStringAsFixed(2)
                    //                                     .startsWith("-")
                    //                                 ? colors.darkred
                    //                                 : colors.ltpgreen,
                    //                             15,
                    //                             FontWeight.w500)),
                    //                   ],
                    //                 ),
                    //               ],
                    //             ),
                    //           )
                    //         ],
                    //       );
                    //     },
                    //     separatorBuilder: (context, index) {
                    //       return Container(
                    //         height: 10,
                    //         color: theme.isDarkMode
                    //             ? colors.darkColorDivider
                    //             : const Color(0xffF1F3F8),
                    //       );
                    //     },
                    //     itemCount: perfomance.performancesearch!.length),
                    // perfomance.performancesearch!.isEmpty ||
                    //         perfomance.ipoPerformanceModel!.emsg == "no data"
                    //     ? Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: 16.0, vertical: 10),
                    //         child: CustomTextBtn(
                    //           icon: assets.downArrow,
                    //           label: showAll ? "See less IPOs" : "See more IPOs",
                    //           onPress: () {
                    //             setState(() {
                    //               showAll = !showAll;
                    //             });
                    //           },
                    //         ),
                    //       )
                    //     :
                    Container(
                        height: devHeight - 600,
                        child: const Center(child: NoDataFound())),
          
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    // height: 300,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF), // #FFFFFF at 0%
                          Color(0xFFF1F3F8), // #F1F3F8 at 100%
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 70),
                        SvgPicture.asset("assets/icon/zebulogo.svg",
                            color: colors.logoColor,
                            // height: 50,
                            width: 100,
                            fit: BoxFit.contain),
                        const SizedBox(height: 16),
                        const Text(
                          "NSE : 13179 | BSE : 6550 | MCX : 55730 | CDSL: 12080400",
                          style: TextStyle(
                            color: Color(0xff666666),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "SEBI Registration No : INZ00174634 | AMFI ARN: 113118",
                          style: TextStyle(
                            color: Color(0xff666666),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Research Analyst : INH200006044",
                          style: TextStyle(
                            color: Color(0xff666666),
                            fontSize: 10,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          // ),
        // ),
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
