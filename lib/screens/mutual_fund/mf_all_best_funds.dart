// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';

class SaveTaxesScreen extends ConsumerWidget {
  final String title;
  const SaveTaxesScreen({super.key, required this.title});

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
            title: Text(title,
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
                  itemCount: mf.bestMFList!.bestMFList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(children: [
                      InkWell(
                          onTap: () async {
                            await mf.fetchFactSheet(
                                "${mf.bestMFList!.bestMFList![index].iSIN}");

                            Navigator.pushNamed(context, Routes.mfStockDetail,
                                arguments: mf.bestMFList!.bestMFList![index]);
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
                                                Text(
                                                    "${mf.bestMFList!.bestMFList![index].fSchemeName}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        14,
                                                        FontWeight.w500)),
                                                const SizedBox(height: 4),
                                                SizedBox(
                                                    height: 18,
                                                    child: ListView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        children: [
                                                          CustomExchBadge(
                                                              exch: mf.bestMFList!.bestMFList![index]
                                                                      .schemeName!
                                                                      .contains(
                                                                          "GROWTH")
                                                                  ? "GROWTH"
                                                                  :mf.bestMFList!.bestMFList![index]
                                                                          .schemeName!
                                                                          .contains(
                                                                              "IDCW PAYOUT")
                                                                      ? "IDCW PAYOUT"
                                                                      : mf.bestMFList!.bestMFList![index]
                                                                              .schemeName!
                                                                              .contains("IDCW REINVESTMENT")
                                                                          ? "IDCW REINVESTMENT"
                                                                          : mf.bestMFList!.bestMFList![index].schemeName!.contains("IDCW")
                                                                              ? "IDCW"
                                                                              : "NORMAL"),
                                                          CustomExchBadge(
                                                              exch:
                                                                  "${mf.bestMFList!.bestMFList![index].schemeType}"),
                                                          CustomExchBadge(
                                                              exch: mf.bestMFList!.bestMFList![index]
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
                                          IconButton(
                                              splashRadius: 20,
                                              onPressed: () async {
                                                await mf.fetchMFWatchlist(
                                                    mf.bestMFList!
                                                        .bestMFList![index].iSIN!,
                                                    mf
                                                            .bestMFList!
                                                            .bestMFList![index]
                                                            .isAdd!
                                                        ? "delete"
                                                        : "add",
                                                    context,
                                                    false,
                                                    "watch");
                                                //    mf.bestMFList!.bestMFList![index].isAdd! ?
                                                // await mf.makefalse(mf
                                                //     .bestmfFilter![index].iSIN
                                                //     .toString())
                                                // :
                                                //   await mf.maketrue(mf
                                                //     .bestmfFilter![index].iSIN
                                                //     .toString());
                                              },
                                              icon: SvgPicture.asset(
                                                color: mf
                                                        .bestMFList!
                                                        .bestMFList![index]
                                                        .isAdd!
                                                    ? colors.colorBlue
                                                    : colors.colorGrey,
                                                mf
                                                        .bestMFList!
                                                        .bestMFList![index]
                                                        .isAdd!
                                                    ? assets.bookmarkIcon
                                                    : assets.bookmarkedIcon,
                                              ))
                                        ]),
                                    Divider(
                                        color: theme.isDarkMode
                                            ? colors.darkColorDivider
                                            : colors.colorDivider),
                                    const SizedBox(height: 3),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Text("AUM (Cr): ",
                                                style: textStyle(
                                                    const Color(0xff999999),
                                                    12,
                                                    FontWeight.w500)),
                                            Text(
                                                (double.parse(mf.bestMFList!.bestMFList![index]
                                                                .aUM!
                                                                .isEmpty
                                                            ? "0.00"
                                                            : mf.bestMFList!.bestMFList![index]
                                                                .aUM!) /
                                                        10000000)
                                                    .toStringAsFixed(2),
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    12,
                                                    FontWeight.w500))
                                          ]),
                                          Row(children: [
                                            Text("3yr: ",
                                                style: textStyle(
                                                    const Color(0xff999999),
                                                    12,
                                                    FontWeight.w500)),
                                            Text(
                                                mf
                                                        .bestMFList!
                                                        .bestMFList![index]
                                                        .tHREEYEARDATA!
                                                        .isEmpty
                                                    ? "0.00"
                                                    : mf
                                                        .bestMFList!
                                                        .bestMFList![index]
                                                        .tHREEYEARDATA!,
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    12,
                                                    FontWeight.w500))
                                          ])
                                        ]),
                                    const SizedBox(height: 3),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Text("NAV: ",
                                                style: textStyle(
                                                    const Color(0xff999999),
                                                    12,
                                                    FontWeight.w500)),
                                            Text(
                                                mf
                                                        .bestMFList!
                                                        .bestMFList![index]
                                                        .nETASSETVALUE!
                                                        .isEmpty
                                                    ? "0.00"
                                                    : mf
                                                        .bestMFList!
                                                        .bestMFList![index]
                                                        .nETASSETVALUE!,
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    12,
                                                    FontWeight.w500))
                                          ]),
                                          Row(children: [
                                            Text("Min. Inv: ",
                                                style: textStyle(
                                                    const Color(0xff999999),
                                                    12,
                                                    FontWeight.w500)),
                                            Text(
                                                mf.bestMFList!.bestMFList![index]
                                                        .minimumPurchaseAmount!
                                                        .isEmpty
                                                    ? "0.00"
                                                    : mf
                                                        .bestMFList!
                                                        .bestMFList![index]
                                                        .minimumPurchaseAmount!,
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    12,
                                                    FontWeight.w500))
                                          ])
                                        ])
                                  ]))),
                      InkWell(
                          onTap: () async {
                            mf.chngMandate("Lumpsum");
                            await fund.fetchUpiDetail();
                            await fund.fetchBankDetail();
                            if (mf.bestMFList!.bestMFList![index].sIPFLAG ==
                                "Y") {
                              await mf.fetchMFSipData(
                                  "${mf.bestMFList!.bestMFList![index].iSIN}",
                                  "${mf.bestMFList!.bestMFList![index].schemeCode}");

                              await mf.fetchMFMandateDetail();
                            }

                            Navigator.pushNamed(context, Routes.mforderScreen,
                                arguments: mf.bestMFList!.bestMFList![index]);
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
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
                                  style: textStyles.scripNameTxtStyle.copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorBlue))))
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
