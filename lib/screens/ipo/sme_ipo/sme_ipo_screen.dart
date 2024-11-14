// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';

class SMEIPO extends ConsumerWidget {
  const SMEIPO({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final ipos = watch(ipoProvide);
    final theme = watch(themeProvider);
    return Column(
      children: [
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : const Color(0xffECEDEE)),
        const SizedBox(
          height: 20,
        ),
        ListTile(
            title: Text("Small and Medium Enterprises IPOs",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600)),
            leading: SvgPicture.asset(
              assets.building,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
            trailing: InkWell(
              onTap: () {
                ipos.activeSMEBtn(!ipos.isActiveSME);
              },
              child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? colors.colorbluegrey
                          : const Color(0xffEBF1FF),
                      borderRadius: BorderRadius.circular(20)),
                  child: SvgPicture.asset(
                      ipos.isActiveSME ? assets.squareminus : assets.add,
                      width: 40,
                      height: 40,
                      fit: BoxFit.scaleDown,
                      color: theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorBlue)),
            )),
        ipos.isActiveSME
            ? ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text("${ipos.smeIpoModel?.sMEIPO?[index].name}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                15,
                                FontWeight.w600)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: theme.isDarkMode
                                          ? colors.colorGrey.withOpacity(.1)
                                          : const Color(0xffF1F3F8),
                                      // border: Border.all(
                                      //     color: const Color(0xffC1E7BA)),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                      "${ipos.smeIpoModel!.sMEIPO![index].symbol}",
                                      style: textStyle(const Color(0xff666666),
                                          11, FontWeight.w500))),
                              const SizedBox(width: 10),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: ipostartdate(
                                                  "${ipos.smeIpoModel!.sMEIPO![index].biddingStartDate}",
                                                  "${ipos.smeIpoModel!.sMEIPO![index].biddingEndDate}") ==
                                              "Open"
                                          ? theme.isDarkMode
                                              ? const Color(0xffECF8F1)
                                                  .withOpacity(.3)
                                              : const Color(0xffECF8F1)
                                          : theme.isDarkMode
                                              ? const Color(0xffFFF6E6)
                                                  .withOpacity(.3)
                                              : const Color(0xffFFF6E6),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                      ipostartdate(
                                          "${ipos.smeIpoModel!.sMEIPO![index].biddingStartDate}",
                                          "${ipos.smeIpoModel!.sMEIPO![index].biddingEndDate}"),
                                      style: textStyle(
                                          Color(ipostartdate("${ipos.smeIpoModel!.sMEIPO![index].biddingStartDate}", "${ipos.smeIpoModel!.sMEIPO![index].biddingEndDate}") == "Open" ? 0xff43A833 : 0xffB37702),
                                          11,
                                          FontWeight.w500))),
                              const SizedBox(width: 10),
                              Text(
                                  "${ipos.smeIpoModel!.sMEIPO![index].biddingStartDate!.substring(0, 2)}th - ${ipos.smeIpoModel!.sMEIPO![index].biddingEndDate!.substring(5, 16)}",
                                  style: textStyle(const Color(0xff666666), 13,
                                      FontWeight.w500)),
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
                                    style: textStyle(const Color(0xff666666),
                                        13, FontWeight.w500)),
                                Text(
                                    "₹${double.parse(ipos.smeIpoModel!.sMEIPO![index].minPrice!).toInt()}- ₹${double.parse(ipos.smeIpoModel!.sMEIPO![index].maxPrice!).toInt()}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        15,
                                        FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Min Qty",
                                    style: textStyle(const Color(0xff666666),
                                        13, FontWeight.w500)),
                                Text(
                                    "${ipos.smeIpoModel!.sMEIPO![index].minBidQuantity}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        15,
                                        FontWeight.w500))
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Min Amount",
                                    style: textStyle(const Color(0xff666666),
                                        13, FontWeight.w500)),
                                Text(
                                    "₹${mininv(double.parse(ipos.smeIpoModel!.sMEIPO![index].minPrice!).toDouble(), int.parse(ipos.smeIpoModel!.sMEIPO![index].minBidQuantity!).toInt())}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        15,
                                        FontWeight.w500))
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: theme.isDarkMode
                                    ? colors.colorbluegrey
                                    : const Color(0xffF1F3F8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                )),
                            onPressed: () async {
                              await context
                                  .read(ipoProvide)
                                  .validateCurrentTime();
                              await context.read(fundProvider).fetchUpiDetail();
                              await context.read(ipoProvide).smeipocategory();
                              Navigator.pushNamed(
                                context,
                                Routes.smeapplyIPO,
                                arguments: ipos.smeIpoModel!.sMEIPO![index],
                              );
                            },
                            child: Text(
                              ipostartdate(
                                          "${ipos.smeIpoModel!.sMEIPO![index].biddingStartDate}",
                                          "${ipos.smeIpoModel!.sMEIPO![index].biddingEndDate}") ==
                                      "Open"
                                  ? "Apply"
                                  : "Pre Apply",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorBlue,
                                  13,
                                  FontWeight.w600),
                            )),
                      )
                    ],
                  );
                },
                itemCount: ipos.smeIpoModel!.sMEIPO!.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : const Color(0xffF1F3F8),
                    height: 7,
                  );
                },
              )
            : Container()
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}
