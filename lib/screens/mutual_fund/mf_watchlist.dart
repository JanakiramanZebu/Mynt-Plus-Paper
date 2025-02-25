import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
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
    return Scaffold(
        body: mfData.mfWatchlist!.isEmpty
            ? const Center(child: NoDataFound())
            : ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemCount: mfData.mfWatchlist!.length,
                itemBuilder: (BuildContext context, int index) {
                  return  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                           mfData.fetchFactSheet(
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
                              const SizedBox(height: 8),
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
                                                  "${mfData.mfWatchlist![index].fSchemeName}",
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
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 18,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: [
                                              CustomExchBadge(
                                                  exch: mfData
                                                          .mfWatchlist![
                                                              index]
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
                                              const SizedBox(width: 5),
                                              CustomExchBadge(
                                                  exch:
                                                      "${mfData.mfWatchlist![index].schemeType}"),
                                              const SizedBox(width: 5),
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
                                            true,"watch");
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
                              const SizedBox(height: 6),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                       Text(
                                          (double.parse(mfData
                                                          .mfWatchlist![
                                                              index]
                                                          .aUM!
                                                          .isEmpty
                                                      ? "0.00"
                                                      : mfData
                                                          .mfWatchlist![
                                                              index]
                                                          .aUM!) /
                                                  10000000)
                                              .toStringAsFixed(2),
                                          style: textStyle(colors.colorBlack,
                                              14, FontWeight.w600)),
                                            const SizedBox(height: 4),
                                      Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Text("AUM (Cr) ",
                                                  style: textStyle(
                                                      const Color(0xff999999),
                                                      13,
                                                      FontWeight.w500)),
                                            ),
                                     
                                    ],
                                  ),

 Column(
                                    children: [
                                       Text(
                                         mfData.mfWatchlist![index]
                                                  .nETASSETVALUE!.isEmpty
                                              ? "0.00"
                                              : mfData.mfWatchlist![index]
                                                  .nETASSETVALUE!,
                                          style: textStyle(colors.colorBlack,
                                              14, FontWeight.w600)),
                                            const SizedBox(height: 4),
                                      Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Text("NAV",
                                                  style: textStyle(
                                                      const Color(0xff999999),
                                                      13,
                                                      FontWeight.w500)),
                                            ),
                                     
                                    ],
                                  ),

 Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Column(children: [
                                            Text(
  "${mfData.mfWatchlist![index].tHREEYEARDATA!.isEmpty ? "0.00" : mfData.mfWatchlist![index].tHREEYEARDATA!}%",
  style: textStyle(
    double.parse(
            mfData.mfWatchlist![index].tHREEYEARDATA!.isEmpty ? "0.00" : mfData.mfWatchlist![index].tHREEYEARDATA!) >=
        0
        ? Colors.green 
        : Colors.red, 
    14,
    FontWeight.w600,
  ),
),


                                              const SizedBox(height: 5),
                                              Text("3YR CAGR ",
                                                  style: textStyle(
                                                      const Color(0xff999999),
                                                      13,
                                                      FontWeight.w500)),
                                            ]),
                                          ),



                                ],
                              ),
                              
                             
                            ],
                          ),
                        ),
                      ),
                      // InkWell(
                      //   onTap: ()async {
                      //     mfData.chngMandate("Lumpsum");
                      //       await fund.fetchUpiDetail();
                      //       await fund.fetchBankDetail();
                      //       if (mfData
                      //                             .mfWatchlist![index].sIPFLAG == "Y") {
                      //         await mfData.fetchMFSipData(
                      //             "${mfData
                      //                             .mfWatchlist![index].iSIN}",
                      //             "${mfData
                      //                             .mfWatchlist![index].schemeCode}");

                      //         await mfData.fetchMFMandateDetail();
                      //       }

                      //       // showDialog(
                      //       //     context: context,
                      //       //     builder: (BuildContext context) {
                      //       //       return MFOrderScreen(
                      //       //           mfData: mfData.topmutualfund![index]);
                      //       //     });

                      //       Navigator.pushNamed(context, Routes.mforderScreen,
                      //           arguments: mfData
                      //                             .mfWatchlist![index]);
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(12.0),
                      //     child: Container(
                      //       padding: const EdgeInsets.symmetric(vertical: 6),
                      //       alignment: Alignment.center,
                      //       width: MediaQuery.of(context).size.width,
                      //       decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(17.0),
                      //         color: const Color(0xffF1F3F8),
                      //         border: Border.all(
                      //             color: const Color(0xffEEF0F2), width: 1.5),
                      //       ),
                      //       child: Text("Invest",
                      //           style: textStyles.scripNameTxtStyle.copyWith(
                      //               color: theme.isDarkMode
                      //                   ? colors.colorLightBlue
                      //                   : colors.colorBlue)),
                      //     ),
                      //   ),
                      // ),
                      Divider(
  color: theme.isDarkMode
      ? colors.darkColorDivider
      : const Color(0xffECEDEE),
  thickness: 6.0, 
),

                    ],
                  );
                },
              ),
      );
  }
}
