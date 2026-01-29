import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart' show MyntColors, MyntFonts;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../provider/thems.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import '../../../sharedWidget/custom_back_btn.dart';

class MFCAGRCAL extends StatefulWidget {
  final VoidCallback? onBack;
  const MFCAGRCAL({super.key, this.onBack});

  @override
  State<MFCAGRCAL> createState() => _MFCAGRCALState();
}

class _MFCAGRCALState extends State<MFCAGRCAL> {
  final TextEditingController _principalCtrl =
      TextEditingController(text: '5000');
  final TextEditingController _finalAmountCtrl =
      TextEditingController(text: '25000');
  double _tenureYears = 5.0;
  String _cagrResult = '38.01'; // Default result based on initial values
  double _principalSliderValue = 5000; // Match initial value
  double _finalAmountSliderValue = 25000; // Match initial value

  @override
  void initState() {
    super.initState();

    // Calculate initial CAGR
    calculateCAGR();

    // Add listeners to text controllers
    _principalCtrl.addListener(_onPrincipalChanged);
    _finalAmountCtrl.addListener(_onFinalAmountChanged);
  }

  void _onPrincipalChanged() {
    final value = double.tryParse(_principalCtrl.text) ?? 0.0;
    if (value > 0) {
      setState(() {
        _principalSliderValue = value.clamp(1, 10000000);
      });
      calculateCAGR();
    }
  }

  void _onFinalAmountChanged() {
    final value = double.tryParse(_finalAmountCtrl.text) ?? 0.0;
    if (value > 0) {
      setState(() {
        _finalAmountSliderValue = value.clamp(1, 10000000);
      });
      calculateCAGR();
    }
  }

  void calculateCAGR() {
    final principal = double.tryParse(_principalCtrl.text) ?? 0.0;
    final finalAmount = double.tryParse(_finalAmountCtrl.text) ?? 0.0;

    if (principal > 0 && finalAmount > 0 && _tenureYears > 0) {
      try {
        final first = finalAmount / principal;
        final second = pow(first, 1 / _tenureYears) - 1;
        final cagr = second * 100;

        setState(() {
          _cagrResult = cagr.toStringAsFixed(2);
        });
      } catch (e) {
        setState(() {
          _cagrResult = '0.00';
        });
      }
    } else {
      setState(() {
        _cagrResult = '0.00';
      });
    }
  }

  @override
  void dispose() {
    // Remove listeners to prevent memory leaks
    _principalCtrl.removeListener(_onPrincipalChanged);
    _finalAmountCtrl.removeListener(_onFinalAmountChanged);

    // Dispose controllers
    _principalCtrl.dispose();
    _finalAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final isDarkMode = theme.isDarkMode;

      // Safely parse values for chart
      final double principal = double.tryParse(_principalCtrl.text) ?? 0.0;
      final double finalAmount = double.tryParse(_finalAmountCtrl.text) ?? 0.0;

      final List<ChartData> donutChart = [
        ChartData('Initial Investment Value', principal, colors.colorBlack),
        ChartData('Final Investment', finalAmount, const Color(0xff015FEC)),
      ];

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            elevation: 0,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: widget.onBack != null
                ? IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 15,
                      color: isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  )
                : const CustomBackBtn(),
            title: Text(
              "CAGR Calculator",
              style: MyntWebTextStyles.title(context, fontWeight: FontWeight.w600),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.2)
                    : colors.textSecondaryLight.withOpacity(0.2),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? colors.darkGrey : colors.colorWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.2)
                        : colors.textSecondaryLight.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                // Left side - Input controls
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Initial Investment
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Initial Investment",
                              style: MyntWebTextStyles.bodyMedium(
                                context,
                                color: isDarkMode
                                    ? MyntColors.textPrimaryDark
                                    : MyntColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 150,
                              child: MyntTextField(
                                controller: _principalCtrl,
                                placeholder: '10000',
                                textAlign: TextAlign.start,
                                height: 40,
                                backgroundColor: isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                leadingIcon: assets.ruppeIcon,
                                onChanged: (value) {
                                  _onPrincipalChanged();
                                },
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Initial Investment Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4.0,
                            activeTrackColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            inactiveTrackColor: theme.isDarkMode
                                ? colors.textSecondaryDark.withOpacity(0.3)
                                : colors.textSecondaryLight.withOpacity(0.1),
                            thumbColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            overlayColor: const Color(0xFFCCCCCC),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 0.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Slider(
                              min: 1,
                              max: 10000000,
                              value: _principalSliderValue.clamp(1, 10000000),
                              label: _principalSliderValue.toStringAsFixed(0),
                              onChanged: (value) {
                                setState(() {
                                  _principalSliderValue = value;
                                  _principalCtrl.text = value.toStringAsFixed(0);
                                });
                                calculateCAGR();
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Final Investment
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Final Investment",
                              style: MyntWebTextStyles.bodyMedium(
                                context,
                                color: isDarkMode
                                    ? MyntColors.textPrimaryDark
                                    : MyntColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 150,
                              child: MyntTextField(
                                controller: _finalAmountCtrl,
                                placeholder: '10000',
                                textAlign: TextAlign.start,
                                height: 40,
                                backgroundColor: isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                leadingIcon: assets.ruppeIcon,
                                onChanged: (value) {
                                  _onFinalAmountChanged();
                                },
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Final Investment Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4.0,
                            activeTrackColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            inactiveTrackColor: theme.isDarkMode
                                ? colors.textSecondaryDark.withOpacity(0.3)
                                : colors.textSecondaryLight.withOpacity(0.1),
                            thumbColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            overlayColor: const Color(0xFFCCCCCC),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 0.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Slider(
                              min: 1,
                              max: 10000000,
                              value: _finalAmountSliderValue.clamp(1, 10000000),
                              label: _finalAmountSliderValue.toStringAsFixed(0),
                              onChanged: (value) {
                                setState(() {
                                  _finalAmountSliderValue = value;
                                  _finalAmountCtrl.text = value.toStringAsFixed(0);
                                });
                                calculateCAGR();
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Duration of Investment
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Duration of Investment (Years)",
                              style: MyntWebTextStyles.bodyMedium(
                                context,
                                color: isDarkMode
                                    ? MyntColors.textPrimaryDark
                                    : MyntColors.textPrimary,
                              ),
                            ),
                            Text(
                              "${_tenureYears.toStringAsFixed(0)} Yr",
                              style: MyntWebTextStyles.bodyMedium(
                                context,
                                color: isDarkMode
                                    ? MyntColors.textPrimaryDark
                                    : MyntColors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Duration Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4.0,
                            activeTrackColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            inactiveTrackColor: theme.isDarkMode
                                ? colors.textSecondaryDark.withOpacity(0.3)
                                : colors.textSecondaryLight.withOpacity(0.1),
                            thumbColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            overlayColor: const Color(0xFFCCCCCC),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 0.0),
                          ),
                          child: Slider(
                            value: _tenureYears.clamp(1, 50),
                            min: 1,
                            max: 50,
                            divisions: 49,
                            label: "${_tenureYears.toStringAsFixed(0)} Yr",
                            onChanged: (value) {
                              setState(() {
                                _tenureYears = value;
                              });
                              calculateCAGR();
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Estimation Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Estimation",
                              style: MyntWebTextStyles.title(
                                context,
                                color: isDarkMode
                                    ? MyntColors.textPrimaryDark
                                    : MyntColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Initial and Final Values
                            resultRow("Initial Value",
                                int.tryParse(_principalCtrl.text) ?? 0, theme, context),
                            const SizedBox(height: 8),
                            resultRow("Final Value",
                                int.tryParse(_finalAmountCtrl.text) ?? 0, theme, context),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                // Right side - Chart
                Expanded(
                  flex: 1,
                  child: Center(
                    child: SizedBox(
                      width: 380,
                      height: 380,
                      child: SfCircularChart(
                    margin: EdgeInsets.zero,
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CAGR',
                              textAlign: TextAlign.center,
                              style: MyntWebTextStyles.para(
                                context,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$_cagrResult %",
                              textAlign: TextAlign.center,
                              style: MyntWebTextStyles.title(
                                context,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    series: <DoughnutSeries<ChartData, String>>[
                      DoughnutSeries<ChartData, String>(
                        animationDuration: 0,
                        radius: '140',
                        innerRadius: '70%',
                            dataSource: donutChart,
                            pointColorMapper: (ChartData data, _) => data.color,
                            dataLabelMapper: (ChartData data, _) => '${data.y}%',
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: false,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
              ],
            ),
          ),
        ),
          ),
        ),
      );
    });
  }

  Widget resultRow(String label, int value, ThemesProvider theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.circle,
                  color: label == 'Initial Value'
                      ? const Color.fromARGB(255, 146, 189, 153)
                      : const Color(0xff015FEC),
                  size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: MyntWebTextStyles.bodyMedium(
                  context,
                  color: theme.isDarkMode
                      ? MyntColors.textPrimaryDark
                      : MyntColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            "₹ ${value.toStringAsFixed(0)}",
            style: MyntWebTextStyles.bodyMedium(
              context,
              color: theme.isDarkMode
                  ? MyntColors.textPrimaryDark
                  : MyntColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}
