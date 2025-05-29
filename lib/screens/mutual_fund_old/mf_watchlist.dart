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

class MFWatchlistScreen extends ConsumerWidget {
  const MFWatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(fundProvider);
    final mfData = ref.watch(mfProvider);
    return PopScope(
      canPop: true, // Allows back navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If system handled back, do nothing

        // await mfData.chngMFCategory(mfData.mfCategory);

        Navigator.of(context).pop(); // Proceed with back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: .2,
          leadingWidth: 41,
          centerTitle: false,
          titleSpacing: 6,
          leading: InkWell(
              onTap: () async {
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
                      : colors.colorBlack)),
        ),
        body: mfData.mfWatchlist!.isEmpty
            ? Center(child: NoDataFound())
            : ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: mfData.mfWatchlist!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          await mfData.fetchFactSheet(
                              "${mfData.mfWatchlist![index].iSIN}");

                          Navigator.pushNamed(context, Routes.mfStockDetail,
                              arguments: mfData.mfWatchlist![index]);
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
                                            "${mfData.mfWatchlist![index].fSchemeName}",
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
                                                  exch: mfData
                                                          .mfWatchlist![index]
                                                          .schemeName!
                                                          .contains("GROWTH")
                                                      ? "GROWTH"
                                                      : mfData
                                                              .mfWatchlist![
                                                                  index]
                                                              .schemeName!
                                                              .contains(
                                                                  "IDCW PAYOUT")
                                                          ? "IDCW PAYOUT"
                                                          : mfData
                                                                  .mfWatchlist![
                                                                      index]
                                                                  .schemeName!
                                                                  .contains(
                                                                      "IDCW REINVESTMENT")
                                                              ? "IDCW REINVESTMENT"
                                                              : mfData
                                                                      .mfWatchlist![
                                                                          index]
                                                                      .schemeName!
                                                                      .contains(
                                                                          "IDCW")
                                                                  ? "IDCW"
                                                                  : "NORMAL"),
                                              CustomExchBadge(
                                                  exch:
                                                      "${mfData.mfWatchlist![index].schemeType}"),
                                              CustomExchBadge(
                                                  exch: mfData
                                                      .mfWatchlist![index]
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
                                            mfData.mfWatchlist![index].iSIN!,
                                            "delete",
                                            context,
                                            true,
                                            "watch");
                                        // await mfData.makefalse(mfData
                                        //     .mfWatchlist![index].iSIN ??
                                        // "".toString());
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text("AUM (cr): ",
                                          style: textStyle(
                                              const Color(0xff999999),
                                              12,
                                              FontWeight.w500)),
                                      Text(
                                          (double.parse(mfData
                                                          .mfWatchlist![index]
                                                          .aUM!
                                                          .isEmpty
                                                      ? "0.00"
                                                      : mfData
                                                          .mfWatchlist![index]
                                                          .aUM!) /
                                                  10000000)
                                              .toStringAsFixed(2),
                                          style: textStyle(colors.colorBlack,
                                              12, FontWeight.w500)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("3yr: ",
                                          style: textStyle(
                                              const Color(0xff999999),
                                              12,
                                              FontWeight.w500)),
                                      Text(
                                          mfData.mfWatchlist![index]
                                                  .tHREEYEARDATA!.isEmpty
                                              ? "0.00"
                                              : mfData.mfWatchlist![index]
                                                  .tHREEYEARDATA!,
                                          style: textStyle(colors.colorBlack,
                                              12, FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text("NAV: ",
                                          style: textStyle(
                                              const Color(0xff999999),
                                              12,
                                              FontWeight.w500)),
                                      Text(
                                          mfData.mfWatchlist![index]
                                                  .nETASSETVALUE!.isEmpty
                                              ? "0.00"
                                              : mfData.mfWatchlist![index]
                                                  .nETASSETVALUE!,
                                          style: textStyle(colors.colorBlack,
                                              12, FontWeight.w500)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Min. Inv: ",
                                          style: textStyle(
                                              const Color(0xff999999),
                                              12,
                                              FontWeight.w500)),
                                      Text(
                                          mfData
                                                  .mfWatchlist![index]
                                                  .minimumPurchaseAmount!
                                                  .isEmpty
                                              ? "0.00"
                                              : mfData.mfWatchlist![index]
                                                  .minimumPurchaseAmount!,
                                          style: textStyle(colors.colorBlack,
                                              12, FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          mfData.chngMandate("Lumpsum");
                          await fund.fetchUpiDetail();
                          await fund.fetchBankDetail();
                          if (mfData.mfWatchlist![index].sIPFLAG == "Y") {
                            await mfData.fetchMFSipData(
                                "${mfData.mfWatchlist![index].iSIN}",
                                "${mfData.mfWatchlist![index].schemeCode}");

                            await mfData.fetchMFMandateDetail();
                          }

                          // showDialog(
                          //     context: context,
                          //     builder: (BuildContext context) {
                          //       return MFOrderScreen(
                          //           mfData: mfData.topmutualfund![index]);
                          //     });

                          Navigator.pushNamed(context, Routes.mforderScreen,
                              arguments: mfData.mfWatchlist![index]);
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
                                      : colors.colorBlue)),
                        ),
                      )
                    ],
                  );
                },
              ),
      ),
    );
  }
}
