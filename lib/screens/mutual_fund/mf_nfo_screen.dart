// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../../provider/fund_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_exch_badge.dart';

class MFNFOScreen extends ConsumerWidget {
  const MFNFOScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mf = watch(mfProvider);
    final theme = watch(themeProvider);
    final fund = watch(fundProvider);
    return Scaffold(
        appBar: AppBar(
            // actions: [
            //   InkWell(
            //       onTap: () async {
            //         Navigator.pop(context);
            //       },
            //       child: SvgPicture.asset(
            //           color: theme.isDarkMode
            //               ? colors.colorWhite
            //               : colors.colorBlack,
            //           assets.bookmarkadd)),
            //   const SizedBox(
            //     width: 15,
            //   ),],
            elevation: .2,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: const CustomBackBtn(),
            shadowColor: const Color(0xffECEFF3),
            title: Text("NFO",
                style: textStyles.appBarTitleTxt.copyWith(
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack))),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: mf.mfNFOList!.nfoList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(children: [
                      InkWell(
                          onTap: () async {
                            // await mf.fetchFactSheet(
                            //     "${mf.mfNFOList!.nfoList![index].iSIN}");

                            // Navigator.pushNamed(context, Routes.mfStockDetail,
                            //     arguments: mf.mfNFOList!.nfoList![index]);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.symmetric(
                                      vertical: BorderSide(
                                          color: theme.isDarkMode
                                              ? colors.darkGrey
                                              : Color(0xffEEF0F2),
                                          width: 1.5))),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.7,
                                                  child: Text(
                                                    "${mf.mfNFOList!.nfoList![index].fSchemeName}",
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                // Text(
                                                //     "${mf.mfNFOList!.nfoList![index].fSchemeName}",
                                                //     maxLines: 1,
                                                //     overflow:
                                                //         TextOverflow.ellipsis,
                                                //     style: textStyle(
                                                //         theme.isDarkMode
                                                //             ? colors.colorWhite
                                                //             : colors.colorBlack,
                                                //         14,
                                                //         FontWeight.w500)),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                    height: 18,
                                                    child: ListView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        children: [
                                                          CustomExchBadge(
                                                              exch: mf
                                                                      .mfNFOList!
                                                                      .nfoList![
                                                                          index]
                                                                      .schemeName!
                                                                      .contains(
                                                                          "GROWTH")
                                                                  ? "GROWTH"
                                                                  : mf
                                                                          .mfNFOList!
                                                                          .nfoList![
                                                                              index]
                                                                          .schemeName!
                                                                          .contains(
                                                                              "IDCW PAYOUT")
                                                                      ? "IDCW PAYOUT"
                                                                      : mf.mfNFOList!.nfoList![index]
                                                                              .schemeName!
                                                                              .contains("IDCW REINVESTMENT")
                                                                          ? "IDCW REINVESTMENT"
                                                                          : mf.mfNFOList!.nfoList![index].schemeName!.contains("IDCW")
                                                                              ? "IDCW"
                                                                              : "NORMAL"),
                                                          const SizedBox(
                                                              width: 5),
                                                          CustomExchBadge(
                                                              exch:
                                                                  "${mf.mfNFOList!.nfoList![index].schemeType}"),
                                                          const SizedBox(
                                                              width: 5),
                                                          CustomExchBadge(
                                                              exch: mf
                                                                  .mfNFOList!
                                                                  .nfoList![
                                                                      index]
                                                                  .sCHEMESUBCATEGORY!
                                                                  .replaceAll(
                                                                      "Fund",
                                                                      '')
                                                                  .replaceAll(
                                                                      "Hybrid",
                                                                      "")
                                                                  .toUpperCase())
                                                        ]))
                                              ])),
                                          // IconButton(
                                          //     splashRadius: 20,
                                          //     onPressed: () async {

                                          //       // await mf.fetchMFWatchlist(
                                          //       //     mf.mfNFOList!.nfoList![index],
                                          //       //     mf.mfNFOList!.nfoList![index].isAdd!
                                          //       //   ? "delete"
                                          //       //   : "add",
                                          //       //     context,
                                          //       //     false,
                                          //       //     "watch");
                                          //         //   mf.mfNFOList!.nfoList![index].isAdd! ?
                                          //         // await mf.makefalse(mf
                                          //         //     .mfNFOList!.nfoList![index].iSIN
                                          //         //     .toString())
                                          //         // :
                                          //         //   await mf.maketrue(mf
                                          //         //     .mfNFOList!.nfoList![index].iSIN
                                          //         //     .toString());
                                          //     },
                                          //     icon: SvgPicture.asset(
                                          //       color:
                                          //           mf.mfNFOList!.nfoList![index].isAdd!
                                          //               ? colors.colorBlue
                                          //               : colors.colorGrey,
                                          //       mf.mfNFOList!.nfoList![index].isAdd!
                                          //           ? assets.bookmarkIcon
                                          //           : assets.bookmarkedIcon,
                                          //     ))
                                        ]),
                                    const SizedBox(height: 5),
                                    Divider(
                                        color: theme.isDarkMode
                                            ? colors.darkColorDivider
                                            : colors.colorDivider),
                                    const SizedBox(height: 5),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left:8),
                                            child: Column(children: [
                                                                                     
                                              Text(
                                                  mf.mfNFOList!.nfoList![index]
                                                      .startDate!,
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w600)),
                                                      const SizedBox(height: 5),
                                                         Text("Start Date",
                                                  style: textStyle(
                                                      const Color(0xff999999),
                                                      13,
                                                      FontWeight.w500)),
                                            ]),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Column(children: [
                                                                                     
                                                                                    
                                              Text(
                                                  mf.mfNFOList!.nfoList![index]
                                                      .endDate!,
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w600)),
                                                      const SizedBox(height: 5),
                                                         Text("End Date ",
                                                  style: textStyle(
                                                      const Color(0xff999999),
                                                      13,
                                                      FontWeight.w500)),
                                            ]),
                                          )
                                        ]),
                                    const SizedBox(height: 2),
                                    // Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       Row(children: [
                                    //         Text("NAV: ",
                                    //             style: textStyle(
                                    //                 const Color(0xff999999),
                                    //                 12,
                                    //                 FontWeight.w500)),
                                    //         Text(
                                    //             mf.mfNFOList!.nfoList![index]
                                    //                     .nETASSETVALUE!.isEmpty
                                    //                 ? "0.00"
                                    //                 : mf.mfNFOList!.nfoList![index]
                                    //                     .nETASSETVALUE!,
                                    //             style: textStyle(
                                    //                 theme.isDarkMode
                                    //                     ? colors.colorWhite
                                    //                     : colors.colorBlack,
                                    //                 12,
                                    //                 FontWeight.w500))
                                    //       ]),
                                    //       Row(children: [
                                    //         Text("Min. Inv: ",
                                    //             style: textStyle(
                                    //                 const Color(0xff999999),
                                    //                 12,
                                    //                 FontWeight.w500)),
                                    //         Text(
                                    //             mf
                                    //                     .mfNFOList!.nfoList![index]
                                    //                     .minimumPurchaseAmount!
                                    //                     .isEmpty
                                    //                 ? "0.00"
                                    //                 : mf.mfNFOList!.nfoList![index]
                                    //                     .minimumPurchaseAmount!,
                                    //             style: textStyle(
                                    //                 theme.isDarkMode
                                    //                     ? colors.colorWhite
                                    //                     : colors.colorBlack,
                                    //                 12,
                                    //                 FontWeight.w500))
                                    //       ])
                                    //     ])
                                  ]))),
                      InkWell(
                          onTap: () async {
                            mf.chngMandate("Lumpsum");
                            await fund.fetchUpiDetail();
                            await fund.fetchBankDetail();
                            if (mf.mfNFOList!.nfoList![index].sIPFLAG == "Y") {
                              await mf.fetchMFSipData(
                                  "${mf.mfNFOList!.nfoList![index].iSIN}",
                                  "${mf.mfNFOList!.nfoList![index].schemeCode}");

                              await mf.fetchMFMandateDetail();
                            }

                            Navigator.pushNamed(context, Routes.mforderScreen,
                                arguments: mf.mfNFOList!.nfoList![index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17.0),
                                  color: theme.isDarkMode
                                      ? colors.colorbluegrey
                                      : const Color(0xffF1F3F8),
                                  border: Border.all(
                                      color: theme.isDarkMode
                                          ? colors.darkGrey
                                          : const Color(0xffEEF0F2),
                                      width: 1.5),
                                ),
                                child: Text("Invest",
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorBlue))),
                          )),
                      Divider(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : const Color(0xffECEDEE),
                        thickness: 6.0, // Increase the thickness here
                      ),
                    ]);
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ));
  }
}
