import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../models/mf_model/mutual_fundmodel.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../res/global_state_text.dart';

class MFPerformance extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFPerformance({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfProvide = ref.watch(mfProvider);
    final factSheetData = mfProvide.factSheetDataModel?.data;

    // Early return if essential data is missing
    if (factSheetData == null) {
      return const SizedBox();
    }
    
    final isDarkMode = theme.isDarkMode;
    
    // Only render if we have sheet graph data
    if (mfProvide.sheetGraph == null) {
      return const SizedBox();
    }
    
    // Safe access of risk data with default fallback
    final riskLevel = factSheetData.risk ?? "0";
    final int riskValue = int.tryParse(riskLevel) ?? 0;
    
    // Map risk value to text
    final String riskText = riskValue == 1 
        ? "Low"
        : riskValue == 2
            ? "Moderately Low"
            : riskValue == 3
                ? "Moderate"
                : riskValue == 4
                    ? "Moderately High"
                    : riskValue == 5
                        ? "High"
                        : "Very High";
                        
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          TextWidget.headText(
            text: "Riskometer",
            theme: isDarkMode,
            fw: 1,
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Container(
              width: double.infinity,
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xffEEF0F2), width: 1.5),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  SvgPicture.asset(
                    riskValue > 3 ? assets.highRisk : assets.lowRisk,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 26),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                        text: "RISK METER",
                        theme: isDarkMode,
                        fw: 0,
                        color: const Color(0xff999999),
                      ),
                      const SizedBox(height: 4),
                      TextWidget.titleText(
                        text: riskText,
                        theme: isDarkMode,
                        fw: 0,
                        color: colors.colorBlack,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      ThemesProvider theme) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                TextWidget.captionText(
                    text: title1,
                    theme: theme.isDarkMode,
                    fw: 3,
                    color: const Color(0xff666666)),
                const SizedBox(height: 4),
                TextWidget.subText(
                    text: value1,
                    theme: theme.isDarkMode,
                    fw: 1),
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
                TextWidget.captionText(
                    text: title2,
                    theme: theme.isDarkMode,
                    fw: 3,
                    color: const Color(0xff666666)),
                const SizedBox(height: 4),
                TextWidget.subText(
                  text: value2,
                  theme: theme.isDarkMode,
                  fw: 1,
                ),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          // Expanded(
          //     child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //       Text(title3,
          //           style: textStyle(
          //               const Color(0xff666666), 10, FontWeight.w400)),
          //       const SizedBox(height: 4),
          //       Text(value3,
          //           style: textStyle(
          //               theme.isDarkMode
          //                   ? colors.colorWhite
          //                   : colors.colorBlack,
          //               14,
          //               FontWeight.w600)),
          //       const SizedBox(height: 2),
          //       Divider(
          //           color: theme.isDarkMode
          //               ? colors.darkColorDivider
          //               : colors.colorDivider)
          //     ]))
        ]);
  }
}
