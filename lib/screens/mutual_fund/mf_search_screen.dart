import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';

class MfCommonSearch extends ConsumerWidget {
  const MfCommonSearch({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mfData = watch(mfProvider);
    final theme = watch(themeProvider);
    final fund = watch(fundProvider);
    
    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            elevation: .2,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: InkWell(
        onTap: () {
          Navigator.pop(context);
          mfData.commonsearch();
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: SvgPicture.asset(assets.backArrow,
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack))),
            shadowColor: const Color(0xffECEFF3),
            title: Text("Mutual Funds Search",
                style: textStyles.appBarTitleTxt.copyWith(
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack))),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  height: 62,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextFormField(
                    controller: mfData.mfsearchcontroller,
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SvgPicture.asset(assets.searchIcon,
                              color: const Color(0xff586279),
                              fit: BoxFit.contain,
                              width: 20),
                        ),
                        suffixIcon: InkWell(
                          onTap: () async {
                            mfData.commonsearch();
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
                      mfData.fetchmfCommonsearch(value, context);
                    },
                  )),
              mfData.mutualFundsearchdata!.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mfData.mutualFundsearchdata!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(children: [
                          InkWell(
                              onTap: () async {
                                await mfData.fetchFactSheet(
                                    "${mfData.mutualFundsearchdata![index].iSIN}");

                                Navigator.pushNamed(
                                    context, Routes.mfStockDetail,
                                    arguments: mfData
                                        .mutualFundsearchdata![index]);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.symmetric(
                                          horizontal: BorderSide(
                                              color: theme.isDarkMode
                                                  ? colors.darkGrey
                                                  : Color(0xffEEF0F2),
                                              width: 1.5),
                                          vertical: BorderSide(
                                              color: theme.isDarkMode
                                                  ? colors.darkGrey
                                                  : Color(0xffEEF0F2),
                                              width: 1.5))),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                    Text(
                                                        "${mfData.mutualFundsearchdata![index].schemeName}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
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
                                                                  exch: mfData
                                                                          .mutualFundsearchdata!
                                                                          [
                                                                              index]
                                                                          .schemeName!
                                                                          .contains(
                                                                              "GROWTH")
                                                                      ? "GROWTH"
                                                                      : mfData
                                                                              .mutualFundsearchdata!
                                                                              [index]
                                                                              .schemeName!
                                                                              .contains("IDCW PAYOUT")
                                                                          ? "IDCW PAYOUT"
                                                                          : mfData.mutualFundsearchdata![index].schemeName!.contains("IDCW REINVESTMENT")
                                                                              ? "IDCW REINVESTMENT"
                                                                              : mfData.mutualFundsearchdata![index].schemeName!.contains("IDCW")
                                                                                  ? "IDCW"
                                                                                  : "NORMAL"),
                                                              CustomExchBadge(
                                                                  exch:
                                                                      "${mfData.mutualFundsearchdata![index].schemeType}"),
                                                              CustomExchBadge(
                                                                  exch: mfData
                                                                      .mutualFundsearchdata!
                                                                      [
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
                                              IconButton(
                                                  splashRadius: 20,
                                                  onPressed: () async {
                                                    await mfData
                                                        .fetchcommonsearchWadd(
                                                            mfData
                                                                .mutualFundsearchdata!
                                                                [index].iSIN!,
                                                            mfData.mutualFundsearchdata![index].isAdd!
                                                ? "delete"
                                                : "add",
                                                            context,
                                                            false);
                                                            // mfData.mutualFundsearchdata![index].isAdd! ?
                                                // await mfData.makefalse(mfData
                                                //     .mutualFundsearchdata![index].iSIN
                                                //     .toString())
                                                // :
                                                //   await mfData.maketrue(mfData
                                                //     .mutualFundsearchdata![index].iSIN
                                                //     .toString());
                                                  },
                                                  icon: SvgPicture.asset(
                                                    color: mfData
                                                            .mutualFundsearchdata!
                                                            [index]
                                                            .isAdd!
                                                        ? colors.colorBlue
                                                        : colors.colorGrey,
                                                    mfData.mutualFundsearchdata!
                                                            [index].isAdd!
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
                                                    (double.parse(mfData
                                                                    .mutualFundsearchdata!
                                                                    [
                                                                        index]
                                                                    .aUM!
                                                                    .isEmpty
                                                                ? "0.00"
                                                                : mfData
                                                                    .mutualFundsearchdata!
                                                                    [
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
                                                    mfData
                                                            .mutualFundsearchdata!
                                                            [index]
                                                            .tHREEYEARDATA!
                                                            .isEmpty
                                                        ? "0.00"
                                                        : mfData
                                                            .mutualFundsearchdata!
                                                            [index]
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
                                                    mfData
                                                            .mutualFundsearchdata!
                                                            [index]
                                                            .nETASSETVALUE!
                                                            .isEmpty
                                                        ? "0.00"
                                                        : mfData
                                                            .mutualFundsearchdata!
                                                            [index]
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
                                                    mfData
                                                            .mutualFundsearchdata!
                                                            [index]
                                                            .minimumPurchaseAmount!
                                                            .isEmpty
                                                        ? "0.00"
                                                        : mfData
                                                            .mutualFundsearchdata!
                                                            [index]
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
                                mfData.chngMandate("Lumpsum");
                                await mfData.fetchUpiDetail();
                                await mfData.fetchBankDetail();
                                if (mfData.mutualFundsearchdata![index]
                                        .sIPFLAG ==
                                    "Y") {
                                  await mfData.fetchMFSipData(
                                      "${mfData.mutualFundsearchdata![index].iSIN}",
                                      "${mfData.mutualFundsearchdata![index].schemeCode}");

                                  await mfData.fetchMFMandateDetail();
                                }

                                Navigator.pushNamed(
                                    context, Routes.mforderScreen,
                                    arguments: mfData
                                        .mutualFundsearchdata![index]);
                              },
                              child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
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
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorBlack
                                                  : colors.colorBlue))))
                        ]);
                      })
                  : const Padding(
                      padding: const EdgeInsets.only(top: 250),
                      child: NoDataFound(),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
