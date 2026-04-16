// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_model/all_bonds_list_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/mobile/bonds/bonds_order_screen/orderscreenbottompage.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class BondsListScreen extends StatelessWidget {
  const BondsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final bonds = ref.watch(bondsProvider);
      // final mainstreamipo = ref.watch(ipoProvide);
      List<BondsList>? bondsList = bonds.bondsList;
      // final upi = ref.watch(transcationProvider);
      final theme = ref.watch(themeProvider);
      final dev_height = MediaQuery.of(context).size.height;
      return bondsList!.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 225),
                child: Container(
                  height: dev_height - 140,
                  child: const Column(
                    children: [
                      NoDataFound(),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {},
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(bondsList[index].name!,
                                        overflow: TextOverflow.ellipsis,
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            15,
                                            FontWeight.w600)),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    CustomExchBadge(
                                        exch: bondsList[index].symbol!),
                                    const SizedBox(width: 10),
                                    Text(
                                        "${bondsList[index].biddingStartDate!.substring(0, 2)} - ${bondsList[index].biddingEndDate!.substring(5, 11)}",
                                        style: textStyle(
                                            const Color(0xff666666),
                                            11,
                                            FontWeight.w500)),
                                    const SizedBox(
                                      width: 20,
                                    ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Lot size",
                                          style: textStyle(
                                              const Color(0xff666666),
                                              10,
                                              FontWeight.w500)),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                          "${(convertCurrencyINRStandard(double.parse(bondsList[index].issueSize!) / 10000000))} Cr.",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              15,
                                              FontWeight.w500)),
                                    ],
                                  ),
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
                                      // Navigator.pushNamed(context,Routes.bondsPlaceOrder,arguments: bondsList[index]);
                                      await bonds.fetchLedgerBal();
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
                                          child: BondOrderScreenbottomPage(
                                            bondInfo: bondsList[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: bonds.loading
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
                                              Text(
                                                  "Invest ₹ ${convertCurrencyINRStandard(int.parse(bondsList[index].minBidQuantity!))}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorBlack
                                                          : colors.colorBlue,
                                                      15,
                                                      FontWeight.w500))
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: bondsList.length,
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 7,
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : const Color(0xffF1F3F8),
                      );
                    },
                  ),
                  //  const Spacer(),
                  // companyInfoWidget(context,true),
                ],
              ),
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

  // Widget companyInfoWidget(BuildContext context,bool setHeight) {
  //   return
  //       // Align(
  //       // alignment: Alignment.bottomCenter,
  //       // child:
  //       Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //     // height: 300,
  //     width: MediaQuery.of(context).size.width,
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Color(0xFFFFFFFF), // #FFFFFF at 0%
  //           Color(0xFFF1F3F8), // #F1F3F8 at 100%
  //         ],
  //         begin: Alignment.topCenter,
  //         end: Alignment.bottomCenter,
  //       ),
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //          SizedBox(height: setHeight? MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * (75/100) : 10),
  //         SvgPicture.asset("assets/icon/zebulogo.svg",
  //             color: colors.logoColor,
  //             // height: 50,
  //             width: 100,
  //             fit: BoxFit.contain),
  //         const SizedBox(height: 16),
  //         const Text(
  //           "NSE : 13179 | BSE : 6550 | MCX : 55730 | CDSL: 12080400",
  //           style: TextStyle(
  //             color: Color(0xff666666),
  //             fontSize: 10,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         const Text(
  //           "SEBI Registration No : INZ00174634 | AMFI ARN: 113118",
  //           style: TextStyle(
  //             color: Color(0xff666666),
  //             fontSize: 10,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         const Text(
  //           "Research Analyst : INH200006044",
  //           style: TextStyle(
  //             color: Color(0xff666666),
  //             fontSize: 10,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  //   // );
  // }
}
