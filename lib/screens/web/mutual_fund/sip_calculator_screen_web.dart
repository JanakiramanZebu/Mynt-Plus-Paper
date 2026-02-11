import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../provider/thems.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import '../../../sharedWidget/custom_back_btn.dart';


class MFSIPSCREENWeb extends StatefulWidget {
  final VoidCallback? onBack;
  const MFSIPSCREENWeb({super.key, this.onBack});

  @override
  State<MFSIPSCREENWeb> createState() => _MFSIPSCREENState();
}

class _MFSIPSCREENState extends State<MFSIPSCREENWeb> {
  // Controllers
  late TextEditingController _principalCtrl;
  late TextEditingController _interestCtrl;
  late TextEditingController _tenureCtrl;

  // State variables matches the sliders
  double _sliderPrincipalAmount = 10000.0;
  double _sliderInterestRate = 10.0;
  double _sliderTenureYears = 2.0;

  // Calculation Results
  int _totalAmount = 0;
  int _investedAmount = 0;
  int _returns = 0;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    _principalCtrl =
        TextEditingController(text: _sliderPrincipalAmount.round().toString());
    _interestCtrl =
        TextEditingController(text: _sliderInterestRate.round().toString());
    _tenureCtrl =
        TextEditingController(text: _sliderTenureYears.round().toString());

    calculateSIP();
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _interestCtrl.dispose();
    _tenureCtrl.dispose();
    super.dispose();
  }

  void calculateSIP() {
    try {
      // Parse inputs
      double principal = double.tryParse(_principalCtrl.text) ?? 0;
      double rate = double.tryParse(_interestCtrl.text) ?? 0;
      double tenure = double.tryParse(_tenureCtrl.text) ?? 0;

      // Basic Validation
       if (principal <= 0) {
         setState(() {
          _totalAmount = 0;
          _investedAmount = 0;
          _returns = 0;
        });
        return;
      }

      // Calculation Logic
      // Monthly Interest Rate
      double monthlyRate = rate / (100 * 12);
      // Total Months
      int months = (tenure * 12).toInt();

      if (monthlyRate > 0 && months > 0) {
        // Formula: P * ({[1 + i]^n - 1} / i) * (1 + i)
        // P = Amount, i = monthlyRate, n = months

        double first = pow(1 + monthlyRate, months) - 1;
        double second = first / monthlyRate;
        double finalVal = principal * second * (1 + monthlyRate);

        setState(() {
          _totalAmount = finalVal.round();
          _investedAmount = (principal * months).toInt();
          _returns = (_totalAmount - _investedAmount);
        });
      } else {
         // Fallback if rate is 0 (just Principal * Months)
         setState(() {
            _investedAmount = (principal * months).toInt();
            _totalAmount = _investedAmount;
            _returns = 0;
        });
      }

    } catch (e) {
      debugPrint("Calculation error: $e");
    }
  }

  void _onPrincipalChanged(String value) {
    if (value.isEmpty) return;
    double? val = double.tryParse(value);
    if (val != null) {
      setState(() {
        _sliderPrincipalAmount = val.clamp(1, 1000000);
      });
      calculateSIP();
    }
  }

  void _onInterestChanged(String value) {
     if (value.isEmpty) return;
    double? val = double.tryParse(value);
    if (val != null) {
      setState(() {
        _sliderInterestRate = val.clamp(1, 30);
      });
      calculateSIP();
    }
  }

  void _onTenureChanged(String value) {
     if (value.isEmpty) return;
    double? val = double.tryParse(value);
    if (val != null) {
      setState(() {
        _sliderTenureYears = val.clamp(1, 40);
      });
      calculateSIP();
    }
  }

  String _formattingNumber(int number) {
     RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
     return number.toString().replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      ref.watch(themeProvider);

      // Chart colors using MyntColors
      final principalColor = resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary);
      final interestColor = resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textPrimary,
      );
      final totalColor = resolveThemeColor(
        context,
        dark: MyntColors.profitDark,
        light: MyntColors.profit,
      );

      final List<ChartData> donutChart = [
        ChartData('Principal', _investedAmount.toDouble(), principalColor),
        ChartData('Interest', _returns.toDouble(), interestColor),
      ];

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
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
                      size: 18,
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: double.infinity),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SIP Calculator",
                      style: MyntWebTextStyles.title(context, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Want to see how your SIP adds up over time? This shows you the full picture - step by step.",
                      style: MyntWebTextStyles.para(
                        context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: MyntColors.textSecondary,
                      ).copyWith(fontSize: 13),
                      maxLines: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content Row
                LayoutBuilder(builder: (context, constraints) {
                  // Use column on small screens, row on large
                  if (constraints.maxWidth < 700) {
                    return Column(
                      children: [
                        _buildInputSection(context),
                        const SizedBox(height: 40),
                        _buildEstimationSection(donutChart, totalColor, principalColor, interestColor, context),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildInputSection(context),
                      ),
                      const SizedBox(width: 40),
                       Expanded(
                        flex: 6,
                        child: _buildEstimationSection(donutChart, totalColor, principalColor, interestColor, context),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Principal Amount
        Text("Principal Amount",
            style: MyntWebTextStyles.title(context,
                    fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 6,
              child: MyntTextField(
                controller: _principalCtrl,
                placeholder: '10000',
                leadingIcon: assets.ruppeIcon,
                leadingIconHoverEffect: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                   FilteringTextInputFormatter.digitsOnly
                 ],
                onChanged: _onPrincipalChanged,
              ),
            ),
            const Spacer(flex: 6),
          ],
        ),

        const SizedBox(height: 32),

        // Interest Rate
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Interest Rate (p.a.)",
                style: MyntWebTextStyles.title(context,
                    fontWeight: FontWeight.w500)),
             SizedBox(
               width: 100,
               child: Stack(
                 children: [
                   MyntTextField(
                     controller: _interestCtrl,
                     placeholder: '10',
                     textAlign: TextAlign.center,
                     keyboardType: TextInputType.number,
                     onChanged: _onInterestChanged,
                   ),
                   Positioned(
                     right: 12,
                     top: 0,
                     bottom: 0,
                     child: Center(
                       child: IgnorePointer(
                         child: Text(
                           "%",
                           style: MyntWebTextStyles.bodySmall(
                             context,
                             color: resolveThemeColor(
                               context,
                               dark: MyntColors.textSecondaryDark,
                               light: MyntColors.textSecondary,
                             ),
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
          context: context,
          value: _sliderInterestRate,
          min: 1,
          max: 30,
          divisions: 290,
          onChanged: (val) {
            setState(() {
              _sliderInterestRate = val;
              _interestCtrl.text =
                  val.toStringAsFixed(0);
            });
            calculateSIP();
          },
        ),

        const SizedBox(height: 32),

        // Tenure Period
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text("Tenure period",
                style: MyntWebTextStyles.title(context,
                    fontWeight: FontWeight.w500)),
             SizedBox(
               width: 100,
               child: Stack(
                 children: [
                   MyntTextField(
                     controller: _tenureCtrl,
                     placeholder: '2',
                     textAlign: TextAlign.center,
                     keyboardType: TextInputType.number,
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
                             color: resolveThemeColor(
                               context,
                               dark: MyntColors.textSecondaryDark,
                               light: MyntColors.textSecondary,
                             ),
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
          context: context,
          value: _sliderTenureYears,
          min: 1,
          max: 40,
          divisions: 39,
          onChanged: (val) {
            setState(() {
              _sliderTenureYears = val;
              _tenureCtrl.text = val.toStringAsFixed(0);
            });
            calculateSIP();
          },
        ),
      ],
    );
  }

  Widget _buildCustomSlider({
    required BuildContext context,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 6.0,
        activeTrackColor:  resolveThemeColor(context, dark: MyntColors.primaryDark,light: MyntColors.primary.withOpacity(0.5)),
        inactiveTrackColor: resolveThemeColor(
          context,
          dark: MyntColors.dividerDark,
          light: MyntColors.divider,
        ),
        thumbColor:resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary),
        overlayColor: resolveThemeColor(context, dark: MyntColors.primaryDark.withOpacity(0.1),light: MyntColors.primary.withOpacity(0.1)),
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
    List<ChartData> data,
    Color totalColor,
    Color principalColor,
    Color interestColor,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Estimation",
          style: MyntWebTextStyles.title(context, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
             // Chart
            SizedBox(
              width: 300,
              height: 300,
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                series: <CircularSeries>[
                  // Outer Ring (Total Amount - Green)
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
                  // Inner Ring (Principal vs Interest)
                  DoughnutSeries<ChartData, String>(
                    radius: '82%',
                    innerRadius: '68%',
                    dataSource: data,
                    pointColorMapper: (ChartData data, _) => data.color,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    cornerStyle: CornerStyle.bothFlat,
                    strokeWidth: 0,
                  ),
                ],
              ),
            ),
             const SizedBox(width: 40),
            // Legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    "Principal Amount",
                    _investedAmount,
                    principalColor,
                    context,
                  ),
                  const SizedBox(height: 24),
                  _buildLegendItem(
                    "Total Interest",
                    _returns,
                    interestColor,
                    context,
                  ),
                   const SizedBox(height: 24),
                   _buildLegendItem(
                    "Total Amount",
                    _totalAmount,
                    totalColor,
                    context,
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(
      String label, int value, Color color, BuildContext context) {
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
              "\u20B9 ${_formattingNumber(value)}",
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
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
