import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class BondsCloseOrder extends ConsumerWidget {
  const BondsCloseOrder({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final bonds = watch(bondsProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bonds.closeOrderBook!.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.bondsclosedetailsscreen,
                      arguments: bonds.closeOrderBook![index]);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(bonds.closeOrderBook![index].symbol.toString(),
                              style: textStyles.scripNameTxtStyle.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack)),

                                      Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text( "₹${getFormatter(
                                          noDecimal: true,
                                          v4d: false,
                                          value: double.parse(bonds
                                                  .closeOrderBook![index]
                                                  .investmentValue
                                                  .toString())
                                              .toDouble(),
                                        )}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                // const SizedBox(
                                //   height: 2,
                                // ),
                                // Text(
                                //   "Invested amount",
                                //   style: textStyle(
                                //       colors.colorGrey, 12, FontWeight.w500),
                                // )
                              ],
                            ),
                         
                          
                          // SvgPicture.asset(assets.rightArrowIcon)
                        ],
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16),
                      //   child: Divider(
                      //       color: theme.isDarkMode
                      //           ? colors.darkColorDivider
                      //           : const Color(0xffECEDEE),
                      //       thickness: 1.2),
                      // ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bonds.closeOrderBook![index].responseDatetime
                                            .toString() ==
                                        ""
                                    ? "----"
                                    : ipodateres(bonds
                                        .closeOrderBook![index].responseDatetime
                                        .toString()),
                                style: textStyle(
                                       const Color(0xff666666),
                                        12,
                                        FontWeight.w600),
                              ),
                              // const SizedBox(
                              //   height: 2,
                              // ),
                              // Text(
                              //   "Bid Date & time",
                              //   style: textStyle(
                              //       colors.colorGrey, 12, FontWeight.w500),
                              // )
                            ],
                          ),
                      
                      
                          Row(
                          children: [
                            SvgPicture.asset(
                                bonds.closeOrderBook![index].reponseStatus ==
                                        "Cancel Success"
                                    ? "assets/icon/failed.svg"
                                    : "assets/icon/failed.svg"),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              bonds.closeOrderBook![index].reponseStatus ==
                                      "Cancel Success"
                                  ? "Cancelled"
                                  : "Failed",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600),
                            ),
                           
                            // Text(
                            //   "BID Qty: ",
                            //   style: textStyle(
                            //       colors.colorGrey, 12, FontWeight.w500),
                            // ),
                            // Text(
                            //   "${bonds.closeOrderBook![index].investmentValue}",
                            //   style: textStyle(
                            //       theme.isDarkMode
                            //           ? colors.colorWhite
                            //           : colors.colorBlack,
                            //       13,
                            //       FontWeight.w600),
                            // )
                          ],
                        ),
                          
                          
                          
                          
                          
                        ],
                      ),
                     
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                  height: 0,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider);
            },
          )
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
