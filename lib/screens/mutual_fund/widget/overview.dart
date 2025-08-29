import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/mf_model/mf_nav_graph_model.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class MFOverview extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFOverview({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfProvide = ref.watch(mfProvider);
    final navGraph = mfProvide.navGraph;
    final factSheetData = mfProvide.factSheetDataModel?.data;

    // Early return if essential data is missing
    if (factSheetData == null) {
      return const SizedBox();
    }

    final isDarkMode = theme.isDarkMode;

    // Create tooltip behavior for chart
    final interactiveTooltip = InteractiveTooltip(
      enable: true,
      format: 'Nav : point.y',
      borderColor: colors.colorBlue,
      textStyle: const TextStyle(color: Colors.white),
    );

    // Safely create data source
    final List<NavGraphData> dataSource =
        mfProvide.singleloader == true ? [] : (navGraph?.data?.toList() ?? []);

    return Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Fund Metrics
              _buildFundMetrics(context, theme, mfProvide),
              // NAV Chart
              Container(
                margin: const EdgeInsets.only(top: 14, bottom: 12),
                height: 320,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: isDarkMode ? colors.colorBlack : Colors.white,
                  border: Border.all(
                    color: isDarkMode ? colors.colorBlack : Colors.transparent,
                  ),
                ),
                child: SfCartesianChart(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  backgroundColor:
                      isDarkMode ? colors.colorBlack : Colors.white,
                  borderWidth: 0,
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    isVisible: false,
                    labelStyle: textStyle(
                      isDarkMode ? colors.colorWhite : colors.colorBlack,
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
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    tooltipSettings: interactiveTooltip,
                    tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                  ),
                  series: <CartesianSeries<NavGraphData, String>>[
                    AreaSeries<NavGraphData, String>(
                      name: "Historical NAV",
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          isDarkMode
                              ? colors.colorBlack
                              : Colors.white.withOpacity(1),
                          isDarkMode
                              ? colors.colorBlack
                              : Colors.white.withOpacity(1),
                          isDarkMode
                              ? colors.colorBlack
                              : Colors.white.withOpacity(1),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      isVisibleInLegend: false,
                      enableTooltip: true,
                      borderColor: colors.colorBlue,
                      borderWidth: 2,
                      dataSource: dataSource,
                      xValueMapper: (NavGraphData data, _) {
                        if (data.navDate == null) return "";
                        return data.navDate!.length > 14
                            ? data.navDate!
                                .substring(0, data.navDate!.length - 14)
                            : data.navDate!;
                      },
                      yValueMapper: (NavGraphData data, _) => data.nav,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                      align: TextAlign.right,
                      text: "Trailing Returns (%)",
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 0),
                  Icon(
                    Icons.circle,
                    size: 16,
                    color: theme.isDarkMode ? colors.profitDark  : colors.profitLight,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  TextWidget.paraText(
                      align: TextAlign.start,
                      text: "Benchmark",
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  Expanded(
                    child: TextWidget.paraText(
                        align: TextAlign.start,
                        text: "  (${factSheetData.benchmark ?? ""})",
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Returns Grid
              if (mfProvide.mfReturnsGridview.isNotEmpty)
                GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.3,
                  children: List.generate(mfProvide.mfReturnsGridview.length,
                      (index) {
                    final item = mfProvide.mfReturnsGridview[index];
                    final value = item['value']?.toString() ?? "0";
                    final isNegative = value.startsWith("-");
                    final returnValue = item['return']?.toString() ?? "0";
                    final isReturnNegative = returnValue.startsWith("-");

                    return Container(
                      decoration: BoxDecoration(
                        color: isNegative
                            ? isDarkMode
                                ? colors.lossDark.withOpacity(0.1)
                                : colors.lossLight.withOpacity(0.1)
                            : isDarkMode
                                ? colors.profitDark.withOpacity(0.1)
                                : colors.profitLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
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
                                  const SizedBox(height: 8),
                                  TextWidget.subText(
                                      align: TextAlign.start,
                                      text: "$value%",
                                      color: isNegative
                                          ? colors.darkred
                                          : colors.ltpgreen,
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                  const SizedBox(height: 3),
                                  TextWidget.paraText(
                                      align: TextAlign.start,
                                      text: item['durName']?.toString() ?? "",
                                      color: isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 0),
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
                                  color: isReturnNegative
                                      ? isDarkMode
                                          ? colors.lossDark.withOpacity(0.5)
                                          : colors.lossLight.withOpacity(0.3)
                                      : isDarkMode
                                          ? colors.profitDark.withOpacity(0.5)
                                          : colors.profitLight.withOpacity(0.3),
                                  borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(5))),
                              child: TextWidget.paraText(
                                  align: TextAlign.start,
                                  text: "$returnValue%",
                                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                  fw: 0),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                )
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child:   
                    TextWidget.subText(
                      text: "No returns data available",
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),  
                    
                   
                  ),
                ),
            ],
          ),
        ));
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

  Widget _buildFundMetrics(
      BuildContext context, ThemesProvider theme, MFProvider mfData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricColumn("Aum (cr)",
            _formatAum(mfData.factSheetDataModel?.data?.AUM), theme),
        _buildMetricColumn("NAV",
            _formatValue(mfData.factSheetDataModel?.data?.currentNAV), theme),
        _buildMetricColumn(
            "Min. Inv",
            _formatValue(mfData.factSheetDataModel?.data?.purchaseMinAmount),
            theme),
        _buildMetricColumn("5Yr CAGR",
            _formatYearData(mfData.factSheetDataModel?.data?.fiveYear), theme),
      ],
    );
  }

  Widget _buildMetricColumn(String title, String value, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
            text: title,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0),
        const SizedBox(height: 6),
        TextWidget.subText(
            text: value,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0),
      ],
    );
  }

  String _formatAum(String? aum) {
    if (aum == null || aum.isEmpty) return "0.00";
    try {
      return double.parse(aum).toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  String _formatValue(String? value) {
    return value?.isEmpty ?? true ? "0.00" : value!;
  }

  String _formatYearData(String? yearData) {
    if (yearData == null || yearData.isEmpty) return "0.00";
    return "$yearData%";
  }
}
