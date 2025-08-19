import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';
import 'package:mynt_plus/screens/mutual_fund/widget/allocation.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../provider/thems.dart';
import 'package:mynt_plus/sharedWidget/cust_text_formfield.dart';

import '../../res/global_state_text.dart';
import '../../sharedWidget/custom_back_btn.dart';

class MFCAGRCAL extends StatefulWidget {
  const MFCAGRCAL({super.key});

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
            leading: const CustomBackBtn(),
            title: TextWidget.titleText(
              text: "CAGR Calculator",
              theme: isDarkMode,
              fw: 1,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CAGR Donut Chart
                  Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    height: 230,
                    child: SfCircularChart(
                      margin: EdgeInsets.zero,
                      annotations: <CircularChartAnnotation>[
                        CircularChartAnnotation(
                          widget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextWidget.paraText(
                                text: 'CAGR',
                                align: TextAlign.center,
                                color: Colors.grey,
                                theme: false,
                                fw: 0,
                              ),
                              const SizedBox(height: 4),
                              TextWidget.titleText(
                                text: "$_cagrResult %",
                                align: TextAlign.center,
                                color: colors.colorBlack,
                                theme: false,
                                fw: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                      series: <DoughnutSeries<ChartData, String>>[
                        DoughnutSeries<ChartData, String>(
                          animationDuration: 0,
                          radius: '96',
                          innerRadius: '70%',
                          dataSource: donutChart,
                          pointColorMapper: (ChartData data, _) => data.color,
                          dataLabelMapper: (ChartData data, _) => '${data.y}%',
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            textStyle: textStyle(
                              !isDarkMode ? colors.colorWhite : colors.colorBlack,
                              0,
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                  const SizedBox(height: 16),
                
                  // Initial Investment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget.subText(
                        text: "Initial Investment",
                        color: isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: isDarkMode,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 150,
                        height: 40,
                        child: CustomTextFormField(
                          textAlign: TextAlign.start,
                          fillColor: isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          hintText: '10000',
                          textCtrl: _principalCtrl,
                        style: TextWidget.textStyle(
                                      fontSize: 16,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      theme: theme.isDarkMode,
                                    ),
                                     hintStyle: TextWidget.textStyle(
                                        fontSize: 14,
                                        theme: theme.isDarkMode,
                                       color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                                      ),
                          prefixIcon: SvgPicture.asset(
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            assets.ruppeIcon,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      )
                    ],
                  ),
                
                  const SizedBox(height: 6),
                
                  // Initial Investment Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                     activeTrackColor:  theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              inactiveTrackColor: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.3) :   colors.textSecondaryLight.withOpacity(0.1),
              thumbColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
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
                      TextWidget.subText(
                        text: "Final Investment",
                        color: isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: isDarkMode,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 150,
                        height: 40,
                        child: CustomTextFormField(
                          textAlign: TextAlign.start,
                          fillColor: isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                               hintStyle: TextWidget.textStyle(
                                        fontSize: 14,
                                        theme: theme.isDarkMode,
                                       color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                                      ),
                          hintText: '10000',
                          textCtrl: _finalAmountCtrl,
                         style: TextWidget.textStyle(
                                      fontSize: 16,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      theme: theme.isDarkMode,
                                    ),
                          prefixIcon: SvgPicture.asset(
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            assets.ruppeIcon,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      )
                    ],
                  ),
                
                  const SizedBox(height: 6),
                
                  // Final Investment Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                     activeTrackColor:  theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              inactiveTrackColor: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.3) :   colors.textSecondaryLight.withOpacity(0.1),
              thumbColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
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
                      TextWidget.subText(
                        text: "Duration of Investment (Years)",
                        color: isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: isDarkMode,
                      ),
                      TextWidget.subText(
                        text: "${_tenureYears.toStringAsFixed(0)} Yr",
                        color: isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: isDarkMode,
                      ),
                    ],
                  ),
                
                  const SizedBox(height: 16),
                
                  // Duration Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                     activeTrackColor:  theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              inactiveTrackColor: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.3) :   colors.textSecondaryLight.withOpacity(0.1),
              thumbColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                      overlayColor: const Color(0xFFCCCCCC),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 0.0),
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
                      TextWidget.subText(
                        text: "Estimation",
                        color: isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: isDarkMode,
                        fw: 0,
                      ),
                      const SizedBox(height: 16),
                
                      // Initial and Final Values
                      resultRow("Initial Value",
                          int.tryParse(_principalCtrl.text) ?? 0, theme),
                      resultRow("Final Value",
                          int.tryParse(_finalAmountCtrl.text) ?? 0, theme),
                      const SizedBox(height: 4),
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

  Widget resultRow(String label, int value, ThemesProvider theme) {
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
              TextWidget.subText(
                text: label,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                theme: theme.isDarkMode,
              ),
            ],
          ),
          TextWidget.subText(
            text: "₹ ${value.toStringAsFixed(0)}",
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            theme: theme.isDarkMode,
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
