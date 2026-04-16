import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/Mobile/authentication/password/forgot_pass_unblock_user.dart';
import 'package:mynt_plus/sharedWidget/cust_text_formfield.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/custom_back_btn.dart';

class MFSIPSCREEN extends StatefulWidget {
  const MFSIPSCREEN({super.key});

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

      final List<ChartData> donutChart = [
        ChartData('Returns', double.parse("${_returns}"), const Color(0xff015FEC)),
        ChartData('Investment', double.parse("${_investedAmount}"), colors.colorBlack)
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
              text: "SIP Calculator",
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 1,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartSection(theme, donutChart),
                  const SizedBox(height: 16),
                  _buildPrincipalSection(theme),
                  const SizedBox(height: 20),
                  _buildInterestRateSection(theme),
                  const SizedBox(height: 16),
                  _buildTenureSection(theme),
                  const SizedBox(height: 16),
                  _buildResultsSection(theme),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildChartSection(ThemesProvider theme, List<ChartData> donutChart) {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xff6eb94b), 
          width: 12
        )
      ),
      height: 230,
      child: SfCircularChart(
        margin: EdgeInsets.zero, 
        series: [
          DoughnutSeries<ChartData, String>(
            radius: "96",
            dataSource: donutChart,
            pointColorMapper: (ChartData data, _) => data.color,
            dataLabelMapper: (ChartData data, _) => 
              data.y > 0 ? "${(data.y / (_totalAmount > 0 ? _totalAmount : 1) * 100).toStringAsFixed(1)}%" : "0%",
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: textStyle(
                !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                12,
                FontWeight.w600
              )
            ),
            innerRadius: "70%"
          )
        ]
      )
    );
  }

  Widget _buildPrincipalSection(ThemesProvider theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: "Principal Amount",
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 1,
            ),
            Container(
              width: 150,
              height: 40,
              child: CustomTextFormField(
                textAlign: TextAlign.start,
                fillColor: theme.isDarkMode
                    ? colors.darkGrey
                    : const Color(0xffF1F3F8),
                      style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                hintText: '10000',
                 hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                fw: 0,
                                    ),
                textCtrl: _principalCtrl,
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
      ],
    );
  }

  Widget _buildInterestRateSection(ThemesProvider theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: "Interest Rate (p.a.)",
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 1,
            ),
            TextWidget.subText(
              text: "${_interestRate.toStringAsFixed(0)}%",
              color:  theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 0,
            ),
          ],
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }

  Widget _buildTenureSection(ThemesProvider theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: "Tenure Period (Years)",
             color :   theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 1,
            ),
            TextWidget.subText(
              text: "${_tenureYears.toStringAsFixed(0)} Yr",
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 0,
            ),
          ],
        ),
        const SizedBox(height: 16),
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
          child: Slider(
            value: _tenureYears.clamp(1, 50),
            min: 1,
            max: 50,
            divisions: 49,
            label: "${_tenureYears.toStringAsFixed(0)} years",
            onChanged: (value) {
              setState(() => _tenureYears = value);
              calculateSIP();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: "Estimation",
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw :1
          
        ),
        const SizedBox(height: 16),
        resultRow("Principal Amount", _investedAmount, const Color(0xff015FEC), theme),
        resultRow("Total Interest", _returns, const Color.fromARGB(255, 114, 192, 169), theme),
        resultRow("Total Amount", _totalAmount, const Color(0xff6eb94b), theme),
      ],
    );
  }

  Widget resultRow(String label, int value, Color iconColor, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                color: iconColor,
                size: 14
              ),
              const SizedBox(width: 4),
              TextWidget.subText(
                text: label,
                color:  theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                theme: false,
                fw: 0,
              ),
            ],
          ),
          TextWidget.subText(
            text: "₹ ${value.toStringAsFixed(0)}",
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            theme: false, 
            fw: 0,
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
