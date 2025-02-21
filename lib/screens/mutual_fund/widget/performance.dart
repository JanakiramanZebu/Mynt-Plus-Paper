import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readmore/readmore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/mf_model/mf_factsheet_graph.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class MFPerformance extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFPerformance({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final mfData = watch(mfProvider);
    final mfDataprofile = watch(mfProvider).factSheetDataModel!.data!;
    // final navGraph = watch(mfProvider).navGraph;
    final mfProvide = watch(mfProvider);
    if (mfData.sheetGraph != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("Riskometer",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    18,
                    FontWeight.w600)),
            // const SizedBox(height: 10),

          Padding(
  padding: const EdgeInsets.only(bottom: 8, top: 8),
  child: Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Container(
      width: double.infinity, // Set the width to 100% of its parent
      height: 80, // Set the height to 200
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffEEF0F2), width: 1.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
         SvgPicture.asset(
  int.parse(mfData.factSheetDataModel!.data!.risk ?? "0") > 3
      ? assets.highRisk
      : assets.lowRisk,
  height: 50, // Keep height fixed to 40
  width: 50, // Increase width to 200
  fit: BoxFit.contain, // Ensure image scales correctly to fit the width and height
),

          const SizedBox(width: 26), // Increased space between image and text
          Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the text vertically
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "RISK METER",
                style: textStyle(const Color(0xff999999), 14, FontWeight.w500), // Adjusted text size
              ),
              const SizedBox(height: 4), // Increased space between title and value
              Text(
                mfData.factSheetDataModel!.data!.risk == "1"
                    ? "Low"
                    : mfData.factSheetDataModel!.data!.risk == "2"
                        ? "Moderately Low"
                        : mfData.factSheetDataModel!.data!.risk == "3"
                            ? "Moderate"
                            : mfData.factSheetDataModel!.data!.risk == "4"
                                ? "Moderately High"
                                : mfData.factSheetDataModel!.data!.risk == "5"
                                    ? "High"
                                    : "Very High",
                style: textStyle(colors.colorBlack, 16, FontWeight.w500), // Adjusted text size
              ),
            ],
          ),
        ],
      ),
    ),
  ),
)



            // Text("${mfDataprofile.name}",
            //     style: textStyle(
            //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            //         14,
            //         FontWeight.w600)),
            // const SizedBox(height: 8),
            // ReadMoreText("${mfDataprofile.overview1}",
            //     style: textStyle(const Color(0xff666666), 12, FontWeight.w500)
            //         .copyWith(
            //       height: 1.5,
            //     ),
            //     textAlign: TextAlign.start,
            //     trimLines: 3,
            //     moreStyle: theme.isDarkMode
            //         ? textStyles.darkmorestyle
            //         : textStyles.morestyle,
            //     lessStyle: theme.isDarkMode
            //         ? textStyles.darkmorestyle
            //         : textStyles.morestyle,
            //     colorClickableText: const Color(0xff0037B7),
            //     trimMode: TrimMode.Line,
            //     trimCollapsedText: 'Read more',
            //     trimExpandedText: ' Read less'),
            // const SizedBox(height: 20),
            // const SizedBox(height: 22),
            // Text("Volatility Measures",
            //     style: textStyle(
            //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            //         17,
            //         FontWeight.w600)),
            // const SizedBox(height: 15),
            // rowOfInfoData("ALPHA", "${mfDataprofile.alpha}", "SHARP RATIO",

            //     "${mfDataprofile.sharpRatio}", "MEAN", "${mfDataprofile.mean}", theme,),
            // const SizedBox(height: 14),
            // rowOfInfoData("BETA", "${mfDataprofile.beta}", "STD. DEVIATION",
            //     "${mfDataprofile.standardDev}", "YTM", "${mfDataprofile.ytm}", theme),
            // const SizedBox(height: 14),
            // rowOfInfoData(
            //     "MODIFIED DURATION",
            //     "${mfDataprofile.modifiedDuration}",
            //     "AVG. MATURITY",
            //     "${mfDataprofile.avgMat}",
            //     "FACE VALUE",
            //     "${mfStockData.faceValue}",
            //     theme),

            // const SizedBox(height: 10),
            //       Text("Cumulative Performance of Last 3 Years",
            //           style: textStyle(
            //               theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            //               17,
            //               FontWeight.w600)),
            //       const SizedBox(height: 8),
            //       Text(
            //         "Cumulative Performance breakdown of ${mfProvide.factSheetDataModel!.data!.fundName} information",
            //         style: textStyle(const Color(0xff666666), 14, FontWeight.w500).copyWith(
            // height: 1.5),
            //       ),
            //       const SizedBox(height: 20),
            //       Container(
            //           margin: const EdgeInsets.only(top: 14, bottom: 12),
            //           height: 320,
            //           width: MediaQuery.of(context).size.width,
            //           child: SfCartesianChart(
            //               margin: const EdgeInsets.symmetric(horizontal: 0),
            //               primaryXAxis: CategoryAxis(
            //                 labelStyle: textStyle(
            //                     theme.isDarkMode
            //                         ? colors.colorWhite
            //                         : colors.colorBlack,
            //                     10,
            //                     FontWeight.w500),
            //                 majorGridLines: const MajorGridLines(width: 0),
            //               ),
            //               legend: Legend(
            //                   isVisible: true,
            //                   position: LegendPosition.bottom,
            //                   overflowMode: LegendItemOverflowMode.wrap),
            //               tooltipBehavior:
            //                   TooltipBehavior(enable: true, color: Colors.transparent),
            //               series: <CartesianSeries<SheetGraphData, String>>[
            //                 AreaSeries(
            //                   name: 'Scheme Returns',
            //                   color: colors.darkGrey.withOpacity(.1),
            //                   isVisibleInLegend: true,
            //                   isVisible: true,
            //                   enableTooltip: true,
            //                   borderColor: const Color(0xff1e53e5),
            //                   borderWidth: 3,
            //                   legendIconType: LegendIconType.circle,
            //                   dataSource: mfData.sheetGraph!.data!,
            //                   xValueMapper: (SheetGraphData data, _) => data.navDate!,
            //                   yValueMapper: (SheetGraphData data, _) =>
            //                       double.parse(data.schReturns ?? "0.00"),
            //                 ),
            //                 AreaSeries(
            //                   name: 'Benchmark Returns',
            //                   color: colors.darkGrey.withOpacity(.3),
            //                   isVisibleInLegend: true,
            //                   isVisible: true,
            //                   enableTooltip: true,
            //                   borderColor: const Color(0xffD86F10),
            //                   borderWidth: 3,
            //                   legendIconType: LegendIconType.image,
            //                   dataSource: mfData.sheetGraph!.data!,
            //                   xValueMapper: (SheetGraphData data, _) => data.navDate!,
            //                   yValueMapper: (SheetGraphData data, _) =>
            //                       double.parse(data.benchmarkReturns ?? "0.00"),
            //                 ),
            //               ])),

            // rowOfInfoData(
            //     "AUM(CR)",
            //     "${(double.parse(mfStockData.aUM!.isEmpty ? "0.00" : mfStockData.aUM!) / 10000000)}",
            //     " Expense Ratio",
            //     "${mfDataprofile.expenseRatio}",
            //     theme),
            // rowOfInfoData("NAV", "${mfDataprofile.currentNAV}", "5YR CAGR",
            //     "${mfDataprofile.d5Year}", theme),


                //  Padding(
                //                       padding: const EdgeInsets.only(bottom: 8,top: 8),
                //                       child: Padding(
                //                         padding: const EdgeInsets.only(top: 8),
                //                         child: Container(
                //                           padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                //                           decoration: BoxDecoration(
                //                             borderRadius: BorderRadius.circular(6),
                //                             border: Border.all(color: const Color(0xffEEF0F2), width: 1.5),
                //                           ),
                //                           child: Row(
                //                             children: [
                //                               SvgPicture.asset(
                //                                 int.parse(mfData.factSheetDataModel!.data!.risk ?? "0") > 3
                //                                     ? assets.highRisk
                //                                     : assets.lowRisk,
                //                                 height: 22,
                //                                 width: 22,
                //                               ),
                //                               const SizedBox(width: 12),
                //                               Column(
                //                                 children: [
                //                                   Text(
                //                                     "RISK METER",
                //                                     style: textStyle(const Color(0xff999999), 12, FontWeight.w500),
                //                                   ),
                //                                   const SizedBox(height: 2),
                //                                   Text(
                //                                     mfData.factSheetDataModel!.data!.risk == "1"
                //                                         ? "Low"
                //                                         : mfData.factSheetDataModel!.data!.risk == "2"
                //                                             ? "Moderately Low"
                //                                             : mfData.factSheetDataModel!.data!.risk == "3"
                //                                                 ? "Moderate"
                //                                                 : mfData.factSheetDataModel!.data!.risk == "4"
                //                                                     ? "Moderately High"
                //                                                     : mfData.factSheetDataModel!.data!.risk == "5"
                //                                                         ? "High"
                //                                                         : "Very High",
                //                                     style: textStyle(colors.colorBlack, 12, FontWeight.w500),
                //                                   ),
                //                                 ],
                //                               ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                                 
          ],
        ),
      );
    } else {
      return Container();
    }
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
