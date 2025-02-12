import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import 'mf_filter.dart';
// import 'mf_order_screen.dart';

class MfCategoryList extends ConsumerWidget {
  const MfCategoryList({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final mfData = watch(mfProvider);
    final fund = watch(fundProvider);
    bool isfalse =
        mfData.topmutualfund!.isEmpty && mfData.mfCategory == "Watchlist";
    return Column(children: [
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
            Text(mfData.mfCategory,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600)),
            Row(
              children: [
                IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      showModalBottomSheet(
                          useSafeArea: true,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16))),
                          context: context,
                          builder: (context) {
                            return const MfFilterscreen();
                          });
                    },
                    icon: SvgPicture.asset(assets.filterLines,
                        width: 19, color: colors.colorGrey)),
                IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      mfData.showOpenSearch(true);
                    },
                    icon: SvgPicture.asset(assets.searchIcon,
                        width: 19, color: colors.colorGrey)),
              ],
            ),
          ],
        ),
      ),
      if (mfData.showSearch) ...[
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
                  controller: mfData.mfsearchcontroller,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
                          mfData.clearopenoreder();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                    mfData.mfSearch(value, context);
                  },
                ),
              ),
              TextButton(
                  onPressed: () {
                    mfData.showOpenSearch(false);
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
      mfData.mutualFundtopsearch!.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  //  mfData.mfCategory == "Top Mutual Funds"
                  //     ?
                  mfData.mutualFundtopsearch!.length > 100
                      ? 100
                      // : mfData.topmutualfund!.length
                      : mfData.mutualFundtopsearch!.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(children: [
                  InkWell(
                      onTap: () async {
                        await mfData.fetchFactSheet(
                            "${mfData.mutualFundtopsearch![index].iSIN}");

                        Navigator.pushNamed(context, Routes.mfStockDetail,
                            arguments: mfData.mutualFundtopsearch![index]);
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
                                                "${mfData.mutualFundtopsearch![index].fSchemeName}",
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
                                                                  .mutualFundtopsearch![
                                                                      index]
                                                                  .schemeName!
                                                                  .contains(
                                                                      "GROWTH")
                                                              ? "GROWTH"
                                                              : mfData
                                                                      .mutualFundtopsearch![
                                                                          index]
                                                                      .schemeName!
                                                                      .contains(
                                                                          "IDCW PAYOUT")
                                                                  ? "IDCW PAYOUT"
                                                                  : mfData
                                                                          .mutualFundtopsearch![
                                                                              index]
                                                                          .schemeName!
                                                                          .contains(
                                                                              "IDCW REINVESTMENT")
                                                                      ? "IDCW REINVESTMENT"
                                                                      : mfData.mutualFundtopsearch![index]
                                                                              .schemeName!
                                                                              .contains("IDCW")
                                                                          ? "IDCW"
                                                                          : "NORMAL"),
                                                      CustomExchBadge(
                                                          exch:
                                                              "${mfData.mutualFundtopsearch![index].schemeType}"),
                                                      CustomExchBadge(
                                                          exch: mfData
                                                              .mutualFundtopsearch![
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
                                                mfData.mutualFundtopsearch![
                                                    index],
                                                "add",
                                                context,
                                                false,"top");
                                          },
                                          icon: SvgPicture.asset(
                                            color: mfData
                                                    .mutualFundtopsearch![index]
                                                    .isAdd!
                                                ? colors.colorBlue
                                                : colors.colorGrey,
                                            mfData.mutualFundtopsearch![index]
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
                                            (double.parse(mfData
                                                            .mutualFundtopsearch![
                                                                index]
                                                            .aUM!
                                                            .isEmpty
                                                        ? "0.00"
                                                        : mfData
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
                                            mfData.mutualFundtopsearch![index]
                                                    .tHREEYEARDATA!.isEmpty
                                                ? "0.00"
                                                : mfData
                                                    .mutualFundtopsearch![index]
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
                                            mfData.mutualFundtopsearch![index]
                                                    .nETASSETVALUE!.isEmpty
                                                ? "0.00"
                                                : mfData
                                                    .mutualFundtopsearch![index]
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
                                                    .mutualFundtopsearch![index]
                                                    .minimumPurchaseAmount!
                                                    .isEmpty
                                                ? "0.00"
                                                : mfData
                                                    .mutualFundtopsearch![index]
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
                        await fund.fetchUpiDetail();
                        await fund.fetchBankDetail();
                        if (mfData.mutualFundtopsearch![index].sIPFLAG == "Y") {
                          await mfData.fetchMFSipData(
                              "${mfData.mutualFundtopsearch![index].iSIN}",
                              "${mfData.mutualFundtopsearch![index].schemeCode}");

                          await mfData.fetchMFMandateDetail();
                        }

                        Navigator.pushNamed(context, Routes.mforderScreen,
                            arguments: mfData.mutualFundtopsearch![index]);
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
          : isfalse
              ? const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: NoDataFound(),
                )
              : !mfData.isFiltered! ? 
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      //  mfData.mfCategory == "Top Mutual Funds"
                      //     ?
                      
                      mfData.topmutualfund!.length > 100
                          ? mfData.shoew
                          // : mfData.topmutualfund!.length
                          : mfData.topmutualfund!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(children: [
                      InkWell(
                          onTap: () async {
                            await mfData.fetchFactSheet(
                                "${mfData.topmutualfund![index].iSIN}");

                            Navigator.pushNamed(context, Routes.mfStockDetail,
                                arguments: mfData.topmutualfund![index]);
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
                                                    "${mfData.topmutualfund![index].fSchemeName}",
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
                                                              exch: mfData
                                                                      .topmutualfund![
                                                                          index]
                                                                      .schemeName!
                                                                      .contains(
                                                                          "GROWTH")
                                                                  ? "GROWTH"
                                                                  : mfData
                                                                          .topmutualfund![
                                                                              index]
                                                                          .schemeName!
                                                                          .contains(
                                                                              "IDCW PAYOUT")
                                                                      ? "IDCW PAYOUT"
                                                                      : mfData.topmutualfund![index]
                                                                              .schemeName!
                                                                              .contains("IDCW REINVESTMENT")
                                                                          ? "IDCW REINVESTMENT"
                                                                          : mfData.topmutualfund![index].schemeName!.contains("IDCW")
                                                                              ? "IDCW"
                                                                              : "NORMAL"),
                                                          CustomExchBadge(
                                                              exch:
                                                                  "${mfData.topmutualfund![index].schemeType}"),
                                                          CustomExchBadge(
                                                              exch: mfData
                                                                  .topmutualfund![
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
                                                await mfData.fetchMFWatchlist(
                                                    mfData
                                                        .topmutualfund![index],
                                                    "add",
                                                    context,
                                                    false,"top");
                                                await mfData.maketrue(mfData
                                                    .topmutualfund![index].iSIN
                                                    .toString());
                                              },
                                              icon: SvgPicture.asset(
                                                color: mfData
                                                        .topmutualfund![index]
                                                        .isAdd!
                                                    ? colors.colorBlue
                                                    : colors.colorGrey,
                                                mfData.topmutualfund![index]
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
                                                (double.parse(mfData
                                                                .topmutualfund![
                                                                    index]
                                                                .aUM!
                                                                .isEmpty
                                                            ? "0.00"
                                                            : mfData
                                                                .topmutualfund![
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
                                                mfData.topmutualfund![index]
                                                        .tHREEYEARDATA!.isEmpty
                                                    ? "0.00"
                                                    : mfData
                                                        .topmutualfund![index]
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
                                                mfData.topmutualfund![index]
                                                        .nETASSETVALUE!.isEmpty
                                                    ? "0.00"
                                                    : mfData
                                                        .topmutualfund![index]
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
                                                        .topmutualfund![index]
                                                        .minimumPurchaseAmount!
                                                        .isEmpty
                                                    ? "0.00"
                                                    : mfData
                                                        .topmutualfund![index]
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
                            await fund.fetchUpiDetail();
                            await fund.fetchBankDetail();
                            if (mfData.topmutualfund![index].sIPFLAG == "Y") {
                              await mfData.fetchMFSipData(
                                  "${mfData.topmutualfund![index].iSIN}",
                                  "${mfData.topmutualfund![index].schemeCode}");

                              await mfData.fetchMFMandateDetail();
                            }

                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return MFOrderScreen(
                            //           mfData: mfData.topmutualfund![index]);
                            //     });

                            Navigator.pushNamed(context, Routes.mforderScreen,
                                arguments: mfData.topmutualfund![index]);
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
                  }) :
                  ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      //  mfData.mfCategory == "Top Mutual Funds"
                      //     ?
                      mfData.filteredMf!.length > 100
                          ? mfData.shoew
                          // : mfData.topmutualfund!.length
                          : mfData.filteredMf!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(children: [
                      InkWell(
                          onTap: () async {
                            await mfData.fetchFactSheet(
                                "${mfData.filteredMf![index].iSIN}");

                            Navigator.pushNamed(context, Routes.mfStockDetail,
                                arguments: mfData.filteredMf![index]);
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
                                                    "${mfData.filteredMf![index].fSchemeName}",
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
                                                              exch: mfData
                                                                      .filteredMf![
                                                                          index]
                                                                      .schemeName!
                                                                      .contains(
                                                                          "GROWTH")
                                                                  ? "GROWTH"
                                                                  : mfData
                                                                          .filteredMf![
                                                                              index]
                                                                          .schemeName!
                                                                          .contains(
                                                                              "IDCW PAYOUT")
                                                                      ? "IDCW PAYOUT"
                                                                      : mfData.filteredMf![index]
                                                                              .schemeName!
                                                                              .contains("IDCW REINVESTMENT")
                                                                          ? "IDCW REINVESTMENT"
                                                                          : mfData.filteredMf![index].schemeName!.contains("IDCW")
                                                                              ? "IDCW"
                                                                              : "NORMAL"),
                                                          CustomExchBadge(
                                                              exch:
                                                                  "${mfData.filteredMf![index].schemeType}"),
                                                          CustomExchBadge(
                                                              exch: mfData
                                                                  .filteredMf![
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
                                                await mfData.fetchMFWatchlist(
                                                    mfData
                                                        .filteredMf![index],
                                                    "add",
                                                    context,
                                                    false,"top");
                                                await mfData.maketrue(mfData
                                                    .filteredMf![index].iSIN
                                                    .toString());
                                              },
                                              icon: SvgPicture.asset(
                                                color: mfData
                                                        .filteredMf![index]
                                                        .isAdd!
                                                    ? colors.colorBlue
                                                    : colors.colorGrey,
                                                mfData.filteredMf![index]
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
                                                (double.parse(mfData
                                                                .filteredMf![
                                                                    index]
                                                                .aUM!
                                                                .isEmpty
                                                            ? "0.00"
                                                            : mfData
                                                                .filteredMf![
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
                                                mfData.filteredMf![index]
                                                        .tHREEYEARDATA!.isEmpty
                                                    ? "0.00"
                                                    : mfData
                                                        .filteredMf![index]
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
                                                mfData.filteredMf![index]
                                                        .nETASSETVALUE!.isEmpty
                                                    ? "0.00"
                                                    : mfData
                                                        .filteredMf![index]
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
                                                        .filteredMf![index]
                                                        .minimumPurchaseAmount!
                                                        .isEmpty
                                                    ? "0.00"
                                                    : mfData
                                                        .filteredMf![index]
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
                            await fund.fetchUpiDetail();
                            await fund.fetchBankDetail();
                            if (mfData.filteredMf![index].sIPFLAG == "Y") {
                              await mfData.fetchMFSipData(
                                  "${mfData.filteredMf![index].iSIN}",
                                  "${mfData.filteredMf![index].schemeCode}");

                              await mfData.fetchMFMandateDetail();
                            }

                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return MFOrderScreen(
                            //           mfData: mfData.topmutualfund![index]);
                            //     });

                            Navigator.pushNamed(context, Routes.mforderScreen,
                                arguments: mfData.filteredMf![index]);
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
                  ,
      const SizedBox(
        height: 10,
      ),
      if(!mfData.isFiltered!)...[
        mfData.shoew <= mfData.topmutualfund!.length
          ? InkWell(
              onTap: () {
                mfData.mfCategory == "Top Mutual Funds" && mfData.shoew == 100
                    ? null
                    : mfData.showmore(10);
                // mfData.topmutualfund!.take(10);
              },
              child: Padding(
                padding: EdgeInsets.all(
                    mfData.mfCategory == "Top Mutual Funds" &&
                            mfData.shoew == 100
                        ? 0
                        : 10),
                child: Text(
                  mfData.mfCategory == "Top Mutual Funds" && mfData.shoew == 100
                      ? ""
                      : 'Show more ${mfData.shoew}',
                  style: textStyles.textBtn,
                ),
              ),
            )
          : Container(),
      const SizedBox(
        height: 10,
      ),
      ]
      else...[
        const SizedBox(
        height: 10,
      ),
      ]
      
    ]);
  }
}
