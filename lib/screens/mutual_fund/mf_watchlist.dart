import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class MFWatchlistScreen extends ConsumerWidget {
  const MFWatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);

    final mfData = watch(mfProvider);
    return WillPopScope(
      onWillPop: () async {
        await mfData.chngMFCategory(mfData.mfCategory);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            elevation: .2,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: InkWell(
                onTap: () async {
                  await mfData.chngMFCategory(mfData.mfCategory);
                  Navigator.pop(context);
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: SvgPicture.asset(assets.backArrow,
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack))),
            shadowColor: const Color(0xffECEFF3),
            title: Text("Mutual Fund Watchlist",
                style: textStyles.appBarTitleTxt.copyWith(
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack))),
        body: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: mfData.mutualFundList!.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                InkWell(
                   onTap: () async {
                    await mfData.fetchFactSheet(
                        "${mfData.mutualFundList![index].iSIN}");

                    Navigator.pushNamed(context, Routes.mfStockDetail,arguments: mfData.mutualFundList![index]);
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        CustomExchBadge(
                                            exch: mfData.mutualFundList![index]
                                                    .schemeName!
                                                    .contains("GROWTH")
                                                ? "GROWTH"
                                                : mfData.mutualFundList![index]
                                                        .schemeName!
                                                        .contains("IDCW PAYOUT")
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
                                                                .contains("IDCW")
                                                            ? "IDCW"
                                                            : "NORMAL"),
                                        CustomExchBadge(
                                            exch:
                                                "${mfData.mutualFundList![index].schemeType}"),
                                        CustomExchBadge(
                                            exch: mfData.mutualFundList![index]
                                                .sCHEMESUBCATEGORY!
                                                .replaceAll("Fund", '')
                                                .replaceAll("Hybrid", "")
                                                .toUpperCase()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                                splashRadius: 20,
                                onPressed: () async {
                                  await mfData.fetchMFWatchlist(
                                      mfData.mutualFundList![index],
                                      mfData.mutualFundList![index].isAdd!
                                          ? "delete"
                                          : "add",
                                      context,true);
                                },
                                icon: SvgPicture.asset(
                                  color: colors.colorBlue,
                                  assets.bookmarkIcon,
                                )),
                          ],
                        ),
                        Divider(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("AUM (cr): ",
                                    style: textStyle(const Color(0xff999999), 12,
                                        FontWeight.w500)),
                                Text(
                                    (double.parse(mfData.mutualFundList![index]
                                                    .aUM!.isEmpty
                                                ? "0.00"
                                                : mfData.mutualFundList![index]
                                                    .aUM!) /
                                            10000000)
                                        .toStringAsFixed(2),
                                    style: textStyle(
                                        colors.colorBlack, 12, FontWeight.w500)),
                              ],
                            ),
                            Row(
                              children: [
                                Text("3yr: ",
                                    style: textStyle(const Color(0xff999999), 12,
                                        FontWeight.w500)),
                                Text(
                                    mfData.mutualFundList![index]
                                            .tHREEYEARDATA!.isEmpty
                                        ? "0.00"
                                        : mfData.mutualFundList![index]
                                            .tHREEYEARDATA!,
                                    style: textStyle(
                                        colors.colorBlack, 12, FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("NAV: ",
                                    style: textStyle(const Color(0xff999999), 12,
                                        FontWeight.w500)),
                                Text(
                                    mfData.mutualFundList![index]
                                            .nETASSETVALUE!.isEmpty
                                        ? "0.00"
                                        : mfData.mutualFundList![index]
                                            .nETASSETVALUE!,
                                    style: textStyle(
                                        colors.colorBlack, 12, FontWeight.w500)),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Min. Inv: ",
                                    style: textStyle(const Color(0xff999999), 12,
                                        FontWeight.w500)),
                                Text(
                                    mfData.mutualFundList![index]
                                            .minimumPurchaseAmount!.isEmpty
                                        ? "0.00"
                                        : mfData.mutualFundList![index]
                                            .minimumPurchaseAmount!,
                                    style: textStyle(
                                        colors.colorBlack, 12, FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F3F8),
                    border:
                        Border.all(color: const Color(0xffEEF0F2), width: 1.5),
                  ),
                  child: Text("Invest",
                      style: textStyles.scripNameTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue)),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
