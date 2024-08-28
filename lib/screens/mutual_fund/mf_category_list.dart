import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
// import 'mf_order_screen.dart';

class MfCategoryList extends ConsumerWidget {
  const MfCategoryList({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);

    final mfData = watch(mfProvider);
    final fund = watch(fundProvider);
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(8, 0, 2, 2),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            border: Border.all(color: const Color(0xffEEF0F2), width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(mfData.mfCategory,
                style: textStyle(colors.colorBlack, 16, FontWeight.w600)),
            IconButton(
                splashRadius: 20,
                onPressed: () {},
                icon: SvgPicture.asset(assets.filterLines,
                    width: 19, color: colors.colorGrey)),
          ],
        ),
      ),
      ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              //  mfData.mfCategory == "Top Mutual Funds"
              //     ?
              mfData.mutualFundList!.length > 100
                  ? 100
                  // : mfData.mutualFundList!.length
                  : mfData.mutualFundList!.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(children: [
              InkWell(
                  onTap: () async {
                    await mfData.fetchFactSheet(
                        "${mfData.mutualFundList![index].iSIN}");

                    Navigator.pushNamed(context, Routes.mfStockDetail,
                        arguments: mfData.mutualFundList![index]);
                  },
                  child: Container(
                      decoration: const BoxDecoration(
                          border: Border.symmetric(
                              vertical: BorderSide(
                                  color: Color(0xffEEF0F2), width: 1.5))),
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
                                            "${mfData.mutualFundList![index].fSchemeName}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                                                      exch: mfData
                                                              .mutualFundList![
                                                                  index]
                                                              .schemeName!
                                                              .contains(
                                                                  "GROWTH")
                                                          ? "GROWTH"
                                                          : mfData
                                                                  .mutualFundList![
                                                                      index]
                                                                  .schemeName!
                                                                  .contains(
                                                                      "IDCW PAYOUT")
                                                              ? "IDCW PAYOUT"
                                                              : mfData
                                                                      .mutualFundList![
                                                                          index]
                                                                      .schemeName!
                                                                      .contains(
                                                                          "IDCW REINVESTMENT")
                                                                  ? "IDCW REINVESTMENT"
                                                                  : mfData
                                                                          .mutualFundList![
                                                                              index]
                                                                          .schemeName!
                                                                          .contains(
                                                                              "IDCW")
                                                                      ? "IDCW"
                                                                      : "NORMAL"),
                                                  CustomExchBadge(
                                                      exch:
                                                          "${mfData.mutualFundList![index].schemeType}"),
                                                  CustomExchBadge(
                                                      exch: mfData
                                                          .mutualFundList![
                                                              index]
                                                          .sCHEMESUBCATEGORY!
                                                          .replaceAll(
                                                              "Fund", '')
                                                          .replaceAll(
                                                              "Hybrid", "")
                                                          .toUpperCase())
                                                ]))
                                      ])),
                                  IconButton(
                                      splashRadius: 20,
                                      onPressed: () async {
                                        await mfData.fetchMFWatchlist(
                                            mfData.mutualFundList![index],
                                            "add",
                                            context,
                                            false);
                                      },
                                      icon: SvgPicture.asset(
                                        color:
                                            mfData.mutualFundList![index].isAdd!
                                                ? colors.colorBlue
                                                : colors.colorGrey,
                                        mfData.mutualFundList![index].isAdd!
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
                                                        .mutualFundList![index]
                                                        .aUM!
                                                        .isEmpty
                                                    ? "0.00"
                                                    : mfData
                                                        .mutualFundList![index]
                                                        .aUM!) /
                                                10000000)
                                            .toStringAsFixed(2),
                                        style: textStyle(colors.colorBlack, 12,
                                            FontWeight.w500))
                                  ]),
                                  Row(children: [
                                    Text("3yr: ",
                                        style: textStyle(
                                            const Color(0xff999999),
                                            12,
                                            FontWeight.w500)),
                                    Text(
                                        mfData.mutualFundList![index]
                                                .tHREEYEARDATA!.isEmpty
                                            ? "0.00"
                                            : mfData.mutualFundList![index]
                                                .tHREEYEARDATA!,
                                        style: textStyle(colors.colorBlack, 12,
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
                                        mfData.mutualFundList![index]
                                                .nETASSETVALUE!.isEmpty
                                            ? "0.00"
                                            : mfData.mutualFundList![index]
                                                .nETASSETVALUE!,
                                        style: textStyle(colors.colorBlack, 12,
                                            FontWeight.w500))
                                  ]),
                                  Row(children: [
                                    Text("Min. Inv: ",
                                        style: textStyle(
                                            const Color(0xff999999),
                                            12,
                                            FontWeight.w500)),
                                    Text(
                                        mfData.mutualFundList![index]
                                                .minimumPurchaseAmount!.isEmpty
                                            ? "0.00"
                                            : mfData.mutualFundList![index]
                                                .minimumPurchaseAmount!,
                                        style: textStyle(colors.colorBlack, 12,
                                            FontWeight.w500))
                                  ])
                                ])
                          ]))),
              InkWell(
                  onTap: () async {
                    mfData.chngMandate("Lumpsum");
                    await fund.fetchUpiDetail();
                    await fund.fetchBankDetail();
                    if (mfData.mutualFundList![index].sIPFLAG == "Y") {
                      await mfData.fetchMFSipData(
                          "${mfData.mutualFundList![index].iSIN}",
                          "${mfData.mutualFundList![index].schemeCode}");

                      await mfData.fetchMFMandateDetail();
                    }

                    // showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return MFOrderScreen(
                    //           mfData: mfData.mutualFundList![index]);
                    //     });

                    Navigator.pushNamed(context, Routes.mforderScreen,
                        arguments: mfData.mutualFundList![index]);
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F3F8),
                        border: Border.all(
                            color: const Color(0xffEEF0F2), width: 1.5),
                      ),
                      child: Text("Invest",
                          style: textStyles.scripNameTxtStyle.copyWith(
                              color: theme.isDarkMode
                                  ? colors.colorLightBlue
                                  : colors.colorBlue))))
            ]);
          })
    ]);
  }
}
