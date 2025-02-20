import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/mf_model/mf_nav_graph_model.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class MFOverview extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFOverview({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    late TooltipBehavior _tooltipBehavior;
    final theme = watch(themeProvider);
    final mfData = watch(mfProvider);
    // factSheetDataModel!.data!;
    final navGraph = watch(mfProvider).navGraph;
    final mfProvide = watch(mfProvider);
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      opacity: 0,
      activationMode: ActivationMode.none,
      shouldAlwaysShow: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            height: 30,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                point.x,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
    var interactiveTooltip = InteractiveTooltip(
      enable: true,
      format: 'Nav : point.y',
      borderColor: colors.colorBlue,
      textStyle: TextStyle(color: Colors.white), 
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // const SizedBox(height: 5),


Container(
  

  margin: const EdgeInsets.only(top: 14, bottom: 12),
  height: 320,
     
  width: MediaQuery.of(context).size.width,
  decoration: BoxDecoration(
    color: Colors.white, 
    border: Border.all(
      color: Colors.transparent, 
    ),
  ),
  child: SfCartesianChart(
 
  margin: const EdgeInsets.symmetric(horizontal: 0),
  backgroundColor: Colors.white, 
  borderWidth: 0, 
   plotAreaBorderWidth: 0,
  primaryXAxis: CategoryAxis(
    isVisible: false,
    labelStyle: textStyle(
      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
      10,
      FontWeight.w500,
    ),
    majorGridLines: const MajorGridLines(width: 0),
    axisLine: const AxisLine(width: 0), 
  ),
  primaryYAxis: NumericAxis(
    isVisible: false,

    majorGridLines: const MajorGridLines(width: 0),
  ),
  // tooltipBehavior: TooltipBehavior(
  //   enable: true,
  //   color: const Color.fromARGB(255, 17, 16, 16),
  //   header: '', 
  //   format: 'NAV: ₹point.y | point.x', 
  // ),
    trackballBehavior: TrackballBehavior(
    enable: true,
    activationMode: ActivationMode.singleTap, 
    tooltipSettings: interactiveTooltip,
    tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    // tooltipAlignment: ChartAlignment.near,
  ),

  series: <CartesianSeries<NavGraphData, String>>[
    AreaSeries<NavGraphData, String>(
      name: "Historical NAV",
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(1),
          Colors.white.withOpacity(1),
          Colors.white.withOpacity(1),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      isVisibleInLegend: false, 
      isVisible: true,
      enableTooltip: true,
      borderColor: colors.colorBlue,
      borderWidth: 2,
      dataSource: navGraph!.data!,
      xValueMapper: (NavGraphData data, _) =>
          data.navDate!.substring(0, data.navDate!.length - 14),
      yValueMapper: (NavGraphData data, _) => data.nav,
    

    ),
  ],
)

),



  //         Text("${mfData.name}",
  //             style: textStyle(
  //                 theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
  //                 17,
  //                 FontWeight.w600)),
  //         const SizedBox(height: 8),
  //         ReadMoreText("${mfData.overview1}",
  //              style: textStyle(const Color(0xff666666), 14, FontWeight.w500).copyWith(
  //   height: 1.5, 
  // ),
  //             textAlign: TextAlign.start,
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
          // const SizedBox(height: 22),
          // Text("Volatility Measures",
          //     style: textStyle(
          //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          //         17,
          //         FontWeight.w600)),
          // const SizedBox(height: 15),
          // rowOfInfoData("ALPHA", "${mfData.alpha}", "SHARP RATIO",
     

          //     "${mfData.sharpRatio}", "MEAN", "${mfData.mean}", theme,),
          // const SizedBox(height: 14),
          // rowOfInfoData("BETA", "${mfData.beta}", "STD. DEVIATION",
          //     "${mfData.standardDev}", "YTM", "${mfData.ytm}", theme),
          // const SizedBox(height: 14),
          // rowOfInfoData(
          //     "MODIFIED DURATION",
          //     "${mfData.modifiedDuration}",
          //     "AVG. MATURITY",
          //     "${mfData.avgMat}",
          //     "FACE VALUE",
          //     "${mfStockData.faceValue}",
          //     theme),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Trailing Returns (%)",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      17,
                      FontWeight.w600)),
       

              // Row(
              //   children: [
              //     Icon(
              //       Icons.circle,
              //       size: 16,
              //       color: colors.ltpgreen,
              //     ),
              //     Text(" Benchmark",
              //         style: textStyle(
              //             theme.isDarkMode
              //                 ? colors.colorWhite
              //                 : colors.colorBlack,
              //             13,
              //             FontWeight.w500)),
              //   ],
              // ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
  children: [
   
    const SizedBox(width: 0),
    Icon(
      Icons.circle,
      size: 16,
      color: colors.ltpgreen,
    ),
    Text(
      " Benchmark",
      style: textStyle(
        theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        13,
        FontWeight.w500,
      ),
    ),
     Expanded(
      child: Text(
        "  (${mfData.factSheetDataModel!.data!.benchmark})",
        style: textStyle(
          theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          13,
          FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis, // Add ellipsis for long text
        maxLines: 1, // Limit to one line
      ),
    ),
  ],
),

          const SizedBox(height: 25),

          // Text("${mfData.benchmark}"),
          //  Text(" Benchmark",
          //             style: textStyle(
          //                 theme.isDarkMode
          //                     ? colors.colorWhite
          //                     : colors.colorBlack,
          //                 13,
          //                 FontWeight.w500)),
          GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 14,
            childAspectRatio: 1.3,
            children:
                List.generate(mfProvide.mfReturnsGridview.length, (index) {
              return Container(
                decoration: BoxDecoration(
                    color: Color(mfProvide.mfReturnsGridview[index]['value']
                            .toString()
                            .startsWith("-")
                        ? 0xffFFFCFB
                        : 0xffFBFFFA),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xff999999), width: .2)),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                "${mfProvide.mfReturnsGridview[index]['value']}%",
                                style: textStyle(
                                    mfProvide.mfReturnsGridview[index]['value']
                                            .toString()
                                            .startsWith("-")
                                        ? colors.darkred
                                        : colors.ltpgreen,
                                    16,
                                    FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text(
                                "${mfProvide.mfReturnsGridview[index]['durName']}",
                                style: textStyle(const Color(0xff666666), 12,
                                    FontWeight.w500)),
                            const SizedBox(height: 3),

                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            color: Color(mfProvide.mfReturnsGridview[index]
                                        ['return']
                                    .toString()
                                    .startsWith("-")
                                ? 0xffFF1717
                                : 0xff43A833),
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10))),
                        child: Text(
                            "${mfProvide.mfReturnsGridview[index]['return']}%",
                            style: textStyle(
                                colors.colorWhite, 14, FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 25),
          // Text("Historical NAV",
          //     style: textStyle(
          //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          //         17,
          //         FontWeight.w600)),
          // const SizedBox(height: 15),

          // Container(
          //     margin: const EdgeInsets.only(top: 14, bottom: 12),
          //     height: 320,
          //     width: MediaQuery.of(context).size.width,
          //     child: SfCartesianChart(
          //         margin: const EdgeInsets.symmetric(horizontal: 0),
          //         primaryXAxis: CategoryAxis(
          //           labelStyle: textStyle(
          //               theme.isDarkMode
          //                   ? colors.colorWhite
          //                   : colors.colorBlack,
          //               10,
          //               FontWeight.w500),
          //           majorGridLines: const MajorGridLines(width: 0),
          //         ),
          //         primaryYAxis: NumericAxis(
          //             labelStyle: textStyle(
          //                 theme.isDarkMode
          //                     ? colors.colorWhite
          //                     : colors.colorBlack,
          //                 12,
          //                 FontWeight.w500),
          //             majorGridLines: const MajorGridLines(width: 0)),
          //         tooltipBehavior:
          //             TooltipBehavior(enable: true, color: Colors.transparent),
          //         series: <CartesianSeries<NavGraphData, String>>[
          //           AreaSeries(
          //             name: "Historical NAV",
          //             gradient: LinearGradient(
          //                 begin: Alignment.topCenter,
          //                 end: Alignment.bottomCenter,
          //                 colors: [
          //                   colors.colorBlue.withOpacity(.99),
          //                   colors.colorBlue.withOpacity(.5),
          //                   colors.colorBlue.withOpacity(.1)
          //                 ],
          //                 stops: const [
          //                   0.1,
          //                   0.4,
          //                   1
          //                 ]),
          //             isVisibleInLegend: true,
          //             isVisible: true,
          //             enableTooltip: true,
          //             borderColor: colors.colorBlue,
          //             borderWidth: 3,
          //             legendIconType: LegendIconType.image,
          //             dataSource: navGraph!.data!,
          //             xValueMapper: (NavGraphData data, _) =>
          //                 data.navDate!.substring(0, data.navDate!.length - 14),
          //             yValueMapper: (NavGraphData data, _) => data.nav,
          //           ),
          //         ])),
       
       
       
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
