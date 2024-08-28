// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/iop_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';

class SMEIPO extends ConsumerWidget {
  const SMEIPO({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final ipos = watch(ipoProvide);
    return Column(
      children: [
        const Divider(
          color: Color(0xffECEDEE),
        ),
        const SizedBox(
          height: 20,
        ),
        ListTile(
            title: Text("Small and Medium Enterprises IPOs",
                style: GoogleFonts.inter(
                    textStyle: textStyle(
                        const Color(0xff000000), 16, FontWeight.w600))),
            leading: SvgPicture.asset(
              assets.building,
            ),
            trailing: InkWell(
              onTap: () {
                ipos.activeSMEBtn(!ipos.isActiveSME);
              },
              child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: const Color(0xffEBF1FF),
                      borderRadius: BorderRadius.circular(20)),
                  child: SvgPicture.asset(
                    ipos.isActiveSME ? assets.squareminus : assets.add,
                    width: 40,
                    height: 40,
                    fit: BoxFit.scaleDown,
                    color: const Color(0xff0037B7),
                  )),
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
                            style: GoogleFonts.inter(
                                textStyle: textStyle(const Color(0xff000000),
                                    15, FontWeight.w600))),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: const Color(0xffF1F3F8),
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
                                      color: Color(ipostartdate(
                                                  "${ipos.smeIpoModel!.sMEIPO![index].biddingStartDate}",
                                                  "${ipos.smeIpoModel!.sMEIPO![index].biddingEndDate}") ==
                                              "Open"
                                          ? 0xffECF8F1
                                          : 0xffFFF6E6),
                                      // border: Border.all(
                                      //     color: const Color(0xffC1E7BA)),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                      ipostartdate(
                                          "${ipos.smeIpoModel!.sMEIPO![index].biddingStartDate}",
                                          "${ipos.smeIpoModel!.sMEIPO![index].biddingEndDate}"),
                                      style: textStyle(
                                          Color(ipostartdate("${ipos.smeIpoModel!.sMEIPO![index].biddingStartDate}", "${ipos.smeIpoModel!.sMEIPO![index].biddingEndDate}") == "Open"
                                              ? 0xff43A833
                                              : 0xffB37702),
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
                      const Divider(
                        color: Color(0xffECEDEE),
                      ),
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
                                    style: GoogleFonts.inter(
                                        textStyle: textStyle(
                                            const Color(0xff666666),
                                            13,
                                            FontWeight.w500))),
                                Text(
                                    "₹${ipos.smeIpoModel!.sMEIPO![index].minPrice!.toInt()}- ₹${ipos.smeIpoModel!.sMEIPO![index].maxPrice!.toInt()}",
                                    style: textStyle(const Color(0xff000000),
                                        15, FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Min Qty",
                                    style: GoogleFonts.inter(
                                        textStyle: textStyle(
                                            const Color(0xff666666),
                                            13,
                                            FontWeight.w500))),
                                Text(
                                    "${ipos.smeIpoModel!.sMEIPO![index].minBidQuantity}",
                                    style: GoogleFonts.inter(
                                        textStyle: textStyle(
                                            const Color(0xff000000),
                                            15,
                                            FontWeight.w500)))
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Min Amount",
                                    style: GoogleFonts.inter(
                                        textStyle: textStyle(
                                            const Color(0xff666666),
                                            13,
                                            FontWeight.w500))),
                                Text(
                                    "₹${mininv(ipos.smeIpoModel!.sMEIPO![index].minPrice!.toDouble(), ipos.smeIpoModel!.sMEIPO![index].minBidQuantity!.toInt()).toInt()}",
                                    style: GoogleFonts.inter(
                                        textStyle: textStyle(
                                            const Color(0xff000000),
                                            15,
                                            FontWeight.w500)))
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
                                backgroundColor: const Color(0xffF1F3F8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                )),
                            onPressed: () async {
                              await context.read(fundProvider).fetchUpiDetail();
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
                                  colors.colorBlue, 13, FontWeight.w600),
                            )),
                      )
                    ],
                  );
                },
                itemCount: ipos.smeIpoModel!.sMEIPO!.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(color: const Color(0xffF1F3F8), height: 7);
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
