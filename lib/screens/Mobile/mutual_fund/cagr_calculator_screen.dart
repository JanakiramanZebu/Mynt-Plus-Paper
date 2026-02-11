import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart' show MyntColors, MyntFonts;
import '../../../../provider/thems.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MFCAGRCAL extends StatefulWidget {
  final VoidCallback? onBack;
  const MFCAGRCAL({super.key, this.onBack});

  @override
  State<MFCAGRCAL> createState() => _MFCAGRCALState();
}

class _MFCAGRCALState extends State<MFCAGRCAL> {
  final TextEditingController _principalCtrl =
      TextEditingController(text: '10000');
  final TextEditingController _finalAmountCtrl =
      TextEditingController(text: '25000');
  late TextEditingController _tenureCtrl; // Controller for editable tenure text
  double _tenureYears = 2.0; // Default matches screenshot
  String _cagrResult = '58.11'; // Default matches screenshot example

  @override
  void initState() {
    super.initState();
    _tenureCtrl =
        TextEditingController(text: _tenureYears.toStringAsFixed(0)); // Initialize ctrl
    calculateCAGR();
    _principalCtrl.addListener(calculateCAGR);
    _finalAmountCtrl.addListener(calculateCAGR);
  }

  @override
  void dispose() {
    _principalCtrl.removeListener(calculateCAGR);
    _finalAmountCtrl.removeListener(calculateCAGR);
    _principalCtrl.dispose();
    _finalAmountCtrl.dispose();
    _tenureCtrl.dispose(); // Dispose ctrl
    super.dispose();
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
      // Handle cases where calculation isn't possible or inputs are invalid
       setState(() {
          _cagrResult = '0.00';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final isDarkMode = theme.isDarkMode;

      // Chart colors using MyntColors (matching SIP calculator)
      final principalColor = resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary);
      final gainsColor = resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textPrimary,
      );
      final totalColor = resolveThemeColor(
        context,
        dark: MyntColors.profitDark,
        light: MyntColors.profit,
      );

      return Scaffold(
        backgroundColor: resolveThemeColor(
          context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor,
        ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            elevation: 0,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            backgroundColor: resolveThemeColor(
              context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor,
            ),
            leading: widget.onBack != null
                ? IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 15,
                      color: resolveThemeColor(
                        context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary,
                      ),
                    ),
                  )
                : const CustomBackBtn(),
            title: Text(
              "Calculator",
              style: MyntWebTextStyles.title(context, fontWeight: FontWeight.w600),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.divider,
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: resolveThemeColor(
                  context,
                  dark: Colors.transparent,
                  light: MyntColors.card,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CAGR Calculator",
                      style: MyntWebTextStyles.title(context, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Use the CAGR tool to see how much your investments have grown over time.",
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: MyntColors.textSecondary,
                      ).copyWith(fontSize: 13),
                      maxLines: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Main Content Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Input controls
                    Expanded(
                      flex: 1,
                      child: _buildInputSection(isDarkMode, theme),
                    ),

                    const SizedBox(width: 48),

                    // Right side - Estimation
                    Expanded(
                      flex: 1,
                      child: _buildEstimationSection(
                        isDarkMode, theme,
                        principalColor: principalColor,
                        gainsColor: gainsColor,
                        totalColor: totalColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        ),
      );
    });
  }

  Widget _buildInputSection(bool isDarkMode, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldWithLabel(
          label: "Initial Investment",
          controller: _principalCtrl,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 32),
        _buildTextFieldWithLabel(
          label: "Final Investment (Maturity)",
          controller: _finalAmountCtrl,
          isDarkMode: isDarkMode,
        ),

        const SizedBox(height: 32),

        // Duration of Investment
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Duration of Investment",
                    style: MyntWebTextStyles.title(
                      context,
                      fontWeight: MyntFonts.medium,
                      color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                    ),
                  ),
                   SizedBox(
                       width: 100,
                       child: Stack(
                         children: [
                           MyntTextField(
                             controller: _tenureCtrl,
                             placeholder: '2',
                             textAlign: TextAlign.center,
                             keyboardType: TextInputType.number,
                             inputFormatters: [
                               FilteringTextInputFormatter.digitsOnly
                             ],
                             onChanged: _onTenureChanged,
                           ),
                           Positioned(
                             right: 12,
                             top: 0,
                             bottom: 0,
                             child: Center(
                               child: IgnorePointer(
                                 child: Text(
                                   "Yr",
                                   style: MyntWebTextStyles.bodySmall(
                                     context,
                                     color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                                   ),
                                 ),
                               ),
                             ),
                           ),
                         ],
                       ),
                     )
                ],
              ),
               const SizedBox(height: 4),
              _buildCustomSlider(
                value: _tenureYears,
                min: 1,
                max: 30,
                divisions: 29,
                onChanged: (value) {
                  setState(() {
                    _tenureYears = value;
                    _tenureCtrl.text = value.toStringAsFixed(0); // Sync text field
                  });
                  calculateCAGR();
                },
              ),
            ],
        )
      ],
    );
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: MyntWebTextStyles.title(
            context,
            fontWeight: MyntFonts.medium,
            color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        MyntTextField(
          controller: controller,
          height: 48,
          backgroundColor: resolveThemeColor(context, dark: MyntColors.cardDark, light: const Color(0xffF5F7FA)),
          borderRadius: 8,
          leadingWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "₹",
                  style: MyntWebTextStyles.bodyMedium(
                    context,
                    color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          placeholder: "",
        ),
      ],
    );
  }

  Widget _buildCustomSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 6.0,
        activeTrackColor: resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary.withOpacity(0.5)),
        inactiveTrackColor: resolveThemeColor(
          context,
          dark: MyntColors.dividerDark,
          light: MyntColors.divider,
        ),
        thumbColor: resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary),
        overlayColor: resolveThemeColor(context, dark: MyntColors.primaryDark.withOpacity(0.1), light: MyntColors.primary.withOpacity(0.1)),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions > 0 ? divisions : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildEstimationSection(
    bool isDarkMode,
    ThemesProvider theme, {
    required Color principalColor,
    required Color gainsColor,
    required Color totalColor,
  }) {
      final double principal = double.tryParse(_principalCtrl.text) ?? 0.0;
      final double finalAmount = double.tryParse(_finalAmountCtrl.text) ?? 0.0;

      double gains = 0;
      if (finalAmount > principal) {
        gains = finalAmount - principal;
      }

      final List<ChartData> chartData = [
          ChartData('Invested', principal, principalColor),
          ChartData('Gain', gains, gainsColor),
      ];

      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Estimation",
              style: MyntWebTextStyles.title(context, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Chart
                Expanded(
                  flex: 6,
                  child: Center(
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: SfCircularChart(
                        margin: EdgeInsets.zero,
                        annotations: <CircularChartAnnotation>[
                          CircularChartAnnotation(
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 Text(
                                  "CAGR",
                                  style: MyntWebTextStyles.bodySmall(
                                    context,
                                    color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                                  ),
                                ),
                                Text(
                                  "$_cagrResult%",
                                  style: MyntWebTextStyles.head(
                                    context,
                                    fontWeight: FontWeight.bold,
                                    color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                                  ).copyWith(fontSize: 20),
                                ),
                              ],
                            ),
                          )
                        ],
                        series: <CircularSeries>[
                          // Outer Ring (Total Amount)
                          DoughnutSeries<ChartData, String>(
                            radius: '100%',
                            innerRadius: '92%',
                            dataSource: [
                              ChartData('Total', 1, totalColor)
                            ],
                            pointColorMapper: (ChartData data, _) => data.color,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            strokeWidth: 0,
                          ),
                          // Inner Ring
                          DoughnutSeries<ChartData, String>(
                            radius: '82%',
                            innerRadius: '68%',

                          dataSource: chartData,
                          pointColorMapper: (ChartData data, _) => data.color,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          cornerStyle: CornerStyle.bothFlat,
                          strokeWidth: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                 const SizedBox(width: 40),

                 // Legend
                 Expanded(
                   flex: 6,
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       _buildLegendItem(
                         "Initial Investment",
                         principal.toInt(),
                         principalColor,
                       ),
                       const SizedBox(height: 24),
                       _buildLegendItem(
                         "Wealth Gain",
                         gains.toInt(),
                         gainsColor,
                       ),
                       const SizedBox(height: 24),
                       _buildLegendItem(
                         "Maturity Value",
                         finalAmount.toInt(),
                         totalColor,
                       ),
                     ],
                   ),
                 )
              ],
            ),
          ],
      );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: MyntWebTextStyles.bodyMedium(
                context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "₹ ${value.toString()}",
               style: MyntWebTextStyles.head(
                 context,
                 fontWeight: FontWeight.bold,
                 darkColor: MyntColors.textPrimaryDark,
                 lightColor: MyntColors.textPrimary,
               ),
            ),
          ],
        ),
      ],
    );
  }
  void _onTenureChanged(String value) {
     if (value.isEmpty) return;
    double? val = double.tryParse(value);
    if (val != null) {
      if (mounted) {
         setState(() {
          _tenureYears = val.clamp(1, 30);
         });
         calculateCAGR();
      }
    }
  }
}



class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
