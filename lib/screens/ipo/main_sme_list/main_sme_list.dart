// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:ffi' hide Size;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/assets.dart';
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
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ipos = watch(ipoProvide);
      final mainstreamipo = watch(ipoProvide);
      final upi = watch(transcationProvider);
      final theme = watch(themeProvider);
      final dev_height = MediaQuery.of(context).size.height;
      return mainstreamipo.mainsme.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 225),
              child: Container(
                height: dev_height - 140,
                child: Column(
                  children: [
                    NoDataFound(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
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
              ),
            )
          : SingleChildScrollView(
              child: Column(children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        print(
                            "::::::::::::::::::::::::::::::::::${mainstreamipo.mainsme[index].name}");
                        await ipos.getIpoSinglePage(
                            ipoName: "${mainstreamipo.mainsme[index].name}");
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
                                        "₹${double.parse(mainstreamipo.mainsme[index].minPrice!).toInt()} - ₹${double.parse(mainstreamipo.mainsme[index].maxPrice!).toInt()}",
                                    mininv:
                                        "₹${convertCurrencyINRStandard(mininv(double.parse(mainstreamipo.mainsme[index].minPrice!).toDouble(), int.parse(mainstreamipo.mainsme[index].minBidQuantity!).toInt()).toInt())}",
                                    enddate:
                                        "${mainstreamipo.mainsme[index].biddingEndDate}",
                                    startdate:
                                        "${mainstreamipo.mainsme[index].biddingStartDate}",
                                    ipotype:
                                        "${mainstreamipo.mainsme[index].key}",
                                    ipodetails: jsonEncode(
                                        mainstreamipo.mainsme[index]),
                                  ),
                                ));
                      },
                      child: Column(
                        children: [
                          ListTile(
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                      mainstreamipo.mainsme[index].name
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
                                        color:
                                            mainstreamipo.mainsme[index].key ==
                                                    "SME"
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
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                        "${mainstreamipo.mainsme[index].key}",
                                        style: textStyle(
                                            const Color(0xff666666),
                                            9,
                                            FontWeight.w500))),
                                // Container(
                                //       padding: const EdgeInsets.symmetric(
                                //           horizontal: 8, vertical: 4),
                                //       decoration: BoxDecoration(
                                //           color: ipostartdate(
                                //                       "${mainstreamipo.mainsme[index].biddingStartDate}",
                                //                       "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                //                   "Open"
                                //               ? theme.isDarkMode
                                //                   ? const Color(0xffECF8F1)
                                //                       .withOpacity(.3)
                                //                   : const Color(0xffECF8F1)
                                //               : theme.isDarkMode
                                //                   ? const Color(0xffFFF6E6)
                                //                       .withOpacity(.3)
                                //                   : const Color(0xffFFF6E6),
                                //           borderRadius: BorderRadius.circular(4)),
                                //       child: Text( // for text open, closed or upcoming
                                //           ipostartdate(
                                //               "${mainstreamipo.mainsme[index].biddingStartDate}",
                                //               "${mainstreamipo.mainsme[index].biddingEndDate}"),
                                //           style: textStyle(
                                //               Color(ipostartdate("${mainstreamipo.mainsme[index].biddingStartDate}", "${mainstreamipo.mainsme[index].biddingEndDate}") == "Open" ? 0xff43A833 : 0xffB37702),
                                //               11,
                                //               FontWeight.w500))),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
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
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: ipostartdate(
                                                      "${mainstreamipo.mainsme[index].biddingStartDate}",
                                                      "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                                  "Open"
                                              ? theme.isDarkMode
                                                  ? const Color(0xffECF8F1)
                                                      .withOpacity(.3)
                                                  : const Color(0xffECF8F1)
                                              : theme.isDarkMode
                                                  ? const Color(0xffFFF6E6)
                                                      .withOpacity(.3)
                                                  : const Color(0xffFFF6E6),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(
                                          // for text open, closed or upcoming
                                          ipostartdate(
                                              "${mainstreamipo.mainsme[index].biddingStartDate}",
                                              "${mainstreamipo.mainsme[index].biddingEndDate}"),
                                          style: textStyle(
                                              Color(ipostartdate("${mainstreamipo.mainsme[index].biddingStartDate}", "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                                      "Open"
                                                  ? 0xff43A833
                                                  : 0xffB37702),
                                              11,
                                              FontWeight.w500))),
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
                                  const SizedBox(width: 10),
                                  Text(
                                      "${mainstreamipo.mainsme[index].biddingStartDate!.substring(0, 2)} - ${mainstreamipo.mainsme[index].biddingEndDate!.substring(5, 11)}",
                                      style: textStyle(const Color(0xff666666),
                                          11, FontWeight.w500)),

                                  const SizedBox(
                                    width: 20,
                                  ),
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
                            ),
                          ),
                          Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 2, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Price Range",
                                        style: textStyle(
                                            const Color(0xff666666),
                                            10,
                                            FontWeight.w500)),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                        "₹ ${double.parse(mainstreamipo.mainsme[index].minPrice!).toInt()} - ₹ ${double.parse(mainstreamipo.mainsme[index].maxPrice!).toInt()}",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            15,
                                            FontWeight.w500)),
                                  ],
                                ),
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
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        fixedSize: const Size(170, 30),
                                        elevation: 0,
                                        backgroundColor: theme.isDarkMode
                                            ? colors.colorbluegrey
                                            : const Color(0xffF1F3F8),
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
                                          upi.bankdetails!.dATA![upi.indexss]
                                              [1],
                                          upi.bankdetails!.dATA![upi.indexss]
                                              [2]);
                                      mainstreamipo.mainsme[index].key == "SME"
                                          ? await context
                                              .read(ipoProvide)
                                              .smeipocategory()
                                          : await context
                                              .read(ipoProvide)
                                              .mainipocategory();

                                      mainstreamipo.mainsme[index].key == "SME"
                                          ? Navigator.pushNamed(
                                              context,
                                              Routes.smeapplyIPO,
                                              arguments: ipos.mainsme[index],
                                            )
                                          : Navigator.pushNamed(
                                              context, Routes.applyIPO,
                                              arguments: ipos.mainsme[index]);
                                    },
                                    child: ipos.loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xff666666)),
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Text("Invest",
                                              //     style: textStyle(
                                              //         theme.isDarkMode
                                              //             ? colors.colorBlack
                                              //             : colors.colorBlue,
                                              //         10,
                                              //         FontWeight.w500)),
                                              // const SizedBox(
                                              //   height: 4,
                                              // ),
                                              Text(
                                                  "Invest ₹ ${convertCurrencyINRStandard(mininv(double.parse(mainstreamipo.mainsme[index].minPrice!).toDouble(), int.parse(mainstreamipo.mainsme[index].minBidQuantity!).toInt()).toInt())}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorBlack
                                                          : colors.colorBlue,
                                                      15,
                                                      FontWeight.w500))
                                            ],
                                          )),
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
                              ],
                            ),
                          ),
                          // Container(
                          //   margin: const EdgeInsets.symmetric(horizontal: 10),
                          //   width: MediaQuery.of(context).size.width,
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //         elevation: 0,
                          //         backgroundColor: theme.isDarkMode
                          //             ? colors.colorbluegrey
                          //             : const Color(0xffF1F3F8),
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(50),
                          //         )),
                          //     onPressed: () async {
                          //       ipos.setisSMEPlaceOrderBtnActiveValue = false;
                          //       ipos.setisMainIPOPlaceOrderBtnActiveValue =
                          //           false;
                          //       await upi.fetchupiIdView(
                          //           upi.bankdetails!.dATA![upi.indexss][1],
                          //           upi.bankdetails!.dATA![upi.indexss][2]);
                          //       mainstreamipo.mainsme[index].key == "SME"
                          //           ? await context
                          //               .read(ipoProvide)
                          //               .smeipocategory()
                          //           : await context
                          //               .read(ipoProvide)
                          //               .mainipocategory();

                          //       mainstreamipo.mainsme[index].key == "SME"
                          //           ? Navigator.pushNamed(
                          //               context,
                          //               Routes.smeapplyIPO,
                          //               arguments: ipos.mainsme[index],
                          //             )
                          //           : Navigator.pushNamed(
                          //               context, Routes.applyIPO,
                          //               arguments: ipos.mainsme[index]);
                          //     },
                          //     child: ipos.loading
                          //         ? const SizedBox(
                          //             width: 18,
                          //             height: 20,
                          //             child: CircularProgressIndicator(
                          //                 strokeWidth: 2,
                          //                 color: Color(0xff666666)),
                          //           )
                          //         : Text(
                          //             ipostartdate(
                          //                         "${mainstreamipo.mainsme[index].biddingStartDate}",
                          //                         "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                          //                     "Open"
                          //                 ? "Apply"
                          //                 : "Pre Apply",
                          //             style: textStyle(
                          //                 theme.isDarkMode
                          //                     ? colors.colorBlack
                          //                     : colors.colorBlue,
                          //                 13,
                          //                 FontWeight.w600),
                          //           ),
                          //   ),
                          // )
                        ],
                      ),
                    );
                  },
                  itemCount: mainstreamipo.mainsme.length,
                  separatorBuilder: (context, index) {
                    return Container(
                      height: 7,
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : const Color(0xffF1F3F8),
                    );
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 8),
                  color: mainstreamipo.mainStreamIpoModel?.msg == "no IPO found"
                      ? Colors.transparent
                      : theme.isDarkMode
                          ? colors.darkColorDivider
                          : const Color(0xffF1F3F8),
                  height:
                      mainstreamipo.mainStreamIpoModel?.msg == "no IPO found"
                          ? 0
                          : 7,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
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
