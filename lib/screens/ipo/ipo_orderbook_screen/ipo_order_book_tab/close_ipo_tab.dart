import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class IpoCloseOrder extends ConsumerWidget {
  // final IPOProvider ipo;
  const IpoCloseOrder({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final ipo = watch(ipoProvide);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ipo.closeorder!.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.ipoclosedetailsscreen,
                      arguments: ipo.closeorder![index]);
                },
                child: Column(
                  children: [
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ipo.closeorder![index].symbol.toString(),
                                  style: textStyles.scripNameTxtStyle.copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack)),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                      ipo.closeorder![index].reponseStatus ==
                                              "cancel success"
                                          ? "assets/icon/failed.svg"
                                          : "assets/icon/failed.svg"),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    ipo.closeorder![index].reponseStatus ==
                                            "cancel success"
                                        ? "Cancelled"
                                        : "Failed",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "BID Qty: ",
                                    style: textStyle(
                                        colors.colorGrey, 12, FontWeight.w500),
                                  ),
                                  Text(
                                    "${ipo.closeorder![index].bidDetail![0].quantity}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w600),
                                  )
                                ],
                              ),
                            ],
                          ),
                          SvgPicture.asset(assets.rightArrowIcon)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : const Color(0xffECEDEE),
                          thickness: 1.2),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,vertical: 10
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ipo.closeorder![index].responseDatetime
                                            .toString() ==
                                        ""
                                    ? "----"
                                    : ipodateres(ipo
                                        .closeorder![index].responseDatetime
                                        .toString()),
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                "Bid Date & time",
                                style: textStyle(
                                    colors.colorGrey, 12, FontWeight.w500),
                              )
                            ],
                          ),Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                ipo.closeorder![index].type == "BSE"
                                    ? "₹${getFormatter(noDecimal: true,v4d: false,value: double.parse(ipo.closeorder![index].bidDetail![0].rate!) * double.parse(ipo.closeorder![index].bidDetail![0].quantity!)).toString()}" 
                                    : "₹${getFormatter(
                                        noDecimal: true,
                                        v4d: false,
                                        value: double.parse(ipo
                                                .closeorder![index]
                                                .bidDetail![0]
                                                .amount
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
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                "Invested amount",
                                style: textStyle(
                                    colors.colorGrey, 12, FontWeight.w500),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : const Color(0xffF1F3F8),
                height: 7,
              );
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
