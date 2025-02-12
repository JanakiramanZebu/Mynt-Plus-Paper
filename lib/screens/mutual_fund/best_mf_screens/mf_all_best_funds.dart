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
import '../../../sharedWidget/custom_exch_badge.dart';

class SaveTaxesScreen extends ConsumerWidget {
  const SaveTaxesScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mf = watch(mfProvider);
    final theme = watch(themeProvider);
    final fund = watch(fundProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 0, 2, 2),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              border: Border.all(
                  color: theme.isDarkMode
                      ? colors.darkGrey
                      : const Color(0xffEEF0F2),
                  width: 1.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mf.bestmfselected,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      16,
                      FontWeight.w600)),
              Row(
                children: [
                  IconButton(
                      splashRadius: 20,
                      onPressed: () {},
                      icon: SvgPicture.asset(assets.filterLines,
                          width: 19, color: colors.colorGrey)),
                  IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        mf.showOpenSearch(true);
                      },
                      icon: SvgPicture.asset(assets.searchIcon,
                          width: 19, color: colors.colorGrey)),
                  InkWell(
                      onTap: () {
                        mf.bestmfEmpty("");
                      },
                      child: SvgPicture.asset(
                        assets.removeIcon,
                        width: 19,
                      )),
                ],
              ),
            ],
          ),
        ),
        if (mf.showSearch) ...[
          Container(
            height: 62,
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        width: 6))),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: mf.mfsearchcontroller,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600),
                    decoration: InputDecoration(
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        filled: true,
                        hintStyle: textStyle(
                            const Color(0xff69758F), 15, FontWeight.w500),
                        prefixIconColor: const Color(0xff586279),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SvgPicture.asset(assets.searchIcon,
                              color: const Color(0xff586279),
                              fit: BoxFit.contain,
                              width: 20),
                        ),
                        suffixIcon: InkWell(
                          onTap: () async {
                            mf.clearopenoreder();
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SvgPicture.asset(assets.removeIcon,
                                fit: BoxFit.scaleDown, width: 20),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20)),
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20)),
                        hintText: "Search",
                        contentPadding: const EdgeInsets.only(top: 20),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20))),
                    onChanged: (value) async {
                      mf.mfSearch(value, context);
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      mf.showOpenSearch(false);
                    },
                    child: Text("Close",
                        style: textStyles.textBtn.copyWith(
                            color: theme.isDarkMode
                                ? colors.colorLightBlue
                                : colors.colorBlue)))
              ],
            ),
          ),
        ],
        mf.mutualFundtopsearch!.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mf.mutualFundtopsearch!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(children: [
                    InkWell(
                        onTap: () async {
                          await mf.fetchFactSheet(
                              "${mf.mutualFundtopsearch![index].iSIN}");

                          Navigator.pushNamed(context, Routes.mfStockDetail,
                              arguments: mf.mutualFundtopsearch![index]);
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
                                                  "${mf.mutualFundtopsearch![index].fSchemeName}",
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
                                                            exch: mf
                                                                    .mutualFundtopsearch![
                                                                        index]
                                                                    .schemeName!
                                                                    .contains(
                                                                        "GROWTH")
                                                                ? "GROWTH"
                                                                : mf
                                                                        .mutualFundtopsearch![
                                                                            index]
                                                                        .schemeName!
                                                                        .contains(
                                                                            "IDCW PAYOUT")
                                                                    ? "IDCW PAYOUT"
                                                                    : mf.mutualFundtopsearch![index]
                                                                            .schemeName!
                                                                            .contains("IDCW REINVESTMENT")
                                                                        ? "IDCW REINVESTMENT"
                                                                        : mf.mutualFundtopsearch![index].schemeName!.contains("IDCW")
                                                                            ? "IDCW"
                                                                            : "NORMAL"),
                                                        CustomExchBadge(
                                                            exch:
                                                                "${mf.mutualFundtopsearch![index].schemeType}"),
                                                        CustomExchBadge(
                                                            exch: mf
                                                                .mutualFundtopsearch![
                                                                    index]
                                                                .sCHEMESUBCATEGORY!
                                                                .replaceAll(
                                                                    "Fund", '')
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
                                                  mf.mutualFundtopsearch![
                                                      index],
                                                  "add",
                                                  context,
                                                  false,
                                                  "watch");
                                            },
                                            icon: SvgPicture.asset(
                                              color:
                                                  mf.mutualFundtopsearch![index]
                                                          .isAdd!
                                                      ? colors.colorBlue
                                                      : colors.colorGrey,
                                              mf.mutualFundtopsearch![index]
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
                                              (double.parse(mf
                                                              .mutualFundtopsearch![
                                                                  index]
                                                              .aUM!
                                                              .isEmpty
                                                          ? "0.00"
                                                          : mf
                                                              .mutualFundtopsearch![
                                                                  index]
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
                                              mf.mutualFundtopsearch![index]
                                                      .tHREEYEARDATA!.isEmpty
                                                  ? "0.00"
                                                  : mf
                                                      .mutualFundtopsearch![
                                                          index]
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
                                              mf.mutualFundtopsearch![index]
                                                      .nETASSETVALUE!.isEmpty
                                                  ? "0.00"
                                                  : mf
                                                      .mutualFundtopsearch![
                                                          index]
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
                                              mf
                                                      .mutualFundtopsearch![
                                                          index]
                                                      .minimumPurchaseAmount!
                                                      .isEmpty
                                                  ? "0.00"
                                                  : mf
                                                      .mutualFundtopsearch![
                                                          index]
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
                          if (mf.mutualFundtopsearch![index].sIPFLAG == "Y") {
                            await mf.fetchMFSipData(
                                "${mf.mutualFundtopsearch![index].iSIN}",
                                "${mf.mutualFundtopsearch![index].schemeCode}");

                            await mf.fetchMFMandateDetail();
                          }

                          Navigator.pushNamed(context, Routes.mforderScreen,
                              arguments: mf.mutualFundtopsearch![index]);
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
                })
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mf.bestmfFilter!.length > 20
                    ? mf.bestshoew
                    : mf.bestmfFilter!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(children: [
                    InkWell(
                        onTap: () async {
                          await mf.fetchFactSheet(
                              "${mf.bestmfFilter![index].iSIN}");

                          Navigator.pushNamed(context, Routes.mfStockDetail,
                              arguments: mf.bestmfFilter![index]);
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
                                                  "${mf.bestmfFilter![index].fSchemeName}",
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
                                                            exch: mf
                                                                    .bestmfFilter![
                                                                        index]
                                                                    .schemeName!
                                                                    .contains(
                                                                        "GROWTH")
                                                                ? "GROWTH"
                                                                : mf
                                                                        .bestmfFilter![
                                                                            index]
                                                                        .schemeName!
                                                                        .contains(
                                                                            "IDCW PAYOUT")
                                                                    ? "IDCW PAYOUT"
                                                                    : mf.bestmfFilter![index]
                                                                            .schemeName!
                                                                            .contains("IDCW REINVESTMENT")
                                                                        ? "IDCW REINVESTMENT"
                                                                        : mf.bestmfFilter![index].schemeName!.contains("IDCW")
                                                                            ? "IDCW"
                                                                            : "NORMAL"),
                                                        CustomExchBadge(
                                                            exch:
                                                                "${mf.bestmfFilter![index].schemeType}"),
                                                        CustomExchBadge(
                                                            exch: mf
                                                                .bestmfFilter![
                                                                    index]
                                                                .sCHEMESUBCATEGORY!
                                                                .replaceAll(
                                                                    "Fund", '')
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
                                                  mf.bestmfFilter![index],
                                                  "add",
                                                  context,
                                                  false,
                                                  "watch");
                                            },
                                            icon: SvgPicture.asset(
                                              color:
                                                  mf.bestmfFilter![index].isAdd!
                                                      ? colors.colorBlue
                                                      : colors.colorGrey,
                                              mf.bestmfFilter![index].isAdd!
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
                                              (double.parse(mf
                                                              .bestmfFilter![
                                                                  index]
                                                              .aUM!
                                                              .isEmpty
                                                          ? "0.00"
                                                          : mf
                                                              .bestmfFilter![
                                                                  index]
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
                                              mf.bestmfFilter![index]
                                                      .tHREEYEARDATA!.isEmpty
                                                  ? "0.00"
                                                  : mf.bestmfFilter![index]
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
                                              mf.bestmfFilter![index]
                                                      .nETASSETVALUE!.isEmpty
                                                  ? "0.00"
                                                  : mf.bestmfFilter![index]
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
                                              mf
                                                      .bestmfFilter![index]
                                                      .minimumPurchaseAmount!
                                                      .isEmpty
                                                  ? "0.00"
                                                  : mf.bestmfFilter![index]
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
                          if (mf.bestmfFilter![index].sIPFLAG == "Y") {
                            await mf.fetchMFSipData(
                                "${mf.bestmfFilter![index].iSIN}",
                                "${mf.bestmfFilter![index].schemeCode}");

                            await mf.fetchMFMandateDetail();
                          }

                          Navigator.pushNamed(context, Routes.mforderScreen,
                              arguments: mf.bestmfFilter![index]);
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
        const SizedBox(
          height: 10,
        ),
        mf.bestshoew <= mf.bestmfFilter!.length
            ? InkWell(
                onTap: () {
                  mf.bestshowmore(10);
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      'Show more ${mf.bestshoew}',
                      style: textStyles.textBtn,
                    ),
                  ),
                ),
              )
            : Container(),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
