import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class MFSchemeInfo extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFSchemeInfo({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final mfData = watch(mfProvider).factSheetDataModel!.data!;
 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
  //         Text("Scheme Information",
  //             style: textStyle(
  //                 theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
  //                 19,
  //                 FontWeight.w600)),
  //         const SizedBox(height: 11),
  //         Text("Investment Objective",
  //             style: textStyle(
  //                 theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
  //                 17,
  //                 FontWeight.w500)),
  //         const SizedBox(height: 8),
  //         ReadMoreText("${mfData.overview2}",
  //             style: textStyle(const Color(0xff666666), 13, FontWeight.w500).copyWith(
  //   height: 1.5, 
  // ),
  //             textAlign: TextAlign.left,
  //             trimLines: 3,
  //             moreStyle: theme.isDarkMode
  //                 ? textStyles.darkmorestyle
  //                 : textStyles.morestyle,
  //             lessStyle: theme.isDarkMode
  //                 ? textStyles.darkmorestyle
  //                 : textStyles.morestyle,
  //             colorClickableText: const Color(0xff0037B7),
  //             trimMode: TrimMode.Line,
  //             trimCollapsedText: 'Read more',
  //             trimExpandedText: ' Read less'),
          // const SizedBox(height: 27),
          Text("Fund Manager",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  18,
                  FontWeight.w600)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xffEEF0F2), width: 1.5)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                    maxRadius: 24,
                    backgroundImage: NetworkImage(
                        "https://v3.mynt.in/mf/static/images/manager/${mfData.fundManager!.toLowerCase().trim()}.png")),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("${mfData.fundManager}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              16,
                              FontWeight.w500)),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${mfData.managerDesignation}",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  12,
                                  FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                              "₹${double.parse(mfData.managerActiveFundsAumSum ?? "0.00").toStringAsFixed(2)} Cr",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "${mfData.managerTotalExperience!.isEmpty ? "N/A" : mfData.managerTotalExperience} experience",
                              style: textStyle(const Color(0xff999999), 14,
                                  FontWeight.w500)),
                          Text(
                              "${double.parse(mfData.managerNumberOfActiveFunds ?? "0.00").ceil()} funds managed",
                              style: textStyle(const Color(0xff999999), 12,
                                  FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
             
              ],
            ),
          ),
          const SizedBox(height: 
          8),
           Text("Manager Description",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  16,
                                  FontWeight.w500)),
                          const SizedBox(height: 2),
    const SizedBox(height: 8),
          ReadMoreText("${mfData.managerDetailedDescription}",
              style: textStyle(const Color(0xff666666), 13, FontWeight.w500).copyWith(
    height: 1.5, 
  ),
              textAlign: TextAlign.left,
              trimLines: 3,
              moreStyle: theme.isDarkMode
                  ? textStyles.darkmorestyle
                  : textStyles.morestyle,
              lessStyle: theme.isDarkMode
                  ? textStyles.darkmorestyle
                  : textStyles.morestyle,
              colorClickableText: const Color(0xff0037B7),
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Read more',
              trimExpandedText: ' Read less'),
          const SizedBox(height: 
          47),
        Text("")
        
          // const SizedBox(height: 13),
          // rowOfInfoData(
          //     "LAUNCHED",
          //     "${mfData.launchDate}",
          //     "SIP MIN.",
          //     "${mfData.sipMinAmount}",
          //     "CORPUS (Cr.)",
          //     "${mfData.corpus}",
          //     theme),
          // const SizedBox(height: 14),
          // rowOfInfoData(
          //     "EXPENSE RATIO",
          //     "${mfData.expenseRatio}",
          //     "LUMPSUM MIN.",
          //     "${mfData.purchaseMinAmount}",
          //     "AUM (Cr.)",
          //     (double.parse(mfStockData.aUM!.isEmpty
          //                 ? "0.00"
          //                 : mfStockData.aUM!) /
          //             10000000)
          //         .toStringAsFixed(2),
          //     theme),
          // const SizedBox(height: 14),
          // rowOfInfoData(
          //     "SETTLEMENT TYPE",
          //     "${mfStockData.sETTLEMENTTYPE}",
          //     "LOCK-IN",
          //     "${mfStockData.lockInPeriod}",
          //     "SCHEME TYPE",
          //     "${mfStockData.nAVSchemeType}",
          //     theme),
          // const SizedBox(height: 12),
        ],
      ),
    );
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      String title3, String value3, ThemesProvider theme) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title1,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(value1,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w600)),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title2,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(
                  value2,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title3,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(value3,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w600)),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ]))
        ]);
  }
}
