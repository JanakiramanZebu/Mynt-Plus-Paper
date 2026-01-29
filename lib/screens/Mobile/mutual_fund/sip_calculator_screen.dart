import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../provider/thems.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

class MFSIPSCREEN extends StatefulWidget {
  final VoidCallback? onBack;
  const MFSIPSCREEN({super.key, this.onBack});

  @override
  State<MFSIPSCREEN> createState() => _MFSIPSCREENState();
}

class _MFSIPSCREENState extends State<MFSIPSCREEN> {
  double _interestRate = 10.0;
  double _tenureYears = 12.0;
  final TextEditingController _principalCtrl = TextEditingController(text: '25000');

  int _totalAmount = 0;
  int _investedAmount = 0;
  int _returns = 0;

  double _sliderPrincipalAmount = 25000.0; // Match initial text controller value

  @override
  void initState() {
    super.initState();
    calculateSIP();
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    super.dispose();
  }

  void calculateSIP() {
    try {
      int principal = int.tryParse(_principalCtrl.text) ?? 0;

      if (principal <= 0) {
        setState(() {
          _totalAmount = 0;
          _investedAmount = 0;
          _returns = 0;
        });
        return;
      }

      if (principal >= 100000) {
          error(context, "Please enter an amount below ₹1,00,000."
        );
        // Reset to a valid value
        _principalCtrl.text = "99999";
        principal = 99999;
        _sliderPrincipalAmount = 99999;
      }

      double interestRate = _interestRate / (100 * 12);
      int tenureMonths = (_tenureYears * 12).toInt();

      if (interestRate > 0 && tenureMonths > 0 && principal <= pow(10, 9) &&
          interestRate <= (50 / (100 * 12)) && tenureMonths <= 50 * 12) {

        double first = 1 + interestRate;
        double second = pow(first, tenureMonths) - 1;
        double third = second / interestRate;
        double fourth = 1 + interestRate;
        double cofinal = third * fourth;
        double finalAmount = cofinal * principal;

        int estimatedReturn = (finalAmount - (principal * tenureMonths)).round();

        setState(() {
          _totalAmount = finalAmount.round();
          _investedAmount = principal * tenureMonths;
          _returns = estimatedReturn;
        });
      } else {
        setState(() {
          _totalAmount = 0;
          _investedAmount = 0;
          _returns = 0;
        });
      }
    } catch (e) {
      // Handle calculation errors
      setState(() {
        _totalAmount = 0;
        _investedAmount = 0;
        _returns = 0;
      });
        error(context, "Calculation error: ${e.toString()}"
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final isDarkMode = theme.isDarkMode;

      final List<ChartData> donutChart = [
        ChartData('Returns', double.parse("$_returns"), const Color(0xff015FEC)),
        ChartData('Investment', double.parse("$_investedAmount"), colors.colorBlack)
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
              "SIP Calculator",
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
                          // Principal Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Principal Amount",
                                style: MyntWebTextStyles.bodyMedium(
                                  context,
                                  color: isDarkMode
                                      ? WebColors.textPrimaryDark
                                      : WebColors.textPrimary,
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
                                    if (value.isNotEmpty) {
                                      final parsedValue = double.tryParse(value);
                                      if (parsedValue != null) {
                                        setState(() {
                                          _sliderPrincipalAmount = parsedValue.clamp(1, 100000);
                                        });
                                      }
                                    }
                                    calculateSIP();
                                  },
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Principal Amount Slider
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
                            child: Slider(
                              value: _sliderPrincipalAmount,
                              min: 1,
                              max: 100000,
                              divisions: 100000,
                              label: _sliderPrincipalAmount.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _sliderPrincipalAmount = value;
                                  _principalCtrl.text = value.round().toString();
                                });
                                calculateSIP();
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Interest Rate
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Interest Rate (p.a.)",
                                style: MyntWebTextStyles.bodyMedium(
                                  context,
                                  color: isDarkMode
                                      ? WebColors.textPrimaryDark
                                      : WebColors.textPrimary,
                                ),
                              ),
                              Text(
                                "${_interestRate.toStringAsFixed(0)}%",
                                style: MyntWebTextStyles.bodyMedium(
                                  context,
                                  color: isDarkMode
                                      ? WebColors.textPrimaryDark
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Interest Rate Slider
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
                            child: Slider(
                              value: _interestRate.clamp(1, 20),
                              min: 1,
                              max: 20,
                              divisions: 19,
                              label: "${_interestRate.toStringAsFixed(0)}%",
                              onChanged: (value) {
                                setState(() => _interestRate = value);
                                calculateSIP();
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tenure Period
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tenure Period (Years)",
                                style: MyntWebTextStyles.bodyMedium(
                                  context,
                                  color: isDarkMode
                                      ? WebColors.textPrimaryDark
                                      : WebColors.textPrimary,
                                ),
                              ),
                              Text(
                                "${_tenureYears.toStringAsFixed(0)} Yr",
                                style: MyntWebTextStyles.bodyMedium(
                                  context,
                                  color: isDarkMode
                                      ? WebColors.textPrimaryDark
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Tenure Slider
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
                                calculateSIP();
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
                                      ? WebColors.textPrimaryDark
                                      : WebColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Result Values
                              resultRow("Principal Amount", _investedAmount, const Color(0xff015FEC), theme, context),
                              const SizedBox(height: 8),
                              resultRow("Total Interest", _returns, const Color.fromARGB(255, 114, 192, 169), theme, context),
                              const SizedBox(height: 8),
                              resultRow("Total Amount", _totalAmount, const Color(0xff6eb94b), theme, context),
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
                                        'Total',
                                        textAlign: TextAlign.center,
                                        style: MyntWebTextStyles.para(
                                          context,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "₹ $_totalAmount",
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

  Widget resultRow(String label, int value, Color iconColor, ThemesProvider theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.circle,
                  color: iconColor,
                  size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: MyntWebTextStyles.bodyMedium(
                  context,
                  color: theme.isDarkMode
                      ? WebColors.textPrimaryDark
                      : WebColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            "₹ ${value.toStringAsFixed(0)}",
            style: MyntWebTextStyles.bodyMedium(
              context,
              color: theme.isDarkMode
                  ? WebColors.textPrimaryDark
                  : WebColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
