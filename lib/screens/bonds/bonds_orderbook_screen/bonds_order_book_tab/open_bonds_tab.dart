import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class BondsOpenOrder extends ConsumerWidget {
  const BondsOpenOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final bonds = ref.watch(bondsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bonds.openOrderBook!.length,
                  itemBuilder: (context, index) {
     
                    // for (var i = 0;
                    //     i < bonds.openOrderBook![index].bidDetail!.length;
                    //     i++) {
                    //   stringList.add( bonds.openOrderBook![index].type== "BSE" ? (double.parse(bonds.openOrderBook![index].bidDetail![i].rate!) * double.parse(bonds.openOrderBook![index].bidDetail![i].quantity!)).toString() : bonds.openOrderBook![index].bidDetail![i].amount.toString());
                    //   bidqty.add(bonds.openOrderBook![index].bidDetail![i].quantity
                    //       .toString());
                    // }
                    // String maxValue = stringList.reduce((curr, next) =>
                    //     double.parse(curr) > double.parse(next) ? curr : next).toString();
                    // String bidmaxvalue = bidqty.reduce((curr, next) =>
                    //     double.parse(curr) > double.parse(next) ? curr : next).toString();
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, Routes.bondsopendetailsscreen,
                            arguments: bonds.openOrderBook![index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    bonds.openOrderBook![index].symbol
                                        .toString(),
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack)),

                                                Text(
                                        // bonds.openOrderBook![index].type == "BSE"
                                        //     ? "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(maxValue))}"
                                        // : 
                                            "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(bonds.openOrderBook![index].investmentValue!))}",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w600),
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
                                      bonds.openOrderBook![index].responseDatetime
                                                  .toString() ==
                                              ""
                                          ? "----"
                                          : ipodateres(bonds.openOrderBook![index]
                                              .responseDatetime
                                              .toString()),
                                      style:  textStyle(
                                         const Color(0xff666666),
                                          12,
                                          FontWeight.w600),
                                    ),
                                    // const SizedBox(
                                    //   height: 2,
                                    // ),
                                    // Text(
                                    //   "Bid Date & time",
                                    //   style: textStyle(colors.colorGrey, 12,
                                    //       FontWeight.w500),
                                    // )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                     Row(
                                children: [
                                  SvgPicture.asset(bonds.openOrderBook![index]
                                              .reponseStatus ==
                                          "new success"
                                      ? "assets/icon/success.svg"
                                      : "assets/icon/pendingicon.svg"),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    bonds.openOrderBook![index]
                                                .reponseStatus ==
                                            "new success"
                                        ? "Success"
                                        : "Pending",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w600),
                                  ),
                                 
                                  // Text(
                                  //   "BID Qty: ",
                                  //   style: textStyle(colors.colorGrey, 12,
                                  //       FontWeight.w500),
                                  // ),
                                  // Text(
                                  //   bonds.openOrderBook![index].investmentValue!,
                                  //   style: textStyle(
                                  //       theme.isDarkMode
                                  //           ? colors.colorWhite
                                  //           : colors.colorBlack,
                                  //       13,
                                  //       FontWeight.w600),
                                  // )
                                ],
                              ),
                                    
                                    // const SizedBox(
                                    //   height: 2,
                                    // ),
                                    // Text(
                                    //   "Invested amount",
                                    //   style: textStyle(colors.colorGrey, 12,
                                    //       FontWeight.w500),
                                    // )
                                  ],
                                )
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
                        : colors.colorDivider,);
                  },
                )
        ]
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
