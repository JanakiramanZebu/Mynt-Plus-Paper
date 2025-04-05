// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_model/all_bonds_list_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/bonds/bonds_order_screen/orderscreenbottompage.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class TreasuryBondsScreen extends StatelessWidget {
  const TreasuryBondsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final bonds = watch(bondsProvider);
      final theme = watch(themeProvider);
      final dev_height = MediaQuery.of(context).size.height;
      return bonds.treasuryBonds!.ncbTBill!.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListView.separated(
                  padding: EdgeInsets.only(bottom: 0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
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
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: BondOrderScreenbottomPage(
                              bondInfo: bonds.treasuryBonds!.ncbTBill![index],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      child: Text(
                                          bonds.treasuryBonds!.ncbTBill![index]
                                              .name!,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              15,
                                              FontWeight.w600)),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: theme.isDarkMode
                                                ? colors.colorGrey
                                                    .withOpacity(.3)
                                                : const Color.fromARGB(
                                                    118, 251, 215, 148),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Text("T-Bill",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                10,
                                                FontWeight.w500))),
                                  ],
                                ),
                                bonds.treasuryBonds!.ncbTBill![index].yield !=
                                        ''
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${bonds.treasuryBonds!.ncbTBill![index].yield}',
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  14,
                                                  FontWeight.w500)),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text("Indicate Yield",
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  10,
                                                  FontWeight.w500)),
                                        ],
                                      )
                                    : SizedBox()
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Column(
                                //   crossAxisAlignment:
                                //       CrossAxisAlignment.start,
                                //   children: [
                                //     Text("Lot size",
                                //         style: textStyle(
                                //             const Color(0xff666666),
                                //             10,
                                //             FontWeight.w500)),
                                //     const SizedBox(
                                //       height: 4,
                                //     ),
                                //     Text(
                                //         "${(convertCurrencyINRStandard(double.parse(bonds.treasuryBonds!.ncbTBill![index].issueSize!) / 10000000))} Cr.",
                                //         style: textStyle(
                                //             theme.isDarkMode
                                //                 ? colors.colorWhite
                                //                 : colors.colorBlack,
                                //             15,
                                //             FontWeight.w500)),
                                //   ],
                                // ),

                                // Text(
                                //      "${bonds.treasuryBonds!.ncbTBill![index].biddingStartDate!.substring(0, 2)} - ${bonds.treasuryBonds!.ncbTBill![index].biddingEndDate!.substring(5, 11)}",
                                //      style: textStyle(
                                //          const Color(0xff666666),
                                //          11,
                                //          FontWeight.w500)),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        '${bonds.treasuryBonds!.ncbTBill![index].biddingEndDate!.substring(5, 11)}',
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
                                        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        minimumSize: const Size(0, 30),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 5),
                                        backgroundColor: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
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
                                            bondInfo: bonds.treasuryBonds!
                                                .ncbTBill![index],
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
                                                  // "Invest ₹ ${convertCurrencyINRStandard(int.parse(bonds.treasuryBonds!.ncbTBill![index].minBidQuantity!))}",
                                                  'Apply',
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorBlack
                                                          : colors.colorWhite,
                                                      12,
                                                      FontWeight.w500))
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: bonds.treasuryBonds!.ncbTBill!.length,
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 0,
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                    );
                  },
                ),
                //  const Spacer(),
                // companyInfoWidget(context,true),

                Divider(
                  height: 0,
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                )
              ],
            )
          : const SizedBox();
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
